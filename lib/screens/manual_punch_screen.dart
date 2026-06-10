import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _now = DateTime.now()));
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
          const Icon(Icons.check_circle_rounded, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text(msg)),
        ]),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ));
    }
  }

  String get _hms => '${_p(_now.hour)}:${_p(_now.minute)}:${_p(_now.second)}';

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
          backgroundColor: const Color(0xFFF5F4F0),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),

                  // Header
                  Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: const Color(0xFFFFD6A5), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.edit_note_rounded, color: Color(0xFFFF9F1C), size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Manual Entry', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1E))),
                          Text('Traditional DTR Log', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Live clock card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
                    decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(28)),
                    child: Column(
                      children: [
                        Text(_hms,
                            style: const TextStyle(
                              color: Colors.white, fontSize: 48, fontWeight: FontWeight.w300,
                              letterSpacing: 3, fontFeatures: [FontFeature.tabularFigures()],
                            )),
                        const SizedBox(height: 6),
                        Text(_dateLabel, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 16),
                        // Session status pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isPunchedIn
                                ? const Color(0xFF2DBF8A).withValues(alpha: 0.2)
                                : const Color(0xFF6C63FF).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7, height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isPunchedIn ? const Color(0xFF2DBF8A) : const Color(0xFF6C63FF),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isPunchedIn && openLog != null
                                    ? 'Active since ${_fmt(openLog.timeIn)}'
                                    : 'Not punched in',
                                style: TextStyle(
                                  color: isPunchedIn ? const Color(0xFF2DBF8A) : const Color(0xFF6C63FF),
                                  fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),
                  const Text('Punch Attendance',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1E))),
                  const SizedBox(height: 14),

                  // Time In — disabled if already punched in
                  _PunchCard(
                    icon: Icons.login_rounded,
                    label: 'Time In',
                    sublabel: isPunchedIn ? 'Already logged in' : 'Record your arrival time',
                    bgColor: const Color(0xFFD4CFFF),
                    iconColor: const Color(0xFF6C63FF),
                    enabled: !isPunchedIn,
                    onTap: () => _punch(context),
                  ),

                  const SizedBox(height: 12),

                  // Time Out — disabled if not punched in
                  _PunchCard(
                    icon: Icons.logout_rounded,
                    label: 'Time Out',
                    sublabel: !isPunchedIn ? 'No active session' : 'Record your departure time',
                    bgColor: const Color(0xFFFFD6A5),
                    iconColor: const Color(0xFFFF9F1C),
                    enabled: isPunchedIn,
                    onTap: () => _punch(context),
                  ),

                  const SizedBox(height: 12),

                  // Break — only when punched in
                  _PunchCard(
                    icon: Icons.free_breakfast_rounded,
                    label: 'Break',
                    sublabel: !isPunchedIn ? 'Must be timed in first' : 'Log lunch or rest break',
                    bgColor: const Color(0xFFB5EAD7),
                    iconColor: const Color(0xFF2DBF8A),
                    enabled: isPunchedIn,
                    onTap: () => _punch(context),
                  ),

                  const SizedBox(height: 24),

                  // Today's hours summary
                  if (state.logs.isNotEmpty) _TodaySummary(state: state),

                  const SizedBox(height: 12),

                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFFD4CFFF), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.wifi_off_rounded, size: 16, color: Color(0xFF6C63FF)),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Entries are saved offline and will sync automatically.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF555555), height: 1.4),
                          ),
                        ),
                      ],
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
    final todayLogs = state.logs.where((l) =>
        l.timeIn.year == today.year &&
        l.timeIn.month == today.month &&
        l.timeIn.day == today.day).toList();

    if (todayLogs.isEmpty) return const SizedBox.shrink();

    final double todayHours = todayLogs.fold(0, (sum, l) => sum + l.calculatedHours);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFB5EAD7), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.today_rounded, size: 16, color: Color(0xFF2DBF8A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Today's Hours", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E))),
                Text('${todayHours.toStringAsFixed(2)} hours logged today',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
              ],
            ),
          ),
          Text('${todayLogs.length} log${todayLogs.length > 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2DBF8A))),
        ],
      ),
    );
  }
}

class _PunchCard extends StatelessWidget {
  final IconData icon;
  final String label, sublabel;
  final Color bgColor, iconColor;
  final bool enabled;
  final VoidCallback onTap;

  const _PunchCard({
    required this.icon, required this.label, required this.sublabel,
    required this.bgColor, required this.iconColor,
    required this.enabled, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? iconColor : const Color(0xFFB0AFAF);
    final effectiveBg = enabled ? bgColor : const Color(0xFFF0F0F0);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(color: effectiveBg, borderRadius: BorderRadius.circular(22)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: effectiveColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: effectiveColor)),
                  const SizedBox(height: 2),
                  Text(sublabel, style: TextStyle(fontSize: 11, color: effectiveColor.withValues(alpha: 0.65))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                enabled ? Icons.arrow_forward_rounded : Icons.lock_outline_rounded,
                size: 16, color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
