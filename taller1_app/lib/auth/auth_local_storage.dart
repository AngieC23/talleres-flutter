import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_models.dart';

class AuthLocalStorageService {
  AuthLocalStorageService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _nameKey = 'auth_user_name';
  static const String _emailKey = 'auth_user_email';
  static const String _themeKey = 'auth_theme_preference';
  static const String _languageKey = 'auth_language_preference';
  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';

  final FlutterSecureStorage _secureStorage;

  Future<void> saveSession(AuthSession session) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_nameKey, session.profile.name);
    await preferences.setString(_emailKey, session.profile.email);
    await preferences.setString(_themeKey, session.profile.themePreference);
    await preferences.setString(
      _languageKey,
      session.profile.languagePreference,
    );

    await _secureStorage.write(
      key: _accessTokenKey,
      value: session.accessToken,
    );
    await _secureStorage.write(
      key: _refreshTokenKey,
      value: session.refreshToken,
    );
  }

  Future<AuthSession?> readSession() async {
    final preferences = await SharedPreferences.getInstance();
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);

    final name = preferences.getString(_nameKey);
    final email = preferences.getString(_emailKey);
    final themePreference = preferences.getString(_themeKey) ?? 'system';
    final languagePreference = preferences.getString(_languageKey) ?? 'es';

    if ((accessToken == null || accessToken.isEmpty) &&
        (name == null || name.isEmpty) &&
        (email == null || email.isEmpty)) {
      return null;
    }

    return AuthSession(
      profile: AuthProfile(
        name: name ?? 'Usuario JWT',
        email: email ?? '',
        themePreference: themePreference,
        languagePreference: languagePreference,
      ),
      accessToken: accessToken ?? '',
      refreshToken: refreshToken,
    );
  }

  Future<void> clearSession() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_nameKey);
    await preferences.remove(_emailKey);
    await preferences.remove(_themeKey);
    await preferences.remove(_languageKey);

    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  Future<bool> hasToken() async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }
}
