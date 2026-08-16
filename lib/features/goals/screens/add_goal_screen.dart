import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/providers.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 180));
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _targetDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => isStart ? _startDate = picked : _targetDate = picked);
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text);

    if (name.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a goal name and a valid target amount.')),
      );
      return;
    }
    if (!_targetDate.isAfter(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target date must be after the start date.')),
      );
      return;
    }

    setState(() => _saving = true);
    await ref.read(expenseRepositoryProvider).addGoal(
      name: name,
      targetAmount: amount,
      startDate: _startDate,
      targetDate: _targetDate,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Add Goal'), backgroundColor: AppColors.bg),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.card,
                child: Icon(Icons.flag, color: AppColors.mint, size: 30),
              ),
            ),
            const SizedBox(height: 28),

            const Text('Goal Name', style: TextStyle(color: AppColors.textOnDarkSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textOnDark),
              decoration: const InputDecoration(hintText: 'e.g. New Laptop'),
            ),
            const SizedBox(height: 20),

            const Text('Target Amount', style: TextStyle(color: AppColors.textOnDarkSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(prefixText: '\$ ', hintText: '0.00'),
            ),
            const SizedBox(height: 20),

            const Text('Start Date', style: TextStyle(color: AppColors.textOnDarkSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            _DateField(date: _startDate, onTap: () => _pickDate(isStart: true)),
            const SizedBox(height: 20),

            const Text('Target Date', style: TextStyle(color: AppColors.textOnDarkSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            _DateField(date: _targetDate, onTap: () => _pickDate(isStart: false)),
            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save Goal'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_format(date), style: const TextStyle(color: AppColors.textOnDark)),
            const Icon(Icons.calendar_today, size: 16, color: AppColors.textOnDarkSecondary),
          ],
        ),
      ),
    );
  }

  String _format(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}