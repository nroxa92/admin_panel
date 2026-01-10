# 📝 Changelog

> **VillaOS Admin Panel** - All notable changes to this project

---

## ⚠️ LEGAL NOTICE

```
This software is PROPRIETARY. Unauthorized use is prohibited.
© 2025-2026 All rights reserved.
```

---

## [2.2.0] - 2026-01-10

### 🎉 Production Ready Release

#### ✅ Fixed
- **Critical:** Fixed `app_provider.dart` translate method argument order
  - Bug: `AppTranslations.get(currentLanguage, key)` → all UI showed "en"
  - Fix: `AppTranslations.get(key, currentLanguage)` → proper translations
- **Critical:** Fixed tenant activation flow - URL updated for new Firebase project
  - Changed from `villa-ai-admin` to `vls-admin`
- **Critical:** Added missing `units` Firestore composite index
  - Query: `ownerId` + `createdAt` (ascending)
  - This was causing Reception screen to fail loading

#### ➕ Added
- Comprehensive Test Suite (138 tests, 2,918 lines)
  - `test/services/auth_service_test.dart` - Authentication tests
  - `test/services/revenue_service_test.dart` - Revenue/Analytics tests
  - `test/services/cache_service_test.dart` - Cache service tests
  - `test/models/booking_model_test.dart` - Booking model tests
  - `test/models/unit_model_test.dart` - Unit model tests
  - `test/widgets/login_screen_test.dart` - Login UI tests
  - `test/integration/auth_flow_test.dart` - Full auth flow tests
  - `test/helpers/test_helpers.dart` - Mock data generators

#### 📊 Statistics
- Total lines of code: ~21,000+
- Test coverage: 138 tests across 9 test files
- Firestore indexes: 11 composite indexes (all enabled)

---

## [2.1.0] - 2026-01-09

### 🔧 Enterprise Hardening (Phase 5)

#### ➕ Added
- Enterprise Auth Service (475 lines)
  - Singleton pattern
  - Comprehensive error handling
  - JWT token management with auto-refresh
  - Session validation
  - Role-based access helpers
- Offline Queue Service with auto-sync
- Performance Monitoring Service
- Health Dashboard Service
- API Versioning (v1/v2 support)
- Performance utilities (`performance_utils.dart`)
  - Debouncer
  - Throttler
  - RetryHelper
  - Memoizer

#### 🔄 Changed
- Auth service rewritten from 28 to 475 lines
- Improved error messages with localization support

---

## [2.0.0] - 2026-01-08

### ⚡ Advanced Features (Phase 4)

#### ➕ Added
- Revenue Analytics Dashboard
  - Monthly revenue tracking
  - Occupancy rate calculations
  - Revenue by source breakdown
  - Year-over-year comparisons
- iCal Calendar Export
  - Export bookings to .ics format
  - Import from external calendars
- Email Notifications System
  - New booking notifications
  - Check-in reminders
  - Daily digest option
- Complete 11-language Support
  - EN, HR, DE, IT, ES, FR, PL, SK, CS, HU, SL
  - ~150 translation keys per language

#### 🔄 Changed
- Translations expanded from ~50 to ~150 keys

---

## [1.5.0] - 2026-01-07

### 👨‍💼 Super Admin Panel (Phase 3)

#### ➕ Added
- Super Admin Panel (3 screens, 2,254 lines)
  - `super_admin_screen.dart` - Owner management
  - `super_admin_tablets.dart` - Tablet deployment
  - `super_admin_notifications.dart` - System notifications
- 10 new Cloud Functions for admin operations
- Audit logging (admin_logs collection)
- APK update distribution system

#### 📊 New Collections
- `system_notifications`
- `apk_updates`
- `admin_logs`
- Expanded `tablets` collection

---

## [1.4.0] - 2026-01-05

### 📄 PDF Generation System

#### ➕ Added
- PDF Service (966 lines)
- 10 PDF document types:
  1. eVisitor Data
  2. House Rules (signed)
  3. Cleaning Log
  4. Unit Schedule
  5. Text List Full
  6. Text List Anonymous
  7. Cleaning Schedule
  8. Graphic Full
  9. Graphic Anonymous
  10. Booking History

---

## [1.3.0] - 2026-01-03

### 📊 Analytics & Gallery

#### ➕ Added
- Analytics Screen (983 lines)
  - Revenue tracking
  - Occupancy statistics
  - Guest insights
  - AI questions log
- Gallery Screen (885 lines)
  - Image upload
  - Screensaver mode
  - Per-unit galleries

---

## [1.2.0] - 2026-01-01

### 📅 Booking Calendar

#### ➕ Added
- Booking Calendar with Drag & Drop (1,355 lines)
- Zone management
- Period selection (7/14/30/ALL days)
- Print options
- Booking overlap detection

---

## [1.1.0] - 2025-12-28

### 🏠 Unit Management

#### ➕ Added
- Dashboard Screen (1,288 lines)
- Unit CRUD operations
- WiFi/PIN configuration
- QR code generation
- Guest check-in workflow

---

## [1.0.0] - 2025-12-20

### 🚀 Initial Release

#### ➕ Added
- Multi-tenant architecture
- Firebase Authentication
- Firestore database setup
- Basic booking management
- Settings management
- Login screen
- Tenant setup (onboarding)

---

## Version History Summary

| Version | Date | Highlights |
|---------|------|------------|
| 2.2.0 | 2026-01-10 | Production Ready, Test Suite, Bug Fixes |
| 2.1.0 | 2026-01-09 | Enterprise Auth, Performance Utils |
| 2.0.0 | 2026-01-08 | Revenue Analytics, iCal, 11 Languages |
| 1.5.0 | 2026-01-07 | Super Admin Panel |
| 1.4.0 | 2026-01-05 | PDF Generation (10 types) |
| 1.3.0 | 2026-01-03 | Analytics, Gallery |
| 1.2.0 | 2026-01-01 | Booking Calendar |
| 1.1.0 | 2025-12-28 | Unit Management |
| 1.0.0 | 2025-12-20 | Initial Release |

---

## 📜 License

```
© 2025-2026 Neven Roksa (@nroxa92). All rights reserved.
This is proprietary software. Unauthorized use is prohibited.
```