import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maneja/features/home/providers/home_providers.dart';
import 'package:maneja/models/confirm_and_record_response.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class VoiceEntryScreen extends ConsumerStatefulWidget {
  const VoiceEntryScreen({super.key});

  @override
  ConsumerState<VoiceEntryScreen> createState() => _VoiceEntryScreenState();
}

class _VoiceEntryScreenState extends ConsumerState<VoiceEntryScreen> {
  final _recorder = AudioRecorder();
  final _transcriptController = TextEditingController();

  bool _isRecording = false;
  bool _isTranscribing = false;
  bool _isRecordingToBackend = false;

  File? _recordedFile;
  String? _transcribedText;
  ConfirmAndRecordResponse? _result;

  @override
  void dispose() {
    _transcriptController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<File> _newTempRecordingFile() async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/maneja_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    return File(path);
  }

  Future<void> _startRecording() async {
    final hasPerm = await _recorder.hasPermission();
    if (!hasPerm) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required.')),
      );
      return;
    }

    final file = await _newTempRecordingFile();
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
      path: file.path,
    );

    setState(() {
      _isRecording = true;
      _recordedFile = file;
      _transcribedText = null;
      _result = null;
      _transcriptController.text = '';
    });
  }

  Future<void> _stopRecordingAndTranscribe() async {
    final path = await _recorder.stop();
    final file = path == null ? _recordedFile : File(path);

    setState(() {
      _isRecording = false;
      _recordedFile = file;
    });

    if (file == null) return;

    setState(() {
      _isTranscribing = true;
    });

    try {
      final voiceApi = ref.read(voiceApiServiceProvider);
      final resp = await voiceApi.transcribe(audioFile: file);
      setState(() {
        _transcribedText = resp.text;
        _transcriptController.text = resp.text;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transcription failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTranscribing = false;
        });
      }
    }
  }

  Future<void> _toggleRecord() async {
    if (_isTranscribing || _isRecordingToBackend) return;
    if (_isRecording) {
      await _stopRecordingAndTranscribe();
      return;
    }
    await _startRecording();
  }

  Future<void> _confirmAndRecord() async {
    final text = _transcriptController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isRecordingToBackend = true;
      _result = null;
    });

    try {
      final voiceApi = ref.read(voiceApiServiceProvider);
      final resp = await voiceApi.confirmAndRecord(text: text);

      setState(() {
        _result = resp;
      });

      // Refresh app state even if partial failures.
      await ref.read(stockProvider.notifier).load();
      await ref.read(transactionsProvider.notifier).load(limit: 10);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(notificationsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording complete.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to record. Please retry.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRecordingToBackend = false;
        });
      }
    }
  }

  void _reset() {
    setState(() {
      _isRecording = false;
      _isTranscribing = false;
      _isRecordingToBackend = false;
      _recordedFile = null;
      _transcribedText = null;
      _result = null;
      _transcriptController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final recordingColor =
        _isRecording ? Colors.redAccent : Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          children: [
            if (_isTranscribing)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(),
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
                    _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    size: 44,
                    color: recordingColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isRecording
                  ? 'Listening…'
                  : _isTranscribing
                      ? 'Transcribing…'
                      : _isRecordingToBackend
                          ? 'Recording…'
                          : 'Tap to start / stop',
              style: const TextStyle(
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            if (_transcribedText != null || _transcriptController.text.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Transcript (edit before confirm)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _transcriptController,
                minLines: 2,
                maxLines: 4,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isRecordingToBackend || _isTranscribing ? null : _reset,
                      child: const Text('Re-record'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isRecordingToBackend || _isTranscribing ? null : _confirmAndRecord,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],

            if (_result != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recorded ${_result!.recordedCount} items',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: _result!.actions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final a = _result!.actions[i];
                    return _ActionRow(action: a);
                  },
                ),
              ),
            ] else ...[
              const Spacer(),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.action});

  final RecordedAction action;

  @override
  Widget build(BuildContext context) {
    final isOk = action.recorded;
    final bg = isOk ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);
    final border = isOk ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA);
    final titleColor = isOk ? const Color(0xFF065F46) : const Color(0xFF991B1B);

    String? itemName;
    int? qty;
    String? amount;

    final tx = action.transaction;
    if (tx != null) {
      itemName = tx['item_name']?.toString();
      qty = (tx['quantity'] is num)
          ? (tx['quantity'] as num).toInt()
          : int.tryParse((tx['quantity'] ?? '').toString());
      amount = tx['amount']?.toString();
    } else {
      itemName = action.parsed['item_name']?.toString();
      qty = (action.parsed['quantity'] is num)
          ? (action.parsed['quantity'] as num).toInt()
          : int.tryParse((action.parsed['quantity'] ?? '').toString());
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOk ? Icons.check_circle_rounded : Icons.error_rounded,
                color: titleColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isOk ? 'Recorded' : 'Failed',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (itemName != null)
            Text(
              '${itemName ?? ''}${qty != null ? ' × $qty' : ''}${amount != null ? ' · $amount' : ''}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          if (!isOk && action.error != null) ...[
            const SizedBox(height: 6),
            Text(
              action.error!,
              style: const TextStyle(
                color: Color(0xFF991B1B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
