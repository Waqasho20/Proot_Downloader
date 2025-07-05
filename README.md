# 🦜 Parrot Downloader

A powerful and user-friendly Flutter app for downloading and playing videos from Facebook, Instagram, and other social media platforms. Built with a focus on speed, security, and simplicity.

## ✨ Features

### 📱 **Core Functionality**
- **Multi-Platform Support**: Download videos from Facebook and Instagram
- **High-Quality Downloads**: Multiple quality options available
- **No Watermarks**: Clean downloads without platform watermarks
- **Fast & Secure**: Optimized download speeds with secure connections
- **Built-in Video Player**: Watch downloaded videos directly in the app

### 🎯 **User Experience**
- **Minimalist UI**: Clean, intuitive interface
- **Easy URL Input**: Simple paste-and-download workflow
- **Download Management**: Track and manage all your downloads
- **File Organization**: Automatic file organization and naming
- **Share Functionality**: Share downloaded videos with friends

### 🔧 **Technical Features**
- **Offline Playback**: Watch videos without internet connection
- **Storage Management**: Efficient file storage and organization
- **Progress Tracking**: Real-time download progress indicators
- **Error Handling**: Robust error handling and user feedback
- **Permission Management**: Automatic permission handling for storage access

## 📱 Screenshots

### Home Screen
The main interface where users can paste URLs and initiate downloads.

### Downloads Screen
View and manage all downloaded videos with playback options.

### Video Player
Full-featured video player with controls and sharing options.

### Settings Screen
Configure app preferences and view app information.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.16.9 or later)
- Dart SDK (3.2.6 or later)
- Android Studio or VS Code with Flutter extensions
- Android device or emulator (API level 21+)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/parrot_downloader.git
   cd parrot_downloader
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Release

1. **Build APK**
   ```bash
   flutter build apk --release
   ```

2. **Build App Bundle**
   ```bash
   flutter build appbundle --release
   ```

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── screens/                  # UI screens
│   ├── home_screen.dart     # Main download interface
│   ├── downloads_screen.dart # Downloaded files management
│   ├── settings_screen.dart # App settings and info
│   └── video_player_screen.dart # Video playback
├── services/                 # Business logic services
│   ├── download_service.dart # API communication
│   └── file_download_service.dart # File operations
├── widgets/                  # Reusable UI components
│   ├── video_info_card.dart # Video information display
│   └── quality_selector.dart # Quality selection UI
└── utils/                    # Utility classes
    └── download_manager.dart # Download management
```

### Key Components

#### Services
- **DownloadService**: Handles API communication with the backend
- **FileDownloadService**: Manages file downloads and storage
- **DownloadManager**: Coordinates download tasks and progress tracking

#### Screens
- **HomeScreen**: Main interface for URL input and video information
- **DownloadsScreen**: File management and playback initiation
- **VideoPlayerScreen**: Full-featured video playback
- **SettingsScreen**: App configuration and information

#### Widgets
- **VideoInfoCard**: Displays video metadata and thumbnail
- **QualitySelector**: Allows users to choose download quality

## 🔌 API Integration

The app uses a custom API endpoint for video information extraction:

```dart
final api_url = "https://tera.backend.live/allinone";
final headers = {
  "x-api-key": "pxrAEVHPV2S0yczPyv9bE9n8JryVwJAw",
  "content-type": "application/json; charset=utf-8",
  "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
};
```

### Supported Platforms
- Facebook (facebook.com, fb.com)
- Instagram (instagram.com, instagr.am)

## 📦 Dependencies

### Core Dependencies
- **flutter**: UI framework
- **http**: HTTP client for API requests
- **dio**: Advanced HTTP client for file downloads
- **video_player**: Video playback functionality
- **chewie**: Enhanced video player controls

### UI & UX
- **cached_network_image**: Efficient image loading and caching
- **flutter_spinkit**: Loading animations
- **fluttertoast**: User notifications

### File & Storage
- **path_provider**: File system access
- **permission_handler**: Runtime permissions
- **share_plus**: File sharing functionality

### Utilities
- **url_launcher**: External URL handling
- **path**: File path manipulation

## 🔒 Permissions

### Android Permissions
- **INTERNET**: Network access for downloads
- **WRITE_EXTERNAL_STORAGE**: File storage access
- **READ_EXTERNAL_STORAGE**: File reading access
- **MANAGE_EXTERNAL_STORAGE**: Android 11+ storage access
- **ACCESS_NETWORK_STATE**: Network state monitoring
- **WAKE_LOCK**: Prevent sleep during downloads
- **POST_NOTIFICATIONS**: Download completion notifications

## 🎨 Design Principles

### Material Design
The app follows Material Design 3 guidelines with:
- Consistent color scheme (Primary: #2196F3)
- Proper typography hierarchy
- Intuitive navigation patterns
- Responsive layouts

### User Experience
- **Simplicity**: Minimal steps from URL to download
- **Feedback**: Clear progress indicators and status messages
- **Accessibility**: Proper contrast ratios and touch targets
- **Performance**: Optimized for smooth operation

## 🧪 Testing

### Running Tests
```bash
flutter test
```

### Test Coverage
- Widget tests for UI components
- Unit tests for service classes
- Integration tests for complete workflows

## 🚀 Deployment

### Play Store Preparation
1. Update version in `pubspec.yaml`
2. Generate signed APK/AAB
3. Update store listing with screenshots
4. Submit for review

### App Store Preparation
1. Configure iOS-specific settings
2. Generate iOS build
3. Submit via App Store Connect

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Dart/Flutter style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Ensure proper error handling

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Common Issues

**Download fails with permission error**
- Ensure storage permissions are granted
- Check available storage space
- Verify network connection

**Video won't play**
- Check file integrity
- Ensure video format is supported
- Verify file permissions

**API errors**
- Check internet connection
- Verify URL format
- Try again after a few minutes

### Contact
- Email: support@parrotdownloader.com
- GitHub Issues: [Create an issue](https://github.com/yourusername/parrot_downloader/issues)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Video.js for video player inspiration
- Material Design team for design guidelines
- Open source community for various packages

## 📊 Changelog

### Version 1.0.0
- Initial release
- Facebook and Instagram support
- Basic video player
- Download management
- Material Design UI

---

**Made with ❤️ using Flutter**

