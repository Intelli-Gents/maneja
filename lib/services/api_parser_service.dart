import 'package:maneja/core/network/api_client.dart';

class ParsedInputDto {
  ParsedInputDto({
    required this.intent,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.amount,
    required this.raw,
  });

  final String intent;
  final int? itemId;
  final String? itemName;
  final int? quantity;
  final double? amount;
  final String raw;

  factory ParsedInputDto.fromJson(Map<String, dynamic> json) {
    return ParsedInputDto(
      intent: (json['intent'] ?? '').toString(),
      itemId: (json['item_id'] as num?)?.toInt(),
      itemName: (json['item_name'] ?? '').toString().trim().isEmpty
          ? null
          : (json['item_name'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt(),
      amount: (json['amount'] as num?)?.toDouble(),
      raw: (json['raw'] ?? '').toString(),
    );
  }
}

class ApiParserService {
  ApiParserService(this._client);

  final ApiClient _client;

  Future<ParsedInputDto> parseInput({
    required String text,
    required String source,
  }) async {
    final json = await _client.postJson(
      '/parser/parse_input/',
      body: {
        'text': text,
        'source': source,
      },
    );
    return ParsedInputDto.fromJson(json);
  }
}
