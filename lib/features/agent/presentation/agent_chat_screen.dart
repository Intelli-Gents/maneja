import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maneja/core/network/api_client.dart';
import 'package:maneja/features/home/providers/home_providers.dart';
import 'package:maneja/models/agent_chat.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AgentChatScreen extends ConsumerStatefulWidget {
  const AgentChatScreen({super.key});

  @override
  ConsumerState<AgentChatScreen> createState() => _AgentChatScreenState();
}

class _AgentChatScreenState extends ConsumerState<AgentChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  final List<_UiMessage> _messages = [];
  String? _conversationId;
  bool _sending = false;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechReady = false;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      final ok = await _speech.initialize();
      if (!mounted) return;
      setState(() {
        _speechReady = ok;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _speechReady = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _speech.stop();
    super.dispose();
  }

  List<AgentChatTurn> _history() {
    final recent = _messages.where((m) => m.role != _UiRole.system).toList();
    final tail = recent.length <= 16 ? recent : recent.sublist(recent.length - 16);
    return tail
        .map(
          (m) => AgentChatTurn(
            role: m.role == _UiRole.user ? 'user' : 'assistant',
            content: m.text,
          ),
        )
        .toList();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 120,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _sending = true;
      _messages.add(_UiMessage(role: _UiRole.user, text: text));
      _controller.clear();
    });

    await Future<void>.delayed(const Duration(milliseconds: 30));
    _scrollToBottom();

    final service = ref.read(agentChatApiServiceProvider);

    try {
      final resp = await service.chat(
        message: text,
        conversationId: _conversationId,
        history: _history(),
      );

      setState(() {
        _conversationId = resp.conversationId.trim().isEmpty
            ? (_conversationId ?? '')
            : resp.conversationId;
        _messages.add(_UiMessage(role: _UiRole.assistant, text: resp.answer));
      });

      await Future<void>.delayed(const Duration(milliseconds: 30));
      _scrollToBottom();
    } catch (e) {
      String msg = 'Agent unavailable.';

      if (e is ApiException) {
        if (e.statusCode == 400) {
          msg = 'Invalid message. Please try again.';
        } else if (e.statusCode >= 500) {
          msg = 'Agent unavailable.';
        }
      }

      setState(() {
        _messages.add(_UiMessage(role: _UiRole.system, text: msg));
      });

      await Future<void>.delayed(const Duration(milliseconds: 30));
      _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  Future<void> _toggleListening() async {
    if (!_speechReady) return;

    if (_listening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() {
        _listening = false;
      });
      return;
    }

    setState(() {
      _listening = true;
    });

    await _speech.listen(
      onResult: (r) {
        if (!mounted) return;
        setState(() {
          _controller.text = r.recognizedWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        });
      },
      listenMode: stt.ListenMode.confirmation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/img/app_icon.png',
                  width: 34,
                  height: 34,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Maneja',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: max(_messages.length, 1),
                itemBuilder: (context, index) {
                  if (_messages.isEmpty) {
                    return const _EmptyChatState();
                  }

                  final m = _messages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ChatBubble(message: m),
                  );
                },
              ),
            ),
            _Composer(
              controller: _controller,
              sending: _sending,
              onSend: _send,
              speechReady: _speechReady,
              listening: _listening,
              onMic: _sending ? null : _toggleListening,
            ),
          ],
        ),
      ),
    );
  }
}

enum _UiRole { user, assistant, system }

class _UiMessage {
  _UiMessage({required this.role, required this.text});

  final _UiRole role;
  final String text;
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Text(
              'Ask me about stock, sales, low-stock risk, and trends.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Try: “What items are likely to run out tomorrow?”',
            style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final _UiMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == _UiRole.user;
    final isSystem = message.role == _UiRole.system;

    final bg = isSystem
        ? const Color(0xFFFFFBEB)
        : isUser
            ? const Color(0xFF111827)
            : Colors.white;

    final fg = isSystem
        ? const Color(0xFF92400E)
        : isUser
            ? Colors.white
            : const Color(0xFF111827);

    final border = isSystem
        ? const Color(0xFFFDE68A)
        : isUser
            ? const Color(0xFF111827)
            : const Color(0xFFE5E7EB);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: fg,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
    required this.speechReady,
    required this.listening,
    required this.onMic,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final bool speechReady;
  final bool listening;
  final VoidCallback? onMic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.06))),
      ),
      child: Row(
        children: [
          if (speechReady)
            IconButton(
              onPressed: onMic,
              icon: Icon(
                listening ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: listening ? const Color(0xFF2563EB) : const Color(0xFF6B7280),
              ),
              tooltip: listening ? 'Stop' : 'Talk',
            ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !sending,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: sending ? 'Waiting for Maneja…' : 'Ask Maneja…',
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 46,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: sending ? null : onSend,
              child: sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.arrow_upward_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
