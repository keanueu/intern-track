import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'dart:io' show Platform, File;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/app_state.dart';
import '../models/profile_model.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'schedule_screen.dart';
import 'calendar_screen.dart';
import 'competency_screen.dart';
import 'export_screen.dart';
import '../services/settings_service.dart';

// image_picker + dart:io File only work on Android/iOS
bool get _isMobile {
  if (kIsWeb) return false;
  try { return Platform.isAndroid || Platform.isIOS; } catch (e) { debugPrint('_isMobile error: $e'); return false; }
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
        final c = ThemeColors.of(context);
        final profile = state.profile;
        final pct = (state.completionPercent * 100).clamp(0.0, 100.0);

        return Scaffold(
          backgroundColor: c.bg,
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
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 4),
                        Text('${profile.course} • ${profile.batch}',
                            style: Theme.of(context).textTheme.bodyMedium),
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
                              padding: const EdgeInsets.symmetric(vertical: 17),
                              decoration: BoxDecoration(
                                color: c.surface2,
                                borderRadius: kRadiusBtn,
                                border: Border.all(color: c.border),
                              ),
                              child: Center(
                                child: Text('Edit Profile',
                                    style: Theme.of(context).textTheme.labelLarge),
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
                        color: c.surface2,
                        borderRadius: kRadiusBtn,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                              child: TapScale(
                                onTap: () => setState(() => _selectedTab = 0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 17),
                                decoration: BoxDecoration(
                                  color: _selectedTab == 0 ? c.surface : Colors.transparent,
                                  borderRadius: kRadiusTag,
                                  boxShadow: _selectedTab == 0 ? const [BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                                ),
                                child: Center(
                                  child: Text('Progress',
                                      style: TextStyle(
                                          color: _selectedTab == 0 ? c.textPrimary : c.textSecondary,
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
                                  padding: const EdgeInsets.symmetric(vertical: 17),
                                decoration: BoxDecoration(
                                  color: _selectedTab == 1 ? c.surface : Colors.transparent,
                                  borderRadius: kRadiusTag,
                                  boxShadow: _selectedTab == 1 ? const [BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                                ),
                                child: Center(
                                  child: Text('Statistics',
                                      style: TextStyle(
                                          color: _selectedTab == 1 ? c.textPrimary : c.textSecondary,
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
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: child,
                        ),
                        child: _selectedTab == 0
                            ? _buildProgressTab(state, profile, pct)
                            : _buildStatisticsTab(state, profile),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 4. Settings & Preferences
                  FadeSlideIn(
                    index: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 8),
                          child: Text('ACCOUNT', style: Theme.of(context).textTheme.labelSmall),
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
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 8),
                          child: Text('PLANNING', style: Theme.of(context).textTheme.labelSmall),
                        ),
                        DarkCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _MenuItem(
                                icon: AppIcons.calendar,
                                label: 'Schedule',
                                sub: 'Set your weekly shift times',
                                color: kGreen,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleScreen())),
                              ),
                              const _CardDivider(),
                              _MenuItem(
                                icon: AppIcons.dateRange,
                                label: 'Calendar',
                                sub: 'Holidays, leave & sick days',
                                color: kAmber,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen())),
                              ),
                              const _CardDivider(),
                              _MenuItem(
                                icon: AppIcons.badge,
                                label: 'Competencies',
                                sub: '${state.completedCompetencies}/${state.totalCompetencies} completed',
                                color: kGreenLight,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompetencyScreen())),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 8),
                          child: Text('PREFERENCES', style: Theme.of(context).textTheme.labelSmall),
                        ),
                        DarkCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _SettingsToggle(
                                icon: AppIcons.lock,
                                label: 'Biometric Lock',
                                sub: 'Unlock with fingerprint or face',
                                value: context.watch<SettingsService>().lockEnabled,
                                color: kGreen,
                                onChanged: (v) => context.read<SettingsService>().setLockEnabled(v),
                              ),
                              if (context.watch<SettingsService>().lockEnabled)
                                Column(
                                  children: [
                                    const _CardDivider(),
                                    _SettingsSelect(
                                      icon: AppIcons.timer,
                                      label: 'Lock Timeout',
                                      sub: '${context.watch<SettingsService>().lockTimeoutSeconds}s after going to background',
                                      color: kAmber,
                                      options: const ['15s', '30s', '1m', '5m'],
                                      values: const [15, 30, 60, 300],
                                      selected: context.watch<SettingsService>().lockTimeoutSeconds,
                                      onChanged: (v) => context.read<SettingsService>().setLockTimeout(v),
                                    ),
                                  ],
                                ),
                              const _CardDivider(),
                              _SettingsSelect(
                                icon: AppIcons.pieChart,
                                label: 'Theme',
                                sub: '${context.watch<SettingsService>().themeMode.name[0].toUpperCase()}${context.watch<SettingsService>().themeMode.name.substring(1)}',
                                color: kGreenLight,
                                options: const ['Light', 'Dark', 'System'],
                                values: const [AppThemeMode.light, AppThemeMode.dark, AppThemeMode.system],
                                selected: context.watch<SettingsService>().themeMode,
                                onChanged: (v) => context.read<SettingsService>().setThemeMode(v),
                              ),
                              const _CardDivider(),
                              _SettingsToggle(
                                icon: AppIcons.notifications,
                                label: 'Reminders',
                                sub: 'Shift reminders & notifications',
                                value: context.watch<SettingsService>().remindersEnabled,
                                color: kGreen,
                                onChanged: (v) {
                                  final s = context.read<AppState>();
                                  context.read<SettingsService>().setRemindersEnabled(v, shifts: s.shifts);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 8),
                          child: Text('DATA & ACTIONS', style: Theme.of(context).textTheme.labelSmall),
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
                                label: 'Export & Backup',
                                sub: 'PDF, CSV, clipboard & data backup',
                                color: kGreenLight,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportScreen())),
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
                    child: Column(
                      children: [
                        TapScale(
                          onTap: () => _confirmLogout(context, state),
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
                        const SizedBox(height: 12),
                        Text('OJT Tracker v1.0.0',
                            style: TextStyle(fontSize: 11, color: c.textMuted)),
                      ],
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
      key: const ValueKey('progress'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('OJT Completion',
                style: Theme.of(context).textTheme.titleSmall),
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
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildStatisticsTab(AppState state, ProfileModel profile) {
    return Column(
      key: const ValueKey('statistics'),
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
    final c = ThemeColors.of(context);
    final nameCtrl = TextEditingController(text: profile.fullName);
    final courseCtrl = TextEditingController(text: profile.course);
    final batchCtrl = TextEditingController(text: profile.batch);
    final hoursCtrl =
        TextEditingController(text: profile.requiredHours.toInt().toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: c.border),
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
                Text('Edit Profile',
                    style: Theme.of(context).textTheme.titleMedium),
                TapScale(
                  onTap: () => Navigator.pop(ctx),
                  child: HitArea(child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration:
                        BoxDecoration(color: c.surface2, borderRadius: kRadiusTag),
                    child: Icon(AppIcons.close,
                        color: c.textSecondary, size: 18),
                  ),
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
                  final parsed = double.tryParse(hoursCtrl.text);
                  if (hoursCtrl.text.isNotEmpty && parsed == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Row(children: [
                        const Icon(AppIcons.warning, color: kAmber, size: 16),
                        const SizedBox(width: 10),
                        Text('Please enter a valid number for required hours',
                            style: TextStyle(color: c.textPrimary)),
                      ]),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: c.surface,
                      shape: RoundedRectangleBorder(
                          borderRadius: kRadiusBtn, side: BorderSide(color: c.border)),
                    ));
                    return;
                  }
                  final updated = profile.copyWith(
                    fullName: nameCtrl.text.trim(),
                    course: courseCtrl.text.trim(),
                    batch: batchCtrl.text.trim(),
                    requiredHours:
                        double.tryParse(hoursCtrl.text) ?? profile.requiredHours,
                  );
                  state.saveProfile(updated);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Row(children: [
                      const Icon(AppIcons.checkCircle, color: kGreen, size: 16),
                      const SizedBox(width: 10),
                      Text('Profile updated', style: TextStyle(color: c.textPrimary)),
                    ]),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: c.surface,
                    shape: RoundedRectangleBorder(
                        borderRadius: kRadiusBtn, side: BorderSide(color: c.border)),
                    duration: const Duration(seconds: 2),
                  ));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                      gradient: kGreenGradient, borderRadius: kRadiusBtn),
                  child: Center(
                    child: Text('Save Changes',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.onAccent)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ).then((_) {
      nameCtrl.dispose();
      courseCtrl.dispose();
      batchCtrl.dispose();
      hoursCtrl.dispose();
    });
  }

  void _showOjtDetails(BuildContext context, AppState state) {
    final profile = state.profile;
    final c = ThemeColors.of(context);
    final companyCtrl = TextEditingController(text: profile.company);
    final supervisorCtrl = TextEditingController(text: profile.supervisor);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: c.border),
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
                Text('OJT Details',
                    style: Theme.of(context).textTheme.titleMedium),
                TapScale(
                  onTap: () => Navigator.pop(ctx),
                  child: HitArea(child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration:
                        BoxDecoration(color: c.surface2, borderRadius: kRadiusTag),
                    child: Icon(AppIcons.close,
                        color: c.textSecondary, size: 18),
                  ),
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Row(children: [
                      const Icon(AppIcons.checkCircle, color: kGreen, size: 16),
                      const SizedBox(width: 10),
                      Text('OJT details updated', style: TextStyle(color: c.textPrimary)),
                    ]),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: c.surface,
                    shape: RoundedRectangleBorder(
                        borderRadius: kRadiusBtn, side: BorderSide(color: c.border)),
                    duration: const Duration(seconds: 2),
                  ));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                      gradient: kGreenGradient, borderRadius: kRadiusBtn),
                  child: Center(
                    child: Text('Save',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.onAccent)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ).then((_) {
      companyCtrl.dispose();
      supervisorCtrl.dispose();
    });
  }

  void _showQrToken(BuildContext context, ProfileModel profile) {
    final c = ThemeColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: c.border),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My QR Token',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Scan this QR code to register on a scanner device.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            Center(
              child: QrImageView(
                data: profile.qrCodeToken,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: kRadiusBtn,
                border: Border.all(color: c.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(profile.qrCodeToken,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: c.textSecondary)),
                  ),
                  TapScale(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: profile.qrCodeToken));
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Row(children: [
                            const Icon(AppIcons.checkCircle, color: kGreen, size: 16),
                            const SizedBox(width: 10),
                            Text('Token copied!', style: TextStyle(color: c.textPrimary)),
                          ]),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: c.surface,
                          shape: RoundedRectangleBorder(
                              borderRadius: kRadiusBtn,
                              side: BorderSide(color: c.border)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: HitArea(child: Container(
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

  void _confirmLogout(BuildContext context, AppState state) {
    final c = ThemeColors.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: kRadiusCard,
          side: BorderSide(color: c.border),
        ),
        title: Text('Log Out', style: Theme.of(context).textTheme.titleMedium),
        content: Text('Are you sure you want to log out?',
            style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: c.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              state.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Log Out', style: TextStyle(color: kRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _InlineStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _InlineStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
          children: [
            Text(value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      );
  }
}

class _InlineDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    return Container(
        width: 1, height: 32, color: c.border,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );
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
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(value,
                style: Theme.of(context).textTheme.labelLarge),
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
  const _Field(
      {required this.controller,
      required this.label,
      required this.icon,
      this.numeric = false});

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    return TextField(
        controller: controller,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: c.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18, color: kGreen),
          filled: true,
          fillColor: c.surface2,
          border: OutlineInputBorder(
              borderRadius: kRadiusInput, borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: kRadiusInput,
              borderSide: BorderSide(color: c.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: kRadiusInput,
              borderSide: const BorderSide(color: kGreen)),
          labelStyle: TextStyle(color: c.textSecondary),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
  }
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
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    return TapScale(
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
                    Text(label, style: Theme.of(context).textTheme.labelLarge),
                    Text(sub,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(AppIcons.chevronRight,
                  color: c.textMuted, size: 20),
            ],
          ),
        ),
      );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    return Divider(height: 1, indent: 60, endIndent: 20, color: c.border);
  }
}

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.icon,
    required this.label,
    required this.sub,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    return Padding(
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
                  Text(label, style: Theme.of(context).textTheme.labelLarge),
                  Text(sub,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            SizedBox(
              height: 28,
              child: Switch.adaptive(
                value: value,
                activeColor: kGreen,
                inactiveThumbColor: c.textSecondary,
                inactiveTrackColor: c.border,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      );
  }
}

class _SettingsSelect extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color color;
  final List<String> options;
  final List<dynamic> values;
  final dynamic selected;
  final ValueChanged<dynamic> onChanged;

  const _SettingsSelect({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.options,
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    return TapScale(
        onTap: () => _showPicker(context),
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
                    Text(label, style: Theme.of(context).textTheme.labelLarge),
                    Text(sub,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(AppIcons.chevronRight, color: c.textMuted, size: 20),
            ],
          ),
        ),
      );
  }

  void _showPicker(BuildContext context) {
    final c = ThemeColors.of(context);
    final idx = values.indexOf(selected);
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: c.border),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: c.border,
                      borderRadius: BorderRadius.circular(2))),
              ...List.generate(options.length, (i) {
                final selected = i == idx;
                return _PickOption(
                  icon: selected ? AppIcons.checkCircle : AppIcons.checkCircleOutline,
                  label: options[i],
                  color: selected ? kGreen : c.textSecondary,
                  onTap: () {
                    onChanged(values[i]);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  final ProfileModel profile;
  final AppState state;
  const _AvatarPicker({required this.profile, required this.state});

  Future<void> _pick(BuildContext context) async {
    final c = ThemeColors.of(context);
    // image_picker not supported on Windows/web — show info instead
    if (!_isMobile) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image picker is only available on mobile devices.',
              style: TextStyle(color: c.textPrimary)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(
              borderRadius: kRadiusBtn, side: BorderSide(color: c.border)),
        ),
      );
      return;
    }
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: c.border),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: c.border, borderRadius: BorderRadius.circular(2))),
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
    final c = ThemeColors.of(context);
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
                : Icon(AppIcons.profile, color: c.textPrimary, size: 36),
          ),
          // Camera badge
          Positioned(
            bottom: -4, right: -4,
            child: Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                color: kGreen,
                shape: BoxShape.circle,
                border: Border.all(color: c.surface, width: 2),
              ),
              child: Icon(AppIcons.camera, size: 14, color: c.onAccent),
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
  Widget build(BuildContext context) {
    return TapScale(
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
              Text(label,
                  style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ),
      );
  }
}
