import 'package:flutter/material.dart';

class TentangAplikasiPage extends StatelessWidget {
  const TentangAplikasiPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Developer', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('Nama: Aslam Muzaky'),
            const Text('Email: zakyaslam2004@email.com'),
            const Text('Instagram: @muzaky7_'),
            const SizedBox(height: 24),
            Text('Versi Aplikasi', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('1.1.1+3'),
            const SizedBox(height: 24),
            const Spacer(),
            Center(
              child: Text('Terima kasih telah menggunakan aplikasi ini!',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 