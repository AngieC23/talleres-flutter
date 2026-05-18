import 'package:flutter/material.dart';

import '../../auth/auth_models.dart';
import '../../auth/auth_scope.dart';
import 'evidence_screen.dart';
import 'login_screen.dart';

class AuthEntryScreen extends StatelessWidget {
  const AuthEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AuthScope.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;

        if (state.status == AuthStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == AuthStatus.authenticated && state.session != null) {
          return const EvidenceScreen();
        }

        return LoginScreen(message: state.message);
      },
    );
  }
}
