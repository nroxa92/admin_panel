# 🏰 VillaOS - Admin Panel

**VillaOS** (Villa Operating System) je sveobuhvatni sustav za upravljanje vilama i rentalnim nekretninama. Projekt se sastoji od **Flutter Web Admin Panela** za vlasnike nekretnina te **Android tablet aplikacije** koja se koristi u kiosk modu direktno u smještajnim jedinicama.

Backend infrastruktura je izgrađena na **Firebase** ekosustavu uključujući Cloud Functions, Firestore bazu podataka i Firebase Storage.

---

# 📊 VillaOS Admin Panel - Kompletna Analiza Projekta

**Datum analize:** Januar 2026  
**GitHub:** https://github.com/nroxa92/admin_panel  
**Ukupno linija koda:** ~18,000+

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
│   │   ├── super_admin_screen.dart(1881) # 👑 Super Admin Dashboard (NOVO!)
│   │   └── tenant_setup_screen.dart(414) # 🆕 Onboarding
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
│       └── unit_widgets.dart   (1426) # Unit cards, dialogs
│
├── 📁 functions/                   # CLOUD FUNCTIONS (Node.js)
│   ├── .gitignore
│   ├── index.js              (681) # 9 Cloud Functions
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

**Sadržaj:**
- `main()` - Firebase inicijalizacija
- `AdminApp` - MaterialApp wrapper
- `superAdminEmail` - Konstanta za Super Admin email
- `AuthWrapper` - Stream koji prati auth state + **Super Admin check**
- `MainLayout` - Scaffold s navigation drawer
- `NavDrawer` - Bočna navigacija (Dashboard, Calendar, Settings...)
- GoRouter setup za URL-based navigation

**Super Admin Logika:**
```dart
const String superAdminEmail = 'nevenroksa@gmail.com';

// U AuthWrapper:
if (userEmail == superAdminEmail) {
  return const SuperAdminScreen();  // 👑 Super Admin vidi SAMO svoj dashboard
}
// Inače normalni flow...
```

**Ključne klase:**
```dart
AdminApp → MaterialApp
AuthWrapper → StreamBuilder<User?> + Super Admin routing
MainLayout → Scaffold + Drawer
NavDrawer → ListView s navigation items
```

---

## 🔷 CONFIG

### `lib/config/theme.dart` (143 linija)
**Svrha:** Tema i boje aplikacije

**Sadržaj:**
- `AppTheme.generateTheme()` - Dinamičko generiranje teme
- Dark/Light mode podrška
- Luxury color palette (Gold, Teal, Coral, Rose...)
- Neon color palette (Cyan, Magenta, Lime...)
- Background themes (OLED Black, Slate Grey, Silver, Pure White...)

---

### `lib/config/translations.dart` (1759 linija)
**Svrha:** Multi-language podrška

**Podržani jezici (11):**
| Kod | Jezik | Kod | Jezik |
|-----|-------|-----|-------|
| `en` | English | `fr` | Français |
| `hr` | Hrvatski | `es` | Español |
| `de` | Deutsch | `pl` | Polski |
| `it` | Italiano | `cz` | Čeština |
| `hu` | Magyar | `sl` | Slovenščina |
| `sk` | Slovenčina | | |

**Kategorije ključeva (~130+):**
- Navigation (nav_dashboard, nav_calendar...)
- Headers (header_settings, header_bookings...)
- Buttons (btn_save, btn_cancel, btn_delete...)
- Labels (label_name, label_address, label_email...)
- Messages (msg_saved, msg_error, msg_confirm_delete...)
- Status (status_confirmed, status_blocked...)
- Print (print_evisitor, print_house_rules...)
- Theme (theme_luxury, theme_neon, theme_dark...)

---

## 🔷 MODELS

### `lib/models/settings_model.dart` (317 linija)
**Svrha:** VillaSettings data model

