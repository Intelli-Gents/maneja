import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:maneja/core/network/api_client.dart';
import 'package:maneja/models/confirm_and_record_response.dart';
import 'package:maneja/models/voice_transcribe_response.dart';

class ApiVoiceService {
  ApiVoiceService(this._client);

  final ApiClient _client;

  Uri _uri(String path) {
    final base = _client.baseUrl.endsWith('/')
        ? _client.baseUrl.substring(0, _client.baseUrl.length - 1)
        : _client.baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalizedPath');
  }

  Future<VoiceTranscribeResponse> transcribe({required File audioFile}) async {
    final request = http.MultipartRequest(
      'POST',
      _uri('/voice/transcribe/'),
    );

    request.headers['Accept'] = 'application/json';

    final filename = audioFile.path.split(Platform.pathSeparator).last;
    request.files.add(
      await http.MultipartFile.fromPath(
        'audio',
        audioFile.path,
        filename: filename,
      ),
    );

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw ApiException(streamed.statusCode, body);
    }

    final decoded = jsonDecode(body);
    if (decoded is Map) {
      return VoiceTranscribeResponse.fromJson(decoded.cast<String, dynamic>());
    }

    throw FormatException('Expected JSON object but got: ${decoded.runtimeType}');
  }

  Future<ConfirmAndRecordResponse> confirmAndRecord({required String text}) async {
    final json = await _client.postJson(
      '/voice/confirm_and_record/',
      body: {
        'text': text,
        'source': 'voice',
      },
    );

    return ConfirmAndRecordResponse.fromJson(json);
  }
}
