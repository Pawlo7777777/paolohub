import 'package:flutter/material.dart';

/// A single flippable card. Presentational only — `faceUp` is computed by
/// the screen (true if matched, or currently one of the up-to-2 revealed
/// cards in the active turn).
class MemoryCardWidget extends StatelessWidget {
  const MemoryCardWidget({
    super.key,
    required this.symbol,
    required this.faceUp,
    required this.matched,
    required this.onTap,
  });

  final String symbol;
  final bool faceUp;
  final bool matched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showFront = faceUp || matched;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
        child: Container(
          key: ValueKey(showFront),
          decoration: BoxDecoration(
            color: matched
                ? theme.colorScheme.secondary.withValues(alpha: 0.18)
                : showFront
                ? theme.cardTheme.color
                : theme.colorScheme.primary.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(14),
            border: matched
                ? Border.all(color: theme.colorScheme.secondary, width: 2)
                : null,
          ),
          alignment: Alignment.center,
          child: showFront
              ? Text(symbol, style: const TextStyle(fontSize: 26))
              : Icon(
            Icons.help_outline_rounded,
            color: Colors.white.withValues(alpha: 0.85),
            size: 22,
          ),
        ),
      ),
    );
  }
}
