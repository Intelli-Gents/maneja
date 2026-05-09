import 'package:maneja/models/transaction.dart';

class ManualSaleLineRequest {
  ManualSaleLineRequest({
    required this.itemId,
    required this.quantity,
    this.unitPrice,
  });

  final int itemId;
  final int quantity;
  final String? unitPrice;

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'quantity': quantity,
      if (unitPrice != null && unitPrice!.trim().isNotEmpty) 'unit_price': unitPrice,
    };
  }
}

class ManualSaleResponse {
  ManualSaleResponse({
    required this.recordedCount,
    required this.transactions,
  });

  final int recordedCount;
  final List<Transaction> transactions;

  factory ManualSaleResponse.fromJson(Map<String, dynamic> json) {
    final rawTxs = json['transactions'];
    final txs = (rawTxs is List)
        ? rawTxs
            .whereType<Map>()
            .map((e) => Transaction.fromJson(e.cast<String, dynamic>()))
            .toList()
        : <Transaction>[];

    return ManualSaleResponse(
      recordedCount: (json['recorded_count'] is num)
          ? (json['recorded_count'] as num).toInt()
          : int.tryParse((json['recorded_count'] ?? '0').toString()) ?? 0,
      transactions: txs,
    );
  }
}
