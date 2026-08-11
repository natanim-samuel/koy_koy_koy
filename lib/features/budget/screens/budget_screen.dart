import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/local/database.dart';
import '../../../data/repositories/providers.dart';

final _currency = CurrencyFormatter(locale: 'en_US', currencyCode: 'USD');

/// Threshold at which the budget-alert "smart" feature should fire a
/// notification. Kept here (not buried in a widget) so the same constant
/// can be reused by a background notification job.
const double budgetAlertThreshold = 0.8;

final _budgetUsageProvider = FutureProvider<Map<Category, double>>((ref) {
  return ref.watch(expenseRepositoryProvider).budgetUsageForMonth(DateTime.now());
});

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.watch(_budgetUsageProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(title: const Text('Budget'), backgroundColor: AppColors.lightBg, foregroundColor: AppColors.textOnLight),
      body: usage.when(
        data: (map) {
          final entries = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              final category = entries[i].key;
              final fraction = entries[i].value;
              final color = AppColors.forCategory(category.name);
              final overBudget = fraction >= 1.0;
              final nearLimit = fraction >= budgetAlertThreshold;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(backgroundColor: color, radius: 10),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      Text(
                        '${_currency.format(fraction * category.monthlyBudget)} / ${_currency.format(category.monthlyBudget)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textOnLightSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fraction.clamp(0, 1),
                      minHeight: 8,
                      backgroundColor: AppColors.trackGray,
                      valueColor: AlwaysStoppedAnimation(overBudget ? AppColors.coral : color),
                    ),
                  ),
                  if (nearLimit)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        overBudget ? 'Over budget for this category.' : "You've used ${(fraction * 100).toStringAsFixed(0)}% of this budget.",
                        style: TextStyle(fontSize: 11, color: overBudget ? AppColors.coral : AppColors.catAmber, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load budgets: $e')),
      ),
    );
  }
}