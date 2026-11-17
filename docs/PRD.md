# Product Requirements Document (PRD) - KosFinder (Versi 1)

---

## 1. Masalah dan Tujuan

### Masalah
- **Pencari Kos**: Informasi kos saat ini tersebar tidak terstruktur di media sosial, grup WhatsApp, dan mulut ke mulut, sehingga sulit membandingkan harga, fasilitas, dan tipe kos di sekitar area kampus.
- **Pemilik Kos**: Mengalami kesulitan mempublikasikan kamar dan memperbarui status ketersediaan secara cepat dan terpusat tanpa harus terus-menerus membalas pertanyaan yang sama.

### Tujuan
- Menyediakan aplikasi mobile (Android) yang cepat, sederhana, dan terpusat bagi pencari kos untuk menemukan kos di sekitar kampus/kota tanpa perlu login.
- Menyediakan platform mandiri bagi pemilik kos untuk mempublikasikan, mengelola, dan memperbarui status ketersediaan (Tersedia/Penuh) kos milik mereka sendiri.

---

## 2. Pengguna

1. **Pencari Kos (Mahasiswa & Masyarakat)**:
   - Pengguna umum yang membutuhkan hunian sewa di sekitar kampus atau area tertentu.
   - Menggunakan aplikasi dalam mode *guest* (tanpa akun/login).
2. **Pemilik Kos**:
   - Pengelola atau pemilik properti kos.
   - Wajib membuat akun dan masuk menggunakan email dan password untuk mengelola data kos.

---

## 3. Scope Versi 1 (V1)

### Yang Masuk (In-Scope)
- **Publik / Pencari Kos**:
  - Melihat daftar seluruh kos aktif.
  - Pencarian berbasis teks (mencocokkan nama kos, kampus, jalan, kecamatan).
  - Filter berdasarkan rentang harga, tipe kos (Putra, Putri, Campur), dan status ketersediaan.
  - Melihat detail informasi kos (nama, tipe, alamat, harga, checklist fasilitas, deskripsi, gambar via URL publik atau placeholder).
  - Menghubungi pemilik langsung via tombol WhatsApp dengan pesan pembuka otomatis.
- **Pemilik Kos**:
  - Registrasi dan login dengan Email & Password via Supabase Auth.
  - Dashboard "Kos Saya" untuk mengelola kos milik sendiri.
  - Formulir tambah kos dan edit kos milik sendiri (nama, tipe, area/kampus, alamat, harga, nomor WhatsApp, URL gambar, checklist fasilitas, deskripsi).
  - Pengubahan status ketersediaan secara cepat (**Tersedia / Penuh**).
  - Pengarsipan data kos (**Soft Delete**) agar tidak tampil di pencarian publik namun dapat diaktifkan kembali.

### Yang TIDAK Masuk (Out-of-Scope)
- Pembayaran online / payment gateway dalam aplikasi.
- Fitur in-app chat (komunikasi dialihkan langsung ke WhatsApp eksternal).
- Sistem ulasan, rating, dan komentar.
- Rekomendasi pintar / AI matching.
- Verifikasi identitas resmi (KTP) pemilik kos.
- Upload berkas foto ke storage server (hanya mendukung input tautan URL gambar atau gambar placeholder default).
- Tampilan peta interaktif (Google Maps / Mapbox) dan pelacakan GPS.

---

## 4. Non-Functional Requirements (NFR)

### Keamanan
- **Autentikasi & Otorisasi**: Autentikasi berbasis Supabase Auth. Seluruh akses modifikasi data dilindungi dengan Row Level Security (RLS) di tingkat database PostgreSQL.
- **Isolasi Data Kepemilikan**: Pemilik kos hanya dapat memperbarui atau mengarsipkan data yang memiliki `owner_id` sesuai UID sesi mereka. Akses lintas pemilik ditolak secara tegas di level database.
- **Privasi Pengguna**: Pencari kos tidak diwajibkan memberikan data pribadi maupun mendaftar akun.

