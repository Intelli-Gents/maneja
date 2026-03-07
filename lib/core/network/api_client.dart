import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException(statusCode: $statusCode, body: $body)';
}

class ApiClient {
  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath')
        .replace(queryParameters: queryParameters);
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final response = await _httpClient.get(
      _uri(path, query),
      headers: {
        'Accept': 'application/json',
        ...?headers,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw FormatException('Expected JSON object but got: ${decoded.runtimeType}');
  }

  Future<List<dynamic>> getJsonList(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final response = await _httpClient.get(
      _uri(path, query),
      headers: {
        'Accept': 'application/json',
        ...?headers,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) return decoded;

    if (decoded is Map) {
      final map = decoded.cast<String, dynamic>();

      dynamic tryGetList(dynamic v) {
        if (v is List) return v;
        if (v is Map && v['results'] is List) return v['results'];
        if (v is Map && v['items'] is List) return v['items'];
        if (v is Map && v['data'] is List) return v['data'];
        return null;
      }

      final direct =
          tryGetList(map['results']) ?? tryGetList(map['items']) ?? tryGetList(map['data']);
      if (direct is List) return direct;

      // As a last resort, return the first List-like value we find.
      for (final v in map.values) {
        final candidate = tryGetList(v);
        if (candidate is List) return candidate;
      }
    }

    throw FormatException('Expected JSON array but got: ${decoded.runtimeType}');
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final response = await _httpClient.post(
      _uri(path, query),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, response.body);
    }

    if (response.body.trim().isEmpty) return <String, dynamic>{};

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;

    if (decoded is Map) {
      final map = decoded.cast<String, dynamic>();
      final nested = map['data'] ?? map['result'] ?? map['transaction'] ?? map['item'];
      if (nested is Map) return nested.cast<String, dynamic>();
    }

    if (decoded is List && decoded.isNotEmpty) {
      final first = decoded.first;
      if (first is Map) return first.cast<String, dynamic>();
    }

    throw FormatException('Expected JSON object but got: ${decoded.runtimeType}');
  }
}
