import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class ManualPunchScreen extends StatefulWidget {
  const ManualPunchScreen({super.key});

  @override
  State<ManualPunchScreen> createState() => _ManualPunchScreenState();
}

class _ManualPunchScreenState extends State<ManualPunchScreen> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(
        const Duration(seconds: 1), (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _punch(BuildContext context) async {
    final state = context.read<AppState>();
    final msg = await state.punch();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: kGreen),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: const TextStyle(color: kWhite))),
        ]),
        behavior: SnackBarBehavior.floating,
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(
            borderRadius: kRadiusBtn, side: const BorderSide(color: kBorder)),
      ));
    }
  }

  String get _hms =>
      '${_p(_now.hour)}:${_p(_now.minute)}:${_p(_now.second)}';

  String get _dateLabel {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const d = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    return '${d[_now.weekday - 1]}, ${m[_now.month - 1]} ${_now.day}';
  }

  String _p(int n) => n.toString().padLeft(2, '0');

  String _fmt(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final isPunchedIn = state.isPunchedIn;
        final openLog = state.openLog;

        return Scaffold(
          backgroundColor: kBg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // 1. Header
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
                          child: const Icon(Icons.edit_note_rounded, color: kWhite, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Manual Entry',
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w800, color: kWhite)),
                            Text('Traditional DTR Log',
                                style: TextStyle(fontSize: 12, color: kGrey)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Offline notice — context BEFORE user acts
                  FadeSlideIn(
                    index: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: kGreen.withValues(alpha: 0.07),
                        borderRadius: kRadiusBtn,
                        border: Border.all(color: kGreen.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 14, color: kGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Entries are saved offline and sync automatically.',
                              style: const TextStyle(fontSize: 11, color: kGrey, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. Live clock — the centrepiece of this screen
                  FadeSlideIn(
                    index: 2,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: kRadiusCard,
                        border: Border.all(color: kBorder),
                        boxShadow: kCardShadow,
                      ),
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                kGreenGradient.createShader(bounds),
                            child: Text(
                              _hms,
                              style: const TextStyle(
                                color: kWhite,
                                fontSize: 48,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 3,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(_dateLabel,
                              style: const TextStyle(
                                  color: kGrey, fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 14),
                          // Session status pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isPunchedIn
                                  ? kGreen.withValues(alpha: 0.15)
                                  : kGreyDark.withValues(alpha: 0.4),
                              borderRadius: kRadiusNav,
                              border: Border.all(
                                color: isPunchedIn
                                    ? kGreen.withValues(alpha: 0.4)
                                    : kBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7, height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isPunchedIn ? kGreen : kGrey,
                                    boxShadow: isPunchedIn ? kGreenGlow : null,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isPunchedIn && openLog != null
                                      ? 'Active since ${_fmt(openLog.timeIn)}'
                                      : 'Not punched in',
                                  style: TextStyle(
                                    color: isPunchedIn ? kGreen : kGrey,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. Today's summary — shows WHAT was logged BEFORE showing action buttons
                  //    Only visible when there are logs — acts as a status line
                  if (state.logs.isNotEmpty) ...[
                    FadeSlideIn(index: 3, child: _TodaySummary(state: state)),
                    const SizedBox(height: 20),
                  ],

                  // 5. Punch actions — the primary interactive zone
                  FadeSlideIn(
                    index: 4,
                    child: const Text('Punch Attendance',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700, color: kWhite)),
                  ),
                  const SizedBox(height: 10),

                  FadeSlideIn(
                    index: 5,
                    child: _PunchCard(
                      icon: Icons.login_rounded,
                      label: 'Time In',
                      sublabel: isPunchedIn
                          ? 'Already logged in'
                          : 'Record your arrival time',
                      accentColor: kGreen,
                      enabled: !isPunchedIn,
                      onTap: () => _punch(context),
                    ),
                  ),
                  const SizedBox(height: 10),

                  FadeSlideIn(
                    index: 6,
                    child: _PunchCard(
                      icon: Icons.logout_rounded,
                      label: 'Time Out',
                      sublabel: !isPunchedIn
                          ? 'No active session'
                          : 'Record your departure time',
                      accentColor: kAmber,
                      enabled: isPunchedIn,
                      onTap: () => _punch(context),
                    ),
                  ),
                  const SizedBox(height: 10),

                  FadeSlideIn(
                    index: 7,
                    child: _PunchCard(
                      icon: Icons.free_breakfast_rounded,
                      label: 'Break',
                      sublabel: !isPunchedIn
                          ? 'Must be timed in first'
                          : 'Log lunch or rest break',
                      accentColor: kGreenLight,
                      enabled: isPunchedIn,
                      onTap: () => _punch(context),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TodaySummary extends StatelessWidget {
  final AppState state;
  const _TodaySummary({required this.state});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayLogs = state.logs
        .where((l) =>
            l.timeIn.year == today.year &&
            l.timeIn.month == today.month &&
            l.timeIn.day == today.day)
        .toList();

    if (todayLogs.isEmpty) return const SizedBox.shrink();

    final double todayHours =
        todayLogs.fold(0, (sum, l) => sum + l.calculatedHours);

    return DarkCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kGreen.withValues(alpha: 0.12),
              borderRadius: kRadiusTag,
            ),
            child: const Icon(Icons.today_rounded, size: 16, color: kGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Today's Hours",
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: kWhite)),
                Text('${todayHours.toStringAsFixed(2)} hours logged today',
                    style: const TextStyle(fontSize: 11, color: kGrey)),
              ],
            ),
          ),
          Text(
            '${todayLogs.length} log${todayLogs.length > 1 ? 's' : ''}',
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: kGreen),
          ),
        ],
      ),
    );
  }
}

class _PunchCard extends StatelessWidget {
  final IconData icon;
  final String label, sublabel;
  final Color accentColor;
  final bool enabled;
  final VoidCallback onTap;

  const _PunchCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.accentColor,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? accentColor : kGrey;

    return TapScale(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: kDurNormal,
        curve: kCurve,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: kRadiusCard,
          border: Border.all(
              color: enabled ? accentColor.withValues(alpha: 0.35) : kBorder),
          boxShadow: enabled
              ? [
                  BoxShadow(
                      color: accentColor.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4)),
                ]
              : kCardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: kRadiusAvatar,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: enabled ? kWhite : kGrey)),
                  const SizedBox(height: 2),
                  Text(sublabel,
                      style: TextStyle(
                          fontSize: 11,
                          color: enabled ? kGrey : kGreyDark)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: kRadiusTag,
              ),
              child: Icon(
                enabled
                    ? Icons.arrow_forward_rounded
                    : Icons.lock_outline_rounded,
                size: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
