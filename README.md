# Kisa (Ruang Privat Eksklusif Dua Hati) ❤️✨

<p align="center">
  <img src="assets/images/app_logo.png" width="128" height="128" alt="Kisa App Logo" style="border-radius: 28px;" />
</p>

<p align="center">
  <b>A bespoke, intimate real-time companion app crafted for couples to stay connected, share memories, track live location, and build their future together.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL" />
  <img src="https://img.shields.io/badge/Platforms-Android%20%7C%20iOS-F43F5E?style=for-the-badge" alt="Platforms" />
</p>

---

## 🌟 Fitur Utama (Key Features)

### 1. 📍 Peta Cinta Real-time & Pelacakan Jarak (Live Map)
* **OpenStreetMap Resmi**: Desain peta minimalis pastel bebas dari gangguan komersial, 100% gratis tanpa batas kuota atau API key berbayar.
* **Perhitungan Jarak Otomatis**: Menggunakan *Haversine Formula* untuk menghitung jarak fisik riil antara kamu dan pasangan dalam satuan meter/kilometer.
* **Marker Avatar & Balon Status**: Pin marker foto avatar berpasangan dengan balon aktivitas live yang bergerak seketika.
* **Garis Koneksi Cinta**: Garis putus-putus (*dashed rose polyline*) yang menghubungkan koordinat kedua ponsel.
* **Fitur Love Poke**: Kirim getaran cinta dan pelukan hangat dengan notifikasi interaktif.
* **GPS Fast-Cache**: Membaca sinyal BTS/Wi-Fi instan (<50 ms) agar lokasi tetap akurat saat berada di dalam ruangan.

### 2. 💬 Status Aktivitas Terkini ("Lagi Ngapain Sekarang?")
* **12 Preset Cepat Ber-emoji**: Kerja, Ngopi, Kangen Kamu, Istirahat, Belajar, Nonton Film, Jalan-jalan, Olahraga, dll.
* **Status Custom & Emoji Bebas**: Menuliskan aktivitas personal apa pun secara fleksibel.
* **Sinkronisasi Multi-Screen**: Status otomatis diperbarui serentak di pin peta, bar linimasa, dan halaman profil pasangan secara *real-time*.

### 3. 🔐 Sistem Pairing Dua Hati & Autentikasi Privat
* **Kode Pairing Unik**: Menghubungkan dua ponsel menggunakan kode unik (format `KIS-XXX` / `FEX-XXX`).
* **Database Row Level Security (RLS)**: Enkripsi dan isolasi di level database PostgreSQL. Data kalian 100% tertutup dan mustahil diakses pengguna lain.
* **Real-time Reactivity**: Kedua ponsel otomatis langsung masuk ke dashboard utama bersamaan begitu tombol *Hubungkan Hati* ditekan.

### 4. 📖 Scrapbook Momen Romantis (Timeline)
* **Tampilan Asimetris Polaroid**: Kartu catatan kenangan dengan nuansa jurnal personal bernuansa hangat.
* **Mood Emoji & Tag Lokasi**: Setiap catatan kenangan dilengkapi penanda suasana hati dan lokasi.
* **Love Burst Animation**: Efek ledakan partikel cinta saat menekan tombol suka (*love*).
* **Format Tanggal Indonesia**: Penulisan tanggal lokal yang nyaman dibaca (contoh: *20 Okt*).

### 5. 🥂 Wishlist & Bucket List Berdua (Shared To-Do)
* **Daftar Target Bersama**: Tempat menaruh rencana kencan, rencana liburan, atau wishlist belanja berdua.
* **Kategori & Prioritas**: Movie 🍿, Trip ✈️, Food 🍲, Nest 🌱, dan Impian ✨ dengan level prioritas (High, Med, Low).
* **Kotak Ceklis Beranimasi Bouncy**: Ceklis interaktif berbasis canvas kustom dengan haptic feedback.
* **Optimistic Updates**: Perubahan centang langsung ter-update seketika di layar tanpa jeda loading.

### 6. 💖 Profil Cinta & Penghitung Hari Jadian (Ruang Kita)
* **Anniversary Counter**: Menghitung otomatis total hari kalian bersama (contoh: *"281 hari penuh cerita"*).
* **Bio Cinta & Avatar Berpasangan**: Menampilkan foto profil pasangan dan kutipan cinta berdua.
* **Edit Profil Anti-Crash**: Ubah nama, pilih kurasi foto avatar, bio, dan kalender pemilih tanggal jadian berformat bahasa Indonesia.

---

## 🛡️ Lapisan Keamanan (Security Shield)

