# KosFinder

Aplikasi pencarian dan publikasi kamar kos berbasis Flutter (Android & macOS) dengan backend Supabase.

---

## Cara Menjalankan

Proyek ini menggunakan konfigurasi dinamis melalui `--dart-define` untuk menghubungkan aplikasi ke backend Supabase. Tidak ada URL atau API key rahasia yang disimpan langsung di dalam kode sumber.

### 1. Menjalankan di Perangkat / Emulator (Debug)

Jalankan perintah berikut di terminal. Ganti nilai contoh (palsu) di bawah ini dengan URL dan Anon Key proyek Supabase Anda:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://contoh-proyek-palsu.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.contohKeyPalsu1234567890abcdef
```

Atau dalam satu baris:

```bash
flutter run --dart-define=SUPABASE_URL=https://contoh-proyek-palsu.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.contohKeyPalsu1234567890abcdef
```

### 2. (Alternatif) Menggunakan Berkas Konfigurasi Lokal

Anda juga dapat membuat berkas `.env.json` di *root directory* (berkas ini sudah diabaikan oleh Git pada `.gitignore`):

```json
{
  "SUPABASE_URL": "https://contoh-proyek-palsu.supabase.co",
  "SUPABASE_ANON_KEY": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.contohKeyPalsu1234567890abcdef"
}
```

Lalu jalankan aplikasi dengan:

```bash
flutter run --dart-define-from-file=.env.json
```

### 3. Build APK Rilis

Untuk menghasilkan berkas APK produksi:

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://contoh-proyek-palsu.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.contohKeyPalsu1234567890abcdef
```

Hasil build berada di `build/app/outputs/flutter-apk/app-release.apk`.

---

## Informasi Pengembang
- **NIM**: 2415051108
- **Nama**: Ketut Rona Dino
