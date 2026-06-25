import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/profile_model.dart';
import '../models/dtr_model.dart';
import '../models/team_stats.dart';

class AdminState extends ChangeNotifier {
  List<ProfileModel> _interns = [];
  List<DtrLog> _allLogs = [];
  List<DtrLog> _anomalies = [];
  TeamStats _stats = TeamStats.empty();
  bool _loading = false;
  
  // Filters
  String? _filterInternId;
  DateTime? _filterFrom;
  DateTime? _filterTo;
  
  List<ProfileModel> get interns => _interns;
  List<DtrLog> get allLogs => _allLogs;
  List<DtrLog> get anomalies => _anomalies;
  TeamStats get stats => _stats;
  bool get loading => _loading;

  String? get filterInternId => _filterInternId;
  DateTime? get filterFrom => _filterFrom;
  DateTime? get filterTo => _filterTo;

  List<DtrLog> get filteredLogs {
    return _allLogs;
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    try {
      _interns = await DBHelper.instance.getAllInterns();
      _anomalies = await DBHelper.instance.getAnomalyLogs();
      _stats = await DBHelper.instance.getTeamStats();
      await applyFilters(
        internId: _filterInternId,
        from: _filterFrom,
        to: _filterTo,
      );
    } catch (e) {
      debugPrint("Error loading admin state: $e");
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> applyFilters({String? internId, DateTime? from, DateTime? to}) async {
    _filterInternId = internId;
    _filterFrom = from;
    _filterTo = to;
    
    _allLogs = await DBHelper.instance.getAllLogsAdmin(
      internId: internId,
      from: from,
      to: to,
    );
    notifyListeners();
  }

  Future<void> registerIntern(ProfileModel intern) async {
    await DBHelper.instance.registerIntern(intern);
    await load();
  }

  Future<void> deleteIntern(String id) async {
    await DBHelper.instance.deleteIntern(id);
    await load();
  }

  Future<void> updateLog(String logId, {DateTime? timeIn, DateTime? timeOut}) async {
    await DBHelper.instance.updateLog(logId, timeIn: timeIn, timeOut: timeOut);
    await load();
  }

  Future<void> closeOrphanedLog(String logId, DateTime timeOut) async {
    await DBHelper.instance.closeOrphanedLog(logId, timeOut);
    await load();
  }
}
