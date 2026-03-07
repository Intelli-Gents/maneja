import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maneja/features/home/providers/home_providers.dart';
import 'package:maneja/services/api_parser_service.dart';

class TextEntryScreen extends ConsumerStatefulWidget {
  const TextEntryScreen({super.key});

  @override
  ConsumerState<TextEntryScreen> createState() => _TextEntryScreenState();
}

class _TextEntryScreenState extends ConsumerState<TextEntryScreen> {
  final _controller = TextEditingController();
  ParsedInputDto? _parsed;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleParse() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final parser = ref.read(parserApiServiceProvider);
    try {
      final parsed = await parser.parseInput(text: text, source: 'text');
      setState(() {
        _parsed = parsed;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to parse input.')),
      );
    }
  }

  Future<void> _handleConfirm() async {
    final parsed = _parsed;
    if (parsed == null) return;

    final txService = ref.read(transactionServiceProvider);
    final txNotifier = ref.read(transactionsProvider.notifier);
    final stockNotifier = ref.read(stockProvider.notifier);

    try {
      final tx = await txService.parseAndRecord(
        text: _controller.text.trim(),
        source: 'text',
      );
      txNotifier.add(tx);
      await stockNotifier.load();
      ref.invalidate(notificationsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recorded: ${parsed.intent}'),
        ),
      );
      Navigator.of(context).maybePop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to record.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF9A3412)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Text input is still under development. Please double-check parsed results before confirming.',
                      style: TextStyle(
                        color: Color(0xFF9A3412),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'What happened?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'sold soda 1000\n'
                    'sold 2 breads\n'
                    'bought sugar stock 20000',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _handleParse(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _handleParse();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Preview',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_parsed != null) ...[
              const Text(
                'Detected:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _ParsedPreview(parsed: _parsed!),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _handleConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.95),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ParsedPreview extends StatelessWidget {
  const _ParsedPreview({required this.parsed});

  final ParsedInputDto parsed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row(label: 'Type', value: parsed.intent),
          if (parsed.itemName != null) _Row(label: 'Item', value: parsed.itemName!),
          if (parsed.quantity != null) _Row(label: 'Qty', value: '${parsed.quantity}'),
          if (parsed.amount != null) _Row(label: 'Total', value: parsed.amount!.toStringAsFixed(0)),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

