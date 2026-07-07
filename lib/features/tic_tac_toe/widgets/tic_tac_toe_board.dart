import 'package:flutter/material.dart';
import '../models/tic_tac_toe_engine.dart';

/// Renders the 3x3 grid and forwards taps on empty cells.
///
/// Purely presentational — all rules live in [TicTacToeEngine]. Highlights
/// the winning line (if any) so a completed game reads clearly.
class TicTacToeBoard extends StatelessWidget {
  const TicTacToeBoard({
    super.key,
    required this.cells,
    required this.winningLine,
    required this.onCellTap,
    required this.enabled,
  });

  final List<Player?> cells;
  final List<int>? winningLine;
  final ValueChanged<int> onCellTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final mark = cells[index];
              final isWinningCell = winningLine?.contains(index) ?? false;

              final baseColor = isWinningCell
                  ? theme.colorScheme.primary.withValues(alpha: 0.18)
                  : theme.cardTheme.color;

              return Material(
                color: baseColor,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: (enabled && mark == null)
                      ? () => onCellTap(index)
                      : null,
                  child: Center(
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 150),
                      scale: mark == null ? 0 : 1,
                      curve: Curves.easeOutBack,
                      child: Text(
                        mark?.mark ?? '',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: mark == Player.x
                              ? theme.colorScheme.primary
                              : theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
