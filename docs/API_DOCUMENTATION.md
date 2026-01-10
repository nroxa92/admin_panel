# 📡 VillaOS API Documentation

> **Version 2.2.0** | **Last Updated: January 2026**

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
| **Current Version** | v2.2.0 |
| **Total Functions** | 20 |

### Function Categories

```
┌─────────────────────────────────────────────────────────────────────┐
│                     CLOUD FUNCTIONS (20 TOTAL)                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  👤 OWNER MANAGEMENT (6)     │  🔄 TRANSLATION (2)                   │
│  ├─ createOwner              │  ├─ translateHouseRules               │
│  ├─ linkTenantId             │  └─ translateNotification             │
│  ├─ listOwners               │                                       │
│  ├─ deleteOwner              │  📱 TABLET MANAGEMENT (2)             │
│  ├─ resetOwnerPassword       │  ├─ registerTablet                    │
│  └─ toggleOwnerStatus        │  └─ tabletHeartbeat                   │
│                              │                                       │
│  👨‍💼 SUPER ADMIN (4)          │  📧 EMAIL NOTIFICATIONS (4)          │
│  ├─ addSuperAdmin            │  ├─ sendEmailNotification             │
│  ├─ removeSuperAdmin         │  ├─ onBookingCreated                  │
│  ├─ listSuperAdmins          │  ├─ sendCheckInReminders              │
│  └─ getAdminLogs             │  └─ updateEmailSettings               │
│                              │                                       │
│  💾 BACKUP (2)               │                                       │
│  ├─ scheduledBackup          │                                       │
│  └─ manualBackup             │                                       │
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
| `superadmin` | System administrator | Full access to all tenants |
| `owner` | Property owner | Access only to own tenant data |
| `tablet` | Kiosk device | Read-only access to assigned unit |

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

### Owner Management

#### `createOwner`
Creates a new owner (tenant) in the system.

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

**Required Role:** `superadmin`

---

#### `linkTenantId`
Links an authenticated user to a tenant ID.

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

**Required Role:** Authenticated user without tenant

---

#### `listOwners`
Returns list of all owners (tenants).

```javascript
// Response
{
  "success": true,
  "owners": [
    {
      "uid": "...",
      "email": "owner@example.com",
      "displayName": "Villa Owner",
      "tenantId": "TENANT001",
      "status": "active",
      "createdAt": "2026-01-10T..."
    }
  ]
}
```

**Required Role:** `superadmin`

---

#### `toggleOwnerStatus`
Enables or disables an owner account.

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

**Required Role:** `superadmin`

---

#### `resetOwnerPassword`
Sends password reset email to owner.

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

**Required Role:** `superadmin`

---

#### `deleteOwner`
Permanently deletes an owner and all associated data.

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

**Required Role:** `superadmin`

---

### Super Admin Functions

#### `addSuperAdmin`
Adds a new super admin.

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

**Required Role:** Primary super admin only

---

#### `removeSuperAdmin`
Removes a super admin.

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

**Required Role:** Primary super admin only

---

#### `listSuperAdmins`
Lists all super admins.

```javascript
// Response
{
  "success": true,
  "admins": [
    {
      "email": "admin@example.com",
      "addedAt": "2026-01-10T..."
    }
  ]
}
```

**Required Role:** `superadmin`

---

#### `getAdminLogs`
Returns admin activity logs.

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
      "timestamp": "2026-01-10T...",
      "details": { ... }
    }
  ]
}
```

**Required Role:** `superadmin`

---

### Translation Functions

#### `translateHouseRules`
Translates house rules to specified language using AI.

```javascript
// Request
{
  "text": "No smoking. No parties.",
  "targetLanguage": "hr"
}

// Response
{
  "success": true,
  "translation": "Zabranjeno pušenje. Zabranjene zabave."
}
```

**Required Role:** `owner` or `superadmin`

---

#### `translateNotification`
Translates notification text.

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

**Required Role:** `owner` or `superadmin`

---

### Tablet Management

#### `registerTablet`
Registers a tablet device for a unit.

```javascript
// Request
{
  "deviceId": "tablet-uuid",
  "unitId": "unit-001",
  "appVersion": "1.0.0"
}

// Response
{
  "success": true,
  "tabletId": "tablet-doc-id"
}
```

**Required Role:** `owner`

---

