import 'package:flutter/material.dart';

/// Renders the NxN board for 2048: a rounded background grid with numbered
/// tiles laid on top. Purely presentational — all game logic lives in
/// [Game2048Model].
class Game2048Board extends StatelessWidget {
  const Game2048Board({super.key, required this.grid});

  final List<List<int>> grid;

  static const Map<int, Color> _tileColors = {
    0: Color(0xFFE4DCD3),
    2: Color(0xFFEEE4DA),
    4: Color(0xFFEDE0C8),
    8: Color(0xFFF2B179),
    16: Color(0xFFF59563),
    32: Color(0xFFF67C5F),
    64: Color(0xFFF65E3B),
    128: Color(0xFFEDCF72),
    256: Color(0xFFEDCC61),
    512: Color(0xFFEDC850),
    1024: Color(0xFFEDC53F),
    2048: Color(0xFFEDC22E),
  };

  Color _colorFor(int value) => _tileColors[value] ?? const Color(0xFF3C3A32);

  Color _textColorFor(int value) =>
      value <= 4 ? const Color(0xFF776E65) : Colors.white;

  @override
  Widget build(BuildContext context) {
    final size = grid.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth;
        const gap = 8.0;
        final cellSize = (boardSize - gap * (size + 1)) / size;

        return Container(
          width: boardSize,
          height: boardSize,
          padding: const EdgeInsets.all(gap),
          decoration: BoxDecoration(
            color: const Color(0xFFBBADA0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              for (var r = 0; r < size; r++)
                for (var c = 0; c < size; c++)
                  Positioned(
                    left: c * (cellSize + gap),
                    top: r * (cellSize + gap),
                    width: cellSize,
                    height: cellSize,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      decoration: BoxDecoration(
                        color: _colorFor(grid[r][c]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: grid[r][c] == 0
                          ? null
                          : Text(
                        '${grid[r][c]}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: grid[r][c] >= 1000 ? 22 : 26,
                          color: _textColorFor(grid[r][c]),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}