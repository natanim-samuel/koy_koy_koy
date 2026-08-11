import 'package:drift/drift.dart';

import '../database.dart';

part 'goals_dao.g.dart';

@DriftAccessor(tables: [Goals])
class GoalsDao extends DatabaseAccessor<AppDatabase> with _$GoalsDaoMixin {
  GoalsDao(super.db);

  Stream<List<Goal>> watchAll() =>
      (select(goals)..orderBy([(g) => OrderingTerm.asc(g.targetDate)])).watch();

  Future<int> addGoal(GoalsCompanion entry) => into(goals).insert(entry);

  Future<void> contribute(int goalId, double amount) async {
    final goal = await (select(goals)..where((g) => g.id.equals(goalId))).getSingle();
    await (update(goals)..where((g) => g.id.equals(goalId)))
        .write(GoalsCompanion(savedAmount: Value(goal.savedAmount + amount)));
  }
}