# 🏨 Vesta Lumina Admin Panel

> **Enterprise Property Management System**
> **Part of Vesta Lumina System**

[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.32+-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-orange.svg)](https://firebase.google.com)
[![Version](https://img.shields.io/badge/Version-0.0.9-blue.svg)]()
[![Status](https://img.shields.io/badge/Status-Beta-yellow.svg)]()

---

## ⚠️ PRAVNA NAPOMENA / LEGAL NOTICE

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║                    ⚖️  VLASNIČKI SOFTVER / PROPRIETARY SOFTWARE  ⚖️            ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  🇭🇷 HRVATSKI:                                                                 ║
║  Ovaj softver je PRIVATNO VLASNIŠTVO i zaštićen zakonima o autorskim         ║
║  pravima. Repozitorij je javno vidljiv ISKLJUČIVO u svrhu demonstracije.     ║
║                                                                               ║
║  🇬🇧 ENGLISH:                                                                  ║
║  This software is PROPRIETARY and protected by copyright law.                ║
║  Repository is publicly visible FOR DEMONSTRATION PURPOSES ONLY.             ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  🔒 STROGO ZABRANJENO / STRICTLY PROHIBITED:                                  ║
║                                                                               ║
║     ❌ Kopiranje, kloniranje ili preuzimanje koda                             ║
║     ❌ Reverse engineering ili dekompilacija                                  ║
║     ❌ Korištenje u komercijalne ili osobne svrhe                             ║
║     ❌ Distribucija ili dijeljenje bilo kojeg dijela                          ║
║     ❌ Kreiranje izvedenih djela                                              ║
║     ❌ Korištenje za AI/ML treniranje                                         ║
║                                                                               ║
║  ⚖️ PRAVNE POSLJEDICE:                                                        ║
║     Neovlašteno korištenje podliježe građanskoj i kaznenoj odgovornosti      ║
║     prema međunarodnim zakonima o autorskim pravima (DMCA, Bern Convention). ║
║                                                                               ║
║  📧 Kontakt: nevenroksa@gmail.com | GitHub: @nroxa92                         ║
║                                                                               ║
║                        © 2025-2026 Sva prava pridržana                        ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## 📋 Sadržaj

- [O Projektu](#-o-projektu)
- [Vesta Lumina System](#-vesta-lumina-system)
- [Statistika Projekta](#-statistika-projekta)
- [Tehnička Arhitektura](#-tehnička-arhitektura)
- [Kompletna Struktura Projekta](#-kompletna-struktura-projekta)
- [Funkcionalnosti](#-funkcionalnosti)
- [Cloud Functions API](#-cloud-functions-api)
- [Sigurnosni Model](#-sigurnosni-model)
- [Lokalizacija](#-lokalizacija)
- [Teme i Personalizacija](#-teme-i-personalizacija)
- [Verzije](#-verzije)

---

## 🎯 O Projektu

**Vesta Lumina Admin Panel** je enterprise-grade web aplikacija za upravljanje smještajnim objektima. Omogućuje vlasnicima vila, apartmana i soba kompletno digitalno upravljanje poslovanjem kroz intuitivno sučelje.

### Ključne Značajke

- Multi-tenant arhitektura s potpunom izolacijom podataka
- Drag & Drop kalendar rezervacija
- 10 tipova PDF dokumenata
- Podrška za 11 jezika
- 10 tema boja + 6 pozadinskih tonova (dark/light)
- Real-time sinkronizacija s Firebase
- Offline podrška s automatskom sinkronizacijom

---

## 🌟 Vesta Lumina System

**Vesta Lumina System** je kompletni ekosustav za upravljanje smještajnim objektima koji se sastoji od:

| Komponenta | Opis | Tehnologija | Status |
|------------|------|-------------|--------|
| **Vesta Lumina Admin Panel** | Web aplikacija za vlasnike | Flutter Web | ✅ Beta |
| **Vesta Lumina Client Terminal** | Tablet aplikacija za goste (Kiosk mode) | Flutter Android | 🔄 U razvoju |
| **Firebase Backend** | Cloud infrastruktura | Firebase (Firestore, Auth, Storage, Functions) | ✅ Aktivan |

### Live Demo

🌐 **Production URL:** `https://vls-admin.web.app`

---

## 📊 Statistika Projekta

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                     VESTA LUMINA ADMIN PANEL v0.0.9                           ║
║                          KOMPLETNA STATISTIKA                                 ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  📁 IZVORNI KOD (lib/)                                                        ║
║  ───────────────────────────────────────────────────────────────────────────  ║
║  │ Screens (13 datoteka)              │ 12,390 linija                        ║
║  │ Services (19 datoteka)             │ 5,671 linija                         ║
║  │ Widgets (7 datoteka)               │ 3,755 linija                         ║
║  │ Config (3 datoteke)                │ 2,418 linija                         ║
║  │ Repositories (3 datoteke)          │ 993 linija                           ║
║  │ Utils (1 datoteka)                 │ 640 linija                           ║
║  │ Models (4 datoteke)                │ 618 linija                           ║
║  │ Providers (1 datoteka)             │ 126 linija                           ║
║  │ Root (main.dart, firebase_options) │ 741 linija                           ║
║  │                                                                           ║
║  │ UKUPNO DART KOD                    │ 27,352 linija                        ║
║                                                                               ║
║  ⚡ CLOUD FUNCTIONS (functions/)                                              ║
║  ───────────────────────────────────────────────────────────────────────────  ║
║  │ index.js (20 funkcija)             │ 1,265 linija                         ║
║  │ api_versioning.js                  │ 242 linija                           ║
║  │                                                                           ║
║  │ UKUPNO JS KOD                      │ 1,507 linija                         ║
║                                                                               ║
║  🧪 TESTOVI (test/)                                                           ║
║  ───────────────────────────────────────────────────────────────────────────  ║
║  │ Test datoteke (14 datoteka)        │ 3,908 linija                         ║
║  │ Broj testova                       │ 138 testova                          ║
║                                                                               ║
║  🌍 LOKALIZACIJA                                                              ║
║  ───────────────────────────────────────────────────────────────────────────  ║
║  │ Podržani jezici                    │ 11 jezika                            ║
║  │ Prijevodni ključevi                │ 178 ključeva                         ║
║  │ Ukupno prijevoda                   │ 1,958 prijevoda                      ║
║                                                                               ║
║  📄 PDF GENERIRANJE                                                           ║
║  ───────────────────────────────────────────────────────────────────────────  ║
║  │ Tipovi dokumenata                  │ 10 tipova                            ║
║                                                                               ║
║  🎨 TEME                                                                      ║
║  ───────────────────────────────────────────────────────────────────────────  ║
║  │ Primarne boje                      │ 10 boja                              ║
║  │ Pozadinski tonovi                  │ 6 (3 dark + 3 light)                 ║
║                                                                               ║
║  ☁️ FIREBASE                                                                  ║
║  ───────────────────────────────────────────────────────────────────────────  ║
║  │ Cloud Functions                    │ 20 funkcija                          ║
║  │ Firestore kolekcije                │ 16 kolekcija                         ║
║  │ Kompozitni indeksi                 │ 11 indeksa                           ║
║                                                                               ║
║  ═══════════════════════════════════════════════════════════════════════════  ║
║  │ UKUPNO LINIJA KODA                 │ 32,767+ linija                       ║
║  │ UKUPNO DATOTEKA                    │ 75+ datoteka                         ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## 🏗️ Tehnička Arhitektura

### Technology Stack

```
┌────────────────────────────────────────────────────────────────────┐
│                           FRONTEND                                  │
│  Flutter 3.32+ │ Dart 3.x │ Material Design │ Provider State Mgmt  │
├────────────────────────────────────────────────────────────────────┤
│                           BACKEND                                   │
│  Firebase Auth │ Cloud Firestore │ Cloud Storage │ Cloud Functions │
├────────────────────────────────────────────────────────────────────┤
│                         INFRASTRUCTURE                              │
│  Firebase Hosting │ Node.js 20 │ Google Cloud │ europe-west3       │
└────────────────────────────────────────────────────────────────────┘
```

### Multi-Tenant Architecture

```
                                    ┌─────────────────────────┐
                                    │      Super Admin        │
                                    │ vestaluminasystem@gmail │
                                    └───────────┬─────────────┘
                                                │
                    ┌───────────────────────────┼───────────────────────────┐
                    │                           │                           │
                    ▼                           ▼                           ▼
           ┌───────────────┐           ┌───────────────┐           ┌───────────────┐
           │   Owner A     │        │   Owner B     │        │   Owner C     │
           │  (Tenant 1)   │        │  (Tenant 2)   │        │  (Tenant 3)   │
           └───────┬───────┘        └───────┬───────┘        └───────┬───────┘
                   │                        │                        │
         ┌─────────┼─────────┐              │              ┌─────────┼─────────┐
         ▼         ▼         ▼              ▼              ▼         ▼         ▼
      ┌─────┐  ┌─────┐  ┌─────┐         ┌─────┐       ┌─────┐  ┌─────┐  ┌─────┐
      │Unit1│  │Unit2│  │Unit3│         │Unit1│       │Unit1│  │Unit2│  │Unit3│
      └─────┘  └─────┘  └─────┘         └─────┘       └─────┘  └─────┘  └─────┘
```

---

## 📁 Kompletna Struktura Projekta

```
vesta-lumina-admin-panel/
│
├── 📄 .firebaserc                           # Firebase project config
├── 📄 .gitattributes                        # Git attributes
├── 📄 .gitignore                            # Git ignore rules
├── 📄 LICENSE                               # Proprietary license
├── 📄 README.md                             # Ovaj dokument
├── 📄 analysis_options.yaml                 # Dart linter config
├── 📄 devtools_options.yaml                 # DevTools config
├── 📄 firebase.json                         # Firebase deploy config
├── 📄 firestore.indexes.json                # Firestore composite indexes (11)
├── 📄 firestore.rules                       # Firestore security rules (235 lines)
├── 📄 pubspec.lock                          # Locked dependencies
├── 📄 pubspec.yaml                          # Flutter dependencies
├── 📄 storage.rules                         # Storage security rules (93 lines)
│
├── 📂 assets/
│   └── 📂 icon/
│       └── 📄 icon.png                      # App icon
│
├── 📂 docs/
│   ├── 📄 API_DOCUMENTATION.md              # API reference
│   ├── 📄 CHANGELOG.md                      # Version history
│   ├── 📄 FIREBASE_DOCUMENTATION.md         # Firebase setup guide
│   └── 📄 PROJECT_ANALYSIS.md               # Project analysis
│
├── 📂 functions/                            # Cloud Functions (1,507 lines)
│   ├── 📄 .gitignore                        # Functions gitignore
│   ├── 📄 api_versioning.js                 # API v1/v2 routing (242 lines)
│   ├── 📄 index.js                          # 20 Cloud Functions (1,265 lines)
│   ├── 📄 package-lock.json                 # Locked dependencies
│   └── 📄 package.json                      # Node.js dependencies
│
├── 📂 lib/                                  # Flutter source (27,352 lines)
│   │
│   ├── 📄 firebase_options.dart             # Firebase config (25 lines)
│   ├── 📄 main.dart                         # App entry point (716 lines)
│   │
│   ├── 📂 config/                           # Configuration (2,418 lines)
│   │   ├── 📄 app_config.dart               # App constants (181 lines)
│   │   ├── 📄 theme.dart                    # Theme definitions (143 lines)
│   │   └── 📄 translations.dart             # 11 languages, 178 keys (2,094 lines)
│   │
│   ├── 📂 models/                           # Data models (618 lines)
│   │   ├── 📄 booking_model.dart            # Booking model (112 lines)
│   │   ├── 📄 cleaning_log_model.dart       # Cleaning log model (87 lines)
│   │   ├── 📄 settings_model.dart           # Settings model (314 lines)
│   │   └── 📄 unit_model.dart               # Unit model (105 lines)
│   │
│   ├── 📂 providers/                        # State management (126 lines)
│   │   └── 📄 app_provider.dart             # Main provider (126 lines)
│   │
│   ├── 📂 repositories/                     # Data access layer (993 lines)
│   │   ├── 📄 base_repository.dart          # Base repository (315 lines)
│   │   ├── 📄 booking_repository.dart       # Booking repository (484 lines)
│   │   └── 📄 units_repository.dart         # Units repository (194 lines)
│   │
│   ├── 📂 screens/                          # UI screens (12,390 lines)
│   │   │
│   │   ├── 📂 analytics/                    # Analytics submodule (1,113 lines)
│   │   │   ├── 📄 analytics_screen.dart     # Analytics main (490 lines)
│   │   │   └── 📄 revenue_screen.dart       # Revenue details (623 lines)
│   │   │
│   │   ├── 📄 analytics_screen.dart         # Analytics overview (983 lines)
│   │   ├── 📄 booking_screen.dart           # Booking calendar (1,344 lines)
│   │   ├── 📄 dashboard_screen.dart         # Main dashboard (1,288 lines)
│   │   ├── 📄 digital_book_screen.dart      # Digital guest book (1,783 lines)
│   │   ├── 📄 gallery_screen.dart           # Image gallery (885 lines)
│   │   ├── 📄 login_screen.dart             # Login screen (181 lines)
│   │   ├── 📄 settings_screen.dart          # Settings (1,395 lines)
│   │   ├── 📄 super_admin_notifications.dart # System notifications (961 lines)
│   │   ├── 📄 super_admin_screen.dart       # Owner management (1,017 lines)
│   │   ├── 📄 super_admin_tablets.dart      # Tablet management (1,037 lines)
│   │   └── 📄 tenant_setup_screen.dart      # Onboarding wizard (403 lines)
│   │
│   ├── 📂 services/                         # Business logic (5,671 lines)
│   │   ├── 📄 analytics_service.dart        # Analytics service (488 lines)
│   │   ├── 📄 app_check_service.dart        # App Check stub (55 lines)
│   │   ├── 📄 auth_service.dart             # Authentication (479 lines)
│   │   ├── 📄 booking_service.dart          # Booking CRUD (345 lines)
│   │   ├── 📄 cache_service.dart            # Offline cache (413 lines)
│   │   ├── 📄 calendar_service.dart         # iCal export (364 lines)
│   │   ├── 📄 cleaning_service.dart         # Cleaning workflow (66 lines)
│   │   ├── 📄 connectivity_service.dart     # Network status (197 lines)
│   │   ├── 📄 error_service.dart            # Error handling (258 lines)
│   │   ├── 📄 health_service.dart           # System health (430 lines)
│   │   ├── 📄 offline_queue_service.dart    # Offline sync queue (375 lines)
│   │   ├── 📄 onboarding_service.dart       # User onboarding (363 lines)
│   │   ├── 📄 pdf_service.dart              # PDF generation (966 lines)
│   │   ├── 📄 performance_service.dart      # Performance metrics (318 lines)
│   │   ├── 📄 revenue_service.dart          # Revenue analytics (566 lines)
│   │   ├── 📄 security_service.dart         # Security utilities (285 lines)
│   │   ├── 📄 settings_service.dart         # Settings CRUD (67 lines)
│   │   ├── 📄 super_admin_service.dart      # Admin operations (333 lines)
│   │   └── 📄 units_service.dart            # Units CRUD (303 lines)
│   │
│   ├── 📂 utils/                            # Utilities (640 lines)
│   │   └── 📄 performance_utils.dart        # Debouncer, Throttler, RetryHelper, Memoizer, BatchProcessor (640 lines)
│   │
│   └── 📂 widgets/                          # Reusable components (3,755 lines)
│       │
│       ├── 📂 analytics/                    # Analytics widgets (687 lines)
│       │   ├── 📄 booking_chart.dart        # Booking chart (134 lines)
│       │   ├── 📄 occupancy_chart.dart      # Occupancy chart (211 lines)
│       │   ├── 📄 stat_card.dart            # Statistics card (118 lines)
│       │   └── 📄 upcoming_bookings_card.dart # Upcoming bookings (224 lines)
│       │
│       ├── 📄 booking_calendar.dart         # Drag & Drop calendar (1,355 lines)
│       ├── 📄 system_notification_banner.dart # System notifications (287 lines)
│       └── 📄 unit_widgets.dart             # Unit components (1,426 lines)
│
├── 📂 test/                                 # Test suite (3,908 lines)
│   │
│   ├── 📄 all_tests.dart                    # Test runner (51 lines)
│   ├── 📄 services_test.dart                # Legacy service tests (163 lines)
│   ├── 📄 widget_test.dart                  # Legacy widget tests (235 lines)
│   │
│   ├── 📂 config/
│   │   └── 📄 app_config_test.dart          # Config tests (162 lines)
│   │
│   ├── 📂 helpers/
│   │   └── 📄 test_helpers.dart             # Test utilities (291 lines)
│   │
│   ├── 📂 integration/
│   │   └── 📄 auth_flow_test.dart           # Auth integration tests (323 lines)
│   │
│   ├── 📂 models/
│   │   ├── 📄 booking_model_test.dart       # Booking model tests (401 lines)
│   │   └── 📄 unit_model_test.dart          # Unit model tests (383 lines)
│   │
│   ├── 📂 repositories/
│   │   └── 📄 booking_repository_test.dart  # Repository tests (214 lines)
│   │
│   ├── 📂 services/
│   │   ├── 📄 auth_service_test.dart        # Auth service tests (291 lines)
│   │   ├── 📄 cache_service_test.dart       # Cache service tests (337 lines)
│   │   ├── 📄 revenue_service_test.dart     # Revenue service tests (421 lines)
│   │   └── 📄 security_service_test.dart    # Security service tests (183 lines)
│   │
│   └── 📂 widgets/
│       └── 📄 login_screen_test.dart        # Login widget tests (453 lines)
│
└── 📂 web/                                  # Web specific files
    ├── 📄 favicon.png                       # Browser favicon
    ├── 📄 index.html                        # HTML entry point
    ├── 📄 manifest.json                     # PWA manifest
    └── 📂 icons/
        ├── 📄 Icon-192.png                  # PWA icon 192x192
        ├── 📄 Icon-512.png                  # PWA icon 512x512
        ├── 📄 Icon-maskable-192.png         # Maskable icon 192x192
        └── 📄 Icon-maskable-512.png         # Maskable icon 512x512
```

---

## ⚡ Funkcionalnosti

### 📅 Booking Management
- Drag & Drop kalendar s vizualnim pregledom
- Status praćenje (confirmed, pending, cancelled, private, blocked)
- Zone grupiranje jedinica
- iCal Export/Import
- Overlap detection
- Booking history s filterima

### 🏠 Unit Management
- Multi-tenant arhitektura s potpunom izolacijom
- WiFi/PIN konfiguracija
- QR kod generiranje
- Zone assignment
- Category grouping

### 📊 Analytics & Revenue
- Revenue tracking po periodu
- Occupancy rate kalkulacija
- Guest insights
- AI Questions logging
- Export u CSV/PDF

### 📄 PDF Generation (10 tipova)

| # | Tip | Opis |
|---|-----|------|
| 1 | eVisitor Data | Skenirani podaci gostiju za eVisitor prijavu |
| 2 | House Rules | Kućna pravila s potpisom gosta |
| 3 | Cleaning Log | Dnevnik čišćenja s checklistom |
| 4 | Unit Schedule | Raspored jedinice (30 dana) |
| 5 | Text List Full | Tekstualna lista rezervacija (puni podaci) |
| 6 | Text List Anonymous | Tekstualna lista rezervacija (anonimizirano) |
| 7 | Cleaning Schedule | Raspored čišćenja za sve jedinice |
| 8 | Graphic Full | Grafički prikaz kalendara (puni podaci) |
| 9 | Graphic Anonymous | Grafički prikaz kalendara (anonimizirano) |
| 10 | Booking History | Kompletna povijest rezervacija |

### 🧹 Cleaning Workflow
- Task management s checklistama
- PIN autentikacija za čistače
- Status workflow (pending → in_progress → completed)
- Photo upload za dokaz čišćenja

### 👨‍💼 Super Admin Panel
- Owner CRUD operacije
- Tablet deployment management
- System notifications (broadcast)
- Audit logging (admin_logs)
- APK update distribution
- Manual/Scheduled backups

### 📱 Digital Guest Book
- Welcome message (multi-language)
- House rules (multi-language)
- Emergency contacts
- Tablet display timers
- AI Knowledge base za concierge

---

## ⚡ Cloud Functions API

### 20 Serverless Funkcija

| # | Kategorija | Funkcija | Opis |
|---|------------|----------|------|
| 1 | Owner | `createOwner` | Kreiranje novog vlasnika |
| 2 | Owner | `linkTenantId` | Povezivanje tenant ID-a |
| 3 | Owner | `listOwners` | Lista svih vlasnika |
| 4 | Owner | `deleteOwner` | Brisanje vlasnika |
| 5 | Owner | `resetOwnerPassword` | Reset lozinke |
| 6 | Owner | `toggleOwnerStatus` | Aktivacija/deaktivacija |
| 7 | Translation | `translateHouseRules` | AI prijevod kućnih pravila |
| 8 | Translation | `translateNotification` | AI prijevod notifikacija |
| 9 | Tablet | `registerTablet` | Registracija tablet uređaja |
| 10 | Tablet | `tabletHeartbeat` | Health check tableta |
| 11 | Super Admin | `addSuperAdmin` | Dodavanje super admina |
| 12 | Super Admin | `removeSuperAdmin` | Uklanjanje super admina |
| 13 | Super Admin | `listSuperAdmins` | Lista super admina |
| 14 | Super Admin | `getAdminLogs` | Dohvat audit logova |
| 15 | Backup | `scheduledBackup` | Automatski dnevni backup (3 AM) |
| 16 | Backup | `manualBackup` | Ručni backup na zahtjev |
| 17 | Email | `sendEmailNotification` | Slanje email notifikacija |
| 18 | Email | `onBookingCreated` | Trigger na novu rezervaciju |
| 19 | Email | `sendCheckInReminders` | Automatski check-in podsjetnici |
| 20 | Email | `updateEmailSettings` | Ažuriranje email postavki |

**API Base URL:** `https://europe-west3-vls-admin.cloudfunctions.net/`

---

## 🔐 Sigurnosni Model

### Authentication Flow

```
User Login → Firebase Auth → JWT Token with Custom Claims
                                    │
                                    ▼
                            ┌───────────────┐
                            │ Custom Claims │
                            ├───────────────┤
                            │ ownerId       │ ← Tenant isolation
                            │ role          │ ← owner/superadmin
                            │ email         │
                            └───────────────┘
                                    │
                                    ▼
                    Firestore Rules + Cloud Functions Validation
```

### Role-Based Access Control

| Rola | Pristup | Autentikacija |
|------|---------|---------------|
| **Super Admin** | Sve funkcije, svi tenanti | Email/Password + superadmin claim |
| **Owner** | Samo vlastiti podaci | Email/Password + ownerId claim |
| **Cleaner** | Cleaning workflow | PIN autentikacija |
| **Guest** | Client Terminal (read-only) | Booking reference |

### Security Features

| Feature | Status | Opis |
|---------|--------|------|
| JWT Authentication | ✅ | Firebase Auth + Custom Claims |
| Tenant Isolation | ✅ | ownerId claim u svakom requestu |
| Firestore Rules | ✅ | 235 linija sigurnosnih pravila |
| Storage Rules | ✅ | 93 linija, size/type validation |
| Rate Limiting | ✅ | Cloud Functions throttling |
| Input Validation | ✅ | Server-side validation |
| Audit Logging | ✅ | admin_logs kolekcija |
| Composite Indexes | ✅ | 11 optimiziranih indeksa |

---

## 🌍 Lokalizacija

### Podržani jezici (11)

| # | Kod | Jezik | Status |
|---|-----|-------|--------|
| 1 | 🇬🇧 EN | English | ✅ Master |
| 2 | 🇭🇷 HR | Hrvatski | ✅ Kompletno |
| 3 | 🇩🇪 DE | Deutsch | ✅ Kompletno |
| 4 | 🇮🇹 IT | Italiano | ✅ Kompletno |
| 5 | 🇪🇸 ES | Español | ✅ Kompletno |
| 6 | 🇫🇷 FR | Français | ✅ Kompletno |
| 7 | 🇵🇱 PL | Polski | ✅ Kompletno |
| 8 | 🇸🇰 SK | Slovenčina | ✅ Kompletno |
| 9 | 🇨🇿 CS | Čeština | ✅ Kompletno |
| 10 | 🇭🇺 HU | Magyar | ✅ Kompletno |
| 11 | 🇸🇮 SL | Slovenščina | ✅ Kompletno |

**178 translation keys × 11 languages = 1,958 translations**

---

## 🎨 Teme i Personalizacija

### Primarne Boje (10)

| # | Naziv | Hex | Tip |
|---|-------|-----|-----|
| 1 | Gold | #D4AF37 | Luxury |
| 2 | Bronze | #CD7F32 | Luxury |
| 3 | Royal Blue | #1B4F72 | Luxury |
| 4 | Burgundy | #800020 | Luxury |
| 5 | Emerald | #2E8B57 | Luxury |
| 6 | Slate | #708090 | Luxury |
| 7 | Neon Green | #39FF14 | Neon |
| 8 | Cyan | #00FFFF | Neon |
| 9 | Hot Pink | #FF69B4 | Neon |
| 10 | Electric Orange | #FF4500 | Neon |

### Pozadinski Tonovi (6)

| # | Naziv | Hex | Tip |
|---|-------|-----|-----|
| 1 | dark1 | #000000 | Dark (Pure Black - OLED) |
| 2 | dark2 | #121212 | Dark (Material Dark) |
| 3 | dark3 | #1E1E1E | Dark (Soft Dark) |
| 4 | light1 | #E0E0E0 | Light (Soft Grey) |
| 5 | light2 | #F5F5F5 | Light (Off White) |
| 6 | light3 | #FFFFFF | Light (Pure White) |

---

## 📌 Verzije

### Trenutna verzija: 0.0.9 (Siječanj 2026)

```
v0.0.9 - Beta Release (Siječanj 2026)
═══════════════════════════════════════════════════════════════
✅ Enterprise Auth Service (479 linija)
✅ Comprehensive Test Suite (138 testova, 3,908 linija)
✅ Fixed tenant activation flow
✅ Fixed translations bug (argument order)
✅ Added missing Firestore indexes (11 total)
✅ Performance utilities (Debouncer, Throttler, RetryHelper)
✅ Complete documentation update

v0.0.8 - Enterprise Hardening
═══════════════════════════════════════════════════════════════
✅ Offline Queue Service + Auto-Sync
✅ Performance Monitoring
✅ API Versioning (v1/v2)
✅ Health Dashboard Service

v0.0.7 - Advanced Features
═══════════════════════════════════════════════════════════════
✅ Revenue Analytics Dashboard
✅ iCal Calendar Export
✅ Email Notifications System
✅ 11-language Support (178 keys)

v0.0.1 - Core System
═══════════════════════════════════════════════════════════════
✅ Multi-tenant Architecture
✅ Booking Calendar (Drag & Drop)
✅ PDF Generation (10 types)
✅ Guest Check-in Workflow
✅ Super Admin Panel
```

---

## 📜 Licenca

Ovaj softver je zaštićen **vlasničkom licencom**. Pogledajte [LICENSE](LICENSE) datoteku za potpune uvjete.

```
© 2025-2026 Sva prava pridržana.
Neovlašteno kopiranje ili korištenje je strogo zabranjeno.
```

---

## 📧 Kontakt

Za upite o licenciranju ili poslovnu suradnju:

- **GitHub:** [@nroxa92](https://github.com/nroxa92)
- **Email:** nevenroksa@gmail.com

---

<div align="center">

**Vesta Lumina Admin Panel** | Part of **Vesta Lumina System**

*Enterprise Property Management*

*Built with Flutter & Firebase*

v0.0.9 Beta

</div>
