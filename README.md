# Pushtaka - Sistem Informasi Perpustakaan

Sistem Informasi Perpustakaan Lengkap (Full Stack) berbasis Microservices.
Mencakup **Aplikasi Mobile (Flutter)** untuk pengguna dan **Web Dashboard** serta **Backend API** untuk manajemen.

[![Download APK](https://img.shields.io/badge/Download-APK-green?style=for-the-badge&logo=android)](https://github.com/marhaendev/pushtaka/raw/main/apk/pushtaka-v1.0.0.apk)

## Arsitektur

Project ini menggunakan arsitektur **Microservices** dengan teknologi berikut:
*   **Mobile**: Flutter (GetX, Shared Preferences)
*   **Backend**: Go (Fiber Framework)
*   **Database**: PostgreSQL
*   **Message Broker**: RabbitMQ
*   **Gateway**: Traefik (Reverse Proxy)
*   **Containerization**: Docker & Docker Compose

## Dokumentasi Lengkap

Silakan merujuk ke folder `docs/` untuk panduan lengkap:

*   [**Panduan Instalasi**](./docs/installation.md)
    *   **Instalasi API & Web**: Panduan deployment server (VPS/Docker).
    *   **Instalasi Mobile**: Panduan build aplikasi Android & iOS (Flutter).
*   [**Dokumentasi API**](./docs/api.md) - Referensi lengkap endpoint API dan format response.

## Struktur Project

*   `api/services/` - Source code microservices (Identity, Book, Transaction).
*   `web/` - Frontend Web (Landing Page).
*   `mobile/` - Aplikasi Mobile (Flutter).
*   `pkg/` - Shared packages (Auth, Database, Messaging).
*   `docs/` - Dokumentasi project.
*   `docker-compose.yml` - Konfigurasi infrastruktur (API, Database, Gateway).

## Credits

Project ini dikembangkan oleh **Hasan Askari** (aka **Marhaendev**).

*   **Landing Page**: [pushtaka.xapi.my.id](https://pushtaka.xapi.my.id)
*   **Personal Website**: [hasanaskari.com](https://hasanaskari.com)
*   **Email**: hasanaskari.id

## License

Project ini dilisensikan di bawah [PolyForm Noncommercial License 1.0.0](./LICENSE).
**Hanya untuk penggunaan non-komersial.**
