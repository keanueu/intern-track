import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform, File;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/profile_model.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

// image_picker + dart:io File only work on Android/iOS
bool get _isMobile {
  if (kIsWeb) return false;
  try { return Platform.isAndroid || Platform.isIOS; } catch (_) { return false; }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final profile = state.profile;
        final pct = (state.completionPercent * 100).clamp(0.0, 100.0);

        return Scaffold(
          backgroundColor: kBg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Header Section
                  FadeSlideIn(
                    index: 0,
                    child: Column(
                      children: [
                        _AvatarPicker(profile: profile, state: state),
                        const SizedBox(height: 16),
                        Text(profile.fullName,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: kWhite)),
                        const SizedBox(height: 4),
                        Text('${profile.course} • ${profile.batch}',
                            style: const TextStyle(
                                fontSize: 14, color: kGrey)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Metrics / Action Row
                  FadeSlideIn(
                    index: 1,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _InlineStat(label: 'OJT Hours', value: state.totalHours.toStringAsFixed(1), color: kGreen),
                            _InlineDivider(),
                            _InlineStat(label: 'Required', value: '${profile.requiredHours.toInt()}', color: kAmber),
                            _InlineDivider(),
                            _InlineStat(label: 'Days', value: '${state.daysPresent}', color: kGreenLight),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: TapScale(
                            onTap: () => _showEditProfile(context, state),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: kSurface2,
                                borderRadius: kRadiusBtn,
                                border: Border.all(color: kBorder),
                              ),
                              child: const Center(
                                child: Text('Edit Profile',
                                    style: TextStyle(
                                        color: kWhite,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 3. Tabbed Section (Segmented Control)
                  FadeSlideIn(
                    index: 2,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: kSurface2,
                        borderRadius: kRadiusBtn,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: TapScale(
                              onTap: () => setState(() => _selectedTab = 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _selectedTab == 0 ? kSurface : Colors.transparent,
                                  borderRadius: kRadiusTag,
                                  boxShadow: _selectedTab == 0 ? const [BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                                ),
                                child: Center(
                                  child: Text('Progress',
                                      style: TextStyle(
                                          color: _selectedTab == 0 ? kWhite : kGrey,
                                          fontWeight: _selectedTab == 0 ? FontWeight.w700 : FontWeight.w600,
                                          fontSize: 14)),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TapScale(
                              onTap: () => setState(() => _selectedTab = 1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _selectedTab == 1 ? kSurface : Colors.transparent,
                                  borderRadius: kRadiusTag,
                                  boxShadow: _selectedTab == 1 ? const [BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                                ),
                                child: Center(
                                  child: Text('Statistics',
                                      style: TextStyle(
                                          color: _selectedTab == 1 ? kWhite : kGrey,
                                          fontWeight: _selectedTab == 1 ? FontWeight.w700 : FontWeight.w600,
                                          fontSize: 14)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tab Content
                  FadeSlideIn(
                    index: 3,
                    child: DarkCard(
                      child: _selectedTab == 0
                          ? _buildProgressTab(state, profile, pct)
                          : _buildStatisticsTab(state, profile),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 4. Settings & Preferences
                  FadeSlideIn(
                    index: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 8, bottom: 8),
                          child: Text('ACCOUNT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kGreyDark)),
                        ),
                        DarkCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _MenuItem(
                                icon: AppIcons.workHistory,
                                label: 'OJT Details',
                                sub: '${profile.company} • ${profile.supervisor}',
                                color: kGreen,
                                onTap: () => _showOjtDetails(context, state),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.only(left: 8, bottom: 8),
                          child: Text('DATA & ACTIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kGreyDark)),
                        ),
                        DarkCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _MenuItem(
                                icon: AppIcons.qr,
                                label: 'My QR Token',
                                sub: 'View to pair scanner',
                                color: kAmber,
                                onTap: () => _showQrToken(context, profile),
                              ),
                              const _CardDivider(),
                              _MenuItem(
                                icon: AppIcons.download,
                                label: 'Export DTR',
                                sub: 'Copy summary to clipboard',
                                color: kGreenLight,
                                onTap: () => _exportDtr(context, state),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 5. Footer Area
                  FadeSlideIn(
                    index: 5,
                    child: TapScale(
                      onTap: () {
                        state.logout();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: kRed.withValues(alpha: 0.1),
                          borderRadius: kRadiusBtn,
                          border: Border.all(color: kRed.withValues(alpha: 0.3)),
                        ),
                        child: const Center(
                          child: Text('Log Out',
                              style: TextStyle(
                                  color: kRed,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                        ),
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

  Widget _buildProgressTab(AppState state, ProfileModel profile, double pct) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('OJT Completion',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kWhite)),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: kGreen.withValues(alpha: 0.12),
                borderRadius: kRadiusTag,
                border: Border.all(
                    color: kGreen.withValues(alpha: 0.3)),
              ),
              child: Text(
                '${pct.toStringAsFixed(1)}%',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: kGreen),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedGradientBar(
          value: state.completionPercent.clamp(0.0, 1.0),
          height: 10,
        ),
        const SizedBox(height: 8),
        Text(
          '${state.totalHours.toStringAsFixed(1)} of ${profile.requiredHours.toInt()} hours rendered',
          style:
              const TextStyle(fontSize: 11, color: kGrey),
        ),
      ],
    );
  }

  Widget _buildStatisticsTab(AppState state, ProfileModel profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatRow('Remaining Hours', '${state.remainingHours.toStringAsFixed(2)} hrs'),
        _StatRow('This Week Logs', '${state.weekLogs.length} sessions'),
        _StatRow('Total Days Present', '${state.daysPresent} days'),
        _StatRow('Total Hours Rendered', '${state.totalHours.toStringAsFixed(2)} hrs'),
      ],
    );
  }

  void _showEditProfile(BuildContext context, AppState state) {
    final profile = state.profile;
    final nameCtrl = TextEditingController(text: profile.fullName);
    final courseCtrl = TextEditingController(text: profile.course);
    final batchCtrl = TextEditingController(text: profile.batch);
    final hoursCtrl =
        TextEditingController(text: profile.requiredHours.toInt().toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: kBorder),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Edit Profile',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: kWhite)),
                TapScale(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration:
                        BoxDecoration(color: kSurface2, borderRadius: kRadiusTag),
                    child: const Icon(AppIcons.close,
                        color: kGrey, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Field(
                controller: nameCtrl,
                label: 'Full Name',
                icon: AppIcons.profile),
            const SizedBox(height: 12),
            _Field(
                controller: courseCtrl,
                label: 'Course',
                icon: AppIcons.school),
            const SizedBox(height: 12),
            _Field(
                controller: batchCtrl,
                label: 'Batch / Year',
                icon: AppIcons.calendar),
            const SizedBox(height: 12),
            _Field(
                controller: hoursCtrl,
                label: 'Required OJT Hours',
                icon: AppIcons.timer,
                numeric: true),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TapScale(
                onTap: () {
                  final updated = profile.copyWith(
                    fullName: nameCtrl.text.trim(),
                    course: courseCtrl.text.trim(),
                    batch: batchCtrl.text.trim(),
                    requiredHours:
                        double.tryParse(hoursCtrl.text) ?? profile.requiredHours,
                  );
                  state.saveProfile(updated);
                  Navigator.pop(ctx);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                      gradient: kGreenGradient, borderRadius: kRadiusBtn),
                  child: const Center(
                    child: Text('Save Changes',
                        style: TextStyle(
                            color: kBg,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
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

  void _showOjtDetails(BuildContext context, AppState state) {
    final profile = state.profile;
    final companyCtrl = TextEditingController(text: profile.company);
    final supervisorCtrl = TextEditingController(text: profile.supervisor);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: kBorder),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('OJT Details',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: kWhite)),
                TapScale(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration:
                        BoxDecoration(color: kSurface2, borderRadius: kRadiusTag),
                    child: const Icon(AppIcons.close,
                        color: kGrey, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Field(
                controller: companyCtrl,
                label: 'Company Name',
                icon: AppIcons.business),
            const SizedBox(height: 12),
            _Field(
                controller: supervisorCtrl,
                label: 'Supervisor Name',
                icon: AppIcons.manageAccounts),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TapScale(
                onTap: () {
                  final updated = profile.copyWith(
                    company: companyCtrl.text.trim(),
                    supervisor: supervisorCtrl.text.trim(),
                  );
                  state.saveProfile(updated);
                  Navigator.pop(ctx);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                      gradient: kGreenGradient, borderRadius: kRadiusBtn),
                  child: const Center(
                    child: Text('Save',
                        style: TextStyle(
                            color: kBg,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
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

  void _showQrToken(BuildContext context, ProfileModel profile) {
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
            const Text('My QR Token',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, color: kWhite)),
            const SizedBox(height: 8),
            const Text('Share this token to register on a scanner device.',
                style: TextStyle(fontSize: 12, color: kGrey)),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kSurface2,
                borderRadius: kRadiusBtn,
                border: Border.all(color: kBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(profile.qrCodeToken,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kWhite)),
                  ),
                  TapScale(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: profile.qrCodeToken));
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: const Text('Token copied!',
                              style: TextStyle(color: kWhite)),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: kSurface,
                          shape: RoundedRectangleBorder(
                              borderRadius: kRadiusBtn,
                              side: const BorderSide(color: kBorder)),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kGreen.withValues(alpha: 0.12),
                        borderRadius: kRadiusTag,
                        border:
                            Border.all(color: kGreen.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(AppIcons.copy,
                          size: 16, color: kGreen),
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
      buffer.writeln(
          'Date: ${log.timeIn.month}/${log.timeIn.day}/${log.timeIn.year}');
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
    buffer.writeln(
        'Completion   : ${(state.completionPercent * 100).toStringAsFixed(1)}%');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(AppIcons.checkCircle, color: kGreen),
          SizedBox(width: 10),
          Text('DTR report copied to clipboard!',
              style: TextStyle(color: kWhite)),
        ]),
        behavior: SnackBarBehavior.floating,
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(
            borderRadius: kRadiusBtn, side: const BorderSide(color: kBorder)),
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

class _InlineStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _InlineStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, color: color)),
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

class _StatRow extends StatelessWidget {
  final String label, value;
  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: kGrey)),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: kWhite)),
          ],
        ),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool numeric;
  const _Field(
      {required this.controller,
      required this.label,
      required this.icon,
      this.numeric = false});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: kWhite),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18, color: kGreen),
          filled: true,
          fillColor: kSurface2,
          border: OutlineInputBorder(
              borderRadius: kRadiusInput, borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: kRadiusInput,
              borderSide: const BorderSide(color: kBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: kRadiusInput,
              borderSide: const BorderSide(color: kGreen)),
          labelStyle: const TextStyle(color: kGrey),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => TapScale(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: kRadiusTag,
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kWhite)),
                    Text(sub,
                        style: const TextStyle(fontSize: 11, color: kGrey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(AppIcons.chevronRight,
                  color: kGreyDark, size: 20),
            ],
          ),
        ),
      );
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 60, endIndent: 20, color: kBorder);
}

class _AvatarPicker extends StatelessWidget {
  final ProfileModel profile;
  final AppState state;
  const _AvatarPicker({required this.profile, required this.state});

  Future<void> _pick(BuildContext context) async {
    // image_picker not supported on Windows/web — show info instead
    if (!_isMobile) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Image picker is only available on mobile devices.',
              style: TextStyle(color: kWhite)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: kSurface,
          shape: RoundedRectangleBorder(
              borderRadius: kRadiusBtn, side: const BorderSide(color: kBorder)),
        ),
      );
      return;
    }
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: kBorder),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(2))),
              _PickOption(
                icon: AppIcons.camera,
                label: 'Take Photo',
                color: kGreen,
                onTap: () async {
                  Navigator.pop(ctx);
                  final img = await picker.pickImage(
                      source: ImageSource.camera, imageQuality: 85);
                  if (img != null) {
                    state.saveProfile(profile.copyWith(avatarPath: img.path));
                  }
                },
              ),
              _PickOption(
                icon: AppIcons.photoLibrary,
                label: 'Choose from Gallery',
                color: kGreenLight,
                onTap: () async {
                  Navigator.pop(ctx);
                  final img = await picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 85);
                  if (img != null) {
                    state.saveProfile(profile.copyWith(avatarPath: img.path));
                  }
                },
              ),
              if (profile.avatarPath != null)
                _PickOption(
                  icon: AppIcons.deleteOutline,
                  label: 'Remove Photo',
                  color: kRed,
                  onTap: () {
                    Navigator.pop(ctx);
                    state.saveProfile(profile.copyWith(clearAvatar: true));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = _isMobile &&
        profile.avatarPath != null &&
        File(profile.avatarPath!).existsSync();

    return TapScale(
      onTap: () => _pick(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: hasImage ? null : kGreenGradientDeep,
              borderRadius: BorderRadius.circular(40),
              boxShadow: kGreenGlow,
              image: hasImage
                  ? DecorationImage(
                      image: FileImage(File(profile.avatarPath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasImage
                ? null
                : const Icon(AppIcons.profile, color: kWhite, size: 36),
          ),
          // Camera badge
          Positioned(
            bottom: -4, right: -4,
            child: Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                color: kGreen,
                shape: BoxShape.circle,
                border: Border.all(color: kSurface, width: 2),
              ),
              child: const Icon(AppIcons.camera, size: 14, color: kBg),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PickOption({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => TapScale(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: kRadiusTag,
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 14),
              Text(label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: kWhite)),
            ],
          ),
        ),
      );
}
