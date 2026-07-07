import 'dart:math';
import 'package:flutter/material.dart';

enum SwipeDirection { up, down, left, right }

/// Game state and logic for 2048.
///
/// Holds a 4x4 grid of tile values (0 = empty), the current score, and
/// whether the game has ended. Call [move] in response to a swipe gesture;
/// it merges tiles, spawns a new random tile, and notifies listeners.
class Game2048Model extends ChangeNotifier {
  Game2048Model({this.size = 4}) {
    reset();
  }

  final int size;
  late List<List<int>> grid;
  int score = 0;
  bool isGameOver = false;
  bool _lastMoveChangedBoard = false;

  final Random _random = Random();

  void reset() {
    grid = List.generate(size, (_) => List.filled(size, 0));
    score = 0;
    isGameOver = false;
    _addRandomTile();
    _addRandomTile();
    notifyListeners();
  }

  void _addRandomTile() {
    final empty = <Point<int>>[];
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (grid[r][c] == 0) empty.add(Point(r, c));
      }
    }
    if (empty.isEmpty) return;
    final cell = empty[_random.nextInt(empty.length)];
    grid[cell.x][cell.y] = _random.nextDouble() < 0.9 ? 2 : 4;
  }

  /// Applies a swipe: slides + merges tiles toward [direction], spawns a
  /// new tile if the board actually changed, and checks for game over.
  void move(SwipeDirection direction) {
    if (isGameOver) return;

    _lastMoveChangedBoard = false;
    switch (direction) {
      case SwipeDirection.left:
        _moveLeft();
        break;
      case SwipeDirection.right:
        _flipHorizontal();
        _moveLeft();
        _flipHorizontal();
        break;
      case SwipeDirection.up:
        _transpose();
        _moveLeft();
        _transpose();
        break;
      case SwipeDirection.down:
        _transpose();
        _flipHorizontal();
        _moveLeft();
        _flipHorizontal();
        _transpose();
        break;
    }

    if (_lastMoveChangedBoard) {
      _addRandomTile();
      if (!_hasMovesLeft()) {
        isGameOver = true;
      }
    }
    notifyListeners();
  }

  // All four directions are implemented in terms of "move everything left",
  // combined with transpose/flip, so the merge logic only has to be
  // written once.
  void _moveLeft() {
    for (var r = 0; r < size; r++) {
      final row = grid[r].where((v) => v != 0).toList();
      final merged = <int>[];
      var i = 0;
      while (i < row.length) {
        if (i + 1 < row.length && row[i] == row[i + 1]) {
          final mergedValue = row[i] * 2;
          merged.add(mergedValue);
          score += mergedValue;
          i += 2;
        } else {
          merged.add(row[i]);
          i += 1;
        }
      }
      while (merged.length < size) {
        merged.add(0);
      }
      if (!_lastMoveChangedBoard) {
        for (var c = 0; c < size; c++) {
          if (grid[r][c] != merged[c]) {
            _lastMoveChangedBoard = true;
            break;
          }
        }
      }
      grid[r] = merged;
    }
  }

  void _transpose() {
    final newGrid = List.generate(size, (_) => List.filled(size, 0));
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        newGrid[c][r] = grid[r][c];
      }
    }
    grid = newGrid;
  }

  void _flipHorizontal() {
    for (var r = 0; r < size; r++) {
      grid[r] = grid[r].reversed.toList();
    }
  }

  bool _hasMovesLeft() {
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (grid[r][c] == 0) return true;
        if (c + 1 < size && grid[r][c] == grid[r][c + 1]) return true;
        if (r + 1 < size && grid[r][c] == grid[r + 1][c]) return true;
      }
    }
    return false;
  }
}