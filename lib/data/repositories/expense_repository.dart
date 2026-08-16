import 'package:drift/drift.dart' show Value;

import '../../core/utils/auto_categorizer.dart';
import '../local/daos/transactions_dao.dart';
import '../local/database.dart';

/// The single entry point features go through to read/write expense
/// data. Keeping this as a facade (rather than having widgets talk to
/// DAOs directly) means the "smart" behavior — auto-categorization,
/// budget-alert thresholds — lives in one testable place.
class ExpenseRepository {
  ExpenseRepository(this._db, {AutoCategorizer? categorizer})
      : _categorizer = categorizer ?? AutoCategorizer();

  final AppDatabase _db;
  final AutoCategorizer _categorizer;

  Stream<List<TransactionWithCategory>> watchRecentTransactions({int limit = 20}) =>
      _db.transactionsDao.watchRecent(limit: limit);

  Stream<List<TransactionWithCategory>> watchTransactionsByType(String type) =>
      _db.transactionsDao.watchByType(type);

  Stream<List<Category>> watchCategories() => _db.categoriesDao.watchAll();

  Stream<List<Goal>> watchGoals() => _db.goalsDao.watchAll();

  /// Suggests a category id for [note] using [AutoCategorizer], falling
  /// back to null (caller shows "Uncategorized") if nothing matches.
  Future<int?> suggestCategory(String note) async {
    final name = _categorizer.categorize(note);
    if (name == null) return null;
    final category = await _db.categoriesDao.findByName(name);
    return category?.id;
  }

  /// Adds a transaction. If [categoryId] is omitted, runs the note
  /// through [suggestCategory] first — this is what makes "Add
  /// Transaction" feel smart without the person picking a category.
  Future<void> addTransaction({
    required double amount,
    required String type, // 'expense' | 'income'
    required DateTime date,
    String note = '',
    int? categoryId,
    int? accountId,
    bool isRecurring = false,
  }) async {
    final resolvedCategoryId = categoryId ?? await suggestCategory(note);
    await _db.transactionsDao.addTransaction(
      TransactionsCompanion.insert(
        amount: amount,
        type: type,
        date: date,
        note: Value(note),
        categoryId: Value(resolvedCategoryId),
        accountId: Value(accountId),
        isRecurring: Value(isRecurring),
      ),
    );
  }

  Future<void> deleteTransaction(int id) => _db.transactionsDao.deleteTransaction(id);

  /// Budget usage per category for the given month, as a fraction
  /// (0.0–1.0+) of each category's `monthlyBudget`. Values above 1.0
  /// mean the category is over budget — this is what should drive a
  /// budget-alert notification once a push layer is wired up.
  Future<Map<Category, double>> budgetUsageForMonth(DateTime month) async {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);

    final categories = await _db.categoriesDao.watchAll().first;
    final spend = await _db.transactionsDao.spendByCategory(start: start, end: end);
    final spendByCategoryId = {for (final s in spend) s.categoryId: s.total};

    return {
      for (final c in categories)
        if (c.monthlyBudget > 0) c: (spendByCategoryId[c.id] ?? 0) / c.monthlyBudget,
    };
  }

  Future<double> totalExpensesForMonth(DateTime month) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    return _db.transactionsDao.totalForType(type: 'expense', start: start, end: end);
  }

  Future<double> totalIncomeForMonth(DateTime month) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    return _db.transactionsDao.totalForType(type: 'income', start: start, end: end);
  }
}

Future<void> addGoal({
  required String name,
  required double targetAmount,
  required DateTime startDate,
  required DateTime targetDate,
  String colorHex = 'FF1FAE8E',
}) {
  return _db.goalsDao.addGoal(
    GoalsCompanion.insert(
      name: name,
      targetAmount: targetAmount,
      startDate: startDate,
      targetDate: targetDate,
      colorHex: Value(colorHex),
    ),
  );
}

Future<void> contributeToGoal(int goalId, double amount) =>
    _db.goalsDao.contribute(goalId, amount);