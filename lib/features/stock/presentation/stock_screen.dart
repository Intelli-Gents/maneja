import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maneja/core/widgets/dashboard_widgets.dart';
import 'package:maneja/features/home/providers/home_providers.dart';
import 'package:maneja/features/stock/presentation/add_item_screen.dart';
import 'package:maneja/models/stock_item.dart';

class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stock = ref.watch(stockProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FC),
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: const Text('Stock'),
        actions: [
          IconButton(
            tooltip: 'Add item',
            icon: const Icon(Icons.add_rounded),
            onPressed: () async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => const AddItemScreen(),
                  fullscreenDialog: true,
                ),
              );
              if (created == true) {
                ref.invalidate(stockProvider);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: stock.when(
            data: (items) {
              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    'No items yet.',
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
                      final item = items[index];
                      return _StockRow(
                        item: item,
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
                'Failed to load stock.',
                style: TextStyle(color: Color(0xFF9CA3AF)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StockRow extends ConsumerWidget {
  const _StockRow({
    required this.item,
    required this.showDivider,
  });

  final StockItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLow = item.quantity <= 5;

    Future<void> handleRestock() async {
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.hideCurrentSnackBar();

      final controller = TextEditingController();
      final qty = await showDialog<int>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Restock ${item.name}'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity to add',
                hintText: 'e.g. 10',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final parsed = int.tryParse(controller.text.trim());
                  if (parsed == null || parsed <= 0) return;
                  Navigator.of(context).pop(parsed);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );

      if (qty == null) return;

      try {
        final service = ref.read(stockApiServiceProvider);
        await service.restock(itemId: int.parse(item.id), quantity: qty);
        ref.invalidate(stockProvider);
        ref.invalidate(notificationsProvider);
        scaffold.showSnackBar(
          SnackBar(content: Text('Added $qty to ${item.name}')),
        );
      } catch (_) {
        scaffold.showSnackBar(
          const SnackBar(content: Text('Failed to restock.')),
        );
      }
    }

    return InkWell(
      onTap: handleRestock,
      child: NotebookEntryRow(
        data: NotebookEntryRowData(
          leadingIcon: Icons.inventory_2_rounded,
          leadingBg: const Color(0xFFF4F6F9),
          title: item.name,
          subtitle: '${item.quantity} left',
          trailing: isLow ? 'Low' : '${item.sellingPrice.toStringAsFixed(0)}',
          trailingIsLink: isLow,
        ),
        showDivider: showDivider,
      ),
    );
  }
}

