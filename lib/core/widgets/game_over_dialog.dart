import 'package:flutter/material.dart';

/// Reusable end-of-game popup used by every mini-game.
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   barrierDismissible: false,
///   builder: (_) => GameOverDialog(
///     title: 'Game Over',
///     message: 'Score: $score',
///     isNewBest: isNewBest,
///     onPlayAgain: _restartGame,
///   ),
/// );
/// ```
class GameOverDialog extends StatelessWidget {
  const GameOverDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onPlayAgain,
    this.isNewBest = false,
  });

  final String title;
  final String message;
  final bool isNewBest;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Column(
        children: [
          if (isNewBest)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Icon(Icons.emoji_events_rounded,
                  color: Color(0xFFFFC93C), size: 40),
            ),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          if (isNewBest)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'New best score!',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // close dialog
            Navigator.of(context).pop(); // back to home
          },
          child: const Text('Back to Home'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // close dialog
            onPlayAgain();
          },
          child: const Text('Play Again'),
        ),
      ],
    );
  }
}