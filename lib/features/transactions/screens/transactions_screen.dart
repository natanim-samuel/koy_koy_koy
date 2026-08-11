import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/local/daos/transactions_dao.dart';
import '../../../data/repositories/providers.dart';

final _currency = CurrencyFormatter(locale: 'en_US', currencyCode: 'USD');

enum _Filter { all, expense, income }

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(title: const Text('Transactions'), backgroundColor: AppColors.lightBg, foregroundColor: AppColors.textOnLight),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _Filter.values.map((f) {
                final selected = f == _filter;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(f.name[0].toUpperCase() + f.name.substring(1)),
                      selected: selected,
                      selectedColor: AppColors.lightCard,
                      labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textOnLightSecondary),
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final stream = switch (_filter) {
                  _Filter.all => ref.watch(expenseRepositoryProvider).watchRecentTransactions(limit: 200),
                  _Filter.expense => ref.watch(expenseRepositoryProvider).watchTransactionsByType('expense'),
                  _Filter.income => ref.watch(expenseRepositoryProvider).watchTransactionsByType('income'),
                };

                return StreamBuilder<List<TransactionWithCategory>>(
                  stream: stream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final items = snapshot.data!;
                    if (items.isEmpty) {
                      return const Center(child: Text('No transactions yet.', style: TextStyle(color: AppColors.textOnLightSecondary)));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final item = items[i];
                        final tx = item.transaction;
                        final isIncome = tx.type == 'income';
                        final color = AppColors.forCategory(item.category?.name ?? '');
                        return ListTile(
                          leading: CircleAvatar(backgroundColor: color, radius: 16),
                          title: Text(tx.note.isEmpty ? (item.category?.name ?? 'Transaction') : tx.note,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text(
                            '${item.category?.name ?? 'Uncategorized'} · ${_formatDate(tx.date)}',
                            style: const TextStyle(color: AppColors.textOnLightSecondary, fontSize: 11),
                          ),
                          trailing: Text(
                            _currency.formatSigned(tx.amount, isIncome: isIncome),
                            style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? AppColors.catGreen : AppColors.textOnLight),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${_month(d.month)} ${d.day}, ${_time(d)}';
  String _month(int m) => const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1];
  String _time(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final suffix = d.hour >= 12 ? 'PM' : 'AM';
    return '$h:${d.minute.toString().padLeft(2, '0')} $suffix';
  }
}