**Polja (30+):**
```dart
// Identifikacija
ownerId: String

// Owner Info
ownerFirstName, ownerLastName, contactEmail, contactPhone, companyName

// Emergency Contact (odvojeno!)
emergencyCall, emergencySms, emergencyWhatsapp, emergencyViber, emergencyEmail

// Kategorije
categories: List<String>

// Sigurnost
cleanerPin, hardResetPin

// AI Knowledge
aiConcierge, aiHousekeeper, aiTech, aiGuide

// Digital Book
welcomeMessage, welcomeMessageTranslations, houseRulesTranslations
cleanerChecklist, welcomeMessageDuration, houseRulesDuration

// Konfiguracija
checkInTime, checkOutTime, wifiSsid, wifiPass

// Izgled
themeColor, themeMode, appLanguage
```

**Metode:**
- `fromFirestore()` - Parse iz Firestore
- `toMap()` - Serialize za spremanje
- Helper parseri za safe type conversion

---

### `lib/models/booking_model.dart` (123 linija)
**Svrha:** Booking/rezervacija model

**Polja:**
```dart
id, ownerId, unitId, guestName, guestCount
startDate, endDate (Timestamp)
checkInTime, checkOutTime (String "HH:mm")
status, note, isScanned
```

**Status boje:**
- confirmed → Green
- booking.com → Blue
- airbnb → Orange
- private → Yellow
- blocked → Red

---

### `lib/models/unit_model.dart` (125 linija)
**Svrha:** Smještajna jedinica model

**Polja:**
```dart
id, ownerId, ownerEmail, name, address
category (nullable - za grupiranje)
wifiSsid, wifiPass, cleanerPin, reviewLink
contactOptions: Map<String, String>
createdAt: DateTime
```

---

### `lib/models/cleaning_log_model.dart` (93 linija)
**Svrha:** Zapisnik čišćenja

**Polja:**
```dart
id, unitId, ownerId, cleanerName
timestamp: DateTime
tasksCompleted: Map<String, bool>
notes: String
status: "completed" | "inspection_needed"
```

---

## 🔷 PROVIDERS

### `lib/providers/app_provider.dart` (123 linija)
**Svrha:** Global state management

**State:**
```dart
_settings: VillaSettings
_primaryColor: Color
_backgroundColor: Color
_language: String
```

**Metode:**
- `loadSettings()` - Učitaj iz Firestore
- `updateSettings()` - Spremi promjene
- `setColors()` - Promijeni temu
- `setLanguage()` - Promijeni jezik
- `translate(key)` - Dohvati prijevod

---

## 🔷 SCREENS

### 👑 `lib/screens/super_admin_screen.dart` (1881 linija) - **NOVO!**
**Svrha:** Super Admin Dashboard - SAMO za `nevenroksa@gmail.com`

**Pristup:**
- Login s `nevenroksa@gmail.com` → Super Admin Dashboard
- Login s bilo kojim drugim emailom → Regular Dashboard
- Super Admin **NE VIDI** regular dashboard module

**4 Taba:**

#### **Tab 1: OWNERS** 👥
| Funkcionalnost | Opis |
|----------------|------|
| 🔍 Search | Pretraživanje po imenu, email, tenant ID |
| 📊 Stats | Total Owners, Active, Pending, Units, Bookings |
| 🏷️ Filter | All / Active / Pending / Suspended |
| ➕ Create Owner | Tenant ID, Email, Password (generator), Display Name |
| 👁️ View Details | Svi podaci + statistika |
| 🔑 Reset Password | Novo generiranje lozinke |
| ⏸️ Toggle Status | Active ↔ Suspended |
| 🗑️ Delete Owner | Double confirmation (upiši tenant ID) |

#### **Tab 2: TABLETS** 📱
| Funkcionalnost | Opis |
|----------------|------|
| 📊 Stats | Total, Online, Offline, Current APK |
| 🟢 Online Status | Heartbeat unutar 5 minuta = Online |
| 📂 Groups | default, beta, test, production |
| 🔄 Change Group | Premjesti tablet u drugu grupu |
| Grid prikaz | Kartica za svaki tablet |

#### **Tab 3: ACTIVITY LOG** 📝
| Akcija | Ikona | Boja |
|--------|-------|------|
| CREATE_OWNER | person_add | Green |
| DELETE_OWNER | person_remove | Red |
| SUSPEND_OWNER | block | Orange |
| ACTIVATE_OWNER | check_circle | Green |
| RESET_PASSWORD | key | Blue |
| PUSH_APK_UPDATE | system_update | Purple |

