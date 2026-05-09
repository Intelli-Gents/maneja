import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maneja/features/home/providers/home_providers.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController(text: '0');
  final _costController = TextEditingController(text: '0');
  final _sellingController = TextEditingController(text: '0');

  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _costController.dispose();
    _sellingController.dispose();
    super.dispose();
  }

  int _parseInt(String v) => int.tryParse(v.trim()) ?? 0;

  double _parseDouble(String v) => double.tryParse(v.trim()) ?? 0;

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _submitting = true;
    });

    try {
      final items = ref.read(itemsApiServiceProvider);
      await items.createItem(
        name: name,
        quantity: _parseInt(_qtyController.text),
        costPrice: _parseDouble(_costController.text),
        sellingPrice: _parseDouble(_sellingController.text),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create item.')),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add item'),
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Bread',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Initial quantity',
                hintText: 'e.g. 10',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _costController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Cost price',
                hintText: 'e.g. 1200.00',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _sellingController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Selling price',
                hintText: 'e.g. 1500.00',
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                child: const Text('Create item'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
