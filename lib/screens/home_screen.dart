import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

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
                    FadeSlideIn(index: 0, child: _TopBar(state: state)),
                    const SizedBox(height: 24),
                    FadeSlideIn(index: 1, child: _HeroBanner(state: state)),
                    const SizedBox(height: 20),
                    FadeSlideIn(index: 2, child: _WeekStrip(state: state)),
                    const SizedBox(height: 28),
                    FadeSlideIn(
                      index: 3,
                      child: const Text("Today's Overview",
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kWhite)),
                    ),
                    const SizedBox(height: 14),
                    FadeSlideIn(index: 4, child: _TodayCards(state: state)),
                    const SizedBox(height: 24),
                    FadeSlideIn(
                      index: 5,
                      child: const Text('OJT Hours',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kWhite)),
                    ),
                    const SizedBox(height: 14),
                    FadeSlideIn(index: 6, child: _StatsRow(state: state)),
                    const SizedBox(height: 20),
                    FadeSlideIn(index: 7, child: _ProgressCard(state: state)),
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
}

class _TopBar extends StatelessWidget {
  final AppState state;
  const _TopBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final firstName = state.profile.fullName.split(' ').first;
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final n = DateTime.now();

    return Row(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            gradient: kGreenGradientDeep,
            borderRadius: kRadiusAvatar,
            boxShadow: kGreenGlow,
          ),
          child: const Icon(Icons.person_rounded, color: kWhite, size: 22),
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
            decoration: BoxDecoration(color: kSurface, borderRadius: kRadiusAvatar, border: Border.all(color: kBorder)),
            child: const Icon(Icons.notifications_none_rounded, color: kGrey, size: 20),
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
                  style: const TextStyle(color: kWhite, fontSize: 26, fontWeight: FontWeight.w900, height: 1.15),
                ),
                const SizedBox(height: 8),
                Text(sub, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
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
              isPunchedIn ? Icons.check_circle_rounded : Icons.qr_code_2_rounded,
              color: kWhite, size: 38,
            ),
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
    const labels = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
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
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                        color: isSelected ? kBg : kGrey)),
                const SizedBox(height: 4),
                Text('${day.day}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                        color: isSelected ? kBg : kWhite)),
                const SizedBox(height: 6),
                Container(
                  width: 5, height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? kBg.withValues(alpha: 0.5)
                        : hasPunch ? kGreen : kGreyDark,
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
      l.timeIn.year == today.year && l.timeIn.month == today.month && l.timeIn.day == today.day
    ).toList();
    final latest = todayLogs.isNotEmpty ? todayLogs.first : null;

    return Row(
      children: [
        Expanded(child: _StatCard(
          label: 'TIME IN',
          value: latest != null ? _fmt(latest.timeIn) : '--:--',
          sub: latest != null ? 'Logged today' : 'No entry yet',
          icon: Icons.login_rounded,
          color: kGreen,
        )),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(
          label: 'TIME OUT',
          value: latest?.timeOut != null ? _fmt(latest!.timeOut) : '--:--',
          sub: state.isPunchedIn ? 'Session active' : latest?.timeOut != null ? 'Session ended' : 'No entry yet',
          icon: Icons.logout_rounded,
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
  const _StatCard({required this.label, required this.value, required this.sub, required this.icon, required this.color});

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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: kRadiusTag),
                  child: Icon(icon, color: color, size: 14),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: kGrey, letterSpacing: 0.8)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kWhite)),
            const SizedBox(height: 3),
            Text(sub, style: const TextStyle(fontSize: 11, color: kGrey)),
          ],
        ),
      );
}

class _StatsRow extends StatelessWidget {
  final AppState state;
  const _StatsRow({required this.state});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _MiniStat(label: 'Rendered', value: '${state.totalHours.toStringAsFixed(1)}h', color: kGreen),
          const SizedBox(width: 10),
          _MiniStat(label: 'Required', value: '${state.requiredHours.toInt()}h', color: kAmber),
          const SizedBox(width: 10),
          _MiniStat(label: 'Remaining', value: '${state.remainingHours.toStringAsFixed(1)}h', color: kRed),
        ],
      );
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: kRadiusCard,
            border: Border.all(color: kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
              const SizedBox(height: 3),
              Text(label, style: const TextStyle(fontSize: 10, color: kGrey)),
            ],
          ),
        ),
      );
}

class _ProgressCard extends StatelessWidget {
  final AppState state;
  const _ProgressCard({required this.state});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: kRadiusCard,
          border: Border.all(color: kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('OJT Completion',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kWhite)),
                Text(
                  '${(state.completionPercent * 100).clamp(0, 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kGreen),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedGradientBar(value: state.completionPercent.clamp(0.0, 1.0), height: 8),
            const SizedBox(height: 10),
            Text(
              '${state.totalHours.toStringAsFixed(1)} of ${state.requiredHours.toInt()} hours rendered',
              style: const TextStyle(fontSize: 11, color: kGrey),
            ),
          ],
        ),
      );
}
