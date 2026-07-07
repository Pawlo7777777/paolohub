/// Pure game logic for Tic Tac Toe — no Flutter imports, so it's trivially
/// unit-testable and reusable if the board widget ever changes.
library;

enum Player { x, o }

extension PlayerX on Player {
  String get mark => this == Player.x ? 'X' : 'O';
  Player get opponent => this == Player.x ? Player.o : Player.x;
}

enum AiDifficulty { easy, hard }

/// The 8 index triples that count as a win on a 3x3 board.
const List<List<int>> kWinLines = [
  [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
  [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
  [0, 4, 8], [2, 4, 6], // diagonals
];

/// Immutable-ish board state: 9 cells, each `null`, `Player.x`, or `Player.o`.
class TicTacToeEngine {
  TicTacToeEngine() : cells = List<Player?>.filled(9, null);

  final List<Player?> cells;

  bool get isFull => cells.every((c) => c != null);

  /// Returns the winning player, or null if there's no winner yet.
  Player? get winner {
    for (final line in kWinLines) {
      final a = cells[line[0]];
      final b = cells[line[1]];
      final c = cells[line[2]];
      if (a != null && a == b && b == c) return a;
    }
    return null;
  }

  /// The 3 winning cell indices, or null if no one has won.
  List<int>? get winningLine {
    for (final line in kWinLines) {
      final a = cells[line[0]];
      final b = cells[line[1]];
      final c = cells[line[2]];
      if (a != null && a == b && b == c) return line;
    }
    return null;
  }

  bool get isDraw => winner == null && isFull;
  bool get isOver => winner != null || isFull;

  bool play(int index, Player player) {
    if (cells[index] != null || isOver) return false;
    cells[index] = player;
    return true;
  }

  List<int> get emptyIndices => [
    for (int i = 0; i < 9; i++)
      if (cells[i] == null) i
  ];

  TicTacToeEngine clone() {
    final copy = TicTacToeEngine();
    for (int i = 0; i < 9; i++) {
      copy.cells[i] = cells[i];
    }
    return copy;
  }

  /// Picks the AI's next move for [aiPlayer] given the requested difficulty.
  /// Returns null if the board has no empty cells left.
  int? pickAiMove(Player aiPlayer, AiDifficulty difficulty) {
    final empties = emptyIndices;
    if (empties.isEmpty) return null;

    if (difficulty == AiDifficulty.easy) {
      empties.shuffle();
      return empties.first;
    }

    // Hard: perfect play via minimax with alpha-beta pruning.
    int? bestMove;
    int bestScore = -1000;
    for (final index in empties) {
      final trial = clone()..cells[index] = aiPlayer;
      final score = _minimax(
        trial,
        depth: 1,
        isMaximizing: false,
        aiPlayer: aiPlayer,
        alpha: -1000,
        beta: 1000,
      );
      if (score > bestScore) {
        bestScore = score;
        bestMove = index;
      }
    }
    return bestMove;
  }

  int _minimax(
      TicTacToeEngine board, {
        required int depth,
        required bool isMaximizing,
        required Player aiPlayer,
        required int alpha,
        required int beta,
      }) {
    final winner = board.winner;
    if (winner == aiPlayer) return 10 - depth;
    if (winner == aiPlayer.opponent) return depth - 10;
    if (board.isFull) return 0;

    final currentPlayer = isMaximizing ? aiPlayer : aiPlayer.opponent;
    int a = alpha, b = beta;

    if (isMaximizing) {
      int best = -1000;
      for (final index in board.emptyIndices) {
        final trial = board.clone()..cells[index] = currentPlayer;
        final score = _minimax(
          trial,
          depth: depth + 1,
          isMaximizing: false,
          aiPlayer: aiPlayer,
          alpha: a,
          beta: b,
        );
        if (score > best) best = score;
        if (best > a) a = best;
        if (b <= a) break; // beta cutoff
      }
      return best;
    } else {
      int best = 1000;
      for (final index in board.emptyIndices) {
        final trial = board.clone()..cells[index] = currentPlayer;
        final score = _minimax(
          trial,
          depth: depth + 1,
          isMaximizing: true,
          aiPlayer: aiPlayer,
          alpha: a,
          beta: b,
        );
        if (score < best) best = score;
        if (best < b) b = best;
        if (b <= a) break; // alpha cutoff
      }
      return best;
    }
  }
}
