# Desain Arsitektur Sistem - KosFinder (Versi 1)

Dokumen ini mendefinisikan arsitektur teknis, pola kode, skema database, konfigurasi, dan alur rilis KosFinder V1 berpedoman pada [PRD.md](file:///Users/ronadino/Documents/kosfinder/docs/PRD.md) dan [AGENTS.md](file:///Users/ronadino/Documents/kosfinder/AGENTS.md).

---

## 1. Komponen Aplikasi & Pola Arsitektur
Aplikasi menerapkan pola berlapis terpisah: **Screen - Provider - Repository - Supabase**.

```
[Screen (UI)] <---> [Provider (State)] <---> [Repository (Data)] <---> [Supabase Client]
```

1. **Screen / View (Presentation Layer)**:
   - Menampilkan antarmuka pengguna, menangani input interaktif, dan merender data dari Provider.
   - *User Story Terkait*: Seluruh story (**US01 - US08**).
2. **Provider (State Management Layer)**:
   - Menggunakan package `provider` (`ChangeNotifier`). Mengatur state UI, validasi form, penanganan loading/error, dan berkoordinasi dengan Repository.
   - Terdiri dari:
     - `KostProvider`: Mengelola daftar kos, pencarian, filter, dan CRUD kos (**US01, US02, US03, US06, US07, US08**).
     - `AuthProvider`: Mengelola sesi login, registrasi, dan logout pemilik kos (**US05**).
3. **Repository (Data Access Layer)**:
   - Mengabstraksi panggilan data, memetakan response JSON Supabase ke model objek Dart (`KostModel`, `UserModel`), dan menangani error jaringan.
   - Terdiri dari `KostRepository` (**US01, US02, US06, US07, US08**) dan `AuthRepository` (**US05**).
4. **Supabase (Backend as a Service)**:
   - Menyediakan Supabase Auth (pengelolaan sesi email/password) dan PostgreSQL Database dengan Row Level Security (**US01 - US08**).

---

## 2. Daftar Layar & Alur Navigasi

### Daftar Layar
- **`HomeScreen`**: Halaman utama publik berisi pencarian teks, filter harga/tipe, dan daftar kartu kos aktif (**US01, US02**).
- **`DetailKosScreen`**: Rincian kos, foto, fasilitas, deskripsi, dan tombol WhatsApp (**US03, US04**).
- **`LoginScreen` & `RegisterScreen`**: Form autentikasi pemilik kos (**US05**).
- **`OwnerDashboardScreen`**: Halaman kelola kos pemilik, toggle ketersediaan, tombol edit, dan arsip (**US06, US07, US08**).
- **`KosFormScreen`**: Formulir tambah dan edit kos (**US06, US07**).
- **`AboutScreen`**: Informasi aplikasi dan identitas wajib: NIM `2415051108`, Nama `Ketut Rona Dino`.

### Alur Navigasi
```
[HomeScreen] ──(Ketuk Kartu)──> [DetailKosScreen] ──(Ketuk WA)──> [WhatsApp App]
      │
      ├──(Ikon Akun)──> [LoginScreen] ──(Daftar)──> [RegisterScreen]
      │                       │ (Berhasil Login)
      │                       ▼
      └──(Menu Samping)─> [OwnerDashboardScreen] ──(+)──> [KosFormScreen (Tambah)]
            │                     │
            │                     └──(Edit)──> [KosFormScreen (Ubah)]
            ▼
      [AboutScreen]
```

---

## 3. Rencana Database & Hak Akses (Supabase PostgreSQL)

### Struktur Tabel `kosts`
| Kolom | Tipe Data | Keterangan & Relasi |
| :--- | :--- | :--- |
| `id` | `uuid` (PK) | Default `gen_random_uuid()`. |
| `owner_id` | `uuid` (FK) | Relasi ke `auth.users(id) on delete cascade` (**US06**). |
| `name` | `text` | Nama kos (**US01, US06**). |
| `gender_type` | `text` | Nilai: `'putra'`, `'putri'`, `'campur'` (**US02, US06**). |
| `area_campus` | `text` | Area/kampus/kecamatan untuk pencarian (**US02, US06**). |
| `address` | `text` | Alamat fisik lengkap (**US03, US06**). |
| `price_monthly` | `numeric` | Harga sewa bulanan (angka, >= 0) (**US01, US02, US06**). |
| `whatsapp_number` | `text` | Nomor kontak WhatsApp pemilik (**US04, US06**). |
| `image_url` | `text` | URL publik gambar (opsional, nullable) (**US01, US03, US06**). |
| `facilities` | `text[]` | Array fasilitas (WiFi, AC, KM Dalam, dll.) (**US03, US06**). |
| `description` | `text` | Deskripsi tambahan kos (**US03, US06**). |
| `status` | `text` | Status: `'tersedia'` atau `'penuh'` (**US01, US07**). |
| `is_active` | `boolean` | Flag status aktif / arsip (soft delete) (**US01, US08**). |
| `created_at` | `timestamptz` | Waktu pembuatan data (default `now()`). |
| `updated_at` | `timestamptz` | Waktu pembaruan terakhir (default `now()`). |

### Aturan Hak Akses (Row Level Security)
- **Melihat (`SELECT`)**:
  - Publik (anonim/pencari) dan pemilik dapat melihat kos yang aktif (`is_active = true`).
  - Pemilik dapat melihat kos miliknya sendiri meskipun diarsipkan (`auth.uid() = owner_id`). (**US01, US02, US08**).
- **Menambah (`INSERT`)**:
  - Hanya pengguna terautentikasi (`auth.role() = 'authenticated'`) dengan syarat `auth.uid() = owner_id`. (**US06**).
- **Mengubah (`UPDATE`)**:
  - Hanya pemilik sah dari kos tersebut (`auth.uid() = owner_id`). Pengguna lain ditolak tegas oleh RLS. (**US07, US08**).
- **Menghapus (`DELETE`)**:
  - Hanya pemilik sah (`auth.uid() = owner_id`). Operasi utama menggunakan update soft delete (`is_active = false`). (**US08**).

---

## 4. Konfigurasi Lingkungan (`--dart-define`)
Sesuai standar keamanan `AGENTS.md`, dilarang keras menyimpan URL atau Anon Key di dalam kode sumber Dart. Kredensial dibaca saat kompilasi/eksekusi runtime via `String.fromEnvironment`:

```dart
class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}
```

- **Menjalankan di development**:
  ```bash
  flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJh...
  ```
- **Atau menggunakan file konfigurasi lokal** (abaikan dari Git):
  ```bash
  flutter run --dart-define-from-file=.env.json
  ```

---

## 5. Cara Rilis (Build APK & GitHub Release)

1. **Build APK Release**:
   Jalankan build APK Android release dengan menyuntikkan environment variables produksi:
   ```bash
   flutter build apk --release \
     --dart-define=SUPABASE_URL=https://xyz.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=eyJh...
   ```
   File binary biner rilis akan dihasilkan di: `build/app/outputs/flutter-apk/app-release.apk`.
2. **Publikasi ke GitHub Release**:
   - Buat Git Tag versi rilis, misalnya `v1.0.0`:
     ```bash
     git tag -a v1.0.0 -m "Release KosFinder v1.0.0"
     git push origin v1.0.0
     ```
   - Buat rilis baru di menu **Releases** repository GitHub `https://github.com/ketutronadino-wq/kosfinder`.
   - Unggah berkas `app-release.apk` sebagai aset rilis disertai catatan rilis (changelog).

---

## 6. Daftar Package yang Dibutuhkan & Kaitannya dengan User Story
Hanya package esensial dan paling sederhana yang digunakan (memenuhi aturan `AGENTS.md`):

| Package | Alasan & Fungsi | Story Terkait |
| :--- | :--- | :---: |
| **`provider`** | State management reaktif yang sederhana, terstandar, dan minim boilerplate untuk memisahkan UI dan business logic. | **US01 - US08** |
| **`supabase_flutter`** | SDK resmi Supabase untuk menangani autentikasi pemilik, session token, dan query PostgreSQL dengan RLS. | **US01, US02, US05, US06, US07, US08** |
| **`url_launcher`** | Membuka deep link eksternal aplikasi WhatsApp (`https://wa.me/<nomor>?text=...`) dari tombol kontak. | **US04** |
| **`intl`** | Pemformatan angka `price_monthly` ke mata uang lokal Rupiah (`Rp 1.500.000 / bulan`). | **US01, US03, US06, US07** |
