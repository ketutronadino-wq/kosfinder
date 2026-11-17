# Daftar Task Pengerjaan (TASKS.md) - KosFinder (Versi 1)

Dokumen ini memuat daftar task terstruktur dengan pendekatan **Vertical Slice Architecture** berpedoman pada [PRD.md](file:///Users/ronadino/Documents/kosfinder/docs/PRD.md), [ARCHITECTURE.md](file:///Users/ronadino/Documents/kosfinder/docs/ARCHITECTURE.md), dan aturan [AGENTS.md](file:///Users/ronadino/Documents/kosfinder/AGENTS.md).

> **Aturan Eksekusi Task:**
> - Kerjakan **satu task per giliran**.
> - Ubah **hanya file yang terdaftar** pada kolom *File yang Boleh Diubah*.
> - Setiap task wajib diakhiri dengan commit Git berformat: `<tipe>(<TASK_ID>): <pesan>` (misal: `feat(T01): setup dependensi dan supabase config`).
> - Setiap akhir slice **wajib menghasilkan aplikasi yang bisa di-build dan dijalankan**.

---

## Slice 1: Daftar dan Detail Kos
*Tujuan Slice: Menghasilkan aplikasi yang bisa dijalankan, menampilkan daftar kos publik di beranda, rincian detail kos, tombol kontak WhatsApp, dan informasi halaman About.*

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **T01** | Setup dependensi (`provider`, `supabase_flutter`, `intl`, `url_launcher`), konfigurasi `AppConfig` via `--dart-define`, dan inisialisasi Supabase | US01-AC1, US01-AC2 | `pubspec.yaml`, `lib/core/config.dart`, `lib/main.dart` | `flutter analyze`, `flutter test`, app berhasil jalan di macOS/Android | [x] Selesai |
| **T02** | Buat `KostModel` dan `KostRepository` untuk mengambil daftar kos aktif dari Supabase | US01-AC1, US01-AC2 | `lib/data/models/kost_model.dart`, `lib/data/repositories/kost_repository.dart`, `test/data/kost_model_test.dart` | Unit test deserialisasi JSON & query `is_active = true` lulus | [ ] Belum |
| **T03** | Buat `KostProvider` dan `HomeScreen` berisi kartu kos publik serta penanganan tampilan saat data kosong | US01-AC1, US01-AC2 | `lib/presentation/providers/kost_provider.dart`, `lib/presentation/screens/home_screen.dart`, `lib/presentation/widgets/kost_card.dart`, `lib/main.dart`, `test/presentation/home_screen_test.dart` | Buka beranda, verifikasi kartu kos atau pesan "Belum ada kos terdaftar" tampil | [ ] Belum |
| **T04** | Buat `DetailKosScreen` lengkap dengan info fasilitas, fallback placeholder gambar, dan tombol WhatsApp via `url_launcher` | US03-AC1, US03-AC2, US04-AC1, US04-AC2 | `lib/presentation/screens/detail_kos_screen.dart`, `lib/core/utils/whatsapp_helper.dart`, `lib/presentation/widgets/image_placeholder.dart`, `lib/presentation/screens/home_screen.dart` | Ketuk kartu kos, cek detail info & foto/placeholder, ketuk tombol WhatsApp | [ ] Belum |
| **T05** | Buat `AboutScreen` yang menampilkan identitas pengembang wajib: NIM `2415051108` dan Nama `Ketut Rona Dino` | AGENTS.md (DoD) | `lib/presentation/screens/about_screen.dart`, `lib/presentation/screens/home_screen.dart` | Buka menu About dari navigasi, pastikan NIM dan Nama tampil tepat | [ ] Belum |

---

## Slice 2: Pencarian dan Filter
*Tujuan Slice: Menghasilkan aplikasi yang bisa dijalankan dengan fitur pencarian teks fleksibel (nama, kampus, jalan, kecamatan) dan filter tipe/harga kos.*

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **T06** | Tambahkan logika query pencarian teks area dan filter tipe gender/harga pada `KostRepository` dan `KostProvider` | US02-AC1, US02-AC2 | `lib/data/repositories/kost_repository.dart`, `lib/presentation/providers/kost_provider.dart`, `test/presentation/kost_provider_test.dart` | Unit test filter kata kunci area, tipe gender, dan rentang harga | [ ] Belum |
| **T07** | Implementasikan UI Search Bar dan Filter Chips/Sheet di `HomeScreen` beserta pesan ramah jika hasil pencarian kosong | US02-AC1, US02-AC2 | `lib/presentation/screens/home_screen.dart`, `lib/presentation/widgets/search_bar_widget.dart`, `lib/presentation/widgets/filter_sheet_widget.dart` | Ketik area/kampus di search bar, aktifkan filter tipe/harga, pastikan daftar tersaring atau muncul pesan "Kos tidak ditemukan" | [ ] Belum |

---

## Slice 3: Login Pemilik
*Tujuan Slice: Menghasilkan aplikasi yang bisa dijalankan dengan sistem autentikasi pemilik kos (registrasi, login email/password, dan logout via Supabase).*

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **T08** | Buat `AuthRepository` dan `AuthProvider` untuk penanganan sesi, registrasi, login, dan logout dengan Supabase Auth | US05-AC1, US05-AC2 | `lib/data/repositories/auth_repository.dart`, `lib/presentation/providers/auth_provider.dart`, `test/data/auth_repository_test.dart` | Unit test login berhasil, login gagal, dan logout | [ ] Belum |
| **T09** | Buat antarmuka `LoginScreen` dan `RegisterScreen` dengan validasi form dan pesan error autentikasi yang ramah | US05-AC1, US05-AC2 | `lib/presentation/screens/auth/login_screen.dart`, `lib/presentation/screens/auth/register_screen.dart`, `lib/presentation/screens/home_screen.dart` | Coba login salah (muncul notifikasi error), login benar diarahkan ke dashboard | [ ] Belum |

---

## Slice 4: Tambah, Ubah, Hapus Kos Milik Sendiri
*Tujuan Slice: Menghasilkan aplikasi yang bisa dijalankan dengan fitur manajemen CRUD kos penuh bagi pemilik terautentikasi.*

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **T10** | Buat `OwnerDashboardScreen` untuk menampilkan daftar kos yang dimiliki pemilik (`owner_id = auth.uid()`) | US06-AC1, US08-AC1 | `lib/presentation/screens/owner/owner_dashboard_screen.dart`, `lib/presentation/providers/kost_provider.dart` | Login sebagai pemilik, pastikan hanya kos miliknya sendiri yang tampil | [ ] Belum |
| **T11** | Buat form `KosFormScreen` untuk menambah kos baru lengkap dengan validasi kolom wajib dan checklist fasilitas | US06-AC1, US06-AC2 | `lib/presentation/screens/owner/kos_form_screen.dart`, `lib/presentation/widgets/facilities_checklist.dart`, `lib/data/repositories/kost_repository.dart` | Submit form kosong (muncul error validasi), submit data lengkap (kos tersimpan di Supabase) | [ ] Belum |
| **T12** | Buat fitur edit kos pada `KosFormScreen` dan verifikasi penolakan edit lintas pemilik (RLS protection) | US07-AC1, US07-AC2 | `lib/presentation/screens/owner/kos_form_screen.dart`, `lib/data/repositories/kost_repository.dart` | Edit kos milik sendiri (berhasil), uji penolakan jika mengedit data pemilik lain | [ ] Belum |
| **T13** | Buat fitur arsipkan kos (*soft delete* `is_active = false`) dan aktifkan kembali di dashboard pemilik | US08-AC1, US08-AC2 | `lib/presentation/screens/owner/owner_dashboard_screen.dart`, `lib/presentation/providers/kost_provider.dart`, `lib/data/repositories/kost_repository.dart` | Tekan "Arsipkan", pastikan kos hilang dari beranda publik tapi ada di dashboard; tekan "Aktifkan Kembali" kos muncul lagi | [ ] Belum |

---

## Slice 5 (Bonus): Ketersediaan Kamar
*Tujuan Slice: Menghasilkan aplikasi yang bisa dijalankan dengan fitur cepat toggle ketersediaan dan filter ketersediaan kamar bagi pencari.*

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **T14** | Tambahkan tombol switch/toggle ketersediaan kamar (**Tersedia ↔ Penuh**) di `OwnerDashboardScreen` dan kartu kos | US07-AC1 | `lib/presentation/screens/owner/owner_dashboard_screen.dart`, `lib/presentation/widgets/availability_badge.dart`, `lib/presentation/providers/kost_provider.dart` | Ubah toggle di dashboard pemilik, verifikasi status berubah di beranda publik | [ ] Belum |
| **T15** | Tambahkan filter ketersediaan pada `HomeScreen` untuk menyaring hanya kos dengan status "Tersedia" | US02-AC1, US07-AC1 | `lib/presentation/screens/home_screen.dart`, `lib/presentation/widgets/filter_sheet_widget.dart`, `lib/presentation/providers/kost_provider.dart` | Aktifkan filter "Hanya Kos Tersedia", pastikan kos berstatus "Penuh" disembunyikan | [ ] Belum |
