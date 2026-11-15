import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final _storage = FlutterSecureStorage();

Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
  await _storage.write(key: _accessTokenKey, value: accessToken);
  await _storage.write(key: _refreshTokenKey, value: refreshToken);
}

Future<void> saveAccessToken(String accessToken) async{
  await _storage.write(key: _accessTokenKey, value: accessToken);
}

Future<String?> getAccessToken() async{
  return await _storage.read(key: _accessTokenKey);
}

Future<String?> getRefreshToken() async {
  return await _storage.read(key: _refreshTokenKey);
}

Future<bool> hasTokens() async {
  final theAccessToken = await getAccessToken();
  final theRefreshToken = await getRefreshToken();

  return theAccessToken != null && theRefreshToken != null;
}

Future<void> clearTokens() async {
  await _storage.delete(key: _accessTokenKey);
  await _storage.delete(key: _refreshTokenKey);
}
}