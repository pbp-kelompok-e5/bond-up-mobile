# BondUp Mobile 

**Proyek Akhir Semester - Pemrograman Berbasis Platform (PBP) 2025**

BondUp adalah aplikasi mobile berbasis Flutter yang menghubungkan para penggemar olahraga untuk menemukan partner olahraga, mengikuti event, dan membangun komunitas aktif. Aplikasi ini merupakan versi mobile dari web application yang telah dikembangkan pada Proyek Tengah Semester.

---

## Anggota Kelompok

| Nama | NPM | Modul |
|------|-----|-------|
| Muhammad Hariz Albaari | 2406428775 | Authentication & Profile, Leaderboard & Points |
| Tsaniya Fini Ardiyanti | 2406437893 | Partner Matching |
| Farrell Bagoes Rahmantyo | 2406420596 | Event Discovery |
| Muhammad Arief Solomon | 2406343092 | Event Management | 
| Gerry | 2406495464 | Review & Rating |

---

## Deskripsi Aplikasi

### Nama Aplikasi
**BondUp Mobile**

### Fungsi Aplikasi
BondUp Mobile adalah platform yang memfasilitasi para penggemar olahraga untuk:
- **Menemukan Partner Olahraga** - Cari dan terhubung dengan orang-orang yang memiliki minat olahraga yang sama
- **Mengikuti Event Olahraga** - Temukan dan ikuti berbagai event olahraga di sekitar Anda
- **Berkompetisi di Leaderboard** - Kumpulkan poin dari aktivitas dan raih achievement
- **Memberikan Review & Rating** - Berikan feedback untuk partner olahraga setelah event
- **Mengelola Profil** - Atur preferensi olahraga dan informasi pribadi Anda

---

## Role/Aktor Pengguna Aplikasi

### 1. Guest User (Belum Login)
**Akses:**
- Melihat halaman landing/welcome
- Register akun baru
- Login ke aplikasi

**Batasan:**
- Tidak dapat mengakses fitur utama aplikasi
- Tidak dapat melihat event atau user lain

---

### 2. Authenticated User (Sudah Login)
**Akses:**
- Semua fitur Guest User
- Melihat dan edit profil sendiri
- Browse dan search users
- Send/accept/reject connection requests
- Browse dan search events
- Create event baru
- Join dan leave events
- Memberikan review untuk event yang sudah attended
- Melihat leaderboard dan points dashboard
- Manage sport preferences

**Batasan:**
- Tidak dapat mengedit event yang dibuat orang lain
- Tidak dapat manage participants event orang lain

---

### 3. Event Organizer (User yang membuat event)
**Akses:**
- Semua fitur Authenticated User
- Edit event yang dibuat sendiri
- Delete/cancel event yang dibuat sendiri
- Manage participants (remove, mark attendance)
- View participants list

**Batasan:**
- Hanya dapat manage event yang dibuat sendiri
- Tidak dapat menghapus review yang diberikan user lain

---

## Alur Pengintegrasian dengan Web Service

Alur pengintegrasian dengan web service dapat dilihat pada file berikut:
[WORKFLOW.md](docs/WORKFLOW.md)

---

## Design & Prototype

**Link Figma:** https://www.figma.com/design/FyD4mI3SwzVciuyidRCaim/Desain--Nama-Web-App-?node-id=0-1&t=sEvdR4GK5FUhPnUp-1

---

## Getting Started

### Prerequisites
- Flutter SDK (versi 3.9.2 atau lebih baru)
- Dart SDK
- Android Studio / VS Code dengan Flutter extension
- Android Emulator / iOS Simulator / Physical Device

### Installation

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd bond_up_mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```
---

## Project Structure

```
bond_up_mobile/
├── lib/
│   ├── app/                       # App-level setup (routes, themes, config)
│   ├── core/                      # Global utilities, constants, widgets
│   ├── features/                  # Folder utama per-feature
│   │   ├── auth/
│   │   │   ├── data/             # Models, API, repository
│   │   │   ├── logic/            # Provider / Bloc / Controller
│   │   │   └── presentation/               # Screens, widgets
│   │   ├── salary/
│   │   ├── profile/
│   │   └── dashboard/
│   ├── main.dart                  # Entry point
│   └── ...
├── docs/
│   ├── API_DOCS.md
│   └── WORKFLOW.md
├── test/
└── pubspec.yaml
```

---

## Resources
- [API Documentation](docs/API_DOCS.md)
- [Team Workflow](docs/WORKFLOW.md)

---

## License

This project is developed as part of PBP 2025 course assignment.

---

**Developed with ❤️ by E05 - PBP 2025**
