import 'package:flutter/material.dart';

/// Placeholder screen for routes not yet implemented
class PlaceholderScreen extends StatelessWidget {
  final String routeName;
  final Map<String, String>? params;

  const PlaceholderScreen({
    super.key,
    required this.routeName,
    this.params,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(routeName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Screen: $routeName',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (params != null && params!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Parameters: ${params.toString()}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'This screen will be implemented in future phases',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
