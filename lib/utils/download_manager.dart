import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();

  final List<DownloadTask> _activeTasks = [];
  final List<DownloadTask> _completedTasks = [];

  List<DownloadTask> get activeTasks => List.unmodifiable(_activeTasks);
  List<DownloadTask> get completedTasks => List.unmodifiable(_completedTasks);

  Future<bool> checkPermissions() async {
    if (Platform.isAndroid) {
      // Check storage permission
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          // Try requesting manage external storage for Android 11+
          var manageStatus = await Permission.manageExternalStorage.status;
          if (!manageStatus.isGranted) {
            manageStatus = await Permission.manageExternalStorage.request();
            return manageStatus.isGranted;
          }
        }
      }
      return status.isGranted;
    }
    return true; // iOS doesn't need explicit storage permission
  }

  Future<String> getDownloadDirectory() async {
    try {
      if (Platform.isAndroid) {
        // Try to get external storage directory first
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final downloadDir = Directory('${externalDir.path}/ParrotDownloader');
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          return downloadDir.path;
        }
      }
      
      // Fallback to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${appDir.path}/Downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir.path;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting download directory: $e');
      }
      rethrow;
    }
  }

  String generateUniqueFileName(String baseName, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cleanName = baseName.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
    return '${cleanName}_$timestamp.$extension';
  }

  Future<String> getUniqueFilePath(String directory, String fileName) async {
    String filePath = '$directory/$fileName';
    int counter = 1;
    
    while (await File(filePath).exists()) {
      final nameWithoutExt = fileName.split('.').first;
      final extension = fileName.split('.').last;
      filePath = '$directory/${nameWithoutExt}_$counter.$extension';
      counter++;
    }
    
    return filePath;
  }

  void addTask(DownloadTask task) {
    _activeTasks.add(task);
  }

  void updateTaskProgress(String taskId, double progress, int downloaded, int total) {
    final taskIndex = _activeTasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _activeTasks[taskIndex] = _activeTasks[taskIndex].copyWith(
        progress: progress,
        downloadedBytes: downloaded,
        totalBytes: total,
        status: DownloadStatus.downloading,
      );
    }
  }

  void completeTask(String taskId, String filePath) {
    final taskIndex = _activeTasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _activeTasks[taskIndex].copyWith(
        progress: 1.0,
        status: DownloadStatus.completed,
        filePath: filePath,
        completedAt: DateTime.now(),
      );
      
      _activeTasks.removeAt(taskIndex);
      _completedTasks.insert(0, task); // Add to beginning for newest first
      
      _showCompletionToast(task.fileName);
    }
  }

  void failTask(String taskId, String error) {
    final taskIndex = _activeTasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _activeTasks[taskIndex] = _activeTasks[taskIndex].copyWith(
        status: DownloadStatus.failed,
        error: error,
      );
    }
  }

  void removeTask(String taskId) {
    _activeTasks.removeWhere((task) => task.id == taskId);
    _completedTasks.removeWhere((task) => task.id == taskId);
  }

  void clearCompleted() {
    _completedTasks.clear();
  }

  void _showCompletionToast(String fileName) {
    Fluttertoast.showToast(
      msg: 'Download completed: $fileName',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String formatSpeed(int bytesPerSecond) {
    return '${formatFileSize(bytesPerSecond)}/s';
  }
}

enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
  cancelled,
}

class DownloadTask {
  final String id;
  final String fileName;
  final String url;
  final String? filePath;
  final double progress;
  final int downloadedBytes;
  final int totalBytes;
  final DownloadStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? error;

  DownloadTask({
    required this.id,
    required this.fileName,
    required this.url,
    this.filePath,
    this.progress = 0.0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.status = DownloadStatus.pending,
    required this.createdAt,
    this.completedAt,
    this.error,
  });

  DownloadTask copyWith({
    String? id,
    String? fileName,
    String? url,
    String? filePath,
    double? progress,
    int? downloadedBytes,
    int? totalBytes,
    DownloadStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? error,
  }) {
    return DownloadTask(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      url: url ?? this.url,
      filePath: filePath ?? this.filePath,
      progress: progress ?? this.progress,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      error: error ?? this.error,
    );
  }

  String get progressText {
    switch (status) {
      case DownloadStatus.pending:
        return 'Pending...';
      case DownloadStatus.downloading:
        return '${(progress * 100).toInt()}%';
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.failed:
        return 'Failed';
      case DownloadStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get sizeText {
    final manager = DownloadManager();
    if (totalBytes > 0) {
      return '${manager.formatFileSize(downloadedBytes)} / ${manager.formatFileSize(totalBytes)}';
    } else if (downloadedBytes > 0) {
      return manager.formatFileSize(downloadedBytes);
    }
    return 'Unknown size';
  }
}

