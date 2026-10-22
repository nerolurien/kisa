Product Requirements Document (PRD): Kisa

Project Name: Kisa
Platform: Mobile Native (Android & iOS)
Tech Stack: Flutter (Frontend), Riverpod (State Management), Supabase (PostgreSQL, Auth, Realtime)
Design Language: Premium Soft Modern (Cozy, Intimate, Tactile - Anti Material Design Default)

1. Product Overview

Kisa adalah aplikasi seluler companion privat eksklusif yang dirancang hanya untuk dua orang (Kip & Pipit). Aplikasi ini berfungsi sebagai ruang digital bersama untuk melacak lokasi secara real-time/background (peace of mind), berbagi momen keseharian (timeline), dan merencanakan masa depan (shared bucket list), jauh dari kebisingan sosial media publik.

2. Target Audience

Pasangan (Kip & Pipit). Sistem dikunci dan diarsiteki hanya untuk skenario 1-on-1 pairing.

3. Core Features & Specifications

A. Authentication & Account Pairing

Sistem login tidak berdiri sendiri, melainkan harus saling terikat (paired) melalui Supabase Auth.

Requirements:

Autentikasi menggunakan Email dan Password.

Setelah register, user masuk ke state Onboarding.

Pairing System: User pertama melakukan generate kode unik (Pairing Code). User kedua memasukkan kode tersebut di perangkatnya.

Database action: partner_id masing-masing user saling terisi. Setelah terikat, keduanya otomatis diarahkan ke Dashboard utama.

B. Shared To-Do & Bucket List

Daftar target, tugas, atau wishlist yang disinkronkan secara real-time via Supabase Realtime.

Requirements:

Input: Teks target, prioritas (Low/Med/High), dan Kategori (misal: 🍿 Movie, ✈️ Trip, 🍲 Food).

Interactivity: Ceklis tugas harus menggunakan Optimistic UI di sisi klien (langsung tercoret/animasi tanpa menunggu respons server).

Gamification: Menampilkan Progress Bar persentase impian yang sudah dicapai berdua (misal: "Kita udah nyelesaiin 15 bucket list bareng! 🥂").

Gunakan interaksi swipe-to-delete bawaan Flutter yang sudah dimodifikasi secara visual.

C. Private Activity Timeline (Scrapbook Feed)

Mini-sosmed untuk berbagi pembaruan status harian dengan tampilan organik.

Requirements:

Data fields: Konten teks, Mood (pilihan emoji interaktif), Timestamp, dan Location Tag (opsional).

UI Layout: Asimetris ala scrapbook. Postingan milik sendiri dan pasangan dibedakan dari sisi alignment atau warna kartu (sangat halus).

Interaksi: Tombol react hati ganda (double tap to love dengan animasi Hero atau Scale).

D. Live Location & Background Map Tracking

Pelacakan koordinat GPS yang mengandalkan kapabilitas native Flutter.

Requirements:

Menampilkan peta interaktif menggunakan flutter_map (OpenStreetMap) atau google_maps_flutter dengan custom styling (pastel/bersih).

Titik lokasi menggunakan custom marker widget (Avatar/Inisial wajah masing-masing).

Background Tracking: Terintegrasi dengan servis lokasi latar belakang agar lokasi tetap update meski HP terkunci (memanfaatkan kapabilitas native Flutter).

Bottom Sheet Info: Menampilkan teks kalkulasi jarak real-time (menggunakan Haversine formula di Dart: "Pipit berjarak 4.2 km dari lokasimu") dan cap waktu terakhir diperbarui.

4. UI/UX & Design Guidelines (Anti-Slop & Anti-Material)

Kisa TIDAK BOLEH terlihat seperti aplikasi Material Design standar bawaan Flutter. Aplikasi harus terasa seperti aplikasi iOS kelas atas atau VisionOS.

Widget Rules: Dilarang menggunakan AppBar, Card, FloatingActionButton, atau BottomNavigationBar bawaan tanpa kustomisasi ekstrem. Buat custom widget.

Warna Utama: Off-white/Cream (#FAFAFA) untuk background, Warm Rose/Blush (#f43f5e) untuk action buttons dan aksen.

Tipografi: Geometris dan bersih (menggunakan google_fonts: Satoshi, Plus Jakarta Sans, atau Urbanist). TIDAK menggunakan warna hitam murni (#000000), gunakan Slate/Zinc gelap.

Bentuk & Bayangan: Sudut membulat ekstrem (BorderRadius.circular(24) atau 32 / Squircle). Gunakan bayangan yang sangat halus (diffused drop shadow / BoxShadow dengan opasitas rendah dan blur radius besar), abaikan properti elevation bawaan.

Transisi & Efek: Gunakan BackdropFilter (Kaca buram / Glassmorphism) untuk navigasi bawah dan overlay. Semua interaksi tombol harus memiliki efek bouncy (AnimatedContainer / TweenAnimationBuilder).

5. Data Architecture (Supabase Schema)

Semua pemodelan data di Dart harus mencerminkan skema tabel Supabase berikut:

Users: id (UUID), email, name, partner_id (UUID, FK to Users), avatar_url, created_at.

Todos: id (UUID), created_by (UUID), text, is_completed (Boolean), category (String), priority (String), created_at.

Activities: id (UUID), user_id (UUID), content, mood_emoji, photo_url, created_at.

Locations: id (UUID), user_id (UUID), latitude (Double), longitude (Double), updated_at (Timestamp).