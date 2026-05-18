import 'package:flutter_test/flutter_test.dart';
import 'package:taller1_app/auth/auth_remote_service.dart';

void main() {
  test(
    'AuthRemoteService login returns access token',
    () async {
      final svc = AuthRemoteService();

      final result = await svc.login(
        email: 'test_jwt_user_20260515@example.com',
        password: 'TestPass123!',
      );

      expect(result.accessToken, isNotEmpty);
      // Print a short confirmation for logs
      print('Login OK - token length: ${result.accessToken.length}');
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