#### **Tab 4: APK UPDATES** 🚀
| Funkcionalnost | Opis |
|----------------|------|
| Current Version | Prikaz trenutne verzije |
| Push Update | Nova verzija + URL + Target Group |
| Force Update | Checkbox za auto-install |
| Tablets by Group | Pregled koliko tableta po grupi |
| Affected Count | Broj tableta koji će primiti update |

**Firestore kolekcije korištene:**
```
/tenant_links/{tenantId}     - Owner podaci
/tablets/{deviceId}          - Registrirani tableti
/admin_logs/{logId}          - Activity log
/app_config/tablet_app       - APK verzija config
```

---

### `lib/screens/dashboard_screen.dart` (1295 linija)
**Svrha:** Live Monitor - pregled svih jedinica

**Funkcionalnosti:**
- Grid/List view toggle
- Prikaz po zonama (kategorijama)
- Check-in/Check-out za danas i sutra
- Cleaning status indikator (🧹 Needs Cleaning)
- Quick actions (Edit, Print, Delete)
- Real-time stream iz Firestore

**Widgets:**
- `LiveMonitorView` - Glavni prikaz
- Zone headers sa statistikom
- Unit cards s guest info

---

### `lib/screens/booking_screen.dart` (1344 linija)
**Svrha:** Booking Calendar

**Funkcionalnosti:**
- Višemjesečni kalendar prikaz
- Drag & drop premještanje rezervacija
- Quick-create booking (drag na prazan dan)
- Period filter (60, 90, ALL dana)
- Zone filter dropdown
- Print opcije (8 PDF tipova)
- Fullscreen mode

**Komponente:**
- Period selector
- Zone dropdown
- Print history dialog
- Calendar grid (koristi booking_calendar.dart)

---

### `lib/screens/settings_screen.dart` (1395 linija)
**Svrha:** Postavke aplikacije

**Sekcije:**
1. **Owner Info** - Ime, email, telefon, firma
2. **Zones** - Dodaj/uredi/briši kategorije
3. **Check-in/out Times** - Globalna vremena
4. **Security PINs** - Cleaner PIN, Hard Reset PIN
5. **Personalization** - Jezik, boje, tema

**Features:**
- Luxury & Neon color palettes
- Dark/Light theme toggle
- Language dropdown (11 jezika)
- Save per section

---

### `lib/screens/digital_book_screen.dart` (1783 linija)
**Svrha:** CMS za tablet sadržaj

**Sekcije:**
1. **Welcome Message** - 11 jezika + AI translate
2. **House Rules** - 11 jezika + AI translate
3. **Emergency Contact** - QR kodovi za kontakt
4. **Tablet Timers** - Welcome/Rules display duration
5. **Cleaner Checklist** - Lista zadataka
6. **AI Knowledge Base** - 4 kontekst polja

**Features:**
- AI auto-translate (Gemini via Cloud Function)
- Per-language editing
- Timer sliders (10-30s, 20-60s)
- Dynamic checklist builder

---

### `lib/screens/login_screen.dart` (133 linija)
**Svrha:** Firebase Auth login

**Features:**
- Email/Password login
- Error handling
- Loading state
- Responsive design

---

### `lib/screens/tenant_setup_screen.dart` (414 linija)
**Svrha:** Onboarding za novog korisnika

**Steps:**
1. Owner Info (ime, prezime, email, telefon)
2. Company Info (opciono)
3. First Unit setup

---

### `lib/screens/analytics_screen.dart` (297 linija)
**Svrha:** Placeholder za statistiku

**Status:** 🚧 Coming Soon

---

### `lib/screens/gallery_screen.dart` (789 linija)
**Svrha:** Placeholder za galeriju slika

**Status:** 🚧 Coming Soon

---

## 🔷 SERVICES

### `lib/services/pdf_service.dart` (966 linija)
**Svrha:** PDF generiranje (10 tipova)

