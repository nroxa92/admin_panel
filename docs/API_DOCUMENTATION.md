# 📡 VillaOS API Documentation

## ⚠️ LEGAL NOTICE

```
═══════════════════════════════════════════════════════════════════════════════
                              PROPRIETARY SOFTWARE
═══════════════════════════════════════════════════════════════════════════════

This software and its API are PROPRIETARY and protected by copyright law.

🔒 STRICTLY PROHIBITED:
   • Copying, reproduction or distribution of code
   • Reverse engineering or decompilation
   • Commercial use without written permission
   • Sharing access credentials or API keys
   • Unauthorized API access or scraping

⚖️ LEGAL CONSEQUENCES:
   Unauthorized copying or use of this software is subject to:
   • Civil liability for damages
   • Criminal prosecution under Copyright Law
   • Trade secret violation liability

© 2024-2025 All rights reserved.
═══════════════════════════════════════════════════════════════════════════════
```

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Cloud Functions API](#cloud-functions-api)
4. [Firestore Data Models](#firestore-data-models)
5. [API Versioning](#api-versioning)
6. [Error Handling](#error-handling)
7. [Rate Limiting](#rate-limiting)

---

## 🎯 Overview

VillaOS API is built on Firebase Cloud Functions with the following characteristics:

| Property | Value |
|----------|-------|
| **Runtime** | Node.js 20 |
| **Region** | europe-west1 (default) |
| **Auth Method** | Firebase Auth + Custom Claims |
| **Current Version** | v2 (Phase 4) |
| **Total Functions** | 20 |

### API Categories

```
┌─────────────────────────────────────────────────────────────────────┐
│                     CLOUD FUNCTIONS CATEGORIES                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  👤 OWNER MANAGEMENT (6)     │  🔄 TRANSLATION (2)                   │
│  • createOwner               │  • translateHouseRules                │
│  • linkTenantId              │  • translateNotification              │
│  • listOwners                │                                       │
│  • deleteOwner               │  📱 TABLET MANAGEMENT (2)             │
│  • resetOwnerPassword        │  • registerTablet                     │
│  • toggleOwnerStatus         │  • tabletHeartbeat                    │
│                              │                                       │
│  👨‍💼 SUPER ADMIN (4)          │  📧 EMAIL NOTIFICATIONS (4)          │
│  • addSuperAdmin             │  • sendEmailNotification              │
│  • removeSuperAdmin          │  • onBookingCreated                   │
│  • listSuperAdmins           │  • sendCheckInReminders               │
│  • getAdminLogs              │  • updateEmailSettings                │
│                              │                                       │
│  💾 BACKUP (2)               │                                       │
│  • scheduledBackup           │                                       │
│  • manualBackup              │                                       │
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
  "ownerId": "tenant-uuid",        // Tenant isolation key
  "role": "owner" | "superadmin" | "tablet",
  
  // Standard claims
  "iat": 1704067200,
  "exp": 1704070800
}
```

### Role Hierarchy

| Role | Access Level | Description |
|------|--------------|-------------|
| `superadmin` | Full system access | Can manage all tenants |
| `owner` | Tenant-scoped | Only own data (units, bookings, etc.) |
| `tablet` | Limited write | Check-in, cleaning logs, signatures |

### Authentication Flow

```
┌──────────────────────────────────────────────────────────────────┐
│                    AUTHENTICATION FLOW                            │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  1. CLIENT                                                        │
│     └─→ signInWithEmailAndPassword(email, password)               │
│                                                                   │
│  2. FIREBASE AUTH                                                 │
│     └─→ Returns ID Token with custom claims                       │
│                                                                   │
│  3. CLIENT                                                        │
│     └─→ Attach token to Cloud Function call                       │
│         httpsCallable('functionName').call(data)                  │
│                                                                   │
│  4. CLOUD FUNCTION                                                │
│     └─→ Verify token: context.auth.token                          │
│     └─→ Check claims: token.ownerId, token.role                   │
│     └─→ Process request or reject                                 │
│                                                                   │
│  5. FIRESTORE                                                     │
│     └─→ Security rules validate token.ownerId                     │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

---

## ⚡ Cloud Functions API

### 1. Owner Management

#### `createOwner`

Creates a new owner (tenant) account.

**Trigger:** `onCall`  
**Authorization:** Super Admin only

```javascript
// Request
{
  email: "owner@example.com",
  displayName: "Villa Owner Name",
  password: "securePassword123"
}

// Response
{
  success: true,
  ownerId: "generated-tenant-uuid",
  message: "Owner created successfully"
}
```

**Errors:**
| Code | Message |
|------|---------|
| `permission-denied` | Caller is not a super admin |
| `already-exists` | Email already registered |
| `invalid-argument` | Missing required fields |

---

#### `linkTenantId`

Links a tenant ID to an existing Firebase Auth user.

**Trigger:** `onCall`  
**Authorization:** Super Admin only

```javascript
// Request
{
  uid: "firebase-auth-uid",
  tenantId: "tenant-uuid"
}

// Response
{
  success: true,
  message: "Tenant ID linked successfully"
}
```

---

#### `listOwners`

Returns all registered owners.

**Trigger:** `onCall`  
**Authorization:** Super Admin only

```javascript
// Request
{} // No parameters

// Response
{
  owners: [
    {
      uid: "user-uid-1",
      email: "owner1@example.com",
      displayName: "Owner 1",
      ownerId: "tenant-uuid-1",
      status: "active",
      createdAt: "2024-01-01T00:00:00Z"
    },
    // ... more owners
  ]
}
```

---

#### `deleteOwner`

Deletes an owner account and optionally their data.

**Trigger:** `onCall`  
**Authorization:** Super Admin only

```javascript
// Request
{
  uid: "firebase-auth-uid",
  deleteData: true  // Optional: delete all tenant data
}

// Response
{
  success: true,
  message: "Owner deleted successfully"
}
```

---

#### `resetOwnerPassword`

Sends password reset email to owner.

**Trigger:** `onCall`  
**Authorization:** Super Admin only

```javascript
// Request
{
  email: "owner@example.com"
}

// Response
{
  success: true,
  message: "Password reset email sent"
}
```

---

#### `toggleOwnerStatus`

Enables or disables an owner account.

**Trigger:** `onCall`  
**Authorization:** Super Admin only

```javascript
// Request
{
  uid: "firebase-auth-uid",
  disabled: true  // true = disable, false = enable
}

// Response
{
  success: true,
  status: "disabled"
}
```

---

### 2. Translation

#### `translateHouseRules`

Translates house rules to all supported languages using Gemini AI.

**Trigger:** `onCall`  
**Authorization:** Owner or Super Admin  
**Secret:** `GEMINI_API_KEY`

```javascript
// Request
{
  ownerId: "tenant-uuid",
  sourceLanguage: "en",
  sourceText: "No smoking inside the property..."
}

// Response
{
  success: true,
  translations: {
    en: "No smoking inside the property...",
    hr: "Zabranjeno pušenje unutar objekta...",
    de: "Rauchen ist im Objekt verboten...",
    it: "Vietato fumare all'interno...",
    // ... 11 languages total
  }
}
```

**Supported Languages:**
`en`, `hr`, `sk`, `cs`, `de`, `it`, `es`, `fr`, `pl`, `hu`, `sl`

---

#### `translateNotification`

Translates a notification message to specified language.

**Trigger:** `onCall`  
**Authorization:** Super Admin only

```javascript
// Request
{
  text: "System maintenance scheduled",
  targetLanguage: "hr"
}

// Response
{
  success: true,
  translation: "Zakazano održavanje sustava"
}
```

---

### 3. Tablet Management

#### `registerTablet`

Registers a new tablet device for an owner.

**Trigger:** `onCall`  
**Authorization:** Super Admin only

```javascript
// Request
{
  ownerId: "tenant-uuid",
  unitId: "unit-uuid",
  deviceId: "android-device-id"
}

// Response
{
  success: true,
  tabletId: "generated-tablet-id",
  authToken: "tablet-auth-token"
}
```

---

#### `tabletHeartbeat`

Records tablet health status and last seen time.

**Trigger:** `onCall`  
**Authorization:** Tablet role only

```javascript
// Request
{
  tabletId: "tablet-uuid",
  appVersion: "1.2.3",
  batteryLevel: 85,
  isCharging: true
}

// Response
{
  success: true,
  serverTime: "2024-01-01T12:00:00Z",
  updateAvailable: false
}
```

---

### 4. Super Admin Functions

#### `addSuperAdmin`

Adds a new super admin user.

**Trigger:** `onCall`  
**Authorization:** Primary Super Admin only (`vestaluminasystem@gmail.com`)

```javascript
// Request
{
  email: "newadmin@example.com"
}

// Response
{
  success: true,
  message: "Super admin added"
}
```

---

#### `removeSuperAdmin`

Removes a super admin user.

**Trigger:** `onCall`  
**Authorization:** Primary Super Admin only

```javascript
// Request
{
  email: "admin@example.com"
}

// Response
{
  success: true,
  message: "Super admin removed"
}
```

---

#### `listSuperAdmins`

Lists all super admin users.

**Trigger:** `onCall`  
**Authorization:** Super Admin only

```javascript
// Response
{
  admins: [
    {
      email: "vestaluminasystem@gmail.com",
      addedAt: "2024-01-01T00:00:00Z",
      primary: true
    },
    // ... more admins
  ]
}
```

---

#### `getAdminLogs`

Retrieves admin action audit logs.

**Trigger:** `onCall`  
**Authorization:** Super Admin only

```javascript
// Request
{
  limit: 100,
  startAfter: "last-log-id"  // Optional pagination
}

// Response
{
  logs: [
    {
      id: "log-id",
      adminEmail: "admin@example.com",
      action: "createOwner",
      details: { email: "newowner@example.com" },
      timestamp: "2024-01-01T12:00:00Z"
    },
    // ... more logs
  ]
}
```

---

### 5. Backup Functions

#### `scheduledBackup`

Automatic daily backup of all Firestore data.

**Trigger:** `onSchedule` - Daily at 03:00 UTC  
**Authorization:** System (automated)

```javascript
// No request parameters - runs automatically

// Creates backup document in /backups collection
{
  id: "backup-2024-01-01",
  timestamp: "2024-01-01T03:00:00Z",
  collections: ["units", "bookings", "settings", ...],
  status: "completed",
  size: "45MB"
}
```

---

#### `manualBackup`

Triggers immediate backup.

**Trigger:** `onCall`  
**Authorization:** Super Admin only

```javascript
// Request
{
  collections: ["units", "bookings"]  // Optional: specific collections
}

// Response
{
  success: true,
  backupId: "backup-manual-uuid"
}
```

---

### 6. Email Notifications

#### `sendEmailNotification`

Sends email notification to owner or guest.

**Trigger:** `onCall`  
**Authorization:** Owner or Super Admin  
**Secrets:** `SMTP_HOST`, `SMTP_USER`, `SMTP_PASS`

```javascript
// Request
{
  to: "guest@example.com",
  subject: "Booking Confirmation",
  template: "booking_confirmation",
  data: {
    guestName: "John Doe",
    checkIn: "2024-06-15",
    checkOut: "2024-06-20",
    unitName: "Villa Sunset"
  }
}

// Response
{
  success: true,
  messageId: "smtp-message-id"
}
```

---

#### `onBookingCreated`

Triggered when new booking is created in Firestore.

**Trigger:** `onDocumentCreated` - `/bookings/{bookingId}`  
**Authorization:** System (automatic)

```javascript
// Automatic actions:
// 1. Send confirmation email to owner
// 2. Log booking creation
// 3. Update analytics counters
```

---

#### `sendCheckInReminders`

Sends check-in reminder emails to guests.

**Trigger:** `onSchedule` - Daily at 09:00 UTC  
**Authorization:** System (automated)

```javascript
// Checks all bookings with checkIn = today + 1 day
// Sends reminder email to guests with email on file
```

---

#### `updateEmailSettings`

Updates owner's email notification settings.

**Trigger:** `onCall`  
**Authorization:** Owner only

```javascript
// Request
{
  contactEmail: "owner@example.com",
  emailNotifications: true,
  reminderDaysBefore: 1
}

// Response
{
  success: true,
  message: "Email settings updated"
}
```

---

## 📊 Firestore Data Models

### Units Collection

```typescript
interface Unit {
  id: string;
  ownerId: string;          // Tenant isolation key
  name: string;
  address: string;
  zone?: string;
  wifiSSID?: string;
  wifiPassword?: string;
  cleanerPIN?: string;
  reviewLink?: string;
  status: 'active' | 'inactive';
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### Bookings Collection

```typescript
interface Booking {
  id: string;
  ownerId: string;          // Tenant isolation key
  unitId: string;
  guestName: string;
  guestCount: number;
  startDate: Timestamp;     // Check-in date
  endDate: Timestamp;       // Check-out date
  status: 'confirmed' | 'cancelled' | 'pending' | 'private';
  notes?: string;
  totalPrice?: number;
  currency?: string;
  source?: string;          // Booking source (Airbnb, Booking.com, Direct)
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

// Subcollection: /bookings/{bookingId}/guests
interface Guest {
  id: string;
  firstName: string;
  lastName: string;
  dateOfBirth?: Timestamp;
  nationality?: string;
  documentType?: string;
  documentNumber?: string;
  scannedAt?: Timestamp;
}
```

### Settings Collection

```typescript
interface Settings {
  ownerId: string;          // Document ID = ownerId
  
  // Personalization
  language: string;         // 'en', 'hr', 'de', etc.
  primaryColor: string;     // Hex color code
  backgroundTone: string;
  
  // PINs
  cleanerPIN?: string;
  resetPIN?: string;
  
  // House Rules (multi-language)
  houseRules: {
    en?: string;
    hr?: string;
    de?: string;
    // ... other languages
  };
  
  // Cleaner Checklist
  cleanerChecklist: string[];
  
  // AI Knowledge Base
  aiKnowledge: {
    concierge?: string;
    housekeeper?: string;
    tech?: string;
    guide?: string;
  };
  
  // Email Settings
  contactEmail?: string;
  ownerFirstName?: string;
  ownerLastName?: string;
  companyName?: string;
  emailNotifications: boolean;
}
```

### Cleaning Logs Collection

```typescript
interface CleaningLog {
  id: string;
  ownerId: string;
  unitId: string;
  cleanerName?: string;
  status: 'needs_cleaning' | 'in_progress' | 'completed';
  timestamp: Timestamp;
  notes?: string;
  photoUrls?: string[];
}
```

### Tablets Collection

```typescript
interface Tablet {
  id: string;
  ownerId: string;
  unitId: string;
  deviceId: string;
  appVersion: string;
  lastHeartbeat: Timestamp;
  batteryLevel?: number;
  isOnline: boolean;
  registeredAt: Timestamp;
}
```

---

## 🔄 API Versioning

### Current Version: v2

```javascript
// functions/api_versioning.js
const API_CONFIG = {
  currentVersion: "v2",
  supportedVersions: ["v1", "v2"],
  deprecatedVersions: ["v1"],
  sunsetDate: {
    v1: "2025-06-01"
  }
};
```

### Version Headers

```http
X-API-Version: v2
X-API-Deprecated: false
```

### Migration Guide

| v1 Feature | v2 Replacement |
|------------|----------------|
| Array-based guests | Subcollection guests |
| Single language rules | Multi-language houseRules |
| No revenue tracking | Full revenue analytics |

---

## ⚠️ Error Handling

### Standard Error Response

```typescript
interface ErrorResponse {
  code: string;
  message: string;
  details?: any;
}
```

### Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `unauthenticated` | 401 | No valid auth token |
| `permission-denied` | 403 | Insufficient permissions |
| `not-found` | 404 | Resource not found |
| `already-exists` | 409 | Resource already exists |
| `invalid-argument` | 400 | Invalid request parameters |
| `resource-exhausted` | 429 | Rate limit exceeded |
| `internal` | 500 | Server error |

### Error Handling Example

```javascript
try {
  const result = await httpsCallable(functions, 'createOwner')(data);
  console.log('Success:', result.data);
} catch (error) {
  if (error.code === 'functions/permission-denied') {
    console.error('You are not authorized');
  } else if (error.code === 'functions/already-exists') {
    console.error('Email already registered');
  } else {
    console.error('Unknown error:', error.message);
  }
}
```

---

## 🚦 Rate Limiting

### Default Limits

| Function Type | Limit |
|---------------|-------|
| `onCall` functions | 100 req/min per user |
| `onDocumentCreated` | No limit (event-driven) |
| `onSchedule` | Fixed schedule |

### Quota Exceeded Response

```javascript
{
  code: "resource-exhausted",
  message: "Rate limit exceeded. Try again in 60 seconds."
}
```

---

## 📚 SDK Integration

### Flutter/Dart

```dart
import 'package:cloud_functions/cloud_functions.dart';

final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

Future<void> createOwner(String email, String name) async {
  try {
    final callable = functions.httpsCallable('createOwner');
    final result = await callable.call({
      'email': email,
      'displayName': name,
      'password': 'tempPassword123',
    });
    print('Owner created: ${result.data}');
  } on FirebaseFunctionsException catch (e) {
    print('Error: ${e.code} - ${e.message}');
  }
}
```

### JavaScript/Web

```javascript
import { getFunctions, httpsCallable } from 'firebase/functions';

const functions = getFunctions(app, 'europe-west1');
const createOwner = httpsCallable(functions, 'createOwner');

try {
  const result = await createOwner({
    email: 'owner@example.com',
    displayName: 'Villa Owner',
    password: 'securePassword'
  });
  console.log('Success:', result.data);
} catch (error) {
  console.error('Error:', error.code, error.message);
}
```

---

```
═══════════════════════════════════════════════════════════════════════════════
                              © 2024-2025
                         ALL RIGHTS RESERVED
              UNAUTHORIZED COPYING IS LEGALLY PROSECUTED
═══════════════════════════════════════════════════════════════════════════════
```