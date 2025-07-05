import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoPlay = true;
  bool _highQualityDefault = true;
  bool _showNotifications = true;

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showToast('Could not open link');
      }
    } catch (e) {
      _showToast('Error opening link');
    }
  }

  void _shareApp() {
    Share.share(
      'Check out Parrot Downloader - Download videos from Facebook and Instagram! '
      'Fast, secure, and no watermarks.',
      subject: 'Parrot Downloader App',
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Parrot Downloader',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.download_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        const Text(
          'A fast and secure video downloader for Facebook and Instagram. '
          'Download high-quality videos without watermarks and enjoy them offline.',
        ),
      ],
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all temporary files and cached data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast('Cache cleared successfully');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Settings Section
          _buildSectionHeader('App Settings'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto-play videos'),
                  subtitle: const Text('Automatically play videos when opened'),
                  value: _autoPlay,
                  onChanged: (value) {
                    setState(() {
                      _autoPlay = value;
                    });
                  },
                  activeColor: const Color(0xFF2196F3),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('High quality by default'),
                  subtitle: const Text('Select highest quality option automatically'),
                  value: _highQualityDefault,
                  onChanged: (value) {
                    setState(() {
                      _highQualityDefault = value;
                    });
                  },
                  activeColor: const Color(0xFF2196F3),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Show notifications'),
                  subtitle: const Text('Get notified when downloads complete'),
                  value: _showNotifications,
                  onChanged: (value) {
                    setState(() {
                      _showNotifications = value;
                    });
                  },
                  activeColor: const Color(0xFF2196F3),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Storage Section
          _buildSectionHeader('Storage'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.folder_open),
                  title: const Text('Download location'),
                  subtitle: const Text('/storage/emulated/0/ParrotDownloader'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showToast('Download location: Internal Storage/ParrotDownloader');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.clear_all),
                  title: const Text('Clear cache'),
                  subtitle: const Text('Free up space by clearing temporary files'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _clearCache,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Support Section
          _buildSectionHeader('Support & Info'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Share app'),
                  subtitle: const Text('Tell your friends about Parrot Downloader'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _shareApp,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.star_rate),
                  title: const Text('Rate us'),
                  subtitle: const Text('Rate and review on Play Store'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _launchUrl('https://play.google.com/store'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: const Text('Report issue'),
                  subtitle: const Text('Found a bug? Let us know'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _launchUrl('mailto:support@parrotdownloader.com'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _launchUrl('https://parrotdownloader.com/privacy'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _launchUrl('https://parrotdownloader.com/terms'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  title: const Text('Parrot Downloader'),
                  subtitle: const Text('Version 1.0.0'),
                  trailing: const Icon(Icons.info_outline),
                  onTap: _showAboutDialog,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Features Info
          Card(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✨ Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem('📱 Support for Facebook & Instagram'),
                  _buildFeatureItem('🎥 High-quality video downloads'),
                  _buildFeatureItem('⚡ Fast and secure downloading'),
                  _buildFeatureItem('🚫 No watermarks'),
                  _buildFeatureItem('📺 Built-in video player'),
                  _buildFeatureItem('📁 Easy file management'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2196F3),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

