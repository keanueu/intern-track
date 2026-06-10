import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/profile_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final profile = state.profile;
        final pct = (state.completionPercent * 100).clamp(0.0, 100.0);

        return Scaffold(
          backgroundColor: const Color(0xFFF5F4F0),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),

                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Profile',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1E))),
                      GestureDetector(
                        onTap: () => _showEditProfile(context, state),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.settings_rounded, color: Color(0xFF1C1C1E), size: 20),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Avatar + info
                  Row(
                    children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(color: const Color(0xFFD4CFFF), borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.person_rounded, color: Color(0xFF6C63FF), size: 34),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile.fullName,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1E))),
                            const SizedBox(height: 3),
                            Text('${profile.course} • ${profile.batch}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showEditProfile(context, state),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF1C1C1E)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Stats row
                  Row(
                    children: [
                      _StatBox(label: 'OJT Hours', value: state.totalHours.toStringAsFixed(1), color: const Color(0xFFD4CFFF)),
                      const SizedBox(width: 10),
                      _StatBox(label: 'Required', value: '${profile.requiredHours.toInt()}', color: const Color(0xFFFFD6A5)),
                      const SizedBox(width: 10),
                      _StatBox(label: 'Days Present', value: '${state.daysPresent}', color: const Color(0xFFB5EAD7)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Progress card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('OJT Completion',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E))),
                            Text('${pct.toStringAsFixed(1)}%',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF6C63FF))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: state.completionPercent.clamp(0.0, 1.0),
                            minHeight: 10,
                            backgroundColor: const Color(0xFFF5F4F0),
                            valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${state.totalHours.toStringAsFixed(1)} of ${profile.requiredHours.toInt()} hours rendered',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Menu items
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                    child: Column(
                      children: [
                        _MenuItem(
                          icon: Icons.work_history_rounded,
                          label: 'OJT Details',
                          sub: '${profile.company} • ${profile.supervisor}',
                          color: const Color(0xFFD4CFFF),
                          iconColor: const Color(0xFF6C63FF),
                          onTap: () => _showOjtDetails(context, state),
                        ),
                        const _Divider(),
                        _MenuItem(
                          icon: Icons.insert_chart_rounded,
                          label: 'Statistics',
                          sub: '${state.daysPresent} days • ${state.totalHours.toStringAsFixed(1)} hrs total',
                          color: const Color(0xFFB5EAD7),
                          iconColor: const Color(0xFF2DBF8A),
                          onTap: () => _showStats(context, state),
                        ),
                        const _Divider(),
                        _MenuItem(
                          icon: Icons.qr_code_rounded,
                          label: 'My QR Token',
                          sub: profile.qrCodeToken,
                          color: const Color(0xFFFFD6A5),
                          iconColor: const Color(0xFFFF9F1C),
                          onTap: () => _showQrToken(context, profile),
                        ),
                        const _Divider(),
                        _MenuItem(
                          icon: Icons.download_rounded,
                          label: 'Export DTR',
                          sub: 'Copy summary to clipboard',
                          color: const Color(0xFFFFB3B3),
                          iconColor: const Color(0xFFE05252),
                          onTap: () => _exportDtr(context, state),
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

  // ── Edit Profile Bottom Sheet ──────────────────────────────────────────────
  void _showEditProfile(BuildContext context, AppState state) {
    final profile = state.profile;
    final nameCtrl = TextEditingController(text: profile.fullName);
    final courseCtrl = TextEditingController(text: profile.course);
    final batchCtrl = TextEditingController(text: profile.batch);
    final hoursCtrl = TextEditingController(text: profile.requiredHours.toInt().toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Edit Profile', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const SizedBox(height: 16),
            _Field(controller: nameCtrl, label: 'Full Name', icon: Icons.person_rounded),
            const SizedBox(height: 12),
            _Field(controller: courseCtrl, label: 'Course', icon: Icons.school_rounded),
            const SizedBox(height: 12),
            _Field(controller: batchCtrl, label: 'Batch / Year', icon: Icons.calendar_today_rounded),
            const SizedBox(height: 12),
            _Field(controller: hoursCtrl, label: 'Required OJT Hours', icon: Icons.timer_rounded, numeric: true),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  final updated = profile.copyWith(
                    fullName: nameCtrl.text.trim(),
                    course: courseCtrl.text.trim(),
                    batch: batchCtrl.text.trim(),
                    requiredHours: double.tryParse(hoursCtrl.text) ?? profile.requiredHours,
                  );
                  state.saveProfile(updated);
                  Navigator.pop(ctx);
                },
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── OJT Details Bottom Sheet ───────────────────────────────────────────────
  void _showOjtDetails(BuildContext context, AppState state) {
    final profile = state.profile;
    final companyCtrl = TextEditingController(text: profile.company);
    final supervisorCtrl = TextEditingController(text: profile.supervisor);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('OJT Details', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const SizedBox(height: 16),
            _Field(controller: companyCtrl, label: 'Company Name', icon: Icons.business_rounded),
            const SizedBox(height: 12),
            _Field(controller: supervisorCtrl, label: 'Supervisor Name', icon: Icons.manage_accounts_rounded),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  final updated = profile.copyWith(
                    company: companyCtrl.text.trim(),
                    supervisor: supervisorCtrl.text.trim(),
                  );
                  state.saveProfile(updated);
                  Navigator.pop(ctx);
                },
                child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Statistics Sheet ───────────────────────────────────────────────────────
  void _showStats(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Statistics', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            _StatRow('Total Days Present', '${state.daysPresent} days'),
            _StatRow('Total Hours Rendered', '${state.totalHours.toStringAsFixed(2)} hrs'),
            _StatRow('Required Hours', '${state.profile.requiredHours.toInt()} hrs'),
            _StatRow('Remaining Hours', '${state.remainingHours.toStringAsFixed(2)} hrs'),
            _StatRow('Completion', '${(state.completionPercent * 100).toStringAsFixed(1)}%'),
            _StatRow('This Week Logs', '${state.weekLogs.length} sessions'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── QR Token Sheet ─────────────────────────────────────────────────────────
  void _showQrToken(BuildContext context, ProfileModel profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My QR Token', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Share this token to register on a scanner device.',
                style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF5F4F0), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(profile.qrCodeToken,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E))),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: profile.qrCodeToken));
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: const Text('Token copied!'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF1C1C1E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFD4CFFF), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF6C63FF)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Export DTR ─────────────────────────────────────────────────────────────
  void _exportDtr(BuildContext context, AppState state) {
    final profile = state.profile;
    final logs = state.logs;
    final buffer = StringBuffer();

    buffer.writeln('=== DTR REPORT ===');
    buffer.writeln('Name: ${profile.fullName}');
    buffer.writeln('Course: ${profile.course} • ${profile.batch}');
    buffer.writeln('Company: ${profile.company}');
    buffer.writeln('Supervisor: ${profile.supervisor}');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('');
    buffer.writeln('--- ATTENDANCE LOG ---');

    for (final log in logs) {
      final timeIn = _fmtDt(log.timeIn);
      final timeOut = log.timeOut != null ? _fmtDt(log.timeOut!) : 'N/A';
      buffer.writeln('Date: ${log.timeIn.month}/${log.timeIn.day}/${log.timeIn.year}');
      buffer.writeln('  Time In:  $timeIn');
      buffer.writeln('  Time Out: $timeOut');
      buffer.writeln('  Hours:    ${log.calculatedHours.toStringAsFixed(2)}');
      buffer.writeln('');
    }

    buffer.writeln('--- SUMMARY ---');
    buffer.writeln('Days Present : ${state.daysPresent}');
    buffer.writeln('Total Hours  : ${state.totalHours.toStringAsFixed(2)}');
    buffer.writeln('Required     : ${profile.requiredHours.toInt()}');
    buffer.writeln('Remaining    : ${state.remainingHours.toStringAsFixed(2)}');
    buffer.writeln('Completion   : ${(state.completionPercent * 100).toStringAsFixed(1)}%');

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle_rounded, color: Colors.white),
          SizedBox(width: 10),
          Text('DTR report copied to clipboard!'),
        ]),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  String _fmtDt(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}

class _StatRow extends StatelessWidget {
  final String label, value;
  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1E))),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool numeric;
  const _Field({required this.controller, required this.label, required this.icon, this.numeric = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF6C63FF)),
        filled: true,
        fillColor: const Color(0xFFF5F4F0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1C1C1E))),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF555555), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color color, iconColor;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, required this.sub, required this.color, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E))),
                  Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0AFAF), size: 20),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 60, endIndent: 16, color: Color(0xFFF5F4F0));
  }
}
