import 'package:flutter/material.dart';

/// Static metadata describing one game in the hub.
///
/// This is intentionally storage-agnostic — it just describes how to
/// render a tile and which route to push. Best-score lookups are done
/// separately via `storageKey` + StorageService (added in Deliverable 2).
class GameInfo {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  /// Key used to read/write this game's best score via StorageService.
  final String storageKey;

  const GameInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
    required this.storageKey,
  });
}

/// Single source of truth for "which games exist in the hub".
/// Add/remove a game here and the Home screen grid updates automatically.
class GameCatalog {
  GameCatalog._();

  static const List<GameInfo> games = [
    GameInfo(
      id: 'game_2048',
      title: '2048',
      subtitle: 'Swipe & merge tiles',
      icon: Icons.grid_view_rounded,
      color: Color(0xFFFF6B4A),
      route: '/game/2048',
      storageKey: 'best_score_2048',
    ),
    GameInfo(
      id: 'memory_match',
      title: 'Memory Match',
      subtitle: 'Flip cards, find pairs',
      icon: Icons.style_rounded,
      color: Color(0xFF2EC4B6),
      route: '/game/memory-match',
      storageKey: 'best_score_memory_match',
    ),
    GameInfo(
      id: 'tic_tac_toe',
      title: 'Tic Tac Toe',
      subtitle: '2-player or vs AI',
      icon: Icons.close_rounded,
      color: Color(0xFF6C63FF),
      route: '/game/tic-tac-toe',
      storageKey: 'best_score_tic_tac_toe',
    ),
    GameInfo(
      id: 'flappy_bird',
      title: 'Flappy Bird',
      subtitle: 'Tap to fly, dodge pipes',
      icon: Icons.flutter_dash_rounded,
      color: Color(0xFFFFC93C),
      route: '/game/flappy-bird',
      storageKey: 'best_score_flappy_bird',
    ),
    GameInfo(
      id: 'sudoku',
      title: 'Sudoku',
      subtitle: 'Fill the grid, no repeats',
      icon: Icons.apps_rounded,
      color: Color(0xFF3AAFA9),
      route: '/game/sudoku',
      storageKey: 'best_score_sudoku',
    ),
  ];
}