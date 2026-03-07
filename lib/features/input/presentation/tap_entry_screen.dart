import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maneja/features/home/providers/home_providers.dart';
import 'package:maneja/models/stock_item.dart';
import 'package:maneja/models/transaction.dart';

class TapEntryScreen extends ConsumerWidget {
  const TapEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stock = ref.watch(stockProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tap entry'),
      ),
      body: stock.when(
        data: (items) => GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _TapItemTile(item: item);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text(
            'Failed to load stock.',
            style: TextStyle(color: Color(0xFF9CA3AF)),
          ),
        ),
      ),
    );
  }
}

class _TapItemTile extends ConsumerWidget {
  const _TapItemTile({required this.item});

  final StockItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txService = ref.read(transactionServiceProvider);
    final txNotifier = ref.read(transactionsProvider.notifier);
    final stockNotifier = ref.read(stockProvider.notifier);

    Future<void> handleTap() async {
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.hideCurrentSnackBar();

      Transaction tx;
      try {
        tx = await txService.recordSale(
          itemId: int.parse(item.id),
          quantity: 1,
          method: 'tap',
        );
      } catch (_) {
        scaffold.showSnackBar(
          const SnackBar(content: Text('Failed to record sale.')),
        );
        return;
      }

      txNotifier.add(tx);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(notificationsProvider);

      try {
        await stockNotifier.load();
      } catch (_) {
        scaffold.showSnackBar(
          const SnackBar(content: Text('Sale recorded, but refresh failed.')),
        );
      }

      scaffold.showSnackBar(
        SnackBar(
          content: Text('Sold 1 ${item.name}'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              try {
                await txService.voidTransaction(
                  transactionId: int.parse(tx.id),
                );
                txNotifier.removeById(tx.id);
                ref.invalidate(dashboardSummaryProvider);
                ref.invalidate(notificationsProvider);
                await stockNotifier.load();
              } catch (_) {
                scaffold.hideCurrentSnackBar();
                scaffold.showSnackBar(
                  const SnackBar(content: Text('Undo failed.')),
                );
              }
            },
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        handleTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Ink(
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
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      item.name.characters.first.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${item.sellingPrice.toStringAsFixed(0)} UGX',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${item.quantity} left',
              style: TextStyle(
                fontSize: 12,
                color: item.quantity <= 5
                    ? const Color(0xFFB91C1C)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

