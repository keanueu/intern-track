import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/dtr_model.dart';
import '../theme/app_theme.dart';
import 'export_screen.dart';

enum _Filter { all, week, month, active }

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  _Filter _filter = _Filter.all;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<DtrLog> _filtered(List<DtrLog> logs) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    List<DtrLog> result;
    switch (_filter) {
      case _Filter.week:
        result = logs.where((l) => l.timeIn.isAfter(startOfWeek)).toList();
      case _Filter.month:
        result = logs.where((l) => l.timeIn.isAfter(startOfMonth)).toList();
      case _Filter.active:
        result = logs.where((l) => l.timeOut == null).toList();
      case _Filter.all:
        result = List.from(logs);
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((l) {
        final dateStr = '${l.timeIn.month}/${l.timeIn.day}/${l.timeIn.year}';
        final dayName = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][l.timeIn.weekday - 1];
        return dateStr.contains(q) ||
            dayName.toLowerCase().contains(q) ||
            l.calculatedHours.toString().contains(q) ||
            (l.locationName?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return result;
  }

  Map<String, List<DtrLog>> _groupByMonth(List<DtrLog> logs) {
    const months = ['January','February','March','April','May','June',
                     'July','August','September','October','November','December'];
    final map = <String, List<DtrLog>>{};
    for (final log in logs) {
      final key = '${months[log.timeIn.month - 1]} ${log.timeIn.year}';
      map.putIfAbsent(key, () => []).add(log);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final c = ThemeColors.of(context);
        final ts = Theme.of(context).textTheme;
        final logs = state.logs;
        final filtered = _filtered(logs);
        final grouped = _groupByMonth(filtered);
        final totalDays = state.daysPresent;
        final totalHours = state.totalHours;
        final weekLogs = state.weekLogs;

        if (state.loading) {
          return Scaffold(
            backgroundColor: c.bg,
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 36, height: 36,
                        child: CircularProgressIndicator(strokeWidth: 3, color: kGreen)),
                    const SizedBox(height: 16),
                    Text('Loading records...', style: ts.bodyMedium),
                  ],
                ),
              ),
            ),
          );
        }

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

                        // Header
                        FadeSlideIn(
                          index: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Records', style: ts.displaySmall),
                                    const SizedBox(height: 4),
                                    Text('Your attendance history',
                                        style: ts.bodyMedium),
                                  ],
                                ),
                              ),
                              TapScale(
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const ExportScreen())),
                                child: Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    color: c.surface,
                                    borderRadius: kRadiusAvatar,
                                    border: Border.all(color: c.border),
                                  ),
                                  child: Icon(AppIcons.download, color: c.textPrimary, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

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

                        const SizedBox(height: 20),

                        // Search bar
                        FadeSlideIn(
                          index: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: c.surface2,
                              borderRadius: kRadiusBtn,
                              border: Border.all(color: c.border),
                            ),
                            child: Row(
                              children: [
                                Icon(AppIcons.calendar, color: c.textSecondary, size: 16),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _searchCtrl,
                                    style: TextStyle(color: c.textPrimary, fontSize: 14),
                                    decoration: InputDecoration(
                                      hintText: 'Search by date, day, or hours...',
                                      hintStyle: TextStyle(color: c.textMuted, fontSize: 13),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    onChanged: (v) => setState(() => _searchQuery = v),
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty)
                                  TapScale(
                                    onTap: () {
                                      _searchCtrl.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                    child: Icon(AppIcons.close, color: c.textSecondary, size: 16),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Filter chips
                        FadeSlideIn(
                          index: 3,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'All',
                                selected: _filter == _Filter.all,
                                onTap: () => setState(() => _filter = _Filter.all),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'This Week',
                                selected: _filter == _Filter.week,
                                onTap: () => setState(() => _filter = _Filter.week),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'This Month',
                                selected: _filter == _Filter.month,
                                onTap: () => setState(() => _filter = _Filter.month),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Active',
                                selected: _filter == _Filter.active,
                                onTap: () => setState(() => _filter = _Filter.active),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        if (logs.isEmpty) FadeSlideIn(index: 4, child: const _EmptyState()),
                        if (logs.isNotEmpty && filtered.isEmpty)
                          FadeSlideIn(
                            index: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Column(
                                children: [
                                  Icon(AppIcons.calendar, color: c.textMuted, size: 32),
                                  const SizedBox(height: 12),
                                  Text('No matching records',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textSecondary)),
                                  const SizedBox(height: 4),
                                  Text('Try a different filter or search term',
                                      style: TextStyle(fontSize: 12, color: c.textMuted)),
                                ],
                              ),
                            ),
                          ),
                      ]),
                    ),
                  ),

                  // Grouped records by month
                  if (filtered.isNotEmpty)
                    ...grouped.entries.toList().asMap().entries.map((entry) {
                      final monthIndex = entry.key;
                      final monthLabel = entry.value.key;
                      final monthLogs = entry.value.value;

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              if (i == 0) {
                                // Month header
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                                  child: FadeSlideIn(
                                    index: (monthIndex * 10 + 5).clamp(0, 15),
                                    child: Text(monthLabel,
                                        style: ts.titleSmall?.copyWith(color: c.textSecondary)),
                                  ),
                                );
                              }
                              final logIndex = i - 1;
                              final isFirst = logIndex == 0;
                              final isLast = logIndex == monthLogs.length - 1;

                              return FadeSlideIn(
                                index: (monthIndex * 10 + logIndex + 6).clamp(0, 15),
                                child: _SwipeableRecord(
                                  log: monthLogs[logIndex],
                                  isFirst: isFirst,
                                  isLast: isLast,
                                  onDelete: () => _confirmDelete(context, state, monthLogs[logIndex].id),
                                  onTap: () => _showRecordDetail(context, monthLogs[logIndex]),
                                ),
                              );
                            },
                            childCount: monthLogs.length + 1,
                          ),
                        ),
                      );
                    }),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
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
    final ts = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: kRadiusCard,
          side: BorderSide(color: c.border),
        ),
        title: Text('Delete Record', style: ts.titleMedium),
        content: Text('This will permanently remove this DTR entry.',
            style: ts.bodyMedium),
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

  void _showRecordDetail(BuildContext context, DtrLog log) {
    final c = ThemeColors.of(context);
    final ts = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: c.border),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(24),
          children: [
            // Handle
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: c.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Record Details', style: ts.titleMedium),
                TapScale(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: c.surface2, borderRadius: kRadiusTag),
                    child: Icon(AppIcons.close, color: c.textSecondary, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Time range
            _DetailRow(
              icon: AppIcons.login,
              label: 'Time In',
              value: fmtTime12(log.timeIn),
              color: kGreen,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: AppIcons.logout,
              label: 'Time Out',
              value: log.timeOut != null ? fmtTime12(log.timeOut!) : 'Active',
              color: log.timeOut != null ? kAmber : kGreen,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: AppIcons.timer,
              label: 'Duration',
              value: log.timeOut != null ? '${log.calculatedHours.toStringAsFixed(2)} hours' : 'In progress',
              color: kGreenLight,
            ),

            if (log.breakMinutes > 0) ...[
              const SizedBox(height: 20),
              Divider(height: 1, color: c.border),
              const SizedBox(height: 16),
              Text('Breaks', style: ts.labelLarge),
              const SizedBox(height: 8),
              ...log.breakEntries.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: kAmber.withValues(alpha: 0.12),
                        borderRadius: kRadiusTag,
                      ),
                      child: Icon(AppIcons.breakfast, color: kAmber, size: 14),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${b.type.toUpperCase()} BREAK',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.textSecondary)),
                          Text(
                            '${fmtTime12(b.start)} → ${b.end != null ? fmtTime12(b.end) : 'Ongoing'}',
                            style: TextStyle(fontSize: 13, color: c.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    Text('${b.durationMinutes}m',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kAmber)),
                  ],
                ),
              )),
            ],

            if (log.activities.isNotEmpty) ...[
              const SizedBox(height: 16),
              Divider(height: 1, color: c.border),
              const SizedBox(height: 16),
              Text('Activities', style: ts.labelLarge),
              const SizedBox(height: 8),
              ...log.activities.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: kGreenLight.withValues(alpha: 0.12),
                        borderRadius: kRadiusTag,
                      ),
                      child: Icon(AppIcons.hub, color: kGreenLight, size: 14),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.tag.toUpperCase(),
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.textSecondary)),
                          if (a.note != null && a.note!.isNotEmpty)
                            Text(a.note!, style: TextStyle(fontSize: 13, color: c.textPrimary)),
                        ],
                      ),
                    ),
                    if (a.durationMinutes > 0)
                      Text('${a.durationMinutes}m',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kGreenLight)),
                  ],
                ),
              )),
            ],

            if (log.lat != null) ...[
              const SizedBox(height: 16),
              Divider(height: 1, color: c.border),
              const SizedBox(height: 16),
              _DetailRow(
                icon: AppIcons.cellular,
                label: 'Location',
                value: '${log.lat!.toStringAsFixed(4)}, ${log.lng?.toStringAsFixed(4) ?? '--'}',
                color: kGreen,
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _DetailRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: kRadiusTag,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: c.textSecondary, fontWeight: FontWeight.w600)),
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.textPrimary)),
            ],
          ),
        ),
      ],
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
  final VoidCallback? onTap;

  const _SwipeableRecord({
    required this.log,
    required this.isFirst,
    required this.isLast,
    required this.onDelete,
    this.onTap,
  });

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
      child: TapScale(
        onTap: onTap,
        scale: 0.98,
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
                          Text('${fmtTime12(log.timeIn)} → ${fmtTime12(log.timeOut)}',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.textPrimary)),
                          const SizedBox(height: 4),
                          if (log.timeOut != null)
                            Text(
                              '${log.calculatedHours.toStringAsFixed(2)} hrs • $_dayLabel, ${log.timeIn.month}/${log.timeIn.day}',
                              style: TextStyle(fontSize: 13, color: c.textSecondary),
                            )
                          else
                            Row(
                              children: [
                                Container(
                                  width: 6, height: 6,
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: kGreen),
                                ),
                                const SizedBox(width: 6),
                                Text('Session in progress',
                                    style: TextStyle(fontSize: 13, color: kGreen, fontWeight: FontWeight.w600)),
                              ],
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
                    // Trailing
                    if (_isComplete)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: kGreen.withValues(alpha: 0.12),
                          borderRadius: kRadiusTag,
                          border: Border.all(color: kGreen.withValues(alpha: 0.3)),
                        ),
                        child: const Text('Complete',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kGreen)),
                      )
                    else
                      Icon(AppIcons.chevronRight, color: c.textMuted, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? kGreenGradient : null,
          color: selected ? null : c.surface2,
          borderRadius: kRadiusBtn,
          border: Border.all(color: selected ? kGreen : c.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? c.onAccent : c.textSecondary,
          ),
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
    final ts = Theme.of(context).textTheme;
    return Flexible(
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
            Text(value, style: ts.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 11, color: c.textSecondary, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
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
