import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_models.dart';

class AuthRemoteException implements Exception {
  const AuthRemoteException({
    required this.message,
    required this.statusCode,
    this.responseBody,
  });

  final String message;
  final int statusCode;
  final Object? responseBody;

  @override
  String toString() => 'AuthRemoteException($statusCode): $message';
}

class AuthApiResult {
  const AuthApiResult({
    required this.profile,
    required this.accessToken,
    this.refreshToken,
    required this.rawPayload,
  });

  final AuthProfile profile;
  final String accessToken;
  final String? refreshToken;
  final Map<String, dynamic> rawPayload;

  factory AuthApiResult.fromPayload(
    Map<String, dynamic> payload, {
    String? fallbackName,
    String? fallbackEmail,
  }) {
    final accessToken =
        _extractString(payload, const [
          'access_token',
          'accessToken',
          'token',
          'jwt',
        ]) ??
        '';
    final refreshToken = _extractString(payload, const [
      'refresh_token',
      'refreshToken',
      'refresh',
    ]);
    final name =
        _extractString(payload, const [
          'name',
          'nombre',
          'full_name',
          'fullName',
        ]) ??
        fallbackName ??
        '';
    final email =
        _extractString(payload, const ['email', 'correo', 'mail']) ??
        fallbackEmail ??
        '';
    final themePreference =
        _extractString(payload, const ['theme', 'tema', 'themePreference']) ??
        'system';
    final languagePreference =
        _extractString(payload, const [
          'language',
          'idioma',
          'languagePreference',
        ]) ??
        'es';

    return AuthApiResult(
      profile: AuthProfile(
        name: name.isEmpty ? _buildFallbackName(email) : name,
        email: email,
        themePreference: themePreference,
        languagePreference: languagePreference,
      ),
      accessToken: accessToken,
      refreshToken: refreshToken,
      rawPayload: payload,
    );
  }
}

class AuthRemoteService {
  AuthRemoteService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://parking.visiontic.com.co/api';

  final http.Client _client;

  Future<AuthApiResult> login({
    required String email,
    required String password,
  }) {
    return _sendJson(
      path: '/login',
      body: <String, dynamic>{'email': email, 'password': password},
      fallbackEmail: email,
    );
  }

  Future<AuthApiResult> createUser({
    required String name,
    required String email,
    required String password,
  }) {
    return _sendJson(
      path: '/users',
      body: <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
      },
      fallbackName: name,
      fallbackEmail: email,
      expectSuccessCodes: const {201, 200},
    );
  }

  Future<Map<String, dynamic>> fetchProfile(String token) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/perfil'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final decoded = _decodeBody(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _asMap(decoded);
    }

    throw AuthRemoteException(
      message: _extractErrorMessage(decoded) ?? 'No fue posible leer el perfil',
      statusCode: response.statusCode,
      responseBody: decoded,
    );
  }

  Future<AuthApiResult> _sendJson({
    required String path,
    required Map<String, dynamic> body,
    String? fallbackName,
    String? fallbackEmail,
    Set<int> expectSuccessCodes = const {200},
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: const <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    final decoded = _decodeBody(response.body);
    if (expectSuccessCodes.contains(response.statusCode)) {
      final payload = _asMap(decoded);
      return AuthApiResult.fromPayload(
        payload,
        fallbackName: fallbackName,
        fallbackEmail: fallbackEmail,
      );
    }

    throw AuthRemoteException(
      message: _extractErrorMessage(decoded) ?? 'La API rechazo la solicitud',
      statusCode: response.statusCode,
      responseBody: decoded,
    );
  }
}

dynamic _decodeBody(String body) {
  if (body.trim().isEmpty) {
    return <String, dynamic>{};
  }

  try {
    return jsonDecode(body);
  } catch (_) {
    return <String, dynamic>{'message': body};
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return value.map((key, dynamic innerValue) => MapEntry('$key', innerValue));
  }

  return <String, dynamic>{'data': value};
}

String? _extractString(dynamic value, List<String> keys) {
  if (value is Map) {
    for (final entry in value.entries) {
      final key = '${entry.key}';
      final currentValue = entry.value;
      if (keys.contains(key) &&
          currentValue is String &&
          currentValue.trim().isNotEmpty) {
        return currentValue;
      }
    }

    for (final entry in value.entries) {
      final nested = _extractString(entry.value, keys);
      if (nested != null && nested.trim().isNotEmpty) {
        return nested;
      }
    }
  } else if (value is List) {
    for (final item in value) {
      final nested = _extractString(item, keys);
      if (nested != null && nested.trim().isNotEmpty) {
        return nested;
      }
    }
  }

  return null;
}

String? _extractErrorMessage(dynamic value) {
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }

  if (value is Map) {
    final candidate = _extractString(value, const [
      'message',
      'error',
      'detail',
      'description',
    ]);
    if (candidate != null && candidate.trim().isNotEmpty) {
      return candidate;
    }
  }

  return null;
}

String _buildFallbackName(String email) {
  if (email.trim().isEmpty) {
    return 'Usuario JWT';
  }

  final localPart = email.split('@').first.trim();
  if (localPart.isEmpty) {
    return 'Usuario JWT';
  }

  final normalized = localPart.replaceAll(RegExp(r'[._-]+'), ' ').trim();
  if (normalized.isEmpty) {
    return 'Usuario JWT';
  }

  return normalized
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}
