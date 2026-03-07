import 'package:maneja/models/stock_item.dart';

abstract class StockService {
  List<StockItem> getInitialStock();

  List<StockItem> applyPurchase({
    required List<StockItem> current,
    required String itemName,
    required int quantity,
  });

  List<StockItem> applySale({
    required List<StockItem> current,
    required String itemName,
    required int quantity,
  });
}

