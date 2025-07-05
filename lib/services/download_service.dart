import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DownloadService {
  static const String _apiUrl = "https://tera.backend.live/allinone";
  static const String _apiKey = "pxrAEVHPV2S0yczPyv9bE9n8JryVwJAw";
  
  final Dio _dio = Dio();

  DownloadService() {
    _dio.options.headers = {
      "x-api-key": _apiKey,
      "content-type": "application/json; charset=utf-8",
      "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    };
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<DownloadResult> getDownloadInfo(String url) async {
    try {
      if (url.isEmpty) {
        throw Exception('URL cannot be empty');
      }

      // Validate URL format
      if (!_isValidUrl(url)) {
        throw Exception('Please enter a valid Facebook or Instagram URL');
      }

      final payload = {
        "url": url.trim()
      };

      if (kDebugMode) {
        print('Making API request to: $_apiUrl');
        print('Payload: ${jsonEncode(payload)}');
      }

      final response = await _dio.post(
        _apiUrl,
        data: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data == null) {
          throw Exception('No data received from server');
        }

        return DownloadResult.fromJson(data);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Dio error: ${e.message}');
      }
      
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timeout. Please try again.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid URL or unsupported platform');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Too many requests. Please wait and try again.');
      } else {
        throw Exception('Network error: ${e.message ?? 'Unknown error'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('General error: $e');
      }
      throw Exception('Error: ${e.toString()}');
    }
  }

  bool _isValidUrl(String url) {
    // Check if URL contains Facebook or Instagram domains
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('facebook.com') || 
           lowerUrl.contains('fb.com') || 
           lowerUrl.contains('instagram.com') ||
           lowerUrl.contains('instagr.am');
  }
}

class DownloadResult {
  final String? title;
  final String? thumbnail;
  final List<VideoQuality> videoQualities;
  final String? audioUrl;
  final String? description;
  final String? author;
  final int? duration;
  final String? platform;

  DownloadResult({
    this.title,
    this.thumbnail,
    required this.videoQualities,
    this.audioUrl,
    this.description,
    this.author,
    this.duration,
    this.platform,
  });

  factory DownloadResult.fromJson(Map<String, dynamic> json) {
    List<VideoQuality> qualities = [];
    
    // Parse video qualities from different possible response formats
    if (json['video'] != null) {
      if (json['video'] is List) {
        qualities = (json['video'] as List)
            .map((item) => VideoQuality.fromJson(item))
            .toList();
      } else if (json['video'] is Map) {
        // Handle single video object
        qualities = [VideoQuality.fromJson(json['video'])];
      }
    }
    
    // Handle alternative response formats
    if (qualities.isEmpty && json['formats'] != null) {
      qualities = (json['formats'] as List)
          .map((item) => VideoQuality.fromJson(item))
          .toList();
    }

    return DownloadResult(
      title: json['title'] ?? json['caption'] ?? 'Unknown Title',
      thumbnail: json['thumbnail'] ?? json['thumb'] ?? json['image'],
      videoQualities: qualities,
      audioUrl: json['audio'] ?? json['audioUrl'],
      description: json['description'] ?? json['caption'],
      author: json['author'] ?? json['username'] ?? json['uploader'],
      duration: json['duration'],
      platform: json['platform'] ?? _detectPlatform(json['url'] ?? ''),
    );
  }

  static String _detectPlatform(String url) {
    if (url.contains('facebook.com') || url.contains('fb.com')) {
      return 'Facebook';
    } else if (url.contains('instagram.com') || url.contains('instagr.am')) {
      return 'Instagram';
    }
    return 'Unknown';
  }
}

class VideoQuality {
  final String url;
  final String quality;
  final String? format;
  final int? fileSize;
  final String? resolution;

  VideoQuality({
    required this.url,
    required this.quality,
    this.format,
    this.fileSize,
    this.resolution,
  });

  factory VideoQuality.fromJson(Map<String, dynamic> json) {
    return VideoQuality(
      url: json['url'] ?? json['downloadUrl'] ?? '',
      quality: json['quality'] ?? json['resolution'] ?? 'Unknown',
      format: json['format'] ?? json['ext'] ?? 'mp4',
      fileSize: json['fileSize'] ?? json['size'],
      resolution: json['resolution'] ?? json['quality'],
    );
  }

  String get displayName {
    if (resolution != null && resolution!.isNotEmpty) {
      return '$resolution ($format)';
    }
    return '$quality ($format)';
  }
}

