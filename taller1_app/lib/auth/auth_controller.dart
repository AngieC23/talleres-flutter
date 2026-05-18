import 'package:flutter/foundation.dart';

import 'auth_local_storage.dart';
import 'auth_models.dart';
import 'auth_remote_service.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    AuthRemoteService? remoteService,
    AuthLocalStorageService? localStorageService,
  }) : _remoteService = remoteService ?? AuthRemoteService(),
       _localStorageService = localStorageService ?? AuthLocalStorageService();

  final AuthRemoteService _remoteService;
  final AuthLocalStorageService _localStorageService;

  AuthState _state = const AuthState.loading();

  AuthState get state => _state;
  AuthSession? get session => _state.session;
  bool get isLoading => _state.status == AuthStatus.loading;

  Future<void> loadStoredSession() async {
    _setState(const AuthState.loading());

    final session = await _localStorageService.readSession();
    if (session == null || !session.hasToken) {
      _setState(
        const AuthState.unauthenticated(
          message: 'No hay una sesión local activa',
        ),
      );
      return;
    }

    _setState(AuthState.authenticated(session: session));
  }

  Future<void> login({
    required String name,
    required String email,
    required String password,
    required String themePreference,
    required String languagePreference,
  }) async {
    final preparedName = _normalizeName(name, email);
    final preparedEmail = email.trim();

    if (preparedEmail.isEmpty || password.trim().isEmpty) {
      _setState(
        const AuthState.error(message: 'Debes completar email y contraseña'),
      );
      return;
    }

    _setState(const AuthState.loading());

    try {
      final result = await _remoteService.login(
        email: preparedEmail,
        password: password,
      );
      final session = AuthSession(
        profile: result.profile.copyWith(
          name: result.profile.name.isEmpty
              ? preparedName
              : result.profile.name,
          email: result.profile.email.isEmpty
              ? preparedEmail
              : result.profile.email,
          themePreference: themePreference,
          languagePreference: languagePreference,
        ),
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await _localStorageService.saveSession(session);
      _setState(
        AuthState.authenticated(
          session: session,
          message: 'Sesion iniciada correctamente',
        ),
      );
    } on AuthRemoteException catch (error) {
      _setState(
        AuthState.error(
          message: _friendlyMessage(error),
          session: _state.session,
        ),
      );
    } catch (error) {
      _setState(
        AuthState.error(
          message: 'No fue posible iniciar sesion: $error',
          session: _state.session,
        ),
      );
    }
  }

  Future<void> createUserAndLogin({
    required String name,
    required String email,
    required String password,
    required String themePreference,
    required String languagePreference,
  }) async {
    final preparedName = _normalizeName(name, email);
    final preparedEmail = email.trim();

    if (preparedName.isEmpty ||
        preparedEmail.isEmpty ||
        password.trim().isEmpty) {
      _setState(
        const AuthState.error(
          message: 'Debes completar nombre, email y contraseña',
        ),
      );
      return;
    }

    _setState(const AuthState.loading());

    try {
      await _remoteService.createUser(
        name: preparedName,
        email: preparedEmail,
        password: password,
      );
      await login(
        name: preparedName,
        email: preparedEmail,
        password: password,
        themePreference: themePreference,
        languagePreference: languagePreference,
      );
    } on AuthRemoteException catch (error) {
      final isLikelyDuplicate =
          error.statusCode == 422 || error.statusCode == 409;
      if (isLikelyDuplicate) {
        await login(
          name: preparedName,
          email: preparedEmail,
          password: password,
          themePreference: themePreference,
          languagePreference: languagePreference,
        );
        return;
      }

      _setState(AuthState.error(message: _friendlyMessage(error)));
    } catch (error) {
      _setState(
        AuthState.error(message: 'No fue posible crear el usuario: $error'),
      );
    }
  }

  Future<void> logout() async {
    _setState(const AuthState.loading());
    await _localStorageService.clearSession();
    _setState(
      const AuthState.unauthenticated(
        message: 'Sesion cerrada y datos locales eliminados',
      ),
    );
  }

  Future<bool> hasSecureToken() => _localStorageService.hasToken();

  Future<AuthSession?> loadLocalSnapshot() =>
      _localStorageService.readSession();

  void _setState(AuthState nextState) {
    _state = nextState;
    notifyListeners();
  }

  String _normalizeName(String name, String email) {
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty) {
      return trimmedName;
    }

    final localPart = email.split('@').first.trim();
    if (localPart.isEmpty) {
      return 'Usuario JWT';
    }

    return localPart.replaceAll(RegExp(r'[._-]+'), ' ').trim();
  }

  String _friendlyMessage(AuthRemoteException error) {
    if (error.statusCode == 401) {
      return 'Credenciales inválidas. Verifica email y contraseña.';
    }

    if (error.statusCode == 422) {
      return 'La API rechazó la solicitud por validación.';
    }

    return error.message;
  }
}
