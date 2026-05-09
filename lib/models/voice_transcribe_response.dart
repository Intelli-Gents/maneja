class VoiceTranscribeResponse {
  VoiceTranscribeResponse({required this.text});

  final String text;

  factory VoiceTranscribeResponse.fromJson(Map<String, dynamic> json) {
    return VoiceTranscribeResponse(
      text: (json['text'] ?? '').toString(),
    );
  }
}
