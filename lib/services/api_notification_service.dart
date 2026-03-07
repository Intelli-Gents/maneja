import 'package:maneja/core/network/api_client.dart';
import 'package:maneja/models/app_notification.dart';

class ApiNotificationService {
  ApiNotificationService(this._client);

  final ApiClient _client;

  Future<List<AppNotification>> fetchNotifications() async {
    final list = await _client.getJsonList('/notifications/');
    return list
        .whereType<Map>()
        .map((e) => AppNotification.fromJson(e.cast<String, dynamic>()))
        .toList();
  }
}
