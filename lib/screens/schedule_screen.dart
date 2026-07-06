import 'package:flutter/material.dart';
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
    final startCtrl = TextEditingController(text: existing != null ? _to12h(existing['start_time']) : '8:00 AM');
    final endCtrl = TextEditingController(text: existing != null ? _to12h(existing['end_time']) : '5:00 PM');
    final breakCtrl = TextEditingController(text: ((existing?['break_minutes'] as int?) ?? 60).toString());
    final selectedDay = day ?? (existing != null ? existing['day_of_week'] as int : 1);

    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: c.border),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24, right: 24, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(existing != null ? 'Edit Shift - ${_dayLabels[selectedDay - 1]}' : 'Add Shift - ${_dayLabels[selectedDay - 1]}',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c.textPrimary)),
                TapScale(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: c.surface2, borderRadius: kRadiusTag),
                    child: Icon(AppIcons.close, color: c.textSecondary, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Start Time', style: TextStyle(fontSize: 12, color: c.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: startCtrl,
              style: TextStyle(color: c.textPrimary),
              decoration: InputDecoration(
                hintText: '8:00 AM',
                filled: true, fillColor: c.surface2,
                border: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: BorderSide(color: c.border)),
                focusedBorder: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: BorderSide(color: kGreen)),
              ),
            ),
            const SizedBox(height: 12),
            Text('End Time', style: TextStyle(fontSize: 12, color: c.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: endCtrl,
              style: TextStyle(color: c.textPrimary),
              decoration: InputDecoration(
                hintText: '5:00 PM',
                filled: true, fillColor: c.surface2,
                border: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: BorderSide(color: c.border)),
                focusedBorder: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: BorderSide(color: kGreen)),
              ),
            ),
            const SizedBox(height: 12),
            Text('Break (minutes)', style: TextStyle(fontSize: 12, color: c.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: breakCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: c.textPrimary),
              decoration: InputDecoration(
                hintText: '60',
                filled: true, fillColor: c.surface2,
                border: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: BorderSide(color: c.border)),
                focusedBorder: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: BorderSide(color: kGreen)),
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
                    'start_time': _to24(startCtrl.text.trim()),
                    'end_time': _to24(endCtrl.text.trim()),
                    'break_minutes': int.tryParse(breakCtrl.text) ?? 60,
                    'recurring': 1,
                  };
                  state.saveShift(shift);
                  Navigator.pop(ctx);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(gradient: kGreenGradient, borderRadius: kRadiusBtn),
                  child: Center(
                    child: Text('Save', style: TextStyle(color: c.onAccent, fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final c = ThemeColors.of(context);
        final shifts = state.shifts;
        final hasShiftToday = state.todayShift != null;
        final todayShift = state.todayShift;

        return Scaffold(
          backgroundColor: c.bg,
          appBar: AppBar(
            backgroundColor: c.bg,
            elevation: 0,
            leading: TapScale(
              onTap: () => Navigator.pop(context),
              child: Icon(AppIcons.chevronLeft, color: c.textPrimary),
            ),
            title: Text('Schedule',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.textPrimary)),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TapScale(
                  onTap: () {
                    if (shifts.length >= 7) {
                      state.clearShifts();
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
                      shifts.isNotEmpty ? 'Reset' : 'Set All',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.textSecondary),
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
                  Text('Set your weekly shift schedule',
                      style: TextStyle(fontSize: 14, color: c.textSecondary)),
                  const SizedBox(height: 24),

                  if (hasShiftToday)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: kGreenGradient,
                        borderRadius: kRadiusCard,
                        boxShadow: kGreenGlow,
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
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.onAccent)),
                                const SizedBox(height: 4),
                                Text(
                                  '${_to12h(todayShift!['start_time'])} – ${_to12h(todayShift['end_time'])}',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: c.onAccent),
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
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.onAccent)),
                          ),
                        ],
                      ),
                    ),
                  if (hasShiftToday) const SizedBox(height: 24),

                  Container(
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
                                        color: hasShift ? kGreen.withValues(alpha: 0.1) : Colors.transparent,
                                        borderRadius: kRadiusTag,
                                      ),
                                      child: Column(
                                        children: [
                                          Text(_dayLabels[i],
                                              style: TextStyle(
                                                  fontSize: 11, fontWeight: FontWeight.w700,
                                                  color: isToday ? kGreen : (hasShift ? c.textPrimary : c.textSecondary))),
                                          if (isToday)
                                            Container(
                                              margin: const EdgeInsets.only(top: 2),
                                              width: 4, height: 4,
                                              decoration: const BoxDecoration(shape: BoxShape.circle, color: kGreen),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: hasShift
                                          ? Text(
                                              '${_to12h(shift['start_time'])} – ${_to12h(shift['end_time'])}',
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary),
                                            )
                                          : Text('Day off',
                                              style: TextStyle(fontSize: 14, color: c.textSecondary)),
                                    ),
                                    if (hasShift)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: kGreen.withValues(alpha: 0.1),
                                          borderRadius: kRadiusTag,
                                        ),
                                        child: Text('${shift['break_minutes']}m',
                                            style: const TextStyle(fontSize: 11, color: kGreen, fontWeight: FontWeight.w600)),
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
                  const SizedBox(height: 16),
                  SizedBox(
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
                              content: Text('Shifts already set. Tap a day to edit.',
                                  style: TextStyle(color: c.textPrimary)),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: c.surface,
                              shape: RoundedRectangleBorder(borderRadius: kRadiusBtn, side: BorderSide(color: c.border)),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: kGreenGradient,
                          borderRadius: kRadiusBtn,
                          boxShadow: kGreenGlow,
                        ),
                        child: Center(
                          child: Text('Set Default Schedule (Mon-Fri 8-5)',
                              style: TextStyle(color: c.onAccent, fontWeight: FontWeight.w700, fontSize: 14)),
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

  String _to12h(String t) {
    final parts = t.split(':');
    if (parts.length != 2) return t;
    final h = int.tryParse(parts[0]) ?? 0;
    final dh = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$dh:${parts[1]} ${h >= 12 ? 'PM' : 'AM'}';
  }

  String _to24(String t) {
    final s = t.trim().toUpperCase();
    final isPM = s.contains('PM'), isAM = s.contains('AM');
    final n = s.replaceAll(RegExp(r'[^0-9:]'), '');
    final parts = n.split(':');
    if (parts.length != 2) return t;
    var h = int.tryParse(parts[0]) ?? 0;
    if (isPM && h != 12) h += 12;
    if (isAM && h == 12) h = 0;
    return '${h.toString().padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }
}
