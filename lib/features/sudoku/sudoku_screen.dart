import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/storage_service.dart';
import '../../core/widgets/game_over_dialog.dart';
import '../../core/widgets/score_board.dart';
import '../sudoku/widgets/sudoko_grid.dart';
import './models/sudoku_engine.dart';

class SudokuScreen extends StatelessWidget {
  const SudokuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SudokuModel(),
      child: const _SudokuView(),
    );
  }
}

class _SudokuView extends StatefulWidget {
  const _SudokuView();

  @override
  State<_SudokuView> createState() => _SudokuViewState();
}

class _SudokuViewState extends State<_SudokuView> {
  // Matches GameInfo.storageKey for sudoku in GameCatalog. Sudoku's "best"
  // is a completion time in seconds (lower is better), so this is written
  // via maybeSaveBestTime rather than maybeSaveBestScore.
  static const _storageKey = 'best_score_sudoku';
  bool _dialogShown = false;
  final Stopwatch _stopwatch = Stopwatch()..start();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SudokuModel>();

    if (model.isSolved && !_dialogShown) {
      _dialogShown = true;
      _stopwatch.stop();
      final elapsedSeconds = _stopwatch.elapsed.inSeconds;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final isNewBest = await StorageService.instance
            .maybeSaveBestTime(_storageKey, elapsedSeconds);
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => GameOverDialog(
            title: 'Solved!',
            message:
            'Time: ${_formatTime(elapsedSeconds)} · Mistakes: ${model.mistakes}',
            isNewBest: isNewBest,
            onPlayAgain: () {
              model.reset();
              _stopwatch
                ..reset()
                ..start();
              setState(() => _dialogShown = false);
            },
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku'),
        actions: [
          PopupMenuButton<SudokuDifficulty>(
            icon: const Icon(Icons.tune_rounded),
            onSelected: (difficulty) {
              model.difficulty = difficulty;
              model.reset();
              _stopwatch
                ..reset()
                ..start();
              setState(() => _dialogShown = false);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: SudokuDifficulty.easy, child: Text('Easy')),
              PopupMenuItem(
                value: SudokuDifficulty.medium,
                child: Text('Medium'),
              ),
              PopupMenuItem(value: SudokuDifficulty.hard, child: Text('Hard')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ScoreBoard(
                stats: [
                  ScoreStat(
                    label: 'Mistakes',
                    value: '${model.mistakes}',
                    icon: Icons.close_rounded,
                  ),
                  ScoreStat(
                    label: 'Difficulty',
                    value: model.difficulty.name,
                    icon: Icons.tune_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SudokuGrid(model: model, onCellTap: model.selectCell),
              const SizedBox(height: 20),
              _NumberPad(
                onNumberSelected: model.enterValue,
                onClear: model.clearSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _NumberPad extends StatelessWidget {
  const _NumberPad({required this.onNumberSelected, required this.onClear});

  final ValueChanged<int> onNumberSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var n = 1; n <= 9; n++)
          _PadButton(label: '$n', onTap: () => onNumberSelected(n)),
        _PadButton(icon: Icons.backspace_rounded, onTap: onClear),
      ],
    );
  }
}

class _PadButton extends StatelessWidget {
  const _PadButton({this.label, this.icon, required this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: icon != null
                ? Icon(icon, size: 20)
                : Text(
              label!,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}