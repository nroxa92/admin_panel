# 📝 Changelog

> **Vesta Lumina Admin Panel** - All notable changes to this project
> **Part of Vesta Lumina System**

---

## ⚠️ LEGAL NOTICE

```
This software is PROPRIETARY. Unauthorized use is prohibited.
© 2025-2026 All rights reserved.
```

---

## [0.0.9] - 2026-01-10

### 🎉 Beta Release - Production Ready

#### ✅ Fixed
- **Critical:** Fixed `app_provider.dart` translate method argument order
  - Bug: `AppTranslations.get(currentLanguage, key)` returned language code instead of translation
  - Fix: `AppTranslations.get(key, currentLanguage)` now returns proper translations
- **Critical:** Fixed tenant activation flow
  - Updated Cloud Function URL from old project to `vls-admin`
  - Fixed "Network error" on account activation
- **Critical:** Added missing `units` Firestore composite index
  - Query: `ownerId` + `createdAt` (ascending)
  - Fixed Reception screen loading failure

#### ➕ Added
- Comprehensive Test Suite
  - 138 tests across 14 test files
  - 3,908 lines of test code
  - Coverage: Services, Models, Widgets, Integration, Repositories
- Complete documentation update
  - README.md with full project structure
  - LICENSE with comprehensive legal protection
  - API_DOCUMENTATION.md with all 20 functions
  - FIREBASE_DOCUMENTATION.md with all 16 collections
  - CHANGELOG.md with version history
  - PROJECT_ANALYSIS.md with statistics

#### 📊 Test Files Added
| File | Lines | Tests |
|------|-------|-------|
| test/all_tests.dart | 51 | - |
| test/services_test.dart | 163 | - |
| test/widget_test.dart | 235 | - |
| test/services/auth_service_test.dart | 291 | 25 |
| test/services/cache_service_test.dart | 337 | 28 |
| test/services/revenue_service_test.dart | 421 | 32 |
| test/services/security_service_test.dart | 183 | 15 |
| test/models/booking_model_test.dart | 401 | 24 |
| test/models/unit_model_test.dart | 383 | 22 |
| test/widgets/login_screen_test.dart | 453 | 18 |
| test/integration/auth_flow_test.dart | 323 | 29 |
| test/helpers/test_helpers.dart | 291 | - |
| test/config/app_config_test.dart | 162 | 12 |
| test/repositories/booking_repository_test.dart | 214 | 15 |
| **TOTAL** | **3,908** | **138** |

---

## [0.0.8] - 2026-01-09

### 🔧 Enterprise Hardening

#### ➕ Added
- Enterprise Auth Service (479 lines)
  - Singleton pattern implementation
  - Comprehensive error handling with localized messages
  - JWT token management with automatic refresh
  - Session validation and timeout handling
  - Role-based access control helpers
- Offline Queue Service (375 lines)
  - Automatic sync when connection restored
  - Queue persistence with SharedPreferences
  - Conflict resolution strategies
- Performance Monitoring Service (318 lines)
  - Custom metrics tracking
  - Screen load time measurement
  - Memory usage monitoring
- Health Service (430 lines)
  - System health dashboard
  - Firebase connection status
  - Storage usage tracking
- API Versioning (242 lines)
  - v1/v2 endpoint routing
  - Deprecation warnings
  - Sunset date management
- Performance Utilities (640 lines)
  - Debouncer class
  - Throttler class
  - RetryHelper with exponential backoff
  - Memoizer for caching
  - BatchProcessor for bulk operations

#### 🔄 Changed
- Auth service completely rewritten (28 → 479 lines)
- Improved error handling across all services

---

## [0.0.7] - 2026-01-08

### ⚡ Advanced Features

#### ➕ Added
- Revenue Analytics Dashboard
  - Monthly revenue tracking by source
  - Occupancy rate calculations
  - Year-over-year comparisons
  - Revenue per unit breakdown
- Revenue Screen (623 lines)
  - Detailed revenue analytics
  - Export to CSV functionality
- iCal Calendar Service (364 lines)
  - Export bookings to .ics format
  - Import from external calendars (Airbnb, Booking.com)
  - Sync with Google Calendar
