import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/dtr_model.dart';
import '../models/profile_model.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ojt_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 5, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        role TEXT NOT NULL,
        qr_code_token TEXT UNIQUE NOT NULL,
        company TEXT DEFAULT 'Not set',
        supervisor TEXT DEFAULT 'Not set',
        required_hours REAL DEFAULT 486,
        start_date TEXT,
        avatar_path TEXT,
        account_role TEXT DEFAULT 'intern',
        email TEXT DEFAULT '',
        password TEXT DEFAULT '123456',
        department TEXT DEFAULT '',
        weekly_target_hours REAL DEFAULT 40,
        week_start_day INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE dtr_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        time_in TEXT NOT NULL,
        time_out TEXT,
        calculated_hours REAL DEFAULT 0.0,
        sync_status TEXT NOT NULL,
        break_minutes INTEGER DEFAULT 0,
        break_entries TEXT,
        activities TEXT,
        lat REAL,
        lng REAL,
        location_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE dtr_photos (
        id TEXT PRIMARY KEY,
        log_id TEXT NOT NULL,
        path TEXT NOT NULL,
        type TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE shifts (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        day_of_week INTEGER NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        break_minutes INTEGER DEFAULT 60,
        recurring INTEGER DEFAULT 1,
        effective_from TEXT,
        effective_to TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE calendar_events (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        note TEXT,
        all_day INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE competencies (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        category TEXT,
        description TEXT,
        completed INTEGER DEFAULT 0,
        completed_at TEXT,
        due_date TEXT,
        evidence_path TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Insert default intern profile so app works immediately
    await db.insert('profiles', ProfileModel.empty().toMap());
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE profiles ADD COLUMN company TEXT DEFAULT 'Not set'");
      await db.execute("ALTER TABLE profiles ADD COLUMN supervisor TEXT DEFAULT 'Not set'");
      await db.execute('ALTER TABLE profiles ADD COLUMN required_hours REAL DEFAULT 486');
      await db.execute('ALTER TABLE profiles ADD COLUMN start_date TEXT');
      // Ensure default profile exists
      final existing = await db.query('profiles', where: 'id = ?', whereArgs: ['default_user']);
      if (existing.isEmpty) {
        await db.insert('profiles', ProfileModel.empty().toMap());
      }
    }
    if (oldVersion < 3) {
      await db.execute("ALTER TABLE profiles ADD COLUMN avatar_path TEXT");
      await db.execute("ALTER TABLE profiles ADD COLUMN account_role TEXT DEFAULT 'intern'");
      await db.execute("ALTER TABLE profiles ADD COLUMN email TEXT DEFAULT ''");
      await db.execute("ALTER TABLE profiles ADD COLUMN department TEXT DEFAULT ''");
    }
    if (oldVersion < 4) {
      await db.execute("ALTER TABLE profiles ADD COLUMN password TEXT DEFAULT '123456'");
    }
    if (oldVersion < 5) {
      // Profile additions
      await db.execute("ALTER TABLE profiles ADD COLUMN weekly_target_hours REAL DEFAULT 40");
      await db.execute("ALTER TABLE profiles ADD COLUMN week_start_day INTEGER DEFAULT 1");

      // dtr_logs additions
      await db.execute("ALTER TABLE dtr_logs ADD COLUMN break_minutes INTEGER DEFAULT 0");
      await db.execute("ALTER TABLE dtr_logs ADD COLUMN break_entries TEXT");
      await db.execute("ALTER TABLE dtr_logs ADD COLUMN activities TEXT");
      await db.execute("ALTER TABLE dtr_logs ADD COLUMN lat REAL");
      await db.execute("ALTER TABLE dtr_logs ADD COLUMN lng REAL");
      await db.execute("ALTER TABLE dtr_logs ADD COLUMN location_name TEXT");

      // New tables
      await db.execute('''
        CREATE TABLE dtr_photos (
          id TEXT PRIMARY KEY,
          log_id TEXT NOT NULL,
          path TEXT NOT NULL,
          type TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE shifts (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          day_of_week INTEGER NOT NULL,
          start_time TEXT NOT NULL,
          end_time TEXT NOT NULL,
          break_minutes INTEGER DEFAULT 60,
          recurring INTEGER DEFAULT 1,
          effective_from TEXT,
          effective_to TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE calendar_events (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          date TEXT NOT NULL,
          type TEXT NOT NULL,
          note TEXT,
          all_day INTEGER DEFAULT 1
        )
      ''');

      await db.execute('''
        CREATE TABLE competencies (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          title TEXT NOT NULL,
          category TEXT,
          description TEXT,
          completed INTEGER DEFAULT 0,
          completed_at TEXT,
          due_date TEXT,
          evidence_path TEXT,
          created_at TEXT NOT NULL
        )
      ''');
    }
  }

  // ── Authentication ────────────────────────────────────────────────────────
  
  Future<ProfileModel?> authenticate(String email, String password) async {
    final db = await database;
    final rows = await db.query(
      'profiles',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ProfileModel.fromMap(rows.first);
  }

  // ── Profile (Intern self-service) ─────────────────────────────────────────

  Future<ProfileModel> getProfile() async {
    final db = await database;
    final rows = await db.query('profiles', limit: 1);
    if (rows.isEmpty) {
      final p = ProfileModel.empty();
      await db.insert('profiles', p.toMap());
      return p;
    }
    return ProfileModel.fromMap(rows.first);
  }

  Future<void> saveProfile(ProfileModel profile) async {
    final db = await database;
    await db.insert('profiles', profile.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Register a new intern — generates their profile entry
  Future<void> registerIntern(ProfileModel intern) async {
    final db = await database;
    await db.insert('profiles', intern.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get a single profile by ID
  Future<ProfileModel?> getProfileById(String id) async {
    final db = await database;
    final rows = await db.query('profiles', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return ProfileModel.fromMap(rows.first);
  }

  // ── DTR Logs (Intern self-service) ────────────────────────────────────────

  Future<String> processTimeLog(String qrToken, {double? lat, double? lng, String? locationName}) async {
    final db = await database;
    final users = await db.query('profiles', where: 'qr_code_token = ?', whereArgs: [qrToken]);
    if (users.isEmpty) return 'Invalid QR Code';

    final String userId = users.first['id'] as String;
    return _punchForUser(db, userId, lat: lat, lng: lng, locationName: locationName);
  }

  Future<String> manualPunch(String userId, {double? lat, double? lng, String? locationName}) async {
    final db = await database;
    return _punchForUser(db, userId, lat: lat, lng: lng, locationName: locationName);
  }

  Future<String> _punchForUser(Database db, String userId, {double? lat, double? lng, String? locationName}) async {
    final openLogs = await db.query(
      'dtr_logs',
      where: 'user_id = ? AND time_out IS NULL',
      whereArgs: [userId],
    );

    if (openLogs.isNotEmpty) {
      final String logId = openLogs.first['id'] as String;
      final DateTime timeIn = DateTime.parse(openLogs.first['time_in'] as String);
      final DateTime timeOut = DateTime.now();
      final int totalMinutes = timeOut.difference(timeIn).inMinutes;
      final int breakMinutes = (openLogs.first['break_minutes'] as int?) ?? 0;
      final double workHours = (totalMinutes - breakMinutes) / 60.0;

      await db.update(
        'dtr_logs',
        {
          'time_out': timeOut.toIso8601String(),
          'calculated_hours': double.parse(workHours.toStringAsFixed(2)),
          'sync_status': 'pending',
        },
        where: 'id = ?',
        whereArgs: [logId],
      );
      return 'Timed Out! Hours logged: ${workHours.toStringAsFixed(2)}h';
    } else {
      await db.insert('dtr_logs', {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'user_id': userId,
        'time_in': DateTime.now().toIso8601String(),
        'time_out': null,
        'calculated_hours': 0.0,
        'sync_status': 'pending',
        'break_minutes': 0,
        'break_entries': null,
        'activities': null,
        'lat': lat,
        'lng': lng,
        'location_name': locationName,
      });
      return 'Timed In Successfully!';
    }
  }

  Future<List<DtrLog>> getAllLogs(String userId) async {
    final db = await database;
    final rows = await db.query(
      'dtr_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'time_in DESC',
    );
    return rows.map(DtrLog.fromMap).toList();
  }

  Future<DtrLog?> getOpenLog(String userId) async {
    final db = await database;
    final rows = await db.query(
      'dtr_logs',
      where: 'user_id = ? AND time_out IS NULL',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DtrLog.fromMap(rows.first);
  }

  Future<DtrLog?> getTodayLog(String userId) async {
    final db = await database;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).toIso8601String();
    final end = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();
    final rows = await db.query(
      'dtr_logs',
      where: 'user_id = ? AND time_in >= ? AND time_in <= ?',
      whereArgs: [userId, start, end],
      orderBy: 'time_in DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DtrLog.fromMap(rows.first);
  }

  Future<double> getTotalHours(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(calculated_hours) as total FROM dtr_logs WHERE user_id = ? AND time_out IS NOT NULL',
      [userId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> getDaysPresent(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT COUNT(DISTINCT date(time_in)) as days FROM dtr_logs WHERE user_id = ? AND time_out IS NOT NULL",
      [userId],
    );
    return (result.first['days'] as int?) ?? 0;
  }

  Future<bool> isPunchedInToday(String userId) async {
    final log = await getOpenLog(userId);
    if (log == null) return false;
    final today = DateTime.now();
    return log.timeIn.year == today.year &&
        log.timeIn.month == today.month &&
        log.timeIn.day == today.day;
  }

  Future<List<DtrLog>> getLogsForWeek(String userId) async {
    final db = await database;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day).toIso8601String();
    final rows = await db.query(
      'dtr_logs',
      where: 'user_id = ? AND time_in >= ?',
      whereArgs: [userId, start],
      orderBy: 'time_in DESC',
    );
    return rows.map(DtrLog.fromMap).toList();
  }

  Future<void> deleteLog(String logId) async {
    final db = await database;
    await db.delete('dtr_logs', where: 'id = ?', whereArgs: [logId]);
    await db.delete('dtr_photos', where: 'log_id = ?', whereArgs: [logId]);
  }

  // ── Break Tracking ────────────────────────────────────────────────────────

  Future<String> startBreak(String userId, {String type = 'short'}) async {
    final db = await database;
    final openLogs = await db.query(
      'dtr_logs',
      where: 'user_id = ? AND time_out IS NULL',
      whereArgs: [userId],
      limit: 1,
    );
    if (openLogs.isEmpty) return 'No active session';

    final String logId = openLogs.first['id'] as String;
    final breakEntries = _parseBreakEntries(openLogs.first['break_entries']);
    
    // Check if there's already an ongoing break
    if (breakEntries.any((b) => b.end == null)) {
      return 'Break already in progress';
    }

    final newBreak = BreakEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      start: DateTime.now(),
      type: type,
    );
    breakEntries.add(newBreak);

    await db.update(
      'dtr_logs',
      {'break_entries': jsonEncode(breakEntries.map((e) => e.toMap()).toList())},
      where: 'id = ?',
      whereArgs: [logId],
    );
    return 'Break started';
  }

  Future<String> endBreak(String userId) async {
    final db = await database;
    final openLogs = await db.query(
      'dtr_logs',
      where: 'user_id = ? AND time_out IS NULL',
      whereArgs: [userId],
      limit: 1,
    );
    if (openLogs.isEmpty) return 'No active session';

    final String logId = openLogs.first['id'] as String;
    final breakEntries = _parseBreakEntries(openLogs.first['break_entries']);
    
    final ongoingIndex = breakEntries.indexWhere((b) => b.end == null);
    if (ongoingIndex == -1) return 'No active break to end';

    breakEntries[ongoingIndex] = BreakEntry(
      id: breakEntries[ongoingIndex].id,
      start: breakEntries[ongoingIndex].start,
      end: DateTime.now(),
      type: breakEntries[ongoingIndex].type,
    );

    // Recalculate total break minutes
    int totalBreakMinutes = 0;
    for (final b in breakEntries) {
      if (b.end != null) {
        totalBreakMinutes += b.durationMinutes;
      }
    }

    await db.update(
      'dtr_logs',
      {
        'break_entries': jsonEncode(breakEntries.map((e) => e.toMap()).toList()),
        'break_minutes': totalBreakMinutes,
      },
      where: 'id = ?',
      whereArgs: [logId],
    );
    return 'Break ended';
  }

  Future<String> setBreakType(String userId, String type) async {
    final db = await database;
    final openLogs = await db.query(
      'dtr_logs',
      where: 'user_id = ? AND time_out IS NULL',
      whereArgs: [userId],
      limit: 1,
    );
    if (openLogs.isEmpty) return 'No active session';

    final String logId = openLogs.first['id'] as String;
    final breakEntries = _parseBreakEntries(openLogs.first['break_entries']);
    
    final ongoingIndex = breakEntries.indexWhere((b) => b.end == null);
    if (ongoingIndex == -1) return 'No active break';

    breakEntries[ongoingIndex] = BreakEntry(
      id: breakEntries[ongoingIndex].id,
      start: breakEntries[ongoingIndex].start,
      end: breakEntries[ongoingIndex].end,
      type: type,
    );

    await db.update(
      'dtr_logs',
      {'break_entries': jsonEncode(breakEntries.map((e) => e.toMap()).toList())},
      where: 'id = ?',
      whereArgs: [logId],
    );
    return 'Break type updated';
  }

  List<BreakEntry> _parseBreakEntries(dynamic data) {
    if (data == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.map((e) => BreakEntry.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Activities ────────────────────────────────────────────────────────────

  Future<String> addActivity(String userId, ActivityEntry activity) async {
    final db = await database;
    final openLogs = await db.query(
      'dtr_logs',
      where: 'user_id = ? AND time_out IS NULL',
      whereArgs: [userId],
      limit: 1,
    );
    if (openLogs.isEmpty) return 'No active session';

    final String logId = openLogs.first['id'] as String;
    final activities = _parseActivities(openLogs.first['activities']);
    activities.add(activity);

    await db.update(
      'dtr_logs',
      {'activities': jsonEncode(activities.map((e) => e.toMap()).toList())},
      where: 'id = ?',
      whereArgs: [logId],
    );
    return 'Activity added';
  }

  Future<String> removeActivity(String userId, String activityId) async {
    final db = await database;
    final openLogs = await db.query(
      'dtr_logs',
      where: 'user_id = ? AND time_out IS NULL',
      whereArgs: [userId],
      limit: 1,
    );
    if (openLogs.isEmpty) return 'No active session';

    final String logId = openLogs.first['id'] as String;
    final activities = _parseActivities(openLogs.first['activities']);
    activities.removeWhere((a) => a.id == activityId);

    await db.update(
      'dtr_logs',
      {'activities': jsonEncode(activities.map((e) => e.toMap()).toList())},
      where: 'id = ?',
      whereArgs: [logId],
    );
    return 'Activity removed';
  }

  List<ActivityEntry> _parseActivities(dynamic data) {
    if (data == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.map((e) => ActivityEntry.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Photos ────────────────────────────────────────────────────────────────

  Future<void> addPhoto(DtrPhoto photo) async {
    final db = await database;
    await db.insert('dtr_photos', photo.toMap());
  }

  Future<List<DtrPhoto>> getPhotosForLog(String logId) async {
    final db = await database;
    final rows = await db.query(
      'dtr_photos',
      where: 'log_id = ?',
      whereArgs: [logId],
      orderBy: 'created_at ASC',
    );
    return rows.map(DtrPhoto.fromMap).toList();
  }

  Future<void> deletePhoto(String photoId) async {
    final db = await database;
    await db.delete('dtr_photos', where: 'id = ?', whereArgs: [photoId]);
  }

  // ── Shifts ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getShifts(String userId) async {
    final db = await database;
    return db.query('shifts', where: 'user_id = ?', whereArgs: [userId], orderBy: 'day_of_week ASC');
  }

  Future<void> saveShift(Map<String, dynamic> shift) async {
    final db = await database;
    await db.insert('shifts', shift, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteShift(String shiftId) async {
    final db = await database;
    await db.delete('shifts', where: 'id = ?', whereArgs: [shiftId]);
  }

  Future<void> clearShifts(String userId) async {
    final db = await database;
    await db.delete('shifts', where: 'user_id = ?', whereArgs: [userId]);
  }

  // ── Calendar Events (Holiday/Leave) ─────────────────────────────────────

  Future<List<Map<String, dynamic>>> getCalendarEvents(String userId) async {
    final db = await database;
    return db.query('calendar_events', where: 'user_id = ?', whereArgs: [userId], orderBy: 'date ASC');
  }

  Future<List<Map<String, dynamic>>> getCalendarEventsInRange(String userId, DateTime start, DateTime end) async {
    final db = await database;
    return db.query(
      'calendar_events',
      where: 'user_id = ? AND date >= ? AND date <= ?',
      whereArgs: [userId, start.toIso8601String().substring(0, 10), end.toIso8601String().substring(0, 10)],
      orderBy: 'date ASC',
    );
  }

  Future<void> saveCalendarEvent(Map<String, dynamic> event) async {
    final db = await database;
    await db.insert('calendar_events', event, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteCalendarEvent(String eventId) async {
    final db = await database;
    await db.delete('calendar_events', where: 'id = ?', whereArgs: [eventId]);
  }

  // ── Competencies ────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getCompetencies(String userId) async {
    final db = await database;
    return db.query('competencies', where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');
  }

  Future<void> saveCompetency(Map<String, dynamic> competency) async {
    final db = await database;
    await db.insert('competencies', competency, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> toggleCompetency(String competencyId, int completed) async {
    final db = await database;
    final now = completed == 1 ? DateTime.now().toIso8601String() : null;
    await db.update('competencies', {'completed': completed, 'completed_at': now}, where: 'id = ?', whereArgs: [competencyId]);
  }

  Future<void> deleteCompetency(String competencyId) async {
    final db = await database;
    await db.delete('competencies', where: 'id = ?', whereArgs: [competencyId]);
  }
}