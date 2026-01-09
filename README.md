# 🏨 VillaOS Admin Panel

## ⚠️ PRAVNA NAPOMENA

```
═══════════════════════════════════════════════════════════════════════════════
                         VLASNIŠTVO I AUTORSKA PRAVA
═══════════════════════════════════════════════════════════════════════════════

Ovaj softver je PRIVATNO VLASNIŠTVO i zaštićen je zakonima o autorskim pravima.

🔒 STROGO ZABRANJENO:
   • Kopiranje, reprodukcija ili distribucija koda
   • Dekompilacija ili obrnuti inženjering
   • Korištenje u komercijalne svrhe bez pisane dozvole
   • Dijeljenje pristupnih podataka ili API ključeva

⚖️ PRAVNE POSLJEDICE:
   Neovlašteno kopiranje ili korištenje ovog softvera podliježe:
   • Građanskoj odgovornosti za naknadu štete
   • Kaznenom progonu prema Zakonu o autorskom pravu
   • Odgovornosti za povredu poslovne tajne

📧 Kontakt za licenciranje: [PRIVATNO]

© 2024-2025 Sva prava pridržana.
═══════════════════════════════════════════════════════════════════════════════
```

---

## 📋 Sadržaj

1. [Pregled Projekta](#-pregled-projekta)
2. [Tehnička Arhitektura](#-tehnička-arhitektura)
3. [Struktura Direktorija](#-struktura-direktorija)
4. [Frontend - Flutter Web](#-frontend---flutter-web)
5. [Backend - Firebase](#-backend---firebase)
6. [Cloud Functions](#-cloud-functions)
7. [Sigurnosni Model](#-sigurnosni-model)
8. [Statistika Koda](#-statistika-koda)
9. [Verzije i Changelog](#-verzije-i-changelog)

---

## 🎯 Pregled Projekta

**VillaOS** (Vesta Lumina System) je enterprise-grade sustav za upravljanje smještajnim objektima (vila, apartmana, soba) koji se sastoji od:

| Komponenta | Opis | Status |
|------------|------|--------|
| **Web Admin Panel** | Flutter Web aplikacija za vlasnike | ✅ Production |
| **Firebase Backend** | Firestore, Auth, Storage, Functions | ✅ Production |
| **Cloud Functions** | 20 serverless funkcija | ✅ Production |
| **Android Tablet App** | Kiosk aplikacija za goste | 🔄 Separate Repo |

### Ključne Funkcionalnosti

```
┌─────────────────────────────────────────────────────────────────────┐
│                        VillaOS FUNKCIONALNOSTI                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  📅 REZERVACIJE          │  🏠 UPRAVLJANJE JEDINICAMA                │
│  • Drag & Drop kalendar  │  • Multi-tenant arhitektura              │
│  • Vizualni pregled      │  • Zone i grupiranje                     │
│  • Status praćenje       │  • WiFi/PIN upravljanje                  │
│  • iCal Export           │  • QR kodovi                             │
│                          │                                          │
│  📊 ANALITIKA            │  📄 PDF GENERIRANJE                      │
│  • Revenue tracking      │  • 10 tipova dokumenata                  │
│  • Occupancy rate        │  • eVisitor podaci                       │
│  • Guest insights        │  • Kućna pravila                         │
│  • AI pitanja log        │  • Cleaning logovi                       │
│                          │                                          │
│  🧹 ČIŠĆENJE             │  🌍 LOKALIZACIJA                         │
│  • Task management       │  • 11 jezika                             │
│  • Status workflow       │  • 150+ ključeva po jeziku               │
│  • PIN autentikacija     │  • Auto-translate (AI)                   │
│                          │                                          │
│  🔐 SIGURNOST            │  👨‍💼 SUPER ADMIN                          │
│  • JWT autentikacija     │  • Owner management                      │
│  • Role-based access     │  • Tablet deployment                     │
│  • Firestore rules       │  • System notifications                  │
│  • Rate limiting         │  • Audit logging                         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🏗️ Tehnička Arhitektura

### Stack

```
┌────────────────────────────────────────────────────────────────────┐
│                           FRONTEND                                  │
│  Flutter 3.32+ │ Dart │ Material Design │ Provider State Mgmt      │
├────────────────────────────────────────────────────────────────────┤
│                           BACKEND                                   │
│  Firebase Auth │ Cloud Firestore │ Cloud Storage │ Cloud Functions │
├────────────────────────────────────────────────────────────────────┤
│                         INFRASTRUCTURE                              │
│  Firebase Hosting │ Node.js 20 │ Google Cloud Platform              │
└────────────────────────────────────────────────────────────────────┘
```

### Arhitekturni Dijagram

```
                                    ┌─────────────────┐
                                    │   Super Admin   │
                                    │  master@admin   │
                                    └────────┬────────┘
                                             │
                    ┌────────────────────────┼────────────────────────┐
                    │                        │                        │
                    ▼                        ▼                        ▼
           ┌───────────────┐        ┌───────────────┐        ┌───────────────┐
           │   Owner A     │        │   Owner B     │        │   Owner C     │
           │  (Tenant 1)   │        │  (Tenant 2)   │        │  (Tenant 3)   │
           └───────┬───────┘        └───────┬───────┘        └───────┬───────┘
                   │                        │                        │
         ┌─────────┼─────────┐              │              ┌─────────┼─────────┐
         │         │         │              │              │         │         │
         ▼         ▼         ▼              ▼              ▼         ▼         ▼
      ┌─────┐  ┌─────┐  ┌─────┐         ┌─────┐       ┌─────┐  ┌─────┐  ┌─────┐
      │Unit1│  │Unit2│  │Unit3│         │Unit1│       │Unit1│  │Unit2│  │Unit3│
      └─────┘  └─────┘  └─────┘         └─────┘       └─────┘  └─────┘  └─────┘
```

---

## 📁 Struktura Direktorija

```
admin_panel/
│
├── 📂 lib/                          # Flutter izvorni kod (~15,000 linija)
│   ├── 📂 config/                   # Konfiguracija (2,237 linija)
│   │   ├── app_config.dart          # App konstante
│   │   ├── theme.dart               # 40+ tema boja (143 linija)
│   │   └── translations.dart        # 11 jezika (2,094 linija)
│   │
│   ├── 📂 models/                   # Data modeli (~400 linija)
│   │   ├── booking_model.dart       # Rezervacije
│   │   ├── cleaning_log_model.dart  # Čišćenje log
│   │   ├── settings_model.dart      # Postavke
│   │   └── unit_model.dart          # Smještajne jedinice
│   │
│   ├── 📂 providers/                # State management
│   │   └── app_provider.dart        # Glavni provider
│   │
│   ├── 📂 repositories/             # Data access layer (~300 linija)
│   │   ├── base_repository.dart     # Base klasa
│   │   ├── booking_repository.dart  # Rezervacije repo
│   │   └── units_repository.dart    # Jedinice repo
│   │
│   ├── 📂 screens/                  # UI ekrani (9,242 linija)
│   │   ├── analytics_screen.dart    # Analitika (983 linija)
│   │   ├── booking_screen.dart      # Rezervacije (1,344 linija)
│   │   ├── dashboard_screen.dart    # Dashboard (1,288 linija)
│   │   ├── digital_book_screen.dart # Info knjiga (1,783 linija)
│   │   ├── gallery_screen.dart      # Galerija (885 linija)
│   │   ├── login_screen.dart        # Login (133 linija)
│   │   ├── settings_screen.dart     # Postavke (1,395 linija)
│   │   ├── super_admin_screen.dart  # Super Admin (1,017 linija)
│   │   ├── super_admin_tablets.dart # Tablet management
│   │   ├── super_admin_notifications.dart # System notifikacije
│   │   └── tenant_setup_screen.dart # Onboarding (414 linija)
│   │
│   ├── 📂 services/                 # Business logika (19 servisa, ~3,636 linija)
│   │   ├── analytics_service.dart   # Analitika (488 linija)
│   │   ├── app_check_service.dart   # Security stub
│   │   ├── auth_service.dart        # Autentikacija
│   │   ├── booking_service.dart     # Rezervacije (345 linija)
│   │   ├── cache_service.dart       # Offline cache (413 linija)
│   │   ├── calendar_service.dart    # iCal export (364 linija)
│   │   ├── cleaning_service.dart    # Čišćenje workflow (66 linija)
│   │   ├── connectivity_service.dart# Online/Offline detection
│   │   ├── error_service.dart       # Error handling
│   │   ├── health_service.dart      # System health monitoring
│   │   ├── offline_queue_service.dart # Sync queue
│   │   ├── onboarding_service.dart  # User onboarding
│   │   ├── pdf_service.dart         # PDF generiranje (966 linija)
│   │   ├── performance_service.dart # Metrics tracking
│   │   ├── revenue_service.dart     # Revenue analytics (566 linija)
│   │   ├── security_service.dart    # Security utilities
│   │   ├── settings_service.dart    # Postavke (67 linija)
│   │   ├── super_admin_service.dart # Admin operacije (333 linija)
│   │   └── units_service.dart       # Jedinice CRUD
│   │
│   ├── 📂 widgets/                  # Reusable komponente (~1,355 linija)
│   │   ├── booking_calendar.dart    # Drag&Drop kalendar (1,355 linija)
│   │   ├── system_notification_banner.dart
│   │   ├── unit_widgets.dart
│   │   └── 📂 analytics/            # Analytics widgets
│   │
│   ├── 📂 ultis/                    # Utilities
│   │   └── performance_utils.dart
│   │
│   ├── firebase_options.dart        # Firebase config (auto-generated)
│   └── main.dart                    # Entry point
│
├── 📂 functions/                    # Cloud Functions (1,265 linija)
│   ├── index.js                     # 20 funkcija (1,265 linija)
│   ├── api_versioning.js            # API v1/v2 routing
│   ├── package.json                 # Node dependencies
│   └── package-lock.json
│
├── 📂 test/                         # Unit & Widget testovi (~200 linija)
│   ├── services_test.dart           # Service testovi
│   ├── widget_test.dart             # Widget testovi
│   ├── 📂 config/
│   ├── 📂 repositories/
│   └── 📂 services/
│
├── 📂 docs/                         # Dokumentacija
│   ├── API_DOCUMENTATION.md         # API referenca
│   └── FIREBASE_DOCUMENTATION.md    # Firebase setup
│
├── 📂 web/                          # Web specific
│   └── index.html
│
├── 📂 assets/                       # Statički resursi
│   └── 📂 icon/                     # App ikone
│
├── firestore.rules                  # Firestore sigurnost (235 linija)
├── firestore.indexes.json           # DB indeksi (86 linija)
├── storage.rules                    # Storage sigurnost (93 linija)
├── firebase.json                    # Firebase deploy config
├── pubspec.yaml                     # Flutter dependencies
├── pubspec.lock                     # Locked versions
├── analysis_options.yaml            # Dart linter config
└── README.md                        # Ovaj dokument
```

---

## 🖥️ Frontend - Flutter Web

### Ekrani i Funkcionalnosti

| Ekran | Linija | Opis |
|-------|--------|------|
| `dashboard_screen.dart` | 1,288 | Pregled svih jedinica, status gostiju, brzi pristup |
| `booking_screen.dart` | 1,344 | Drag&drop kalendar, zone, periodi, print opcije |
| `settings_screen.dart` | 1,395 | Tema, jezik, PIN-ovi, lozinka, AI kontekst |
| `digital_book_screen.dart` | 1,783 | Kućna pravila, checklist, AI knowledge base |
| `analytics_screen.dart` | 983 | Revenue, occupancy, reviews, AI questions |
| `gallery_screen.dart` | 885 | Slike jedinica, screensaver, upload |
| `super_admin_screen.dart` | 1,017 | Owner CRUD, system config |
| `login_screen.dart` | 133 | Firebase Auth login |
| `tenant_setup_screen.dart` | 414 | Onboarding wizard |

### Servisi (Business Logic Layer)

| Servis | Linija | Odgovornost |
|--------|--------|-------------|
| `pdf_service.dart` | 966 | 10 tipova PDF dokumenata |
| `revenue_service.dart` | 566 | Revenue tracking, statistike |
| `analytics_service.dart` | 488 | Guest insights, AI log |
| `cache_service.dart` | 413 | Offline persistence |
| `calendar_service.dart` | 364 | iCal export/import |
| `booking_service.dart` | 345 | CRUD rezervacija |
| `super_admin_service.dart` | 333 | Owner management |
| `health_service.dart` | ~280 | System health monitoring |
| `offline_queue_service.dart` | ~250 | Offline sync queue |
| `onboarding_service.dart` | ~250 | User onboarding flow |
| `performance_service.dart` | ~200 | Performance metrics |
| `connectivity_service.dart` | ~150 | Network status detection |

### PDF Generiranje - 10 Tipova

| Tip | Opis |
|-----|------|
| eVisitor Data | Skenirani podaci gostiju |
| House Rules | Potpisana kućna pravila |
| Cleaning Log | Dnevnik čišćenja |
| Unit Schedule | Raspored jedinice (30 dana) |
| Text List Full | Tekstualna lista (puna) |
| Text List Anonymous | Tekstualna lista (anonimna) |
| Cleaning Schedule | Raspored čišćenja |
| Graphic Full | Grafički prikaz (pun) |
| Graphic Anonymous | Grafički prikaz (anoniman) |
| Booking History | Povijest rezervacija |

### Lokalizacija - 11 Jezika

| Kod | Jezik | Status |
|-----|-------|--------|
| EN | English | ✅ Master |
| HR | Hrvatski | ✅ Complete |
| SK | Slovenčina | ✅ Complete |
| CS | Čeština | ✅ Complete |
| DE | Deutsch | ✅ Complete |
| IT | Italiano | ✅ Complete |
| ES | Español | ✅ Complete |
| FR | Français | ✅ Complete |
| PL | Polski | ✅ Complete |
| HU | Magyar | ✅ Complete |
| SL | Slovenščina | ✅ Complete |

**Ukupno: ~150 ključeva prijevoda po jeziku = ~1,650 prijevoda**

---

## 🔥 Backend - Firebase

### Firestore Kolekcije

```
firestore/
├── owners/                  # Vlasnici (tenants)
│   └── {ownerId}/
│       ├── email
│       ├── displayName
│       ├── createdAt
│       └── status (active/disabled)
│
├── units/                   # Smještajne jedinice
│   └── {unitId}/
│       ├── ownerId          # Tenant isolation key
│       ├── name, address
│       ├── wifiSSID, wifiPassword
│       ├── cleanerPIN
│       ├── zone
│       ├── reviewLink
│       └── status
│
├── bookings/                # Rezervacije
│   └── {bookingId}/
│       ├── ownerId
│       ├── unitId
│       ├── guestName, guestCount
│       ├── checkIn, checkOut
│       ├── status (confirmed/cancelled/pending/private)
│       ├── notes
│       └── guests[]         # Guest details array
│
├── settings/                # Postavke po tenantu
│   └── {ownerId}/
│       ├── language
│       ├── primaryColor
│       ├── houseRules{}     # Multi-language rules
│       ├── cleanerChecklist[]
│       ├── aiKnowledge{}
│       └── emailSettings{}
│
├── cleaning_logs/           # Log čišćenja
│   └── {logId}/
│       ├── unitId, ownerId
│       ├── cleanerName
│       ├── timestamp
│       └── status
│
├── tablets/                 # Registrirani tableti
│   └── {tabletId}/
│       ├── ownerId
│       ├── unitId
│       ├── lastHeartbeat
│       └── appVersion
│
├── system_notifications/    # Sistemske obavijesti
│   └── {notificationId}/
│       ├── title, message
│       ├── type
│       └── createdAt
│
├── apk_updates/             # APK verzije za tablete
│   └── {version}/
│       ├── downloadUrl
│       ├── releaseNotes
│       └── mandatory
│
├── admin_logs/              # Audit trail
│   └── {logId}/
│       ├── action
│       ├── performedBy
│       ├── timestamp
│       └── details
│
└── super_admins/            # Super admin lista
    └── {email}/
        └── addedAt
```

### Firestore Indeksi (86 linija)

Kompozitni indeksi za optimizirane upite:
- `bookings`: ownerId + checkIn (ascending)
- `bookings`: ownerId + unitId + checkIn
- `units`: ownerId + zone
- `cleaning_logs`: ownerId + timestamp

---

## ⚡ Cloud Functions

### 20 Implementiranih Funkcija (1,265 linija)

| Kategorija | Funkcija | Trigger | Opis |
|------------|----------|---------|------|
| **Owner Management** | `createOwner` | onCall | Kreiranje novog vlasnika |
| | `linkTenantId` | onCall | Povezivanje tenant ID-a |
| | `listOwners` | onCall | Lista svih vlasnika |
| | `deleteOwner` | onCall | Brisanje vlasnika |
| | `resetOwnerPassword` | onCall | Reset lozinke |
| | `toggleOwnerStatus` | onCall | Aktivacija/deaktivacija |
| **Translation** | `translateHouseRules` | onCall | AI prijevod pravila |
| | `translateNotification` | onCall | Prijevod notifikacija |
| **Tablet Management** | `registerTablet` | onCall | Registracija tableta |
| | `tabletHeartbeat` | onCall | Health check tableta |
| **Super Admin** | `addSuperAdmin` | onCall | Dodavanje admina |
| | `removeSuperAdmin` | onCall | Uklanjanje admina |
| | `listSuperAdmins` | onCall | Lista admina |
| | `getAdminLogs` | onCall | Audit logovi |
| **Backup** | `scheduledBackup` | onSchedule | Automatski backup (daily) |
| | `manualBackup` | onCall | Ručni backup |
| **Email Notifications** | `sendEmailNotification` | onCall | Slanje emaila |
| | `onBookingCreated` | onDocumentCreated | Trigger na novu rezervaciju |
| | `sendCheckInReminders` | onSchedule | Podsjetnici za check-in |
| | `updateEmailSettings` | onCall | Email postavke |

### API Versioning

```javascript
// functions/api_versioning.js
const API_CONFIG = {
  currentVersion: "v2",
  supportedVersions: ["v1", "v2"],
  deprecatedVersions: ["v1"],
  sunsetDate: { v1: "2025-06-01" }
};
```

---

## 🔐 Sigurnosni Model

### Autentikacija Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    AUTHENTICATION FLOW                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. User Login                                               │
│     └─→ Firebase Auth (email/password)                       │
│                                                              │
│  2. Token Generation                                         │
│     └─→ JWT sa custom claims:                                │
│         • ownerId (tenant ID)                                │
│         • role (owner/superadmin)                            │
│         • email                                              │
│                                                              │
│  3. Request Authorization                                    │
│     └─→ Firestore Rules provjera tokena                      │
│     └─→ Cloud Functions validacija                           │
│                                                              │
│  4. Data Isolation                                           │
│     └─→ Svaki query filtriran po ownerId                     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Role-Based Access Control

| Rola | Pristup | Autentikacija |
|------|---------|---------------|
| **Super Admin** | Sve funkcije, svi tenanti | Email/Password + Custom Claim |
| **Owner** | Samo vlastiti podaci | Email/Password + ownerId Claim |
| **Cleaner** | Cleaning workflow | PIN autentikacija |
| **Guest** | Tablet app (read-only) | Booking reference |

### Firestore Security Rules (235 linija)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(ownerId) {
      return request.auth.token.ownerId == ownerId;
    }
    
    function isSuperAdmin() {
      return request.auth.token.role == 'superadmin';
    }
    
    // Units collection
    match /units/{unitId} {
      allow read: if isAuthenticated() && 
                  (isOwner(resource.data.ownerId) || isSuperAdmin());
      allow create: if isAuthenticated() && 
                    isOwner(request.resource.data.ownerId);
      allow update, delete: if isAuthenticated() && 
                            isOwner(resource.data.ownerId);
    }
    
    // Bookings collection
    match /bookings/{bookingId} {
      allow read, write: if isAuthenticated() && 
                         isOwner(resource.data.ownerId);
    }
    
    // Settings collection
    match /settings/{ownerId} {
      allow read, write: if isAuthenticated() && 
                         isOwner(ownerId);
    }
  }
}
```

### Storage Security Rules (93 linija)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Gallery images
    match /gallery/{ownerId}/{allPaths=**} {
      allow read: if request.auth.token.ownerId == ownerId;
      allow write: if request.auth.token.ownerId == ownerId
                   && request.resource.size < 5 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
    }
    
    // APK uploads (super admin only)
    match /apk/{version}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.role == 'superadmin';
    }
  }
}
```

### Security Features Checklist

| Feature | Status | Opis |
|---------|--------|------|
| JWT Authentication | ✅ | Firebase Auth + Custom Claims |
| Tenant Isolation | ✅ | ownerId claim u svakom requestu |
| Firestore Rules | ✅ | 235 linija sigurnosnih pravila |
| Storage Rules | ✅ | 93 linija, size/type validation |
| Rate Limiting | ✅ | Cloud Functions throttling |
| Input Validation | ✅ | Server-side validation |
| Audit Logging | ✅ | admin_logs kolekcija |
| App Check | ⏳ | Stub spreman za aktivaciju |

---

## 📊 Statistika Koda

### Ukupan Broj Linija

| Kategorija | Linija | Postotak |
|------------|--------|----------|
| Screens (12 files) | 9,242 | 48.6% |
| Services (19 files) | 3,636 | 19.1% |
| Translations | 2,094 | 11.0% |
| Widgets | 1,355 | 7.1% |
| Cloud Functions | 1,265 | 6.7% |
| Firebase Rules | 414 | 2.2% |
| Models | ~400 | 2.1% |
| Repositories | ~300 | 1.6% |
| Tests | ~200 | 1.1% |
| Config | ~143 | 0.8% |
| **UKUPNO** | **~19,000+** | **100%** |

### Datoteke po Tipu

| Tip | Broj Datoteka |
|-----|---------------|
| `.dart` | ~45 |
| `.js` | 2 |
| `.json` | 5 |
| `.rules` | 2 |
| `.md` | 3 |
| `.yaml` | 3 |

### Kompleksnost Projekta

| Metrika | Vrijednost |
|---------|------------|
| UI Ekrani | 12 |
| Business Servisi | 19 |
| Cloud Functions | 20 |
| Firestore Kolekcije | 10+ |
| Podržani jezici | 11 |
| PDF tipova | 10 |
| Tema boja | 40+ |
| Firestore indeksa | 6+ |

---

## 📌 Verzije i Changelog

### Trenutna Verzija: 2.1.0

```
═══════════════════════════════════════════════════════════════

v2.1.0 (Phase 5 - Enterprise Hardening) - CURRENT
────────────────────────────────────────────────────────────────
✅ Offline Queue Service + Auto-Sync
✅ Performance Monitoring Service
✅ App Check Security (stub ready)
✅ API Versioning (v1/v2)
✅ Enhanced Onboarding Service
✅ Health Dashboard Service
✅ Unit Tests Foundation

═══════════════════════════════════════════════════════════════

v2.0.0 (Phase 4 - Advanced Features)
────────────────────────────────────────────────────────────────
✅ Revenue Analytics Dashboard
✅ iCal Calendar Export
✅ Email Notifications System
✅ 11-language Support Complete
✅ ~150 Translation Keys per Language

═══════════════════════════════════════════════════════════════

v1.0.0 (Phase 1-3 - Core System)
────────────────────────────────────────────────────────────────
✅ Multi-tenant Architecture
✅ Booking Calendar with Drag & Drop
✅ PDF Generation (10 document types)
✅ Guest Check-in Workflow
✅ Cleaner Tasks Management
✅ Gallery + Screensaver Mode
✅ AI Concierge Integration
✅ Super Admin Panel
✅ Tablet Management
✅ System Notifications

═══════════════════════════════════════════════════════════════
```

---

## 🔧 Dependencies

### Flutter Packages (pubspec.yaml)

```yaml
dependencies:
  # UI & Design
  google_fonts: ^6.1.0
  flutter_markdown: ^0.7.0
  animate_do: ^3.3.4
  intl: ^0.19.0
  
  # State & Navigation
  provider: ^6.1.1
  go_router: ^14.6.3
  
  # Firebase
  firebase_core: ^3.8.1
  cloud_firestore: ^5.5.2
  firebase_auth: ^5.3.4
  firebase_storage: ^12.3.6
  cloud_functions: ^5.2.3
  
  # PDF & Printing
  pdf: ^3.10.4
  printing: ^5.11.0
  
  # Networking & Offline
  http: ^1.2.0
  connectivity_plus: ^6.0.0
  shared_preferences: ^2.2.0
  
  # Error Tracking
  sentry_flutter: ^8.0.0
  
  # Utilities
  file_picker: ^6.1.1
  image_network: ^2.6.0
```

### Cloud Functions (package.json)

```json
{
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^5.0.0",
    "@google/generative-ai": "^0.21.0"
  },
  "engines": {
    "node": "20"
  }
}
```

---

## ⚠️ Završna Napomena

```
═══════════════════════════════════════════════════════════════════════════════

                    PRIVATNO VLASNIŠTVO - ZABRANJENO KOPIRANJE

  Ovaj repozitorij i sav sadržaj u njemu su zaštićeni autorskim pravima.
  
  Neovlašteno kopiranje, distribucija, modifikacija ili korištenje
  bilo kojeg dijela ovog softvera bez izričite pisane dozvole 
  vlasnika autorskih prava je STROGO ZABRANJENO i podliježe
  pravnim sankcijama.

  Za sve upite kontaktirajte vlasnika repozitorija.

                              © 2024-2025
                         SVA PRAVA PRIDRŽANA

═══════════════════════════════════════════════════════════════════════════════
```