**PDF Tipovi:**
1. `printEvisitorForm()` - Lista skeniranih gostiju
2. `printHouseRulesSigned()` - Potpisana pravila
3. `printCleaningReport()` - Izvještaj čišćenja
4. `printUnitSchedule()` - Raspored jedinice (30 dana)
5. `printTextualList()` - Tekstualni pregled
6. `printTextualListAnonymous()` - Anonimizirana verzija
7. `printCleaningSchedule()` - Raspored čišćenja
8. `printGraphicView()` - Grafički kalendar
9. `printGraphicViewAnonymous()` - Anonimizirana verzija
10. `printBookingHistory()` - Arhiva rezervacija

**Koristi:** `pdf` + `printing` packages

---

### `lib/services/booking_service.dart` (375 linija)
**Svrha:** CRUD operacije za rezervacije

**Metode:**
```dart
getBookingsStream() → Stream<List<Booking>>
addBooking(booking) → Future<void>
updateBooking(booking) → Future<void>
deleteBooking(id) → Future<void>
moveBooking(id, newStart, newEnd) → Future<void>
getGuestsOnce(bookingId) → Future<List<Map>>
```

---

### `lib/services/units_service.dart` (350 linija)
**Svrha:** CRUD operacije za jedinice

**Metode:**
```dart
getUnitsStream() → Stream<List<Unit>>
saveUnit(unit) → Future<void>
deleteUnit(id) → Future<void>
generateUnitId() → Future<String>  // Auto-generates ID
```

**ID Format:** `{OWNER_INITIALS}-{CATEGORY}-{NAME}`

---

### `lib/services/settings_service.dart` (67 linija)
**Svrha:** Settings CRUD

**Metode:**
```dart
getSettingsStream() → Stream<VillaSettings>
saveSettings(settings) → Future<void>
```

---

### `lib/services/cleaning_service.dart` (72 linija)
**Svrha:** Cleaning logs CRUD

**Metode:**
```dart
getLogsStream(unitId) → Stream<List<CleaningLog>>
getLastLog(unitId) → Future<CleaningLog?>
addLog(log) → Future<void>
```

---

### `lib/services/auth_service.dart` (28 linija)
**Svrha:** Auth helper

**Metode:**
```dart
signOut() → Future<void>
getCurrentUser() → User?
```

---

## 🔷 WIDGETS

### `lib/widgets/booking_calendar.dart` (1355 linija)
**Svrha:** Drag & Drop kalendar widget

**Features:**
- Multi-month horizontal scroll
- Drag to move bookings
- Drag to resize bookings
- Click to edit
- Visual booking bars with colors
- Responsive cell sizing
- Fullscreen mode support

**Callbacks:**
```dart
onBookingTap(booking)
onBookingMoved(booking, newStart, newEnd)
onQuickCreate(unitId, date)
```

---

### `lib/widgets/unit_widgets.dart` (1426 linija)
**Svrha:** Unit-related widgets

**Widgets:**
1. `EditUnitDialog` - Quick edit dialog (WiFi, Review Link)
2. `UnitStatusMixin` - Shared logic (delete, print menu)
3. `UnitStatusCard` - Grid card view
4. `UnitListItem` - List item view
5. `UnitDialog` - Full CRUD dialog
6. `PrintOptionRow` - Helper za print menu

**Print Menu (4 opcije):**
- eVisitor List
- Signed House Rules
- Last Cleaning Report
- Unit Schedule (30 Days)

---

## 🔷 CLOUD FUNCTIONS

### `functions/index.js` (681 linija)
**Svrha:** Backend logic (Node.js 18)

**Funkcije (9):**

| Funkcija | Opis | Pristup |
|----------|------|---------|
| `createOwner` | Kreira novog vlasnika | Super Admin only |
| `deleteOwner` | Briše vlasnika | Super Admin only |
| `resetOwnerPassword` | Resetira lozinku | Super Admin only |
| `toggleOwnerStatus` | Active/Suspended toggle | Super Admin only |
| `linkTenantId` | Aktivira tenant account | Public |
| `translateText` | AI prijevod (Gemini) | Authenticated |
| `translateBatch` | Batch prijevod | Authenticated |
| `registerTablet` | Registrira novi tablet | Authenticated |
| `tabletHeartbeat` | Tablet ping (online status) | Authenticated |

**Super Admin Check:**
```javascript
if (!request.auth || request.auth.token.email !== 'nevenroksa@gmail.com') {
  throw new HttpsError('permission-denied', 'Super Admin only');
}
```

