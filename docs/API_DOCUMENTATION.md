# 📡 Vesta Lumina API Documentation

> **Version 0.0.9 Beta** | **Last Updated: January 2026**
> **Part of Vesta Lumina System**

---

## ⚠️ LEGAL NOTICE

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                              PROPRIETARY SOFTWARE                             ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║  This API documentation and associated software are PROPRIETARY.              ║
║  Unauthorized access, use, or reproduction is STRICTLY PROHIBITED.            ║
║                                                                               ║
║  🔒 PROHIBITED: Copying, reverse engineering, commercial use                  ║
║  ⚖️ VIOLATIONS: Subject to civil and criminal prosecution                     ║
║                                                                               ║
║  © 2025-2026 All rights reserved.                                             ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## 📋 Table of Contents

1. [Overview](#-overview)
2. [Authentication](#-authentication)
3. [Cloud Functions API](#-cloud-functions-api)
4. [Firestore Data Models](#-firestore-data-models)
5. [Error Handling](#-error-handling)
6. [Rate Limiting](#-rate-limiting)

---

## 🎯 Overview

### API Configuration

| Property | Value |
|----------|-------|
| **Runtime** | Node.js 20 |
| **Region** | `europe-west3` (Frankfurt) |
| **Base URL** | `https://europe-west3-vls-admin.cloudfunctions.net/` |
| **Auth Method** | Firebase Auth + Custom Claims |
| **Current Version** | 0.0.9 Beta |
| **Total Functions** | 20 |
| **Total Lines** | 1,507 (index.js: 1,265 + api_versioning.js: 242) |

### Function Categories

```
┌─────────────────────────────────────────────────────────────────────┐
│                     CLOUD FUNCTIONS (20 TOTAL)                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  👤 OWNER MANAGEMENT (6)              │  🔄 TRANSLATION (2)          │
│  ├─ createOwner                       │  ├─ translateHouseRules      │
│  ├─ linkTenantId                      │  └─ translateNotification    │
│  ├─ listOwners                        │                              │
│  ├─ deleteOwner                       │  📱 TABLET MANAGEMENT (2)    │
│  ├─ resetOwnerPassword                │  ├─ registerTablet           │
│  └─ toggleOwnerStatus                 │  └─ tabletHeartbeat          │
│                                       │                              │
│  👨‍💼 SUPER ADMIN (4)                   │  📧 EMAIL NOTIFICATIONS (4)  │
│  ├─ addSuperAdmin                     │  ├─ sendEmailNotification    │
│  ├─ removeSuperAdmin                  │  ├─ onBookingCreated         │
│  ├─ listSuperAdmins                   │  ├─ sendCheckInReminders     │
│  └─ getAdminLogs                      │  └─ updateEmailSettings      │
│                                       │                              │
│  💾 BACKUP (2)                        │                              │
│  ├─ scheduledBackup                   │                              │
│  └─ manualBackup                      │                              │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🔐 Authentication

### Firebase Auth + Custom Claims

All API calls require Firebase Authentication with JWT tokens containing custom claims:

```javascript
// JWT Token Structure
{
  "uid": "firebase-user-id",
  "email": "user@example.com",
  "email_verified": true,
  
  // Custom Claims (set by Cloud Functions)
  "ownerId": "TENANT_ID",           // Tenant isolation key
  "role": "owner" | "superadmin",   // User role
}
```

### Roles and Permissions

| Role | Description | Permissions |
|------|-------------|-------------|
| `superadmin` | System administrator | Full access to all tenants and system functions |
| `owner` | Property owner | Access only to own tenant data |
| `tablet` | Kiosk device | Read-only access to assigned unit |
| `cleaner` | Cleaning staff | PIN-based access to cleaning workflow |

### Authentication Flow

```
┌──────────────────────────────────────────────────────────────────┐
│                     AUTHENTICATION FLOW                           │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. User Login (Email/Password)                                  │
│     └─→ Firebase Auth validates credentials                      │
│                                                                  │
│  2. Token Generation                                             │
│     └─→ Firebase returns ID Token with custom claims             │
│                                                                  │
│  3. API Request                                                  │
│     └─→ Client sends token in Authorization header               │
│         Authorization: Bearer <ID_TOKEN>                         │
│                                                                  │
│  4. Server Validation                                            │
│     └─→ Cloud Function validates token                           │
│     └─→ Extracts ownerId for data isolation                      │
│                                                                  │
│  5. Data Access                                                  │
│     └─→ Firestore query filtered by ownerId                      │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## ⚡ Cloud Functions API

### 1. Owner Management (6 functions)

#### `createOwner`
Creates a new owner (tenant) in the system.

| Property | Value |
|----------|-------|
| **Method** | onCall |
| **Required Role** | superadmin |
| **Region** | europe-west3 |

```javascript
// Request
{
  "email": "owner@example.com",
  "displayName": "Villa Owner",
  "tenantId": "TENANT001"
}

// Response
{
  "success": true,
  "uid": "firebase-uid",
  "tenantId": "TENANT001"
}
```

---

#### `linkTenantId`
Links an authenticated user to a tenant ID (account activation).

| Property | Value |
|----------|-------|
| **Method** | onCall |
| **Required Role** | Authenticated user without tenant |
| **Region** | europe-west3 |

```javascript
// Request
{
  "tenantId": "TENANT001"
}

// Response
{
  "success": true,
  "message": "Account activated successfully"
}
```

---

#### `listOwners`
Returns list of all owners (tenants).

| Property | Value |
|----------|-------|
| **Method** | onCall |
| **Required Role** | superadmin |
| **Region** | europe-west3 |

```javascript
// Response
{
  "success": true,
  "owners": [
    {
      "uid": "firebase-uid",
      "email": "owner@example.com",
      "displayName": "Villa Owner",
      "tenantId": "TENANT001",
      "status": "active",
      "createdAt": "2026-01-10T..."
    }
  ]
}
```

---

#### `deleteOwner`
Permanently deletes an owner and all associated data.

| Property | Value |
|----------|-------|
| **Method** | onCall |
| **Required Role** | superadmin |
| **Region** | europe-west3 |

```javascript
// Request
{
  "uid": "firebase-uid"
}

// Response
{
  "success": true,
  "message": "Owner deleted successfully"
}
```

---

#### `resetOwnerPassword`
Sends password reset email to owner.

| Property | Value |
|----------|-------|
| **Method** | onCall |
| **Required Role** | superadmin |
| **Region** | europe-west3 |

```javascript
// Request
{
  "email": "owner@example.com"
}

// Response
{
  "success": true,
  "message": "Password reset email sent"
}
```

---

#### `toggleOwnerStatus`
Enables or disables an owner account.

| Property | Value |
|----------|-------|
| **Method** | onCall |
| **Required Role** | superadmin |
| **Region** | europe-west3 |

```javascript
// Request
{
  "uid": "firebase-uid",
  "status": "active" | "disabled"
}

// Response
{
  "success": true,
  "newStatus": "disabled"
}
```

---

### 2. Super Admin Functions (4 functions)

#### `addSuperAdmin`
Adds a new super admin to the system.

| Property | Value |
|----------|-------|
| **Method** | onCall |
| **Required Role** | Primary super admin (vestaluminasystem@gmail.com) |
| **Region** | europe-west3 |

```javascript
// Request
{
  "email": "newadmin@example.com"
}

// Response
{
  "success": true,
  "message": "Super admin added"
}
```

---

#### `removeSuperAdmin`
Removes a super admin from the system.

| Property | Value |
|----------|-------|
| **Method** | onCall |
| **Required Role** | Primary super admin |
| **Region** | europe-west3 |

```javascript
// Request
{
  "email": "admin@example.com"
}

// Response
{
  "success": true,
  "message": "Super admin removed"
}
```

---

#### `listSuperAdmins`
Lists all super admins in the system.

| Property | Value |
|----------|-------|
| **Method** | onCall |
| **Required Role** | superadmin |
| **Region** | europe-west3 |

```javascript
// Response
{
  "success": true,
  "admins": [
    {
      "email": "vestaluminasystem@gmail.com",
      "addedAt": "2026-01-01T...",
      "isPrimary": true
    },
    {
      "email": "admin@example.com",
      "addedAt": "2026-01-10T...",
      "isPrimary": false
    }
  ]
}
```

---

#### `getAdminLogs`
Returns admin activity audit logs.

| Property | Value |
|----------|-------|
| **Method** | onCall |
| **Required Role** | superadmin |
| **Region** | europe-west3 |

```javascript
// Request
{
  "limit": 50,
  "startAfter": "timestamp"
}

// Response
{
  "success": true,
  "logs": [
    {
      "action": "CREATE_OWNER",
      "performedBy": "admin@example.com",
      "targetId": "owner-uid",
      "timestamp": "2026-01-10T...",
      "details": {
        "email": "newowner@example.com",
        "tenantId": "TENANT002"
      }
    }
  ]
}
```

---

### 3. Translation Functions (2 functions)

#### `translateHouseRules`
Translates house rules to specified language using Google Gemini AI.

| Property | Value |
|----------|-------|
| **Method** | onCall |
| **Required Role** | owner or superadmin |
| **Region** | europe-west3 |
| **AI Model** | Google Generative AI (Gemini) |

```javascript
// Request
{
  "text": "No smoking. No parties. Quiet hours 10pm-8am.",
  "targetLanguage": "hr"
}

// Response
{
  "success": true,
  "translation": "Zabranjeno pušenje. Zabranjene zabave. Sati tišine 22-08h."
}
```

---

#### `translateNotification`
Translates notification text using AI.

| Property | Value |
|----------|-------|
| **Method** | onCall |
| **Required Role** | owner or superadmin |
| **Region** | europe-west3 |

```javascript
// Request
{
  "text": "Check-in tomorrow at 3 PM",
  "targetLanguage": "de"
}

// Response
{
  "success": true,
  "translation": "Check-in morgen um 15 Uhr"
}
```

---

### 4. Tablet Management (2 functions)

#### `registerTablet`
Registers a tablet device for a specific unit.

| Property | Value |
|----------|-------|
| **Method** | onCall |
| **Required Role** | owner |
| **Region** | europe-west3 |

```javascript
// Request
{
  "deviceId": "tablet-android-uuid",
  "unitId": "unit-001",
  "appVersion": "1.0.0"
}

// Response
{
  "success": true,
  "tabletId": "tablet-doc-id"
}
```

---

#### `tabletHeartbeat`
Reports tablet health status and checks for updates.

| Property | Value |
|----------|-------|
| **Method** | onCall |
| **Required Role** | tablet |
| **Region** | europe-west3 |

```javascript
// Request
{
  "tabletId": "tablet-doc-id",
  "batteryLevel": 85,
  "isCharging": true,
  "appVersion": "1.0.0"
}

// Response
{
  "success": true,
  "hasUpdate": false,
  "latestVersion": "1.0.0"
}
```

---

### 5. Backup Functions (2 functions)

#### `scheduledBackup`
Automatic daily backup triggered by Cloud Scheduler.

| Property | Value |
|----------|-------|
| **Method** | onSchedule |
| **Schedule** | Every day at 03:00 UTC |
| **Region** | europe-west3 |

---

#### `manualBackup`
Triggers manual backup on demand.

| Property | Value |
|----------|-------|
| **Method** | onCall |
| **Required Role** | superadmin |
| **Region** | europe-west3 |

```javascript
// Request
{
  "includeImages": false
}

// Response
{
  "success": true,
  "backupId": "backup-2026-01-10",
  "size": "15.2 MB",
  "collections": 16
}
```

---

### 6. Email Functions (4 functions)

#### `sendEmailNotification`
Sends email notification to specified recipient.

| Property | Value |
|----------|-------|
| **Method** | onCall |
| **Required Role** | System (internal) |
| **Region** | europe-west3 |

```javascript
// Request
{
  "to": "owner@example.com",
  "subject": "New Booking Received",
  "body": "You have received a new booking for Villa Sunset..."
}

// Response
{
  "success": true,
  "messageId": "email-message-id"
}
```

---

#### `onBookingCreated`
Triggered automatically when a new booking is created.

| Property | Value |
|----------|-------|
| **Method** | onDocumentCreated |
| **Path** | bookings/{bookingId} |
| **Region** | europe-west3 |

---

#### `sendCheckInReminders`
Sends check-in reminders for upcoming bookings.

| Property | Value |
|----------|-------|
| **Method** | onSchedule |
| **Schedule** | Every day at 08:00 UTC |
| **Region** | europe-west3 |

---

#### `updateEmailSettings`
Updates email notification preferences for an owner.

| Property | Value |
|----------|-------|
| **Method** | onCall |
| **Required Role** | owner |
| **Region** | europe-west3 |

```javascript
// Request
{
  "newBookingNotifications": true,
  "checkInReminders": true,
  "dailyDigest": false,
  "notificationEmail": "owner@example.com"
}

// Response
{
  "success": true
}
```

---

## 📊 Firestore Data Models

### Collections Overview (16 Collections)

| # | Collection | Description | Access |
|---|------------|-------------|--------|
| 1 | `owners` | Owner/tenant accounts | Super Admin |
| 2 | `units` | Accommodation units | Owner (filtered) |
| 3 | `bookings` | Reservations | Owner (filtered) |
| 4 | `settings` | Tenant settings | Owner (own) |
| 5 | `cleaning_logs` | Cleaning records | Owner (filtered) |
| 6 | `tablets` | Registered tablet devices | Owner (filtered) |
| 7 | `signatures` | Guest document signatures | Owner (filtered) |
| 8 | `feedback` | Guest feedback | Owner (filtered) |
| 9 | `screensaver_images` | Gallery images metadata | Owner (filtered) |
| 10 | `ai_logs` | AI conversation logs | Owner (filtered) |
| 11 | `system_notifications` | System-wide announcements | All (read) |
| 12 | `apk_updates` | Tablet APK versions | All (read) |
| 13 | `admin_logs` | Audit trail | Super Admin |
| 14 | `super_admins` | Super admin list | Super Admin |
| 15 | `tenant_links` | Tenant ID mappings | System |
| 16 | `activation_codes` | Account activation codes | System |

### Key Data Models

#### Booking Model
```javascript
{
  id: "booking-uuid",
  ownerId: "TENANT001",           // Tenant isolation key
  unitId: "unit-uuid",
  guestName: "John Doe",
  guestCount: 2,
  startDate: Timestamp,
  endDate: Timestamp,
  checkInTime: "15:00",
  checkOutTime: "10:00",
  status: "confirmed",            // confirmed | pending | cancelled | private | blocked
  source: "airbnb",               // airbnb | booking | direct | other
  totalPrice: 500.00,
  currency: "EUR",
  notes: "Early check-in requested",
  guests: [
    {
      firstName: "John",
      lastName: "Doe",
      dateOfBirth: Timestamp,
      nationality: "USA",
      documentType: "passport",
      documentNumber: "AB123456",
      scannedAt: Timestamp
    }
  ],
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### Unit Model
```javascript
{
  id: "unit-uuid",
  ownerId: "TENANT001",          // Tenant isolation key
  ownerEmail: "owner@example.com",
  name: "Villa Sunset",
  address: "123 Beach Road, Split",
  zone: "Zone A",
  category: "villa",
  wifiSsid: "VillaSunset_WiFi",
  wifiPass: "welcome123",
  cleanerPin: "1234",
  reviewLink: "https://airbnb.com/...",
  contactOptions: {
    phone: "+385...",
    whatsapp: "+385..."
  },
  status: "active",
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### Settings Model
```javascript
{
  ownerId: "TENANT001",
  appLanguage: "en",              // 11 supported languages
  themeColor: "gold",             // 10 color options
  themeMode: "dark2",             // 6 background options
  cleanerPin: "0000",
  hardResetPin: "123456",
  houseRules: {
    en: "No smoking. No parties...",
    hr: "Zabranjeno pušenje...",
    de: "Rauchen verboten...",
    // ... all 11 languages
  },
  cleanerChecklist: [
    "Check bedsheets",
    "Clean bathroom",
    "Restock supplies",
    "Take out trash"
  ],
  aiKnowledge: {
    concierge: "Local restaurant recommendations...",
    housekeeper: "Cleaning product locations...",
    tech: "WiFi troubleshooting steps...",
    guide: "Beach directions, parking info..."
  },
  emailNotifications: true,
  contactEmail: "owner@example.com",
  companyName: "Villa Management Ltd",
  checkInTime: "15:00",
  checkOutTime: "10:00"
}
```

---

## ⚠️ Error Handling

### Error Response Format

```javascript
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message"
  }
}
```

### Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `UNAUTHENTICATED` | 401 | Missing or invalid auth token |
| `PERMISSION_DENIED` | 403 | Insufficient permissions for operation |
| `NOT_FOUND` | 404 | Requested resource not found |
| `ALREADY_EXISTS` | 409 | Resource already exists |
| `INVALID_ARGUMENT` | 400 | Invalid request parameters |
| `INTERNAL` | 500 | Internal server error |
| `RESOURCE_EXHAUSTED` | 429 | Rate limit exceeded |
| `FAILED_PRECONDITION` | 400 | Operation requirements not met |

---

## 🚦 Rate Limiting

### Default Limits

| Endpoint Type | Limit | Window |
|---------------|-------|--------|
| Read operations | 100 requests | per minute per user |
| Write operations | 50 requests | per minute per user |
| Translation | 20 requests | per minute per user |
| Backup | 5 requests | per hour per admin |
| Authentication | 10 requests | per minute per IP |

### Response Headers

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1704844800
```

---

## 📜 License Notice

```
This API documentation is part of the Vesta Lumina System proprietary software.
Unauthorized reproduction, distribution, or use is strictly prohibited.

© 2025-2026 Neven Roksa (@nroxa92). All rights reserved.
```