### Performa & Keandalan
- **Responsivitas**: Daftar kos dan hasil pencarian lokal/remote harus tampil dalam waktu < 2 detik pada jaringan internet standar (4G).
- **Fallback Visual**: Jika URL gambar eksternal kosong atau gagal dimuat, aplikasi wajib menampilkan placeholder grafis lokal tanpa membuat UI terhenti (*crash/freeze*).
- **Stabilitas Deep Link**: Tombol kontak WhatsApp harus menangani validasi format nomor dan mengalihkan ke WhatsApp URL scheme (`https://wa.me/...`) tanpa memutus alur aplikasi.

---

## 5. User Stories & Acceptance Criteria

### US01: Menjelajah Daftar Kos
> *Sebagai pencari kos, saya ingin melihat daftar kos yang tersedia di beranda, sehingga saya dapat mengetahui pilihan kos yang ada.*

- **US01-AC1**:  
  **Given** terdapat kos aktif dalam database,  
  **When** pencari membuka halaman beranda,  
  **Then** sistem menampilkan daftar kartu kos yang memuat nama, tipe, area/kampus, harga/bulan, status ketersediaan, serta gambar (atau placeholder).
- **US01-AC2 (Kasus Data Kosong)**:  
  **Given** tidak ada data kos aktif di database atau koneksi belum memiliki data,  
  **When** pencari membuka halaman beranda,  
  **Then** sistem menampilkan pesan/ilustrasi kosong yang informatif ("Belum ada kos yang terdaftar saat ini").

---

### US02: Mencari dan Menyaring Kos
> *Sebagai pencari kos, saya ingin mencari kos berdasarkan kata kunci area dan memfilternya berdasarkan harga dan tipe, sehingga saya dapat menemukan kos yang sesuai kriteria saya.*

- **US02-AC1**:  
  **Given** pencari berada di halaman beranda,  
  **When** memasukkan kata kunci pencarian (nama kampus/jalan/kecamatan) atau memilih filter tipe/harga,  
  **Then** sistem menampilkan daftar kos yang cocok dengan kriteria tersebut.
- **US02-AC2 (Kasus Data Kosong)**:  
  **Given** pencari memasukkan kata kunci pencarian yang tidak ada padanannya,  
  **When** sistem memproses pencarian,  
  **Then** sistem menampilkan pesan "Tidak ada kos yang cocok dengan pencarian Anda" beserta saran untuk mereset filter.

---

### US03: Melihat Detail Kos
> *Sebagai pencari kos, saya ingin melihat rincian informasi dan fasilitas dari suatu kos, sehingga saya tahu kelayakan kamar kos tersebut.*

- **US03-AC1**:  
  **Given** pencari melihat daftar kartu kos,  
  **When** mengetuk salah satu kartu kos,  
  **Then** sistem membuka halaman detail kos yang memuat foto, nama, tipe, alamat lengkap, harga, checklist fasilitas, deskripsi, dan status ketersediaan.
- **US03-AC2**:  
  **Given** kos tidak memiliki tautan gambar publik (`image_url` kosong/null),  
  **When** halaman detail kos dimuat,  
  **Then** sistem menampilkan gambar placeholder default yang rapi tanpa error visual.

---

### US04: Menghubungi Pemilik via WhatsApp
> *Sebagai pencari kos, saya ingin menghubungi pemilik kos melalui WhatsApp, sehingga saya bisa menanyakan ketersediaan kamar secara langsung.*

- **US04-AC1**:  
  **Given** pencari berada di halaman detail kos yang memiliki nomor WhatsApp valid,  
  **When** mengetuk tombol "Hubungi via WhatsApp",  
  **Then** sistem membuka aplikasi WhatsApp eksternal dengan nomor pemilik dan pesan pembuka otomatis berisi nama kos terkait.
- **US04-AC2**:  
  **Given** perangkat tidak memiliki aplikasi WhatsApp atau nomor tidak valid,  
  **When** tombol "Hubungi via WhatsApp" ditekan,  
  **Then** sistem menampilkan pesan error (*snackbar*) ramah pengguna yang menginformasikan bahwa WhatsApp tidak dapat dibuka.

---

### US05: Registrasi dan Login Pemilik Kos
> *Sebagai pemilik kos, saya ingin mendaftar dan masuk menggunakan email dan password, sehingga saya dapat mengelola kos milik saya.*

