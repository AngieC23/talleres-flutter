import 'package:flutter/material.dart';

import '../../auth/auth_models.dart';
import '../../auth/auth_scope.dart';
import '../../widgets/custom_drawer.dart';

class EvidenceScreen extends StatelessWidget {
  const EvidenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AuthScope.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final session = controller.session;

        return Scaffold(
          appBar: AppBar(title: const Text('Evidencia local')),
          drawer: const CustomDrawer(),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF5F7FA),
                  Color(0xFFE7F0FF),
                  Color(0xFFFBE9E7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderCard(
                      title: 'Datos almacenados localmente',
                      subtitle:
                          'Nombre y correo en SharedPreferences, token en Flutter Secure Storage.',
                      isLoggedIn: session != null && session.hasToken,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _DataCard(
                            title: 'Nombre',
                            value: session?.profile.name.isNotEmpty == true
                                ? session!.profile.name
                                : 'Sin nombre',
                            icon: Icons.badge_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DataCard(
                            title: 'Correo',
                            value: session?.profile.email.isNotEmpty == true
                                ? session!.profile.email
                                : 'Sin correo',
                            icon: Icons.email_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _DataCard(
                            title: 'Tema',
                            value: session?.profile.themePreference ?? 'system',
                            icon: Icons.palette_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DataCard(
                            title: 'Idioma',
                            value: session?.profile.languagePreference ?? 'es',
                            icon: Icons.language_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _TokenCard(session: session),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: session == null
                              ? null
                              : () async {
                                  await controller.logout();
                                },
                          icon: const Icon(Icons.logout),
                          label: const Text('Cerrar sesión'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await controller.loadStoredSession();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Recargar evidencia'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (controller.state.message != null &&
                        controller.state.message!.isNotEmpty)
                      _InfoBanner(message: controller.state.message!),
                    const SizedBox(height: 18),
                    const Text(
                      'Este módulo deja visible el estado de la sesión para sustentar la evidencia del consumo de API y del almacenamiento local.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.isLoggedIn,
  });

  final String title;
  final String subtitle;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.92),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: isLoggedIn
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFC62828),
              child: Icon(
                isLoggedIn ? Icons.verified_user : Icons.no_accounts_outlined,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _SessionChip(isLoggedIn: isLoggedIn),
          ],
        ),
      ),
    );
  }
}

class _SessionChip extends StatelessWidget {
  const _SessionChip({required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    final color = isLoggedIn
        ? const Color(0xFF2E7D32)
        : const Color(0xFFC62828);
    final label = isLoggedIn ? 'token presente' : 'sin token';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  const _DataCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.92),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TokenCard extends StatelessWidget {
  const _TokenCard({required this.session});

  final AuthSession? session;

  @override
  Widget build(BuildContext context) {
    final token = session?.accessToken ?? '';
    final refreshToken = session?.refreshToken ?? '';
    final hasToken = token.isNotEmpty;

    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.92),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasToken ? Icons.lock : Icons.lock_open,
                  color: hasToken
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Tokens',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Access token: ${hasToken ? _maskToken(token) : 'sin token'}'),
            const SizedBox(height: 6),
            Text(
              'Refresh token: ${refreshToken.isNotEmpty ? _maskToken(refreshToken) : 'sin refresh token'}',
            ),
            const SizedBox(height: 6),
            Text('Longitud access token: ${token.length} caracteres'),
          ],
        ),
      ),
    );
  }

  String _maskToken(String token) {
    if (token.length <= 10) {
      return token;
    }

    return '${token.substring(0, 6)}...${token.substring(token.length - 4)}';
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF2E7D32),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
