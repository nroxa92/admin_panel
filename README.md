# 🏠 VillaOS Admin Panel v2.0

> **Professional Property Management System for Villa & Apartment Rentals**  
> Flutter Web + Firebase Backend + Super Admin Console

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.32+-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase)
![Languages](https://img.shields.io/badge/Languages-11-green)
![Lines](https://img.shields.io/badge/Lines_of_Code-19,543-orange)

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Project Structure](#-project-structure)
- [Firebase Architecture](#-firebase-architecture)
- [Firestore Collections](#-firestore-collections)
- [Cloud Functions](#-cloud-functions)
- [Security Rules](#-security-rules)
- [Installation](#-installation)
- [Deployment](#-deployment)
- [Translations](#-translations)

---

## 🎯 Overview

VillaOS Admin Panel is a comprehensive property management system designed for villa and apartment rental businesses. It provides:

- **Web Admin Panel** - Central control for property owners
- **Super Admin Console** - Multi-tenant management (master@admin.com)
- **Tablet Integration** - On-site guest check-in via Android tablets
- **Multi-language Support** - 11 languages out of the box

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        VillaOS ECOSYSTEM                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐      │
│  │  WEB PANEL   │    │ SUPER ADMIN  │    │   TABLETS    │      │
│  │   (Owners)   │    │  (Master)    │    │  (On-site)   │      │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘      │
│         │                   │                   │               │
│         └───────────────────┼───────────────────┘               │
│                             │                                    │
│                    ┌────────▼────────┐                          │
│                    │    FIREBASE     │                          │
│                    │  ┌───────────┐  │                          │
│                    │  │ Firestore │  │                          │
│                    │  │  Storage  │  │                          │
│                    │  │   Auth    │  │                          │
│                    │  │ Functions │  │                          │
│                    │  └───────────┘  │                          │
│                    └─────────────────┘                          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## ✨ Features

### 🏢 Property Management
- **Units Management** - Add/edit apartments, villas, rooms
- **Zone Categorization** - Group units by building/floor/area
- **Real-time Status** - Vacant, Check-in Expected, Occupied

### 📅 Booking System
- **Interactive Calendar** - Drag & drop bookings
- **Multi-source Support** - Booking.com, Airbnb, Private, etc.
- **Guest Management** - Contact info, guest count, notes

### 📊 Analytics Dashboard
- **Bookings Statistics** - Monthly/Yearly counts
- **Occupancy Rate** - Last 30 days calculation
- **Average Stay Duration** - Per booking analysis
- **Guest Feedback** - Ratings and reviews
- **AI Questions Log** - What guests are asking

### 🖼️ Gallery & Screensaver
- **Image Upload** - Firebase Storage integration
- **Screensaver Config** - Delay, duration, transitions
- **Multiple Effects** - Fade, Slide, Zoom, Rotate, Ken Burns

### 📝 Digital Guest Book
- **House Rules** - Multi-language support
- **Welcome Message** - Customizable per unit
- **Cleaner Checklist** - Task management
- **AI Knowledge Base** - Concierge, Tech, Guide contexts

### 🔐 Super Admin Console
- **Owner Management** - Create/disable tenant accounts
- **Tablet Management** - Remote device monitoring
- **APK Deployment** - OTA updates for tablets
- **System Notifications** - Broadcast to owners
- **Activity Logs** - Audit trail

---

## 📁 Project Structure

```
villa_admin/                          # Root (19,543 lines total)
├── lib/                              # Flutter source code
│   ├── main.dart                (629)  # App entry, AuthWrapper routing
│   │
│   ├── config/                        # Configuration
│   │   ├── translations.dart  (2,122) # 🌍 11 languages, 168 keys
│   │   └── theme.dart          (143)  # 🎨 Theme definitions
│   │
│   ├── models/                  (341)  # Data models
│   │   ├── booking_model.dart  (123)  # 📅 Reservation model
│   │   ├── unit_model.dart     (125)  # 🏠 Property unit model
│   │   └── cleaning_log_model.dart (93) # 🧹 Cleaning records
│   │
│   ├── providers/                     # State management
│   │   └── app_provider.dart   (123)  # 🔄 Global app state
│   │
│   ├── screens/             (10,520)  # UI Screens
│   │   ├── dashboard_screen.dart    (1,270) # 📊 Main dashboard
│   │   ├── booking_screen.dart      (1,344) # 📅 Booking management
│   │   ├── digital_book_screen.dart (1,783) # 📖 Guest book content
│   │   ├── settings_screen.dart     (1,395) # ⚙️ Owner settings
│   │   ├── gallery_screen.dart        (885) # 🖼️ Screensaver gallery
│   │   ├── analytics_screen.dart      (444) # 📈 Statistics & insights
│   │   ├── login_screen.dart          (133) # 🔑 Authentication
│   │   ├── tenant_setup_screen.dart   (414) # 🆕 New tenant onboarding
│   │   ├── super_admin_screen.dart    (854) # 👑 Owner management
│   │   ├── super_admin_tablets.dart (1,037) # 📱 Device management
│   │   └── super_admin_notifications.dart (961) # 📢 Broadcasts
│   │
│   ├── services/              (1,858)  # Business logic
│   │   ├── pdf_service.dart    (966)  # 📄 PDF generation (10 types)
│   │   ├── booking_service.dart (375) # 📅 Booking CRUD
│   │   ├── units_service.dart  (350)  # 🏠 Units CRUD
│   │   ├── settings_service.dart (67) # ⚙️ Settings management
│   │   ├── cleaning_service.dart (72) # 🧹 Cleaning logs
│   │   └── auth_service.dart    (28)  # 🔐 Authentication
│   │
│   └── widgets/               (3,068)  # Reusable components
│       ├── unit_widgets.dart  (1,426) # 🏠 Unit cards & dialogs
│       ├── booking_calendar.dart (1,355) # 📅 Calendar widget
│       └── system_notification_banner.dart (287) # 📢 Notifications
│
├── functions/                   (739)  # Cloud Functions
│   └── index.js                (739)  # ☁️ 10 serverless functions
│
├── firestore.rules             (375)  # 🔐 Security rules
├── storage.rules                      # 📦 Storage security
├── firebase.json                      # ⚙️ Firebase config
└── pubspec.yaml                       # 📦 Dependencies
```

---

## 🔥 Firebase Architecture

### Authentication

```
┌─────────────────────────────────────────────────────────────────┐
│                    AUTHENTICATION FLOW                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  User Login (Email/Password)                                     │
│       │                                                          │
│       ▼                                                          │
│  ┌─────────────────────────────────────────┐                    │
│  │        Firebase Authentication          │                    │
│  │  ┌─────────────────────────────────┐   │                    │
│  │  │       Custom Claims (JWT)        │   │                    │
│  │  │  ┌─────────────────────────────┐ │   │                    │
│  │  │  │ ownerId: "TENANT123"        │ │   │                    │
│  │  │  │ role: "owner" | "tablet"    │ │   │                    │
│  │  │  │ unitId: "unit_abc" (tablet) │ │   │                    │
│  │  │  └─────────────────────────────┘ │   │                    │
│  │  └─────────────────────────────────┘   │                    │
│  └─────────────────────────────────────────┘                    │
│       │                                                          │
│       ▼                                                          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Super Admin    │  │   Web Panel     │  │     Tablet      │ │
│  │  email check    │  │  ownerId claim  │  │  role: tablet   │ │
│  │ master@admin.com│  │  role: owner    │  │  unitId claim   │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Tenant Isolation

Every document contains `ownerId` field for multi-tenant isolation:

```javascript
// Example: Booking document
{
  id: "booking_abc123",
  ownerId: "TENANT123",      // ← Tenant isolation key
  unitId: "unit_xyz",
  guestName: "John Doe",
  startDate: Timestamp,
  endDate: Timestamp,
  status: "confirmed"
}
```

---

## 📚 Firestore Collections

### Collection Overview (17 Collections)

| # | Collection | Description | Access |
|---|------------|-------------|--------|
| 1 | `app_config` | API keys, APK version | Auth users (read), Super Admin (write) |
| 2 | `tenant_links` | Owner accounts | Super Admin only |
| 3 | `settings` | Owner preferences | Owner (own data) |
| 4 | `units` | Properties/apartments | Owner (own data) |
| 5 | `bookings` | Reservations | Owner + Tablet |
| 6 | `bookings/{id}/guests` | Guest details | Owner + Tablet |
| 7 | `signatures` | House rules signatures | Owner + Tablet |
| 8 | `check_ins` | OCR scan events | Owner + Tablet |
| 9 | `cleaning_logs` | Cleaner reports | Owner + Tablet |
| 10 | `feedback` | Guest ratings | Owner + Tablet |
| 11 | `gallery` | Legacy gallery | Owner |
| 12 | `screensaver_images` | Tablet screensaver | Owner + Tablet |
| 13 | `ai_logs` | AI chat history | Owner + Tablet |
| 14 | `tablets` | Registered devices | Owner + Super Admin |
| 15 | `archived_bookings` | Historical data | Owner |
| 16 | `system_notifications` | Super Admin broadcasts | Super Admin → Owners |
| 17 | `apk_updates` | APK deployment | Super Admin + Tablets |
| 18 | `admin_logs` | Audit trail | Super Admin only |

### Required Indexes

| Collection | Fields | Order |
|------------|--------|-------|
| `screensaver_images` | ownerId, uploadedAt | ASC, DESC |
| `bookings` | ownerId, startDate | ASC, DESC |
| `cleaning_logs` | unitId, timestamp | ASC, DESC |
| `feedback` | ownerId, timestamp | ASC, DESC |
| `ai_logs` | ownerId, timestamp | ASC, DESC |

---

## ☁️ Cloud Functions

### Functions Overview (10 Functions)

```javascript
// functions/index.js (739 lines)

// 🔐 OWNER MANAGEMENT
exports.createOwner        // Create new tenant account
exports.disableOwner       // Disable tenant account
exports.refreshOwnerClaims // Refresh JWT claims

// 📱 TABLET MANAGEMENT  
exports.registerTablet     // Register new device
exports.deactivateTablet   // Deactivate device

// 🔄 APK DEPLOYMENT
exports.deployApkToAll     // Push update to all tablets
exports.deployApkToOwner   // Push update to owner's tablets
exports.tabletHeartbeat    // Device health monitoring

// 🌐 TRANSLATIONS
exports.translateHouseRules // Auto-translate house rules

// 🧹 MAINTENANCE
exports.cleanupOldBookings  // Archive old reservations
```

### Function Triggers

| Function | Trigger | Description |
|----------|---------|-------------|
| `createOwner` | HTTP Callable | Creates Firebase user + sets claims |
| `registerTablet` | HTTP Callable | Creates tablet user + assigns to owner |
| `translateHouseRules` | HTTP Callable | Translates via Google Translate API |
| `cleanupOldBookings` | Scheduled (weekly) | Moves old bookings to archive |
| `tabletHeartbeat` | HTTP Callable | Updates tablet status |

---

## 🔐 Security Rules

### Firestore Rules Structure

```javascript
// firestore.rules (375 lines)

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper Functions
    function isAuthenticated() { ... }
    function isSuperAdmin() { ... }      // email == 'master@admin.com'
    function isWebPanel() { ... }        // has ownerId, not tablet
    function isTablet() { ... }          // role == 'tablet'
    function isResourceOwner() { ... }   // ownerId match
    
    // Collection Rules
    match /units/{unitId} {
      allow read: if isResourceOwner() || isSuperAdmin();
      allow create: if (isWebPanel() && isRequestOwner()) || isSuperAdmin();
      allow update, delete: if (isWebPanel() && isResourceOwner()) || isSuperAdmin();
    }
    
    // ... (17 collections defined)
    
    // Catch-all: Deny everything else
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### Storage Rules

```javascript
// storage.rules

rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Screensaver images
    match /screensaver/{ownerId}/{fileName} {
      allow read: if request.auth.token.ownerId == ownerId;
      allow write: if request.auth.token.ownerId == ownerId
                   && request.auth.token.role != 'tablet';
    }
    
    // APK files (Super Admin only)
    match /apk/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.email == 'master@admin.com';
    }
  }
}
```

---

## 🚀 Installation

### Prerequisites

- Flutter SDK 3.32+
- Node.js 18+
- Firebase CLI
- Firebase Project

### Setup

```bash
# 1. Clone repository
git clone https://github.com/nroxa92/admin_panel.git
cd admin_panel

# 2. Install Flutter dependencies
flutter pub get

# 3. Install Cloud Functions dependencies
cd functions
npm install
cd ..

# 4. Configure Firebase
firebase login
firebase use --add

# 5. Run locally
flutter run -d chrome
```

---

## 📦 Deployment

### Deploy Everything

```bash
# Build Flutter web
flutter build web --release

# Deploy all Firebase services
firebase deploy
```

### Deploy Specific Services

```bash
# Only hosting (web app)
firebase deploy --only hosting

# Only Firestore rules
firebase deploy --only firestore:rules

# Only Cloud Functions
firebase deploy --only functions

# Only Storage rules
firebase deploy --only storage
```

---

## 🌍 Translations

### Supported Languages (11)

| Code | Language | Status |
|------|----------|--------|
| `en` | English | ✅ Complete (Master) |
| `hr` | Hrvatski (Croatian) | ✅ Complete |
| `sk` | Slovenčina (Slovak) | ✅ Complete |
| `cs` | Čeština (Czech) | ✅ Complete |
| `de` | Deutsch (German) | ✅ Complete |
| `it` | Italiano (Italian) | ✅ Complete |
| `es` | Español (Spanish) | ✅ Complete |
| `fr` | Français (French) | ✅ Complete |
| `pl` | Polski (Polish) | ✅ Complete |
| `hu` | Magyar (Hungarian) | ✅ Complete |
| `sl` | Slovenščina (Slovenian) | ✅ Complete |

### Translation Keys: 168 keys across categories:
- Navigation & Dashboard
- Booking & Calendar
- Settings & Configuration
- Analytics & Gallery
- Super Admin Console
- Error Messages & Notifications

---

## 📊 Statistics

| Metric | Value |
|--------|-------|
| **Total Lines of Code** | 19,543 |
| **Flutter/Dart Files** | 25 |
| **Cloud Functions** | 10 |
| **Firestore Collections** | 17 |
| **Translation Keys** | 168 |
| **Supported Languages** | 11 |
| **PDF Types** | 10 |

---

## ⚠️ License

**PROPRIETARY & CONFIDENTIAL**

This software is the exclusive property of VillaOS. All rights reserved.

⛔ **STRICTLY PROHIBITED:**
- Copying, modifying, or distributing this code
- Reverse engineering or decompiling
- Using any part of this codebase without written permission

📜 **Legal action will be taken against any unauthorized use.**

🔒 **Copyright © 2026 VillaOS. Sva prava pridržana.**

---

## 👨‍💻 Author

**VillaOS Team**

---

*Last Updated: January 9, 2026*
