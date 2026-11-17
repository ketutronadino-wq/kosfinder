# Panduan & Aturan Kerja Agen AI (AGENTS.md) - KosFinder

Dokumen ini merupakan aturan kerja dan pedoman baku bagi agen AI dalam mengembangkan dan memelihara proyek **KosFinder**.

---

## 1. Konteks Proyek & Dokumen Acuan
KosFinder adalah aplikasi pencarian dan publikasi kos berbasis Flutter dengan backend Supabase. Seluruh keputusan dan implementasi teknis harus selalu merujuk pada dokumen-dokumen acuan berikut:
- **`docs/PRD.md`**: Persyaratan produk, batasan cakupan V1, User Stories (US01-US08), dan Acceptance Criteria.
- **`docs/ARCHITECTURE.md`**: Desain arsitektur teknis, struktur folder, skema database Supabase, dan integrasi sistem.
- **`docs/TASKS.md`**: Daftar breakdown task kerja terstruktur beserta Task ID dan status implementasi.

---

## 2. Cara Kerja
1. **Satu Task per Permintaan**: Kerjakan hanya satu task spesifik dalam satu giliran/permintaan sesuai arahan atau urutan task list.
2. **Batasan File**: Dilarang mengubah file di luar cakupan task yang sedang dikerjakan. Hindari modifikasi liar pada file atau modul yang tidak terkait.
3. **Rencanakan Perubahan Besar**: Untuk perubahan skala besar atau perubahan struktur arsitektur, buat dan paparkan rencana terlebih dahulu serta minta persetujuan pengguna sebelum mengeksekusi kode.
4. **Pilih Solusi Paling Sederhana (KISS & YAGNI)**: Prioritaskan solusi yang paling sederhana, jelas, minim boilerplate, dan langsung menyelesaikan masalah tanpa membuat abstraksi yang belum diperlukan.
5. **Pembatasan Package**: **Dilarang** menambahkan library/package baru ke `pubspec.yaml` tanpa persetujuan eksplisit dari pengguna.

---

## 3. Standar Teknologi
- **Framework**: Flutter (Dart) dengan target utama Android dan macOS.
- **State Management**: **Provider** (gunakan secara konsisten di seluruh modul aplikasi).
- **Backend**: **Supabase** (Autentikasi akun pemilik, PostgreSQL Database, dan Realtime jika diperlukan).

---

## 4. Keamanan & Kebijakan Akses Data
1. **Bebas Kredensial di Kode Sumber**: Tidak boleh ada hardcoded API key, password, URL rahasia, atau token di dalam kode program (`.dart`). Seluruh konfigurasi rahasia harus dimuat melalui environment variable (`.env`) yang diabaikan oleh Git.
2. **Larangan Penggunaan `service_role` Key**: Kunci `service_role` **TIDAK PERNAH** boleh dipakai atau dimasukkan ke dalam aplikasi client (Flutter). Aplikasi client hanya boleh menggunakan Supabase `anon` key.
3. **Penegakan Hak Akses via RLS**: Keamanan data dan pembatasan hak akses ditegakkan secara mutlak di tingkat database menggunakan PostgreSQL **Row Level Security (RLS)** pada Supabase, sehingga pemilik hanya bisa memodifikasi datanya sendiri dan pencari hanya bisa membaca data yang aktif.

---

## 5. Standar Git & Commit
- **Satu Task, Satu Commit**: Setiap penyelesaian satu task harus langsung diakhiri dengan satu commit terpisah.
- **Format Pesan Commit**: Pesan commit wajib mencantumkan ID task secara eksplisit, contohnya:
  - `feat(TASK-01): inisialisasi struktur direktori dan konfigurasi provider`
  - `fix(TASK-03): perbaiki validasi nomor kontak whatsapp`
  - `docs(TASK-05): tambahkan panduan setup database supabase`

---

## 6. Definition of Done (DoD)
Sebuah task hanya dinyatakan selesai (*Done*) jika memenuhi seluruh kriteria berikut:
1. **`flutter analyze` Bersih**: Menghasilkan 0 error, 0 warning, dan 0 lint issues.
2. **`flutter test` Lulus**: Semua automated tests (unit test / widget test) yang relevan berjalan sukses tanpa kegagalan.
3. **Verifikasi Perangkat**: Aplikasi berhasil di-build dan dijalankan di device yang tersedia (misal: macOS Desktop / Android).
4. **Laporan Uji Transparan**: Agen wajib melaporkan secara terbuka apa saja yang sudah diuji dan apa saja skenario yang belum/tidak diuji pada akhir respon.

---

## 7. Identitas Pengembang (Halaman About)
Pada halaman **About / Tentang Aplikasi**, wajib menampilkan identitas pengembang:
- **NIM**: `2415051108`
- **Nama**: `Ketut Rona Dino`
