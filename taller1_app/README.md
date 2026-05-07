# taller1_app

Repositorio de la asignatura para el flujo de publicación con Firebase App Distribution.

## Flujo general

1. Generar el APK con `flutter build apk`.
2. Subir el APK a Firebase App Distribution.
3. Agregar testers al grupo de QA.
4. Instalar el build desde el correo o el enlace de invitación.
5. Validar la app en un dispositivo Android físico.
6. Publicar una actualización con un nuevo `versionName` y `versionCode`.

## Publicación

### 1. Preparar la versión

- Mantener el versionado en `pubspec.yaml` con el formato `version: 1.0.1+2`.
- Incrementar primero el nombre visible de versión (`1.0.0` -> `1.0.1`) y luego el número de build (`+1` -> `+2`) para cada nueva distribución.
- Verificar que el `applicationId` usado en Firebase coincida con `android/app/build.gradle.kts`.

### 2. Generar el APK

```bash
flutter build apk
```

El archivo de salida esperado queda en `build/app/outputs/flutter-apk/app-release.apk`.

### 3. Configurar Firebase App Distribution

- Abrir el proyecto en Firebase Console.
- Registrar la app Android usando el `applicationId` del proyecto.
- Ir a `App Distribution > Testers & Groups`.
- Crear el grupo `QA_Clase`.
- Agregar el tester `dduran@uceva.edu.co`.
- Subir el APK en `Releases` y asignarlo al grupo `QA_Clase`.
- Escribir release notes claras con fecha, cambios y responsables.

### 4. Verificar la instalación

- Confirmar que el tester reciba la invitación por correo o el enlace de instalación.
- Instalar el APK en un dispositivo Android físico.
- Abrir la app y validar que arranque sin errores.

### 5. Publicar la actualización

- Cambiar la versión a algo como `1.0.1+2`.
- Generar de nuevo el APK.
- Subir la nueva release en App Distribution.
- Comparar la evidencia anterior y la nueva en el panel de `Releases`.

## Permisos Android

Esta app no usa red explícitamente en el código actual, así que no se agregó un permiso extra como `INTERNET`. Si en el futuro se consume una API o Firebase desde la app, el permiso debe revisarse otra vez en `android/app/src/main/AndroidManifest.xml`.

## Bitácora QA

Usar una tabla breve en el PDF o en una nota aparte con este formato:

| Versión | Fecha | Cambios | Incidencias | Estado |
| --- | --- | --- | --- | --- |
| 1.0.0+1 | YYYY-MM-DD | Versión base | Sin incidencias críticas | Aprobado |
| 1.0.1+2 | YYYY-MM-DD | Ajustes de publicación y documentación | Pendiente de confirmar instalación | En prueba |

## Evidencias a entregar

- Captura de `Releases` en App Distribution con la versión visible.
- Captura de `Testers & Groups` mostrando `dduran@uceva.edu.co`.
- Captura del correo de invitación recibido.
- Captura o foto de la app instalada y abierta.
- Evidencia de actualización entre `1.0.0` y `1.0.1`.
- PDF unificado con la URL del repositorio en la primera página.

## GitFlow

- Rama de trabajo: `feature/app_distribution`.
- Flujo esperado: `feature/app_distribution -> dev -> main` mediante PR y merge.

## Notas rápidas

- El `applicationId` actual es `com.example.taller1_app`.
- El build de release usa la configuración de firma por defecto del proyecto.
- Si más adelante se agrega un backend o autenticación, conviene completar también la sección de credenciales de prueba en las release notes.