- Email Notifications System (4 Cloud Functions)
  - sendEmailNotification - Manual email sending
  - onBookingCreated - Automatic booking notifications
  - sendCheckInReminders - Daily check-in reminders
  - updateEmailSettings - Notification preferences
- Complete 11-language Support
  - EN, HR, DE, IT, ES, FR, PL, SK, CS, HU, SL
  - 178 translation keys per language
  - Total: 1,958 translations
- Analytics Widgets (687 lines)
  - booking_chart.dart (134 lines)
  - occupancy_chart.dart (211 lines)
  - stat_card.dart (118 lines)
  - upcoming_bookings_card.dart (224 lines)

#### 🔄 Changed
- Translations expanded from 50 to 178 keys
- Analytics screen redesigned with new widgets

---

## [0.0.6] - 2026-01-07

### 👨‍💼 Super Admin Panel

#### ➕ Added
- Super Admin Screen (1,017 lines)
  - Owner listing with status
  - Create new owner
  - Edit owner details
  - Delete owner (with confirmation)
  - Reset password
  - Toggle active/disabled status
- Super Admin Tablets Screen (1,037 lines)
  - Registered tablets listing
  - Tablet health status
  - APK version management
  - Remote tablet management
- Super Admin Notifications Screen (961 lines)
  - System-wide notifications
  - Notification types (info, warning, critical)
  - Expiration management
  - Broadcast to all users
- Super Admin Service (333 lines)
  - Owner CRUD operations
  - Tablet management
  - Notification broadcasting
- 10 new Cloud Functions
  - createOwner
  - linkTenantId
  - listOwners
  - deleteOwner
  - resetOwnerPassword
  - toggleOwnerStatus
  - addSuperAdmin
  - removeSuperAdmin
  - listSuperAdmins
  - getAdminLogs
- Audit Logging (admin_logs collection)
  - All admin actions logged
  - Timestamp and performer tracking
  - Action details storage

#### 📊 New Firestore Collections
- system_notifications
- apk_updates
- admin_logs
- super_admins (expanded)
- tablets (expanded)

---

## [0.0.5] - 2026-01-05

### 📄 PDF Generation System

#### ➕ Added
- PDF Service (966 lines)
  - Complete PDF generation engine
  - Multi-language support
  - Custom styling and branding
- 10 PDF Document Types:
  1. **eVisitor Data** - Guest data for eVisitor registration
  2. **House Rules** - Signed house rules document
  3. **Cleaning Log** - Cleaning checklist with timestamps
  4. **Unit Schedule** - 30-day unit schedule
  5. **Text List Full** - Text booking list (full details)
  6. **Text List Anonymous** - Text booking list (anonymized)
  7. **Cleaning Schedule** - Cleaning schedule for all units
  8. **Graphic Full** - Visual calendar (full details)
  9. **Graphic Anonymous** - Visual calendar (anonymized)
  10. **Booking History** - Complete booking history report

---

## [0.0.4] - 2026-01-03

### 📊 Analytics & Gallery

#### ➕ Added
- Analytics Screen (983 lines)
  - Revenue overview
  - Occupancy statistics
  - Guest demographics
  - AI questions log
  - Export functionality
- Gallery Screen (885 lines)
  - Image upload (multi-select)
  - Per-unit galleries
  - Screensaver mode configuration
  - Image ordering
  - Delete with confirmation
- Analytics Service (488 lines)
  - Data aggregation
  - Statistical calculations
  - AI log management
- Cache Service (413 lines)
  - Offline data persistence
  - Cache invalidation
  - Memory management

---

## [0.0.3] - 2026-01-01

### 📅 Booking Calendar

#### ➕ Added
- Booking Calendar Widget (1,355 lines)
  - Drag & Drop functionality
  - Visual booking blocks
  - Overlap detection
  - Color coding by status
  - Color coding by source
- Booking Screen (1,344 lines)
  - Period selection (7/14/30/ALL days)
  - Zone filtering
  - Category visibility toggle
  - Print menu with 10 PDF options
  - Booking history dialog
