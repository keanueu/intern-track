import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin/admin_shell.dart';
import '../main.dart'; // To import MainContainer

class RoleScreen extends StatelessWidget {
  const RoleScreen({Key? key}) : super(key: key);

  void _enterAsIntern(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainContainer()),
    );
  }

  Future<void> _enterAsAdmin(BuildContext context) async {
    String pin = '';
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          title: const Text('Admin Access', style: TextStyle(color: Colors.white)),
          content: TextField(
            keyboardType: TextInputType.number,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter 4-digit PIN',
              hintStyle: TextStyle(color: Colors.grey),
            ),
            onChanged: (val) => pin = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Enter', style: TextStyle(color: Color(0xFF32D74B))),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final prefs = await SharedPreferences.getInstance();
      final savedPin = prefs.getString('admin_pin') ?? '1234';
      if (pin == savedPin) {
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminShell()),
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid PIN')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hub_rounded, size: 80, color: Color(0xFF32D74B)),
              const SizedBox(height: 16),
              const Text(
                'OJT Tracker',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your role to continue',
                style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 48),
              _buildRoleCard(
                icon: Icons.person_rounded,
                title: 'Continue as Intern',
                subtitle: 'Log hours, view progress, and QR code',
                onTap: () => _enterAsIntern(context),
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                icon: Icons.admin_panel_settings_rounded,
                title: 'Enter as Admin',
                subtitle: 'Manage interns, logs, and reports',
                onTap: () => _enterAsAdmin(context),
                isSecondary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSecondary ? const Color(0xFF2C2C2E) : const Color(0xFF32D74B).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: isSecondary ? null : Border.all(color: const Color(0xFF32D74B), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSecondary ? const Color(0xFF3C3C3E) : const Color(0xFF32D74B).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSecondary ? Colors.white : const Color(0xFF32D74B),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
