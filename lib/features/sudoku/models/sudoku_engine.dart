import 'dart:math';
import 'package:flutter/material.dart';

enum SudokuDifficulty { easy, medium, hard }

/// Generates and tracks state for a 9x9 Sudoku puzzle.
///
/// [solution] is the fully solved grid; [puzzle] is the solution with some
/// cells blanked out (0 = empty) for the player to fill; [userGrid] is what
/// the player has entered so far (starts as a copy of [puzzle]).
class SudokuModel extends ChangeNotifier {
  SudokuModel({this.difficulty = SudokuDifficulty.medium}) {
    reset();
  }

  SudokuDifficulty difficulty;

  late List<List<int>> solution;
  late List<List<int>> puzzle;
  late List<List<int>> userGrid;
  late List<List<bool>> isFixed;

  int? selectedRow;
  int? selectedCol;
  bool isSolved = false;
  int mistakes = 0;

  final Random _random = Random();

  void reset() {
    solution = _generateSolvedGrid();
    puzzle = _carvePuzzle(solution, difficulty);
    userGrid = [for (final row in puzzle) [...row]];
    isFixed = [
      for (final row in puzzle) [for (final v in row) v != 0],
    ];
    selectedRow = null;
    selectedCol = null;
    isSolved = false;
    mistakes = 0;
    notifyListeners();
  }

  // ---- Generation ----

  List<List<int>> _generateSolvedGrid() {
    final grid = List.generate(9, (_) => List.filled(9, 0));
    _fill(grid, 0, 0);
    return grid;
  }

  /// Backtracking fill with shuffled candidates at each cell, so every
  /// call produces a different valid, fully-solved 9x9 grid.
  bool _fill(List<List<int>> grid, int row, int col) {
    if (row == 9) return true;
    final nextRow = col == 8 ? row + 1 : row;
    final nextCol = col == 8 ? 0 : col + 1;

    final candidates = List.generate(9, (i) => i + 1)..shuffle(_random);
    for (final value in candidates) {
      if (_isValidPlacement(grid, row, col, value)) {
        grid[row][col] = value;
        if (_fill(grid, nextRow, nextCol)) return true;
        grid[row][col] = 0;
      }
    }
    return false;
  }

  bool _isValidPlacement(List<List<int>> grid, int row, int col, int value) {
    for (var i = 0; i < 9; i++) {
      if (grid[row][i] == value || grid[i][col] == value) return false;
    }
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (var r = boxRow; r < boxRow + 3; r++) {
      for (var c = boxCol; c < boxCol + 3; c++) {
        if (grid[r][c] == value) return false;
      }
    }
    return true;
  }

  List<List<int>> _carvePuzzle(List<List<int>> solved, SudokuDifficulty diff) {
    final puzzle = [for (final row in solved) [...row]];
    final cellsToRemove = switch (diff) {
      SudokuDifficulty.easy => 35,
      SudokuDifficulty.medium => 45,
      SudokuDifficulty.hard => 54,
    };

    final positions = [
      for (var r = 0; r < 9; r++)
        for (var c = 0; c < 9; c++) Point(r, c),
    ]..shuffle(_random);

    for (var i = 0; i < cellsToRemove && i < positions.length; i++) {
      final p = positions[i];
      puzzle[p.x][p.y] = 0;
    }
    return puzzle;
  }

  // ---- Interaction ----

  void selectCell(int row, int col) {
    if (isFixed[row][col]) return;
    selectedRow = row;
    selectedCol = col;
    notifyListeners();
  }

  void enterValue(int value) {
    final r = selectedRow;
    final c = selectedCol;
    if (r == null || c == null || isFixed[r][c]) return;

    userGrid[r][c] = value;
    if (value != 0 && value != solution[r][c]) {
      mistakes++;
    }
    _checkSolved();
    notifyListeners();
  }

  void clearSelected() {
    final r = selectedRow;
    final c = selectedCol;
    if (r == null || c == null || isFixed[r][c]) return;
    userGrid[r][c] = 0;
    notifyListeners();
  }

  void _checkSolved() {
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (userGrid[r][c] != solution[r][c]) return;
      }
    }
    isSolved = true;
  }

  bool isCellIncorrect(int row, int col) {
    final value = userGrid[row][col];
    return value != 0 && !isFixed[row][col] && value != solution[row][col];
  }
}