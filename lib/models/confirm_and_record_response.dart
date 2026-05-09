class ConfirmAndRecordResponse {
  ConfirmAndRecordResponse({
    required this.recordedCount,
    required this.actions,
  });

  final int recordedCount;
  final List<RecordedAction> actions;

  factory ConfirmAndRecordResponse.fromJson(Map<String, dynamic> json) {
    final rawActions = json['actions'];
    final actions = (rawActions is List)
        ? rawActions
            .whereType<Map>()
            .map((e) => RecordedAction.fromJson(e.cast<String, dynamic>()))
            .toList()
        : <RecordedAction>[];

    return ConfirmAndRecordResponse(
      recordedCount: (json['recorded_count'] is num)
          ? (json['recorded_count'] as num).toInt()
          : int.tryParse((json['recorded_count'] ?? '0').toString()) ?? 0,
      actions: actions,
    );
  }
}

class RecordedAction {
  RecordedAction({
    required this.intent,
    required this.recorded,
    required this.parsed,
    required this.transaction,
    required this.item,
    required this.error,
  });

  final String intent;
  final bool recorded;
  final Map<String, dynamic> parsed;
  final Map<String, dynamic>? transaction;
  final Map<String, dynamic>? item;
  final String? error;

  factory RecordedAction.fromJson(Map<String, dynamic> json) {
    final parsed = json['parsed'];
    final tx = json['transaction'];
    final item = json['item'];

    return RecordedAction(
      intent: (json['intent'] ?? '').toString(),
      recorded: json['recorded'] == true,
      parsed: parsed is Map ? parsed.cast<String, dynamic>() : <String, dynamic>{},
      transaction: tx is Map ? tx.cast<String, dynamic>() : null,
      item: item is Map ? item.cast<String, dynamic>() : null,
      error: json['error']?.toString(),
    );
  }
}
