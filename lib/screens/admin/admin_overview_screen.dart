import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/admin_state.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../login_screen.dart';

class AdminOverviewScreen extends StatefulWidget {
  const AdminOverviewScreen({super.key});

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  void _logout() {
    context.read<AppState>().logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminState>();
    final stats = state.stats;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: state.loading
            ? const Center(child: CircularProgressIndicator(color: kGreen))
            : RefreshIndicator(
                color: kGreen,
                backgroundColor: kSurface,
                onRefresh: () => context.read<AdminState>().load(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      FadeSlideIn(index: 0, child: _buildHeader()),
                      const SizedBox(height: 20),
                      FadeSlideIn(index: 1, child: _buildStatsRow(stats.totalInterns, stats.clockedInNow, stats.avgCompletion)),
                      const SizedBox(height: 24),
                      FadeSlideIn(index: 2, child: _buildActiveNowSection(state)),
                      const SizedBox(height: 24),
                      FadeSlideIn(index: 3, child: _buildTeamProgressSection(state)),
                      const SizedBox(height: 100), // Padding for floating nav bar
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Team Overview',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: kWhite,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 14,
                color: kGrey,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: kRed),
          onPressed: _logout,
          tooltip: 'Logout Admin',
        ),
      ],
    );
  }

  Widget _buildStatsRow(int total, int active, double avgCompletion) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total Interns',
            value: total.toString(),
            icon: Icons.people_rounded,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Active Now',
            value: active.toString(),
            icon: Icons.bolt_rounded,
            color: kGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Avg Compl.',
            value: '${(avgCompletion * 100).toStringAsFixed(1)}%',
            icon: Icons.pie_chart_rounded,
            color: kAmber,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveNowSection(AdminState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Now',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kWhite,
          ),
        ),
        const SizedBox(height: 12),
        DarkCard(
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: kGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: kGreen,
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Active session tracking requires dedicated state. See Timesheet for logs.',
                  style: TextStyle(color: kGrey),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamProgressSection(AdminState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Team Progress',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kWhite,
          ),
        ),
        const SizedBox(height: 12),
        if (state.interns.isEmpty)
          const Text('No interns registered yet.', style: TextStyle(color: kGrey))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.interns.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final intern = state.interns[index];
              final initial = intern.fullName.isNotEmpty ? intern.fullName[0].toUpperCase() : '?';
              return DarkCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: kSurface2,
                      child: Text(initial, style: const TextStyle(color: kWhite)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        intern.fullName,
                        style: const TextStyle(color: kWhite, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: kGrey, size: 20),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DarkCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kWhite,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: kGrey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
