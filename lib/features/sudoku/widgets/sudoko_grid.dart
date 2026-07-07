import 'package:flutter/material.dart';

import '../models/sudoku_engine.dart';

/// Renders the 9x9 Sudoku board: fixed clue cells, player-entered values,
/// the current selection and its row/column/box peers, and thicker
/// borders between the 3x3 boxes.
class SudokuGrid extends StatelessWidget {
  const SudokuGrid({
    super.key,
    required this.model,
    required this.onCellTap,
  });

  final SudokuModel model;
  final void Function(int row, int col) onCellTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.onSurface, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
          ),
          itemCount: 81,
          itemBuilder: (context, index) {
            final row = index ~/ 9;
            final col = index % 9;
            final selectedRow = model.selectedRow;
            final selectedCol = model.selectedCol;
            final isPeer = selectedRow == row ||
                selectedCol == col ||
                (selectedRow != null &&
                    selectedCol != null &&
                    (selectedRow ~/ 3) == row ~/ 3 &&
                    (selectedCol ~/ 3) == col ~/ 3);

            return _SudokuCell(
              value: model.userGrid[row][col],
              isFixed: model.isFixed[row][col],
              isSelected: selectedRow == row && selectedCol == col,
              isPeer: isPeer,
              isIncorrect: model.isCellIncorrect(row, col),
              row: row,
              col: col,
              onTap: () => onCellTap(row, col),
            );
          },
        ),
      ),
    );
  }
}

class _SudokuCell extends StatelessWidget {
  const _SudokuCell({
    required this.value,
    required this.isFixed,
    required this.isSelected,
    required this.isPeer,
    required this.isIncorrect,
    required this.row,
    required this.col,
    required this.onTap,
  });

  final int value;
  final bool isFixed;
  final bool isSelected;
  final bool isPeer;
  final bool isIncorrect;
  final int row;
  final int col;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.onSurface.withValues(alpha: 0.25);

    final Color background;
    if (isSelected) {
      background = theme.colorScheme.primary.withValues(alpha: 0.35);
    } else if (isPeer) {
      background = theme.colorScheme.primary.withValues(alpha: 0.08);
    } else {
      background = Colors.transparent;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: background,
          border: Border(
            right: BorderSide(
              color: borderColor,
              width: (col + 1) % 3 == 0 ? 2 : 0.5,
            ),
            bottom: BorderSide(
              color: borderColor,
              width: (row + 1) % 3 == 0 ? 2 : 0.5,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: value == 0
            ? null
            : Text(
          '$value',
          style: TextStyle(
            fontSize: 18,
            fontWeight: isFixed ? FontWeight.w800 : FontWeight.w600,
            color: isIncorrect
                ? theme.colorScheme.error
                : isFixed
                ? theme.colorScheme.onSurface
                : theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}