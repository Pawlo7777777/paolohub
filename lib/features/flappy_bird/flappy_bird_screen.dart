import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../services/storage_service.dart';
import '../../core/widgets/game_over_dialog.dart';
import '../../core/widgets/score_board.dart';
import './models/flappy_bird_engine.dart';
import './widgets/flappy_bird_widget.dart';

class FlappyBirdScreen extends StatefulWidget {
  const FlappyBirdScreen({super.key});

  @override
  State<FlappyBirdScreen> createState() => _FlappyBirdScreenState();
}

class _FlappyBirdScreenState extends State<FlappyBirdScreen>
    with SingleTickerProviderStateMixin {
  static const _storageKey = 'best_score_flappy_bird';

  final FlappyBirdModel _model = FlappyBirdModel();
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _model.addListener(_onModelChanged);
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    // Clamp dt so a dropped frame (e.g. app briefly backgrounded) can't
    // cause a huge physics jump when it resumes.
    _model.tick(dt.clamp(0, 1 / 30));
  }

  void _onModelChanged() {
    if (_model.isGameOver && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final isNewBest = await StorageService.instance
            .maybeSaveBestScore(_storageKey, _model.score);
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => GameOverDialog(
            title: 'Game Over',
            message: 'Score: ${_model.score}',
            isNewBest: isNewBest,
            onPlayAgain: () {
              _dialogShown = false;
              _model.start();
            },
          ),
        );
      });
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    _model.removeListener(_onModelChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bestScore = StorageService.instance.getBestScore(_storageKey);

    return Scaffold(
      appBar: AppBar(title: const Text('Flappy Bird')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ScoreBoard(
                stats: [
                  ScoreStat(
                    label: 'Score',
                    value: '${_model.score}',
                    icon: Icons.star_rounded,
                  ),
                  ScoreStat(
                    label: 'Best',
                    value: '$bestScore',
                    icon: Icons.emoji_events_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    _model.configure(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _model.jump,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          color: const Color(0xFFBEEBFF),
                          child: Stack(
                            children: [
                              CustomPaint(
                                size: Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                ),
                                painter: FlappyBirdPainter(
                                  birdY: _model.birdY,
                                  rotation: _model.rotation,
                                  pipes: _model.pipes,
                                ),
                              ),
                              if (!_model.hasStarted)
                                const Center(
                                  child: Text(
                                    'Tap to start',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}