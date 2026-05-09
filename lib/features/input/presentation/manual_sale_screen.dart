import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maneja/features/home/providers/home_providers.dart';
import 'package:maneja/models/manual_sale_response.dart';
import 'package:maneja/models/stock_item.dart';

class ManualSaleScreen extends ConsumerStatefulWidget {
  const ManualSaleScreen({super.key});

  @override
  ConsumerState<ManualSaleScreen> createState() => _ManualSaleScreenState();
}

class _ManualSaleScreenState extends ConsumerState<ManualSaleScreen> {
  final List<_LineState> _lines = [
    _LineState(),
  ];

  bool _submitting = false;
  ManualSaleResponse? _result;

  void _addLine() {
    setState(() {
      _lines.add(_LineState());
    });
  }

  void _removeLine(int index) {
    setState(() {
      _lines.removeAt(index);
    });
  }

  Future<void> _submit() async {
    final valid = _lines
        .where((l) => l.itemId != null)
        .map((l) => ManualSaleLineRequest(
              itemId: l.itemId!,
              quantity: l.quantity,
              unitPrice: l.unitPrice?.trim().isEmpty == true ? null : l.unitPrice,
            ))
        .toList();

    if (valid.isEmpty) return;

    setState(() {
      _submitting = true;
      _result = null;
    });

    try {
      final service = ref.read(manualSaleApiServiceProvider);
      final resp = await service.recordManualSale(
        method: 'text',
        lines: valid,
      );

      setState(() {
        _result = resp;
      });

      await ref.read(stockProvider.notifier).load();
      await ref.read(transactionsProvider.notifier).load(limit: 10);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(notificationsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manual sale recorded.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to record manual sale.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stock = ref.watch(stockProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual sale'),
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Record'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          children: [
            Expanded(
              child: stock.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(
                      child: Text('No items yet.'),
                    );
                  }

                  return ListView.separated(
                    itemCount: _lines.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final line = _lines[index];
                      return _ManualLineCard(
                        index: index,
                        items: items,
                        state: line,
                        onRemove: _lines.length <= 1 ? null : () => _removeLine(index),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Failed to load items.')),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _submitting ? null : _addLine,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add line'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: const Text('Record sale'),
                  ),
                ),
              ],
            ),
            if (_result != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recorded ${_result!.recordedCount} items',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  itemCount: _result!.transactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final t = _result!.transactions[i];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF065F46)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${t.itemName} × ${t.quantity}',
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          Text(
                            t.amount.toStringAsFixed(0),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LineState {
  int? itemId;
  int quantity = 1;
  String? unitPrice;

  final qtyController = TextEditingController(text: '1');
  final priceController = TextEditingController();

  void sync() {
    quantity = int.tryParse(qtyController.text.trim()) ?? 1;
    if (quantity <= 0) quantity = 1;
    unitPrice = priceController.text;
  }

  void dispose() {
    qtyController.dispose();
    priceController.dispose();
  }
}

class _ManualLineCard extends StatefulWidget {
  const _ManualLineCard({
    required this.index,
    required this.items,
    required this.state,
    required this.onRemove,
  });

  final int index;
  final List<StockItem> items;
  final _LineState state;
  final VoidCallback? onRemove;

  @override
  State<_ManualLineCard> createState() => _ManualLineCardState();
}

class _ManualLineCardState extends State<_ManualLineCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Line ${widget.index + 1}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              if (widget.onRemove != null)
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Remove',
                ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            value: widget.state.itemId,
            decoration: const InputDecoration(
              labelText: 'Item',
              border: OutlineInputBorder(),
            ),
            items: widget.items
                .map(
                  (i) => DropdownMenuItem<int>(
                    value: int.parse(i.id),
                    child: Text(i.name),
                  ),
                )
                .toList(),
            onChanged: (v) {
              setState(() {
                widget.state.itemId = v;
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.state.qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Units',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => widget.state.sync(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.state.priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Unit price (optional)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => widget.state.sync(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
