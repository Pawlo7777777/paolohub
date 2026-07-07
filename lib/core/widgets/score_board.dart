import 'package:flutter/material.dart';

/// A single stat shown inside a [ScoreBoard] (e.g. "Score", "Best", "Time").
class ScoreStat {
  final String label;
  final String value;
  final IconData? icon;

  const ScoreStat({required this.label, required this.value, this.icon});
}

/// Reusable header shown at the top of every game screen.
///
/// Pass in whichever stats matter for that game — e.g. 2048 uses
/// `[Score, Best]`, Memory Match uses `[Moves, Time]`, Flappy Bird uses
/// `[Score, Best]`. Keeping this generic lets every game share one look.
class ScoreBoard extends StatelessWidget {
  const ScoreBoard({super.key, required this.stats});

  final List<ScoreStat> stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final stat in stats) _StatColumn(stat: stat),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.stat});

  final ScoreStat stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (stat.icon != null) ...[
              Icon(stat.icon, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
            ],
            Text(
              stat.label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 0.8,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          stat.value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}