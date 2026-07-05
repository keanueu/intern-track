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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(error ? AppIcons.warning : AppIcons.checkCircle,
              color: error ? kRed : kGreen, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: TextStyle(color: c.textPrimary))),
        ]),
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: kRadiusBtn, side: BorderSide(color: c.border)),
      ),
    );
  }

  Future<void> _exportPdf(AppState state) async {
    setState(() => _busy = true);
    try {
      await ExportService.instance.sharePdf(
        state.profile,
        state.logs,
        state.totalHours,
        state.daysPresent,
      );
      _showSnack('PDF generated');
    } catch (e) {
      _showSnack('Failed to generate PDF: $e', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _exportCsv(AppState state) async {
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
    final text = ExportService.instance.generateTextReport(
      state.profile,
      state.logs,
      state.totalHours,
      state.daysPresent,
      state.remainingHours,
      state.completionPercent,
    );
    await Clipboard.setData(ClipboardData(text: text));
    _showSnack('Report copied to clipboard');
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
        return Scaffold(
          backgroundColor: c.bg,
          appBar: AppBar(
            backgroundColor: c.bg,
            elevation: 0,
            leading: TapScale(
              onTap: () => Navigator.pop(context),
              child: Icon(AppIcons.chevronLeft, color: c.textPrimary),
            ),
            title: Text('Export & Backup',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.textPrimary)),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Tab bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: c.surface2,
                    borderRadius: kRadiusBtn,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _tabBtn(label: 'Export', index: 0),
                      _tabBtn(label: 'Backup', index: 1),
                    ],
                  ),
                ),

                if (_busy)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator(color: kGreen)),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: _selectedTab == 0 ? _buildExportTab(state) : _buildBackupTab(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tabBtn({required String label, required int index}) {
    final selected = _selectedTab == index;
    final c = ThemeColors.of(context);
    return Expanded(
      child: TapScale(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? c.surface : Colors.transparent,
            borderRadius: kRadiusTag,
            boxShadow: selected ? const [BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selected ? c.textPrimary : c.textSecondary)),
          ),
        ),
      ),
    );
  }

  Widget _buildExportTab(AppState state) {
    final c = ThemeColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Generate Reports',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.textPrimary)),
        const SizedBox(height: 4),
        Text('Export your DTR in multiple formats',
            style: TextStyle(fontSize: 12, color: c.textSecondary)),
        const SizedBox(height: 20),

        _ExportCard(
          icon: AppIcons.pdf,
          label: 'PDF Report',
          sub: 'Professional DTR with table, summary & signatures',
          color: kRed,
          onTap: () => _exportPdf(state),
        ),
        const SizedBox(height: 10),
        _ExportCard(
          icon: AppIcons.download,
          label: 'CSV File',
          sub: 'Spreadsheet-compatible format (.csv)',
          color: kGreen,
          onTap: () => _exportCsv(state),
        ),
        const SizedBox(height: 10),
        _ExportCard(
          icon: AppIcons.copy,
          label: 'Text (Clipboard)',
          sub: 'Copy plain text report to clipboard',
          color: kAmber,
          onTap: () => _exportText(state),
        ),
      ],
    );
  }

  Widget _buildBackupTab() {
    final c = ThemeColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Data Backup',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.textPrimary)),
        const SizedBox(height: 4),
        Text('Export or import all your data',
            style: TextStyle(fontSize: 12, color: c.textSecondary)),
        const SizedBox(height: 20),

        Container(
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
                  const Icon(AppIcons.wifiOff, color: kGreen, size: 20),
                  const SizedBox(width: 10),
                  Text('Offline Backup',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.textPrimary)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'All data is stored locally on your device. '
                'Use backup to transfer data between devices or keep a safe copy.',
                style: TextStyle(fontSize: 12, color: c.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TapScale(
                  onTap: _exportBackup,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: kGreenGradient,
                      borderRadius: kRadiusBtn,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(AppIcons.download, color: c.onAccent, size: 18),
                        const SizedBox(width: 8),
                        Text('Export Backup',
                            style: TextStyle(color: c.onAccent, fontWeight: FontWeight.w700, fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TapScale(
                  onTap: _importBackup,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: c.surface2,
                      borderRadius: kRadiusBtn,
                      border: Border.all(color: c.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(AppIcons.download, color: kGreenLight, size: 18),
                        const SizedBox(width: 8),
                        Text('Import Backup',
                            style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kRed.withValues(alpha: 0.05),
            borderRadius: kRadiusCard,
            border: Border.all(color: kRed.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(AppIcons.warning, color: kRed, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Importing a backup will replace all current data.',
                  style: TextStyle(fontSize: 12, color: kRed.withValues(alpha: 0.8)),
                ),
              ),
            ],
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
                Text(label,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.textPrimary)),
                const SizedBox(height: 2),
                Text(sub, style: TextStyle(fontSize: 11, color: c.textSecondary)),
              ],
            ),
          ),
          Icon(AppIcons.chevronRight, color: c.textMuted, size: 20),
        ],
      ),
    ),
  );
  }
}
