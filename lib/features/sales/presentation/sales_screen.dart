import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maneja/core/widgets/dashboard_widgets.dart';
import 'package:maneja/features/home/providers/home_providers.dart';
import 'package:maneja/models/transaction.dart';

enum SalesFilter { today, week, month }

final _salesFilterProvider =
    StateProvider<SalesFilter>((ref) => SalesFilter.today);

final _salesSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((ref) {
  final filter = ref.watch(_salesFilterProvider);
  final query = ref.watch(_salesSearchQueryProvider).toLowerCase();
  final all = ref.watch(transactionsProvider);
  final now = DateTime.now();

  bool inRange(Transaction t) {
    final d = t.timestamp;
    if (filter == SalesFilter.today) {
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }
    if (filter == SalesFilter.week) {
      return d.isAfter(now.subtract(const Duration(days: 7)));
    }
    return d.isAfter(now.subtract(const Duration(days: 30)));
  }

  return all.whenData((items) {
    return items.where((t) {
      final matchesRange = inRange(t);
      final matchesQuery =
          query.isEmpty || t.itemName.toLowerCase().contains(query);
      return matchesRange && matchesQuery;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  });
});

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(_salesFilterProvider);
    final transactions = ref.watch(filteredTransactionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FC),
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: const Text('Sales'),
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search item...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  ref.read(_salesSearchQueryProvider.notifier).state = value;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FilterChip(
                    label: 'Today',
                    selected: filter == SalesFilter.today,
                    onTap: () => ref
                        .read(_salesFilterProvider.notifier)
                        .state = SalesFilter.today,
                  ),
                  _FilterChip(
                    label: 'Week',
                    selected: filter == SalesFilter.week,
                    onTap: () => ref
                        .read(_salesFilterProvider.notifier)
                        .state = SalesFilter.week,
                  ),
                  _FilterChip(
                    label: 'Month',
                    selected: filter == SalesFilter.month,
                    onTap: () => ref
                        .read(_salesFilterProvider.notifier)
                        .state = SalesFilter.month,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: transactions.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return const Center(
                        child: Text(
                          'No sales in this period.',
                          style: TextStyle(color: Color(0xFF9CA3AF)),
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final t = items[index];
                            return _TransactionRow(
                              transaction: t,
                              showDivider: index != items.length - 1,
                            );
                          },
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(
                    child: Text(
                      'Failed to load sales.',
                      style: TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFFE5ECFF),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: selected ? const Color(0xFF1D4ED8) : const Color(0xFF6B7280),
      ),
      backgroundColor: const Color(0xFFF3F4F6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide.none,
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.transaction,
    required this.showDivider,
  });

  final Transaction transaction;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.Hm().format(transaction.timestamp);
    final amount = NumberFormat.compactCurrency(
      locale: 'en_UG',
      symbol: '',
      decimalDigits: 0,
    ).format(transaction.amount);

    return NotebookEntryRow(
      data: NotebookEntryRowData(
        leadingIcon: Icons.receipt_long_rounded,
        leadingBg: const Color(0xFFF4F6F9),
        title: transaction.itemName,
        subtitle:
            '$time • ${transaction.quantity} item${transaction.quantity == 1 ? '' : 's'}',
        trailing: amount,
      ),
      showDivider: showDivider,
    );
  }
}

