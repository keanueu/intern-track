import 'dart:convert';

class DtrLog {
  final String id;
  final String userId;
  final DateTime timeIn;
  final DateTime? timeOut;
  final double calculatedHours;
  final String syncStatus;
  final int breakMinutes;
  final List<BreakEntry> breakEntries;
  final List<ActivityEntry> activities;
  final double? lat;
  final double? lng;
  final String? locationName;

  DtrLog({
    required this.id,
    required this.userId,
    required this.timeIn,
    this.timeOut,
    this.calculatedHours = 0.0,
    this.syncStatus = 'pending',
    this.breakMinutes = 0,
    this.breakEntries = const [],
    this.activities = const [],
    this.lat,
    this.lng,
    this.locationName,
  });

  // Convert a DtrLog object into a Map for SQLite insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'time_in': timeIn.toIso8601String(),
      'time_out': timeOut?.toIso8601String(),
      'calculated_hours': calculatedHours,
      'sync_status': syncStatus,
      'break_minutes': breakMinutes,
      'break_entries': jsonEncode(breakEntries.map((e) => e.toMap()).toList()),
      'activities': jsonEncode(activities.map((e) => e.toMap()).toList()),
      'lat': lat,
      'lng': lng,
      'location_name': locationName,
    };
  }

  // Convert SQLite row back into a DtrLog object
  factory DtrLog.fromMap(Map<String, dynamic> map) {
    return DtrLog(
      id: map['id'],
      userId: map['user_id'],
      timeIn: DateTime.parse(map['time_in']),
      timeOut: map['time_out'] != null ? DateTime.parse(map['time_out']) : null,
      calculatedHours: (map['calculated_hours'] as num?)?.toDouble() ?? 0.0,
      syncStatus: map['sync_status'] ?? 'pending',
      breakMinutes: (map['break_minutes'] as num?)?.toInt() ?? 0,
      breakEntries: _parseBreakEntries(map['break_entries']),
      activities: _parseActivities(map['activities']),
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
      locationName: map['location_name'] as String?,
    );
  }

  static List<BreakEntry> _parseBreakEntries(dynamic data) {
    if (data == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.map((e) => BreakEntry.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static List<ActivityEntry> _parseActivities(dynamic data) {
    if (data == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.map((e) => ActivityEntry.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Whether this log looks anomalous (orphaned session > 12h or impossibly long)
  bool get isAnomaly {
    if (timeOut == null) {
      // Open session older than 12 hours
      return DateTime.now().difference(timeIn).inHours >= 12;
    }
    // Completed session longer than 12 hours
    return calculatedHours > 12.0;
  }
}

class BreakEntry {
  final String id;
  final DateTime start;
  final DateTime? end;
  final String type; // 'lunch' | 'short' | 'custom'

  BreakEntry({
    required this.id,
    required this.start,
    this.end,
    this.type = 'short',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'start': start.toIso8601String(),
    'end': end?.toIso8601String(),
    'type': type,
  };

  factory BreakEntry.fromMap(Map<String, dynamic> map) => BreakEntry(
    id: map['id'],
    start: DateTime.parse(map['start']),
    end: map['end'] != null ? DateTime.parse(map['end']) : null,
    type: map['type'] ?? 'short',
  );

  int get durationMinutes {
    final endTime = end ?? DateTime.now();
    return endTime.difference(start).inMinutes;
  }
}

class ActivityEntry {
  final String id;
  final String tag; // 'coding', 'meetings', 'docs', 'testing', 'research', 'admin', 'learning', 'other'
  final String? note;
  final int durationMinutes;

  ActivityEntry({
    required this.id,
    required this.tag,
    this.note,
    this.durationMinutes = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'tag': tag,
    'note': note,
    'duration_minutes': durationMinutes,
  };

  factory ActivityEntry.fromMap(Map<String, dynamic> map) => ActivityEntry(
    id: map['id'],
    tag: map['tag'],
    note: map['note'],
    durationMinutes: (map['duration_minutes'] as num?)?.toInt() ?? 0,
  );
}

class DtrPhoto {
  final String id;
  final String logId;
  final String path;
  final String type; // 'time_in' | 'time_out' | 'break_start' | 'break_end'
  final DateTime createdAt;

  DtrPhoto({
    required this.id,
    required this.logId,
    required this.path,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'log_id': logId,
    'path': path,
    'type': type,
    'created_at': createdAt.toIso8601String(),
  };

  factory DtrPhoto.fromMap(Map<String, dynamic> map) => DtrPhoto(
    id: map['id'],
    logId: map['log_id'],
    path: map['path'],
    type: map['type'],
    createdAt: DateTime.parse(map['created_at']),
  );
}