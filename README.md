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
| Gerry Bima Putra| 2406495464 | Review & Rating |

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
- Flutter SDK (versi 3.3.0 atau lebih baru)
- Dart SDK (versi 3.3.0 atau lebih baru)
- Android Studio / VS Code dengan Flutter extension
- Android Emulator / iOS Simulator / Physical Device

### Installation

1. **Clone repository**
   ```bash
   git clone https://github.com/pbp-kelompok-e5/bond-up-mobile
   cd bond-up-mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/data/services/auth_service_test.dart
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

## Features Overview

### Authentication & Profile
**Developer:** Muhammad Hariz Albaari

- **Login & Register** - Secure authentication with Django backend
- **Profile Management** - View and edit user profiles
- **Sport Preferences** - Manage favorite sports and skill levels
- **Session Management** - Persistent login with secure token storage

### Partner Matching
**Developer:** Tsaniya Fini Ardiyanti

- **Browse Users** - Discover other sports enthusiasts
- **Advanced Filters** - Filter by sport, city, and skill level
- **Connection System** - Send, accept, and reject connection requests
- **User Recommendations** - Get matched with compatible partners

### Event Discovery
**Developer:** Farrell Bagoes Rahmantyo

- **Browse Events** - Explore upcoming sports events
- **Event Filters** - Filter by sport type, date, and location
- **Event Search** - Search events by title and description
- **Join/Leave Events** - Participate in events with one tap
- **My Joined Events** - Track all your event participations

### Event Management
**Developer:** Muhammad Arief Solomon

- **Create Events** - Organize new sports events
- **Edit Events** - Update event details and settings
- **Manage Participants** - View, remove, and mark attendance
- **Event Status** - Track event status (open, full, completed, cancelled)
- **My Events** - View upcoming and past events you organized

### Review & Rating
**Developer:** Gerry Bima Putra

- **Event Reviews** - Rate participants after events
- **User Reviews** - View reviews received and written
- **Update/Delete Reviews** - Manage your submitted reviews
- **Rating System** - 5-star rating with comments

### Leaderboard & Points
**Developer:** Muhammad Hariz Albaari

- **Global Leaderboard** - Compete with other users
- **Points Dashboard** - Track your points breakdown
- **Points History** - View detailed transaction history
- **Achievements** - Unlock badges and earn bonus points

---

## Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **Provider** - State management solution
- **pbp_django_auth** - Django authentication integration

### Backend Integration
- **Django** - Backend 
- **Session-based Auth** - Secure authentication
- **JSON API** - RESTful data exchange

### Key Dependencies
```yaml
dependencies:
  flutter: sdk
  provider: ^6.1.5+1              # State management
  pbp_django_auth: ^0.4.0         # Django authentication
  http: ^1.6.0                    # HTTP requests
  shared_preferences: ^2.5.3      # Local storage
  image_picker: ^1.2.1            # Image selection
  intl: ^0.19.0                   # Date formatting

dev_dependencies:
  flutter_test: sdk
  flutter_lints: ^5.0.0           # Linting rules
  mockito: ^5.6.1                 # Testing mocks
  build_runner: ^2.10.4           # Code generation
```

---

## Design System

BondUp Mobile implements a custom design system based on the web application's `.global.css` for visual consistency across platforms.

### Color Palette
- **Primary (Orange Sport):** `#FF6B35` - Main brand color
- **Secondary (Deep Sea):** `#004E89` - Accent color
- **Success:** `#28A745` - Success states
- **Warning:** `#FFC107` - Warning states
- **Danger:** `#DC3545` - Error states

### Components
- **AppButton** - Customizable buttons (primary, secondary, danger, success)
- **AppTextField** - Styled input fields
- **AppChip** - Sport and skill level chips
- **DeepSeaCard** - Consistent card styling
- **StatusBadge** - Event and connection status indicators

For detailed design system documentation, see [core/DESIGN_SYSTEM.md](lib/core/DESIGN_SYSTEM.md)

---

## API Integration

BondUp Mobile integrates with the Django backend API for all data operations.

**Base URL:** `https://farrell-bagoes-sigmaapp.pbp.cs.ui.ac.id`

### Authentication Flow
1. User logs in via `/auth/flutter/login/`
2. Session cookie is stored using `pbp_django_auth`
3. All subsequent requests include the session cookie
4. Token is persisted using `shared_preferences`

### Key Endpoints
- **Auth:** `/auth/flutter/login/`, `/auth/flutter/register/`, `/auth/flutter/logout/`
- **Profile:** `/profile/api/`, `/profile/update/`, `/profile/sports/`
- **Partner Matching:** `/partner-matching/browse-users-api/`, `/partner-matching/connections/`
- **Events:** `/event-discovery/events/json/`, `/event-management/create/`
- **Reviews:** `/reviews/ajax/event/<id>/create/`, `/reviews/user/<id>/`
- **Leaderboard:** `/leaderboard/api/flutter/leaderboard/`, `/leaderboard/api/flutter/points-dashboard/`

For complete API documentation, see [docs/API_DOCS.md](docs/API_DOCS.md)

---

## State Management

The app uses **Provider** for state management with the following providers:

- **CookieRequest** - Global HTTP client with session management
- **AuthService** - Authentication state and operations
- **BrowseUsersProvider** - User browsing and filtering state
- **ConnectionsProvider** - Connection requests and friends list state

---

## Testing

The project includes comprehensive unit tests for critical components:

### Test Coverage
- ✅ **Auth Service** - Login, register, logout functionality
- ✅ **Auth Models** - User model serialization
- ✅ **Leaderboard Service** - API integration tests
- ✅ **Leaderboard Models** - Entry and points history models
- ✅ **Points History Models** - Transaction model tests

### Running Tests
```bash
# Run all tests
flutter test

# Run with coverage report
flutter test --coverage

# View coverage in browser (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Development Workflow

### Git Workflow
1. Create feature branch: `git checkout -b feature/nama-fitur`
2. Make changes and commit: `git commit -m "feat: description"`
3. Push to remote: `git push origin feature/nama-fitur`
4. Create Pull Request to `main`
5. Wait for review and approval
6. Merge to `main`

### Commit Message Convention
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code formatting
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

For detailed workflow guide, see [docs/WORKFLOW.md](docs/WORKFLOW.md)

---

## Resources

### Documentation
- [API Documentation](docs/API_DOCS.md) - Complete API endpoint reference
- [Team Workflow](docs/WORKFLOW.md) - Development workflow and best practices
- [Design System](lib/core/DESIGN_SYSTEM.md) - UI component library
- [Features Guide](docs/FEATURES.md) - Detailed feature documentation
- [Testing Guide](docs/TESTING.md) - Testing strategy and best practices

### External Links
- [Figma Design](https://www.figma.com/design/FyD4mI3SwzVciuyidRCaim/Desain--Nama-Web-App-?node-id=0-1&t=sEvdR4GK5FUhPnUp-1)
- [Backend Repository](https://github.com/pbp-kelompok-e5/sigma-app)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Django Documentation](https://docs.djangoproject.com/)

---

## Contributing

This is a course project for PBP 2025. Contributions are limited to team members.

### Team Members
- **Muhammad Hariz Albaari** - Authentication, Profile, Leaderboard
- **Tsaniya Fini Ardiyanti** - Partner Matching
- **Farrell Bagoes Rahmantyo** - Event Discovery
- **Muhammad Arief Solomon** - Event Management
- **Gerry Bima Putra** - Review & Rating

---

## License

This project is developed as part of PBP 2025 course assignment at Universitas Indonesia.

---

**Developed with ❤️ by Team E05 - PBP 2025**
