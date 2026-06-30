import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/admin_state.dart';
import '../../models/dtr_model.dart';
import '../../theme/app_theme.dart';

class AdminTimesheetScreen extends StatefulWidget {
  const AdminTimesheetScreen({super.key});

  @override
  State<AdminTimesheetScreen> createState() => _AdminTimesheetScreenState();
}

class _AdminTimesheetScreenState extends State<AdminTimesheetScreen> {
  bool _anomaliesOnly = false;

  void _showLogActions(BuildContext context, DtrLog log) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                log.internName ?? 'Unknown Intern',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kWhite),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMM d, yyyy').format(log.timeIn),
                style: const TextStyle(color: kGrey),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(AppIcons.edit, color: kWhite),
                title: const Text('Edit Log', style: TextStyle(color: kWhite)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: implement log edit dialog
                },
              ),
              if (log.timeOut == null)
                ListTile(
                  leading: const Icon(AppIcons.timerOff, color: kAmber),
                  title: const Text('Close Session', style: TextStyle(color: kAmber)),
                  onTap: () async {
                    Navigator.pop(context);
                    await context.read<AdminState>().closeOrphanedLog(log.id, DateTime.now());
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
    final state = context.watch<AdminState>();
    final logs = _anomaliesOnly ? state.anomalies : state.allLogs;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: FadeSlideIn(
                index: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Master Timesheet',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: kWhite,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('All Interns', style: TextStyle(color: kWhite)),
                            backgroundColor: kSurface,
                            selectedColor: kGreen.withValues(alpha: 0.2),
                            onSelected: (_) {},
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: kBorder)),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Any Date', style: TextStyle(color: kWhite)),
                            backgroundColor: kSurface,
                            selectedColor: kGreen.withValues(alpha: 0.2),
                            onSelected: (_) {},
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: kBorder)),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Anomalies Only', style: TextStyle(color: kAmber)),
                            backgroundColor: kSurface,
                            selectedColor: kAmber.withValues(alpha: 0.2),
                            selected: _anomaliesOnly,
                            checkmarkColor: kAmber,
                            onSelected: (val) => setState(() => _anomaliesOnly = val),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: _anomaliesOnly ? kAmber : kBorder)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (state.anomalies.isNotEmpty)
              FadeSlideIn(
                index: 1,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kAmber.withValues(alpha: 0.1),
                    borderRadius: kRadiusCard,
                    border: Border.all(color: kAmber.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(AppIcons.warning, color: kAmber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${state.anomalies.length} logs need attention',
                          style: const TextStyle(color: kAmber, fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _anomaliesOnly = true),
                        child: const Text('View', style: TextStyle(color: kAmber)),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: state.loading
                  ? const Center(child: CircularProgressIndicator(color: kGreen))
                  : logs.isEmpty
                      ? const Center(
                          child: Text('No logs found.', style: TextStyle(color: kGrey)),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 100),
                          itemCount: logs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            final isAnomaly = log.isAnomaly;
                            return FadeSlideIn(
                              index: index.clamp(0, 5) + 2,
                              child: DarkCard(
                                padding: const EdgeInsets.all(16),
                                onTap: () => _showLogActions(context, log),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: isAnomaly ? Border.all(color: kAmber, width: 1.5) : null,
                                    borderRadius: isAnomaly ? kRadiusCard : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              log.internName ?? 'Unknown Intern',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: kWhite,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              DateFormat('MMM d, yyyy').format(log.timeIn),
                                              style: const TextStyle(color: kGrey, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${DateFormat('h:mm a').format(log.timeIn)} - '
                                            '${log.timeOut != null ? DateFormat('h:mm a').format(log.timeOut!) : 'Ongoing'}',
                                            style: const TextStyle(color: kWhite, fontSize: 14),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            log.timeOut == null ? '--- hrs' : '${log.calculatedHours.toStringAsFixed(2)} hrs',
                                            style: TextStyle(
                                              color: log.timeOut == null ? kAmber : kGreen,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
