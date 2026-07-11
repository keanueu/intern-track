import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _viewMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadCalendarEvents();
    });
  }

  void _prevMonth() => setState(() => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1));
  void _nextMonth() => setState(() => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1));

  String _formatDateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  void _toggleDate(BuildContext context, AppState state, DateTime date) {
    final c = ThemeColors.of(context);
    final ts = Theme.of(context).textTheme;
    final dateStr = _formatDateKey(date);
    final existing = state.calendarEvents.cast<Map<String, dynamic>?>().firstWhere(
      (e) => e?['date'] == dateStr,
      orElse: () => null,
    );

    if (existing != null) {
      _confirmDelete(context, state, existing, c, ts);
    } else {
      _showAddSheet(context, state, date, dateStr, c, ts);
    }
  }

  void _confirmDelete(BuildContext context, AppState state, Map<String, dynamic> event, ThemeColors c, TextTheme ts) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: c.surface,
        shape: const RoundedRectangleBorder(borderRadius: kRadiusCard),
        title: Row(
          children: [
            Icon(AppIcons.warning, color: c.error, size: 24),
            const SizedBox(width: 8),
            Text('Remove event?', style: ts.titleLarge),
          ],
        ),
        content: Text('This will remove the ${event['type']} entry.', style: ts.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: ts.labelLarge),
          ),
          TextButton(
            onPressed: () {
              try {
                state.deleteCalendarEvent(event['id']);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete event', style: ts.bodyMedium),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: c.surface,
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: Text('Remove', style: ts.labelLarge?.copyWith(color: c.error)),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context, AppState state, DateTime date, String dateStr, ThemeColors c, TextTheme ts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(borderRadius: kRadiusSheet),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDragHandle(c),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mark Date', style: ts.titleLarge),
                HitArea(
                  size: 44,
                  child: TapScale(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: c.surface2, borderRadius: kRadiusTag),
                      child: Icon(AppIcons.close, color: c.textSecondary, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('${date.month}/${date.day}/${date.year}', style: ts.titleSmall),
            const SizedBox(height: 16),
            _EventTypeButton(
              icon: Icons.celebration,
              label: 'Holiday',
              color: c.accent,
              onTap: () {
                state.saveCalendarEvent({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'user_id': state.profile.id,
                  'date': dateStr,
                  'type': 'holiday',
                  'note': '',
                  'all_day': 1,
                });
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 8),
            _EventTypeButton(
              icon: Icons.flight_takeoff,
              label: 'Leave',
              color: c.warning,
              onTap: () {
                state.saveCalendarEvent({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'user_id': state.profile.id,
                  'date': dateStr,
                  'type': 'leave',
                  'note': '',
                  'all_day': 1,
                });
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 8),
            _EventTypeButton(
              icon: Icons.sick,
              label: 'Sick',
              color: c.error,
              onTap: () {
                state.saveCalendarEvent({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'user_id': state.profile.id,
                  'date': dateStr,
                  'type': 'sick',
                  'note': '',
                  'all_day': 1,
                });
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _eventColor(String type, ThemeColors c) {
    switch (type) {
      case 'holiday': return c.accent;
      case 'leave': return c.warning;
      case 'sick': return c.error;
      default: return c.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final c = ThemeColors.of(context);
        final ts = Theme.of(context).textTheme;
        final now = DateTime.now();
        final daysInMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
        final firstWeekday = DateTime(_viewMonth.year, _viewMonth.month, 1).weekday;
        final weeks = _buildWeeks(daysInMonth, firstWeekday);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: c.bg,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: TapScale(
              onTap: () => Navigator.pop(context),
              child: Icon(AppIcons.chevronLeft, color: c.textPrimary),
            ),
            title: Text('Calendar', style: ts.titleLarge),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  FadeSlideIn(
                    index: 0,
                    child: Text('Mark holidays, leave, or sick days', style: ts.bodyMedium),
                  ),
                  const SizedBox(height: 24),

                  FadeSlideIn(
                    index: 1,
                    child: Row(
                      children: [
                        TapScale(
                          onTap: _prevMonth,
                          child: HitArea(child: Icon(AppIcons.chevronLeft, color: c.textPrimary, size: 24)),
                        ),
                        Expanded(
                          child: Text(
                            '${_monthLabel(_viewMonth.month)} ${_viewMonth.year}',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ts.titleLarge,
                          ),
                        ),
                        TapScale(
                          onTap: _nextMonth,
                          child: HitArea(child: Icon(AppIcons.chevronRight, color: c.textPrimary, size: 24)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  FadeSlideIn(
                    index: 2,
                    child: Row(
                      children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                          .map((d) => Expanded(
                            child: Text(d, textAlign: TextAlign.center, style: ts.labelSmall),
                          ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  FadeSlideIn(
                    index: 3,
                    child: Column(
                      children: weeks.map((week) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: week.map((day) {
                              if (day == 0) return const Expanded(child: SizedBox(height: 48));
                              final date = DateTime(_viewMonth.year, _viewMonth.month, day);
                              final dateStr = _formatDateKey(date);
                              final isToday = now.year == date.year && now.month == date.month && now.day == day;
                              final event = state.calendarEvents.cast<Map<String, dynamic>?>().firstWhere(
                                (e) => e?['date'] == dateStr,
                                orElse: () => null,
                              );
                              final hasEvent = event != null;

                              return Expanded(
                                child: TapScale(
                                  onTap: () => _toggleDate(context, state, date),
                                  child: HitArea(
                                    size: 48,
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: hasEvent
                                            ? _eventColor(event['type'], c).withValues(alpha: 0.2)
                                            : (isToday ? c.accentLight : Colors.transparent),
                                        border: isToday ? Border.all(color: c.accent, width: 1.5) : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$day',
                                          style: ts.bodyMedium?.copyWith(
                                            fontWeight: isToday || hasEvent ? FontWeight.w700 : FontWeight.w500,
                                            color: hasEvent ? _eventColor(event['type'], c) : (isToday ? c.accent : c.textPrimary),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  FadeSlideIn(
                    index: 4,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: c.surface2,
                        borderRadius: kRadiusCard,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Legend', style: ts.titleSmall),
                          const SizedBox(height: 10),
                          _LegendRow(color: c.accent, label: 'Holiday'),
                          const SizedBox(height: 6),
                          _LegendRow(color: c.warning, label: 'Leave'),
                          const SizedBox(height: 6),
                          _LegendRow(color: c.error, label: 'Sick'),
                          const SizedBox(height: 6),
                          _LegendRow(color: c.accent, label: 'Today', outlined: true),
                        ],
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

  String _monthLabel(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m - 1];
  }

  List<List<int>> _buildWeeks(int daysInMonth, int firstWeekday) {
    final weeks = <List<int>>[];
    var week = List.filled(7, 0);
    var day = 1;
    for (var i = firstWeekday - 1; i < 7 && day <= daysInMonth; i++) {
      week[i] = day++;
    }
    weeks.add(week);
    while (day <= daysInMonth) {
      week = List.filled(7, 0);
      for (var i = 0; i < 7 && day <= daysInMonth; i++) {
        week[i] = day++;
      }
      weeks.add(week);
    }
    return weeks;
  }
}

class _EventTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _EventTypeButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;
    return TapScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: kRadiusBtn,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(label, style: ts.labelLarge?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final bool outlined;

  const _LegendRow({required this.color, required this.label, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;
    return Row(
      children: [
        outlined
            ? Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
              )
            : Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 8),
        Text(label, style: ts.bodySmall),
      ],
    );
  }
}
