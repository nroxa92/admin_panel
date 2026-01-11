# VESTA LUMINA DEVELOPER ONBOARDING GUIDE
## New Developer Setup & Best Practices

**Version:** 2.1.0  
**Last Updated:** January 2026

---

## ⚠️ PROPRIETARY - CONFIDENTIAL

```
This documentation is confidential and proprietary to Vesta Lumina d.o.o.
For authorized development personnel only.
```

---

## Table of Contents

1. [Welcome](#1-welcome)
2. [Development Environment Setup](#2-development-environment-setup)
3. [Project Architecture](#3-project-architecture)
4. [Code Standards](#4-code-standards)
5. [Git Workflow](#5-git-workflow)
6. [Testing Guidelines](#6-testing-guidelines)
7. [Deployment Process](#7-deployment-process)
8. [Security Guidelines](#8-security-guidelines)
9. [Resources & Contacts](#9-resources--contacts)

---

## 1. Welcome

### 1.1. About Vesta Lumina

Welcome to the Vesta Lumina development team! You'll be working on a property management platform that consists of:

| Component | Technology | Purpose |
|-----------|------------|---------|
| Admin Panel | Flutter Web | Owner management dashboard |
| Tablet Terminal | Flutter Android | Guest self-service kiosk |
| Backend | Firebase | Authentication, database, functions |
| Functions | Node.js/TypeScript | Server-side logic |

### 1.2. Your First Week

```
Day 1: Environment Setup
├── Install required tools
├── Get access to repositories
├── Set up local development
└── Run both apps locally

Day 2-3: Codebase Exploration
├── Read this documentation
├── Explore Admin Panel code
├── Explore Tablet Terminal code
└── Understand Firebase structure

Day 4-5: First Tasks
├── Pick up a starter issue
├── Make your first PR
├── Get code review
└── Merge first contribution
```

---

## 2. Development Environment Setup

### 2.1. Required Tools

```bash
# Install Flutter
# macOS
brew install flutter

# Or download from https://docs.flutter.dev/get-started/install

# Verify Flutter installation
flutter doctor

# Install Firebase CLI
npm install -g firebase-tools

# Install Node.js (for Cloud Functions)
# Use nvm for version management
nvm install 18
nvm use 18

# Install VS Code extensions
code --install-extension Dart-Code.dart-code
code --install-extension Dart-Code.flutter
code --install-extension ms-vscode.vscode-typescript-next
```

### 2.2. Clone Repositories

```bash
# Create workspace directory
mkdir ~/vesta-lumina && cd ~/vesta-lumina

# Clone repositories (requires access)
git clone git@github.com:nroxa92/admin_panel.git
git clone git@github.com:nroxa92/tablet_terminal.git

# Install dependencies - Admin Panel
cd admin_panel
flutter pub get
cd functions && npm install && cd ..

# Install dependencies - Tablet Terminal
cd ../tablet_terminal
flutter pub get
```

### 2.3. Firebase Setup

```bash
# Login to Firebase
firebase login

# Select project for development
firebase use vestalumina-dev

# Generate Firebase options
cd admin_panel
flutterfire configure --project=vestalumina-dev

cd ../tablet_terminal
flutterfire configure --project=vestalumina-dev --platforms=android
```

### 2.4. Environment Variables

Create `.env` files for each project:

**admin_panel/.env**
```env
FIREBASE_PROJECT_ID=vestalumina-dev
APP_ENV=development
SENTRY_DSN=
OPENAI_API_KEY=
```

**tablet_terminal/.env**
```env
FIREBASE_PROJECT_ID=vestalumina-dev
APP_ENV=development
SENTRY_DSN=
```

### 2.5. Running Locally

```bash
# Admin Panel (Web)
cd admin_panel
flutter run -d chrome

# Tablet Terminal (Android emulator or device)
cd tablet_terminal
flutter run -d <device_id>

# List available devices
flutter devices

# Run Cloud Functions locally
cd admin_panel/functions
npm run serve
```

### 2.6. VS Code Configuration

**settings.json**
```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  "[dart]": {
    "editor.rulers": [80],
    "editor.defaultFormatter": "Dart-Code.dart-code"
  }
}
```

**launch.json**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Admin Panel (Chrome)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["-d", "chrome"]
    },
    {
      "name": "Tablet Terminal (Debug)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart"
    }
  ]
}
```

---

## 3. Project Architecture

### 3.1. Admin Panel Structure

```
admin_panel/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── app/
│   │   ├── app.dart              # Root widget with providers
│   │   ├── router.dart           # GoRouter configuration
│   │   └── theme/                # Theme definitions
│   ├── features/                 # Feature-based modules
│   │   ├── auth/                 # Authentication
│   │   │   ├── screens/          # UI screens
│   │   │   ├── services/         # Business logic
│   │   │   ├── models/           # Data models
│   │   │   └── widgets/          # Feature-specific widgets
│   │   ├── bookings/             # Booking management
│   │   ├── units/                # Property units
│   │   └── ...                   # Other features
│   ├── shared/                   # Shared code
│   │   ├── models/               # Shared data models
│   │   ├── services/             # Shared services
│   │   ├── widgets/              # Reusable widgets
│   │   └── utils/                # Utilities
│   └── l10n/                     # Localization
├── functions/                    # Cloud Functions
│   ├── src/
│   │   ├── index.ts              # Function exports
│   │   └── [feature]/            # Feature functions
│   └── package.json
├── test/                         # Tests
└── pubspec.yaml                  # Dependencies
```

### 3.2. Tablet Terminal Structure

```
tablet_terminal/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── screens/                  # All screens (17 total)
│   ├── services/                 # Business logic (16 services)
│   ├── models/                   # Data models
│   ├── widgets/                  # Reusable widgets
│   ├── utils/                    # Utilities
│   └── l10n/                     # Localization
├── android/                      # Android configuration
└── pubspec.yaml                  # Dependencies
```

### 3.3. State Management

We use **Riverpod 2.0** for state management:

```dart
// Provider definition
final bookingsProvider = StateNotifierProvider<BookingsNotifier, AsyncValue<List<Booking>>>((ref) {
  return BookingsNotifier(ref.watch(bookingRepositoryProvider));
});

// Usage in widget
class BookingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);
    
    return bookingsAsync.when(
      data: (bookings) => BookingsList(bookings: bookings),
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorWidget(error: error),
    );
  }
}
```

### 3.4. Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                        UI LAYER                              │
│  (Screens, Widgets)                                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     STATE LAYER                              │
│  (Riverpod Providers, StateNotifiers)                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   REPOSITORY LAYER                           │
│  (Data access abstraction)                                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    SERVICE LAYER                             │
│  (Firebase, API calls, Local storage)                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Code Standards

### 4.1. Dart Style Guide

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style):

```dart
// ✅ Good: Use camelCase for variables and functions
final userName = 'John';
void calculateTotal() {}

// ✅ Good: Use PascalCase for classes and types
class BookingService {}
typedef BookingCallback = void Function(Booking);

// ✅ Good: Use SCREAMING_CAPS for constants
const maxGuestCount = 10;  // Note: lowerCamelCase for const too

// ✅ Good: Document public APIs
/// Creates a new booking.
/// 
/// Throws [BookingConflictException] if dates overlap.
Future<Booking> createBooking(BookingData data) async {}
```

### 4.2. File Naming

```
✅ Good:
booking_service.dart
booking_model.dart
bookings_screen.dart
booking_card_widget.dart

❌ Bad:
BookingService.dart
booking-service.dart
bookingservice.dart
```

### 4.3. Import Order

```dart
// 1. Dart imports
import 'dart:async';
import 'dart:convert';

// 2. Package imports
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

// 3. Project imports
import 'package:admin_panel/features/bookings/models/booking_model.dart';
import 'package:admin_panel/shared/widgets/loading_indicator.dart';
```

### 4.4. Widget Structure

```dart
class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
  });

  final Booking booking;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      booking.guestName,
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDetails() {
    return Text('${booking.checkIn} - ${booking.checkOut}');
  }
}
```

### 4.5. Error Handling

```dart
// ✅ Good: Specific error handling
try {
  await bookingService.createBooking(data);
} on BookingConflictException catch (e) {
  showErrorSnackbar('Dates conflict with existing booking');
} on NetworkException catch (e) {
  showErrorSnackbar('Network error. Please try again.');
} catch (e, stack) {
  // Log unexpected errors
  logger.error('Unexpected error creating booking', e, stack);
  showErrorSnackbar('Something went wrong');
}

