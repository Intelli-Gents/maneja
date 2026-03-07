import 'package:maneja/models/transaction.dart';
import 'package:maneja/models/stock_item.dart';

class InsightsSnapshot {
  InsightsSnapshot({
    required this.todaySales,
    required this.bestSellingItem,
    required this.lowStockCount,
  });

  final double todaySales;
  final String bestSellingItem;
  final int lowStockCount;
}

abstract class InsightsService {
  InsightsSnapshot buildSnapshot({
    required List<Transaction> transactions,
    required List<StockItem> stock,
  });
}

