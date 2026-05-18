enum AuthStatus { loading, unauthenticated, authenticated, error }

class AuthProfile {
  const AuthProfile({
    required this.name,
    required this.email,
    required this.themePreference,
    required this.languagePreference,
  });

  final String name;
  final String email;
  final String themePreference;
  final String languagePreference;

  AuthProfile copyWith({
    String? name,
    String? email,
    String? themePreference,
    String? languagePreference,
  }) {
    return AuthProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      themePreference: themePreference ?? this.themePreference,
      languagePreference: languagePreference ?? this.languagePreference,
    );
  }
}

class AuthSession {
  const AuthSession({
    required this.profile,
    required this.accessToken,
    this.refreshToken,
  });

  final AuthProfile profile;
  final String accessToken;
  final String? refreshToken;

  bool get hasToken => accessToken.trim().isNotEmpty;

  AuthSession copyWith({
    AuthProfile? profile,
    String? accessToken,
    String? refreshToken,
  }) {
    return AuthSession(
      profile: profile ?? this.profile,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}

class AuthState {
  const AuthState({required this.status, this.session, this.message});

  final AuthStatus status;
  final AuthSession? session;
  final String? message;

  const AuthState.loading()
    : status = AuthStatus.loading,
      session = null,
      message = null;

  const AuthState.unauthenticated({String? message})
    : status = AuthStatus.unauthenticated,
      session = null,
      message = message;

  const AuthState.authenticated({required AuthSession session, String? message})
    : status = AuthStatus.authenticated,
      session = session,
      message = message;

  const AuthState.error({String? message, AuthSession? session})
    : status = AuthStatus.error,
      session = session,
      message = message;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      message: message ?? this.message,
    );
  }
}
