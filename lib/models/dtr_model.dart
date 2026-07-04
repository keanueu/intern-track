class DtrLog {
  final String id;
  final String userId;
  final DateTime timeIn;
  final DateTime? timeOut;
  final double calculatedHours;
  final String syncStatus;

  DtrLog({
    required this.id,
    required this.userId,
    required this.timeIn,
    this.timeOut,
    this.calculatedHours = 0.0,
    this.syncStatus = 'pending',
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
    );
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