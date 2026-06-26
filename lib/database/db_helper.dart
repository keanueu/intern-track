import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/dtr_model.dart';
import '../models/profile_model.dart';
import '../models/team_stats.dart';

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
    return await openDatabase(path, version: 4, onCreate: _createDB, onUpgrade: _upgradeDB);
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
        department TEXT DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE dtr_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        time_in TEXT NOT NULL,
        time_out TEXT,
        calculated_hours REAL DEFAULT 0.0,
        sync_status TEXT NOT NULL
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
      // Add default admin if not exists
      final admins = await db.query('profiles', where: 'account_role = ?', whereArgs: ['admin']);
      if (admins.isEmpty) {
        await db.insert('profiles', ProfileModel.admin().toMap());
      }
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
    final rows = await db.query('profiles',
        where: "account_role = ? OR account_role IS NULL",
        whereArgs: ['intern'],
        limit: 1);
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

  // ── Admin: Profile Management ─────────────────────────────────────────────

  /// Get all registered intern profiles (excludes admin accounts)
  Future<List<ProfileModel>> getAllInterns() async {
    final db = await database;
    final rows = await db.query('profiles',
        where: "account_role = ? OR account_role IS NULL",
        whereArgs: ['intern'],
        orderBy: 'full_name ASC');
    return rows.map(ProfileModel.fromMap).toList();
  }

  /// Register a new intern — generates their profile entry
  Future<void> registerIntern(ProfileModel intern) async {
    final db = await database;
    await db.insert('profiles', intern.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Delete an intern and all their DTR logs
  Future<void> deleteIntern(String internId) async {
    final db = await database;
    await db.delete('dtr_logs', where: 'user_id = ?', whereArgs: [internId]);
    await db.delete('profiles', where: 'id = ?', whereArgs: [internId]);
  }

  /// Get a single profile by ID
  Future<ProfileModel?> getProfileById(String id) async {
    final db = await database;
    final rows = await db.query('profiles', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return ProfileModel.fromMap(rows.first);
  }

  // ── DTR Logs (Intern self-service) ────────────────────────────────────────

  Future<String> processTimeLog(String qrToken) async {
    final db = await database;
    final users = await db.query('profiles', where: 'qr_code_token = ?', whereArgs: [qrToken]);
    if (users.isEmpty) return 'Invalid QR Code';

    final String userId = users.first['id'] as String;
    return _punchForUser(db, userId);
  }

  Future<String> manualPunch(String userId) async {
    final db = await database;
    return _punchForUser(db, userId);
  }

  Future<String> _punchForUser(Database db, String userId) async {
    final openLogs = await db.query(
      'dtr_logs',
      where: 'user_id = ? AND time_out IS NULL',
      whereArgs: [userId],
    );

    if (openLogs.isNotEmpty) {
      final String logId = openLogs.first['id'] as String;
      final DateTime timeIn = DateTime.parse(openLogs.first['time_in'] as String);
      final DateTime timeOut = DateTime.now();
      final double hours = timeOut.difference(timeIn).inMinutes / 60.0;

      await db.update(
        'dtr_logs',
        {
          'time_out': timeOut.toIso8601String(),
          'calculated_hours': double.parse(hours.toStringAsFixed(2)),
          'sync_status': 'pending',
        },
        where: 'id = ?',
        whereArgs: [logId],
      );
      return 'Timed Out! Hours logged: ${hours.toStringAsFixed(2)}h';
    } else {
      await db.insert('dtr_logs', {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'user_id': userId,
        'time_in': DateTime.now().toIso8601String(),
        'time_out': null,
        'calculated_hours': 0.0,
        'sync_status': 'pending',
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
  }

  // ── Admin: DTR Log Management ─────────────────────────────────────────────

  /// Get all logs across all interns with intern name attached (for admin timesheet)
  Future<List<DtrLog>> getAllLogsAdmin({
    String? internId,
    DateTime? from,
    DateTime? to,
    bool anomaliesOnly = false,
  }) async {
    final db = await database;

    String query = '''
      SELECT dtr_logs.*, profiles.full_name as intern_name
      FROM dtr_logs
      LEFT JOIN profiles ON dtr_logs.user_id = profiles.id
      WHERE 1=1
    ''';
    final List<dynamic> args = [];

    if (internId != null) {
      query += ' AND dtr_logs.user_id = ?';
      args.add(internId);
    }
    if (from != null) {
      query += ' AND dtr_logs.time_in >= ?';
      args.add(DateTime(from.year, from.month, from.day).toIso8601String());
    }
    if (to != null) {
      query += ' AND dtr_logs.time_in <= ?';
      args.add(DateTime(to.year, to.month, to.day, 23, 59, 59).toIso8601String());
    }

    query += ' ORDER BY dtr_logs.time_in DESC';

    final rows = await db.rawQuery(query, args);
    List<DtrLog> logs = rows.map(DtrLog.fromMap).toList();

    if (anomaliesOnly) {
      logs = logs.where((l) => l.isAnomaly).toList();
    }

    return logs;
  }

  /// Get anomaly logs (orphaned sessions > 12h or calculated > 12h)
  Future<List<DtrLog>> getAnomalyLogs() async {
    return getAllLogsAdmin(anomaliesOnly: true);
  }

  /// Admin: update a DTR log entry (edit timestamps)
  Future<void> updateLog(String logId, {DateTime? timeIn, DateTime? timeOut}) async {
    final db = await database;
    final updates = <String, dynamic>{};

    if (timeIn != null) {
      updates['time_in'] = timeIn.toIso8601String();
    }
    if (timeOut != null) {
      updates['time_out'] = timeOut.toIso8601String();
    }

    // Recalculate hours if both timestamps are available
    if (updates.isNotEmpty) {
      final existing = await db.query('dtr_logs', where: 'id = ?', whereArgs: [logId]);
      if (existing.isNotEmpty) {
        final effectiveIn = timeIn ?? DateTime.parse(existing.first['time_in'] as String);
        final rawOut = timeOut?.toIso8601String() ??
            existing.first['time_out'] as String?;
        if (rawOut != null) {
          final effectiveOut = DateTime.parse(rawOut);
          updates['calculated_hours'] =
              double.parse((effectiveOut.difference(effectiveIn).inMinutes / 60.0).toStringAsFixed(2));
          updates['time_out'] = rawOut;
        }
        updates['time_in'] = effectiveIn.toIso8601String();
      }

      await db.update('dtr_logs', updates, where: 'id = ?', whereArgs: [logId]);
    }
  }

  /// Admin: close an orphaned session with a specified time-out
  Future<void> closeOrphanedLog(String logId, DateTime timeOut) async {
    await updateLog(logId, timeOut: timeOut);
  }

  /// Admin: Update sync_status (e.g. approve/reject manual logs)
  Future<void> updateLogStatus(String logId, String status) async {
    final db = await database;
    await db.update('dtr_logs', {'sync_status': status}, where: 'id = ?', whereArgs: [logId]);
  }

  /// Get interns currently clocked in right now
  Future<List<Map<String, dynamic>>> getActiveSessions() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT dtr_logs.*, profiles.full_name as intern_name
      FROM dtr_logs
      LEFT JOIN profiles ON dtr_logs.user_id = profiles.id
      WHERE dtr_logs.time_out IS NULL
      ORDER BY dtr_logs.time_in DESC
    ''');
    return rows;
  }

  /// Get aggregate team statistics
  Future<TeamStats> getTeamStats() async {
    final db = await database;

    // Total interns
    final totalResult = await db.rawQuery(
        "SELECT COUNT(*) as cnt FROM profiles WHERE account_role = 'intern' OR account_role IS NULL");
    final totalInterns = (totalResult.first['cnt'] as int?) ?? 0;

    // Clocked in now
    final activeResult = await db.rawQuery(
        'SELECT COUNT(DISTINCT user_id) as cnt FROM dtr_logs WHERE time_out IS NULL');
    final clockedInNow = (activeResult.first['cnt'] as int?) ?? 0;

    // Active today (had at least one log today)
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day).toIso8601String();
    final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();
    final todayResult = await db.rawQuery(
        'SELECT COUNT(DISTINCT user_id) as cnt FROM dtr_logs WHERE time_in >= ? AND time_in <= ?',
        [todayStart, todayEnd]);
    final activeToday = (todayResult.first['cnt'] as int?) ?? 0;

    // Average completion %
    double avgCompletion = 0.0;
    if (totalInterns > 0) {
      final interns = await getAllInterns();
      double totalPct = 0.0;
      for (final intern in interns) {
        final hours = await getTotalHours(intern.id);
        if (intern.requiredHours > 0) {
          totalPct += (hours / intern.requiredHours).clamp(0.0, 1.0);
        }
      }
      avgCompletion = totalPct / totalInterns;
    }

    return TeamStats(
      totalInterns: totalInterns,
      activeToday: activeToday,
      clockedInNow: clockedInNow,
      avgCompletion: avgCompletion,
    );
  }

  /// Get total hours for each intern (for team progress display)
  Future<List<Map<String, dynamic>>> getTeamProgress() async {
    final interns = await getAllInterns();
    final List<Map<String, dynamic>> progress = [];

    for (final intern in interns) {
      final hours = await getTotalHours(intern.id);
      progress.add({
        'profile': intern,
        'totalHours': hours,
        'completion': intern.requiredHours > 0
            ? (hours / intern.requiredHours).clamp(0.0, 1.0)
            : 0.0,
      });
    }

    // Sort by completion descending
    progress.sort((a, b) => (b['completion'] as double).compareTo(a['completion'] as double));
    return progress;
  }
}
