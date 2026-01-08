# 🏰 VillaOS - Admin Panel

**VillaOS** (Villa Operating System) je sveobuhvatni sustav za upravljanje vilama i rentalnim nekretninama. Projekt se sastoji od **Flutter Web Admin Panela** za vlasnike nekretnina, **Super Admin Panela** za upravljanje svim vlasnicima, te **Android tablet aplikacije** koja se koristi u kiosk modu direktno u smještajnim jedinicama.

Backend infrastruktura je izgrađena na **Firebase** ekosustavu uključujući Cloud Functions, Firestore bazu podataka i Firebase Storage.

---

# 📊 VillaOS Admin Panel - Kompletna Analiza Projekta

**Datum analize:** Januar 2026  
**GitHub:** https://github.com/nroxa92/admin_panel  
**Ukupno linija koda:** ~21,000+

---

# 📁 STRUKTURA PROJEKTA

```
admin_panel/
├── 📄 ROOT FILES
│   ├── .firebaserc                 # Firebase projekt config
│   ├── .gitattributes              # Git attributes
│   ├── LICENSE                     # Proprietary license
│   ├── README.md                   # Dokumentacija
│   ├── analysis_options.yaml       # Dart linter rules
│   ├── firebase.json          (56) # Firebase hosting/functions config
│   ├── firestore.rules       (357) # Firestore security rules (16 kolekcija)
│   ├── storage.rules         (160) # Storage security rules (APK + files)
│   ├── pubspec.yaml           (57) # Flutter dependencies
│   ├── pubspec.lock                # Locked versions
│   └── villa_admin.iml             # IntelliJ config
│
├── 📁 lib/                         # FLUTTER SOURCE CODE
│   ├── main.dart             (628) # Entry point + AuthWrapper + Super Admin routing
│   ├── firebase_options.dart  (22) # Firebase config (auto-generated)
│   │
│   ├── 📁 config/
│   │   ├── theme.dart        (143) # AppTheme + color schemes
│   │   └── translations.dart(1759) # 11 jezika × 130+ ključeva
│   │
│   ├── 📁 models/
│   │   ├── booking_model.dart(123) # Booking data model
│   │   ├── cleaning_log_model.dart (93) # Cleaning log model
│   │   ├── settings_model.dart(317) # VillaSettings (30+ polja)
│   │   └── unit_model.dart   (125) # Unit data model
│   │
│   ├── 📁 providers/
│   │   └── app_provider.dart (123) # Global state (theme, language, settings)
│   │
│   ├── 📁 screens/
│   │   ├── analytics_screen.dart   (297) # 📊 Statistika (placeholder)
│   │   ├── booking_screen.dart    (1344) # 📅 Booking kalendar
│   │   ├── dashboard_screen.dart  (1295) # 🏠 Live monitor
│   │   ├── digital_book_screen.dart(1783) # 📖 CMS za tablet
│   │   ├── gallery_screen.dart     (789) # 🖼️ Galerija (placeholder)
│   │   ├── login_screen.dart       (133) # 🔐 Login
│   │   ├── settings_screen.dart   (1395) # ⚙️ Postavke
│   │   ├── tenant_setup_screen.dart(414) # 🆕 Onboarding
│   │   │
│   │   │── 👑 SUPER ADMIN MODULE (NOVO!)
│   │   ├── super_admin_screen.dart       (701) # 👑 Main + Owners Tab
│   │   ├── super_admin_tablets.dart      (816) # 📱 Tablets + APK Updates
│   │   └── super_admin_notifications.dart(737) # 📢 Activity Log + Notifications
│   │
│   ├── 📁 services/
│   │   ├── auth_service.dart   (28) # Firebase Auth helper
│   │   ├── booking_service.dart(375) # CRUD rezervacija + guests
│   │   ├── cleaning_service.dart(72) # Cleaning logs
│   │   ├── pdf_service.dart   (966) # 10 PDF tipova
│   │   ├── settings_service.dart(67) # Settings CRUD
│   │   └── units_service.dart (350) # Units CRUD + ID generator
│   │
│   └── 📁 widgets/
│       ├── booking_calendar.dart(1355) # Drag&drop kalendar
│       ├── unit_widgets.dart   (1426) # Unit cards, dialogs
│       └── system_notification_banner.dart (274) # 📢 Owner notification banner
│
├── 📁 functions/                   # CLOUD FUNCTIONS (Node.js)
│   ├── .gitignore
│   ├── index.js              (740) # 10 Cloud Functions
│   ├── package.json
│   └── package-lock.json
│
├── 📁 web/                         # WEB CONFIG
│   ├── favicon.png
│   ├── icons/
│   ├── index.html
│   └── manifest.json
│
├── 📁 assets/
│   └── icon/
│       └── icon.png
│
└── 📁 [IGNORIRATI - cache/build]
    ├── .dart_tool/
    ├── .firebase/
    ├── .idea/
    └── build/
```

