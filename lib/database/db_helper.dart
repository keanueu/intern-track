import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
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
        start_date TEXT
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

    // Insert default profile so app works immediately
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
  }

  // ── Profile ────────────────────────────────────────────────────────────────

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

  // ── DTR Logs ───────────────────────────────────────────────────────────────

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
}
