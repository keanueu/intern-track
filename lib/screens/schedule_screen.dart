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
    final startCtrl = TextEditingController(text: existing?['start_time'] ?? '08:00');
    final endCtrl = TextEditingController(text: existing?['end_time'] ?? '17:00');
    final breakCtrl = TextEditingController(text: ((existing?['break_minutes'] as int?) ?? 60).toString());
    final selectedDay = day ?? (existing != null ? existing['day_of_week'] as int : 1);

    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: kBorder),
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
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kWhite)),
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
            const Text('Start Time (HH:mm)', style: TextStyle(fontSize: 12, color: kGrey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: startCtrl,
              style: const TextStyle(color: kWhite),
              decoration: InputDecoration(
                hintText: '08:00',
                filled: true, fillColor: kSurface2,
                border: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: const BorderSide(color: kBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: const BorderSide(color: kGreen)),
              ),
            ),
            const SizedBox(height: 12),
            const Text('End Time (HH:mm)', style: TextStyle(fontSize: 12, color: kGrey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: endCtrl,
              style: const TextStyle(color: kWhite),
              decoration: InputDecoration(
                hintText: '17:00',
                filled: true, fillColor: kSurface2,
                border: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: const BorderSide(color: kBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: const BorderSide(color: kGreen)),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Break (minutes)', style: TextStyle(fontSize: 12, color: kGrey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: breakCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: kWhite),
              decoration: InputDecoration(
                hintText: '60',
                filled: true, fillColor: kSurface2,
                border: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: const BorderSide(color: kBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: const BorderSide(color: kGreen)),
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
                    'start_time': startCtrl.text.trim(),
                    'end_time': endCtrl.text.trim(),
                    'break_minutes': int.tryParse(breakCtrl.text) ?? 60,
                    'recurring': 1,
                  };
                  state.saveShift(shift);
                  Navigator.pop(ctx);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(gradient: kGreenGradient, borderRadius: kRadiusBtn),
                  child: const Center(
                    child: Text('Save', style: TextStyle(color: kBg, fontWeight: FontWeight.w700, fontSize: 15)),
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
        final shifts = state.shifts;
        final hasShiftToday = state.todayShift != null;
        final todayShift = state.todayShift;

        return Scaffold(
          backgroundColor: kBg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Schedule',
                          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: kWhite)),
                      TapScale(
                        onTap: () {
                          if (shifts.length >= 7) {
                            state.clearShifts();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: kSurface2,
                            borderRadius: kRadiusBtn,
                            border: Border.all(color: kBorder),
                          ),
                          child: Text(
                            shifts.isNotEmpty ? 'Reset' : 'Set All',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kGrey),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Set your weekly shift schedule',
                      style: TextStyle(fontSize: 14, color: kGrey)),
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
                          const Icon(AppIcons.today, color: kBg, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Today's Shift",
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kBg)),
                                const SizedBox(height: 4),
                                Text(
                                  '${todayShift!['start_time']} – ${todayShift['end_time']}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kBg),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: kBg.withValues(alpha: 0.2),
                              borderRadius: kRadiusTag,
                            ),
                            child: Text('${todayShift['break_minutes']}m break',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kBg)),
                          ),
                        ],
                      ),
                    ),
                  if (hasShiftToday) const SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: kSurface2,
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
                            if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16, color: kBorder),
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
                                                  color: isToday ? kGreen : (hasShift ? kWhite : kGrey))),
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
                                              '${shift['start_time']} – ${shift['end_time']}',
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kWhite),
                                            )
                                          : const Text('Day off',
                                              style: TextStyle(fontSize: 14, color: kGrey)),
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
                                    const Icon(AppIcons.chevronRight, color: kGreyDark, size: 18),
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
                              content: const Text('Shifts already set. Tap a day to edit.',
                                  style: TextStyle(color: kWhite)),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: kSurface,
                              shape: RoundedRectangleBorder(borderRadius: kRadiusBtn, side: const BorderSide(color: kBorder)),
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
                        child: const Center(
                          child: Text('Set Default Schedule (Mon-Fri 8-5)',
                              style: TextStyle(color: kBg, fontWeight: FontWeight.w700, fontSize: 14)),
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
