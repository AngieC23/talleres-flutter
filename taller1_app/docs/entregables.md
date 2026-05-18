# Entregables - JWT Flutter

## 1. Repositorio

- URL: https://github.com/AngieC23/talleres-flutter.git
- Rama de trabajo: `feature/taller_jwt`
- Ramas base del flujo GitFlow: `dev` y `main`

## 2. Evidencia de consumo del API

La documentación del backend se valida en Swagger UI: `https://parking.visiontic.com.co/api/documentation`.

Captura de referencia tomada en esta sesión: Swagger UI con los bloques de Autenticación, Usuarios y Establecimientos visibles.

Pruebas ejecutadas contra el backend:

1. Registro de usuario con `POST /api/users` usando `application/x-www-form-urlencoded`.
2. Inicio de sesión con `POST /api/login` usando el usuario creado.
3. Ejecución de prueba automática en Flutter con `flutter test test/auth_remote_service_test.dart`.

Resultado de login verificado:

```json
{
  "success": true,
  "type": "bearer",
  "expires_in": 3600,
  "token": "<jwt_token>",
  "user": {
    "id": 89,
    "name": "Test JWT User",
    "email": "test_jwt_user_20260515@example.com"
  }
}
```

Salida de la prueba automatizada:

```text
Login OK - token length: 332
All tests passed!
```

## 3. Cómo se almacenan los datos del login

La lógica está separada en capas:

- Servicio remoto: [lib/auth/auth_remote_service.dart](../lib/auth/auth_remote_service.dart)
- Almacenamiento local: [lib/auth/auth_local_storage.dart](../lib/auth/auth_local_storage.dart)
- Controlador de estado: [lib/auth/auth_controller.dart](../lib/auth/auth_controller.dart)

### Datos no sensibles

Se guardan en `SharedPreferences`:

- `auth_user_name`
- `auth_user_email`
- `auth_theme_preference`
- `auth_language_preference`

### Datos sensibles

Se guardan en `FlutterSecureStorage`:

- `auth_access_token`
- `auth_refresh_token`

### Flujo

1. El login llama al backend y recibe el JWT.
2. El perfil del usuario se normaliza en `AuthSession`.
3. El perfil se guarda en `SharedPreferences`.
4. Los tokens se guardan en `FlutterSecureStorage`.
5. La pantalla de evidencia lee ambos orígenes para mostrar el estado local.

## 4. Evidencia funcional de la app

La app centraliza el flujo en:

- Entrada de autenticación: [lib/views/auth/auth_entry_screen.dart](../lib/views/auth/auth_entry_screen.dart)
- Formulario de login: [lib/views/auth/login_screen.dart](../lib/views/auth/login_screen.dart)
- Vista de evidencia local: [lib/views/auth/evidence_screen.dart](../lib/views/auth/evidence_screen.dart)


