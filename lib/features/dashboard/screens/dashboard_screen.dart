import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../add_expense/screens/add_expense_screen.dart';
import '../providers/dashboard_providers.dart';

final _currency = CurrencyFormatter(locale: 'en_US', currencyCode: 'USD');

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentTx = ref.watch(recentTransactionsProvider);
    final stats = ref.watch(monthlyStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.lightCard,
                  child: Text('J', style: TextStyle(color: AppColors.mint, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome,', style: TextStyle(color: AppColors.textOnLightSecondary, fontSize: 12)),
                    Text('Jackson', style: TextStyle(color: AppColors.textOnLight, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _BalanceCard(stats: stats.value),
            const SizedBox(height: 24),
            const Text('Quick Actions', style: TextStyle(color: AppColors.textOnLight, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            _QuickActionsRow(
              onAddExpense: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddExpenseScreen(type: 'expense')),
              ),
              onAddIncome: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddExpenseScreen(type: 'income')),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Recent Transactions', style: TextStyle(color: AppColors.textOnLight, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            recentTx.when(
              data: (items) => Column(
                children: items.map((item) {
                  final tx = item.transaction;
                  final isIncome = tx.type == 'income';
                  final color = AppColors.forCategory(item.category?.name ?? '');
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(backgroundColor: color, radius: 16),
                    title: Text(tx.note.isEmpty ? (item.category?.name ?? 'Transaction') : tx.note,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(item.category?.name ?? 'Uncategorized',
                        style: const TextStyle(color: AppColors.textOnLightSecondary, fontSize: 11)),
                    trailing: Text(
                      _currency.formatSigned(tx.amount, isIncome: isIncome),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isIncome ? AppColors.catGreen : AppColors.textOnLight,
                      ),
                    ),
                  );
                }).toList(),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('Could not load transactions: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.stats});
  final ({double earned, double spent})? stats;

  @override
  Widget build(BuildContext context) {
    final earned = stats?.earned ?? 0;
    final spent = stats?.spent ?? 0;
    final available = 50000.90; // demo seed balance; wire to Accounts sum in production
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.lightCard, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TOTAL BALANCE', style: TextStyle(color: AppColors.textOnDarkSecondary, fontSize: 11, letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(_currency.format(available), style: const TextStyle(color: AppColors.textOnDark, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat(label: 'Earned', value: _currency.format(earned)),
              _Stat(label: 'Spent', value: _currency.format(spent)),
              _Stat(label: 'Saved', value: _currency.format(available - spent)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textOnDarkSecondary, fontSize: 10)),
        Text(value, style: const TextStyle(color: AppColors.textOnDark, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.onAddExpense, required this.onAddIncome});
  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (icon: Icons.add, label: 'Add Expense', color: AppColors.catRed, onTap: onAddExpense),
      (icon: Icons.add, label: 'Add Income', color: AppColors.catGreen, onTap: onAddIncome),
      (icon: Icons.swap_horiz, label: 'Transfer', color: AppColors.catAmber, onTap: () {}),
      (icon: Icons.qr_code_scanner, label: 'Scan Receipt', color: AppColors.catPurple, onTap: () {}),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) {
        return Column(
          children: [
            InkWell(
              onTap: a.onTap,
              customBorder: const CircleBorder(),
              child: CircleAvatar(radius: 22, backgroundColor: a.color, child: Icon(a.icon, color: Colors.white, size: 20)),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 64,
              child: Text(a.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppColors.textOnLightSecondary)),
            ),
          ],
        );
      }).toList(),
    );
  }
}