import 'package:maneja/core/network/api_client.dart';

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
  return 0;
}

class DashboardSummaryDto {
  DashboardSummaryDto({
    required this.todaySalesAmount,
    required this.transactionCount,
    required this.lowStockCount,
    required this.estimatedProfit,
    required this.kioskName,
  });

  final double todaySalesAmount;
  final int transactionCount;
  final int lowStockCount;
  final double estimatedProfit;
  final String kioskName;

  factory DashboardSummaryDto.fromJson(Map<String, dynamic> json) {
    final todaySalesRaw =
        json['today_sales_amount'] ?? json['todaySalesAmount'] ?? json['today_sales'];
    final txCountRaw =
        json['transaction_count'] ?? json['transactionCount'] ?? json['transactions_count'];
    final lowStockRaw =
        json['low_stock_count'] ?? json['lowStockCount'] ?? json['low_stock'];
    final profitRaw =
        json['estimated_profit'] ?? json['estimatedProfit'] ?? json['profit_estimate'];
    return DashboardSummaryDto(
      todaySalesAmount: _toDouble(todaySalesRaw),
      transactionCount: _toInt(txCountRaw),
      lowStockCount: _toInt(lowStockRaw),
      estimatedProfit: _toDouble(profitRaw),
      kioskName: (json['kiosk_name'] ?? '').toString(),
    );
  }
}

class WeeklyTrendPointDto {
  WeeklyTrendPointDto({
    required this.date,
    required this.total,
  });

  final DateTime date;
  final double total;

  factory WeeklyTrendPointDto.fromJson(Map<String, dynamic> json) {
    return WeeklyTrendPointDto(
      date: DateTime.parse((json['date'] ?? '').toString()),
      total: _toDouble(json['total']),
    );
  }
}

class ApiInsightsService {
  ApiInsightsService(this._client);

  final ApiClient _client;

  Future<DashboardSummaryDto> fetchDashboard() async {
    final json = await _client.getJson('/dashboard/');
    return DashboardSummaryDto.fromJson(json);
  }

  Future<List<WeeklyTrendPointDto>> fetchWeeklyTrend() async {
    final list = await _client.getJsonList('/insights/weekly_trend/');
    return list
        .whereType<Map>()
        .map((e) => WeeklyTrendPointDto.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchLowStock({int threshold = 5}) async {
    final list = await _client.getJsonList(
      '/insights/low_stock/',
      query: {
        'threshold': '$threshold',
      },
    );
    return list.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
  }
}
