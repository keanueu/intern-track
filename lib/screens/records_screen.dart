import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/dtr_model.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final logs = state.logs;
        final weekLogs = state.weekLogs;
        final totalDays = state.daysPresent;
        final totalHours = state.totalHours;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F4F0),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => state.load(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 18),

                        // Header
                        Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(color: const Color(0xFFB5EAD7), borderRadius: BorderRadius.circular(14)),
                              child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF2DBF8A), size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('DTR Records', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1E))),
                                Text('Your attendance history', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // Summary chips
                        Row(
                          children: [
                            _SummaryChip(label: 'Days Present', value: '$totalDays', color: const Color(0xFFD4CFFF)),
                            const SizedBox(width: 10),
                            _SummaryChip(label: 'Total Hours', value: totalHours.toStringAsFixed(1), color: const Color(0xFFFFD6A5)),
                            const SizedBox(width: 10),
                            _SummaryChip(label: 'This Week', value: '${weekLogs.length}', color: const Color(0xFFB5EAD7)),
                          ],
                        ),

                        const SizedBox(height: 26),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('All Records',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF9E9E9E))),
                            Text('${logs.length} entries',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (logs.isEmpty)
                          _EmptyState(),
                      ]),
                    ),
                  ),

                  // Records list with swipe-to-delete
                  if (logs.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            if (i == logs.length) return const SizedBox(height: 24);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _SwipeableRecord(
                                log: logs[i],
                                onDelete: () => _confirmDelete(context, state, logs[i].id),
                              ),
                            );
                          },
                          childCount: logs.length + 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, AppState state, String logId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Record', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('This will permanently remove this DTR entry.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF9E9E9E))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              state.deleteLog(logId);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFE05252), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFFD4CFFF), shape: BoxShape.circle),
            child: const Icon(Icons.event_note_rounded, size: 36, color: Color(0xFF6C63FF)),
          ),
          const SizedBox(height: 16),
          const Text('No records yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E))),
          const SizedBox(height: 6),
          const Text('Start by scanning your QR\nor using manual entry',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
        ],
      ),
    );
  }
}

class _SwipeableRecord extends StatelessWidget {
  final DtrLog log;
  final VoidCallback onDelete;
  const _SwipeableRecord({required this.log, required this.onDelete});

  String _fmt(DateTime? dt) {
    if (dt == null) return '--:--';
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  String get _dayLabel {
    const d = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return d[log.timeIn.weekday - 1];
  }

  String get _status => log.timeOut != null ? 'Complete' : 'Active';

  Color get _statusBg => log.timeOut != null ? const Color(0xFFB5EAD7) : const Color(0xFFFFD6A5);
  Color get _statusText => log.timeOut != null ? const Color(0xFF2DBF8A) : const Color(0xFFFF9F1C);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(log.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: const Color(0xFFFFB3B3), borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.delete_rounded, color: Color(0xFFE05252)),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: const Color(0xFFF5F4F0), borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_dayLabel, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E), fontWeight: FontWeight.w600)),
                  Text('${log.timeIn.day}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF1C1C1E))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_fmt(log.timeIn)} → ${_fmt(log.timeOut)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E))),
                  const SizedBox(height: 3),
                  Text(
                    log.timeOut != null
                        ? '${log.calculatedHours.toStringAsFixed(2)} hrs'
                        : 'Session in progress',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: _statusBg, borderRadius: BorderRadius.circular(20)),
                  child: Text(_status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _statusText)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${log.timeIn.month}/${log.timeIn.day}/${log.timeIn.year}',
                  style: const TextStyle(fontSize: 9, color: Color(0xFFB0AFAF)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1C1C1E))),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF555555), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
