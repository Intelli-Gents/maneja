import 'dart:math';

import 'package:maneja/models/stock_item.dart';
import 'package:maneja/models/transaction.dart';
import 'package:maneja/services/insights_service.dart';
import 'package:maneja/services/stock_service.dart';
import 'package:maneja/services/transaction_service.dart';

class MockTransactionService implements TransactionService {
  MockTransactionService() {
    _transactions = getInitialTransactions();
  }

  late List<Transaction> _transactions;

  List<Transaction> getInitialTransactions() {
    final now = DateTime.now();
    return [
      Transaction(
        id: 't1',
        itemName: 'Soda',
        quantity: 1,
        amount: 2000,
        timestamp: now.subtract(const Duration(minutes: 15)),
        entryMethod: 'tap',
      ),
      Transaction(
        id: 't2',
        itemName: 'Sugar',
        quantity: 2,
        amount: 5000,
        timestamp: now.subtract(const Duration(minutes: 30)),
        entryMethod: 'text',
      ),
      Transaction(
        id: 't3',
        itemName: 'Bread',
        quantity: 3,
        amount: 6000,
        timestamp: now.subtract(const Duration(hours: 1)),
        entryMethod: 'voice',
      ),
    ];
  }

  Transaction _newTx({
    required String itemName,
    required double amount,
    required int quantity,
    required String method,
  }) {
    return Transaction(
      id: '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(9999)}',
      itemName: itemName,
      quantity: quantity,
      amount: amount,
      timestamp: DateTime.now(),
      entryMethod: method,
    );
  }

  @override
  Future<List<Transaction>> fetchTransactions({
    String? period,
    String? search,
    int? limit,
    String ordering = '-created_at',
  }) async {
    var items = [..._transactions];
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      items = items.where((t) => t.itemName.toLowerCase().contains(q)).toList();
    }

    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (limit != null && limit > 0 && items.length > limit) {
      items = items.take(limit).toList();
    }
    return items;
  }

  @override
  Future<Transaction> recordSale({
    required int itemId,
    required int quantity,
    required String method,
  }) async {
    final tx = _newTx(
      itemName: 'Item $itemId',
      amount: 0,
      quantity: quantity,
      method: method,
    );
    _transactions = [..._transactions, tx];
    return tx;
  }

  @override
  Future<void> voidTransaction({required int transactionId}) async {
    _transactions =
        _transactions.where((t) => int.tryParse(t.id) != transactionId).toList();
  }

  @override
  Future<Transaction> parseAndRecord({
    required String text,
    required String source,
  }) async {
    final tx = _newTx(
      itemName: text,
      amount: 0,
      quantity: 1,
      method: source,
    );
    _transactions = [..._transactions, tx];
    return tx;
  }
}

class MockStockService implements StockService {
  @override
  List<StockItem> getInitialStock() {
    return [
      StockItem(
        id: 's1',
        name: 'Sugar',
        quantity: 12,
        costPrice: 2500,
        sellingPrice: 3000,
      ),
      StockItem(
        id: 's2',
        name: 'Soda',
        quantity: 5,
        costPrice: 1500,
        sellingPrice: 2000,
      ),
      StockItem(
        id: 's3',
        name: 'Bread',
        quantity: 3,
        costPrice: 1800,
        sellingPrice: 2500,
      ),
      StockItem(
        id: 's4',
        name: 'Airtime',
        quantity: 30,
        costPrice: 900,
        sellingPrice: 1000,
      ),
      StockItem(
        id: 's5',
        name: 'Soap',
        quantity: 8,
        costPrice: 2500,
        sellingPrice: 3000,
      ),
    ];
  }

  @override
  List<StockItem> applyPurchase({
    required List<StockItem> current,
    required String itemName,
    required int quantity,
  }) {
    return current
        .map(
          (item) => item.name.toLowerCase() == itemName.toLowerCase()
              ? StockItem(
                  id: item.id,
                  name: item.name,
                  quantity: item.quantity + quantity,
                  costPrice: item.costPrice,
                  sellingPrice: item.sellingPrice,
                )
              : item,
        )
        .toList();
  }

  @override
  List<StockItem> applySale({
    required List<StockItem> current,
    required String itemName,
    required int quantity,
  }) {
    return current
        .map(
          (item) => item.name.toLowerCase() == itemName.toLowerCase()
              ? StockItem(
                  id: item.id,
                  name: item.name,
                  quantity: (item.quantity - quantity).clamp(0, 999999),
                  costPrice: item.costPrice,
                  sellingPrice: item.sellingPrice,
                )
              : item,
        )
        .toList();
  }
}

class MockInsightsService implements InsightsService {
  @override
  InsightsSnapshot buildSnapshot({
    required List<Transaction> transactions,
    required List<StockItem> stock,
  }) {
    final today = DateTime.now();
    final todayTotal = transactions
        .where((t) =>
            t.timestamp.year == today.year &&
            t.timestamp.month == today.month &&
            t.timestamp.day == today.day)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final Map<String, int> counts = {};
    for (final t in transactions) {
      counts.update(t.itemName, (value) => value + t.quantity,
          ifAbsent: () => t.quantity);
    }
    String bestItem = '—';
    int bestQty = 0;
    counts.forEach((item, qty) {
      if (qty > bestQty) {
        bestQty = qty;
        bestItem = item;
      }
    });

    final lowStockCount =
        stock.where((s) => s.quantity <= 5).length; // threshold

    return InsightsSnapshot(
      todaySales: todayTotal,
      bestSellingItem: bestItem,
      lowStockCount: lowStockCount,
    );
  }
}

