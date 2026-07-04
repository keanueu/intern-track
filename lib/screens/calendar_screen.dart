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

  void _toggleDate(BuildContext context, AppState state, DateTime date) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final existing = state.calendarEvents.cast<Map<String, dynamic>?>().firstWhere(
      (e) => e?['date'] == dateStr,
      orElse: () => null,
    );

    if (existing != null) {
      state.deleteCalendarEvent(existing['id']);
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: kSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          side: BorderSide(color: kBorder),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mark Date', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kWhite)),
                  TapScale(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: kSurface2, borderRadius: kRadiusTag),
                      child: const Icon(AppIcons.close, color: kGrey, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('${date.month}/${date.day}/${date.year}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kWhite)),
              const SizedBox(height: 16),
              _EventTypeButton(
                icon: Icons.celebration,
                label: 'Holiday',
                color: kGreen,
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
                color: kAmber,
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
                color: kRed,
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final now = DateTime.now();
        final daysInMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
        final firstWeekday = DateTime(_viewMonth.year, _viewMonth.month, 1).weekday;

        return Scaffold(
          backgroundColor: kBg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Calendar',
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: kWhite)),
                  const SizedBox(height: 8),
                  const Text('Mark holidays, leave, or sick days',
                      style: TextStyle(fontSize: 14, color: kGrey)),
                  const SizedBox(height: 24),

                  // Month header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TapScale(onTap: _prevMonth, child: const Icon(AppIcons.chevronLeft, color: kWhite, size: 24)),
                      Text(
                        '${_monthLabel(_viewMonth.month)} ${_viewMonth.year}',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kWhite),
                      ),
                      TapScale(onTap: _nextMonth, child: const Icon(AppIcons.chevronRight, color: kWhite, size: 24)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Day headers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                        .map((d) => SizedBox(
                          width: 36,
                          child: Text(d, textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11, color: kGrey, fontWeight: FontWeight.w600)),
                        ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),

                  // Calendar grid
                  ...List.generate(_buildWeeks(daysInMonth, firstWeekday).length, (weekIndex) {
                    final week = _buildWeeks(daysInMonth, firstWeekday)[weekIndex];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: week.map((day) {
                          if (day == 0) {
                            return const SizedBox(width: 36, height: 36);
                          }
                          final date = DateTime(_viewMonth.year, _viewMonth.month, day);
                          final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                          final isToday = now.year == date.year && now.month == date.month && now.day == day;
                          final event = state.calendarEvents.cast<Map<String, dynamic>?>().firstWhere(
                            (e) => e?['date'] == dateStr,
                            orElse: () => null,
                          );
                          final isExcluded = event != null;

                          return TapScale(
                            onTap: () => _toggleDate(context, state, date),
                            child: Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isExcluded
                                    ? _eventColor(event['type']).withValues(alpha: 0.2)
                                    : (isToday ? kGreen.withValues(alpha: 0.15) : Colors.transparent),
                                border: isToday ? Border.all(color: kGreen, width: 1.5) : null,
                              ),
                              child: Center(
                                child: Text(
                                  '$day',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isToday || isExcluded ? FontWeight.w700 : FontWeight.w500,
                                    color: isExcluded ? _eventColor(event['type']) : (isToday ? kGreen : kWhite),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Legend
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kSurface2,
                      borderRadius: kRadiusCard,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Legend',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kWhite)),
                        const SizedBox(height: 10),
                        _LegendRow(color: kGreen, label: 'Holiday'),
                        const SizedBox(height: 6),
                        _LegendRow(color: kAmber, label: 'Leave'),
                        const SizedBox(height: 6),
                        _LegendRow(color: kRed, label: 'Sick'),
                        const SizedBox(height: 6),
                        _LegendRow(color: kGreen, label: 'Today'),
                      ],
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

  Color _eventColor(String type) {
    switch (type) {
      case 'holiday': return kGreen;
      case 'leave': return kAmber;
      case 'sick': return kRed;
      default: return kGrey;
    }
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
  Widget build(BuildContext context) => TapScale(
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
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15)),
        ],
      ),
    ),
  );
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 12, color: kGrey)),
    ],
  );
}
