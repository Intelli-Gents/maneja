import 'package:maneja/core/network/api_client.dart';
import 'package:maneja/models/stock_item.dart';

class ApiStockService {
  ApiStockService(this._client);

  final ApiClient _client;

  Future<List<StockItem>> fetchStock() async {
    final list = await _client.getJsonList('/stock/');
    return list
        .whereType<Map>()
        .map((e) => StockItem.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<StockItem> restock({
    required int itemId,
    required int quantity,
  }) async {
    final json = await _client.postJson(
      '/restock/',
      body: {
        'item_id': itemId,
        'quantity': quantity,
      },
    );

    return StockItem.fromJson(json);
  }
}