**Region:** `europe-west3`  
**Secrets:** `GEMINI_API_KEY`

---

## 🔷 FIRESTORE SCHEMA

### Postojeće kolekcije:
```
/settings/{tenantId}           - Owner postavke (30+ polja)
/units/{unitId}                - Smještajne jedinice
/bookings/{bookingId}          - Rezervacije
/bookings/{id}/guests/{guestId} - Skenirani gosti (subcollection)
/signatures/{signatureId}      - Potpisi pravila
/cleaning_logs/{logId}         - Zapisnici čišćenja
/tenant_links/{tenantId}       - Owner<->Firebase UID link
```

### 👑 NOVE kolekcije (Super Admin):
```
/tablets/{deviceId}
├── deviceId: String
├── unitId: String
├── ownerId: String
├── ownerName: String
├── unitName: String
├── appVersion: String           # "1.0.0"
├── lastHeartbeat: Timestamp     # Zadnji ping
├── group: String                # "default" | "beta" | "test" | "production"
├── model: String                # "Samsung Tab A8"
├── osVersion: String            # "Android 13"
├── pendingUpdate: Boolean
├── pendingVersion: String
├── pendingApkUrl: String
└── forceUpdate: Boolean

/admin_logs/{logId}
├── action: String               # "CREATE_OWNER", "DELETE_OWNER", etc.
├── targetId: String             # Tenant ID
├── targetEmail: String
├── details: String
├── timestamp: Timestamp
└── performedBy: String          # "Super Admin"

/app_config/tablet_app
├── currentVersion: String       # "1.0.0"
├── apkUrl: String               # Download URL
├── updatedAt: Timestamp
├── targetGroup: String          # "all" | "beta" | etc.
└── forceUpdate: Boolean
```

---

## 🔷 CONFIG FILES

### `firebase.json` (56 linija)
```json
{
  "hosting": {
    "public": "build/web",
    "headers": [
      // CORS for fonts
      // Cache control for images
      // No-cache for index.html
    ]
  },
  "functions": {
    "source": "functions",
    "region": "europe-west3"
  }
}
```

### `pubspec.yaml` (57 linija)
**Dependencies:**
- Flutter SDK >=3.2.0
- firebase_core, firebase_auth, cloud_firestore, firebase_storage, cloud_functions
- provider (state management)
- go_router (navigation)
- pdf, printing (PDF generation)
- google_fonts, animate_do (UI)
- intl (formatting)
- http, file_picker, image_network

---

# 📊 STATISTIKA

| Kategorija | Fajlova | Linija |
|------------|---------|--------|
| **Screens** | 9 | 9,331 |
| **Widgets** | 2 | 2,781 |
| **Services** | 6 | 1,858 |
| **Models** | 4 | 658 |
| **Config** | 2 | 1,902 |
| **Providers** | 1 | 123 |
| **Main** | 2 | 650 |
| **Functions** | 1 | 681 |
| **UKUPNO** | **27** | **~18,000** |

---

# 🔐 SIGURNOSNI MODEL

## User Roles:

| Role | Email | Pristup |
|------|-------|---------|
| **Super Admin** | `nevenroksa@gmail.com` | Super Admin Dashboard SAMO |
| **Owner** | Bilo koji drugi | Regular Dashboard (tenant-isolated) |
| **Cleaner** | N/A (tablet app) | PIN-based pristup |

## Auth Flow:

```
┌─────────────────────────────────────────────────────┐
│                    LOGIN                            │
└─────────────────────────────────────────────────────┘
                        │
                        ▼
           ┌────────────────────────┐
           │  email == superAdmin?  │
           └────────────────────────┘
                  │           │
                 YES          NO
                  │           │
                  ▼           ▼
    ┌──────────────────┐  ┌─────────────────────┐
    │ SuperAdminScreen │  │ Check Custom Claims │
    │   (Owners,       │  │   role == 'admin'?  │
    │   Tablets,       │  └─────────────────────┘
    │   APK Updates)   │         │         │
    └──────────────────┘        YES        NO
                                 │         │
                                 ▼         ▼
                      ┌──────────────┐ ┌──────────────┐
                      │  Dashboard   │ │ TenantSetup  │
                      │  (tenant     │ │ (Onboarding) │
                      │   isolated)  │ └──────────────┘
                      └──────────────┘
```

