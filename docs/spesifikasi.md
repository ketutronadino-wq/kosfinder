# Spesifikasi Kebutuhan & Desain Sistem - KosFinder (Versi 1)

## 1. Ringkasan Produk
**KosFinder** adalah aplikasi mobile berbasis Flutter (Android & macOS) dengan backend Supabase, yang dirancang untuk mempermudah pencarian dan publikasi kamar kos di sekitar area kampus/kota.

---

## 2. Pengguna & Hak Akses

| Peran Pengguna | Autentikasi | Hak Akses & Kemampuan |
| :--- | :---: | :--- |
| **Pencari Kos** *(Mahasiswa / Masyarakat)* | **Guest** (Tanpa login) | • Menjelajah daftar kos aktif.<br>• Melakukan pencarian teks (nama kos, kampus, jalan, kecamatan).<br>• Memfilter berdasarkan rentang harga & tipe kos.<br>• Melihat detail lengkap kos (fasilitas, deskripsi, harga, foto URL).<br>• Menghubungi pemilik langsung via WhatsApp. |
| **Pemilik Kos** | **Login** (Email & Password via Supabase Auth) | • Mendaftar akun baru dan masuk.<br>• Mengelola kos miliknya sendiri (Tambah, Ubah detail, Ubah ketersediaan).<br>• Mengubah status kamar (**Tersedia / Penuh**).<br>• Mengarsipkan/menonaktifkan kos miliknya (*Soft Delete*). |

---

## 3. Fitur Utama Versi 1 (V1)

### A. Sisi Pencari Kos (Publik / Guest)
1. **Beranda & Daftar Kos**:
   - Menampilkan kartu kos yang berstatus aktif (`is_active = true`).
   - Kartu memuat: Foto (dari URL atau placeholder default), Nama Kos, Tipe (Putra/Putri/Campur), Lokasi/Area, Harga/bulan, dan Badge Status (Tersedia / Penuh).
2. **Pencarian & Penyaringan (Search & Filter)**:
   - Kolom pencarian teks bebas (mencocokkan kata kunci pada: nama kos, nama kampus, alamat jalan, kecamatan).
   - Filter harga (urutkan termurah/termahal atau filter batas harga).
   - Filter kategori tipe kos (Semua, Putra, Putri, Campur).
   - Filter ketersediaan (menampilkan hanya yang "Tersedia").
3. **Halaman Detail Kos**:
   - Tampilan visual gambar kos (atau placeholder ilustrasi jika tidak ada URL).
   - Informasi lengkap: nama, tipe, alamat lengkap, kampus terdekat, deskripsi detail.
   - Daftar fasilitas kos (WiFi, AC, Kamar Mandi Dalam, Kasur, Lemari, Parkir, Dapur, dll.).
   - Tombol **"Hubungi via WhatsApp"**: Membuka aplikasi WhatsApp ke nomor kontak pemilik dengan pesan template otomatis (misal: *"Halo, saya tertarik dengan kos [Nama Kos] yang ada di KosFinder..."*).

### B. Sisi Pemilik Kos
1. **Autentikasi**:
   - Registrasi (Email & Password).
   - Login & Logout.
2. **Dashboard Kelola Kos**:
   - Melihat daftar semua kos milik pemilik (termasuk yang aktif dan yang diarsipkan).
   - Tombol cepat untuk mengubah status ketersediaan (**Tersedia ↔ Penuh**).
3. **Form Tambah & Edit Kos**:
   - Input: Nama Kos, Tipe Kos (Dropdown: Putra / Putri / Campur).
   - Input: Area / Kampus Terdekat, Alamat Lengkap.
   - Input: Harga Sewa per Bulan.
   - Input: Nomor WhatsApp Pemilik (format internasional/lokal e.g. 08xx / 628xx).
   - Input: Tautan URL Gambar Publik (opsional).
   - Pilihan Fasilitas (Checklist multi-select).
   - Input: Deskripsi Tambahan.
4. **Soft Delete / Arsip**:
   - Opsi nonaktifkan/arsipkan kos (`is_active = false`).
   - Kos yang diarsipkan tidak akan muncul di pencarian publik, namun tetap ada di daftar kelola pemilik dan dapat diaktifkan kembali sewaktu-waktu.

---

## 4. Batasan Versi 1 (Out of Scope)
Sesuai kesepakatan, fitur-fitur berikut **TIDAK** diimplementasikan pada Versi 1:
- ❌ Tidak ada pembayaran online / payment gateway.
- ❌ Tidak ada in-app chat (komunikasi langsung dialihkan ke WhatsApp eksternal).
- ❌ Tidak ada sistem review, rating, atau ulasan.
- ❌ Tidak ada rekomendasi berbasis AI.
- ❌ Tidak ada verifikasi identitas resmi (KTP) pemilik.
- ❌ Tidak ada file upload storage (gambar murni menggunakan link URL publik atau placeholder default aplikasi).
- ❌ Tidak ada peta interaktif (Google Maps / Mapbox).

