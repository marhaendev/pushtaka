# Panduan Instalasi Pushtaka

Dokumen ini mencakup panduan instalasi untuk dua bagian utama sistem:
1.  **API & Web** (Deployment ke VPS)
2.  **Mobile App** (Build Android/iOS)

---

## 1. Instalasi API & Web (VPS Deployment)

Panduan ini menjelaskan cara men-deploy aplikasi Pushtaka (Backend API & Frontend Web) ke Virtual Private Server (VPS) menggunakan Docker Compose.

### Prasyarat VPS
*   **OS**: AlmaLinux 9 (Direkomendasikan).
*   **Docker & Docker Compose**: Sudah terinstall.
*   **Domain**: Menggunakan Cloudflare (Direkomendasikan untuk DNS).
*   **Ports**: Pastikan port 80 dan 443 terbuka.

### Langkah-langkah

#### A. Persiapan Server
Masuk ke VPS Anda dan install Docker jika belum ada (Khusus AlmaLinux/RHEL):
```bash
# Update Server
sudo dnf update -y
sudo dnf install git -y

# Setup Docker Repo & Install
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo systemctl enable --now docker
```

#### B. Clone Repository
```bash
git clone https://github.com/marhaendev/pushtaka.git
cd pushtaka
```

#### C. Konfigurasi Environment
Salin file contoh konfigurasi dan sesuaikan:

```bash
cp .env.example .env
nano .env
```

**Variabel Penting:**
*   `DOMAIN_NAME`: Isi dengan domain Anda (misal: `pushtaka.com`).
*   `DB_PASSWORD`: Ganti dengan password kuat.
*   `JWT_SECRET`: Ganti dengan random string panjang.
*   `RABBITMQ_PASS`: Ganti password RabbitMQ.

#### D. Jalankan Aplikasi
Jalankan semua service (API, Web, Database, Proxy) dengan satu perintah:

```bash
sudo docker compose up -d --build
```

#### E. Verifikasi
Tunggu 1-2 menit hingga SSL certificate (Let's Encrypt) terbit otomatis.
*   Akses Web: `https://pushtaka.com`
*   Akses API: `https://pushtaka.com/api` (atau sesuai route yang tersedia)

#### F. Solusi Alternatif: SSL Manual (Certbot)
Jika SSL otomatis gagal atau Anda ingin menggunakan sertifikat sendiri, gunakan Certbot (Manual).

1.  **Install Certbot**:
    ```bash
    sudo dnf install certbot -y
    ```
2.  **Hentikan Docker sementara** (Port 80 harus kosong):
    ```bash
    sudo docker compose down
    ```
3.  **Generate Sertifikat**:
    ```bash
    sudo certbot certonly --standalone -d domainanda.com
    ```
4.  **Konfigurasi Traefik**:
    Anda perlu me-mount sertifikat yang dihasilkan (`/etc/letsencrypt/live/domainanda.com/...`) ke container Traefik via `docker-compose.yml` dan mengupdate konfigurasi Traefik untuk menggunakan sertifikat tersebut.

---

## 2. Instalasi Mobile (Build Apps)

Aplikasi mobile dibangun menggunakan **Flutter**. Pastikan Anda telah menginstall Flutter SDK di komputer lokal Anda.

### Prasyarat Lokal
*   **Flutter SDK**: Versi terbaru (Stable).
*   **Android Studio / Xcode**: Untuk build tools.
*   **Koneksi Internet**: Untuk mengunduh dependencies.

### Langkah-langkah

#### A. Masuk ke Direktori Mobile
```bash
cd mobile
```

#### B. Install Dependencies
```bash
flutter pub get
```

#### C. Konfigurasi Environment Mobile
Buat file `assets/.env` atau sesuaikan konfigurasi API Base URL di `lib/core/constants/api_constants.dart` (tergantung implementasi Anda).
*   Pastikan URL mengarah ke domain VPS Anda (misal: `https://pushtaka.com`).

#### D. Build Aplikasi

**Untuk Android (APK):**
```bash
flutter build apk --release
```
*Output: `build/app/outputs/flutter-apk/app-release.apk`*

**Untuk Android (App Bundle - Play Store):**
```bash
flutter build appbundle --release
```

**Untuk iOS (Memerlukan MacOS):**
```bash
flutter build ipa --release
```

#### E. Run Debug (Emulator/Device)
```bash
flutter run
```
