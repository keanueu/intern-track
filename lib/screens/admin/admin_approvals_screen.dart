import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/admin_state.dart';
import '../../theme/app_theme.dart';
import '../../models/dtr_model.dart';

class AdminApprovalsScreen extends StatelessWidget {
  const AdminApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        title: const Text('Approvals Queue', style: TextStyle(color: kWhite, fontWeight: FontWeight.w700)),
        centerTitle: false,
      ),
      body: Consumer<AdminState>(
        builder: (context, state, child) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator(color: kGreen));
          }

          final pendingLogs = state.pendingLogs;

          if (pendingLogs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingLogs.length,
            itemBuilder: (context, index) {
              final log = pendingLogs[index];
              return _buildApprovalCard(context, log, state);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(AppIcons.checkCircleOutline, size: 64, color: kGrey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: kWhite.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No pending logs require approval.',
            style: TextStyle(color: kGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalCard(BuildContext context, DtrLog log, AdminState state) {
    final dateStr = DateFormat('MMM d, yyyy').format(log.timeIn);
    final inStr = DateFormat('h:mm a').format(log.timeIn);
    final outStr = log.timeOut != null ? DateFormat('h:mm a').format(log.timeOut!) : 'Ongoing';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                log.internName ?? 'Unknown Intern',
                style: const TextStyle(
                  color: kWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(AppIcons.calendar, size: 14, color: kGrey),
              const SizedBox(width: 6),
              Text(dateStr, style: const TextStyle(color: kGrey, fontSize: 13)),
              const Spacer(),
              Text('$inStr — $outStr', style: const TextStyle(color: kWhite, fontSize: 13)),
            ],
          ),
          if (log.timeOut != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Logged: ${log.calculatedHours} hrs',
                  style: const TextStyle(color: kGreen, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => state.updateLogStatus(log.id, 'rejected'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF453A),
                    side: const BorderSide(color: Color(0xFFFF453A)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => state.updateLogStatus(log.id, 'approved'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    foregroundColor: kWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