- **US05-AC1**:  
  **Given** pemilik belum masuk dan berada di halaman registrasi,  
  **When** memasukkan email dan password valid,  
  **Then** sistem membuat akun di Supabase Auth dan mengarahkan pemilik ke dashboard kelola kos.
- **US05-AC2**:  
  **Given** pemilik berada di halaman login,  
  **When** memasukkan kombinasi email/password yang salah,  
  **Then** sistem menampilkan pesan kesalahan autentikasi yang jelas dan tetap berada di halaman login.

---

### US06: Menambah Kos Baru
> *Sebagai pemilik kos yang telah masuk, saya ingin menambahkan data kos baru, sehingga kos saya dapat dipublikasikan ke pencari.*

- **US06-AC1**:  
  **Given** pemilik berada di halaman form tambah kos,  
  **When** mengisi semua kolom wajib (nama, tipe, area, alamat, harga, nomor WhatsApp, fasilitas) dan menekan "Simpan",  
  **Then** data kos baru tersimpan di Supabase dengan `owner_id` pemilik dan muncul di daftar kos publik.
- **US06-AC2 (Validasi Form Kosong)**:  
  **Given** pemilik berada di halaman form tambah kos,  
  **When** menekan tombol "Simpan" dengan kolom wajib (misal: nama atau harga) masih kosong,  
  **Then** sistem menampilkan indikator validasi error pada kolom terkait dan tidak mengirim data ke database.

---

### US07: Mengubah Data & Ketersediaan Kos
> *Sebagai pemilik kos, saya ingin mengubah detail kos dan memperbarui status ketersediaan (Tersedia/Penuh), sehingga informasi kos saya selalu akurat.*

- **US07-AC1**:  
  **Given** pemilik telah login dan membuka kos miliknya sendiri,  
  **When** mengubah data (atau mengubah status Tersedia/Penuh) dan menekan simpan,  
  **Then** perubahan berhasil diperbarui di database dan langsung terrefleksi di halaman publik.
- **US07-AC2 (Kasus Pemilik Lain Mencoba Mengedit)**:  
  **Given** Pengguna A sedang login,  
  **When** Pengguna A mencoba mengedit atau mengirim perintah mutasi data kos milik Pengguna B (baik melalui manipulasi UI maupun panggilan request langsung),  
  **Then** sistem (didukung Supabase RLS) menolak permintaan dengan pesan penolakan akses (*permission denied*) dan data kos milik Pengguna B tidak berubah.

---

### US08: Mengarsipkan Kos (Soft Delete)
> *Sebagai pemilik kos, saya ingin mengarsipkan kos saya ketika tidak ingin dipublikasikan sementara waktu, sehingga saya tidak perlu menghapus dan membuat ulang di masa depan.*

- **US08-AC1**:  
  **Given** pemilik berada di dashboard kelola kos miliknya,  
  **When** memilih opsi "Arsipkan Kos" dan mengonfirmasi tindakan,  
  **Then** status kos diubah menjadi tidak aktif (`is_active = false`), tidak lagi muncul di pencarian publik, namun tetap terlihat di dashboard pemilik dengan label "Diarsipkan".
- **US08-AC2**:  
  **Given** kos berstatus diarsipkan di dashboard pemilik,  
  **When** pemilik memilih opsi "Aktifkan Kembali",  
  **Then** status kos kembali aktif (`is_active = true`) dan segera dapat dilihat kembali oleh pencari kos.

---

## 6. Hal Ambigu / Catatan Tambahan (Open Questions)

1. **Normalisasi Format Nomor WhatsApp**:  
   Apakah input nomor WhatsApp pemilik otomatis dikonversi dari awalan lokal (`08...`) ke format internasional (`628...`), atau sistem mewajibkan pemilik memilih kode negara di form?
2. **Penanganan Link URL Gambar Eksternal yang Tidak Valid / Rusak**:  
   Apakah aplikasi cukup melakukan fallback ke placeholder default saat URL gambar menghasilkan status HTTP 404/bukan gambar, tanpa validasi URL di sisi form input?
3. **Penyortiran Default pada Beranda**:  
   Apakah daftar kos pada beranda diurutkan berdasarkan kos terbaru yang ditambahkan (*created_at desc*), ketersediaan (*tersedia terlebih dahulu*), atau urutan acak?
