import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TestLauncherPage extends StatelessWidget {
  const TestLauncherPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Launcher')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final uri = Uri.parse('https://flutter.dev');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              child: const Text('Test Launch Web'),
            ),
            ElevatedButton(
              onPressed: () async {
                final uri = Uri.parse('mailto:zakyaslam2004@gmail.com');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              child: const Text('Test Launch Email'),
            ),
            ElevatedButton(
              onPressed: () async {
                final uri = Uri.parse('tel:0855685455');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              child: const Text('Test Launch Telepon'),
            ),
          ],
        ),
      ),
    );
  }
} 