* **Anti-Brute Force (Rate Limiting)**: Form otomatis terkunci 30 detik jika terjadi 5 kesalahan berturut-turut, lengkap dengan timer hitung mundur.
* **Sanitasi Input (Anti-XSS)**: Seluruh input (nama, email, status, to-do, bio, momen) disaring dari tag HTML `<script>` dan karakter kontrol berbahaya.
* **Validasi Standar RFC 5322**: Pengecekan keabsahan email dan panjang kata sandi (6–72 karakter).
* **Protected Route Guards**: Rute dashboard utama dan halaman pairing dilindungi penuh. Sesi habis otomatis dialihkan ke halaman login.
* **Zero-Leak Error Masking**: Pesan error teknis database/Postgres disaring menjadi pesan bahasa Indonesia yang ramah tanpa membocorkan skema SQL atau *stack trace*.

---

## 🛠️ Tech Stack & Arsitektur

* **Framework**: [Flutter](https://flutter.dev) (v3.24+)
* **Language**: [Dart](https://dart.dev) (v3.5+)
* **State Management**: [Flutter Riverpod](https://riverpod.dev)
* **Backend as a Service**: [Supabase Cloud](https://supabase.com)
  * Supabase Auth (Email & Password)
  * PostgreSQL 15+ dengan Real-time Subscriptions & RLS
  * Database Functions (RPC) & PostgreSQL Triggers
* **Maps & GPS**:
  * [flutter_map](https://pub.dev/packages/flutter_map) + [latlong2](https://pub.dev/packages/latlong2)
  * [OpenStreetMap Tile Server](https://tile.openstreetmap.org/)
  * [geolocator](https://pub.dev/packages/geolocator)
* **Typography**: Google Fonts ([Plus Jakarta Sans](https://fonts.google.com/specimen/Plus+Jakarta+Sans))

---

## 📂 Struktur Direktori Proyek

```text
lib/
├── core/
│   ├── services/       # Location & GPS Tracking Service
│   ├── theme/          # AppColors, Typography, AppTheme, Shadows
│   ├── utils/          # Haversine Calculator, Security Sanitizer & Validator
│   ├── widgets/        # BouncyButton, GlassyContainer, AvatarMarker, Toast, Header
│   └── supabase_client.dart # Central Supabase Client & Real-time Streams
├── features/
│   ├── activities/     # Scrapbook, Momen, Foto, Timeline
│   ├── auth/           # Login, Register, Pairing Screen, Status Sheet
│   ├── map/            # Live Map, Distance Bottom Sheet, GPS Stream
│   ├── navigation/     # MainNavigationScaffold, Floating Glassy Bar
│   ├── profile/        # Profil Kita, Edit Profile Sheet, Anniversary Counter
│   └── todos/          # Shared Wishlist, Bucket List, Animated Checkbox
└── main.dart           # App Entrypoint & Route Guards
```

---

## 🚀 Memulai (Getting Started)

### Prasyarat
* Flutter SDK (3.24.x ke atas)
* Java OpenJDK 17 LTS
* Akun [Supabase](https://supabase.com)

### 1. Clone Repositori
```bash
git clone https://github.com/nerolurien/kisa.git
cd kisa
```

### 2. Install Dependensi
```bash
flutter pub get
```

### 3. Konfigurasi Environment (.env)
Salin berkas `.env.example` menjadi `.env`, lalu isi dengan kredensial proyek Supabase Anda:
```bash
cp .env.example .env
```
Contoh isi file `.env`:
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key-here
```
> 🛡️ **Keamanan**: Berkas `.env` telah dimasukkan ke dalam `.gitignore` sehingga rahasia/kredensial API tidak akan pernah bocor ke repositori remote.

### 4. Setup Database Supabase
Jalankan seluruh query SQL yang ada di berkas [`supabase/schema.sql`](supabase/schema.sql) pada menu **SQL Editor** di Dashboard Supabase kamu.

### 5. Menjalankan Aplikasi
```bash
# Debug mode di perangkat yang terhubung
flutter run

# Cek kualitas & integritas kode
flutter analyze
```

### 6. Kompilasi Rilis

#### Android (Release APK):
```bash
flutter build apk --release
# File APK tersimpan di: build/app/outputs/flutter-apk/app-release.apk
```

#### iOS (Release IPA via GitHub Actions):
1. Push kode ke repositori GitHub.
2. Buka tab **Actions** di GitHub repository kamu.
3. Jalankan workflow **Build iOS IPA (Sideloadly)**.
4. Download artifact file `Kisa.ipa` yang dihasilkan untuk di-sideload menggunakan Sideloadly.
