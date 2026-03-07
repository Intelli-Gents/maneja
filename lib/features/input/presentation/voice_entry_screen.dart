import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maneja/features/home/providers/home_providers.dart';
import 'package:maneja/services/api_parser_service.dart';

class VoiceEntryScreen extends ConsumerStatefulWidget {
  const VoiceEntryScreen({super.key});

  @override
  ConsumerState<VoiceEntryScreen> createState() => _VoiceEntryScreenState();
}

class _VoiceEntryScreenState extends ConsumerState<VoiceEntryScreen> {
  bool _recording = false;
  String? _mockTranscript;
  ParsedInputDto? _parsed;

  Future<void> _toggleRecord() async {
    setState(() {
      _recording = !_recording;
    });

    if (!_recording) {
      // Simulate a fixed transcript for now.
      const transcript = 'I sold two sodas for 4000';
      final parser = ref.read(parserApiServiceProvider);
      try {
        final parsed = await parser.parseInput(text: transcript, source: 'voice');
        setState(() {
          _mockTranscript = transcript;
          _parsed = parsed;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _mockTranscript = transcript;
          _parsed = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to parse transcript.')),
        );
      }
    }
  }

  Future<void> _handleConfirm() async {
    final parsed = _parsed;
    if (parsed == null) return;

    final txService = ref.read(transactionServiceProvider);
    final txNotifier = ref.read(transactionsProvider.notifier);
    final stockNotifier = ref.read(stockProvider.notifier);
    final transcript = _mockTranscript;
    if (transcript == null) return;

    try {
      final tx = await txService.parseAndRecord(
        text: transcript,
        source: 'voice',
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
    final recordingColor =
        _recording ? Colors.redAccent : Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
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
                      'Voice input is still under development. Use tap entry if something looks wrong.',
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
              'Hold to record',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                _toggleRecord();
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: recordingColor.withOpacity(0.1),
                ),
                child: Center(
                  child: Icon(
                    _recording ? Icons.stop_rounded : Icons.mic_rounded,
                    size: 44,
                    color: recordingColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _recording ? 'Listening…' : 'Tap to start / stop',
              style: const TextStyle(
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            if (_mockTranscript != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Transcript',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(_mockTranscript!),
              ),
              const SizedBox(height: 18),
            ],
            if (_parsed != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Detected',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _VoiceParsedPreview(parsed: _parsed!),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _handleConfirm();
                  },
                  style: ElevatedButton.styleFrom(
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

class _VoiceParsedPreview extends StatelessWidget {
  const _VoiceParsedPreview({required this.parsed});

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

