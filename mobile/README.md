
# Pushtaka Mobile App

Aplikasi manajemen perpustakaan berbasis Flutter dengan Logic Clean Architecture & GetX State Management.

## Arsitektur & Teknologi

*   **Language**: Dart
*   **Framework**: Flutter
*   **State Management**: GetX
*   **Navigation**: GetX (Named Routes)
*   **Architecture**: Clean Architecture

## Struktur Project (Clean Architecture + GetX)

Project ini menerapkan Clean Architecture dengan pembagian layer sebagai berikut:

- **Domain Layer** (Inner Layer): Berisi Entity, Repository Interface, dan UseCases.
- **Data Layer**: Berisi Model (FromJson/ToJson), Repository Implementation, dan Remote Data Sources.
- **Presentation Layer**: Berisi UI (Pages/Widgets) dan **GetX Controllers**.
- **Core**: Berisi Routings, Bindings, dan utilitas umum.

### Struktur Folder:

```
lib/
├── core/
│   ├── routes/             # AppPages & AppRoutes
│   └── ...
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   │   ├── controllers/ # GetxController
│   │   │   └── pages/       # GetView / Widgets
│   │   └── ...
│   ├── book/
│   └── transaction/
└── main.dart               # Entry point (GetMaterialApp)
```

## Setup

1.  Jalankan `flutter pub get`
2.  Jalankan `flutter run`