- Booking Service (345 lines)
  - CRUD operations
  - Overlap validation
  - Date calculations
- Booking Repository (484 lines)
  - Firestore integration
  - Query optimization
  - Real-time listeners

---

## [0.0.2] - 2025-12-28

### 🏠 Unit Management

#### ➕ Added
- Dashboard Screen (1,288 lines)
  - Navigation sidebar/drawer
  - Unit grid/list view
  - Quick status overview
  - Daily schedule widget
- Unit Widgets (1,426 lines)
  - UnitStatusCard
  - UnitListItem
  - UnitDialog
  - EditUnitDialog
  - PrintOptionRow
- Units Service (303 lines)
  - CRUD operations
  - Category management
  - Zone assignment
- Units Repository (194 lines)
  - Firestore integration
  - Query builders
- Digital Book Screen (1,783 lines)
  - Welcome message editor
  - House rules editor (11 languages)
  - Cleaner checklist editor
  - AI knowledge base editor
  - Emergency contact editor
  - Tablet timer configuration

---

## [0.0.1] - 2025-12-20

### 🚀 Initial Release

#### ➕ Added
- Multi-tenant Architecture
  - JWT custom claims for tenant isolation
  - ownerId filtering on all queries
- Firebase Authentication
  - Email/Password login
  - Custom claims management
  - Session persistence
- Firestore Database Setup
  - Initial collections (owners, units, bookings, settings)
  - Security rules foundation
- Settings Screen (1,395 lines)
  - Theme selection (10 colors + 6 backgrounds)
  - Language selection (11 languages)
  - PIN management (cleaner + master)
  - Owner info editing
  - Password change
- Login Screen (181 lines)
  - Email/Password form
  - Error handling
  - Remember me functionality
- Tenant Setup Screen (403 lines)
  - Activation code entry
  - Initial configuration wizard
- App Provider (126 lines)
  - State management
  - Theme handling
  - Language handling
- Configuration Files
  - app_config.dart (181 lines)
  - theme.dart (143 lines)
  - translations.dart (2,094 lines)
- Base Repository (315 lines)
  - Generic CRUD operations
  - Error handling
  - Pagination support

---

## Version History Summary

| Version | Date | Highlights |
|---------|------|------------|
| 0.0.9 | 2026-01-10 | Beta Release, Test Suite (138 tests), Bug Fixes, Documentation |
| 0.0.8 | 2026-01-09 | Enterprise Auth (479 lines), Performance Utils, Health Service |
| 0.0.7 | 2026-01-08 | Revenue Analytics, iCal Export, Email Notifications, 11 Languages |
| 0.0.6 | 2026-01-07 | Super Admin Panel (3 screens, 3,015 lines), 10 Cloud Functions |
| 0.0.5 | 2026-01-05 | PDF Service (966 lines), 10 PDF Document Types |
| 0.0.4 | 2026-01-03 | Analytics Screen, Gallery Screen, Cache Service |
| 0.0.3 | 2026-01-01 | Booking Calendar (Drag & Drop), Booking Screen |
| 0.0.2 | 2025-12-28 | Dashboard, Unit Management, Digital Book |
| 0.0.1 | 2025-12-20 | Initial Release - Multi-tenant Foundation |

---

## Statistics Summary

| Metric | Value |
|--------|-------|
| **Total Dart Code** | 27,352 lines |
| **Total JS Code** | 1,507 lines |
| **Total Test Code** | 3,908 lines |
| **Total Lines** | 32,767+ lines |
| **Total Files** | 75+ files |
| **Cloud Functions** | 20 functions |
| **Firestore Collections** | 16 collections |
| **Firestore Indexes** | 11 indexes |
| **Languages** | 11 |
| **Translation Keys** | 178 |
| **PDF Types** | 10 |
| **Theme Colors** | 10 |
| **Background Tones** | 6 |

---

## 📜 License

```
© 2025-2026 Neven Roksa (@nroxa92). All rights reserved.
This is proprietary software. Unauthorized use is prohibited.

Part of Vesta Lumina System:
• Vesta Lumina Admin Panel
• Vesta Lumina Client Terminal
```
