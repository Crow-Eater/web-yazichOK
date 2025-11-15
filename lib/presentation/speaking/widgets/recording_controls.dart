import 'package:flutter/material.dart';

/// Widget for recording control buttons
class RecordingControls extends StatelessWidget {
  final bool isRecording;
  final bool isStopped;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onReRecord;
  final VoidCallback onSubmit;

  const RecordingControls({
    super.key,
    required this.isRecording,
    required this.isStopped,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onReRecord,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isRecording) {
      // Show stop button during recording
      return Center(
        child: Column(
          children: [
            // Large stop button with pulsing animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 1.0 + (0.1 * value),
                  child: child,
                );
              },
              onEnd: () {},
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.error,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.error.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onStopRecording,
                    customBorder: const CircleBorder(),
                    child: const Icon(
                      Icons.stop,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tap to stop recording',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    if (isStopped) {
      // Show re-record and submit buttons
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Re-record button
              OutlinedButton.icon(
                onPressed: onReRecord,
                icon: const Icon(Icons.refresh),
                label: const Text('Re-record'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Submit button
              ElevatedButton.icon(
                onPressed: onSubmit,
                icon: const Icon(Icons.send),
                label: const Text('Submit'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Show start recording button (idle state)
    return Center(
      child: Column(
        children: [
          // Large record button
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.red.shade400,
                  Colors.red.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onStartRecording,
                customBorder: const CircleBorder(),
                child: const Icon(
                  Icons.mic,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tap to start recording',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
