# Dokumentasi API Pushtaka

## Ringkasan

**Base URL**: `https://pushtaka.xapi.my.id` (Sesuaikan dengan domain yang Anda konfigurasi di VPS)

**Format Response**: Semua response menggunakan format JSON baku:

```json
{
  "status": "success",          // success | error
  "message": "...",             // Pesan deskriptif
  "data": { ... }               // Objek data atau null
}
```

---

## Service: Identity (User & Auth)

Base URL: `https://pushtaka.xapi.my.id`

### Endpoint Autentikasi (Publik)

#### 1. Registrasi User
Mendaftar user baru.

*   **URL**: `/auth/register`
*   **Method**: `POST`
*   **Body**:
    ```json
    {
      "email": "user@contoh.com",
      "password": "password123",
      "name": "Nama User"
    }
    ```
*   **Catatan**: Setelah ini user harus verifikasi OTP yang dikirim ke email.

#### 2. Login
Masuk untuk mendapatkan Token JWT.

*   **URL**: `/auth/login`
*   **Method**: `POST`
*   **Body**:
    ```json
    {
      "email": "user@contoh.com",
      "password": "password123"
    }
    ```
*   **Response**: Mengembalikan token akses (JWT).

#### 3. Verifikasi OTP
Verifikasi kode OTP untuk registrasi atau reset password.

*   **URL**: `/auth/verify-otp`
*   **Method**: `POST`
*   **Body**:
    ```json
    {
      "email": "user@contoh.com",
      "otp": "123456",
      "purpose": "register"
    }
    ```
    *(Purpose bisa: `register`, `login`, `reset_password`, `change_password`, `change_email`)*

#### 4. Lupa Password
Request kode OTP untuk mereset password.

*   **URL**: `/auth/forgot-password`
*   **Method**: `POST`
*   **Body**:
    ```json
    {
      "email": "user@contoh.com"
    }
    ```

#### 5. Reset Password
Mengatur ulang password menggunakan token reset (didapat setelah verifikasi OTP).

*   **URL**: `/auth/reset-password`
*   **Method**: `POST`
*   **Body**:
    ```json
    {
      "token": "string_reset_token",
      "new_password": "password_baru"
    }
    ```

#### 6. Request OTP
Meminta kode OTP untuk tujuan tertentu (misal: ganti email/password saat login).

*   **URL**: `/auth/request-otp`
*   **Method**: `POST`
*   **Body**:
    ```json
    {
      "email": "user@contoh.com",
      "purpose": "change_email"
    }
    ```

#### 7. Change Email
Mengubah email menggunakan token yang didapat dari `VerifyOTP` (purpose `change_email`).

*   **URL**: `/auth/change-email`
*   **Method**: `POST`
*   **Body**:
    ```json
    {
      "token": "string_change_token",
      "new_email": "email_baru@contoh.com"
    }
    ```

---

### Endpoint Profile (User & Admin)

**Header Wajib**: `Authorization: Bearer <TOKEN>`

#### 8. Lihat Profile
Mendapatkan data profile user yang sedang login.

*   **URL**: `/profile`
*   **Method**: `GET`
*   **Response**: Detail user yang sedang login.

#### 9. Update Profile
Mengubah data profile (Nama/Email) user sendiri.

*   **URL**: `/profile`
*   **Method**: `PUT`
*   **Body**:
    ```json
    {
      "name": "Nama Baru",
      "email": "emailbaru@contoh.com"
    }
    ```
    *(Hanya isi field yang ingin diubah)*

---

### Endpoint Manajemen User (Khusus Admin)

**Header Wajib**: `Authorization: Bearer <TOKEN_ADMIN>`

#### 10. Lihat Daftar User
Mendapatkan semua data user dengan pagination.

*   **URL**: `/users`
*   **Method**: `GET`
*   **Query Params**:
    *   `limit`: Jumlah data per halaman (default 10)
    *   `offset`: Posisi awal data (default 0)

#### 11. Lihat Detail User
Mendapatkan detail satu user berdasarkan ID.

*   **URL**: `/users/:id`
*   **Method**: `GET`

#### 12. Buat User (Manual)
Membuat user baru secara langsung (otomatis terverifikasi).

*   **URL**: `/users`
*   **Method**: `POST`
*   **Body**:
    ```json
    {
      "email": "adminbaru@contoh.com",
      "password": "passwordkuat",
      "name": "Admin Baru"
    }
    ```

#### 13. Update User
Mengubah data user.

*   **URL**: `/users/:id`
*   **Method**: `PUT`
*   **Body**:
    ```json
    {
      "name": "Nama Baru",
      "email": "emailbaru@contoh.com",
      "role": "admin",
      "is_verified": true
    }
    ```

