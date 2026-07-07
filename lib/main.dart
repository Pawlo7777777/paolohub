import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import './splash_screen.dart';
import 'features/home/home_screen.dart';
import 'features/home/settings_screen.dart';
import 'features/game_2048/game_2048_screen.dart';
import 'features/memory_match/memory_match_screen.dart';
import 'features/tic_tac_toe/tic_tac_toe_screen.dart';
import 'features/flappy_bird/flappy_bird_screen.dart';
import 'features/sudoku/sudoku_screen.dart';
import 'services/settings_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Both services must be ready before the app builds its first frame,
  // since Home reads best scores and the theme depends on settings.
  await StorageService.init();
  final settings = await SettingsService.init();

  runApp(GameHubApp(settings: settings));
}

/// Root of the app: sets up the router, the shared theme, and exposes
/// [SettingsService] to the whole widget tree via `provider`.
class GameHubApp extends StatelessWidget {
  const GameHubApp({super.key, required this.settings});

  final SettingsService settings;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingsService>.value(
      value: settings,
      child: Consumer<SettingsService>(
        builder: (context, settings, _) {
          return MaterialApp.router(
            title: 'PaoloHub',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

/// Central route table: Splash -> Home -> each game screen -> Settings.
/// Adding a 6th game later only means adding one GoRoute here plus one
/// entry in `GameCatalog.games`.
final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/game/2048',
      builder: (context, state) => const Game2048Screen(),
    ),
    GoRoute(
      path: '/game/memory-match',
      builder: (context, state) => const MemoryMatchScreen(),
    ),
    GoRoute(
      path: '/game/tic-tac-toe',
      builder: (context, state) => const TicTacToeScreen(),
    ),
    GoRoute(
      path: '/game/flappy-bird',
      builder: (context, state) => const FlappyBirdScreen(),
    ),
    GoRoute(
      path: '/game/sudoku',
      builder: (context, state) => const SudokuScreen(),
    ),
  ],
);