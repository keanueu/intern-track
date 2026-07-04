import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'break_tracking_screen.dart';
import 'activity_log_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: kBg,
          body: SafeArea(
            child: RefreshIndicator(
              color: kGreen,
              backgroundColor: kSurface,
              onRefresh: () => state.load(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // 1. Greeting + date
                    FadeSlideIn(index: 0, child: _TopBar(state: state)),
                    const SizedBox(height: 20),

                    // 2. Hero — primary action context
                    FadeSlideIn(index: 1, child: _HeroBanner(state: state)),
                    const SizedBox(height: 20),

                    // 3. Today's time-in / time-out — directly under hero (same topic)
                    FadeSlideIn(
                      index: 2,
                      child: const Text("Today's Punches",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kWhite)),
                    ),
                    const SizedBox(height: 10),
                    FadeSlideIn(index: 3, child: _TodayCards(state: state)),
                    const SizedBox(height: 16),

                    // Session Controls (Break + Activity) when punched in
                    if (state.isPunchedIn)
                      FadeSlideIn(index: 4, child: _SessionControls(state: state)),
                    const SizedBox(height: 24),

                    // 4. Week strip — labelled so user knows what it is
                    FadeSlideIn(
                      index: 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('This Week',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kWhite)),
                          Text(
                            _weekRangeLabel(),
                            style: const TextStyle(fontSize: 11, color: kGrey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeSlideIn(index: 6, child: _WeekStrip(state: state)),
                    const SizedBox(height: 24),

                    // 5. OJT Hours — unified progress + stats in one card
                    FadeSlideIn(
                      index: 7,
                      child: const Text('OJT Progress',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kWhite)),
                    ),
                    const SizedBox(height: 10),
                    FadeSlideIn(index: 8, child: _OjtProgressCard(state: state)),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _weekRangeLabel() {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final today = DateTime.now();
    final start = today.subtract(Duration(days: today.weekday - 1));
    final end = start.add(const Duration(days: 6));
    return '${months[start.month - 1]} ${start.day} – ${months[end.month - 1]} ${end.day}';
  }
}

class _TopBar extends StatelessWidget {
  final AppState state;
  const _TopBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final firstName = state.profile.fullName.split(' ').first;
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final n = DateTime.now();

    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';

    return Row(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            gradient: kGreenGradientDeep,
            borderRadius: kRadiusAvatar,
            boxShadow: kGreenGlow,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kWhite,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, $firstName 👋',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kWhite)),
            Text('${n.day} ${months[n.month - 1]} ${n.year}',
                style: const TextStyle(fontSize: 12, color: kGrey)),
          ],
        ),
        const Spacer(),
        TapScale(
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: kSurface, borderRadius: kRadiusAvatar, border: Border.all(color: kBorder)),
            child: const Icon(AppIcons.notifications, color: kWhite, size: 20),
          ),
        ),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final AppState state;
  const _HeroBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    final isPunchedIn = state.isPunchedIn;
    final openLog = state.openLog;
    String sub = 'Scan QR or use manual entry';
    if (isPunchedIn && openLog != null) {
      final h = openLog.timeIn.hour.toString().padLeft(2, '0');
      final m = openLog.timeIn.minute.toString().padLeft(2, '0');
      sub = 'Active since $h:$m';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: isPunchedIn ? kGreenGradientDeep : kGreenGradient,
        borderRadius: kRadiusCard,
        boxShadow: kGreenGlow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: kRadiusTag,
                  ),
                  child: Text(
                    isPunchedIn ? '● Active Session' : 'OJT Tracker',
                    style: const TextStyle(color: kWhite, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isPunchedIn ? 'Currently\nLogged In' : 'Log Your\nAttendance',
                  style: const TextStyle(
                      color: kWhite, fontSize: 26, fontWeight: FontWeight.w900, height: 1.15),
                ),
                const SizedBox(height: 8),
                Text(sub,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
              ],
            ),
          ),
          Container(
            width: 76, height: 76,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: kRadiusCard,
            ),
            child: Icon(
              isPunchedIn ? AppIcons.checkCircle : AppIcons.qr,
              color: kWhite, size: 38,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayCards extends StatelessWidget {
  final AppState state;
  const _TodayCards({required this.state});

  String _fmt(DateTime? dt) {
    if (dt == null) return '--:--';
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ap';
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayLogs = state.logs.where((l) =>
      l.timeIn.year == today.year &&
      l.timeIn.month == today.month &&
      l.timeIn.day == today.day).toList();
    final latest = todayLogs.isNotEmpty ? todayLogs.first : null;

    return Row(
      children: [
        Expanded(child: _StatCard(
          label: 'TIME IN',
          value: latest != null ? _fmt(latest.timeIn) : '--:--',
          sub: latest != null ? 'Logged today' : 'No entry yet',
          icon: AppIcons.login,
          color: kGreen,
        )),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(
          label: 'TIME OUT',
          value: latest?.timeOut != null ? _fmt(latest!.timeOut) : '--:--',
          sub: state.isPunchedIn
              ? 'Session active'
              : latest?.timeOut != null
                  ? 'Session ended'
                  : 'No entry yet',
          icon: AppIcons.logout,
          color: kAmber,
        )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label, required this.value, required this.sub,
    required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: kRadiusCard,
          border: Border.all(color: kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15), borderRadius: kRadiusTag),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(height: 12),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600, color: kGrey, letterSpacing: 0.8)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kWhite)),
            const SizedBox(height: 3),
            Text(sub, style: const TextStyle(fontSize: 11, color: kGrey)),
          ],
        ),
      );
}