#### `tabletHeartbeat`
Reports tablet health status.

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
  "hasUpdate": false
}
```

**Required Role:** `tablet`

---

### Email Functions

#### `sendEmailNotification`
Sends email notification to owner.

```javascript
// Request
{
  "to": "owner@example.com",
  "subject": "New Booking",
  "body": "You have a new booking..."
}

// Response
{
  "success": true,
  "messageId": "email-id"
}
```

**Required Role:** System (trigger-based)

---

#### `updateEmailSettings`
Updates email notification preferences.

```javascript
// Request
{
  "newBookingNotifications": true,
  "checkInReminders": true,
  "dailyDigest": false
}

// Response
{
  "success": true
}
```

**Required Role:** `owner`

---

### Backup Functions

#### `scheduledBackup`
Automatic daily backup (runs at 3 AM).

**Trigger:** `schedule: 'every day 03:00'`

---

#### `manualBackup`
Triggers manual backup.

```javascript
// Request
{
  "includeImages": false
}

// Response
{
  "success": true,
  "backupId": "backup-2026-01-10",
  "size": "15.2 MB"
}
```

**Required Role:** `superadmin`

---

## 📊 Firestore Data Models

### Collections Structure

```
firestore/
├── owners/{uid}                 # Owner accounts
├── units/{unitId}               # Accommodation units
├── bookings/{bookingId}         # Reservations
├── settings/{ownerId}           # Tenant settings
├── cleaning_logs/{logId}        # Cleaning records
├── tablets/{tabletId}           # Registered tablets
├── signatures/{signatureId}     # Guest signatures
├── feedback/{feedbackId}        # Guest feedback
├── screensaver_images/{imageId} # Gallery images
├── ai_logs/{logId}              # AI conversation logs
├── system_notifications/{id}    # System announcements
├── apk_updates/{version}        # Tablet APK versions
├── admin_logs/{logId}           # Audit trail
├── super_admins/{email}         # Super admin list
├── tenant_links/{tenantId}      # Tenant link mapping
└── activation_codes/{code}      # Activation codes
```

### Key Data Models

#### Booking
```javascript
{
  id: "booking-uuid",
  ownerId: "TENANT001",           // Tenant isolation key
  unitId: "unit-001",
  guestName: "John Doe",
  guestCount: 2,
  startDate: Timestamp,
  endDate: Timestamp,
  checkInTime: "15:00",
  checkOutTime: "10:00",
  status: "confirmed",            // confirmed|pending|cancelled|private
  source: "airbnb",               // airbnb|booking|direct|other
  totalPrice: 500.00,
  currency: "EUR",
  notes: "...",
  guests: [                       // Guest details array
    {
      firstName: "John",
      lastName: "Doe",
      dateOfBirth: Timestamp,
      nationality: "USA",
      documentType: "passport",
      documentNumber: "AB123456"
    }
  ],
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### Unit
```javascript
{
  id: "unit-001",
  ownerId: "TENANT001",
  name: "Villa Sunset",
  address: "123 Beach Road",
  zone: "Zone A",
  wifiSSID: "VillaSunset_WiFi",
  wifiPassword: "welcome123",
  cleanerPIN: "1234",
  reviewLink: "https://airbnb.com/...",
  status: "active",
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### Settings
```javascript
{
  ownerId: "TENANT001",
  appLanguage: "en",
  themeColor: "gold",
  themeMode: "dark2",
  cleanerPIN: "0000",
  resetPIN: "1234",
  houseRules: {
    en: "No smoking...",
    hr: "Zabranjeno pušenje..."
  },
  cleanerChecklist: ["Task 1", "Task 2"],
  aiKnowledge: {
    concierge: "...",
    housekeeper: "...",
    tech: "...",
    guide: "..."
  },
  emailNotifications: true,
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
| `PERMISSION_DENIED` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `ALREADY_EXISTS` | 409 | Resource already exists |
| `INVALID_ARGUMENT` | 400 | Invalid request parameters |
| `INTERNAL` | 500 | Internal server error |
| `RESOURCE_EXHAUSTED` | 429 | Rate limit exceeded |

---

## 🚦 Rate Limiting

### Default Limits

| Endpoint Type | Limit |
|---------------|-------|
| Read operations | 100 req/min per user |
| Write operations | 50 req/min per user |
| Translation | 20 req/min per user |
| Backup | 5 req/hour per admin |

### Response Headers

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1704844800
```

---

## 📜 License Notice

```
This API documentation is part of the VillaOS proprietary software.
Unauthorized reproduction, distribution, or use is strictly prohibited.

© 2025-2026 Neven Roksa (@nroxa92). All rights reserved.
```