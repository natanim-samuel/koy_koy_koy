import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../budget/screens/budget_screen.dart';
import '../dashboard/screens/dashboard_screen.dart';
import '../transactions/screens/transactions_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  // Goals and Profile screens follow the same pattern as Dashboard/
  // Transactions/Budget above — omitted here to keep this scaffold
  // focused, add them the same way once you're ready.
  static const _screens = [
    DashboardScreen(),
    TransactionsScreen(),
    BudgetScreen(),
    _PlaceholderScreen(title: 'Goals'),
    _PlaceholderScreen(title: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Budget'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goals'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(title), backgroundColor: AppColors.bg),
      body: Center(
        child: Text('$title screen — build this the same way as Dashboard.',
            style: const TextStyle(color: AppColors.textOnDarkSecondary)),
      ),
    );
  }
}