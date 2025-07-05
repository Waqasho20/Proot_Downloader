# 🔌 API Documentation

This document describes the API integration used by Parrot Downloader to fetch video information from Facebook and Instagram.

## Overview

Parrot Downloader uses a third-party API service to extract video metadata and download URLs from social media platforms. The API provides a unified interface for multiple platforms.

## Base Configuration

### Endpoint
```
https://tera.backend.live/allinone
```

### Authentication
The API uses API key authentication via headers:

```dart
final headers = {
  "x-api-key": "pxrAEVHPV2S0yczPyv9bE9n8JryVwJAw",
  "content-type": "application/json; charset=utf-8",
  "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
};
```

## Request Format

### HTTP Method
`POST`

### Request Body
```json
{
  "url": "https://www.facebook.com/video/url/here"
}
```

### Example Request
```dart
final payload = {
  "url": "https://www.instagram.com/p/example123/"
};

final response = await dio.post(
  "https://tera.backend.live/allinone",
  data: jsonEncode(payload),
  options: Options(headers: headers),
);
```

## Response Format

### Successful Response (200 OK)

```json
{
  "title": "Video Title",
  "thumbnail": "https://example.com/thumbnail.jpg",
  "video": [
    {
      "url": "https://example.com/video_hd.mp4",
      "quality": "HD",
      "resolution": "1280x720",
      "format": "mp4",
      "fileSize": 15728640
    },
    {
      "url": "https://example.com/video_sd.mp4",
      "quality": "SD",
      "resolution": "640x480",
      "format": "mp4",
      "fileSize": 7864320
    }
  ],
  "audio": "https://example.com/audio.mp3",
  "description": "Video description text",
  "author": "Content Creator Name",
  "duration": 120,
  "platform": "Instagram"
}
```

### Alternative Response Formats

The API may return different response structures depending on the platform:

#### Format 1: Array of Videos
```json
{
  "title": "Video Title",
  "video": [
    {
      "downloadUrl": "https://example.com/video.mp4",
      "quality": "720p",
      "ext": "mp4"
    }
  ]
}
```

#### Format 2: Formats Array
```json
{
  "title": "Video Title",
  "formats": [
    {
      "url": "https://example.com/video.mp4",
      "resolution": "1080p",
      "format": "mp4",
      "size": 20971520
    }
  ]
}
```

## Response Fields

### Core Fields
| Field | Type | Description |
|-------|------|-------------|
| `title` | String | Video title or caption |
| `thumbnail` | String | Thumbnail image URL |
| `video` | Array | Array of video quality options |
| `audio` | String | Audio-only download URL |
| `description` | String | Video description or caption |
| `author` | String | Content creator username |
| `duration` | Integer | Video duration in seconds |
| `platform` | String | Source platform (Facebook/Instagram) |

### Video Quality Object
| Field | Type | Description |
|-------|------|-------------|
| `url` | String | Direct download URL |
| `quality` | String | Quality label (HD, SD, 720p, etc.) |
| `resolution` | String | Video resolution (1280x720) |
| `format` | String | File format (mp4, mov, etc.) |
| `fileSize` | Integer | File size in bytes |

## Error Handling

### HTTP Status Codes

#### 400 Bad Request
Invalid URL or unsupported platform
```json
{
  "error": "Invalid URL format",
  "message": "The provided URL is not supported"
}
```

#### 429 Too Many Requests
Rate limit exceeded
```json
{
  "error": "Rate limit exceeded",
  "message": "Please wait before making another request"
}
```

#### 500 Internal Server Error
Server-side processing error
```json
{
  "error": "Processing failed",
  "message": "Unable to extract video information"
}
```

### Client-Side Error Handling

```dart
try {
  final response = await _dio.post(apiUrl, data: payload);
  
  if (response.statusCode == 200) {
    return DownloadResult.fromJson(response.data);
  }
} on DioException catch (e) {
  if (e.response?.statusCode == 400) {
    throw Exception('Invalid URL or unsupported platform');
  } else if (e.response?.statusCode == 429) {
    throw Exception('Too many requests. Please wait and try again.');
  } else {
    throw Exception('Network error: ${e.message}');
  }
}
```

