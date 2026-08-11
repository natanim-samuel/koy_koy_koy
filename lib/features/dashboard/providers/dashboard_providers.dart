import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/daos/transactions_dao.dart';
import '../../../data/repositories/providers.dart';

final recentTransactionsProvider = StreamProvider<List<TransactionWithCategory>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchRecentTransactions(limit: 5);
});

/// Current month's earned / spent totals, recomputed whenever
/// transactions change (via the underlying Drift stream invalidation).
final monthlyStatsProvider = FutureProvider<({double earned, double spent})>((ref) async {
  final repo = ref.watch(expenseRepositoryProvider);
  final now = DateTime.now();
  final earned = await repo.totalIncomeForMonth(now);
  final spent = await repo.totalExpensesForMonth(now);
  return (earned: earned, spent: spent);
});