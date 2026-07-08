import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../models/profile_model.dart';
import '../models/dtr_model.dart';

class ExportService {
  static final ExportService instance = ExportService._();
  ExportService._();

  String _fmt(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  String _fmtDate(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year}';
  }

  // ── PDF Report ───────────────────────────────────────────────────────────

  Future<Uint8List> generatePdf(ProfileModel profile, List<DtrLog> logs, double totalHours, int daysPresent) async {
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(bottom: 16),
          child: pw.Text('DAILY TIME RECORD', style: pw.TextStyle(font: fontBold, fontSize: 18, color: PdfColors.green700)),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 16),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey),
          ),
        ),
        build: (context) => [
          // Info section
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _infoRow('Name:', profile.fullName, font, fontBold),
                      _infoRow('Course:', '${profile.course} • ${profile.batch}', font, fontBold),
                      _infoRow('Company:', profile.company, font, fontBold),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _infoRow('Supervisor:', profile.supervisor, font, fontBold),
                      _infoRow('Period:', '${logs.isNotEmpty ? _fmtDate(logs.last.timeIn) : '--'} – ${logs.isNotEmpty ? _fmtDate(logs.first.timeIn) : '--'}', font, fontBold),
                      _infoRow('Required Hours:', '${profile.requiredHours.toInt()}h', font, fontBold),
                    ],
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.2),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(0.8),
              4: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.green50),
                children: [
                  _headerCell('Date', fontBold),
                  _headerCell('Time In', fontBold),
                  _headerCell('Time Out', fontBold),
                  _headerCell('Hours', fontBold),
                  _headerCell('Activities', fontBold),
                ],
              ),
              ...logs.map((log) {
                final activities = log.activities.map((a) => a.note ?? a.tag).join(', ');
                return pw.TableRow(
                  children: [
                    _cell('${_fmtDate(log.timeIn)} ${_dayAbbr(log.timeIn.weekday)}', font),
                    _cell(log.timeOut != null ? _fmt(log.timeIn) : '--:--', font),
                    _cell(log.timeOut != null ? _fmt(log.timeOut!) : 'Active', font),
                    _cell(log.timeOut != null ? '${log.calculatedHours.toStringAsFixed(1)}h' : '--', font),
                    _cell(activities.isEmpty ? '—' : activities, font),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 20),

          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              children: [
                _summaryRow('Days Present:', '$daysPresent days', font, fontBold),
                pw.SizedBox(height: 4),
                _summaryRow('Total Hours Rendered:', '${totalHours.toStringAsFixed(2)}h', font, fontBold),
                pw.SizedBox(height: 4),
                _summaryRow('Required Hours:', '${profile.requiredHours.toInt()}h', font, fontBold),
                pw.SizedBox(height: 4),
                _summaryRow('Remaining:', '${(profile.requiredHours - totalHours).clamp(0, profile.requiredHours).toStringAsFixed(2)}h', font, fontBold),
              ],
            ),
          ),

          pw.SizedBox(height: 40),

          // Signatures
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('__________________________', style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.grey)),
                  pw.SizedBox(height: 4),
                  pw.Text('Intern Signature', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('__________________________', style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.grey)),
                  pw.SizedBox(height: 4),
                  pw.Text('Supervisor Signature', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),
          pw.Text('Generated: ${_fmtDate(DateTime.now())} ${_fmt(DateTime.now())}', style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey)),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _infoRow(String label, String value, pw.Font font, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.Text(label, style: pw.TextStyle(font: fontBold, fontSize: 10)),
          pw.SizedBox(width: 4),
          pw.Text(value, style: pw.TextStyle(font: font, fontSize: 10)),
        ],
      ),
    );
  }

  pw.Widget _headerCell(String text, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.green700)),
    );
  }

  pw.Widget _cell(String text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 9)),
    );
  }

  pw.Widget _summaryRow(String label, String value, pw.Font font, pw.Font fontBold) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(font: fontBold, fontSize: 10)),
        pw.Text(value, style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.green700)),
      ],
    );
  }

  String _dayAbbr(int weekday) {
    const d = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return d[weekday - 1];
  }

  Future<void> sharePdf(ProfileModel profile, List<DtrLog> logs, double totalHours, int daysPresent) async {
    final pdf = await generatePdf(profile, logs, totalHours, daysPresent);
    await Printing.sharePdf(bytes: pdf, filename: 'DTR_Report_${DateTime.now().millisecondsSinceEpoch}');
  }

  // ── CSV Export ───────────────────────────────────────────────────────────

  String generateCsv(ProfileModel profile, List<DtrLog> logs) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('Date,Day,Time In,Time Out,Break (min),Work Hours,Activities,Location,Status');

    for (final log in logs) {
      final date = _fmtDate(log.timeIn);
      final day = _dayAbbr(log.timeIn.weekday);
      final timeIn = log.timeOut != null ? _fmt(log.timeIn) : '--:--';
      final timeOut = log.timeOut != null ? _fmt(log.timeOut!) : 'Active';
      final breakMin = log.breakMinutes;
      final hours = log.timeOut != null ? log.calculatedHours.toStringAsFixed(2) : '--';
      final activities = log.activities.map((a) => a.note ?? a.tag).join(';');
      final location = log.locationName ?? (log.lat != null ? '${log.lat!.toStringAsFixed(4)},${log.lng!.toStringAsFixed(4)}' : '');
      final status = log.timeOut != null ? 'Complete' : 'Active';

      buffer.writeln('"$date","$day","$timeIn","$timeOut","$breakMin","$hours","$activities","$location","$status"');
    }

    return buffer.toString();
  }

  Future<void> saveCsv(ProfileModel profile, List<DtrLog> logs) async {
    final csv = generateCsv(profile, logs);
    final bytes = utf8.encode(csv);
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save DTR as CSV',
      fileName: 'DTR_${DateTime.now().millisecondsSinceEpoch}.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
      bytes: bytes,
    );
    if (result != null) {
      if (!Platform.isAndroid && !Platform.isIOS) {
        await File(result).writeAsString(csv);
      }
    }
  }

  // ── Backup ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _collectAllData() async {
    final dbHelper = DBHelper.instance;
    final db = await dbHelper.database;

    final profiles = await db.query('profiles');
    final dtrLogs = await db.query('dtr_logs');
    final photos = await db.query('dtr_photos');
    final shifts = await db.query('shifts');
    final calendarEvents = await db.query('calendar_events');
    final competencies = await db.query('competencies');

    return {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'profiles': profiles,
      'dtr_logs': dtrLogs,
      'dtr_photos': photos,
      'shifts': shifts,
      'calendar_events': calendarEvents,
      'competencies': competencies,
    };
  }

  Future<String> exportBackup() async {
    final data = await _collectAllData();
    final json = jsonEncode(data);
    final bytes = utf8.encode(json);

    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Backup',
      fileName: 'OJT_Backup_${DateTime.now().millisecondsSinceEpoch}.ojtbackup',
      type: FileType.custom,
      allowedExtensions: ['ojtbackup'],
      bytes: bytes,
    );

    if (result != null) {
      if (!Platform.isAndroid && !Platform.isIOS) {
        await File(result).writeAsString(json);
      }
      return 'Backup saved successfully!';
    }
    return 'Backup cancelled';
  }

  Future<String> importBackup() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select Backup File',
      type: FileType.custom,
      allowedExtensions: ['ojtbackup'],
    );

    if (result == null || result.files.isEmpty) return 'Import cancelled';

    final file = File(result.files.single.path!);
    final jsonStr = await file.readAsString();

    Map<String, dynamic> data;
    try {
      data = jsonDecode(jsonStr);
    } catch (_) {
      return 'Invalid backup file';
    }

    final dbHelper = DBHelper.instance;
    final db = await dbHelper.database;

    await db.transaction((txn) async {
      // Clear existing data
      await txn.delete('dtr_logs');
      await txn.delete('dtr_photos');
      await txn.delete('shifts');
      await txn.delete('calendar_events');
      await txn.delete('competencies');

      // Import profiles (keep at least one)
      final importedProfiles = (data['profiles'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      for (final p in importedProfiles) {
        await txn.insert('profiles', p, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      if (importedProfiles.isEmpty) {
        await txn.insert('profiles', ProfileModel.empty().toMap());
      }

      // Import logs
      final importedLogs = (data['dtr_logs'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      for (final log in importedLogs) {
        await txn.insert('dtr_logs', log, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Import photos
      final importedPhotos = (data['dtr_photos'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      for (final photo in importedPhotos) {
        await txn.insert('dtr_photos', photo, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Import shifts
      final importedShifts = (data['shifts'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      for (final shift in importedShifts) {
        await txn.insert('shifts', shift, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Import calendar events
      final importedEvents = (data['calendar_events'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      for (final event in importedEvents) {
        await txn.insert('calendar_events', event, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Import competencies
      final importedCompetencies = (data['competencies'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      for (final competency in importedCompetencies) {
        await txn.insert('competencies', competency, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });

    return 'Backup restored successfully! Restart the app to see changes.';
  }

  // ── Share to Clipboard (existing text export) ────────────────────────────

  String generateTextReport(ProfileModel profile, List<DtrLog> logs, double totalHours, int daysPresent, double remainingHours, double completionPercent) {
    final buffer = StringBuffer();

    buffer.writeln('=== DTR REPORT ===');
    buffer.writeln('Name: ${profile.fullName}');
    buffer.writeln('Course: ${profile.course} • ${profile.batch}');
    buffer.writeln('Company: ${profile.company}');
    buffer.writeln('Supervisor: ${profile.supervisor}');
    buffer.writeln('Generated: ${_fmtDate(DateTime.now())} ${_fmt(DateTime.now())}');
    buffer.writeln('');
    buffer.writeln('--- ATTENDANCE LOG ---');
    for (final log in logs) {
      final timeIn = _fmt(log.timeIn);
      final timeOut = log.timeOut != null ? _fmt(log.timeOut!) : 'N/A';
      buffer.writeln('Date: ${_fmtDate(log.timeIn)} (${_dayAbbr(log.timeIn.weekday)})');
      buffer.writeln('  Time In:  $timeIn');
      buffer.writeln('  Time Out: $timeOut');
      buffer.writeln('  Hours:    ${log.calculatedHours.toStringAsFixed(2)}');
      if (log.breakMinutes > 0) {
        buffer.writeln('  Break:    ${log.breakMinutes} min');
      }
      if (log.activities.isNotEmpty) {
        buffer.writeln('  Tasks:    ${log.activities.map((a) => a.note ?? a.tag).join(', ')}');
      }
      buffer.writeln('');
    }
    buffer.writeln('--- SUMMARY ---');
    buffer.writeln('Days Present : $daysPresent');
    buffer.writeln('Total Hours  : ${totalHours.toStringAsFixed(2)}');
    buffer.writeln('Required     : ${profile.requiredHours.toInt()}');
    buffer.writeln('Remaining    : ${remainingHours.toStringAsFixed(2)}');
    buffer.writeln('Completion   : ${(completionPercent * 100).toStringAsFixed(1)}%');

    return buffer.toString();
  }
}