---

# ✅ ZDRAVLJE PROJEKTA

| Aspekt | Status | Napomena |
|--------|--------|----------|
| **Struktura** | ✅ Čista | MVC pattern, odvojeni slojevi |
| **Null Safety** | ✅ Da | Sound null safety |
| **State Management** | ✅ Provider | Jednostavno i efikasno |
| **Navigation** | ✅ GoRouter | URL-based, refresh-safe |
| **Translations** | ✅ 100% | 11 jezika, 130+ ključeva |
| **Error Handling** | ✅ Dobro | Try-catch, mounted checks |
| **Firebase Security** | ✅ Rules | Tenant isolation + Super Admin |
| **PDF Generation** | ✅ 10 tipova | Kompletno |
| **Super Admin** | ✅ Kompletno | Owner CRUD, Tablets, APK Updates |
| **Responsive** | ⚠️ Djelomično | Web-first, mobile OK |
| **Deprecation Warnings** | ✅ 0 | Flutter 3.32+ kompatibilno |

---

# 📱 TABLET APP INTEGRACIJA

## Potrebne Cloud Functions za Tablet:

| Funkcija | Status | Opis |
|----------|--------|------|
| `registerTablet` | ✅ Postoji | Registrira tablet u `/tablets` |
| `tabletHeartbeat` | ✅ Postoji | Ping svakih 60s za online status |

## Tablet → Firestore komunikacija:

```
TABLET STARTUP:
1. Call registerTablet(deviceId, unitId)
2. Read /settings/{tenantId}
3. Read /units/{unitId}

HEARTBEAT (every 60s):
1. Call tabletHeartbeat(deviceId)
2. Check pendingUpdate flag
3. If true → download new APK

GUEST SCAN:
1. Write to /bookings/{id}/guests
2. Update booking.is_scanned = true

SIGNATURE:
1. Upload to Storage
2. Write to /signatures

---

# 🎯 ZAKLJUČAK

**VillaOS Admin Panel** je production-ready web aplikacija s:

### Core Features:
- ✅ Kompletnim CRUD operacijama
- ✅ Multi-tenant arhitekturom
- ✅ 11-jezičnom podrškom
- ✅ 10 PDF tipova
- ✅ Real-time Firestore sync
- ✅ Drag & drop kalendar
- ✅ Cloud Functions backend

### 👑 Super Admin Features (NOVO):
- ✅ Owner Management (Create, Edit, Delete, Suspend)
- ✅ Tablet Monitoring (Online/Offline status)
- ✅ Tablet Groups (beta, test, production)
- ✅ Mass APK Updates po grupama
- ✅ Force Update opcija
- ✅ Activity Log (sve akcije zapisane)

**Spremno za:** 
- ✅ Produkcijsko korištenje
- ✅ Tablet app integraciju
- ✅ Multi-owner SaaS deployment

---

*Analiza generirana: Januar 2026* 
---

## ⛔️ Licenca i Autorska Prava

**© Copyright 2024-2025 nroxa92. Sva prava pridržana.**

Ovaj softver i povezani izvorni kod su **intelektualno vlasništvo autora**. Kod je javno dostupan na GitHubu isključivo u svrhu **prezentacije (portfolio)** i **nije otvorenog koda (Not Open Source)**.

### Strogo je zabranjeno:

1. ❌ Kopiranje, umnožavanje ili distribucija koda u bilo kojem obliku
2. ❌ Korištenje ovog projekta ili njegovih dijelova u komercijalne ili privatne svrhe
3. ❌ Modificiranje izvornog koda ili stvaranje izvedenih djela (derivative works)
4. ❌ Reverse engineering ili dekompilacija

> ⚠️ **Bilo kakvo neovlašteno korištenje smatrat će se kršenjem autorskih prava i bit će poduzete odgovarajuće pravne mjere.**

---

## 📬 Kontakt

Za upite vezane uz ovaj projekt:
- **GitHub**: [@nroxa92](https://github.com/nroxa92)
- **E-Mail**: nevenroksa@gmail.com

---
---

**VillaOS** - Simplifying Property Management 🏰