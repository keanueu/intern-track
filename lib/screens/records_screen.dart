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
        final c = ThemeColors.of(context);
        final logs = state.logs;
        final weekLogs = state.weekLogs;
        final totalDays = state.daysPresent;
        final totalHours = state.totalHours;

        return Scaffold(
          backgroundColor: c.bg,
          body: SafeArea(
            child: RefreshIndicator(
              color: kGreen,
              backgroundColor: c.surface,
              onRefresh: () => state.load(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 20),

                        // Header (Large Title)
                        FadeSlideIn(
                          index: 0,
                          child: Text('Records',
                              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: c.textPrimary)),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        FadeSlideIn(
                          index: 0,
                          child: Text('Your attendance history',
                              style: TextStyle(fontSize: 14, color: c.textSecondary)),
                        ),

                        const SizedBox(height: 24),

                        // Summary chips
                        FadeSlideIn(
                          index: 1,
                          child: Row(
                            children: [
                              _SummaryChip(label: 'Days Present', value: '$totalDays', icon: AppIcons.calendar, color: kGreen),
                              const SizedBox(width: 10),
                              _SummaryChip(label: 'Total Hours', value: totalHours.toStringAsFixed(1), icon: AppIcons.timer, color: kAmber),
                              const SizedBox(width: 10),
                              _SummaryChip(label: 'This Week', value: '${weekLogs.length}', icon: AppIcons.dateRange, color: kGreenLight),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        if (logs.isEmpty) FadeSlideIn(index: 2, child: const _EmptyState()),
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
                            if (i == logs.length) return const SizedBox(height: 32);
                            
                            final isFirst = i == 0;
                            final isLast = i == logs.length - 1;
                            
                            return FadeSlideIn(
                              index: i + 3,
                              child: _SwipeableRecord(
                                log: logs[i],
                                isFirst: isFirst,
                                isLast: isLast,
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
    final c = ThemeColors.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: kRadiusCard,
          side: BorderSide(color: c.border),
        ),
        title: Text('Delete Record',
            style: TextStyle(fontWeight: FontWeight.w800, color: c.textPrimary)),
        content: Text('This will permanently remove this DTR entry.',
            style: TextStyle(color: c.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: c.textSecondary)),
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
    final c = ThemeColors.of(context);
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
            child: const Icon(AppIcons.eventNote, size: 36, color: kGreen),
          ),
          const SizedBox(height: 16),
          Text('No records yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.textPrimary)),
          const SizedBox(height: 6),
          Text('Start by scanning your QR\nor using manual entry',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: c.textSecondary)),
        ],
      ),
    );
  }
}

class _SwipeableRecord extends StatelessWidget {
  final DtrLog log;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onDelete;
  
  const _SwipeableRecord({
    required this.log, 
    required this.isFirst,
    required this.isLast,
    required this.onDelete
  });

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
    final c = ThemeColors.of(context);
    final borderRadius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(16) : Radius.zero,
      bottom: isLast ? const Radius.circular(16) : Radius.zero,
    );

    return Dismissible(
      key: Key(log.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: kRed.withValues(alpha: 0.9),
          borderRadius: borderRadius,
        ),
        child: Icon(AppIcons.delete, color: c.textPrimary),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Container(
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: borderRadius,
        ),
        child: Column(
          children: [
            if (!isFirst) Divider(height: 1, indent: 76, endIndent: 0, color: c.border),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            style: TextStyle(fontSize: 10, color: c.textSecondary, fontWeight: FontWeight.w600)),
                        Text('${log.timeIn.day}',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: c.textPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_fmt(log.timeIn)} → ${_fmt(log.timeOut)}',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.textPrimary)),
                        const SizedBox(height: 4),
                        Text(
                          log.timeOut != null
                              ? '${log.calculatedHours.toStringAsFixed(2)} hrs • $_dayLabel, ${log.timeIn.month}/${log.timeIn.day}'
                              : 'Session in progress',
                          style: TextStyle(fontSize: 13, color: c.textSecondary),
                        ),
                        if (log.timeOut != null && (log.breakMinutes > 0 || log.activities.isNotEmpty || log.lat != null))
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                if (log.breakMinutes > 0)
                                  _MetaChip(
                                    icon: AppIcons.timer,
                                    label: '${log.breakMinutes}m break',
                                    color: kAmber,
                                  ),
                                if (log.activities.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(left: log.breakMinutes > 0 ? 6 : 0),
                                    child: _MetaChip(
                                      icon: AppIcons.hub,
                                      label: '${log.activities.length} activities',
                                      color: kGreenLight,
                                    ),
                                  ),
                                if (log.lat != null)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: (log.breakMinutes > 0 || log.activities.isNotEmpty) ? 6 : 0,
                                    ),
                                    child: _MetaChip(
                                      icon: AppIcons.cellular,
                                      label: 'Location',
                                      color: kGreen,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Trailing status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _isComplete ? kGreen : kAmber,
                      ),
                    ),
                  ),
                ],
              ),
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
    final c = ThemeColors.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: kRadiusCard,
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 11, color: c.textSecondary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MetaChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
        ],
      );
}
