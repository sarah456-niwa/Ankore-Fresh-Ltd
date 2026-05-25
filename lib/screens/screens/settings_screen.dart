import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _urlController = TextEditingController();
  String _currentUrl = 'Loading...';
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUrl();
  }

  Future<void> _loadCurrentUrl() async {
    final url = await ApiService.baseUrl;
    setState(() {
      _currentUrl = url;
      _urlController.text = url;
    });
  }

  Future<void> _testAndSaveUrl() async {
    setState(() {
      _isTesting = true;
    });

    final success = await ApiService._testConnection(_urlController.text);
    
    setState(() {
      _isTesting = false;
    });

    if (success) {
      await ApiService.setBaseUrl(_urlController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Backend URL saved and working!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Cannot connect to this URL. Please check and try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Settings'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Backend URL:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_currentUrl),
            ),
            const SizedBox(height: 24),
            const Text(
              'Change Backend URL:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'API Base URL',
                hintText: 'http://192.168.1.172:8000/api',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isTesting ? null : _testAndSaveUrl,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isTesting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Test & Save URL'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () async {
                await ApiService.refreshBackendDiscovery();
                await _loadCurrentUrl();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🔄 Discovery reset. Restart app to rediscover.')),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Discovery'),
            ),
          ],
        ),
      ),
    );
  }
}