import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';
import '../models/profile_model.dart';
import '../models/dtr_model.dart';
import 'settings_service.dart';
import 'notification_service.dart';

class AppState extends ChangeNotifier {
  ProfileModel _profile = ProfileModel.empty();
  List<DtrLog> _logs = [];
  double _totalHours = 0;
  int _daysPresent = 0;
  DtrLog? _openLog;
  bool _loading = false;
  List<Map<String, dynamic>> _shifts = [];
  List<Map<String, dynamic>> _calendarEvents = [];
  List<Map<String, dynamic>> _competencies = [];
  
  // In-memory fallback for unsupported platforms (e.g., Web)
  static final List<ProfileModel> _mockProfiles = [
    ProfileModel.empty(),
  ];
  Future<void> _loadMockProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('mock_profiles');
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      _mockProfiles.clear();
      _mockProfiles.addAll(decoded.map((m) => ProfileModel.fromMap(m)));
    }
  }

  Future<void> _saveMockProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_mockProfiles.map((p) => p.toMap()).toList());
    await prefs.setString('mock_profiles', data);
  }

  // sqflite only works on Android/iOS
  static bool get _dbSupported {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
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
  bool get isLoggedIn => _profile.id != 'default_user' && _profile.id.isNotEmpty;

  Future<void> login(String email, String password) async {
    _loading = true;
    notifyListeners();

    if (!_dbSupported) {
      await _loadMockProfiles();
      try {
        _profile = _mockProfiles.firstWhere((p) => p.email == email && p.password == password);
      } catch (_) {
        // Not found
      }
    } else {
      final user = await DBHelper.instance.authenticate(email, password);
      if (user != null) {
        _profile = user;
        await _refresh();
      }
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> register(String fullName, String email, String password) async {
    _loading = true;
    notifyListeners();

    final newProfile = ProfileModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: fullName,
      qrCodeToken: DateTime.now().millisecondsSinceEpoch.toString(),
      company: 'Not set',
      supervisor: 'Not set',
      requiredHours: 486,
      course: 'BSIT',
      batch: 'Batch 2025',
      startDate: DateTime.now().toIso8601String(),
      email: email,
      password: password,
      department: '',
    );

    if (!_dbSupported) {
      await _loadMockProfiles();
      _mockProfiles.add(newProfile);
      await _saveMockProfiles();
      _profile = newProfile;
    } else {
      await DBHelper.instance.registerIntern(newProfile);
      _profile = newProfile;
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

    _scheduleRemindersIfNeeded();
  }

  Future<void> _scheduleRemindersIfNeeded() async {
    if (!_dbSupported) return;
    final settings = SettingsService.instance;
    if (settings.remindersEnabled && _shifts.isNotEmpty) {
      await NotificationService.instance.scheduleShiftReminders(_shifts);
    }
  }

  Future<void> _refresh() async {
    if (!_dbSupported) return;
    final id = _profile.id;
    _logs = await DBHelper.instance.getAllLogs(id);
    _totalHours = await DBHelper.instance.getTotalHours(id);
    _daysPresent = await DBHelper.instance.getDaysPresent(id);
    _openLog = await DBHelper.instance.getOpenLog(id);
    _shifts = await DBHelper.instance.getShifts(id);
    _calendarEvents = await DBHelper.instance.getCalendarEvents(id);
    _competencies = await DBHelper.instance.getCompetencies(id);
  }

  Future<String> punch({double? lat, double? lng, String? locationName}) async {
    if (!_dbSupported) return 'Available on mobile only';
    final result = await DBHelper.instance.manualPunch(_profile.id, lat: lat, lng: lng, locationName: locationName);
    await _refresh();
    notifyListeners();
    return result;
  }

  Future<String> scanPunch(String qrToken, {double? lat, double? lng, String? locationName}) async {
    if (!_dbSupported) return 'Available on mobile only';
    final result = await DBHelper.instance.processTimeLog(qrToken, lat: lat, lng: lng, locationName: locationName);
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

  // ── Break Tracking ───────────────────────────────────────────────────────

  bool get isOnBreak {
    if (_openLog == null) return false;
    return _openLog!.breakEntries.any((b) => b.end == null);
  }

  BreakEntry? get activeBreak {
    if (_openLog == null) return null;
    try {
      return _openLog!.breakEntries.firstWhere((b) => b.end == null);
    } catch (_) {
      return null;
    }
  }

  int get todayBreakMinutes {
    final today = DateTime.now();
    return _logs
        .where((l) =>
            l.timeIn.year == today.year &&
            l.timeIn.month == today.month &&
            l.timeIn.day == today.day)
        .fold(0, (sum, l) => sum + l.breakMinutes);
  }

  Future<String> startBreak() async {
    if (!_dbSupported) return 'Available on mobile only';
    final result = await DBHelper.instance.startBreak(_profile.id);
    await _refresh();
    notifyListeners();
    return result;
  }

  Future<String> endBreak() async {
    if (!_dbSupported) return 'Available on mobile only';
    final result = await DBHelper.instance.endBreak(_profile.id);
    await _refresh();
    notifyListeners();
    return result;
  }

  Future<String> setBreakType(String type) async {
    if (!_dbSupported) return 'Available on mobile only';
    final result = await DBHelper.instance.setBreakType(_profile.id, type);
    await _refresh();
    notifyListeners();
    return result;
  }

  // ── Activities ───────────────────────────────────────────────────────────

  Future<String> addActivity(ActivityEntry activity) async {
    if (!_dbSupported) return 'Available on mobile only';
    final result = await DBHelper.instance.addActivity(_profile.id, activity);
    await _refresh();
    notifyListeners();
    return result;
  }

  Future<String> removeActivity(String activityId) async {
    if (!_dbSupported) return 'Available on mobile only';
    final result = await DBHelper.instance.removeActivity(_profile.id, activityId);
    await _refresh();
    notifyListeners();
    return result;
  }

  // ── Photos ───────────────────────────────────────────────────────────────

  Future<void> addPhoto(DtrPhoto photo) async {
    if (!_dbSupported) return;
    await DBHelper.instance.addPhoto(photo);
  }

  Future<List<DtrPhoto>> getPhotosForLog(String logId) async {
    if (!_dbSupported) return [];
    return DBHelper.instance.getPhotosForLog(logId);
  }

  Future<void> deletePhoto(String photoId) async {
    if (!_dbSupported) return;
    await DBHelper.instance.deletePhoto(photoId);
  }

  // ── Weekly Stats ────────────────────────────────────────────────────────

  double get weeklyHours {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(start.year, start.month, start.day);
    return _logs
        .where((l) => l.timeOut != null && l.timeIn.isAfter(weekStart))
        .fold(0.0, (sum, l) => sum + l.calculatedHours);
  }

  double get weeklyTarget => _profile.weeklyTargetHours;

  double get weeklyPercent => weeklyTarget > 0 ? (weeklyHours / weeklyTarget).clamp(0.0, 1.0) : 0.0;

  // ── Shifts ──────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get shifts => _shifts;

  Future<void> loadShifts() async {
    if (!_dbSupported) return;
    _shifts = await DBHelper.instance.getShifts(_profile.id);
    notifyListeners();
  }

  Future<void> saveShift(Map<String, dynamic> shift) async {
    if (!_dbSupported) return;
    await DBHelper.instance.saveShift(shift);
    await loadShifts();
  }

  Future<void> deleteShift(String shiftId) async {
    if (!_dbSupported) return;
    await DBHelper.instance.deleteShift(shiftId);
    await loadShifts();
  }

  Future<void> clearShifts() async {
    if (!_dbSupported) return;
    await DBHelper.instance.clearShifts(_profile.id);
    await loadShifts();
  }

  Map<String, dynamic>? get todayShift {
    final today = DateTime.now().weekday - 1;
    try {
      return _shifts.firstWhere((s) => s['day_of_week'] == today || (today == 6 && s['day_of_week'] == 7));
    } catch (_) {
      return null;
    }
  }

  // ── Calendar Events (Holiday/Leave) ─────────────────────────────────────

  List<Map<String, dynamic>> get calendarEvents => _calendarEvents;

  Future<void> loadCalendarEvents() async {
    if (!_dbSupported) return;
    _calendarEvents = await DBHelper.instance.getCalendarEvents(_profile.id);
    notifyListeners();
  }

  Future<void> saveCalendarEvent(Map<String, dynamic> event) async {
    if (!_dbSupported) return;
    await DBHelper.instance.saveCalendarEvent(event);
    await loadCalendarEvents();
  }

  Future<void> deleteCalendarEvent(String eventId) async {
    if (!_dbSupported) return;
    await DBHelper.instance.deleteCalendarEvent(eventId);
    await loadCalendarEvents();
  }

  bool isDateExcluded(DateTime date) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _calendarEvents.any((e) => e['date'] == dateStr);
  }

  // ── Competencies ────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get competencies => _competencies;

  Future<void> loadCompetencies() async {
    if (!_dbSupported) return;
    _competencies = await DBHelper.instance.getCompetencies(_profile.id);
    notifyListeners();
  }

  Future<void> saveCompetency(Map<String, dynamic> competency) async {
    if (!_dbSupported) return;
    await DBHelper.instance.saveCompetency(competency);
    await loadCompetencies();
  }

  Future<void> toggleCompetency(String competencyId, int completed) async {
    if (!_dbSupported) return;
    await DBHelper.instance.toggleCompetency(competencyId, completed);
    await loadCompetencies();
  }

  Future<void> deleteCompetency(String competencyId) async {
    if (!_dbSupported) return;
    await DBHelper.instance.deleteCompetency(competencyId);
    await loadCompetencies();
  }

  int get completedCompetencies => _competencies.where((c) => c['completed'] == 1).length;
  int get totalCompetencies => _competencies.length;
  double get competencyPercent => totalCompetencies > 0 ? completedCompetencies / totalCompetencies : 0.0;
}
