import 'package:flutter/material.dart';

class FurniFlowPackScreen extends StatelessWidget {
  const FurniFlowPackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.build, size: 64, color: Colors.grey),
            const SizedBox(height: 24),
            Text('Furni Flow Pack ',
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
