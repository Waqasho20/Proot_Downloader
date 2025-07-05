import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class FileDownloadService {
  final Dio _dio = Dio();
  
  FileDownloadService() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(minutes: 10);
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status != PermissionStatus.granted) {
        // Try requesting manage external storage for Android 11+
        final manageStatus = await Permission.manageExternalStorage.request();
        return manageStatus == PermissionStatus.granted;
      }
      return true;
    }
    return true; // iOS doesn't need explicit storage permission for app documents
  }

  Future<String> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // Try to get external storage directory
      try {
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          final downloadDir = Directory('${directory.path}/ParrotDownloader');
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          return downloadDir.path;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error accessing external storage: $e');
        }
      }
    }
    
    // Fallback to app documents directory
    final directory = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${directory.path}/Downloads');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir.path;
  }

  Future<DownloadProgress> downloadFile({
    required String url,
    required String fileName,
    Function(int received, int total)? onProgress,
  }) async {
    try {
      // Request storage permission
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Get download directory
      final downloadDir = await getDownloadDirectory();
      
      // Ensure filename has proper extension
      if (!fileName.toLowerCase().endsWith('.mp4') && 
          !fileName.toLowerCase().endsWith('.mov') &&
          !fileName.toLowerCase().endsWith('.avi')) {
        fileName = '$fileName.mp4';
      }

      // Create unique filename if file already exists
      String finalFileName = fileName;
      String filePath = path.join(downloadDir, finalFileName);
      int counter = 1;
      
      while (await File(filePath).exists()) {
        final nameWithoutExt = path.basenameWithoutExtension(fileName);
        final extension = path.extension(fileName);
        finalFileName = '${nameWithoutExt}_$counter$extension';
        filePath = path.join(downloadDir, finalFileName);
        counter++;
      }

      if (kDebugMode) {
        print('Downloading to: $filePath');
      }

      // Start download
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (onProgress != null && total != -1) {
            onProgress(received, total);
          }
        },
      );

      // Verify file was downloaded
      final file = File(filePath);
      if (await file.exists()) {
        final fileSize = await file.length();
        return DownloadProgress(
          filePath: filePath,
          fileName: finalFileName,
          isCompleted: true,
          progress: 1.0,
          downloadedBytes: fileSize,
          totalBytes: fileSize,
        );
      } else {
        throw Exception('Download failed - file not found');
      }

    } on DioException catch (e) {
      if (kDebugMode) {
        print('Download error: ${e.message}');
      }
      
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout during download');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Download timeout');
      } else {
        throw Exception('Download failed: ${e.message ?? 'Unknown error'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('General download error: $e');
      }
      throw Exception('Download failed: ${e.toString()}');
    }
  }

  Future<List<DownloadedFile>> getDownloadedFiles() async {
    try {
      final downloadDir = await getDownloadDirectory();
      final directory = Directory(downloadDir);
      
      if (!await directory.exists()) {
        return [];
      }

      final files = await directory.list().toList();
      final downloadedFiles = <DownloadedFile>[];

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          final fileName = path.basename(file.path);
          
          // Only include video files
          if (_isVideoFile(fileName)) {
            downloadedFiles.add(DownloadedFile(
              name: fileName,
              path: file.path,
              size: stat.size,
              downloadDate: stat.modified,
            ));
          }
        }
      }

      // Sort by download date (newest first)
      downloadedFiles.sort((a, b) => b.downloadDate.compareTo(a.downloadDate));
      
      return downloadedFiles;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting downloaded files: $e');
      }
      return [];
    }
  }

  bool _isVideoFile(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    return ['.mp4', '.mov', '.avi', '.mkv', '.flv', '.wmv', '.webm'].contains(extension);
  }

  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting file: $e');
      }
      return false;
    }
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class DownloadProgress {
  final String? filePath;
  final String? fileName;
  final bool isCompleted;
  final double progress;
  final int downloadedBytes;
  final int totalBytes;
  final String? error;

  DownloadProgress({
    this.filePath,
    this.fileName,
    required this.isCompleted,
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
    this.error,
  });

  String get progressText {
    if (error != null) return 'Error: $error';
    if (isCompleted) return 'Completed';
    return '${(progress * 100).toInt()}%';
  }
}

class DownloadedFile {
  final String name;
  final String path;
  final int size;
  final DateTime downloadDate;

  DownloadedFile({
    required this.name,
    required this.path,
    required this.size,
    required this.downloadDate,
  });

  String get displayName {
    // Remove file extension and clean up name
    final nameWithoutExt = path.split('.').first;
    return nameWithoutExt.replaceAll('_', ' ').trim();
  }

  String get sizeText {
    final service = FileDownloadService();
    return service.formatFileSize(size);
  }

  String get dateText {
    final now = DateTime.now();
    final difference = now.difference(downloadDate);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

