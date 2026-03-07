import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  writeValue({required String key, required String value}) async {

    await storage.write(key: key, value: value);

  }

  readValue({required String key}) async {

    return await storage.read(key: key);

  }

}