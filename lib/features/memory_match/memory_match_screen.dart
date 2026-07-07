import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/widgets/score_board.dart';
import '../../core/widgets/game_over_dialog.dart';
import '../../services/storage_service.dart';
import 'models/memory_match_engine.dart';
import 'widgets/memory_card_widget.dart';

/// Entry screen for Memory Match.
///
/// Shows a difficulty picker (4x4 / 6x6) first, then the card grid with a
/// live timer + move counter. "Best score" is the fastest completion time,
/// tracked separately per difficulty and mirrored to the shared
/// `best_score_memory_match` key (as the faster of the two) for the Home tile.
class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  static const sharedStorageKey = 'best_score_memory_match';

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  MemoryDifficulty? _difficulty;
  late MemoryMatchEngine _engine;

  final List<int> _faceUpIndices = [];
  bool _busy = false;
  bool _dialogShown = false;

  int _elapsedSeconds = 0;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  int _bestTimeFor(MemoryDifficulty d) =>
      StorageService.instance.getBestScore(d.storageKey);

  void _selectDifficulty(MemoryDifficulty d) {
    setState(() {
      _difficulty = d;
      _engine = MemoryMatchEngine(d);
      _faceUpIndices.clear();
      _busy = false;
      _dialogShown = false;
      _elapsedSeconds = 0;
      _ticker?.cancel();
      _ticker = null;
    });
  }

  void _restart() {
    final d = _difficulty;
    if (d == null) return;
    _selectDifficulty(d);
  }

  void _startTickerIfNeeded() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);
    });
  }

  void _handleCardTap(int index) {
    if (_busy) return;
    final card = _engine.cards[index];
    if (card.matched || _faceUpIndices.contains(index)) return;

    _startTickerIfNeeded();

    setState(() => _faceUpIndices.add(index));

    if (_faceUpIndices.length < 2) return;

    _engine.registerMove();
    final a = _faceUpIndices[0];
    final b = _faceUpIndices[1];

    if (_engine.isMatch(a, b)) {
      _engine.markMatched(a, b);
      setState(() => _faceUpIndices.clear());
      if (_engine.isComplete) _handleComplete();
    } else {
      _busy = true;
      setState(() {});
      Future.delayed(const Duration(milliseconds: 650), () {
        if (!mounted) return;
        setState(() {
          _faceUpIndices.clear();
          _busy = false;
        });
      });
    }
  }

  Future<void> _handleComplete() async {
    if (_dialogShown) return;
    _dialogShown = true;
    _ticker?.cancel();

    final difficulty = _difficulty!;
    final isNewBest =
    await StorageService.instance.maybeSaveBestTime(difficulty.storageKey, _elapsedSeconds);

    // Mirror the faster of the two difficulty times to the shared key so
    // the Home screen tile shows a single "best" number for this game.
    await StorageService.instance
        .maybeSaveBestTime(MemoryMatchScreen.sharedStorageKey, _elapsedSeconds);

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(
        title: 'Solved! 🎉',
        message: 'Time: ${_formatTime(_elapsedSeconds)}   ·   Moves: ${_engine.moves}',
        isNewBest: isNewBest,
        onPlayAgain: _restart,
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Match'),
        actions: [
          if (_difficulty != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Restart',
              onPressed: _restart,
            ),
        ],
      ),
      body: SafeArea(
        child: _difficulty == null
            ? _buildDifficultyPicker(context)
            : _buildGame(context),
      ),
    );
  }

  Widget _buildDifficultyPicker(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.style_rounded, size: 56, color: theme.colorScheme.secondary),
          const SizedBox(height: 12),
          Text(
            'Choose a difficulty',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),
          for (final d in MemoryDifficulty.values) ...[
            _DifficultyButton(
              label: d.label,
              bestTime: _bestTimeFor(d),
              formatTime: _formatTime,
              onTap: () => _selectDifficulty(d),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildGame(BuildContext context) {
    final columns = _difficulty!.columns;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() {
                _ticker?.cancel();
                _ticker = null;
                _difficulty = null;
              }),
              icon: const Icon(Icons.swap_horiz_rounded, size: 18),
              label: const Text('Change difficulty'),
            ),
          ),
          ScoreBoard(
            stats: [
              ScoreStat(
                  label: 'Moves',
                  value: '${_engine.moves}',
                  icon: Icons.touch_app_rounded),
              ScoreStat(
                  label: 'Time',
                  value: _formatTime(_elapsedSeconds),
                  icon: Icons.timer_rounded),
              ScoreStat(
                  label: 'Pairs',
                  value: '${_engine.matchedPairs}/${_engine.totalPairs}',
                  icon: Icons.favorite_rounded),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              itemCount: _engine.cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final card = _engine.cards[index];
                return MemoryCardWidget(
                  symbol: card.symbol,
                  faceUp: _faceUpIndices.contains(index),
                  matched: card.matched,
                  onTap: () => _handleCardTap(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  const _DifficultyButton({
    required this.label,
    required this.bestTime,
    required this.formatTime,
    required this.onTap,
  });

  final String label;
  final int bestTime;
  final String Function(int) formatTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            if (bestTime > 0)
              Text(
                'Best ${formatTime(bestTime)}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }
}