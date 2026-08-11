import 'package:drift/drift.dart';

import '../database.dart';

part 'transactions_dao.g.dart';

/// Spend total for one category over a date range — powers the Budget
/// and Analytics screens without pulling every transaction row client-side.
class CategorySpend {
  CategorySpend({required this.categoryId, required this.total});
  final int categoryId;
  final double total;
}

@DriftAccessor(tables: [Transactions, Categories, Accounts])
class TransactionsDao extends DatabaseAccessor<AppDatabase> with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  /// Recent transactions newest-first, joined with category for display.
  Stream<List<TransactionWithCategory>> watchRecent({int limit = 20}) {
    final query = select(transactions).join([
      leftOuterJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])
      ..orderBy([OrderingTerm.desc(transactions.date)])
      ..limit(limit);

    return query.watch().map(
          (rows) => rows
          .map((row) => TransactionWithCategory(
        transaction: row.readTable(transactions),
        category: row.readTableOrNull(categories),
      ))
          .toList(),
    );
  }

  /// Same as [watchRecent] but filtered by 'expense' | 'income'.
  Stream<List<TransactionWithCategory>> watchByType(String type) {
    final query = select(transactions).join([
      leftOuterJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])
      ..where(transactions.type.equals(type))
      ..orderBy([OrderingTerm.desc(transactions.date)]);

    return query.watch().map(
          (rows) => rows
          .map((row) => TransactionWithCategory(
        transaction: row.readTable(transactions),
        category: row.readTableOrNull(categories),
      ))
          .toList(),
    );
  }

  /// Sum of expenses per category within [start, end) — feeds the
  /// Budget progress bars and the Analytics donut chart.
  Future<List<CategorySpend>> spendByCategory({
    required DateTime start,
    required DateTime end,
  }) async {
    final totalExpr = transactions.amount.sum();
    final query = selectOnly(transactions)
      ..addColumns([transactions.categoryId, totalExpr])
      ..where(transactions.type.equals('expense') &
      transactions.date.isBiggerOrEqualValue(start) &
      transactions.date.isSmallerThanValue(end))
      ..groupBy([transactions.categoryId]);

    final rows = await query.get();
    return rows
        .where((r) => r.read(transactions.categoryId) != null)
        .map((r) => CategorySpend(
      categoryId: r.read(transactions.categoryId)!,
      total: r.read(totalExpr) ?? 0,
    ))
        .toList();
  }

  Future<double> totalForType({
    required String type,
    required DateTime start,
    required DateTime end,
  }) async {
    final totalExpr = transactions.amount.sum();
    final query = selectOnly(transactions)
      ..addColumns([totalExpr])
      ..where(transactions.type.equals(type) &
      transactions.date.isBiggerOrEqualValue(start) &
      transactions.date.isSmallerThanValue(end));
    final row = await query.getSingle();
    return row.read(totalExpr) ?? 0;
  }

  Future<int> addTransaction(TransactionsCompanion entry) =>
      into(transactions).insert(entry);

  Future<bool> updateTransaction(TransactionsCompanion entry) =>
      update(transactions).replace(entry);

  Future<int> deleteTransaction(int id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();
}

class TransactionWithCategory {
  TransactionWithCategory({required this.transaction, required this.category});
  final Transaction transaction;
  final Category? category;
}