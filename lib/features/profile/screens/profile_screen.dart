import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const rows = [
      (icon: Icons.person_outline, label: 'Personal Information'),
      (icon: Icons.payment, label: 'Payment Methods'),
      (icon: Icons.tune, label: 'Preferences'),
      (icon: Icons.security, label: 'Security'),
      (icon: Icons.help_outline, label: 'Help & Support'),
      (icon: Icons.info_outline, label: 'About App'),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 12),
            const Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.card,
                child: Text('J', style: TextStyle(color: AppColors.mint, fontSize: 28, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 14),
            const Center(
              child: Text('Jackson', style: TextStyle(color: AppColors.textOnDark, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text('jackson@example.com', style: TextStyle(color: AppColors.textOnDarkSecondary, fontSize: 12)),
            ),
            const SizedBox(height: 24),
            ...rows.map(
                  (r) => ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.card, child: Icon(r.icon, color: AppColors.textOnDark, size: 18)),
                title: Text(r.label, style: const TextStyle(color: AppColors.textOnDark, fontSize: 14)),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textOnDarkMuted),
                onTap: () {
                  // Hook up to a real sub-screen when it exists — same
                  // pattern as AddGoalScreen: push a MaterialPageRoute.
                },
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                // Wire up to your auth/session logic.
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.coral,
                side: const BorderSide(color: AppColors.coral),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}