#### 14. Hapus User (Single)
Menghapus user (default Soft Delete).

*   **URL**: `/users/:id`
*   **Method**: `DELETE`
*   **Query Params**:
    *   `permanent=true`: Hapus permanen dari database.

#### 15. Hapus User (Batch)
Menghapus banyak user sekaligus.

*   **URL**: `/users`
*   **Method**: `DELETE`
*   **Body**:
    ```json
    {
      "ids": [1, 2, 3]
    }
    ```

---

## Service: Book (Manajemen Buku)

### Endpoint Publik (Tanpa Token)

#### 1. Lihat Daftar Buku
Mendapatkan list semua buku.

*   **URL**: `/books`
*   **Method**: `GET`
*   **Response Success**:
    ```json
    {
        "status": "success",
        "message": "book list retrieved",
        "data": [
            {
                "id": 1,
                "title": "Clean Code",
                "slug": "clean-code",
                "code": "BK-170123456",
                "author": "Robert C. Martin",
                "stock": 10
            }
        ]
    }
    ```

#### 2. Detail Buku
Mendapatkan detail buku berdasarkan ID.

*   **URL**: `/books/:id`
*   **Method**: `GET`

### Endpoint Khusus Admin
**Header Wajib**: `Authorization: Bearer <TOKEN_ADMIN>`

#### 3. Tambah Buku
Menambah buku baru. `slug` akan di-generate otomatis dari `title` jika kosong.

*   **URL**: `/books`
*   **Method**: `POST`
*   **Body**:
    ```json
    {
      "title": "Belajar Golang",
      "author": "John Doe",
      "stock": 10,
      "image": "https://example.com/cover.jpg",
      "isbn": "978-3-16-148410-0",
      "publisher": "Pushtaka Press",
      "slug": "belajar-golang" // Opsional
    }
    ```
*   **Response Success (201 Created)**:
    ```json
    {
        "status": "success",
        "message": "book created successfully",
        "data": { ... }
    }
    ```

#### 4. Update Buku
Mengupdate data buku.

*   **URL**: `/books/:id`
*   **Method**: `PUT`
*   **Body**: (Sama dengan Create, field opsional)

#### 5. Hapus Buku (Single)
Menghapus satu buku (Soft Delete).

*   **URL**: `/books/:id`
*   **Method**: `DELETE`

#### 6. Hapus Buku (Batch)
Menghapus banyak buku sekaligus.

*   **URL**: `/books`
*   **Method**: `DELETE`
*   **Body**:
    ```json
    {
      "ids": [10, 11, 12]
    }
    ```


### Endpoint Favorit (User Authenticated)
**Header Wajib**: `Authorization: Bearer <TOKEN>`

#### 7. Lihat Daftar Favorit
Mendapatkan list buku favorit user yang sedang login.

*   **URL**: `/favorites`
*   **Method**: `GET`

#### 8. Tambah ke Favorit
Menambahkan buku ke daftar favorit user.

*   **URL**: `/favorites/:book_id`
*   **Method**: `POST`
*   **Body**: (Kosong)
*   **Response Success**:
    ```json
    {
      "status": "success",
      "message": "book added to favorites",
      "data": null
    }
    ```

#### 9. Hapus dari Favorit
Menghapus buku dari daftar favorit.

*   **URL**: `/favorites/:book_id`
*   **Method**: `DELETE`

---

## Service: Transaction (Peminjaman & Denda)

**Akses**: Semua authenticated user (User & Admin)
**Header Wajib**: `Authorization: Bearer <TOKEN>`

> [!IMPORTANT]
> **Batasan Peminjaman:**
> - Maksimal 3 buku dalam satu waktu per user
> - Tidak bisa meminjam buku yang sama sebelum dikembalikan
> - Denda otomatis dihitung jika terlambat mengembalikan

### Endpoint Transaksi

#### 1. Pinjam Buku
Meminjam buku. Sistem akan otomatis mengurangi stok buku.

*   **URL**: `/transactions/borrow/:id`
*   **Method**: `POST`
*   **Parameter**: `id` = Book ID (integer)
*   **Body**: (Kosong)
*   **Response Success**:
    ```json
    {
      "status": "success",
      "message": "book borrowed successfully",
      "data": null
    }
    ```

#### 2. Kembalikan Buku
Mengembalikan buku. Sistem akan otomatis menambah stok buku dan menghitung denda jika terlambat.

*   **URL**: `/transactions/return/:id`
*   **Method**: `POST`
*   **Parameter**: `id` = Book ID (integer)
*   **Body**: (Kosong)
*   **Response Success**:
    ```json
    {
      "status": "success",
      "message": "book returned successfully",
      "data": null
    }
    ```

