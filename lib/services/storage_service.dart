import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] for simple per-game data:
/// best scores, unlocked cosmetics, coin balance, etc.
///
/// Anything more structured (e.g. a paused Sudoku board) should use Hive
/// instead — see the Sudoku feature folder for that pattern once it's built.
class StorageService {
  StorageService._(this._prefs);

  final SharedPreferences _prefs;

  static StorageService? _instance;

  /// Must be awaited once (e.g. in `main()`) before the app uses it.
  static Future<StorageService> init() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = StorageService._(prefs);
    return _instance!;
  }

  /// Convenience accessor once [init] has run. Throws if called too early.
  static StorageService get instance {
    final i = _instance;
    if (i == null) {
      throw StateError(
        'StorageService.init() must be awaited before StorageService.instance is used.',
      );
    }
    return i;
  }

  // ---- Best scores (per game, keyed by GameInfo.storageKey) ----

  int getBestScore(String key) => _prefs.getInt(key) ?? 0;

  /// Saves [score] as the new best only if it beats the current best.
  /// Returns true if a new best score was set.
  Future<bool> maybeSaveBestScore(String key, int score) async {
    final current = getBestScore(key);
    if (score > current) {
      await _prefs.setInt(key, score);
      return true;
    }
    return false;
  }

  /// For "lower is better" records, like a completion time in seconds.
  /// A stored value of 0 (unset) always counts as beaten.
  /// Returns true if a new best time was set.
  Future<bool> maybeSaveBestTime(String key, int seconds) async {
    final current = getBestScore(key);
    if (current == 0 || seconds < current) {
      await _prefs.setInt(key, seconds);
      return true;
    }
    return false;
  }

  // ---- Coins (simple local points economy, optional feature) ----

  int get coins => _prefs.getInt('coins') ?? 0;

  Future<void> addCoins(int amount) async {
    await _prefs.setInt('coins', coins + amount);
  }

  Future<bool> spendCoins(int amount) async {
    if (coins < amount) return false;
    await _prefs.setInt('coins', coins - amount);
    return true;
  }

  // ---- Reset everything (used by Settings > "Reset all progress") ----

  Future<void> resetAllProgress() async {
    for (final game in [
      'best_score_2048',
      'best_score_memory_match',
      'best_time_memory_match_4x4',
      'best_time_memory_match_6x6',
      'best_score_tic_tac_toe',
      'best_score_flappy_bird',
      'best_score_sudoku',
    ]) {
      await _prefs.remove(game);
    }
    await _prefs.remove('coins');
  }
}