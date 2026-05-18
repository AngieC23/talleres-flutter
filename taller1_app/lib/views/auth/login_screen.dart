import 'package:flutter/material.dart';

import '../../auth/auth_models.dart';
import '../../auth/auth_scope.dart';
import '../../widgets/custom_drawer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.message});

  final String? message;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Usuario JWT');
  final _emailController = TextEditingController(text: 'admin@alpha.com');
  final _passwordController = TextEditingController(text: '12345678');

  String _selectedTheme = 'system';
  String _selectedLanguage = 'es';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AuthScope.of(context);
    final isLoading = controller.state.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Login JWT')),
      drawer: const CustomDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6F2EC), Color(0xFFE8F0FF), Color(0xFFF9DCC9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  child: const Icon(
                                    Icons.lock_outline,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Autenticación JWT',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Consume el backend, guarda el perfil en prefs y el token en storage seguro.',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre',
                              prefixIcon: Icon(Icons.badge_outlined),
                              border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Ingresa un correo';
                              }

                              if (!text.contains('@')) {
                                return 'Ingresa un correo válido';
                              }

                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icon(Icons.key_outlined),
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Ingresa una contraseña';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedTheme,
                                  decoration: const InputDecoration(
                                    labelText: 'Tema',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'system',
                                      child: Text('Sistema'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'light',
                                      child: Text('Claro'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'dark',
                                      child: Text('Oscuro'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value == null) {
                                      return;
                                    }

                                    setState(() {
                                      _selectedTheme = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedLanguage,
                                  decoration: const InputDecoration(
                                    labelText: 'Idioma',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'es',
                                      child: Text('Español'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'en',
                                      child: Text('English'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value == null) {
                                      return;
                                    }

                                    setState(() {
                                      _selectedLanguage = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          if (widget.message != null &&
                              widget.message!.isNotEmpty)
                            _StatusBanner(
                              message: widget.message!,
                              isError:
                                  controller.state.status == AuthStatus.error,
                            )
                          else if (controller.state.message != null &&
                              controller.state.message!.isNotEmpty)
                            _StatusBanner(
                              message: controller.state.message!,
                              isError:
                                  controller.state.status == AuthStatus.error,
                            ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              FilledButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        if (!_formKey.currentState!
                                            .validate()) {
                                          return;
                                        }

                                        await controller.login(
                                          name: _nameController.text,
                                          email: _emailController.text,
                                          password: _passwordController.text,
                                          themePreference: _selectedTheme,
                                          languagePreference: _selectedLanguage,
                                        );
                                      },
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.login),
                                label: const Text('Iniciar sesión'),
                              ),
                              OutlinedButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        if (!_formKey.currentState!
                                            .validate()) {
                                          return;
                                        }

                                        await controller.createUserAndLogin(
                                          name: _nameController.text,
                                          email: _emailController.text,
                                          password: _passwordController.text,
                                          themePreference: _selectedTheme,
                                          languagePreference: _selectedLanguage,
                                        );
                                      },
                                icon: const Icon(Icons.person_add_alt_1),
                                label: const Text('Crear usuario y entrar'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Usa el usuario de ejemplo de Swagger si ya existe en el backend, o crea uno nuevo con el botón de registro.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isError
        ? const Color(0xFFFFEBEE)
        : const Color(0xFFE8F5E9);
    final foregroundColor = isError
        ? const Color(0xFFC62828)
        : const Color(0xFF2E7D32);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: foregroundColor.withValues(alpha: 0.25)),
      ),
      child: Text(
        message,
        style: TextStyle(color: foregroundColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}
