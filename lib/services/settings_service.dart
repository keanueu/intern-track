import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

enum AppThemeMode { system, light, dark }

class SettingsService extends ChangeNotifier {
  static final SettingsService instance = SettingsService._();
  SettingsService._();

  bool _lockEnabled = false;
  int _lockTimeoutSeconds = 30;
  AppThemeMode _themeMode = AppThemeMode.dark;
  bool _remindersEnabled = true;

  bool get lockEnabled => _lockEnabled;
  int get lockTimeoutSeconds => _lockTimeoutSeconds;
  AppThemeMode get themeMode => _themeMode;
  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case AppThemeMode.system: return ThemeMode.system;
      case AppThemeMode.light: return ThemeMode.light;
      case AppThemeMode.dark: return ThemeMode.dark;
    }
  }
  bool get remindersEnabled => _remindersEnabled;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _lockEnabled = prefs.getBool('lock_enabled') ?? false;
    _lockTimeoutSeconds = prefs.getInt('lock_timeout') ?? 30;
    _themeMode = AppThemeMode.values[prefs.getInt('theme_mode') ?? 2];
    _remindersEnabled = prefs.getBool('reminders_enabled') ?? true;
    notifyListeners();
  }

  Future<void> setLockEnabled(bool value) async {
    _lockEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lock_enabled', value);
  }

  Future<void> setLockTimeout(int seconds) async {
    _lockTimeoutSeconds = seconds;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lock_timeout', seconds);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  Future<void> setRemindersEnabled(bool value,
      {List<Map<String, dynamic>>? shifts}) async {
    _remindersEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminders_enabled', value);
    if (value && shifts != null && shifts.isNotEmpty) {
      await NotificationService.instance.scheduleShiftReminders(shifts);
    } else if (!value) {
      await NotificationService.instance.cancelAll();
    }
  }
}
