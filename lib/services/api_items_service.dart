import 'package:maneja/core/network/api_client.dart';
import 'package:maneja/models/stock_item.dart';

class ApiItemsService {
  ApiItemsService(this._client);

  final ApiClient _client;

  Future<StockItem> createItem({
    required String name,
    int quantity = 0,
    double costPrice = 0,
    double sellingPrice = 0,
  }) async {
    final json = await _client.postJson(
      '/items/',
      body: {
        'name': name,
        'quantity': quantity,
        'cost_price': costPrice.toStringAsFixed(2),
        'selling_price': sellingPrice.toStringAsFixed(2),
      },
    );
    return StockItem.fromJson(json);
  }
}
