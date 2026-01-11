# Vesta Lumina - Admin Panel

[![Version](https://img.shields.io/badge/version-2.1.0-blue.svg)](https://github.com/nroxa92/admin_panel)
[![Platform](https://img.shields.io/badge/platform-Web-orange.svg)](https://flutter.dev/web)
[![Flutter](https://img.shields.io/badge/Flutter-3.32+-02569B.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-Proprietary-red.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/tests-138%20passing-brightgreen.svg)](tests/)

> **Enterprise Property Management System for Short-Term Rental Owners**

---

## ⚠️ PROPRIETARY LICENSE - STRICTLY ENFORCED

```
Copyright © 2024-2026 Neven Roksa. All Rights Reserved.

This repository is PUBLIC FOR PORTFOLIO DEMONSTRATION ONLY.

STRICTLY PROHIBITED:
• Copying, cloning, forking, or downloading this code
• Reverse engineering or decompiling
• Commercial use of any kind
• Use for AI/ML model training
• Any unauthorized distribution

LEGAL CONSEQUENCES:
• DMCA takedown notices
• Cease and desist orders  
• Civil litigation for damages
• Criminal prosecution where applicable

Contact: nevenroksa@gmail.com | GitHub: @nroxa92
```

---

## Sažetak

Admin Panel je web aplikacija za upravljanje kratkoročnim iznajmljivanjem nekretnina. Omogućuje vlasnicima smještaja upravljanje rezervacijama, gostima, kućnim redom, čišćenjem i tablet terminalima. Sustav podržava multi-tenant arhitekturu s različitim razinama pristupa (Super Admin, Brand Admin, Vlasnik, Čistač).

## Pregled Sustava

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        VESTA LUMINA ADMIN PANEL                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                         FRONTEND (Flutter Web)                      │ │
│  │                                                                     │ │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  │ │
│  │  │Dashboard│  │Bookings │  │  Units  │  │Cleaning │  │Settings │  │ │
│  │  │         │  │Calendar │  │ Manager │  │  Logs   │  │& Config │  │ │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘  └─────────┘  │ │
│  │                                                                     │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                   │                                      │
│                                   ▼                                      │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                         FIREBASE BACKEND                            │ │
│  │                                                                     │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │ │
│  │  │Firestore │  │  Auth    │  │ Storage  │  │ Cloud Functions  │   │ │
│  │  │(Database)│  │(Identity)│  │ (Files)  │  │ (Server Logic)   │   │ │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────────────┘   │ │
│  │                                                                     │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Multi-Tenant Arhitektura

| Razina | Uloga | Pristup |
|--------|-------|---------|
| **Super Admin** | Sistemski administrator | Svi vlasnici, sva podešavanja, statistike platforme |
| **Brand Admin** | Partner administrator | Vlastiti brendirani vlasnici, ograničena podešavanja |
| **Owner** | Vlasnik smještaja | Vlastite jedinice, rezervacije, gosti, čišćenje |
| **Cleaner** | Čistač | PIN pristup, check-liste čišćenja, prijavljivanje problema |

## Upute za Korištenje

### Za Vlasnike Smještaja

1. **Prijava u Sustav**
   - Otvorite web aplikaciju na https://app.vestalumina.com
   - Prijavite se s email adresom i lozinkom
   - Dvostruka autentifikacija (2FA) je opcijska ali preporučena

2. **Dodavanje Smještajnih Jedinica**
   - Idite na "Jedinice" → "Nova Jedinica"
   - Unesite naziv, adresu, kapacitet
   - Postavite WiFi podatke i pristupni kod tableta

3. **Upravljanje Rezervacijama**
   - Koristite drag-and-drop kalendar za unos rezervacija
   - Povežite s booking platformama (Airbnb, Booking.com) putem iCal
   - Pregledavajte status check-in-a u realnom vremenu

4. **Konfiguracija Kućnog Reda**
   - Definirajte pravila za svaku jedinicu
   - Dodajte prijevode na podržane jezike
   - Postavite obavezne stavke koje gost mora prihvatiti

5. **AI Asistent**
   - Dodajte pitanja i odgovore u bazu znanja
   - Konfigurirajte ton i stil komunikacije
   - Pregledavajte transkripte razgovora gostiju

### Za Super Admine

1. **Upravljanje Vlasnicima**
   - Kreirajte nove vlasnike i dodijelite im pristup
   - Postavite limite (broj jedinica, funkcionalnosti)
   - Blokirajte/deblokirajte pristup

2. **Brendiranje**
   - Konfigurirajte white-label partnere
   - Prilagodite logo, boje, domenu
   - Upravljajte pretplatama i licencama

---

## Technical Documentation

### Project Statistics

| Metric | Value |
|--------|-------|
| **Total Code** | 32,767+ lines |
| **Dart Code** | 27,352 lines |
| **JavaScript (Functions)** | 1,507 lines |
| **Test Code** | 3,908 lines |
| **Total Files** | 75+ |
| **Screens** | 25+ |
| **Cloud Functions** | 24 |
| **Tests** | 138 |
| **Localization Keys** | 178 × 11 languages |

### Project Structure

```
admin_panel/
├── lib/
│   ├── main.dart                    # Application entry point
│   ├── firebase_options.dart        # Firebase configuration
│   ├── app/
│   │   ├── app.dart                 # Root widget
│   │   ├── router.dart              # Navigation configuration
│   │   └── theme/                   # Theme definitions
│   │       ├── app_theme.dart
│   │       ├── colors.dart
│   │       └── typography.dart
│   ├── features/
│   │   ├── auth/                    # Authentication
│   │   │   ├── screens/
│   │   │   ├── services/
│   │   │   └── widgets/
│   │   ├── dashboard/               # Main dashboard
│   │   │   ├── screens/
│   │   │   ├── widgets/
│   │   │   └── controllers/
│   │   ├── bookings/                # Booking management
│   │   │   ├── screens/
│   │   │   │   ├── bookings_screen.dart
│   │   │   │   ├── booking_detail_screen.dart
│   │   │   │   └── calendar_screen.dart
│   │   │   ├── services/
│   │   │   ├── models/
│   │   │   └── widgets/
│   │   ├── units/                   # Property units
│   │   │   ├── screens/
│   │   │   ├── services/
│   │   │   └── models/
│   │   ├── guests/                  # Guest management
│   │   │   ├── screens/
│   │   │   ├── services/
│   │   │   └── models/
│   │   ├── cleaning/                # Cleaning management
│   │   │   ├── screens/
│   │   │   ├── services/
│   │   │   └── models/
│   │   ├── house_rules/             # House rules editor
│   │   │   ├── screens/
│   │   │   ├── services/
│   │   │   └── models/
│   │   ├── ai_assistant/            # AI configuration
│   │   │   ├── screens/
│   │   │   ├── services/
│   │   │   └── models/
│   │   ├── settings/                # Settings & config
│   │   │   ├── screens/
│   │   │   └── widgets/
│   │   ├── reports/                 # Analytics & reports
│   │   │   ├── screens/
│   │   │   ├── services/
│   │   │   └── widgets/
│   │   └── super_admin/             # Super admin features
│   │       ├── screens/
│   │       ├── services/
│   │       └── widgets/
│   ├── shared/
│   │   ├── models/                  # Shared data models
│   │   ├── services/                # Shared services
│   │   ├── widgets/                 # Reusable widgets
│   │   ├── utils/                   # Utilities
│   │   └── constants/               # Constants
│   └── l10n/                        # Localization (11 languages)
│       ├── app_en.arb
│       ├── app_hr.arb
│       └── ... (9 more)
├── functions/                       # Firebase Cloud Functions
│   ├── src/
│   │   ├── index.ts                 # Function exports
│   │   ├── auth/                    # Auth triggers
│   │   ├── bookings/                # Booking functions
│   │   ├── notifications/           # Push notifications
│   │   ├── pdf/                     # PDF generation
│   │   ├── integrations/            # External APIs
│   │   └── scheduled/               # Cron jobs
│   ├── package.json
│   └── tsconfig.json
├── test/                            # Test suite (138 tests)
│   ├── services/
│   ├── models/
│   ├── repositories/
│   └── widgets/
├── web/                             # Web-specific assets
├── firebase.json                    # Firebase configuration
├── firestore.rules                  # Security rules (235 lines)
├── storage.rules                    # Storage security (93 lines)
└── pubspec.yaml                     # Dependencies
```

### Cloud Functions API Reference

| Function | Trigger | Description |
|----------|---------|-------------|
| `onUserCreate` | Auth onCreate | Initialize new owner document |
| `onUserDelete` | Auth onDelete | Cleanup owner data |
| `onBookingCreate` | Firestore onCreate | Send confirmation notification |
| `onBookingUpdate` | Firestore onUpdate | Handle status changes |
| `onBookingDelete` | Firestore onDelete | Cleanup related data |
| `onGuestCheckin` | Firestore onUpdate | Generate eVisitor report |
| `onCleaningComplete` | Firestore onCreate | Notify owner |
| `generatePDF` | HTTP callable | Generate various PDF documents |
| `syncIcal` | HTTP callable | Import iCal bookings |
| `processOCR` | HTTP callable | Process scanned documents |
| `sendPushNotification` | HTTP callable | Send FCM notification |
| `generateReport` | HTTP callable | Generate analytics report |
| `exportGuestData` | HTTP callable | GDPR data export |
| `deleteGuestData` | HTTP callable | GDPR data deletion |
| `dailyCleanup` | Scheduled (daily) | Auto-delete expired data |
| `weeklyReport` | Scheduled (weekly) | Send weekly summary |
| `monthlyBilling` | Scheduled (monthly) | Process subscriptions |
| `icalSync` | Scheduled (hourly) | Auto-sync calendars |
| `backupFirestore` | Scheduled (daily) | Database backup |
| `cleanupStorage` | Scheduled (weekly) | Remove orphaned files |
| `validateBookings` | HTTP callable | Check booking conflicts |
| `generateAccessCode` | HTTP callable | Create tablet pairing code |
| `revokeAccess` | HTTP callable | Revoke tablet access |
| `chatbotWebhook` | HTTP endpoint | AI chatbot integration |

### Firestore Collections

```
firestore/
├── owners/                          # Owner accounts
│   └── {ownerId}/
│       ├── settings                 # Owner settings document
│       ├── units/                   # Property units collection
│       │   └── {unitId}/
│       │       ├── bookings/        # Bookings subcollection
│       │       │   └── {bookingId}/
│       │       │       └── guests[] # Guest array (not subcollection)
│       │       ├── house_rules      # Rules document
│       │       ├── ai_knowledge     # AI knowledge base
│       │       ├── screensaver      # Screensaver config
│       │       └── wifi             # WiFi credentials
│       ├── cleaning_logs/           # Cleaning records
│       ├── terminals/               # Paired tablets
│       ├── notifications/           # Push notifications
│       └── reports/                 # Generated reports
├── super_admin/                     # Platform administration
│   ├── config                       # Global configuration
│   ├── brands/                      # White-label brands
│   └── statistics                   # Platform statistics
├── subscriptions/                   # Billing records
└── audit_log/                       # Security audit trail
```

### PDF Document Types

| Document | Description | Languages |
|----------|-------------|-----------|
| **Booking Confirmation** | Reservation details for guest | 11 |
| **House Rules** | Property rules document | 11 |
| **Guest Registration** | eVisitor report format | 11 |
| **Cleaning Checklist** | Cleaner task list | 11 |
| **Invoice** | Payment invoice | 11 |
| **Receipt** | Payment receipt | 11 |
| **Key Handover** | Key collection form | 11 |
| **Damage Report** | Property damage documentation | 11 |
| **Monthly Report** | Owner analytics summary | 11 |
| **GDPR Export** | Guest data export | 11 |

### Theme System

| Theme | Description |
|-------|-------------|
| Ocean Blue | Default blue theme |
| Forest Green | Nature-inspired green |
| Sunset Orange | Warm orange tones |
| Midnight Purple | Dark purple theme |
| Ruby Red | Bold red theme |
| Golden Yellow | Bright yellow theme |
| Teal Breeze | Fresh teal colors |
| Rose Pink | Soft pink theme |
| Slate Gray | Professional gray |
| Custom | User-defined colors |

**Background Tones:** Light, Dark, System (auto), High Contrast, Sepia, Blue Light Filter

### Technology Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.32+ (Web) |
| **Language** | Dart 3.5+ |
| **Backend** | Firebase Suite |
| **Functions** | Node.js 18 + TypeScript |
| **PDF** | pdf package + printing |
| **Charts** | fl_chart |
| **Calendar** | table_calendar (drag-drop) |
| **State** | Riverpod 2.0 |
| **Routing** | go_router |
| **Testing** | flutter_test, mockito |

### Test Suite

| Category | Tests | Coverage |
|----------|-------|----------|
| **Services** | 45 | Core business logic |
| **Models** | 32 | Data serialization |
| **Repositories** | 28 | Data access layer |
| **Widgets** | 33 | UI components |
| **Total** | **138** | **3,908 lines** |

### Security Implementation

#### Firestore Rules (235 lines)
```javascript
// Example rule structure
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Owner isolation
    match /owners/{ownerId}/{document=**} {
      allow read, write: if request.auth != null 
        && request.auth.token.ownerId == ownerId;
    }
    
    // Super admin access
    match /{document=**} {
      allow read, write: if request.auth.token.role == 'super_admin';
    }
  }
}
```

#### Authentication Levels
| Level | Method | Access |
|-------|--------|--------|
| 3 | Email + 2FA | Super Admin |
| 2 | Email + Password | Brand Admin / Owner |
| 1 | PIN Code | Cleaner |
| 0 | Booking Reference | Guest (tablet only) |

### GDPR Compliance

| Feature | Implementation |
|---------|----------------|
| **Data Minimization** | Collect only necessary guest data |
| **Right to Access** | One-click data export (PDF) |
| **Right to Erasure** | Auto-delete after checkout + manual |
| **Data Portability** | JSON/CSV export available |
| **Consent Management** | Digital signature on house rules |
| **Audit Trail** | Full activity logging |
| **Data Location** | europe-west3 (Frankfurt) |

### Localization

| Language | Code | Keys | Status |
|----------|------|------|--------|
| English | `en` | 178 | ✅ Complete |
| Croatian | `hr` | 178 | ✅ Complete |
| German | `de` | 178 | ✅ Complete |
| Italian | `it` | 178 | ✅ Complete |
| Slovenian | `sl` | 178 | ✅ Complete |
| French | `fr` | 178 | ✅ Complete |
| Spanish | `es` | 178 | ✅ Complete |
| Portuguese | `pt` | 178 | ✅ Complete |
| Dutch | `nl` | 178 | ✅ Complete |
| Polish | `pl` | 178 | ✅ Complete |
| Czech | `cs` | 178 | ✅ Complete |

**Total Translations:** 178 keys × 11 languages = **1,958 translations**

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.1.0 | 2026-01 | Enhanced analytics, new PDF types |
| 2.0.0 | 2025-11 | Super admin panel, white-label support |
| 1.8.0 | 2025-09 | Drag-drop calendar, iCal sync |
| 1.5.0 | 2025-07 | AI assistant configuration |
| 1.0.0 | 2025-05 | Initial release |

---

## Related Components

| Component | Repository | Description |
|-----------|------------|-------------|
| **Tablet Terminal** | [tablet_terminal](https://github.com/nroxa92/tablet_terminal) | Guest self-service kiosk |
| **Documentation** | This README | Technical documentation |

---

## Contact

**Developer:** Neven Roksa  
**Email:** nevenroksa@gmail.com  
**GitHub:** [@nroxa92](https://github.com/nroxa92)

---

<p align="center">
  <strong>Vesta Lumina System</strong><br>
  <em>Enterprise Property Management Platform</em><br><br>
  © 2024-2026 Neven Roksa. All Rights Reserved.
</p>
