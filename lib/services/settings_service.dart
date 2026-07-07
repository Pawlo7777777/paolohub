import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide settings: theme mode and sound on/off.
///
/// Exposed as a [ChangeNotifier] and registered via `provider` in main.dart
/// so any screen can read/toggle it and have the whole app rebuild.
class SettingsService extends ChangeNotifier {
  SettingsService._(this._prefs) {
    _themeMode = _readThemeMode();
    _soundOn = _prefs.getBool(_soundKey) ?? true;
  }

  final SharedPreferences _prefs;

  static const _themeKey = 'settings_theme_mode';
  static const _soundKey = 'settings_sound_on';

  late ThemeMode _themeMode;
  late bool _soundOn;

  ThemeMode get themeMode => _themeMode;
  bool get soundOn => _soundOn;

  static Future<SettingsService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService._(prefs);
  }

  ThemeMode _readThemeMode() {
    final raw = _prefs.getString(_themeKey);
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeKey, mode.name);
    notifyListeners();
  }

  Future<void> toggleSound(bool value) async {
    _soundOn = value;
    await _prefs.setBool(_soundKey, value);
    notifyListeners();
  }
}