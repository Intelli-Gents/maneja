import 'package:maneja/core/network/api_client.dart';
import 'package:maneja/models/transaction.dart';
import 'package:maneja/services/transaction_service.dart';

class ApiTransactionService implements TransactionService {
  ApiTransactionService(this._client);

  final ApiClient _client;

  @override
  Future<List<Transaction>> fetchTransactions({
    String? period,
    String? search,
    int? limit,
    String ordering = '-created_at',
  }) async {
    final query = <String, String>{
      'ordering': ordering,
      if (period != null) 'period': period,
      if (search != null && search.isNotEmpty) 'search': search,
      if (limit != null) 'limit': '$limit',
    };

    final list = await _client.getJsonList('/transactions/', query: query);
    return list
        .whereType<Map>()
        .map((e) => Transaction.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<Transaction> recordSale({
    required int itemId,
    required int quantity,
    required String method,
  }) async {
    final json = await _client.postJson(
      '/transactions/',
      body: {
        'item_id': itemId,
        'quantity': quantity,
        'method': method,
      },
    );
    return Transaction.fromJson(json);
  }

  @override
  Future<void> voidTransaction({required int transactionId}) async {
    await _client.postJson(
      '/transactions/$transactionId/void/',
      body: <String, dynamic>{},
    );
  }

  @override
  Future<Transaction> parseAndRecord({
    required String text,
    required String source,
  }) async {
    final json = await _client.postJson(
      '/transactions/parse_and_record/',
      body: {
        'text': text,
        'source': source,
      },
    );
    return Transaction.fromJson(json);
  }
}
