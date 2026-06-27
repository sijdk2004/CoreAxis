import 'package:flutter/material.dart';

class PlatformReportsScreen extends StatelessWidget {
  const PlatformReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.build, size: 64, color: Colors.grey),
            const SizedBox(height: 24),
            Text('Platform Reports ',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('This module is under development.',
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
