# Vesta Lumina - Admin Panel

[![Version](https://img.shields.io/badge/version-2.1.0-blue.svg)](https://github.com/nroxa92/admin_panel)
[![Platform](https://img.shields.io/badge/platform-Web-orange.svg)](https://flutter.dev/web)
[![Flutter](https://img.shields.io/badge/Flutter-3.32+-02569B.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-Proprietary-red.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/tests-passing-brightgreen.svg)](test/)

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

## 📋 Sažetak

Admin Panel je web aplikacija (Flutter Web) za upravljanje kratkoročnim iznajmljivanjem nekretnina. Omogućuje vlasnicima potpunu kontrolu nad:

- 📅 **Booking management** s drag-and-drop kalendarom
- 🏠 **Unit management** (smještajne jedinice)
- 📊 **Analytics & Revenue tracking**
- 🧹 **Cleaning logs** iz Tablet Terminala
- 📄 **PDF export** za eVisitor prijave
- 📆 **iCal sync** s Airbnb/Booking.com
- 🎨 **White-label** multi-tenant arhitektura

---

## 🏗️ Arhitektura Sustava

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
│  │  │Analytics│  │Calendar │  │ Manager │  │  Logs   │  │& Config │  │ │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘  └─────────┘  │ │
│  │                                                                     │ │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  │ │
│  │  │ Digital │  │ Gallery │  │  iCal   │  │   PDF   │  │  Super  │  │ │
│  │  │  Book   │  │  View   │  │ Export  │  │ Export  │  │  Admin  │  │ │
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

---

## 🎭 Multi-Tenant Arhitektura

| Razina | Uloga | Pristup |
|--------|-------|---------|
| **Super Admin** | Sistemski administrator | • Svi vlasnici<br>• White-label konfiguracija<br>• System settings<br>• Tablet management<br>• Notifications<br>• Retail settings |
| **Brand Admin** | Partner administrator | • Vlastiti brendirani vlasnici<br>• Ograničene postavke |
| **Owner** | Vlasnik smještaja | • Vlastite jedinice<br>• Bookings<br>• Cleaning logs<br>• Analytics |
| **Cleaner** | Čistač | • PIN pristup preko Tablet Terminala<br>• Task checklist<br>• Problem reporting |

---

## 🚀 Glavni Features

### 1. 📅 Booking Management

**Booking Calendar**
- Interactive drag-and-drop kalendar
- Multi-unit prikaz
- Booking creation/editing
- Check-in/out status tracking
- Guest count tracking

**Booking Details**
- Guest name, email, phone
- Check-in/out dates i vremena
- Number of guests
- Booking status (pending, confirmed, checked-in, completed, cancelled)
- Notes
- Connection to guest data from Tablet Terminal

**iCal Integration**
- **Export**: Generate iCal URL za svaku jedinicu
- **Import**: Parse iCal podataka iz Airbnb/Booking.com
- Format: VCALENDAR s VEVENT-ima
- Timezone support: Europe/Zagreb
- Auto-sync capabilities

### 2. 🏠 Unit Management

- Unit CRUD operations
- Configuration:
  - Unit name, address
  - WiFi SSID & password
  - Check-in/out times
  - Capacity
  - House rules content
  - AI knowledge base
  - Cleaner checklist
  - Screensaver images

### 3. 📄 PDF Export

**eVisitor Forms**
```dart
printEvisitorForm(
  unitName: String,
  guestData: List<Map<String, dynamic>>
)
```

**Extracted fields from MRZ:**
- Guest name (firstName + lastName)
- Date of birth
- Nationality
- Document type & number
- Sex
- Place of birth & country
- Issuing country
- Expiry date
- Address, residence city/country

**Booking Schedules**
- Text list (full / anonymous)
- Graphic calendar
- Cleaning schedule
- Multi-page PDF generation
- Professional formatting

### 4. 📊 Analytics & Revenue

**Dashboard KPIs:**
- Total revenue
- Occupancy rate
- Average booking value
- Number of bookings

**Analytics Screen:**
- Revenue over time (charts)
- Booking trends
- Occupancy heatmap
- Unit performance comparison

**Revenue Service:**
- Revenue calculation per unit
- Period-based filtering
- Revenue projections

### 5. 🧹 Cleaning Management

**Cleaning Logs** (from Tablet Terminal):
- Timestamp
- Unit name
- Cleaner name
- Completed tasks
- Notes
- Photo documentation (optional)
- Connection to booking

**Checklist Configuration:**
- Define custom tasks per owner
- Default task list fallback
- Translation support

### 6. 🎨 White-Label System

**Super Admin Controls:**
```dart
super_admin_white_label.dart:
- Create/edit Brand Admins
- Configure branding (logo, colors, domain)
- Manage licenses
- Set feature limits per brand
```

**Brand Hierarchy:**
```
Super Admin
  └─ Brand Admin 1
      ├─ Owner A
      ├─ Owner B
      └─ Owner C
  └─ Brand Admin 2
      ├─ Owner D
      └─ Owner E
```

### 7. 🔧 Super Admin Features

**Super Admin Screens:**
- `super_admin_screen.dart` - Overview
- `super_admin_settings.dart` - Global settings
- `super_admin_tablets.dart` - Tablet management
- `super_admin_white_label.dart` - Brand management
- `super_admin_retail.dart` - Retail configuration
- `super_admin_notifications.dart` - System notifications
- `super_admin_exit.dart` - Exit dialog

**Capabilities:**
- View all owners
- Platform statistics
- System health monitoring
- Tablet monitoring
- Notification broadcasting

---

## 📁 Project Structure

```
admin_panel/
├── lib/
│   ├── main.dart              # Application entry point
│   ├── firebase_options.dart  # Firebase configuration
│   │
│   ├── config/                # Configuration
│   │   ├── app_config.dart           # App constants
│   │   ├── firestore_fields.dart     # Field name constants
│   │   ├── theme.dart                # App theme
│   │   └── translations/             # i18n (11 languages)
│   │       ├── translations.dart
│   │       ├── lang_en.dart          # English
│   │       ├── lang_hr.dart          # Croatian
│   │       ├── lang_de.dart          # German
│   │       ├── lang_it.dart          # Italian
│   │       ├── lang_sl.dart          # Slovenian
│   │       ├── lang_fr.dart          # French
│   │       ├── lang_es.dart          # Spanish
│   │       ├── lang_pl.dart          # Polish
│   │       ├── lang_cs.dart          # Czech
│   │       ├── lang_sk.dart          # Slovak
│   │       └── lang_hu.dart          # Hungarian
│   │
│   ├── models/                # Data models
│   │   ├── booking_model.dart        # Booking data
│   │   ├── unit_model.dart           # Unit data
│   │   ├── cleaning_log_model.dart   # Cleaning log
│   │   └── settings_model.dart       # Settings
│   │
│   ├── repositories/          # Data layer
│   │   ├── base_repository.dart      # Base repository class
│   │   ├── booking_repository.dart   # Booking CRUD
│   │   └── units_repository.dart     # Units CRUD
│   │
│   ├── services/              # Business logic
│   │   ├── auth_service.dart              # Authentication
│   │   ├── booking_service.dart           # Booking operations
│   │   ├── units_service.dart             # Unit operations
│   │   ├── cleaning_service.dart          # Cleaning logs
│   │   ├── calendar_service.dart          # iCal export/import
│   │   ├── pdf_service.dart               # PDF generation
│   │   ├── analytics_service.dart         # Analytics
│   │   ├── revenue_service.dart           # Revenue calculation
│   │   ├── settings_service.dart          # Settings
│   │   ├── super_admin_service.dart       # Super admin ops
│   │   ├── brand_service.dart             # White-label
│   │   ├── onboarding_service.dart        # User onboarding
│   │   ├── offline_queue_service.dart     # Offline sync
│   │   ├── connectivity_service.dart      # Network status
│   │   ├── cache_service.dart             # Caching
│   │   ├── security_service.dart          # Security
│   │   ├── health_service.dart            # System health
│   │   ├── error_service.dart             # Error handling
│   │   ├── app_check_service.dart         # Firebase App Check
│   │   └── performance_service.dart       # Performance
│   │
│   ├── providers/             # State management
│   │   └── app_provider.dart
│   │
│   ├── screens/               # UI screens
│   │   ├── login_screen.dart             # Login
│   │   ├── tenant_setup_screen.dart      # Initial setup
│   │   ├── dashboard_screen.dart         # Dashboard
│   │   ├── booking_screen.dart           # Bookings & calendar
│   │   ├── digital_book_screen.dart      # Digital book
│   │   ├── gallery_screen.dart           # Image gallery
│   │   ├── settings_screen.dart          # Settings
│   │   ├── analytics_screen.dart         # Analytics overview
│   │   ├── analytics/
│   │   │   ├── analytics_screen.dart     # Detailed analytics
│   │   │   └── revenue_screen.dart       # Revenue analytics
│   │   └── super_admin_*.dart            # Super admin screens
│   │
│   ├── widgets/               # Reusable widgets
│   │   ├── booking_calendar.dart
│   │   ├── system_notification_banner.dart
│   │   ├── unit_widgets.dart
│   │   └── analytics/
│   │       ├── booking_chart.dart
│   │       ├── occupancy_chart.dart
│   │       ├── stat_card.dart
│   │       └── upcoming_bookings_card.dart
│   │
│   └── utils/
│       └── performance_utils.dart
│
├── test/                      # Unit & integration tests
│   ├── all_tests.dart
│   ├── config/
│   │   └── app_config_test.dart
│   ├── models/
│   │   ├── booking_model_test.dart
│   │   └── unit_model_test.dart
│   ├── repositories/
│   │   └── booking_repository_test.dart
│   ├── services/
│   │   ├── auth_service_test.dart
│   │   ├── cache_service_test.dart
│   │   ├── revenue_service_test.dart
│   │   └── security_service_test.dart
│   ├── widgets/
│   │   └── login_screen_test.dart
│   ├── integration/
│   │   └── auth_flow_test.dart
│   └── helpers/
│       └── test_helpers.dart
│
├── web/                       # Web-specific files
│   ├── index.html
│   ├── manifest.json
│   └── favicon.png
│
├── assets/                    # Assets
│   └── icon/
│       └── icon.png          # Web app icon
│
├── pubspec.yaml              # Dependencies
├── analysis_options.yaml     # Linting rules
├── firebase.json             # Firebase hosting config
├── firestore.rules           # Firestore security rules
├── firestore.indexes.json    # Firestore indexes
├── storage.rules             # Storage security rules
├── .firebaserc               # Firebase project config
└── LICENSE                   # Proprietary license
```

---

## 🛠️ Technology Stack

| Kategorija | Tehnologija | Verzija |
|-----------|-------------|---------|
| **Framework** | Flutter Web | 3.32+ |
| **Language** | Dart | 3.5+ |
| **State Management** | Provider | 6.1+ |
| **Navigation** | GoRouter | 14.6+ |
| **UI Libraries** | Google Fonts, Animate Do, Flutter Markdown | Latest |
| **Backend** | Firebase Suite | Latest |
| **PDF Generation** | pdf + printing | 3.10+ / 5.11+ |
| **File Handling** | file_picker, image_network | Latest |
| **Networking** | http | 1.2+ |
| **Local Storage** | Shared Preferences | 2.2+ |
| **Monitoring** | Sentry Flutter | 8.0+ |
| **Connectivity** | Connectivity Plus | 6.0+ |

---

## 🔧 Firebase Integration

### Firestore Collections

```
owners/{ownerId}/
  ├── units/{unitId}/
  │   ├── bookings/{bookingId}/
  │   │   ├── guestName: string
  │   │   ├── startDate: timestamp
  │   │   ├── endDate: timestamp
  │   │   ├── guestCount: number
  │   │   ├── status: string
  │   │   ├── guests: Array<Guest>  // From tablet OCR
  │   │   └── ...
  │   │
  │   ├── house_rules/
  │   │   └── content: Map<lang, string>
  │   │
  │   └── ai_knowledge/
  │       └── qa_pairs: Array<{q, a}>
  │
  ├── cleaning_logs/{logId}/
  │   ├── timestamp: timestamp
  │   ├── unitId: string
  │   ├── cleanerName: string
  │   ├── tasks: Map<task, bool>
  │   ├── notes: string
  │   └── bookingId: string
  │
  └── settings/
      ├── cleanerChecklist: Array<string>
      ├── wifiSSID: string
      ├── wifiPassword: string
      └── ...

brands/{brandId}/
  ├── name: string
  ├── logo: string
  ├── colors: Map
  ├── domain: string
  └── owners: Array<ownerId>

settings/
  └── {ownerId}/
      └── ...

app_config/
  └── api_keys/
      ├── gemini_api_key: string
      ├── Maps_api_key: string
      └── gemini_model: string
```

### Firebase Storage

```
owners/{ownerId}/
  ├── signatures/{bookingId}_{guestIndex}.png
  ├── screensaver/{image}.jpg
  └── cleaning_photos/{logId}_{index}.jpg
```

### Firebase Functions

```
functions/
  └── (Server-side logic as needed)
```

---

## 🌐 Supported Languages

| Language | Code | Status |
|----------|------|--------|
| English | `en` | ✅ Complete |
| Croatian | `hr` | ✅ Complete |
| German | `de` | ✅ Complete |
| Italian | `it` | ✅ Complete |
| Slovenian | `sl` | ✅ Complete |
| French | `fr` | ✅ Complete |
| Spanish | `es` | ✅ Complete |
| Polish | `pl` | ✅ Complete |
| Czech | `cs` | ✅ Complete |
| Slovak | `sk` | ✅ Complete |
| Hungarian | `hu` | ✅ Complete |

---

## 📊 Data Flow

### Tablet Terminal → Admin Panel (Upstream)

Tablet šalje u Firestore:
- Scanned guest data (OCR results)
- Digital signatures (Firebase Storage)
- Cleaning completion logs
- Guest check-in status updates
- Error reports (Sentry)

Admin Panel čita iz Firestore:
- `owners/{ownerId}/units/{unitId}/bookings/{bookingId}/guests`
- `owners/{ownerId}/cleaning_logs/{logId}`
- `owners/{ownerId}/units/{unitId}/bookings/{bookingId}/status`

### Admin Panel → Tablet Terminal (Downstream)

Admin Panel piše u Firestore:
- House rules content
- AI knowledge base
- Cleaner checklist
- WiFi credentials
- Screensaver images
- Booking data

Tablet čita iz Firestore:
- `owners/{ownerId}/units/{unitId}/house_rules`
- `owners/{ownerId}/units/{unitId}/ai_knowledge`
- `settings/{ownerId}/cleanerChecklist`
- `owners/{ownerId}/units/{unitId}/bookings/{bookingId}`

---

## 🔒 Security

| Layer | Implementation |
|-------|----------------|
| **Authentication** | Firebase Auth (email/password) |
| **Authorization** | Firestore Security Rules (role-based) |
| **Data Encryption** | TLS 1.3 in transit, AES-256 at rest |
| **App Check** | Optional (can be enabled) |
| **Security Service** | Input validation, XSS prevention |
| **GDPR Compliance** | Data retention policies |

### Firestore Security Rules

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Owner data - only accessible by owner
    match /owners/{ownerId}/{document=**} {
      allow read, write: if request.auth != null && 
                            request.auth.uid == ownerId;
    }
    
    // Super admin - full access
    match /{document=**} {
      allow read, write: if request.auth != null && 
                            get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'super_admin';
    }
  }
}
```

---

## 🐛 Error Handling & Monitoring

- **Sentry**: Crash reporting i error tracking
- **Error Service**: Centralized error handling
- **Health Service**: System health monitoring
- **Performance Service**: Performance tracking
- **Connectivity Service**: Network status monitoring
- **Offline Queue**: Offline operation queueing

---

## 🧪 Testing

```
test/
├── Unit Tests
│   ├── Models
│   ├── Repositories
│   └── Services
│
├── Widget Tests
│   └── Screens
│
├── Integration Tests
│   └── User flows
│
└── Test Helpers
```

**Test Coverage:**
- 138+ passing tests
- Models, repositories, services
- Widget tests for key screens
- Integration tests for critical flows

---

## 📦 Installation & Deployment

### Local Development

```bash
# Install dependencies
flutter pub get

# Run web app
flutter run -d chrome

# Build for production
flutter build web --release
```

### Firebase Deployment

```bash
# Deploy to Firebase Hosting
firebase deploy --only hosting

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage
```

### Environment Setup

1. Create Firebase project
2. Enable Firestore, Auth, Storage
3. Configure `firebase.json`, `.firebaserc`
4. Add `firebase_options.dart` (via FlutterFire CLI)
5. Set up Firestore security rules
6. Create initial admin user

---

## 🔄 Workflows

### Owner Workflow

1. **Login** → Dashboard
2. **Manage Units** → Add/edit units
3. **Manage Bookings** → Drag-and-drop calendar
4. **Configure** → House rules, AI knowledge, cleaner checklist
5. **Export** → iCal for Airbnb/Booking.com
6. **View Analytics** → Revenue, occupancy
7. **Review Cleaning Logs** → From Tablet Terminal

### Super Admin Workflow

1. **Login** → Super Admin Dashboard
2. **Manage Brands** → White-label configuration
3. **View All Owners** → System overview
4. **Monitor Tablets** → Health status
5. **System Settings** → Global configuration
6. **Notifications** → Broadcast to owners

---

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.1.0 | 2026-01 | Enhanced eVisitor PDF, MRZ support, testing |
| 2.0.0 | 2025-11 | White-label system, Super Admin features |
| 1.5.0 | 2025-09 | Analytics, revenue tracking |
| 1.0.0 | 2025-07 | Initial release |

---

## 🔗 Related Components

| Component | Repository | Description |
|-----------|------------|-------------|
| **Tablet Terminal** | [tablet_terminal](https://github.com/nroxa92/tablet_terminal) | Android kiosk app for guests (Slave) |
| **Documentation** | This README | Technical documentation |

---

## 👨‍💻 Contact

**Developer:** Neven Roksa  
**Email:** nevenroksa@gmail.com  
**GitHub:** [@nroxa92](https://github.com/nroxa92)

---

<p align="center">
  <strong>Vesta Lumina System</strong><br>
  <em>Enterprise Property Management for Short-Term Rentals</em><br><br>
  © 2024-2026 Neven Roksa. All Rights Reserved.
</p>