## Supported Platforms

### Facebook
- **Domains**: facebook.com, fb.com
- **URL Formats**: 
  - `https://www.facebook.com/video/123456789`
  - `https://fb.com/video/123456789`
  - `https://www.facebook.com/username/videos/123456789`

### Instagram
- **Domains**: instagram.com, instagr.am
- **URL Formats**:
  - `https://www.instagram.com/p/ABC123DEF/`
  - `https://instagr.am/p/ABC123DEF/`
  - `https://www.instagram.com/reel/ABC123DEF/`

## Rate Limiting

### Limits
- **Requests per minute**: 60
- **Requests per hour**: 1000
- **Requests per day**: 10000

### Best Practices
1. Implement exponential backoff for retries
2. Cache responses when possible
3. Validate URLs client-side before API calls
4. Handle rate limit errors gracefully

## Implementation Example

### Complete Service Implementation

```dart
class DownloadService {
  static const String _apiUrl = "https://tera.backend.live/allinone";
  static const String _apiKey = "pxrAEVHPV2S0yczPyv9bE9n8JryVwJAw";
  
  final Dio _dio = Dio();

  DownloadService() {
    _dio.options.headers = {
      "x-api-key": _apiKey,
      "content-type": "application/json; charset=utf-8",
      "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    };
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<DownloadResult> getDownloadInfo(String url) async {
    if (!_isValidUrl(url)) {
      throw Exception('Please enter a valid Facebook or Instagram URL');
    }

    final payload = {"url": url.trim()};
    
    try {
      final response = await _dio.post(_apiUrl, data: jsonEncode(payload));
      
      if (response.statusCode == 200) {
        return DownloadResult.fromJson(response.data);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  bool _isValidUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('facebook.com') || 
           lowerUrl.contains('fb.com') || 
           lowerUrl.contains('instagram.com') ||
           lowerUrl.contains('instagr.am');
  }

  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      throw Exception('Connection timeout. Please check your internet connection.');
    } else if (e.response?.statusCode == 400) {
      throw Exception('Invalid URL or unsupported platform');
    } else if (e.response?.statusCode == 429) {
      throw Exception('Too many requests. Please wait and try again.');
    } else {
      throw Exception('Network error: ${e.message ?? 'Unknown error'}');
    }
  }
}
```

## Security Considerations

### API Key Protection
- Store API keys securely
- Use environment variables in production
- Implement key rotation if needed

### URL Validation
- Validate URLs client-side before API calls
- Sanitize user input
- Implement domain whitelist

### Data Privacy
- Don't log sensitive user data
- Implement proper error messages without exposing internal details
- Follow platform terms of service

## Testing

### Unit Tests
```dart
void main() {
  group('DownloadService', () {
    test('should validate Facebook URLs', () {
      final service = DownloadService();
      expect(service.isValidUrl('https://facebook.com/video/123'), true);
      expect(service.isValidUrl('https://example.com'), false);
    });

    test('should handle API errors gracefully', () async {
      // Mock API error response
      // Test error handling
    });
  });
}
```

### Integration Tests
```dart
void main() {
  testWidgets('should fetch video info from API', (tester) async {
    // Test complete API integration flow
  });
}
```

## Monitoring and Analytics

### Key Metrics
- API response times
- Success/failure rates
- Popular platforms
- Error types and frequencies

### Logging
```dart
if (kDebugMode) {
  print('API Request: $payload');
  print('API Response: ${response.statusCode}');
}
```

## Future Enhancements

### Planned Features
1. **Additional Platforms**: YouTube, TikTok, Twitter
2. **Batch Processing**: Multiple URLs at once
3. **Quality Preferences**: User-defined quality settings
4. **Offline Mode**: Cache video metadata

### API Improvements
1. **WebSocket Support**: Real-time progress updates
2. **GraphQL**: More efficient data fetching
3. **CDN Integration**: Faster thumbnail loading
4. **Compression**: Reduced bandwidth usage

---

For technical support or API-related questions, please contact the development team.