// ❌ Bad: Catching everything silently
try {
  await bookingService.createBooking(data);
} catch (e) {
  // Silent failure
}
```

---

## 5. Git Workflow

### 5.1. Branch Naming

```
feature/VL-123-add-booking-calendar
bugfix/VL-456-fix-checkin-crash
hotfix/VL-789-security-patch
chore/update-dependencies
docs/update-readme
```

### 5.2. Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(bookings): add drag-and-drop calendar
fix(checkin): resolve OCR crash on certain documents
docs(readme): update deployment instructions
chore(deps): update Flutter to 3.32
test(bookings): add unit tests for booking service
refactor(auth): simplify login flow
```

### 5.3. Pull Request Process

1. Create feature branch from `develop`
2. Make changes, commit with meaningful messages
3. Push branch and create PR
4. Fill PR template:
   - Description of changes
   - Screenshots (if UI changes)
   - Testing done
   - Related issues
5. Request review from team members
6. Address review comments
7. Squash and merge when approved

### 5.4. Code Review Checklist

```
☐ Code follows style guide
☐ No commented-out code
☐ No debug print statements
☐ Error handling is appropriate
☐ Tests added/updated
☐ Documentation updated
☐ No security vulnerabilities
☐ Performance considered
```

---

## 6. Testing Guidelines

### 6.1. Test Structure

