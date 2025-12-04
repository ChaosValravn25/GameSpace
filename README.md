# GameSpace

Una aplicación móvil cross-platform desarrollada con Flutter para descubrir y gestionar tu colección personal de videojuegos.

## Descripción

**GameSpace** es una aplicación que permite a los usuarios explorar información detallada sobre videojuegos, mantener su colección personal y acceder a contenido tanto online como offline. La aplicación consume la API de [RAWG.io](https://rawg.io/apidocs) para obtener información actualizada sobre miles de videojuegos.

## Características

### Funcionalidades Principales

- **Información Remota y Local**:
  - Consume API REST de RAWG.io
  - Almacenamiento local con SQLite para trabajo offline
  - Caché inteligente de búsquedas y juegos

- **Interfaces Modernas**:
  - Diseño Material Design 3
  - Navegación con Bottom Navigation Bar
  - Pantallas: Home, Explorar, Colección, Preferencias
  - Animaciones y transiciones fluidas

- **Gestión de Colección**:
  - Marcar juegos como favoritos
  - Organizar en categorías: Jugando, Completados, Lista de Deseos
  - CRUD completo de colección personal

- **Búsqueda y Filtros**:
  - Búsqueda de juegos en tiempo real
  - Filtros por género y plataforma
  - Historial de búsquedas

- **Internacionalización**:
  - Soporte para Español e Inglés
  - Cambio de idioma en tiempo real

- **Funcionalidad Offline/Online**:
  - Detección automática de conectividad
  - Indicador visual del estado de conexión
  - Acceso a contenido guardado sin internet

- **Integración con Apps Externas**:
  - Compartir juegos (Share Plus)
  - Abrir enlaces externos (URL Launcher)

- **Personalización**:
  - Modo claro y oscuro automático
  - Preferencias de usuario persistentes

## Tecnologías Utilizadas

### Framework y Lenguaje
- Flutter 3.x
- Dart 3.x

## Estructura principal
lib/
├── config/
│   ├── api_constants.dart
│   ├── theme.dart
│  
│       
├── core/
│   ├── network/
│   │   ├── Api_Service.dart
│   │   └── Connectivity_Service.dart
│   └── utils/
├── data/
│   ├── models/
│   │   ├── game.dart
│   │   ├── genre.dart
│   │   └── platform.dart
│   ├── repositories/
│   └── local/
│       └── Database_Helper.dart
├── presentation/
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── explore.dart
│   │   ├── collection.dart
│   │   ├── game_detail.dart
│   │   ├── preferences.dart
│   │   └── about.dart
│   └── widgets/
├── providers/
│   ├── game_provider.dart
│   ├── theme_provider.dart
│   └── locale_provider.dart
├── l10n/
│   ├── app_es.arb
│   └── app_en.arb
└── main.dart


### Diagrama de Flujo

<img width="941" height="751" alt="GameSpace drawio" src="https://github.com/user-attachments/assets/f3ef48cc-e45b-450d-9fde-c966875d94c2" />


### Dependencias Principales

```yaml
dependencies:
  # HTTP & API
  http: ^1.1.0
  dio: ^5.4.0
  
  # State Management
  provider: ^6.1.1
  
  # Persistencia
  sqflite: ^2.3.0
  shared_preferences: ^2.2.2
  
  # UI Components
  cached_network_image: ^3.3.0
  
  # Conectividad
  connectivity_plus: ^5.0.2
  
  # Compartir & URLs
  share_plus: ^7.2.1
  url_launcher: ^6.2.2
  
  # Internacionalización
  intl: ^0.18.1
  
 