---

# 📄 DETALJNA ANALIZA SVAKOG FAJLA

## 🔷 ENTRY POINT

### `lib/main.dart` (628 linija)
**Svrha:** Ulazna točka aplikacije + Super Admin routing

**Super Admin Logika:**
```dart
const String superAdminEmail = 'master@admin.com';

// U AuthWrapper:
if (userEmail == superAdminEmail) {
  return const SuperAdminScreen();  // 👑 Super Admin vidi SAMO svoj dashboard
}
```

---

## 🔷 CONFIG

### `lib/config/translations.dart` (1759 linija)
**Podržani jezici (11):**
| Kod | Jezik | Kod | Jezik |
|-----|-------|-----|-------|
| `en` | English | `fr` | Français |
| `hr` | Hrvatski | `es` | Español |
| `de` | Deutsch | `pl` | Polski |
| `it` | Italiano | `cz` | Čeština |
| `hu` | Magyar | `sl` | Slovenščina |
| `sk` | Slovenčina | | |

---

## 👑 SUPER ADMIN MODULE

### `lib/screens/super_admin_screen.dart` (701 linija)
**Svrha:** Main Super Admin scaffold + Owners management

**Features:**
- 5-tab TabController (Owners, Tablets, APK Updates, Activity Log, Notifications)
- Create Owner dialog (email, password, tenant ID)
- Edit/Delete/Suspend owner
- Password reset
- Status toggle (Active/Suspended)

---

### `lib/screens/super_admin_tablets.dart` (816 linija)
**Svrha:** Tablet monitoring + APK Updates

**Tablets Features:**
- Real-time online/offline status (heartbeat)
- App version tracking
- Device info (model, OS)
- Owner grouping
- **Update status tracking:**
  - 🟠 PENDING - Čeka download
  - 🔵 DOWNLOADING - Skida se
  - 🔵 DOWNLOADED - Skinuto, čeka install
  - 🟢 INSTALLED - Instalirano uspješno
  - 🔴 FAILED - Greška + poruka

**APK Updates Features:**
- Manual APK upload to Firebase Storage
- Owner-based selection (checkboxes)
- Force update toggle
- Real-time tablet count
- Update history

---

### `lib/screens/super_admin_notifications.dart` (737 linija)
**Svrha:** Activity Log + System Notifications

**Notifications Features:**
- 4 priority levels (🔴 Red, 🟡 Yellow, 🟢 Green, 🔵 Blue)
- AI translation to 11 languages (Gemini)
- **Target selection:**
  - All Owners
  - Specific Owners (checkboxes)
- Active/Inactive sections
- Dismissible by owners

---

## 🔷 CLOUD FUNCTIONS

### `functions/index.js` (740 linija)
**10 Backend Cloud Functions:**

| # | Funkcija | Opis | Pristup |
|---|----------|------|---------|
| 1 | `createOwner` | Kreira novog vlasnika | Super Admin only |
| 2 | `linkTenantId` | Aktivira tenant account | Public |
| 3 | `listOwners` | Lista svih vlasnika | Super Admin only |
| 4 | `deleteOwner` | Briše vlasnika | Super Admin only |
| 5 | `resetOwnerPassword` | Resetira lozinku | Super Admin only |
| 6 | `toggleOwnerStatus` | Active/Suspended toggle | Super Admin only |
| 7 | `translateHouseRules` | AI prijevod (Gemini) | Authenticated |
| 8 | `registerTablet` | Registrira novi tablet | Authenticated |
| 9 | `tabletHeartbeat` | Tablet ping + update check | Tablet only |
| 10 | `translateNotification` | Prijevod obavijesti (11 jezika) | Super Admin only |

**Super Admin Check:**
```javascript
if (!request.auth || request.auth.token.email !== 'master@admin.com') {
  throw new Error('Unauthorized - Super Admin only');
}
```

**Region:** `europe-west3`  
**Secrets:** `GEMINI_API_KEY`

---

## 🔷 FIRESTORE SCHEMA

### Owner Data kolekcije:
```
/settings/{tenantId}           - Owner postavke (30+ polja)
/units/{unitId}                - Smještajne jedinice
/bookings/{bookingId}          - Rezervacije
/bookings/{id}/guests/{guestId} - Skenirani gosti (subcollection)
/signatures/{signatureId}      - Potpisi pravila
/cleaning_logs/{logId}         - Zapisnici čišćenja
/check_ins/{checkInId}         - OCR scan events
/feedback/{feedbackId}         - Guest ratings
/gallery/{imageId}             - Screensaver images
/ai_logs/{logId}               - AI chat history
```

