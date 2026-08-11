import 'package:drift/drift.dart';

import '../database.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Stream<List<Category>> watchAll() => select(categories).watch();

  Future<Category?> findByName(String name) =>
      (select(categories)..where((c) => c.name.equals(name))).getSingleOrNull();

  Future<int> upsert(CategoriesCompanion entry) => into(categories).insertOnConflictUpdate(entry);

  Future<void> updateBudget(int categoryId, double monthlyBudget) {
    return (update(categories)..where((c) => c.id.equals(categoryId)))
        .write(CategoriesCompanion(monthlyBudget: Value(monthlyBudget)));
  }
}