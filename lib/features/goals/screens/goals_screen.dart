import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/goals_providers.dart';
import 'add_goal_screen.dart';

final _currency = CurrencyFormatter(locale: 'en_US', currencyCode: 'USD');

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsListProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Savings Goals'),
        backgroundColor: AppColors.lightBg,
        foregroundColor: AppColors.textOnLight,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.lightCard),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddGoalScreen()),
            ),
          ),
        ],
      ),
      body: goals.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('No goals yet — tap + to add one.', style: TextStyle(color: AppColors.textOnLightSecondary)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, i) {
              final goal = items[i];
              final fraction = goal.targetAmount == 0 ? 0.0 : (goal.savedAmount / goal.targetAmount).clamp(0, 1);
              final color = Color(int.parse(goal.colorHex, radix: 16));

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF5F7F6), borderRadius: BorderRadius.circular(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(backgroundColor: color, radius: 18, child: const Icon(Icons.flag, color: Colors.white, size: 18)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text(
                                '${_currency.format(goal.targetAmount)} Goal   ·   ${_currency.format(goal.savedAmount)} Saved',
                                style: const TextStyle(fontSize: 11, color: AppColors.textOnLightSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: fraction.toDouble(),
                              minHeight: 8,
                              backgroundColor: AppColors.trackGray,
                              valueColor: AlwaysStoppedAnimation(color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('${(fraction * 100).round()}%', style: const TextStyle(fontSize: 11, color: AppColors.textOnLightSecondary)),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load goals: $e')),
      ),
    );
  }
}