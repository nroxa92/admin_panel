# 🏨 VillaOS Admin Panel

> **Enterprise-grade Property Management System**

[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.32+-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-orange.svg)](https://firebase.google.com)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-green.svg)]()

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

- [Pregled Projekta](#-pregled-projekta)
- [Statistika Projekta](#-statistika-projekta)
- [Tehnička Arhitektura](#-tehnička-arhitektura)
- [Struktura Direktorija](#-struktura-direktorija)
- [Funkcionalnosti](#-funkcionalnosti)
- [Cloud Functions API](#-cloud-functions-api)
- [Sigurnosni Model](#-sigurnosni-model)
- [Lokalizacija](#-lokalizacija)
- [Verzije i Changelog](#-verzije-i-changelog)

---

## 🎯 Pregled Projekta

**VillaOS** (Vesta Lumina System) je enterprise-grade sustav za upravljanje smještajnim objektima koji omogućuje vlasnicima vila, apartmana i soba kompletno digitalno upravljanje poslovanjem.

### Komponente Sustava

| Komponenta | Tehnologija | Status |
|------------|-------------|--------|
| **Web Admin Panel** | Flutter Web 3.32+ | ✅ Production Ready |
| **Firebase Backend** | Firestore, Auth, Storage, Functions | ✅ Production Ready |
| **Cloud Functions** | Node.js 20, 20 funkcija | ✅ Production Ready |
| **Android Tablet App** | Flutter Android (Kiosk Mode) | 🔄 Separate Repository |

### Live Demo

🌐 **Production URL:** `https://vls-admin.web.app`

---

## 📊 Statistika Projekta

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         VillaOS ADMIN PANEL v2.2.0                            ║
║                            PRODUCTION STATISTICS                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  📁 IZVORNI KOD                                                               ║
║  ─────────────────────────────────────────────────────────────────────────── ║
║  │ Ukupno linija koda        │ ~21,000+                                      ║
║  │ Flutter/Dart datoteke     │ ~50 datoteka                                  ║
║  │ Cloud Functions           │ 1,265 linija (20 funkcija)                    ║
║  │ Firebase Rules            │ 328 linija (Firestore + Storage)              ║
║  │ Firestore Indexes         │ 11 kompozitnih indeksa                        ║
║                                                                               ║
║  🧪 TESTIRANJE                                                                ║
║  ─────────────────────────────────────────────────────────────────────────── ║
║  │ Test Suite                │ 2,918 linija                                  ║
║  │ Broj testova              │ 138 unit/widget testova                       ║
║  │ Test kategorije           │ Services, Models, Widgets, Integration        ║
║                                                                               ║
║  🌍 LOKALIZACIJA                                                              ║
║  ─────────────────────────────────────────────────────────────────────────── ║
║  │ Podržani jezici           │ 11 (EN, HR, DE, IT, ES, FR, PL, SK, CS, HU, SL)║
║  │ Prijevodni ključevi       │ ~150 po jeziku                                ║
║  │ Ukupno prijevoda          │ ~1,650                                        ║
║                                                                               ║
║  📄 PDF GENERIRANJE                                                           ║
║  ─────────────────────────────────────────────────────────────────────────── ║
║  │ Tipovi dokumenata         │ 10 različitih PDF formata                     ║
║                                                                               ║
║  🎨 TEME                                                                      ║
║  ─────────────────────────────────────────────────────────────────────────── ║
║  │ Paleta boja               │ 10 primarnih + 6 pozadinskih tonova           ║
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
├── 📂 lib/                          # Flutter izvorni kod (~21,000 linija)
│   ├── 📂 config/                   # Konfiguracija
│   │   ├── app_config.dart          # App konstante
│   │   ├── theme.dart               # Tema definicije
│   │   └── translations.dart        # 11 jezika (~2,100 linija)
│   │
│   ├── 📂 models/                   # Data modeli
│   │   ├── booking_model.dart       # Rezervacije
│   │   ├── cleaning_log_model.dart  # Čišćenje log
│   │   ├── settings_model.dart      # Postavke
│   │   └── unit_model.dart          # Smještajne jedinice
│   │
│   ├── 📂 providers/                # State management
│   │   └── app_provider.dart        # Glavni provider
│   │
│   ├── 📂 screens/                  # UI ekrani (12 ekrana)
│   │   ├── dashboard_screen.dart    # Dashboard + Navigation
│   │   ├── booking_screen.dart      # Kalendar rezervacija
│   │   ├── settings_screen.dart     # Postavke
│   │   ├── analytics_screen.dart    # Analitika i statistike
│   │   ├── digital_book_screen.dart # Info knjiga za goste
│   │   ├── gallery_screen.dart      # Galerija slika
│   │   ├── login_screen.dart        # Firebase Auth login
│   │   ├── tenant_setup_screen.dart # Onboarding wizard
│   │   ├── super_admin_screen.dart  # Owner management
│   │   ├── super_admin_tablets.dart # Tablet deployment
│   │   └── super_admin_notifications.dart
│   │
│   ├── 📂 services/                 # Business logika (19 servisa)
│   │   ├── auth_service.dart        # Enterprise Auth (475 linija)
│   │   ├── booking_service.dart     # CRUD rezervacija
│   │   ├── pdf_service.dart         # 10 PDF tipova
│   │   ├── revenue_service.dart     # Revenue analytics
│   │   ├── cache_service.dart       # Offline persistence
│   │   ├── super_admin_service.dart # Admin operacije
│   │   └── ... (13 dodatnih servisa)
│   │
│   ├── 📂 widgets/                  # Reusable komponente
│   │   ├── booking_calendar.dart    # Drag&Drop kalendar
│   │   └── unit_widgets.dart        # Unit kartice
│   │
│   ├── 📂 utils/                    # Utilities
│   │   └── performance_utils.dart   # Debouncer, Throttler, etc.
│   │
│   ├── firebase_options.dart        # Firebase config
│   └── main.dart                    # Entry point
│
├── 📂 functions/                    # Cloud Functions (1,265 linija)
│   ├── index.js                     # 20 funkcija
│   └── package.json                 # Node dependencies
│
├── 📂 test/                         # Test Suite (2,918 linija)
│   ├── 📂 services/                 # Service testovi
│   ├── 📂 models/                   # Model testovi
│   ├── 📂 widgets/                  # Widget testovi
│   ├── 📂 integration/              # Integration testovi
│   └── 📂 helpers/                  # Test utilities
│
├── 📂 docs/                         # Dokumentacija
│   ├── API_DOCUMENTATION.md         # API referenca
│   ├── FIREBASE_DOCUMENTATION.md    # Firebase setup
│   └── CHANGELOG.md                 # Version history
│
├── firestore.rules                  # Firestore sigurnost (235 linija)
├── firestore.indexes.json           # DB indeksi (11 indeksa)
├── storage.rules                    # Storage sigurnost (93 linija)
├── firebase.json                    # Firebase deploy config
├── LICENSE                          # Proprietary License
└── README.md                        # Ovaj dokument
```

---

## ⚡ Funkcionalnosti

### 📅 Booking Management
- Drag & Drop kalendar s vizualnim pregledom
- Status praćenje (confirmed, pending, cancelled, private)
- Zone grupiranje jedinica
- iCal Export/Import
- Overlap detection

### 🏠 Unit Management
- Multi-tenant arhitektura s potpunom izolacijom
- WiFi/PIN konfiguracija
- QR kod generiranje
- Zone assignment

### 📊 Analytics & Revenue
- Revenue tracking po periodu
- Occupancy rate kalkulacija
- Guest insights
- AI Questions logging

### 📄 PDF Generation (10 tipova)
| Tip | Opis |
|-----|------|
| eVisitor Data | Skenirani podaci gostiju |
| House Rules | Potpisana kućna pravila |
| Cleaning Log | Dnevnik čišćenja |
| Unit Schedule | Raspored jedinice |
| Text List (Full/Anon) | Tekstualne liste |
| Graphic View (Full/Anon) | Grafički prikazi |
| Cleaning Schedule | Raspored čišćenja |
| Booking History | Povijest rezervacija |

### 🧹 Cleaning Workflow
- Task management s checklistama
- PIN autentikacija za čistače
- Status workflow (pending → in_progress → completed)
- Photo upload

### 👨‍💼 Super Admin Panel
- Owner CRUD operacije
- Tablet deployment management
- System notifications
- Audit logging
- APK update distribution

---

## ⚡ Cloud Functions API

### 20 Serverless Funkcija

| Kategorija | Funkcija | Opis |
|------------|----------|------|
| **Owner Management (6)** | `createOwner` | Kreiranje novog vlasnika |
| | `linkTenantId` | Povezivanje tenant ID-a |
| | `listOwners` | Lista svih vlasnika |
| | `deleteOwner` | Brisanje vlasnika |
| | `resetOwnerPassword` | Reset lozinke |
| | `toggleOwnerStatus` | Aktivacija/deaktivacija |
| **Translation (2)** | `translateHouseRules` | AI prijevod pravila |
| | `translateNotification` | Prijevod notifikacija |
| **Tablet (2)** | `registerTablet` | Registracija tableta |
| | `tabletHeartbeat` | Health check |
| **Super Admin (4)** | `addSuperAdmin` | Dodavanje admina |
| | `removeSuperAdmin` | Uklanjanje admina |
| | `listSuperAdmins` | Lista admina |
| | `getAdminLogs` | Audit logovi |
| **Backup (2)** | `scheduledBackup` | Automatski backup |
| | `manualBackup` | Ručni backup |
| **Email (4)** | `sendEmailNotification` | Slanje emaila |
| | `onBookingCreated` | Trigger na rezervaciju |
| | `sendCheckInReminders` | Check-in podsjetnici |
| | `updateEmailSettings` | Email postavke |

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
| **Guest** | Tablet app (read-only) | Booking reference |

### Security Features

- ✅ JWT Authentication with Custom Claims
- ✅ Multi-tenant Data Isolation
- ✅ Firestore Security Rules (235 lines)
- ✅ Storage Security Rules (93 lines)
- ✅ Server-side Input Validation
- ✅ Rate Limiting on Cloud Functions
- ✅ Audit Logging (admin_logs collection)
- ✅ 11 Composite Firestore Indexes

---

## 🌍 Lokalizacija

### Podržani jezici (11)

| Kod | Jezik | Status |
|-----|-------|--------|
| 🇬🇧 EN | English | ✅ Master |
| 🇭🇷 HR | Hrvatski | ✅ Complete |
| 🇩🇪 DE | Deutsch | ✅ Complete |
| 🇮🇹 IT | Italiano | ✅ Complete |
| 🇪🇸 ES | Español | ✅ Complete |
| 🇫🇷 FR | Français | ✅ Complete |
| 🇵🇱 PL | Polski | ✅ Complete |
| 🇸🇰 SK | Slovenčina | ✅ Complete |
| 🇨🇿 CS | Čeština | ✅ Complete |
| 🇭🇺 HU | Magyar | ✅ Complete |
| 🇸🇮 SL | Slovenščina | ✅ Complete |

**~150 translation keys × 11 languages = ~1,650 translations**

---

## 📌 Verzije i Changelog

### Trenutna verzija: 2.2.0 (Siječanj 2026)

```
v2.2.0 - Production Ready Release
═══════════════════════════════════════════════════════════════
✅ Enterprise Auth Service (475 lines)
✅ Comprehensive Test Suite (138 tests, 2,918 lines)
✅ Fixed tenant activation flow
✅ Fixed translations bug (argument order)
✅ Added missing Firestore indexes
✅ Performance utilities (Debouncer, Throttler, RetryHelper)

v2.1.0 - Enterprise Hardening
═══════════════════════════════════════════════════════════════
✅ Offline Queue Service + Auto-Sync
✅ Performance Monitoring
✅ API Versioning (v1/v2)
✅ Health Dashboard Service

v2.0.0 - Advanced Features
═══════════════════════════════════════════════════════════════
✅ Revenue Analytics Dashboard
✅ iCal Calendar Export
✅ Email Notifications System
✅ 11-language Support

v1.0.0 - Core System
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

**VillaOS Admin Panel** | Enterprise Property Management System

*Built with Flutter & Firebase*

</div>