import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/dtr_model.dart';
import '../theme/app_theme.dart';

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
          backgroundColor: kBg,
          body: SafeArea(
            child: RefreshIndicator(
              color: kGreen,
              backgroundColor: kSurface,
              onRefresh: () => state.load(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 20),

                        // Header
                        FadeSlideIn(
                          index: 0,
                          child: Row(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  gradient: kGreenGradient,
                                  borderRadius: kRadiusAvatar,
                                  boxShadow: kGreenGlow,
                                ),
                                child: const Icon(Icons.bar_chart_rounded, color: kWhite, size: 24),
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('DTR Records',
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kWhite)),
                                  Text('Your attendance history',
                                      style: TextStyle(fontSize: 12, color: kGrey)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Summary chips
                        FadeSlideIn(
                          index: 1,
                          child: Row(
                            children: [
                              _SummaryChip(label: 'Days Present', value: '$totalDays', icon: Icons.calendar_today_rounded, color: kGreen),
                              const SizedBox(width: 10),
                              _SummaryChip(label: 'Total Hours', value: totalHours.toStringAsFixed(1), icon: Icons.timer_rounded, color: kAmber),
                              const SizedBox(width: 10),
                              _SummaryChip(label: 'This Week', value: '${weekLogs.length}', icon: Icons.date_range_rounded, color: kGreenLight),
                            ],
                          ),
                        ),

                        const SizedBox(height: 26),

                        FadeSlideIn(
                          index: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('All Records',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kWhite)),
                              Text('${logs.length} entries',
                                  style: const TextStyle(fontSize: 12, color: kGrey)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (logs.isEmpty) FadeSlideIn(index: 3, child: const _EmptyState()),
                      ]),
                    ),
                  ),

                  // Records list
                  if (logs.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            if (i == logs.length) return const SizedBox(height: 24);
                            return FadeSlideIn(
                              index: i + 3,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _SwipeableRecord(
                                  log: logs[i],
                                  onDelete: () => _confirmDelete(context, state, logs[i].id),
                                ),
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
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(
          borderRadius: kRadiusCard,
          side: const BorderSide(color: kBorder),
        ),
        title: const Text('Delete Record',
            style: TextStyle(fontWeight: FontWeight.w800, color: kWhite)),
        content: const Text('This will permanently remove this DTR entry.',
            style: TextStyle(color: kGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: kGrey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              state.deleteLog(logId);
            },
            child: const Text('Delete', style: TextStyle(color: kRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: kGreen.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.event_note_rounded, size: 36, color: kGreen),
          ),
          const SizedBox(height: 16),
          const Text('No records yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kWhite)),
          const SizedBox(height: 6),
          const Text('Start by scanning your QR\nor using manual entry',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: kGrey)),
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

  bool get _isComplete => log.timeOut != null;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(log.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: kRed.withValues(alpha: 0.15),
          borderRadius: kRadiusCard,
          border: Border.all(color: kRed.withValues(alpha: 0.4)),
        ),
        child: const Icon(Icons.delete_rounded, color: kRed),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: DarkCard(
        child: Row(
          children: [
            // Date box
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: kGreen.withValues(alpha: 0.1),
                borderRadius: kRadiusAvatar,
                border: Border.all(color: kGreen.withValues(alpha: 0.25)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_dayLabel,
                      style: const TextStyle(fontSize: 10, color: kGrey, fontWeight: FontWeight.w600)),
                  Text('${log.timeIn.day}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: kWhite)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_fmt(log.timeIn)} → ${_fmt(log.timeOut)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kWhite)),
                  const SizedBox(height: 3),
                  Text(
                    log.timeOut != null
                        ? '${log.calculatedHours.toStringAsFixed(2)} hrs'
                        : 'Session in progress',
                    style: const TextStyle(fontSize: 11, color: kGrey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _isComplete
                        ? kGreen.withValues(alpha: 0.12)
                        : kAmber.withValues(alpha: 0.12),
                    borderRadius: kRadiusTag,
                    border: Border.all(
                      color: _isComplete
                          ? kGreen.withValues(alpha: 0.3)
                          : kAmber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _isComplete ? 'Complete' : 'Active',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _isComplete ? kGreen : kAmber,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${log.timeIn.month}/${log.timeIn.day}/${log.timeIn.year}',
                  style: const TextStyle(fontSize: 9, color: kGreyDark),
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
  final IconData icon;
  final Color color;
  const _SummaryChip({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: kRadiusCard,
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 9, color: kGrey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
