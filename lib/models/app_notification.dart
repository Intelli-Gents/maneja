class AppNotification {
  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.payload,
    required this.createdAt,
    required this.readAt,
  });

  final int id;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final DateTime? readAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    final payloadRaw = json['payload'];

    return AppNotification(
      id: (json['id'] as num?)?.toInt() ?? int.tryParse('${json['id']}') ?? 0,
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      payload: payloadRaw is Map
          ? payloadRaw.cast<String, dynamic>()
          : <String, dynamic>{},
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
      readAt: parseDate(json['read_at']),
    );
  }
}