class _SessionControls extends StatelessWidget {
  final AppState state;
  const _SessionControls({required this.state});

  void _openBreakSheet(BuildContext context) {
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
  }

  void _openActivitySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: kBorder),
      ),
      builder: (_) => const ActivityLogScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnBreak = state.isOnBreak;
    final activityCount = state.isPunchedIn && state.openLog != null 
        ? state.openLog!.activities.length 
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: kRadiusCard,
        border: Border.all(color: kBorder),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Session Controls',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kWhite)),
              if (isOnBreak)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kAmber.withValues(alpha: 0.15),
                    borderRadius: kRadiusTag,
                    border: Border.all(color: kAmber.withValues(alpha: 0.3)),
                  ),
                  child: const Text('BREAK',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: kAmber)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TapScale(
                  onTap: () => _openBreakSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isOnBreak ? kAmberGradient : kGreenGradient,
                      borderRadius: kRadiusBtn,
                      boxShadow: isOnBreak ? null : kGreenGlow,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isOnBreak ? AppIcons.timer : AppIcons.breakfast,
                          color: kBg, size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isOnBreak ? 'End Break' : 'Break',
                          style: const TextStyle(
                              color: kBg, fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TapScale(
                  onTap: () => _openActivitySheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: kSurface2,
                      borderRadius: kRadiusBtn,
                      border: Border.all(color: kBorder),
                    ),
                    child: Column(
                      children: [
                        Icon(AppIcons.hub, color: kGreen, size: 20),
                        const SizedBox(height: 4),
                        Text(
                          activityCount > 0 ? '$activityCount activities' : 'Activity',
                          style: const TextStyle(
                              color: kWhite, fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TapScale(
                  onTap: () {
                    // Photo capture will be added
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Photo capture coming soon',
                            style: TextStyle(color: kWhite)),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: kSurface,
                        shape: RoundedRectangleBorder(
                            borderRadius: kRadiusBtn, side: const BorderSide(color: kBorder)),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: kSurface2,
                      borderRadius: kRadiusBtn,
                      border: Border.all(color: kBorder),
                    ),
                    child: const Column(
                      children: [
                        Icon(AppIcons.camera, color: kGreenLight, size: 20),
                        SizedBox(height: 4),
                        Text('Photo',
                            style: TextStyle(
                                color: kWhite, fontWeight: FontWeight.w700, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatefulWidget {
  final AppState state;
  const _WeekStrip({required this.state});

  @override
  State<_WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<_WeekStrip> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = DateTime.now().weekday - 1;
  }

  @override
  Widget build(BuildContext context) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now();
    final start = today.subtract(Duration(days: today.weekday - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = start.add(Duration(days: i));
        final isSelected = _selected == i;
        final hasPunch = widget.state.hasPunchedOn(day);

        return TapScale(
          onTap: () => setState(() => _selected = i),
          child: AnimatedContainer(
            duration: kDurNormal,
            curve: kCurve,
            width: 42,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected ? kGreenGradient : null,
              color: isSelected ? null : kSurface,
              borderRadius: kRadiusBtn,
              border: Border.all(color: isSelected ? kGreen : kBorder),
              boxShadow: isSelected ? kGreenGlow : null,
            ),
            child: Column(
              children: [
                Text(labels[i],
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? kBg : kGrey)),
                const SizedBox(height: 4),
                Text('${day.day}',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? kBg : kWhite)),
                const SizedBox(height: 6),
                Container(
                  width: 5, height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? kBg.withValues(alpha: 0.5)
                        : hasPunch
                            ? kGreen
                            : kGreyDark,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// Unified OJT progress card: bar + 3 stats in one place
class _OjtProgressCard extends StatelessWidget {
  final AppState state;
  const _OjtProgressCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final pct = (state.completionPercent * 100).clamp(0.0, 100.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: kRadiusCard,
        border: Border.all(color: kBorder),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('OJT Completion',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kWhite)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kGreen.withValues(alpha: 0.12),
                  borderRadius: kRadiusTag,
                  border: Border.all(color: kGreen.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${pct.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress bar
          AnimatedGradientBar(value: state.completionPercent.clamp(0.0, 1.0), height: 8),
          const SizedBox(height: 6),
          Text(
            '${state.totalHours.toStringAsFixed(1)} of ${state.requiredHours.toInt()} hours rendered',
            style: const TextStyle(fontSize: 11, color: kGrey),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: kBorder),
          const SizedBox(height: 16),

          // 3 stats inline under the bar — same topic, same card
          Row(
            children: [
              _InlineStat(label: 'Rendered', value: '${state.totalHours.toStringAsFixed(1)}h', color: kGreen),
              _InlineDivider(),
              _InlineStat(label: 'Required', value: '${state.requiredHours.toInt()}h', color: kAmber),
              _InlineDivider(),
              _InlineStat(label: 'Remaining', value: '${state.remainingHours.toStringAsFixed(1)}h', color: kRed),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _InlineStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 10, color: kGrey)),
          ],
        ),
      );
}

class _InlineDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1, height: 32, color: kBorder,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );
}
