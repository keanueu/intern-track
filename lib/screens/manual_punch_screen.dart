import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'break_tracking_screen.dart';

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

  Future<Position?> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _punch(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final state = context.read<AppState>();
    final pos = await _getLocation();
    final msg = await state.punch(
      lat: pos?.latitude,
      lng: pos?.longitude,
      locationName: null,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          Icon(msg.contains('Success') ? AppIcons.checkCircle : AppIcons.warning,
              color: msg.contains('Success') ? kGreen : kAmber),
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

                  // 1. Header (Large Title)
                  FadeSlideIn(
                    index: 0,
                    child: const Text('Manual Entry',
                        style: TextStyle(
                            fontSize: 34, fontWeight: FontWeight.w800, color: kWhite)),
                  ),

                  const SizedBox(height: 12),

                  // 2. Offline notice — context BEFORE user acts
                  FadeSlideIn(
                    index: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: kGreen.withValues(alpha: 0.07),
                        borderRadius: kRadiusBtn,
                      ),
                      child: Row(
                        children: [
                          const Icon(AppIcons.wifiOff, size: 14, color: kGreen),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Entries are saved offline and sync automatically.',
                              style: TextStyle(fontSize: 11, color: kGrey, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. Live clock — Flat Inset Grouped style
                  FadeSlideIn(
                    index: 2,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                      decoration: BoxDecoration(
                        color: kSurface2,
                        borderRadius: kRadiusCard,
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

                  const SizedBox(height: 24),

                  // 4. Today's summary — grouped flat
                  if (state.logs.isNotEmpty) ...[
                    FadeSlideIn(index: 3, child: _TodaySummary(state: state)),
                    const SizedBox(height: 24),
                  ],

                  // 5. Punch actions — Inset Grouped List
                  FadeSlideIn(
                    index: 4,
                    child: const Text('ACTIONS',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700, color: kGreyDark)),
                  ),
                  const SizedBox(height: 8),

                  FadeSlideIn(
                    index: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: kSurface2,
                        borderRadius: kRadiusCard,
                      ),
                      child: Column(
                        children: [
                          _GroupedPunchAction(
                            icon: AppIcons.login,
                            label: 'Time In',
                            sublabel: isPunchedIn
                                ? 'Already logged in'
                                : 'Record your arrival time',
                            accentColor: kGreen,
                            enabled: !isPunchedIn,
                            onTap: () => _punch(context),
                          ),
                          const Divider(height: 1, indent: 56, endIndent: 0, color: kBorder),
                          _GroupedPunchAction(
                            icon: AppIcons.logout,
                            label: 'Time Out',
                            sublabel: !isPunchedIn
                                ? 'No active session'
                                : 'Record your departure time',
                            accentColor: kAmber,
                            enabled: isPunchedIn,
                            onTap: () => _punch(context),
                          ),
                          const Divider(height: 1, indent: 56, endIndent: 0, color: kBorder),
                          _GroupedPunchAction(
                            icon: AppIcons.breakfast,
                            label: 'Break',
                            sublabel: !isPunchedIn
                                ? 'Must be timed in first'
                                : state.isOnBreak ? 'End your current break' : 'Log lunch or rest break',
                            accentColor: kGreenLight,
                            enabled: isPunchedIn,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: kSurface,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                                  side: BorderSide(color: kBorder),
                                ),
                                builder: (_) => const BreakTrackingScreen(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kSurface2,
        borderRadius: kRadiusCard,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kGreen.withValues(alpha: 0.12),
              borderRadius: kRadiusTag,
            ),
            child: const Icon(AppIcons.today, size: 16, color: kGreen),
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

class _GroupedPunchAction extends StatelessWidget {
  final IconData icon;
  final String label, sublabel;
  final Color accentColor;
  final bool enabled;
  final VoidCallback onTap;

  const _GroupedPunchAction({
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
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: kRadiusTag,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: enabled ? kWhite : kGrey)),
                  const SizedBox(height: 2),
                  Text(sublabel,
                      style: TextStyle(
                          fontSize: 12,
                          color: enabled ? kGrey : kGreyDark)),
                ],
              ),
            ),
            const Icon(
              AppIcons.chevronRight,
              color: kGreyDark,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
