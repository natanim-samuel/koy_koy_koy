import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/local/database.dart';
import '../../../data/repositories/providers.dart';

/// Add Expense / Add Income form.
///
/// The "smart" part: as the person types in [noteController], we debounce
/// and run the note through [ExpenseRepository.suggestCategory] so the
/// category field pre-fills itself — they only need to correct it, not
/// pick it from scratch, in the common case.
class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key, required this.type});

  /// 'expense' or 'income'
  final String type;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  late String _type = widget.type;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  Category? _selectedCategory;
  bool _categoryWasAutoSuggested = false;
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _onNoteChanged(String note) async {
    // Only auto-suggest if the person hasn't manually picked a category yet,
    // so we never clobber an explicit choice while they keep typing notes.
    if (_selectedCategory != null && !_categoryWasAutoSuggested) return;

    final repo = ref.read(expenseRepositoryProvider);
    final categoryId = await repo.suggestCategory(note);
    if (!mounted || categoryId == null) return;

    final categories = await repo.watchCategories().first;
    final match = categories.where((c) => c.id == categoryId).firstOrNull;
    if (match != null) {
      setState(() {
        _selectedCategory = match;
        _categoryWasAutoSuggested = true;
      });
    }
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(expenseRepositoryProvider);
    await repo.addTransaction(
      amount: amount,
      type: _type,
      date: _date,
      note: _noteController.text,
      categoryId: _selectedCategory?.id,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(_categoriesStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Add Transaction'), backgroundColor: AppColors.bg),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text('Select Type', style: TextStyle(color: AppColors.textOnDarkSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _TypeChip(label: 'Expense', selected: _type == 'expense', onTap: () => setState(() => _type = 'expense'))),
                const SizedBox(width: 12),
                Expanded(child: _TypeChip(label: 'Income', selected: _type == 'income', onTap: () => setState(() => _type = 'income'))),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Select Category', style: TextStyle(color: AppColors.textOnDarkSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            categoriesAsync.when(
              data: (categories) => DropdownButtonFormField<Category>(
                initialValue: _selectedCategory,
                dropdownColor: AppColors.card,
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name, style: const TextStyle(color: AppColors.textOnDark))))
                    .toList(),
                onChanged: (c) => setState(() {
                  _selectedCategory = c;
                  _categoryWasAutoSuggested = false; // explicit choice now
                }),
                hint: const Text('Uncategorized', style: TextStyle(color: AppColors.textOnDarkMuted)),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            if (_categoryWasAutoSuggested && _selectedCategory != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Suggested from your note — tap to change.',
                  style: TextStyle(color: AppColors.mint.withValues(alpha: 0.8), fontSize: 11),
                ),
              ),
            const SizedBox(height: 20),

            const Text('Amount', style: TextStyle(color: AppColors.textOnDarkSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(prefixText: '\$ ', hintText: '0.00'),
            ),
            const SizedBox(height: 20),

            const Text('Note (Optional)', style: TextStyle(color: AppColors.textOnDarkSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              style: const TextStyle(color: AppColors.textOnDark),
              decoration: const InputDecoration(hintText: 'e.g. "Grocery shopping" or "Uber to airport"'),
              onChanged: _onNoteChanged,
            ),
            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}

final _categoriesStreamProvider = StreamProvider((ref) => ref.watch(expenseRepositoryProvider).watchCategories());

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.mintDark : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: selected ? Border.all(color: AppColors.mint) : null,
        ),
        child: Text(label, style: TextStyle(color: selected ? AppColors.mint : AppColors.textOnDarkSecondary, fontWeight: FontWeight.bold)),
      ),
    );
  }
}