#### 3. Riwayat Transaksi (Pribadi)
Melihat riwayat peminjaman **user yang sedang login saja**.

*   **URL**: `/transactions/history`
*   **Method**: `GET`
*   **Response**: List riwayat peminjaman pribadi dengan detail buku.

#### 4. Semua Riwayat Transaksi (Admin Only)
Melihat riwayat **semua peminjaman dari semua user** (Khusus Admin).

*   **URL**: `/transactions`
*   **Method**: `GET`
*   **Header Wajib**: `Authorization: Bearer <TOKEN_ADMIN>`

---

### Endpoint Denda (Fines)

#### 5. Lihat Denda Saya
Melihat daftar denda yang belum dibayar.

*   **URL**: `/transactions/fines`
*   **Method**: `GET`
*   **Response**:
    ```json
    {
        "status": "success",
        "message": "unpaid fines retrieved",
        "data": [
            {
                "id": 125,
                "fine": 3000,
                "status": "completed", // transaction status
                "created_at": "..."
            }
        ]
    }
    ```

#### 6. Bayar Denda
Memulai pembayaran denda. Mendukung metode Otomatis (QRIS) dan Manual.

*   **URL**: `/transactions/pay-fine/:id`
*   **Method**: `POST`
*   **Parameter**: `id` = Transaction ID
*   **Body (QRIS)**:
    ```json
    { "method": "qris" }
    ```
*   **Body (Manual)**:
    ```json
    { "method": "manual", "proof": "base64_image_string..." }
    ```
*   **Response Success**:
    ```json
    {
      "status": "success",
      "message": "payment initiated",
      "data": {
          "qr_string": "https://...",
          "message": "Scan / Payment submitted"
      }
    }
    ```

#### 7. Verifikasi Denda (Admin Only)
Menyetujui atau menolak pembayaran manual.

*   **URL**: `/transactions/verify/:id`
*   **Method**: `POST`
*   **Body**:
    ```json
    { "action": "approve" } // atau "reject"
    ```

#### 8. Payment Callback (Webhook)
Webhook untuk Midtrans (Publik).

*   **URL**: `/transactions/callback`
*   **Method**: `POST`
*   **Body**: Standard Midtrans payload.

---

### Endpoint Pengaturan Transaksi (Settings - Admin)
*Pengaturan khusus layanan transaksi (durasi pinjam, tarif denda).*

**Header Wajib**: `Authorization: Bearer <TOKEN_ADMIN>`

#### 9. Lihat Pengaturan Transaksi
Mengambil konfigurasi durasi pinjam dan tarif denda saat ini.

*   **URL**: `/transactions/settings`
*   **Method**: `GET`
*   **Response**:
    ```json
    {
        "status": "success",
        "message": "settings retrieved",
        "data": {
            "borrow_duration": 7,
            "fine_amount": 1000,
            "max_borrow_limit": 3
        }
    }
    ```

#### 10. Update Pengaturan Transaksi
Mengubah konfigurasi.

*   **URL**: `/transactions/settings`
*   **Method**: `POST`
*   **Body**:
    ```json
    {
        "borrow_duration": 5,
        "borrow_duration_unit": "day",
        "fine_amount": 2000,
        "fine_unit": "day"
    }
    ```

---

### Utility & Testing

#### 11. Test Helper - Jadikan Buku Terlambat (Test Only)
**⚠️ Hanya untuk testing/development!** Endpoint ini mengubah due date menjadi masa lalu untuk mensimulasikan keterlambatan.

*   **URL**: `/transactions/test/make-late/:id`
*   **Method**: `POST`
*   **Query Parameter**: `days` (opsional) = Jumlah hari terlambat (default: 3)

---

## Arsitektur Event-Driven (RabbitMQ)

Sistem menggunakan RabbitMQ untuk sinkronisasi data antar service, khususnya untuk **Update Stok Buku**.

### Alur Kerja
1.  **Publisher**: `Transaction Service`
    *   Saat peminjaman berhasil (`BorrowBook`), service mengirim event `borrow` (qty: -1).
    *   Saat pengembalian berhasil (`ReturnBook`), service mengirim event `return` (qty: +1).
2.  **Exchange/Queue**: `stock_updates`
3.  **Consumer**: `Book Service`
    *   Mendengarkan queue `stock_updates`.
    *   Menerima pesan dan melakukan update stok di database secara asinkron.

### Struktur Pesan (JSON)
```json
{
  "book_id": 1,
  "action": "borrow", // atau "return"
  "quantity": -1      // atau 1
}
```
