import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_state.dart';

import '../../theme/app_theme.dart';
import 'admin_directory_screen.dart';
import 'admin_overview_screen.dart';
import 'admin_timesheet_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_approvals_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AdminOverviewScreen(),       // Live Master Overview
    AdminApprovalsScreen(),      // Approvals Queue
    AdminTimesheetScreen(),      // Master Ledger
    AdminDirectoryScreen(),      // Onboarding & Kiosk
    AdminReportsScreen(),        // Reports / Export
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminState>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: AnimatedSwitcher(
        duration: kDurNormal,
        switchInCurve: kCurve,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: _AdminFloatingNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _AdminFloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AdminFloatingNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBg,
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 8),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: kRadiusNav,
          border: Border.all(color: kBorder),
          boxShadow: kCardShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _AdminNavItem(icon: AppIcons.dashboard, outlinedIcon: AppIcons.dashboardOutline, label: 'Overview', index: 0, current: currentIndex, onTap: onTap),
            _AdminNavItem(icon: AppIcons.approvals, outlinedIcon: AppIcons.approvalsOutline, label: 'Approvals', index: 1, current: currentIndex, onTap: onTap),
            _AdminNavItem(icon: AppIcons.table, outlinedIcon: AppIcons.tableOutline, label: 'Ledger', index: 2, current: currentIndex, onTap: onTap),
            _AdminNavItem(icon: AppIcons.people, outlinedIcon: AppIcons.peopleOutline, label: 'Onboarding', index: 3, current: currentIndex, onTap: onTap),
            _AdminNavItem(icon: AppIcons.pdf, outlinedIcon: AppIcons.pdfOutline, label: 'Reports', index: 4, current: currentIndex, onTap: onTap),
          ],
        ),
      ),
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final IconData outlinedIcon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _AdminNavItem({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = current == index;

    return Expanded(
      child: TapScale(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: kDurNormal,
          curve: kCurve,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          decoration: BoxDecoration(
            color: selected ? kSurface2 : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? icon : outlinedIcon,
                color: selected ? kGreen : kGrey,
                size: 22,
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    color: selected ? kWhite : kGrey,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
