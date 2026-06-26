import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/admin_state.dart';
import '../../models/dtr_model.dart';

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
      backgroundColor: const Color(0xFF2C2C2E),
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
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMM d, yyyy').format(log.timeIn),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: Colors.white),
                title: const Text('Edit Log', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: implement log edit dialog
                },
              ),
              if (log.timeOut == null)
                ListTile(
                  leading: const Icon(Icons.timer_off_rounded, color: Colors.amber),
                  title: const Text('Close Session', style: TextStyle(color: Colors.amber)),
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
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Master Timesheet',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All Interns', style: TextStyle(color: Colors.white)),
                          backgroundColor: const Color(0xFF2C2C2E),
                          selectedColor: const Color(0xFF32D74B).withValues(alpha: 0.2),
                          onSelected: (_) {},
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Any Date', style: TextStyle(color: Colors.white)),
                          backgroundColor: const Color(0xFF2C2C2E),
                          selectedColor: const Color(0xFF32D74B).withValues(alpha: 0.2),
                          onSelected: (_) {},
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Anomalies Only', style: TextStyle(color: Colors.amber)),
                          backgroundColor: const Color(0xFF2C2C2E),
                          selectedColor: Colors.amber.withValues(alpha: 0.2),
                          selected: _anomaliesOnly,
                          checkmarkColor: Colors.amber,
                          onSelected: (val) => setState(() => _anomaliesOnly = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (state.anomalies.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_rounded, color: Colors.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${state.anomalies.length} logs need attention',
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _anomaliesOnly = true),
                      child: const Text('View', style: TextStyle(color: Colors.amber)),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: state.loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF32D74B)))
                  : logs.isEmpty
                      ? const Center(
                          child: Text('No logs found.', style: TextStyle(color: Colors.grey)),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          itemCount: logs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            final isAnomaly = log.isAnomaly;
                            return GestureDetector(
                              onTap: () => _showLogActions(context, log),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C2C2E),
                                  borderRadius: BorderRadius.circular(16),
                                  border: isAnomaly ? Border.all(color: Colors.amber) : null,
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
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat('MMM d, yyyy').format(log.timeIn),
                                            style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          log.timeOut == null ? '--- hrs' : '${log.calculatedHours} hrs',
                                          style: TextStyle(
                                            color: log.timeOut == null ? Colors.amber : const Color(0xFF32D74B),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
