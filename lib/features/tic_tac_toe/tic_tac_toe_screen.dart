import 'package:flutter/material.dart';
import '../../core/widgets/score_board.dart';
import '../../core/widgets/game_over_dialog.dart';
import '../../services/storage_service.dart';
import 'models/tic_tac_toe_engine.dart';
import 'widgets/tic_tac_toe_board.dart';

enum _GameMode { twoPlayer, aiEasy, aiHard }

/// Entry screen for Tic Tac Toe.
///
/// Shows a mode picker first (2-player local, vs AI Easy, vs AI Hard), then
/// the game itself. "Best score" persisted for this game is the longest
/// win streak achieved against the AI.
class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  static const storageKey = 'best_score_tic_tac_toe';

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  _GameMode? _mode;

  TicTacToeEngine _engine = TicTacToeEngine();
  Player _currentTurn = Player.x;

  // vs-AI session stats
  int _winStreak = 0;
  late int _bestStreak;

  // 2-player session stats
  int _xWins = 0;
  int _oWins = 0;

  bool _aiThinking = false;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _bestStreak = StorageService.instance.getBestScore(TicTacToeScreen.storageKey);
  }

  bool get _isAiMode => _mode == _GameMode.aiEasy || _mode == _GameMode.aiHard;

  AiDifficulty get _aiDifficulty =>
      _mode == _GameMode.aiHard ? AiDifficulty.hard : AiDifficulty.easy;

  void _selectMode(_GameMode mode) {
    setState(() {
      _mode = mode;
      _resetBoard();
      _xWins = 0;
      _oWins = 0;
      _winStreak = 0;
    });
  }

  void _resetBoard() {
    _engine = TicTacToeEngine();
    _currentTurn = Player.x;
    _aiThinking = false;
    _dialogShown = false;
  }

  void _handleCellTap(int index) {
    if (_aiThinking) return;
    if (!_engine.play(index, _currentTurn)) return;

    setState(() {
      if (!_engine.isOver) {
        _currentTurn = _currentTurn.opponent;
      }
    });

    if (_engine.isOver) {
      _handleGameOver();
      return;
    }

    if (_isAiMode && _currentTurn == Player.o) {
      _triggerAiMove();
    }
  }

  void _triggerAiMove() {
    setState(() => _aiThinking = true);

    // Small delay so the AI's move doesn't feel instant/robotic.
    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      final move = _engine.pickAiMove(Player.o, _aiDifficulty);
      if (move != null) {
        _engine.play(move, Player.o);
      }
      setState(() {
        _aiThinking = false;
        if (!_engine.isOver) {
          _currentTurn = Player.x;
        }
      });
      if (_engine.isOver) _handleGameOver();
    });
  }

  Future<void> _handleGameOver() async {
    if (_dialogShown) return;
    _dialogShown = true;

    final winner = _engine.winner;
    bool isNewBest = false;
    String title;
    String message;

    if (_isAiMode) {
      if (winner == Player.x) {
        _winStreak += 1;
        if (_winStreak > _bestStreak) {
          _bestStreak = _winStreak;
          await StorageService.instance
              .maybeSaveBestScore(TicTacToeScreen.storageKey, _bestStreak);
          isNewBest = true;
        }
        title = 'You Win! 🎉';
        message = 'Win streak: $_winStreak';
      } else if (winner == Player.o) {
        _winStreak = 0;
        title = 'AI Wins';
        message = 'Streak reset. Try again!';
      } else {
        _winStreak = 0;
        title = "It's a Draw";
        message = 'Streak reset. Try again!';
      }
    } else {
      if (winner == Player.x) {
        _xWins += 1;
        title = 'Player X Wins! 🎉';
        message = 'X: $_xWins   ·   O: $_oWins';
      } else if (winner == Player.o) {
        _oWins += 1;
        title = 'Player O Wins! 🎉';
        message = 'X: $_xWins   ·   O: $_oWins';
      } else {
        title = "It's a Draw";
        message = 'X: $_xWins   ·   O: $_oWins';
      }
    }

    if (!mounted) return;
    setState(() {}); // reflect updated stats in the ScoreBoard immediately

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(
        title: title,
        message: message,
        isNewBest: isNewBest,
        onPlayAgain: () => setState(_resetBoard),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        actions: [
          if (_mode != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Restart',
              onPressed: () => setState(_resetBoard),
            ),
        ],
      ),
      body: SafeArea(
        child: _mode == null ? _buildModePicker(context) : _buildGame(context),
      ),
    );
  }

  Widget _buildModePicker(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.close_rounded, size: 56, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            'Choose a mode',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),
          _ModeButton(
            icon: Icons.people_alt_rounded,
            label: '2 Player (local)',
            onTap: () => _selectMode(_GameMode.twoPlayer),
          ),
          const SizedBox(height: 12),
          _ModeButton(
            icon: Icons.sentiment_satisfied_alt_rounded,
            label: 'vs AI · Easy',
            onTap: () => _selectMode(_GameMode.aiEasy),
          ),
          const SizedBox(height: 12),
          _ModeButton(
            icon: Icons.psychology_alt_rounded,
            label: 'vs AI · Hard',
            onTap: () => _selectMode(_GameMode.aiHard),
          ),
        ],
      ),
    );
  }

  Widget _buildGame(BuildContext context) {
    final theme = Theme.of(context);

    final stats = _isAiMode
        ? [
      ScoreStat(
          label: 'Streak',
          value: '$_winStreak',
          icon: Icons.local_fire_department_rounded),
      ScoreStat(
          label: 'Best',
          value: '$_bestStreak',
          icon: Icons.emoji_events_rounded),
    ]
        : [
      ScoreStat(label: 'X wins', value: '$_xWins'),
      ScoreStat(label: 'O wins', value: '$_oWins'),
    ];

    final turnLabel = _aiThinking
        ? "AI is thinking…"
        : _isAiMode
        ? (_currentTurn == Player.x ? 'Your turn (X)' : "AI's turn (O)")
        : "Player ${_currentTurn.mark}'s turn";

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _mode = null),
              icon: const Icon(Icons.swap_horiz_rounded, size: 18),
              label: const Text('Change mode'),
            ),
          ),
          ScoreBoard(stats: stats),
          const SizedBox(height: 16),
          Text(
            turnLabel,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TicTacToeBoard(
            cells: _engine.cells,
            winningLine: _engine.winningLine,
            enabled: !_aiThinking && !_engine.isOver,
            onCellTap: _handleCellTap,
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }
}
