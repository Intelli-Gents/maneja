import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maneja/models/stock_item.dart';
import 'package:maneja/models/transaction.dart';
import 'package:maneja/core/network/api_client.dart';
import 'package:maneja/core/network/api_config.dart';
import 'package:maneja/services/api_insights_service.dart';
import 'package:maneja/services/api_parser_service.dart';
import 'package:maneja/services/api_notification_service.dart';
import 'package:maneja/services/api_stock_service.dart';
import 'package:maneja/services/api_transaction_service.dart';
import 'package:maneja/services/api_voice_service.dart';
import 'package:maneja/services/api_items_service.dart';
import 'package:maneja/services/api_manual_sale_service.dart';
import 'package:maneja/services/api_agent_chat_service.dart';
import 'package:maneja/services/transaction_service.dart';
import 'package:maneja/models/app_notification.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: ApiConfig.baseUrl);
});

final transactionServiceProvider = Provider<TransactionService>((ref) {
  return ApiTransactionService(ref.watch(apiClientProvider));
});

final stockApiServiceProvider = Provider<ApiStockService>((ref) {
  return ApiStockService(ref.watch(apiClientProvider));
});

final itemsApiServiceProvider = Provider<ApiItemsService>((ref) {
  return ApiItemsService(ref.watch(apiClientProvider));
});

final insightsApiServiceProvider = Provider<ApiInsightsService>((ref) {
  return ApiInsightsService(ref.watch(apiClientProvider));
});

final parserApiServiceProvider = Provider<ApiParserService>((ref) {
  return ApiParserService(ref.watch(apiClientProvider));
});

final manualSaleApiServiceProvider = Provider<ApiManualSaleService>((ref) {
  return ApiManualSaleService(ref.watch(apiClientProvider));
});

final agentChatApiServiceProvider = Provider<ApiAgentChatService>((ref) {
  return ApiAgentChatService(ref.watch(apiClientProvider));
});

final voiceApiServiceProvider = Provider<ApiVoiceService>((ref) {
  return ApiVoiceService(ref.watch(apiClientProvider));
});

final notificationsServiceProvider = Provider<ApiNotificationService>((ref) {
  return ApiNotificationService(ref.watch(apiClientProvider));
});

final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final service = ref.watch(notificationsServiceProvider);
  return service.fetchNotifications();
});

final transactionsProvider =
    StateNotifierProvider<TransactionListNotifier, AsyncValue<List<Transaction>>>(
  (ref) {
    final service = ref.watch(transactionServiceProvider);
    return TransactionListNotifier(service);
  },
);

final stockProvider =
    StateNotifierProvider<StockListNotifier, AsyncValue<List<StockItem>>>(
  (ref) {
    final service = ref.watch(stockApiServiceProvider);
    return StockListNotifier(service);
  },
);

class TransactionListNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  TransactionListNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  final TransactionService _service;

  Future<void> load({
    String? period,
    String? search,
    int? limit,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.fetchTransactions(
        period: period,
        search: search,
        limit: limit,
      ),
    );
  }

  void add(Transaction tx) {
    final current = state.value ?? <Transaction>[];
    state = AsyncValue.data([...current, tx]);
  }

  void removeById(String id) {
    final current = state.value ?? <Transaction>[];
    state = AsyncValue.data(current.where((t) => t.id != id).toList());
  }
}

class StockListNotifier extends StateNotifier<AsyncValue<List<StockItem>>> {
  StockListNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  final ApiStockService _service;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_service.fetchStock);
  }
}

class HomeSummary {
  HomeSummary({
    required this.todaySales,
    required this.transactionCount,
    required this.lowStockCount,
  });

  final double todaySales;
  final int transactionCount;
  final int lowStockCount;
}

final dashboardSummaryProvider = FutureProvider<DashboardSummaryDto>((ref) async {
  final service = ref.watch(insightsApiServiceProvider);
  return service.fetchDashboard();
});

final weeklyTrendProvider = FutureProvider<List<WeeklyTrendPointDto>>((ref) async {
  final service = ref.watch(insightsApiServiceProvider);
  return service.fetchWeeklyTrend();
});

final homeSummaryProvider = Provider<AsyncValue<HomeSummary>>((ref) {
  final dashboard = ref.watch(dashboardSummaryProvider);
  return dashboard.whenData(
    (d) => HomeSummary(
      todaySales: d.todaySalesAmount,
      transactionCount: d.transactionCount,
      lowStockCount: d.lowStockCount,
    ),
  );
});

final recentTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((ref) {
  final all = ref.watch(transactionsProvider);
  return all.whenData((items) {
    final sorted = [...items]
      ..sort(
        (a, b) => b.timestamp.compareTo(a.timestamp),
      );
    return sorted.take(10).toList();
  });
});

