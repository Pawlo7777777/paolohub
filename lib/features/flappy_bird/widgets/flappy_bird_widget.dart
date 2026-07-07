import 'package:flutter/material.dart';

import '../models/flappy_bird_engine.dart';

/// Paints the bird and pipes for one frame of Flappy Bird.
///
/// Kept as a single [CustomPainter] rather than a widget tree since the
/// game redraws every frame (60fps) — rebuilding widgets per-tick would be
/// far more expensive than repainting a canvas.
class FlappyBirdPainter extends CustomPainter {
  FlappyBirdPainter({
    required this.birdY,
    required this.rotation,
    required this.pipes,
  });

  final double birdY;
  final double rotation;
  final List<Pipe> pipes;

  static const double _birdX = FlappyBirdModel.birdX;
  static const double _birdRadius = FlappyBirdModel.birdRadius;
  static const double _pipeWidth = FlappyBirdModel.pipeWidth;
  static const double _pipeGapHeight = FlappyBirdModel.pipeGapHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final pipePaint = Paint()..color = const Color(0xFF2EC4B6);
    final pipeGapHalf = _pipeGapHeight * size.height / 2;

    for (final pipe in pipes) {
      final topRect = Rect.fromLTRB(
        pipe.x,
        0,
        pipe.x + _pipeWidth,
        pipe.gapCenter - pipeGapHalf,
      );
      final bottomRect = Rect.fromLTRB(
        pipe.x,
        pipe.gapCenter + pipeGapHalf,
        pipe.x + _pipeWidth,
        size.height,
      );
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          topRect,
          bottomLeft: const Radius.circular(6),
          bottomRight: const Radius.circular(6),
        ),
        pipePaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          bottomRect,
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        ),
        pipePaint,
      );
    }

    canvas.save();
    canvas.translate(_birdX, birdY);
    canvas.rotate(rotation);
    canvas.drawCircle(Offset.zero, _birdRadius, Paint()..color = const Color(0xFFFFC93C));
    canvas.drawCircle(const Offset(6, -4), 2.4, Paint()..color = Colors.black87);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, -3, 12, 6),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFFF6B4A),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FlappyBirdPainter oldDelegate) => true;
}