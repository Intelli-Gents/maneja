import 'package:maneja/core/network/api_client.dart';
import 'package:maneja/models/manual_sale_response.dart';

class ApiManualSaleService {
  ApiManualSaleService(this._client);

  final ApiClient _client;

  Future<ManualSaleResponse> recordManualSale({
    required String method,
    required List<ManualSaleLineRequest> lines,
  }) async {
    final json = await _client.postJson(
      '/sales/manual/',
      body: {
        'method': method,
        'lines': lines.map((l) => l.toJson()).toList(),
      },
    );
    return ManualSaleResponse.fromJson(json);
  }
}