---

## 5. Desain Database Supabase (PostgreSQL)

### A. Tabel `profiles`
Menyimpan informasi tambahan untuk akun pemilik kos yang terdaftar di `auth.users`.
```sql
create table public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  email text not null,
  full_name text,
  phone_whatsapp text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
```

### B. Tabel `kosts`
Menyimpan data kos yang didaftarkan oleh pemilik.
```sql
create type kost_gender_type as enum ('putra', 'putri', 'campur');
create type kost_availability_status as enum ('tersedia', 'penuh');

create table public.kosts (
  id uuid default gen_random_uuid() primary key,
  owner_id uuid references auth.users(id) on delete cascade not null,
  name text not null,
  gender_type kost_gender_type not null default 'campur',
  area_campus text not null,          -- nama kampus / area / kecamatan
  address text not null,              -- alamat lengkap
  price_monthly integer not null,     -- harga sewa per bulan dalam rupiah
  whatsapp_number text not null,      -- nomor kontak pemilik untuk WA
  image_url text,                     -- URL gambar eksternal (opsional)
  facilities text[] default '{}',     -- array fasilitas: ['WiFi', 'AC', 'KM Dalam', dll.]
  description text,                   -- deskripsi detail
  status kost_availability_status not null default 'tersedia',
  is_active boolean not null default true, -- soft delete flag
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);
```

### C. Row Level Security (RLS)
- **Akses Publik**: Siapapun (termasuk anon/guest) dapat membaca data kos yang aktif (`is_active = true`):
  ```sql
  alter table public.kosts enable row level security;
  
  create policy "Publik dapat melihat kos aktif"
  on public.kosts for select
  using (is_active = true or auth.uid() = owner_id);
  ```
- **Akses Pemilik**: Pemilik hanya dapat mengubah dan menghapus kos miliknya sendiri:
  ```sql
  create policy "Pemilik dapat menambah kos"
  on public.kosts for insert
  with check (auth.uid() = owner_id);

  create policy "Pemilik dapat memperbarui kos miliknya"
  on public.kosts for update
  using (auth.uid() = owner_id);

  create policy "Pemilik dapat menghapus kos miliknya"
  on public.kosts for delete
  using (auth.uid() = owner_id);
  ```

---

## 6. Desain Arsitektur Aplikasi Flutter

### A. Dependensi Utama
- `supabase_flutter`: Integrasi autentikasi & database Supabase.
- `url_launcher`: Membuka link WhatsApp (`https://wa.me/<nomor>?text=...`).
- `intl`: Format mata uang Rupiah (`Rp 1.200.000 / bulan`).
- `cached_network_image`: Menampilkan gambar URL secara optimal dengan cache & fallback placeholder.
- `flutter_dotenv`: Membaca URL dan Anon Key Supabase dari file `.env`.

### B. Struktur Direktori Rekomendasi
```text
lib/
├── core/
│   ├── constants/       # Konstanta warna, gaya teks, list fasilitas standar
│   ├── env/             # Konfigurasi environment (Supabase URL & Anon Key)
│   ├── utils/           # Helper format mata uang, format nomor WA, validator
│   └── widgets/         # Widget global (custom button, text field, image placeholder)
├── data/
│   ├── models/          # KostModel, ProfileModel
│   └── repositories/    # KostRepository, AuthRepository (interaksi Supabase)
├── presentation/
│   ├── screens/
│   │   ├── seeker/      # Home, Search, DetailKos
│   │   ├── auth/        # Login, Register
│   │   └── owner/       # DashboardOwner, FormTambahEditKos
│   └── providers/       # State management / ChangeNotifier
└── main.dart
```

---

## 7. Rencana Tahapan Implementasi
1. **Fase 1: Setup Dependensi & Konfigurasi**
   - Menambahkan library: `supabase_flutter`, `url_launcher`, `intl`, `flutter_dotenv`.
   - Setup konfigurasi `.env` untuk Supabase.
2. **Fase 2: Script Database & Service Client**
   - Menyediakan file migrasi SQL untuk tabel `profiles`, `kosts`, dan RLS policies.
   - Inisialisasi Supabase client di `main.dart`.
3. **Fase 3: Modul Pencari Kos (Public/Guest)**
   - Halaman Home (Daftar kos, search bar, filter chip).
   - Halaman Detail Kos (Visual, fasilitas, info harga, tombol WhatsApp).
4. **Fase 4: Modul Pemilik Kos (Auth & CRUD)**
   - Halaman Login & Registrasi.
   - Halaman Dashboard Pemilik (Daftar kos milik sendiri, toggle Tersedia/Penuh, tombol arsip).
   - Form Tambah & Edit Kos.
5. **Fase 5: Pengujian & Finalisasi**
   - Uji alur guest (pencarian, filter, direct WhatsApp).
   - Uji alur pemilik (auth, CRUD kos, RLS restriction).
   - Push update ke Git repository.
