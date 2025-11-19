# BondUp Mobile - Team Workflow Guide

Panduan workflow untuk tim development BondUp Mobile. Dokumen ini menjelaskan proses development, git workflow, dan best practices yang harus diikuti oleh semua anggota tim.

---

## Table of Contents
- [Development Phases](#-development-phases)
- [Git Workflow](#-git-workflow)
- [Coding Standards](#-coding-standards)
- [Testing Guidelines](#-testing-guidelines)
- [Integration Checklist](#-integration-checklist)
- [Common Issues & Solutions](#-common-issues--solutions)

---

## Development Phases

### **Fase 1: Fondasi (Pekan 1)**
**Target:** Akhir Pekan 1

#### Fitur yang Harus Diselesaikan:
1. **Inisiasi Project dan README**
   - Setup Flutter project
   - Konfigurasi dependencies
   - Update README dengan informasi lengkap

2. **Login & Register**
   - Implementasi UI login & register
   - Integrasi dengan API `/auth/login/` dan `/auth/register/`
   - Simpan session token menggunakan `flutter_secure_storage`
   - Handle error validation

3. **View Profile (Public & Private)**
   - Implementasi UI profile page
   - Integrasi dengan API `GET /profile/` dan `GET /profile/<user_id>/`
   - Tampilkan data user dengan benar

**Target Hasil di Main Branch:**
- Aplikasi Flutter bisa login dan register menggunakan Django API
- Token autentikasi tersimpan dan dapat digunakan untuk request selanjutnya
- Aplikasi dapat menampilkan profil user sendiri dan profil user lain

---

### **Fase 2: Inti (Pekan 2)**
**Target:** Akhir Pekan 2

#### Fitur yang Harus Diselesaikan:
1. **Browse & Search Users**
   - Implementasi UI user list dengan filter
   - Filter: sport, city, skill level
   - Search functionality
   - API: `GET /partner-matching/browse-users-api/`

2. **Event Discovery - List & Detail**
   - Implementasi UI event list dengan filter
   - Filter: sport, date, city
   - Event detail page
   - API: `GET /event-discovery/events/json/`, `GET /event-discovery/events/<id>/json/`

**Target Hasil di Main Branch:**
- Aplikasi dapat menampilkan daftar users dengan filter dan search
- Aplikasi dapat menampilkan list event dengan filter dan detail event

---

### **Fase 3: Interaksi (Pekan 3)**
**Target:** Akhir Pekan 3

#### Fitur yang Harus Diselesaikan:
1. **Connection System (Send/Accept/Reject)**
   - Send connection request
   - Accept/reject incoming requests
   - View connections list
   - API: `POST /partner-matching/connection/<action>/<user_id>/`, `GET /partner-matching/connections/`

2. **Join & Leave Event**
   - Join event functionality
   - Leave event functionality
   - View my joined events
   - API: `POST /event-discovery/events/<id>/join/`, `DELETE /event-discovery/events/<id>/leave/`

3. **Create & Edit Event**
   - Create new event form
   - Edit existing event
   - View my events (upcoming & past)
   - API: `POST /event-management/create/`, `PUT /event-management/<event_id>/edit/`

**Target Hasil di Main Branch:**
- Aplikasi dapat mengirim, menerima, dan menolak connection request
- Aplikasi dapat join dan leave event
- Aplikasi dapat membuat dan mengedit event sebagai organizer

---

### **Fase 4: Finalisasi (Pekan 4)**
**Target:** Pekan 4

#### Fitur yang Harus Diselesaikan:
1. **Review & Rating System**
   - Create review untuk event participants
   - View event reviews
   - View user reviews (received & written)
   - Update & delete review
   - API: `POST /reviews/ajax/event/<event_id>/create/`, dll

2. **Leaderboard & Points Dashboard**
   - Global leaderboard (all time, weekly, monthly)
   - Points dashboard
   - Points history
   - Achievements
   - API: `GET /leaderboard/api/leaderboard/`, dll

3. **Edit Profile & Sport Preferences**
   - Update profile (bio, city, foto)
   - Add/remove sport preferences
   - API: `POST /profile/update/`, `DELETE /profile/sports/<sport_id>/`

4. **Manage Event Participants (Organizer)**
   - View participants list
   - Remove participant
   - Mark attendance
   - Cancel event
   - API: `GET /event-management/<event_id>/participants/`, dll

5. **My Connections & Connection Requests**
   - View all connections
   - View pending requests
   - Remove/accept/reject actions
   - API: `GET /partner-matching/connections/`, dll

6. **Bug Fixing & Integration Testing**
   - End-to-end testing
   - Bug fixes
   - Performance optimization
   - UI/UX improvements

**Target Hasil di Main Branch:**
- Semua fitur terintegrasi dengan baik
- Testing end-to-end flow: Login → Browse → Connect/Join → Create Event → Review → Leaderboard
- Semua API calls menggunakan token authentication dengan benar

---

## Git Workflow

### Branch Strategy

```
main (production-ready code)
  ├── lib 
  │   ├── feature/auth-login
  │   ├── feature/profile-view
  │   ├── feature/event-discovery
  │   └── feature/leaderboard
```

- `feature/<nama-fitur>` - Development branch untuk fitur baru

### Workflow Steps

#### 1. Mulai Fitur Baru
```bash
# Update develop branch
git checkout develop
git pull origin develop

# Buat feature branch baru
git checkout -b feature/nama-fitur

# Contoh:
git checkout -b feature/event-discovery
```

#### 2. Development
```bash
# Lakukan perubahan code
# ...

# Add & commit changes
git add .
git commit -m "feat: implement event discovery list"

# Push ke remote
git push origin feature/nama-fitur
```

#### 3. Pull Request
1. Buka GitHub
2. Create Pull Request dari `feature/nama-fitur` ke `dev`
3. Isi deskripsi PR dengan jelas:
   - Fitur apa yang diimplementasikan
   - API endpoints yang digunakan
   - Screenshot (jika ada perubahan UI)
   - Testing yang sudah dilakukan
4. Request review dari minimal 1 anggota tim
5. Tunggu approval sebelum merge

#### 4. Merge ke Develop
```bash
# Setelah PR approved
# Merge akan dilakukan via GitHub/GitLab interface
# ATAU manual:

git checkout develop
git pull origin develop
git merge feature/nama-fitur
git push origin develop

# Delete feature branch (optional)
git branch -d feature/nama-fitur
git push origin --delete feature/nama-fitur
```

### Commit Message Convention

Gunakan format berikut untuk commit messages:

```
<type>(<scope>): <subject>

<body> (optional)
```

**Types:**
- `feat` - Fitur baru
- `fix` - Bug fix
- `docs` - Perubahan dokumentasi
- `style` - Formatting, missing semicolons, dll (tidak mengubah logic)
- `refactor` - Refactoring code
- `test` - Menambah atau memperbaiki tests
- `chore` - Maintenance tasks

**Contoh:**
```bash
git commit -m "feat(auth): implement login functionality"
git commit -m "fix(profile): fix profile image not loading"
git commit -m "docs: update API documentation"
git commit -m "refactor(event): simplify event list widget"
```

---

## Coding Standards

### Project Structure

```
lib/
├── main.dart                     # Entry point
├── app/                          # Hal umum tingkat aplikasi
│   ├── app_router.dart           # Route setup
│   ├── app_theme.dart            # Global theme
│   └── app_config.dart           # Konfigurasi global
├── core/                         # Bagian yang bisa dipakai semua fitur
│   ├── widgets/                  # Reusable global widgets
│   ├── utils/                    # Helpers, formatters, validators
│   ├── network/                  # HTTP client, interceptors
│   └── constants.dart            # App-wide constants
├── features/                     # Folder utama per fitur
│   ├── auth/
│   │   ├── data/                 # API, models, repository
│   │   ├── logic/                # State management (provider/bloc)
│   │   └── presentation/         # Screens, widgets khusus auth
│   └── leaderboard/
│       ├── data/
│       ├── logic/
│       └── presentation/
├── test/                         # Unit & widget tests
└── pubspec.yaml                  # Dependencies dan config

```

### Naming Conventions

**Files & Folders:**
- Gunakan `snake_case` untuk nama file dan folder
- Contoh: `event_list_screen.dart`, `auth_service.dart`

**Classes:**
- Gunakan `PascalCase` untuk nama class
- Contoh: `EventListScreen`, `AuthService`, `UserModel`

**Variables & Functions:**
- Gunakan `camelCase` untuk variables dan functions
- Contoh: `userName`, `fetchEvents()`, `isLoading`

**Constants:**
- Gunakan `UPPER_SNAKE_CASE` untuk constants
- Contoh: `API_BASE_URL`, `MAX_PARTICIPANTS`

### Code Style

**1. Always use const constructors when possible:**
```dart
// Good
const Text('Hello World')
const SizedBox(height: 16)

// Bad
Text('Hello World')
SizedBox(height: 16)
```

**2. Use meaningful variable names:**
```dart
// Good
final List<Event> upcomingEvents = [];
final bool isLoadingEvents = false;

// Bad
final List<Event> list = [];
final bool loading = false;
```

**3. Add comments for complex logic:**
```dart
// Calculate user's total points from all activities
int calculateTotalPoints(List<PointTransaction> transactions) {
  return transactions.fold(0, (sum, transaction) => sum + transaction.points);
}
```

**4. Handle errors properly:**
```dart
try {
  final events = await eventService.fetchEvents();
  setState(() {
    _events = events;
  });
} catch (e) {
  // Show error message to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to load events: $e')),
  );
}
```

---

## Testing Guidelines

### Unit Tests

Buat unit tests untuk:
- Models (serialization/deserialization)
- Services (API calls dengan mock data)
- Validators
- Helper functions

**Contoh:**
```dart
// test/models/user_test.dart
void main() {
  group('User Model', () {
    test('should create User from JSON', () {
      final json = {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
      };

      final user = User.fromJson(json);

      expect(user.id, 1);
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
    });
  });
}
```

### Widget Tests

Buat widget tests untuk:
- Custom widgets
- Screens (basic rendering)

**Contoh:**
```dart
// test/widgets/event_card_test.dart
void main() {
  testWidgets('EventCard displays event information', (tester) async {
    final event = Event(
      id: 1,
      title: 'Football Match',
      sportType: 'football',
    );

    await tester.pumpWidget(
      MaterialApp(home: EventCard(event: event)),
    );

    expect(find.text('Football Match'), findsOneWidget);
  });
}
```

### Integration Tests

Test end-to-end flows:
- Login → Browse Events → Join Event
- Register → Setup Profile → Browse Users
- Create Event → Manage Participants → Cancel Event

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/models/user_test.dart

# Run tests with coverage
flutter test --coverage
```

---

## Integration Checklist

Sebelum merge ke `develop`, pastikan checklist berikut sudah terpenuhi:

### Code Quality
- [ ] Code mengikuti naming conventions
- [ ] Tidak ada hardcoded values (gunakan constants)
- [ ] Error handling sudah diimplementasikan
- [ ] Code sudah di-format (`flutter format .`)
- [ ] Tidak ada warnings/errors dari analyzer (`flutter analyze`)

### Functionality
- [ ] Fitur berfungsi sesuai requirement
- [ ] API integration berfungsi dengan benar
- [ ] Loading states ditampilkan saat fetch data
- [ ] Error messages ditampilkan dengan jelas
- [ ] Success feedback ditampilkan setelah aksi berhasil

### UI/UX
- [ ] UI responsive di berbagai ukuran layar
- [ ] Konsisten dengan design system
- [ ] Tidak ada overflow/layout issues
- [ ] Smooth transitions/animations
- [ ] Accessible (text readable, buttons tappable)

### Testing
- [ ] Unit tests untuk models & services
- [ ] Widget tests untuk custom widgets
- [ ] Manual testing di emulator/device
- [ ] Tested dengan berbagai skenario (success, error, edge cases)

### Documentation
- [ ] Code comments untuk logic yang kompleks
- [ ] README updated (jika perlu)
- [ ] API endpoints documented
- [ ] PR description lengkap
---

**Happy Coding!**
