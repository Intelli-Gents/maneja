import 'package:maneja/core/network/api_client.dart';
import 'package:maneja/models/agent_chat.dart';

class ApiAgentChatService {
  ApiAgentChatService(this._client);

  final ApiClient _client;

  Future<AgentChatResponse> chat({
    required String message,
    String? conversationId,
    List<AgentChatTurn>? history,
  }) async {
    final json = await _client.postJson(
      '/agent/chat/',
      body: {
        'message': message,
        if (conversationId != null && conversationId.trim().isNotEmpty)
          'conversation_id': conversationId,
        if (history != null && history.isNotEmpty)
          'history': history.map((t) => t.toJson()).toList(),
      },
    );

    return AgentChatResponse.fromJson(json);
  }
}
