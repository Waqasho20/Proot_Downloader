# 🔨 Build Instructions - Parrot Downloader

This document provides step-by-step instructions for building and deploying the Parrot Downloader Flutter app.

## 📋 Prerequisites

### System Requirements
- **Operating System**: Windows 10+, macOS 10.14+, or Linux (Ubuntu 18.04+)
- **RAM**: Minimum 8GB (16GB recommended)
- **Storage**: At least 10GB free space
- **Internet**: Stable connection for downloading dependencies

### Required Software

#### 1. Flutter SDK
```bash
# Download Flutter SDK (version 3.16.9 or later)
# Linux/macOS:
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.9-stable.tar.xz
tar xf flutter_linux_3.16.9-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"

# Add to your shell profile (.bashrc, .zshrc, etc.)
echo 'export PATH="$PATH:/path/to/flutter/bin"' >> ~/.bashrc
```

#### 2. Android Studio
- Download from: https://developer.android.com/studio
- Install Android SDK (API level 21 or higher)
- Install Android SDK Command-line Tools
- Accept Android licenses: `flutter doctor --android-licenses`

#### 3. VS Code (Optional but Recommended)
- Download from: https://code.visualstudio.com/
- Install Flutter extension
- Install Dart extension

### Verify Installation
```bash
flutter doctor
```
Ensure all checkmarks are green before proceeding.

## 🚀 Building the App

### 1. Clone and Setup
```bash
# Clone the repository
git clone <repository-url>
cd parrot_downloader

# Install dependencies
flutter pub get

# Verify project setup
flutter analyze
```

### 2. Development Build

#### Run on Emulator/Device
```bash
# List available devices
flutter devices

# Run in debug mode
flutter run

# Run with specific device
flutter run -d <device-id>

# Hot reload during development
# Press 'r' in terminal or use IDE hot reload
```

#### Debug Build (APK)
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### 3. Release Build

#### Prepare for Release
1. **Update Version**
   ```yaml
   # pubspec.yaml
   version: 1.0.0+1  # Update as needed
   ```

2. **Configure App Signing**
   ```bash
   # Generate keystore (first time only)
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

3. **Create key.properties**
   ```properties
   # android/key.properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=<path-to-keystore>
   ```

4. **Configure build.gradle**
   ```gradle
   // android/app/build.gradle
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

#### Release APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Release App Bundle (Recommended for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### 4. iOS Build (macOS only)

#### Prerequisites
- Xcode 12.0 or later
- iOS 11.0 or later target
- Apple Developer Account (for distribution)

#### Development Build
```bash
flutter build ios --debug
```

#### Release Build
```bash
flutter build ios --release
```

## 📱 Platform-Specific Configuration

### Android Configuration

#### Minimum SDK Version
```gradle
// android/app/build.gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

#### Permissions
Already configured in `android/app/src/main/AndroidManifest.xml`:
- INTERNET
- WRITE_EXTERNAL_STORAGE
- READ_EXTERNAL_STORAGE
- MANAGE_EXTERNAL_STORAGE
- ACCESS_NETWORK_STATE
- WAKE_LOCK
- POST_NOTIFICATIONS

#### ProGuard (Optional)
```gradle
// android/app/build.gradle
buildTypes {
    release {
        minifyEnabled true
        useProguard true
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
}
```

### iOS Configuration

#### Info.plist Permissions
```xml
<!-- ios/Runner/Info.plist -->
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to save downloaded videos</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for video features</string>
```

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

## 📦 Distribution

### Google Play Store

#### Prepare Release
1. **Build App Bundle**
   ```bash
   flutter build appbundle --release
   ```

2. **Upload to Play Console**
   - Create app listing
   - Upload app-release.aab
   - Configure store listing
   - Submit for review

#### Store Listing Requirements
- App icon (512x512 PNG)
- Feature graphic (1024x500 PNG)
- Screenshots (minimum 2, maximum 8)
- App description
- Privacy policy URL

### Apple App Store

#### Prepare Release
1. **Build iOS App**
   ```bash
   flutter build ios --release
   ```

2. **Archive in Xcode**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Product > Archive
   - Upload to App Store Connect

## 🔧 Troubleshooting

### Common Build Issues

#### Gradle Build Failed
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release
```

#### Android License Issues
```bash
flutter doctor --android-licenses
# Accept all licenses
```

#### iOS Build Issues
```bash
# Clean iOS build
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
flutter clean
flutter build ios
```

### Performance Optimization

#### Reduce APK Size
```bash
# Build with split APKs
flutter build apk --split-per-abi --release

# Build with compression
flutter build apk --shrink --release
```

#### Optimize Images
- Use WebP format for images
- Compress images before adding to assets
- Use vector graphics where possible

## 📊 Build Verification

### Pre-Release Checklist
- [ ] All tests pass (`flutter test`)
- [ ] No analysis issues (`flutter analyze`)
- [ ] App builds successfully
- [ ] Permissions work correctly
- [ ] Download functionality tested
- [ ] Video playback tested
- [ ] UI responsive on different screen sizes
- [ ] Performance acceptable on target devices

### Post-Build Testing
- [ ] Install APK on physical device
- [ ] Test core functionality
- [ ] Verify permissions requests
- [ ] Test on different Android versions
- [ ] Check app size and performance

## 🚀 Deployment Scripts

### Automated Build Script
```bash
#!/bin/bash
# build.sh

echo "Building Parrot Downloader..."

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Run tests
flutter test

# Analyze code
flutter analyze --no-fatal-infos

# Build release APK
flutter build apk --release

# Build release App Bundle
flutter build appbundle --release

echo "Build completed successfully!"
echo "APK: build/app/outputs/flutter-apk/app-release.apk"
echo "AAB: build/app/outputs/bundle/release/app-release.aab"
```

### Make Script Executable
```bash
chmod +x build.sh
./build.sh
```

## 📈 Monitoring and Analytics

### Crash Reporting
Consider integrating:
- Firebase Crashlytics
- Sentry
- Bugsnag

### Analytics
Consider integrating:
- Firebase Analytics
- Google Analytics
- Mixpanel

---

**Happy Building! 🎉**

For additional support or questions about the build process, please refer to the [Flutter documentation](https://docs.flutter.dev/) or contact the development team.

