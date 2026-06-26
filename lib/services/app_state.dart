import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import '../database/db_helper.dart';
import '../models/profile_model.dart';
import '../models/dtr_model.dart';

class AppState extends ChangeNotifier {
  ProfileModel _profile = ProfileModel.empty();
  List<DtrLog> _logs = [];
  double _totalHours = 0;
  int _daysPresent = 0;
  DtrLog? _openLog;
  bool _loading = false;

  // sqflite only works on Android/iOS
  static bool get _dbSupported {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  ProfileModel get profile => _profile;
  List<DtrLog> get logs => _logs;
  double get totalHours => _totalHours;
  int get daysPresent => _daysPresent;
  DtrLog? get openLog => _openLog;
  bool get loading => _loading;
  bool get isPunchedIn => _openLog != null;
  double get requiredHours => _profile.requiredHours;
  double get remainingHours => (_profile.requiredHours - _totalHours).clamp(0, _profile.requiredHours);
  double get completionPercent => _totalHours / _profile.requiredHours;
  String get currentRole => _profile.role;
  bool get isLoggedIn => _profile.id != 'default_user' && _profile.id.isNotEmpty;

  Future<void> login(String email, String password) async {
    if (!_dbSupported) return;
    _loading = true;
    notifyListeners();

    final user = await DBHelper.instance.authenticate(email, password);
    if (user != null) {
      _profile = user;
      await _refresh();
    }

    _loading = false;
    notifyListeners();
  }

  void logout() {
    _profile = ProfileModel.empty();
    _logs = [];
    _totalHours = 0;
    _daysPresent = 0;
    _openLog = null;
    notifyListeners();
  }

  Future<void> load() async {
    if (!_dbSupported) return;

    _loading = true;
    notifyListeners();

    try {
      // Keep load() non-destructive. If we are already logged in, just refresh.
      if (isLoggedIn) {
        await _refresh();
      } else {
        // Fallback for development if no user is logged in
        _profile = await DBHelper.instance.getProfile();
        await _refresh();
      }
    } catch (_) {}

    _loading = false;
    notifyListeners();
  }

  Future<void> _refresh() async {
    if (!_dbSupported) return;
    final id = _profile.id;
    _logs = await DBHelper.instance.getAllLogs(id);
    _totalHours = await DBHelper.instance.getTotalHours(id);
    _daysPresent = await DBHelper.instance.getDaysPresent(id);
    _openLog = await DBHelper.instance.getOpenLog(id);
  }

  Future<String> punch() async {
    if (!_dbSupported) return 'Available on mobile only';
    final result = await DBHelper.instance.manualPunch(_profile.id);
    await _refresh();
    notifyListeners();
    return result;
  }

  Future<String> scanPunch(String qrToken) async {
    if (!_dbSupported) return 'Available on mobile only';
    final result = await DBHelper.instance.processTimeLog(qrToken);
    await _refresh();
    notifyListeners();
    return result;
  }

  Future<void> deleteLog(String logId) async {
    if (!_dbSupported) return;
    await DBHelper.instance.deleteLog(logId);
    await _refresh();
    notifyListeners();
  }

  Future<void> saveProfile(ProfileModel updated) async {
    _profile = updated;
    notifyListeners();
    if (!_dbSupported) return;
    await DBHelper.instance.saveProfile(updated);
  }

  List<DtrLog> get weekLogs {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return _logs.where((l) => l.timeIn.isAfter(start)).toList();
  }

  bool hasPunchedOn(DateTime date) {
    return _logs.any((l) =>
        l.timeIn.year == date.year &&
        l.timeIn.month == date.month &&
        l.timeIn.day == date.day &&
        l.timeOut != null);
  }
}
