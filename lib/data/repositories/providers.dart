import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/database.dart';
import 'expense_repository.dart';

/// Single [AppDatabase] instance for the app's lifetime.
/// `keepAlive: true` because closing/reopening the sqlite connection
/// mid-session would be wasteful and isn't needed here.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.watch(databaseProvider));
});