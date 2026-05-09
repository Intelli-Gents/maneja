class AgentChatTurn {
  AgentChatTurn({
    required this.role,
    required this.content,
  });

  final String role;
  final String content;

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  factory AgentChatTurn.fromJson(Map<String, dynamic> json) {
    return AgentChatTurn(
      role: (json['role'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
    );
  }
}

class AgentChatResponse {
  AgentChatResponse({
    required this.conversationId,
    required this.answer,
    required this.model,
    required this.shopSnapshot,
  });

  final String conversationId;
  final String answer;
  final String model;
  final Map<String, dynamic> shopSnapshot;

  factory AgentChatResponse.fromJson(Map<String, dynamic> json) {
    final snapshot = json['shop_snapshot'];
    return AgentChatResponse(
      conversationId: (json['conversation_id'] ?? '').toString(),
      answer: (json['answer'] ?? '').toString(),
      model: (json['model'] ?? '').toString(),
      shopSnapshot: snapshot is Map ? snapshot.cast<String, dynamic>() : <String, dynamic>{},
    );
  }
}
