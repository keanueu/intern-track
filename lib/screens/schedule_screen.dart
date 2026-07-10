import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadShifts();
    });
  }

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  void _editShift(BuildContext context, AppState state, Map<String, dynamic>? existing, int? day) {
    final c = ThemeColors.of(context);
    final ts = Theme.of(context).textTheme;
    final selectedDay = day ?? (existing != null ? existing['day_of_week'] as int : 1);

    TimeOfDay startTime = existing != null ? _parseTime(existing['start_time']) : const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = existing != null ? _parseTime(existing['end_time']) : const TimeOfDay(hour: 17, minute: 0);
    int breakMinutes = (existing?['break_minutes'] as int?) ?? 60;

    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: kRadiusSheet),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDragHandle(c),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        existing != null
                            ? 'Edit Shift - ${_dayLabels[selectedDay - 1]}'
                            : 'Add Shift - ${_dayLabels[selectedDay - 1]}',
                        style: ts.titleLarge),
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

                Text('Start Time', style: ts.labelSmall),
                const SizedBox(height: 6),
                _buildTimePicker(ctx, c, ts, 'Start Time', startTime, (t) {
                  setSheetState(() => startTime = t);
                }),
                const SizedBox(height: 12),

                Text('End Time', style: ts.labelSmall),
                const SizedBox(height: 6),
                _buildTimePicker(ctx, c, ts, 'End Time', endTime, (t) {
                  setSheetState(() => endTime = t);
                }),
                const SizedBox(height: 12),

                Text('Break (minutes)', style: ts.labelSmall),
                const SizedBox(height: 6),
                TextField(
                  keyboardType: TextInputType.number,
                  style: ts.bodyLarge,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                  onChanged: (v) {
                    final n = int.tryParse(v) ?? 60;
                    breakMinutes = n.clamp(0, 120);
                  },
                  decoration: InputDecoration(
                    hintText: '60',
                    focusedBorder: OutlineInputBorder(
                        borderRadius: kRadiusInput,
                        borderSide: BorderSide(color: c.accent, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: TapScale(
                    onTap: () {
                      final shift = {
                        'id': existing?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        'user_id': state.profile.id,
                        'day_of_week': selectedDay,
                        'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                        'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                        'break_minutes': breakMinutes,
                        'recurring': 1,
                      };
                      state.saveShift(shift);
                      FocusScope.of(ctx).unfocus();
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Shift saved', style: ts.bodyMedium),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: c.surface,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: const BoxDecoration(gradient: kGreenGradient, borderRadius: kRadiusBtn),
                      child: Center(
                        child: Text('Save', style: ts.labelLarge?.copyWith(color: c.onAccent)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext ctx, ThemeColors c, TextTheme ts, String label, TimeOfDay initial, ValueChanged<TimeOfDay> onPicked) {
    return TapScale(
      onTap: () async {
        final picked = await showTimePicker(context: ctx, initialTime: initial);
        if (picked != null) onPicked(picked);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: kRadiusInput,
          border: Border.all(color: c.border),
        ),
        child: Text(
          '${initial.hourOfPeriod == 0 ? 12 : initial.hourOfPeriod}:${initial.minute.toString().padLeft(2, '0')} ${initial.period == DayPeriod.am ? 'AM' : 'PM'}',
          style: ts.bodyLarge,
        ),
      ),
    );
  }

  TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    if (parts.length != 2) return const TimeOfDay(hour: 8, minute: 0);
    return TimeOfDay(hour: int.tryParse(parts[0]) ?? 8, minute: int.tryParse(parts[1]) ?? 0);
  }

  String _to12h(String t) {
    final parts = t.split(':');
    if (parts.length != 2) return t;
    final h = int.tryParse(parts[0]) ?? 0;
    final dh = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$dh:${parts[1]} ${h >= 12 ? 'PM' : 'AM'}';
  }

  void _confirmReset(BuildContext context, AppState state) {
    final c = ThemeColors.of(context);
    final ts = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: c.surface,
        shape: const RoundedRectangleBorder(borderRadius: kRadiusCard),
        title: Text('Reset schedule?', style: ts.titleLarge),
        content: Text('This will remove all shifts.', style: ts.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: ts.labelLarge),
          ),
          TextButton(
            onPressed: () {
              state.clearShifts();
              Navigator.pop(context);
            },
            child: Text('Reset', style: ts.labelLarge?.copyWith(color: c.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final c = ThemeColors.of(context);
        final ts = Theme.of(context).textTheme;
        final shifts = state.shifts;
        final hasShiftToday = state.todayShift != null;
        final todayShift = state.todayShift;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: c.bg,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: TapScale(
              onTap: () => Navigator.pop(context),
              child: Icon(AppIcons.chevronLeft, color: c.textPrimary),
            ),
            title: Text('Schedule', style: ts.titleLarge),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TapScale(
                  onTap: () {
                    if (shifts.isNotEmpty) {
                      _confirmReset(context, state);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('No shifts to reset.', style: ts.bodyMedium),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: c.surface,
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: c.surface2,
                      borderRadius: kRadiusBtn,
                      border: Border.all(color: c.border),
                    ),
                    child: Text(
                      'Reset',
                      style: ts.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
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
                    child: Text('Set your weekly shift schedule', style: ts.bodyMedium),
                  ),
                  const SizedBox(height: 24),

                  if (hasShiftToday)
                    FadeSlideIn(
                      index: 1,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          gradient: kGreenGradient,
                          borderRadius: kRadiusCard,
                        ),
                        child: Row(
                          children: [
                            Icon(AppIcons.today, color: c.onAccent, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Today's Shift",
                                      style: ts.labelSmall?.copyWith(color: c.onAccent)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_to12h(todayShift!['start_time'])} – ${_to12h(todayShift['end_time'])}',
                                    style: ts.titleLarge?.copyWith(
                                        color: c.onAccent, fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: c.onAccent.withValues(alpha: 0.2),
                                borderRadius: kRadiusTag,
                              ),
                              child: Text('${todayShift['break_minutes']}m break',
                                  style: ts.labelSmall?.copyWith(
                                      color: c.onAccent, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (hasShiftToday) const SizedBox(height: 24),

                  FadeSlideIn(
                    index: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: c.surface2,
                        borderRadius: kRadiusCard,
                      ),
                      child: Column(
                        children: List.generate(7, (i) {
                          final day = i + 1;
                          final shift = shifts.cast<Map<String, dynamic>?>().firstWhere(
                            (s) => s?['day_of_week'] == day,
                            orElse: () => null,
                          );
                          final isToday = DateTime.now().weekday == day;
                          final hasShift = shift != null;

                          return Column(
                            children: [
                              if (i > 0) Divider(height: 1, indent: 16, endIndent: 16, color: c.border),
                              TapScale(
                                onTap: () => _editShift(context, state, shift, day),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        decoration: BoxDecoration(
                                          color: hasShift ? c.accentLight : Colors.transparent,
                                          borderRadius: kRadiusTag,
                                        ),
                                        child: Column(
                                          children: [
                                            Text(_dayLabels[i],
                                                style: ts.labelSmall?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: isToday ? c.accent : (hasShift ? c.textPrimary : c.textSecondary))),
                                            if (isToday)
                                              Container(
                                                margin: const EdgeInsets.only(top: 2),
                                                width: 6,
                                                height: 6,
                                                decoration: BoxDecoration(shape: BoxShape.circle, color: c.accent),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: hasShift
                                            ? Text(
                                                '${_to12h(shift['start_time'])} – ${_to12h(shift['end_time'])}',
                                                style: ts.bodyLarge,
                                              )
                                            : Text('Day off', style: ts.bodyMedium),
                                      ),
                                      if (hasShift)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: c.accentLight,
                                            borderRadius: kRadiusTag,
                                          ),
                                          child: Text('${shift['break_minutes']}m',
                                              style: ts.labelSmall?.copyWith(
                                                  color: c.accent, fontWeight: FontWeight.w600)),
                                        ),
                                      const SizedBox(width: 4),
                                      Icon(AppIcons.chevronRight, color: c.textMuted, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    index: 3,
                    child: SizedBox(
                      width: double.infinity,
                      child: TapScale(
                        onTap: () {
                          if (shifts.isEmpty) {
                            const defaults = [
                              (1, '08:00', '17:00'),
                              (2, '08:00', '17:00'),
                              (3, '08:00', '17:00'),
                              (4, '08:00', '17:00'),
                              (5, '08:00', '17:00'),
                            ];
                            for (final d in defaults) {
                              state.saveShift({
                                'id': DateTime.now().millisecondsSinceEpoch.toString() + d.$1.toString(),
                                'user_id': state.profile.id,
                                'day_of_week': d.$1,
                                'start_time': d.$2,
                                'end_time': d.$3,
                                'break_minutes': 60,
                                'recurring': 1,
                              });
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Shifts already set. Tap a day to edit.', style: ts.bodyMedium),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: c.surface,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: const BoxDecoration(gradient: kGreenGradient, borderRadius: kRadiusBtn),
                          child: Center(
                            child: Text('Set Default Schedule (Mon-Fri 8-5)',
                                style: ts.labelLarge?.copyWith(color: c.onAccent)),
                          ),
                        ),
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
}
