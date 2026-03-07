import 'package:maneja/models/transaction.dart';

abstract class TransactionService {
  Future<List<Transaction>> fetchTransactions({
    String? period,
    String? search,
    int? limit,
    String ordering = '-created_at',
  });

  Future<Transaction> recordSale({
    required int itemId,
    required int quantity,
    required String method, // tap|text|voice
  });

  Future<void> voidTransaction({
    required int transactionId,
  });

  Future<Transaction> parseAndRecord({
    required String text,
    required String source, // text|voice
  });
}
