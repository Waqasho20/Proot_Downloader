import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/download_service.dart';
import '../services/file_download_service.dart';
import '../widgets/video_info_card.dart';
import '../widgets/quality_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  final DownloadService _downloadService = DownloadService();
  final FileDownloadService _fileDownloadService = FileDownloadService();
  
  bool _isLoading = false;
  DownloadResult? _downloadResult;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
        setState(() {
          _urlController.text = clipboardData.text!;
        });
      }
    } catch (e) {
      _showToast('Failed to paste from clipboard');
    }
  }

  Future<void> _fetchVideoInfo() async {
    if (_urlController.text.trim().isEmpty) {
      _showToast('Please enter a URL');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _downloadResult = null;
    });

    try {
      final result = await _downloadService.getDownloadInfo(_urlController.text.trim());
      setState(() {
        _downloadResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      _showToast(_error!);
    }
  }

  Future<void> _downloadVideo(VideoQuality quality) async {
    if (_downloadResult == null) return;

    try {
      _showToast('Starting download...');
      
      // Generate filename
      String fileName = _downloadResult!.title ?? 'video';
      fileName = fileName.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
      if (fileName.isEmpty) fileName = 'video';
      
      // Show download progress dialog
      _showDownloadDialog(quality, fileName);
      
    } catch (e) {
      _showToast('Download failed: ${e.toString()}');
    }
  }

  void _showDownloadDialog(VideoQuality quality, String fileName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DownloadProgressDialog(
        quality: quality,
        fileName: fileName,
        fileDownloadService: _fileDownloadService,
      ),
    );
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  void _clearAll() {
    setState(() {
      _urlController.clear();
      _downloadResult = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Parrot Downloader',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_downloadResult != null || _error != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearAll,
              tooltip: 'Clear',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.download_rounded,
                      size: 48,
                      color: Color(0xFF2196F3),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Download Videos',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Paste Facebook or Instagram URL below',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // URL Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _urlController,
                            decoration: const InputDecoration(
                              hintText: 'Paste Facebook or Instagram URL here...',
                              prefixIcon: Icon(Icons.link),
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _fetchVideoInfo(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _pasteFromClipboard,
                          icon: const Icon(Icons.content_paste),
                          tooltip: 'Paste',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _fetchVideoInfo,
                      icon: _isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.search),
                      label: Text(_isLoading ? 'Processing...' : 'Get Video Info'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Loading Indicator
            if (_isLoading)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      SpinKitFadingCircle(
                        color: Color(0xFF2196F3),
                        size: 50,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Fetching video information...',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Error Display
            if (_error != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Video Info and Download Options
            if (_downloadResult != null) ...[
              VideoInfoCard(downloadResult: _downloadResult!),
              const SizedBox(height: 16),
              QualitySelector(
                downloadResult: _downloadResult!,
                onDownload: _downloadVideo,
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Features Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(Icons.high_quality, 'High Quality Downloads'),
                    _buildFeatureItem(Icons.speed, 'Fast & Secure'),
                    _buildFeatureItem(Icons.no_accounts, 'No Watermarks'),
                    _buildFeatureItem(Icons.play_circle, 'Built-in Video Player'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2196F3)),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}

class DownloadProgressDialog extends StatefulWidget {
  final VideoQuality quality;
  final String fileName;
  final FileDownloadService fileDownloadService;

  const DownloadProgressDialog({
    super.key,
    required this.quality,
    required this.fileName,
    required this.fileDownloadService,
  });

  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  double _progress = 0.0;
  String _status = 'Starting download...';
  bool _isCompleted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      await widget.fileDownloadService.downloadFile(
        url: widget.quality.url,
        fileName: widget.fileName,
        onProgress: (received, total) {
          if (mounted) {
            setState(() {
              _progress = received / total;
              _status = 'Downloading... ${(received / total * 100).toInt()}%';
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isCompleted = true;
          _status = 'Download completed!';
        });
        
        // Auto close after 2 seconds
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _status = 'Download failed';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Downloading Video'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error == null) ...[
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            ),
            const SizedBox(height: 16),
            Text(_status),
          ] else ...[
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
      actions: [
        if (_error != null || _isCompleted)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
      ],
    );
  }
}