### 👑 Super Admin kolekcije:
```
/tenant_links/{tenantId}       - Owner<->Firebase UID link
├── tenantId, firebaseUid, email, displayName
├── status: "pending" | "active" | "suspended"
├── createdAt, linkedAt

/tablets/{deviceId}
├── tabletId, firebaseUid, ownerId, unitId
├── ownerName, unitName, appVersion
├── lastActiveAt, status, model, osVersion
├── batteryLevel, isCharging
├── pendingUpdate, pendingVersion, pendingApkUrl, forceUpdate
├── updateStatus: "pending" | "downloading" | "downloaded" | "installed" | "failed"
├── updateError, updatePushedAt, updateDownloadedAt, updateInstalledAt

/system_notifications/{notificationId}
├── message, priority: "red" | "yellow" | "green" | "blue"
├── sourceLanguage, translations: {en: "...", hr: "...", ...}
├── active, sendToAll, targetOwners: ["ROKSA123", ...]
├── dismissedBy: [], createdAt, createdBy

/apk_updates/{updateId}
├── version, apkUrl, targetOwners: []
├── forceUpdate, pushedAt, pushedBy, tabletCount

/admin_logs/{logId}
├── action, targetId, details, timestamp, performedBy

/app_config/{configId}
├── currentVersion, apkUrl, updatedAt, forceUpdate
```

---

## 🔷 FIREBASE STORAGE

### Putanje:
```
/apk/{filename}                              # APK files (Super Admin upload)
/apk/{version}/{filename}                    # Alternative versioned path
/screensaver/{ownerId}/{imageId}             # Screensaver images
/signatures/{ownerId}/{filename}             # Guest signatures
/units/{ownerId}/{unitId}/{filename}         # Unit images
/exports/{ownerId}/{filename}                # PDF exports
```

---

# 🔐 SIGURNOSNI MODEL

## User Roles:

| Role | Email/Claims | Pristup |
|------|--------------|---------|
| **Super Admin** | `master@admin.com` | Super Admin Dashboard SAMO |
| **Owner** | `role: 'owner'` | Regular Dashboard (tenant-isolated) |
| **Tablet** | `role: 'tablet'` | Read settings, Write guests/signatures |

## Custom Claims Structure:

```javascript
// Super Admin (email-based)
{ email: 'master@admin.com' }

// Owner (Web Panel)
{ ownerId: 'ROKSA123', role: 'owner' }

// Tablet
{ ownerId: 'ROKSA123', unitId: 'NR-PREM-SUNSET', role: 'tablet' }
```

---

# 📊 STATISTIKA

| Kategorija | Fajlova | Linija |
|------------|---------|--------|
| **Screens** | 11 | 11,585 |
| **Widgets** | 3 | 3,055 |
| **Services** | 6 | 1,858 |
| **Models** | 4 | 658 |
| **Config** | 2 | 1,902 |
| **Functions** | 1 | 740 |
| **Rules** | 2 | 517 |
| **UKUPNO** | **~32** | **~21,000** |

---

# 📱 TABLET APP INTEGRACIJA

## Update Status Flow:

```
Super Admin pushes update
        │
        ▼
┌───────────────────┐
│ pendingUpdate:true│
└───────────────────┘
        │
        ▼ (Tablet heartbeat reports progress)
┌───────────────────┐
│ 'pending'         │
│ 'downloading'     │
│ 'downloaded'      │
│ 'installed' ✅    │
└───────────────────┘
(or 'failed' ❌ with updateError)
```

---

# 🎯 ZAKLJUČAK

**VillaOS Admin Panel** je production-ready web aplikacija s:

### Core Features:
- ✅ Multi-tenant arhitektura
- ✅ 11-jezična podrška
- ✅ 10 PDF tipova
- ✅ Real-time Firestore sync
- ✅ 10 Cloud Functions

### 👑 Super Admin Features:
- ✅ Owner Management (CRUD + Suspend)
- ✅ Tablet Monitoring (status, battery, version)
- ✅ APK Update System (owner selection, force update)
- ✅ Update Status Tracking
- ✅ System Notifications (4 prioriteta, 11 jezika, owner targeting)
- ✅ Activity Log

**Spremno za:** 
- ✅ Produkcijsko korištenje
- ✅ Tablet app integraciju
- ✅ Multi-owner SaaS deployment

---

## ⛔️ Licenca

**© Copyright 2024-2026 nroxa92. Sva prava pridržana.**

---

## 📬 Kontakt

- **GitHub**: [@nroxa92](https://github.com/nroxa92)
- **E-Mail**: nevenroksa@gmail.com

---

**VillaOS** - Simplifying Property Management 🏰
