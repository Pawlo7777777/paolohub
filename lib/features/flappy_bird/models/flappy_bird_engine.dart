import 'dart:math';
import 'package:flutter/material.dart';

/// A single pipe obstacle: [x] is its horizontal position (logical pixels
/// from the left of the game canvas), [gapCenter] is the vertical center
/// of the gap, and [passed] tracks whether the bird has already flown
/// through it (used for scoring, once per pipe).
class Pipe {
  Pipe({required this.x, required this.gapCenter, this.passed = false});

  double x;
  double gapCenter;
  bool passed;
}

/// Physics and state for Flappy Bird.
///
/// The screen owns a [Ticker] driving [tick] every frame; this class only
/// knows about game rules, not rendering.
class FlappyBirdModel extends ChangeNotifier {
  static const double gravity = 1800; // px/s^2
  static const double jumpVelocity = -520; // px/s
  static const double pipeSpeed = 180; // px/s
  static const double pipeGapHeight = 0.28; // fraction of canvas height
  static const double pipeSpacing = 240; // px between consecutive pipes
  static const double birdX = 90; // fixed horizontal position
  static const double birdRadius = 16;
  static const double pipeWidth = 64;

  double canvasWidth = 400;
  double canvasHeight = 700;

  double birdY = 0;
  double birdVelocity = 0;
  double rotation = 0;
  List<Pipe> pipes = [];
  int score = 0;
  bool isGameOver = false;
  bool hasStarted = false;

  final Random _random = Random();

  /// Called from a LayoutBuilder each frame the canvas size is known, so
  /// the bird's starting position matches the actual screen before the
  /// player has tapped to start.
  void configure(double width, double height) {
    canvasWidth = width;
    canvasHeight = height;
    if (!hasStarted) {
      birdY = height / 2;
    }
  }

  void start() {
    birdY = canvasHeight / 2;
    birdVelocity = 0;
    rotation = 0;
    pipes = [
      Pipe(x: canvasWidth + 100, gapCenter: _randomGapCenter()),
      Pipe(x: canvasWidth + 100 + pipeSpacing, gapCenter: _randomGapCenter()),
      Pipe(x: canvasWidth + 100 + pipeSpacing * 2, gapCenter: _randomGapCenter()),
    ];
    score = 0;
    isGameOver = false;
    hasStarted = true;
    notifyListeners();
  }

  double _randomGapCenter() {
    final margin = pipeGapHeight * canvasHeight / 2 + 40;
    return margin + _random.nextDouble() * (canvasHeight - margin * 2);
  }

  void jump() {
    if (isGameOver) return;
    if (!hasStarted) {
      start();
    }
    birdVelocity = jumpVelocity;
  }

  void tick(double dt) {
    if (!hasStarted || isGameOver || dt <= 0) return;

    birdVelocity += gravity * dt;
    birdY += birdVelocity * dt;
    rotation = (birdVelocity / 900).clamp(-0.5, 1.2);

    for (final pipe in pipes) {
      pipe.x -= pipeSpeed * dt;
    }

    if (pipes.isNotEmpty && pipes.first.x < -pipeWidth) {
      pipes.removeAt(0);
      final lastX = pipes.isNotEmpty ? pipes.last.x : canvasWidth;
      pipes.add(Pipe(x: lastX + pipeSpacing, gapCenter: _randomGapCenter()));
    }

    for (final pipe in pipes) {
      if (!pipe.passed && pipe.x + pipeWidth < birdX) {
        pipe.passed = true;
        score++;
      }
    }

    _checkCollisions();
    notifyListeners();
  }

  void _checkCollisions() {
    if (birdY - birdRadius <= 0 || birdY + birdRadius >= canvasHeight) {
      isGameOver = true;
      return;
    }

    final gapHalf = pipeGapHeight * canvasHeight / 2;
    for (final pipe in pipes) {
      final withinX =
          birdX + birdRadius > pipe.x && birdX - birdRadius < pipe.x + pipeWidth;
      if (!withinX) continue;
      final withinGap = birdY - birdRadius > pipe.gapCenter - gapHalf &&
          birdY + birdRadius < pipe.gapCenter + gapHalf;
      if (!withinGap) {
        isGameOver = true;
        return;
      }
    }
  }
}