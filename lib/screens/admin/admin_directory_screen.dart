import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_state.dart';
import '../../models/profile_model.dart';
import '../../theme/app_theme.dart';
import 'package:uuid/uuid.dart';
import 'admin_kiosk_screen.dart';

class AdminDirectoryScreen extends StatelessWidget {
  const AdminDirectoryScreen({super.key});

  void _showAddInternDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Register New Intern', style: TextStyle(color: kWhite, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: kWhite),
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: kGrey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kGreen)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                style: const TextStyle(color: kWhite),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(color: kGrey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kGreen)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordCtrl,
                style: const TextStyle(color: kWhite),
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: kGrey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kGreen)),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty) return;
                  
                  final newIntern = ProfileModel(
                    id: const Uuid().v4(),
                    fullName: nameCtrl.text.trim(),
                    course: 'Intern',
                    batch: '',
                    company: 'Not set',
                    supervisor: 'Not set',
                    qrCodeToken: const Uuid().v4(),
                    requiredHours: 486,
                    startDate: DateTime.now().toIso8601String(),
                    email: emailCtrl.text.trim(),
                    password: passwordCtrl.text.trim(),
                    role: 'intern',
                  );

                  context.read<AdminState>().registerIntern(newIntern);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: kRadiusBtn),
                ),
                child: const Text('Register Intern', style: TextStyle(color: kBg, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text(
                        'Onboarding & Kiosk',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: kWhite,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminKioskScreen())),
                      icon: const Icon(Icons.qr_code_scanner_rounded, color: kGreen, size: 20),
                      label: const Text('Kiosk', style: TextStyle(color: kGreen, fontWeight: FontWeight.w600)),
                      style: TextButton.styleFrom(
                        backgroundColor: kGreen.withValues(alpha: 0.1),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: kRadiusBtn),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Consumer<AdminState>(
                builder: (context, state, child) {
                  if (state.loading) return const Center(child: CircularProgressIndicator(color: kGreen));

                  if (state.interns.isEmpty) {
                    return const Center(child: Text('No interns registered yet.', style: TextStyle(color: kGrey)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                    itemCount: state.interns.length,
                    itemBuilder: (context, index) {
                      final intern = state.interns[index];
                      return FadeSlideIn(
                        index: index.clamp(0, 5) + 1,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: DarkCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: kSurface2,
                                  child: Text(intern.fullName[0].toUpperCase(), style: const TextStyle(color: kWhite, fontWeight: FontWeight.w700)),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(intern.fullName, style: const TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 4),
                                      Text(intern.email.isEmpty ? 'No email' : intern.email, style: const TextStyle(color: kGrey, fontSize: 13)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: kRed),
                                  onPressed: () => state.deleteIntern(intern.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Above floating nav bar
        child: FloatingActionButton(
          onPressed: () => _showAddInternDialog(context),
          backgroundColor: kGreen,
          elevation: 4,
          child: const Icon(Icons.person_add_rounded, color: kBg),
        ),
      ),
    );
  }
}
