import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/storage_service.dart';
import '../../core/widgets/game_over_dialog.dart';
import '../../core/widgets/score_board.dart';
import './widgets/game_2048_board.dart';
import './models/game_2048_engine.dart';

class Game2048Screen extends StatelessWidget {
  const Game2048Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Game2048Model(),
      child: const _Game2048View(),
    );
  }
}

class _Game2048View extends StatefulWidget {
  const _Game2048View();

  @override
  State<_Game2048View> createState() => _Game2048ViewState();
}

class _Game2048ViewState extends State<_Game2048View> {
  static const _storageKey = 'best_score_2048';
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<Game2048Model>();
    final bestScore = StorageService.instance.getBestScore(_storageKey);

    if (model.isGameOver && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final isNewBest = await StorageService.instance
            .maybeSaveBestScore(_storageKey, model.score);
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => GameOverDialog(
            title: 'Game Over',
            message: 'Score: ${model.score}',
            isNewBest: isNewBest,
            onPlayAgain: () {
              model.reset();
              setState(() => _dialogShown = false);
            },
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('2048')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ScoreBoard(
                stats: [
                  ScoreStat(
                    label: 'Score',
                    value: '${model.score}',
                    icon: Icons.star_rounded,
                  ),
                  ScoreStat(
                    label: 'Best',
                    value: '$bestScore',
                    icon: Icons.emoji_events_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onPanEnd: (details) => _handleSwipeEnd(model, details),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Game2048Board(grid: model.grid),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  model.reset();
                  setState(() => _dialogShown = false);
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Restart'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSwipeEnd(Game2048Model model, DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    if (velocity.distance < 100) return;

    if (velocity.dx.abs() > velocity.dy.abs()) {
      model.move(velocity.dx > 0 ? SwipeDirection.right : SwipeDirection.left);
    } else {
      model.move(velocity.dy > 0 ? SwipeDirection.down : SwipeDirection.up);
    }
  }
}