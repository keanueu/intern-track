import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  int _selectedTab = 0;
  bool _busy = false;

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    final c = ThemeColors.of(context);
    final ts = Theme.of(context).textTheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(error ? AppIcons.warning : AppIcons.checkCircle,
              color: error ? c.error : c.accent, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: ts.bodyMedium)),
        ]),
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.surface,
      ),
    );
  }

  Future<void> _exportPdf(AppState state) async {
    if (state.logs.isEmpty) {
      _showSnack('No DTR logs to export.', error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await ExportService.instance.sharePdf(
        state.profile, state.logs, state.totalHours, state.daysPresent,
      );
      _showSnack('PDF generated');
    } catch (e) {
      _showSnack('Failed to generate PDF: $e', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _exportCsv(AppState state) async {
    if (state.logs.isEmpty) {
      _showSnack('No DTR logs to export.', error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await ExportService.instance.saveCsv(state.profile, state.logs);
      _showSnack('CSV exported');
    } catch (e) {
      _showSnack('Failed to export CSV: $e', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _exportText(AppState state) async {
    if (state.logs.isEmpty) {
      _showSnack('No DTR logs to export.', error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      final text = ExportService.instance.generateTextReport(
        state.profile, state.logs, state.totalHours, state.daysPresent,
        state.remainingHours, state.completionPercent,
      );
      await Clipboard.setData(ClipboardData(text: text));
      _showSnack('Report copied to clipboard');
    } catch (e) {
      _showSnack('Failed to generate report: $e', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _exportBackup() async {
    setState(() => _busy = true);
    try {
      final msg = await ExportService.instance.exportBackup();
      _showSnack(msg, error: msg.contains('error') || msg.contains('cancelled'));
    } catch (e) {
      _showSnack('Backup failed: $e', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  void _confirmImport() {
    final c = ThemeColors.of(context);
    final ts = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: c.surface,
        shape: const RoundedRectangleBorder(borderRadius: kRadiusCard),
        title: Row(
          children: [
            Icon(AppIcons.warning, color: c.error, size: 24),
            const SizedBox(width: 8),
            Text('Import Backup?', style: ts.titleLarge),
          ],
        ),
        content: Text(
          'Importing a backup will replace all current data. This action cannot be undone.',
          style: ts.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: ts.labelLarge),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _importBackup();
            },
            child: Text('Import', style: ts.labelLarge?.copyWith(color: c.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _importBackup() async {
    setState(() => _busy = true);
    try {
      final msg = await ExportService.instance.importBackup();
      _showSnack(msg, error: msg.contains('error') || msg.contains('cancelled') || msg.contains('Invalid'));
    } catch (e) {
      _showSnack('Import failed: $e', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final c = ThemeColors.of(context);
        final ts = Theme.of(context).textTheme;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: c.bg,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: TapScale(
              onTap: () => Navigator.pop(context),
              child: Icon(AppIcons.chevronLeft, color: c.textPrimary),
            ),
            title: Text('Export & Backup', style: ts.titleLarge),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(color: c.surface2, borderRadius: kRadiusBtn),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _tabBtn(label: 'Export', index: 0, c: c, ts: ts),
                      _tabBtn(label: 'Backup', index: 1, c: c, ts: ts),
                    ],
                  ),
                ),

                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: _selectedTab == 0 ? _buildExportTab(state, c, ts) : _buildBackupTab(c, ts),
                      ),
                      if (_busy)
                        Container(
                          color: c.bg.withValues(alpha: 0.6),
                          child: Center(
                            child: CircularProgressIndicator(color: c.accent),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tabBtn({required String label, required int index, required ThemeColors c, required TextTheme ts}) {
    final selected = _selectedTab == index;
    return Expanded(
      child: AbsorbPointer(
        absorbing: _busy,
        child: TapScale(
          onTap: () => setState(() => _selectedTab = index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: selected ? c.surface : Colors.transparent,
              borderRadius: kRadiusTag,
              boxShadow: selected ? [BoxShadow(color: c.shadowColor, blurRadius: 4)] : null,
            ),
            child: Center(
              child: Text(label, style: ts.labelLarge?.copyWith(
                  color: selected ? c.textPrimary : c.textSecondary)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExportTab(AppState state, ThemeColors c, TextTheme ts) {
    if (state.logs.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 40),
          Icon(AppIcons.pdf, color: c.textMuted, size: 48),
          const SizedBox(height: 16),
          Text('No data to export', style: ts.titleSmall),
          const SizedBox(height: 8),
          Text('Record some time entries first.', style: ts.bodySmall),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeSlideIn(
          index: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Generate Reports', style: ts.titleSmall),
              const SizedBox(height: 4),
              Text('Export your DTR in multiple formats', style: ts.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FadeSlideIn(
          index: 1,
          child: _ExportCard(
            icon: AppIcons.pdf,
            label: 'PDF Report',
            sub: 'Professional DTR with table, summary & signatures',
            color: c.error,
            onTap: () => _exportPdf(state),
          ),
        ),
        const SizedBox(height: 10),
        FadeSlideIn(
          index: 2,
          child: _ExportCard(
            icon: AppIcons.download,
            label: 'CSV File',
            sub: 'Spreadsheet-compatible format (.csv)',
            color: c.accent,
            onTap: () => _exportCsv(state),
          ),
        ),
        const SizedBox(height: 10),
        FadeSlideIn(
          index: 3,
          child: _ExportCard(
            icon: AppIcons.copy,
            label: 'Text (Clipboard)',
            sub: 'Copy plain text report to clipboard',
            color: c.warning,
            onTap: () => _exportText(state),
          ),
        ),
      ],
    );
  }

  Widget _buildBackupTab(ThemeColors c, TextTheme ts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeSlideIn(
          index: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Data Backup', style: ts.titleSmall),
              const SizedBox(height: 4),
              Text('Export or import all your data', style: ts.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 20),

        FadeSlideIn(
          index: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: kRadiusCard,
              border: Border.all(color: c.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(AppIcons.wifiOff, color: c.accent, size: 20),
                    const SizedBox(width: 10),
                    Text('Offline Backup', style: ts.titleSmall),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'All data is stored locally on your device. '
                  'Use backup to transfer data between devices or keep a safe copy.',
                  style: ts.bodySmall?.copyWith(height: 1.4),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: AbsorbPointer(
                    absorbing: _busy,
                    child: TapScale(
                      onTap: _exportBackup,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: const BoxDecoration(gradient: kGreenGradient, borderRadius: kRadiusBtn),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(AppIcons.download, color: c.onAccent, size: 18),
                            const SizedBox(width: 8),
                            Text('Export Backup', style: ts.labelLarge?.copyWith(color: c.onAccent)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: AbsorbPointer(
                    absorbing: _busy,
                    child: TapScale(
                      onTap: _confirmImport,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: c.surface2,
                          borderRadius: kRadiusBtn,
                          border: Border.all(color: c.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(AppIcons.download, color: c.accent, size: 18),
                            const SizedBox(width: 8),
                            Text('Import Backup', style: ts.labelLarge),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        FadeSlideIn(
          index: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.errorLight,
              borderRadius: kRadiusCard,
              border: Border.all(color: c.error.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(AppIcons.warning, color: c.error, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Importing a backup will replace all current data.',
                    style: ts.bodySmall?.copyWith(color: c.error),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ExportCard extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color color;
  final VoidCallback onTap;

  const _ExportCard({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    final ts = Theme.of(context).textTheme;
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: kRadiusCard,
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: kRadiusTag,
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: ts.titleSmall),
                  const SizedBox(height: 2),
                  Text(sub, style: ts.labelSmall),
                ],
              ),
            ),
            Icon(AppIcons.download, color: c.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
