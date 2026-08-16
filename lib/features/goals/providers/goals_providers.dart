import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../../../data/repositories/providers.dart';

final goalsListProvider = StreamProvider<List<Goal>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchGoals();
});