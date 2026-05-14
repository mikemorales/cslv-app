# CSLV Manager - Flutter App

Aplicación móvil para la gestión de villas de alquiler, blog, administradores y pagos de CSLV.

## 📱 Características

- **Villas**: CRUD completo con imágenes, tarifas estacionales y disponibilidad
- **Blog**: Gestión de artículos con categorías y etiquetas
- **Administradores**: Gestión de usuarios con roles
- **Pagos Pendientes**: Monitoreo y captura de pagos en tiempo real

## 🚀 Inicio Rápido

### Prerequisites
- Flutter 3.41.9+ ([Instalar Flutter](https://flutter.dev/docs/get-started/install))
- Dart 3.11.5+
- iOS: Xcode 14.0+
- Android: Android Studio + SDK 21+

### Instalación

```bash
cd mobile/cslv-app
flutter pub get
flutter run
```

### Ambientes

Por defecto se ejecuta en desarrollo. Para cambiar el ambiente, editar `lib/main.dart`:

```dart
// Development
ApiConfig.setEnvironment(Environment.development);

// Staging
ApiConfig.setEnvironment(Environment.sandbox);

// Production
ApiConfig.setEnvironment(Environment.production);
```

## 📁 Estructura del Proyecto

```
lib/
├── config/              # Configuración de API
│   └── api_config.dart
├── constants/           # Constantes globales
│   └── app_constants.dart
├── models/              # Modelos de datos (JSON serializable)
│   ├── villa.dart
│   ├── post.dart
│   ├── administrator.dart
│   └── booking.dart
├── services/            # Servicios API
│   ├── base_service.dart
│   ├── villa_service.dart
│   ├── post_service.dart
│   ├── administrator_service.dart
│   └── payment_service.dart
├── screens/             # Pantallas/Páginas (por implementar)
│   ├── villas/
│   ├── posts/
│   ├── administrators/
│   └── payments/
├── providers/           # State management con Riverpod (por implementar)
│   ├── villa_provider.dart
│   ├── post_provider.dart
│   ├── admin_provider.dart
│   └── payment_provider.dart
├── widgets/             # Componentes reutilizables (por implementar)
├── utils/               # Utilidades y helpers (por implementar)
└── main.dart            # Entry point
```

## 🔧 Generación de Código

El proyecto usa `json_serializable` para generar código de serialización JSON.

### Generar archivos .g.dart

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Watch mode (regenera automáticamente al guardar)

```bash
flutter pub run build_runner watch
```

## 📡 API Endpoints

Todos los endpoints están configurados en `lib/config/api_config.dart`:

- **Villas**: `/api/manager/villas`
- **Posts**: `/api/manager/posts`
- **Administrators**: `/api/manager/administrators`
- **Payments**: `/api/manager/payments`

## 🔐 Autenticación

- Token Bearer en header: `Authorization: Bearer {token}`
- Storage seguro usando `flutter_secure_storage`
- Manejo automático de token expirado (401 Unauthorized)

## 📦 Dependencias Principales

- **dio**: Cliente HTTP con interceptores
- **riverpod**: State management
- **provider**: Alternativa para state management
- **cached_network_image**: Descarga y caché de imágenes
- **image_picker**: Selección de imágenes
- **google_maps_flutter**: Mapas interactivos
- **google_fonts**: Fuentes personalizadas
- **shimmer**: Skeleton loaders
- **fluttertoast**: Notificaciones tipo toast

Ver `pubspec.yaml` para la lista completa.

## 🧪 Testing

Por implementar:
- Unit tests para servicios
- Widget tests para pantallas
- Integration tests

## 📝 Notas Importantes

### Modelos
- Todos los modelos generan código JSON con `json_serializable`
- Ejecutar build_runner después de cualquier cambio en modelos
- Los modelos incluyen métodos `copyWith()` para inmutabilidad

### Servicios
- `BaseService` maneja:
  - Todos los métodos HTTP (GET, POST, PUT, DELETE)
  - Interceptores para autenticación
  - Manejo centralizado de errores
  - Timeouts configurables
- Cada recurso tiene su propio servicio heredando de `BaseService`

### API Config
- Switch automático entre ambientes (dev, staging, prod)
- URLs y endpoints centralizados
- Configurables sin tocar código

## 🚨 Próximos Pasos

1. **Implementar Providers Riverpod**
   - `VillaProvider` con listado paginado
   - `PostProvider` con filtros
   - `AdministratorProvider`
   - `PaymentProvider` con auto-refresh

2. **Crear Screens**
   - Pantallas de listado para cada módulo
   - Formularios de creación/edición
   - Modales y diálogos

3. **Widgets Reutilizables**
   - DataTable personalizada
   - FormFields validados
   - Paginación
   - Loading states y error handling

4. **Validaciones y Transformaciones**
   - Capitalizar nombres
   - Minúsculas para emails
   - Formatos de teléfono
   - Validación de URLs

5. **UI/UX**
   - Material Design 3
   - Temas dark/light
   - Animaciones y transiciones

## 📚 Documentación

- [Flutter Docs](https://flutter.dev/docs)
- [Riverpod Docs](https://riverpod.dev)
- [Dio Package](https://pub.dev/packages/dio)
- [JSON Serializable](https://pub.dev/packages/json_serializable)

## 👤 Author

CSLV App Development

## 📄 License

Proprietary - CSLV 2024

---

**Actualizado**: 14 de Mayo de 2024  
**Versión de Flutter**: 3.41.9  
**Versión de Dart**: 3.11.5