```
test/
├── services/
│   ├── booking_service_test.dart
│   └── auth_service_test.dart
├── models/
│   ├── booking_model_test.dart
│   └── guest_model_test.dart
├── repositories/
│   └── booking_repository_test.dart
└── widgets/
    ├── booking_card_test.dart
    └── calendar_widget_test.dart
```

### 6.2. Writing Tests

```dart
// Unit test example
void main() {
  group('BookingService', () {
    late BookingService service;
    late MockFirebaseService mockFirebase;

    setUp(() {
      mockFirebase = MockFirebaseService();
      service = BookingService(mockFirebase);
    });

    test('createBooking returns booking with ID', () async {
      // Arrange
      final data = BookingData(
        checkIn: DateTime(2026, 2, 15),
        checkOut: DateTime(2026, 2, 20),
        guestName: 'John Doe',
      );
      when(mockFirebase.createDocument(any, any))
          .thenAnswer((_) async => 'booking_123');

      // Act
      final result = await service.createBooking(data);

      // Assert
      expect(result.id, 'booking_123');
      expect(result.guestName, 'John Doe');
    });

    test('createBooking throws on date conflict', () async {
      // Arrange
      when(mockFirebase.queryDocuments(any, any))
          .thenAnswer((_) async => [existingBooking]);

      // Act & Assert
      expect(
        () => service.createBooking(conflictingData),
        throwsA(isA<BookingConflictException>()),
      );
    });
  });
}
```

### 6.3. Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/booking_service_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 6.4. Test Coverage Goals

| Category | Minimum Coverage |
|----------|------------------|
| Services | 80% |
| Models | 90% |
| Repositories | 80% |
| Widgets | 60% |

---

## 7. Deployment Process

### 7.1. Environments

| Environment | Firebase Project | URL |
|-------------|------------------|-----|
| Development | vestalumina-dev | dev.vestalumina.com |
| Staging | vestalumina-staging | staging.vestalumina.com |
| Production | vestalumina-prod | app.vestalumina.com |

### 7.2. Deployment Steps

```bash
# 1. Ensure tests pass
flutter test

# 2. Build for production
flutter build web --release

# 3. Deploy to staging first
firebase use vestalumina-staging
firebase deploy

# 4. Test on staging

# 5. Deploy to production
firebase use vestalumina-prod
firebase deploy
```

### 7.3. Version Bumping

```bash
# Update version in pubspec.yaml
# Format: major.minor.patch+buildNumber

# Before release
version: 2.1.0+30

# After release
version: 2.1.1+31
```

---

## 8. Security Guidelines

### 8.1. Never Commit

```
❌ API keys
❌ Firebase credentials
❌ Private keys
❌ Passwords
❌ .env files
❌ User data
```

### 8.2. Firestore Rules

Always test security rules:

```bash
# Run rules emulator
firebase emulators:start --only firestore

# Run security rules tests
npm run test:rules
```

### 8.3. Input Validation

```dart
// ✅ Always validate user input
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Invalid email format';
  }
  return null;
}
```

### 8.4. Sensitive Data Handling

```dart
// ✅ Never log sensitive data
logger.info('User logged in: ${user.id}');

// ❌ Don't do this
logger.info('User logged in: ${user.email} with password: ${user.password}');
```

---

## 9. Resources & Contacts

### 9.1. Documentation

| Resource | Link |
|----------|------|
| Flutter Docs | https://docs.flutter.dev |
| Firebase Docs | https://firebase.google.com/docs |
| Riverpod Docs | https://riverpod.dev |
| Dart Style Guide | https://dart.dev/guides/language/effective-dart |

### 9.2. Internal Resources

| Resource | Location |
|----------|----------|
| API Documentation | `/docs/API_DOCUMENTATION.md` |
| Deployment Guide | `/docs/DEPLOYMENT_GUIDE.md` |
| Design System | Figma (ask for access) |
| Architecture Diagrams | Confluence |

### 9.3. Team Contacts

| Role | Contact |
|------|---------|
| Tech Lead | tech@vestalumina.com |
| DevOps | devops@vestalumina.com |
| QA Lead | qa@vestalumina.com |
| Product Owner | product@vestalumina.com |

### 9.4. Getting Help

1. **Check documentation first**
2. **Search existing issues** on GitHub
3. **Ask in team chat** (Slack #dev-help)
4. **Schedule pair programming** session
5. **Escalate to tech lead** if blocked

---

## Onboarding Checklist

```
Week 1:
☐ Development environment set up
☐ Access to all repositories
☐ Access to Firebase Console
☐ Access to Sentry
☐ Access to Slack channels
☐ Read this documentation
☐ Run both apps locally
☐ Explore codebase

Week 2:
☐ Complete first starter issue
☐ Submit first PR
☐ Attend team standup
☐ Meet with mentor

Week 3-4:
☐ Complete 2-3 more issues
☐ Participate in code review
☐ Understand deployment process
☐ Shadow a production deployment
```

---

<p align="center">
  <strong>VESTA LUMINA</strong><br>
  <em>Developer Onboarding Guide</em><br>
  Version 2.1.0<br><br>
  © 2024-2026 Vesta Lumina d.o.o.
</p>
