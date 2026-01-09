# 🔥 VillaOS Firebase Documentation

## ⚠️ LEGAL NOTICE

```
═══════════════════════════════════════════════════════════════════════════════
                              PROPRIETARY SOFTWARE
═══════════════════════════════════════════════════════════════════════════════

This software and its configuration are PROPRIETARY and protected by copyright.

🔒 STRICTLY PROHIBITED:
   • Copying, reproduction or distribution of configuration files
   • Unauthorized access to Firebase project
   • Sharing credentials, API keys, or service accounts
   • Reverse engineering security rules

⚖️ LEGAL CONSEQUENCES:
   Unauthorized access or copying is subject to:
   • Civil liability for damages
   • Criminal prosecution under Computer Fraud laws
   • Trade secret violation liability

© 2024-2025 All rights reserved.
═══════════════════════════════════════════════════════════════════════════════
```

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Firebase Services](#firebase-services)
3. [Firestore Database](#firestore-database)
4. [Security Rules](#security-rules)
5. [Cloud Storage](#cloud-storage)
6. [Cloud Functions](#cloud-functions)
7. [Authentication](#authentication)
8. [Indexes](#indexes)
9. [Deployment](#deployment)

---

## 🎯 Project Overview

### Firebase Project Configuration

| Property | Value |
|----------|-------|
| **Project ID** | `vesta-lumina-system` |
| **Region** | `europe-west1` |
| **Node.js Version** | 20 |
| **Firestore Mode** | Native |
| **Auth Providers** | Email/Password |

### Services Used

```
┌─────────────────────────────────────────────────────────────────────┐
│                      FIREBASE SERVICES                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  🔐 AUTHENTICATION          │  📊 CLOUD FIRESTORE                   │
│  • Email/Password login     │  • 15+ collections                    │
│  • Custom claims (JWT)      │  • Multi-tenant isolation             │
│  • Role-based access        │  • 10 composite indexes               │
│                             │                                       │
│  📁 CLOUD STORAGE           │  ⚡ CLOUD FUNCTIONS                   │
│  • Gallery images           │  • 20 functions                       │
│  • Signatures               │  • Node.js 20 runtime                 │
│  • APK updates              │  • Scheduled tasks                    │
│  • Screensaver images       │  • Firestore triggers                 │
│                             │                                       │
│  🌐 HOSTING                 │  🔒 SECURITY                          │
│  • Flutter Web SPA          │  • Firestore rules (235 lines)        │
│  • Custom domain ready      │  • Storage rules (93 lines)           │
│                             │  • App Check (ready)                  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🗄️ Firestore Database

### Collections Architecture

```
firestore/
│
├── 🔷 super_admins/           # System administrators
│   └── {email}/
│       ├── active: boolean
│       └── addedAt: timestamp
│
├── 🔷 admin_logs/             # Audit trail (write-only)
│   └── {logId}/
│       ├── adminEmail: string
│       ├── action: string
│       ├── details: map
│       ├── timestamp: timestamp
│       └── ip: string?
│
├── 🔷 backups/                # Backup records (write-only)
│   └── {backupId}/
│       ├── timestamp: timestamp
│       ├── collections: array
│       ├── status: string
│       └── size: string
│
├── 🔷 app_config/             # System configuration
│   └── {configId}/
│       └── [configuration data]
│
├── 🔷 tenant_links/           # Tenant ID mappings
│   └── {tenantId}/
│       └── [link data]
│
├── 🔷 settings/               # Owner settings (per tenant)
│   └── {ownerId}/
│       ├── language: string
│       ├── primaryColor: string
│       ├── backgroundTone: string
│       ├── cleanerPIN: string?
│       ├── resetPIN: string?
│       ├── houseRules: map<lang, string>
│       ├── cleanerChecklist: array<string>
│       ├── aiKnowledge: map
│       ├── contactEmail: string?
│       ├── ownerFirstName: string?
│       ├── ownerLastName: string?
│       ├── companyName: string?
│       └── emailNotifications: boolean
│
├── 🔷 units/                  # Rental units (per tenant)
│   └── {unitId}/
│       ├── ownerId: string    # TENANT ISOLATION KEY
│       ├── name: string
│       ├── address: string
│       ├── zone: string?
│       ├── wifiSSID: string?
│       ├── wifiPassword: string?
│       ├── cleanerPIN: string?
│       ├── reviewLink: string?
│       ├── status: string
│       ├── createdAt: timestamp
│       └── updatedAt: timestamp
│
├── 🔷 bookings/               # Reservations (per tenant)
│   └── {bookingId}/
│       ├── ownerId: string    # TENANT ISOLATION KEY
│       ├── unitId: string
│       ├── guestName: string
│       ├── guestCount: number
│       ├── startDate: timestamp
│       ├── endDate: timestamp
│       ├── status: string
│       ├── notes: string?
│       ├── totalPrice: number?
│       ├── currency: string?
│       ├── source: string?
│       ├── createdAt: timestamp
│       ├── updatedAt: timestamp
│       │
│       └── 📂 guests/         # SUBCOLLECTION
│           └── {guestId}/
│               ├── firstName: string
│               ├── lastName: string
│               ├── dateOfBirth: timestamp?
│               ├── nationality: string?
│               ├── documentType: string?
│               ├── documentNumber: string?
│               └── scannedAt: timestamp?
│
├── 🔷 archived_bookings/      # Historical bookings
│   └── {bookingId}/
│       └── [same structure as bookings]
│       └── 📂 guests/
│
├── 🔷 signatures/             # Guest signatures
│   └── {signatureId}/
│       ├── ownerId: string
│       ├── bookingId: string
│       ├── guestId: string
│       ├── signatureUrl: string
│       ├── signedAt: timestamp
│       └── ipAddress: string?
│
├── 🔷 check_ins/              # Check-in records
│   └── {checkInId}/
│       ├── ownerId: string
│       ├── bookingId: string
│       ├── unitId: string
│       ├── timestamp: timestamp
│       └── method: string
│
├── 🔷 cleaning_logs/          # Cleaning records
│   └── {logId}/
│       ├── ownerId: string
│       ├── unitId: string
│       ├── cleanerName: string?
│       ├── status: string
│       ├── timestamp: timestamp
│       ├── notes: string?
│       └── photoUrls: array?
│
├── 🔷 feedback/               # Guest feedback
│   └── {feedbackId}/
│       ├── ownerId: string
│       ├── unitId: string
│       ├── bookingId: string?
│       ├── rating: number
│       ├── comment: string?
│       └── timestamp: timestamp
│
├── 🔷 gallery/                # Gallery metadata
│   └── {imageId}/
│       ├── ownerId: string
│       ├── unitId: string?
│       ├── url: string
│       ├── order: number
│       └── uploadedAt: timestamp
│
├── 🔷 screensaver_images/     # Screensaver images
│   └── {imageId}/
│       ├── ownerId: string
│       ├── url: string
│       ├── order: number
│       └── uploadedAt: timestamp
│
├── 🔷 ai_logs/                # AI conversation logs
│   └── {logId}/
│       ├── ownerId: string
│       ├── unitId: string
│       ├── question: string
│       ├── response: string
│       ├── persona: string
│       └── timestamp: timestamp
│
├── 🔷 tablets/                # Registered tablets
│   └── {tabletId}/
│       ├── ownerId: string
│       ├── unitId: string
│       ├── deviceId: string
│       ├── appVersion: string
│       ├── lastHeartbeat: timestamp
│       ├── batteryLevel: number?
│       ├── isOnline: boolean
│       └── registeredAt: timestamp
│
├── 🔷 system_notifications/   # System-wide notifications
│   └── {notificationId}/
│       ├── title: string
│       ├── message: string
│       ├── type: string
│       ├── active: boolean
│       └── createdAt: timestamp
│
└── 🔷 apk_updates/            # APK version management
    └── {updateId}/
        ├── version: string
        ├── downloadUrl: string
        ├── releaseNotes: string
        ├── mandatory: boolean
        └── createdAt: timestamp
```

---

## 🔐 Security Rules

### Firestore Rules (235 lines)

**File:** `firestore.rules`

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // =====================================================
    // HELPER FUNCTIONS
    // =====================================================
    
    // Check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Check if user is super admin
    function isSuperAdmin() {
      return isAuthenticated() && 
        (request.auth.token.email == 'vestaluminasystem@gmail.com' ||
         exists(/databases/$(database)/documents/super_admins/$(request.auth.token.email)));
    }
    
    // Check if user is web panel (owner role)
    function isWebPanel() {
      return isAuthenticated() && 
        request.auth.token.role == 'owner';
    }
    
    // Check if user is tablet
    function isTablet() {
      return isAuthenticated() && 
        request.auth.token.role == 'tablet';
    }
    
    // Check if user owns the specified tenant
    function isOwnerOf(ownerId) {
      return isAuthenticated() && 
        request.auth.token.ownerId == ownerId;
    }
    
    // Check if user owns the existing resource
    function isResourceOwner() {
      return isAuthenticated() && 
        resource.data.ownerId == request.auth.token.ownerId;
    }
    
    // Check if user owns the incoming resource
    function isRequestOwner() {
      return isAuthenticated() && 
        request.resource.data.ownerId == request.auth.token.ownerId;
    }

    // =====================================================
    // COLLECTION RULES
    // =====================================================

    // SUPER ADMINS - Only primary admin can write
    match /super_admins/{email} {
      allow read: if isSuperAdmin();
      allow write: if isAuthenticated() && 
        request.auth.token.email == 'vestaluminasystem@gmail.com';
    }

    // BACKUPS - Cloud Functions only
    match /backups/{backupId} {
      allow read: if isSuperAdmin();
      allow write: if false;
    }

    // ADMIN LOGS - Cloud Functions only
    match /admin_logs/{logId} {
      allow read: if isSuperAdmin();
      allow write: if false;
    }

    // APP CONFIG - Super admin manages
    match /app_config/{doc} {
      allow read: if isAuthenticated();
      allow write: if isSuperAdmin();
    }

    // TENANT LINKS - Super admin manages
    match /tenant_links/{tenantId} {
      allow read: if isSuperAdmin() || isOwnerOf(tenantId);
      allow write: if isSuperAdmin();
    }

    // SETTINGS - Owner's settings
    match /settings/{ownerId} {
      allow read: if isSuperAdmin() || isOwnerOf(ownerId);
      allow write: if isSuperAdmin() || isOwnerOf(ownerId);
    }

    // UNITS - Tenant isolated
    match /units/{unitId} {
      allow read: if isSuperAdmin() || isResourceOwner() || 
        (isTablet() && resource.data.ownerId == request.auth.token.ownerId);
      allow create: if isWebPanel() && isRequestOwner();
      allow update, delete: if isWebPanel() && isResourceOwner();
    }

    // BOOKINGS + GUESTS SUBCOLLECTION
    match /bookings/{bookingId} {
      allow read: if isSuperAdmin() || isResourceOwner() || 
        (isTablet() && resource.data.ownerId == request.auth.token.ownerId);
      allow create: if (isWebPanel() || isTablet()) && isRequestOwner();
      allow update: if (isWebPanel() || isTablet()) && isResourceOwner();
      allow delete: if isWebPanel() && isResourceOwner();
      
      // Guests subcollection
      match /guests/{guestId} {
        allow read: if isSuperAdmin() || 
          get(/databases/$(database)/documents/bookings/$(bookingId)).data.ownerId == request.auth.token.ownerId;
        allow write: if isWebPanel() || isTablet();
      }
    }

    // SIGNATURES
    match /signatures/{signatureId} {
      allow read: if isSuperAdmin() || isResourceOwner();
      allow create: if (isWebPanel() || isTablet()) && isRequestOwner();
      allow update, delete: if isWebPanel() && isResourceOwner();
    }

    // CHECK-INS
    match /check_ins/{checkInId} {
      allow read: if isSuperAdmin() || isResourceOwner();
      allow create: if isTablet() && isRequestOwner();
      allow update: if (isWebPanel() || isTablet()) && isResourceOwner();
      allow delete: if isWebPanel() && isResourceOwner();
    }

    // CLEANING LOGS
    match /cleaning_logs/{logId} {
      allow read: if isSuperAdmin() || isResourceOwner();
      allow create: if isTablet() && isRequestOwner();
      allow update, delete: if isWebPanel() && isResourceOwner();
    }

    // FEEDBACK
    match /feedback/{feedbackId} {
      allow read: if isSuperAdmin() || isResourceOwner();
      allow create: if isTablet() && isRequestOwner();
      allow update, delete: if isWebPanel() && isResourceOwner();
    }

    // GALLERY
    match /gallery/{imageId} {
      allow read: if isSuperAdmin() || isResourceOwner() || 
        (isTablet() && resource.data.ownerId == request.auth.token.ownerId);
      allow create: if isWebPanel() && isRequestOwner();
      allow update, delete: if isWebPanel() && isResourceOwner();
    }

    // AI LOGS - Tablet creates, immutable
    match /ai_logs/{logId} {
      allow read: if isSuperAdmin() || isResourceOwner();
      allow create: if isTablet() && isRequestOwner();
      allow update, delete: if false;
    }

    // TABLETS
    match /tablets/{tabletId} {
      allow read: if isSuperAdmin() || isResourceOwner();
      allow create: if false; // Only Cloud Functions
      allow update: if isSuperAdmin() || 
        (isTablet() && resource.data.ownerId == request.auth.token.ownerId);
      allow delete: if isSuperAdmin();
    }

    // ARCHIVED BOOKINGS
    match /archived_bookings/{bookingId} {
      allow read: if isSuperAdmin() || isResourceOwner();
      allow write: if isWebPanel() && isResourceOwner();
      
      match /guests/{guestId} {
        allow read: if isSuperAdmin() || 
          get(/databases/$(database)/documents/archived_bookings/$(bookingId)).data.ownerId == request.auth.token.ownerId;
        allow write: if isWebPanel();
      }
    }

    // SYSTEM NOTIFICATIONS - Public read
    match /system_notifications/{notificationId} {
      allow read: if isAuthenticated();
      allow write: if isSuperAdmin();
    }

    // APK UPDATES - Public read
    match /apk_updates/{updateId} {
      allow read: if isAuthenticated();
      allow write: if isSuperAdmin();
    }

    // SCREENSAVER IMAGES
    match /screensaver_images/{imageId} {
      allow read: if isSuperAdmin() || isResourceOwner() || 
        (isTablet() && resource.data.ownerId == request.auth.token.ownerId);
      allow create: if isWebPanel() && isRequestOwner();
      allow update, delete: if isWebPanel() && isResourceOwner();
    }

    // CATCH-ALL DENY
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## 📁 Cloud Storage

### Storage Rules (93 lines)

**File:** `storage.rules`

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // =====================================================
    // HELPER FUNCTIONS
    // =====================================================
    
    function isSuperAdmin() {
      return request.auth != null && 
             request.auth.token.email == 'vestaluminasystem@gmail.com';
    }
    
    function isOwnerOf(ownerId) {
      return request.auth != null && 
             request.auth.token.ownerId == ownerId;
    }
    
    function isTablet() {
      return request.auth != null && 
             request.auth.token.role == 'tablet';
    }
    
    function isWebPanel() {
      return request.auth != null && 
             request.auth.token.ownerId != null &&
             request.auth.token.role != 'tablet';
    }
    
    // =====================================================
    // STORAGE PATHS
    // =====================================================
    
    // SIGNATURES - Guest signatures from tablet
    // Path: /signatures/{ownerId}/{filename}
    match /signatures/{ownerId}/{filename} {
      allow write: if isTablet() && isOwnerOf(ownerId);
      allow read, delete: if isOwnerOf(ownerId) || isSuperAdmin();
    }
    
    // SCREENSAVER - Gallery images for tablet
    // Path: /screensaver/{ownerId}/{imageId}
    match /screensaver/{ownerId}/{imageId} {
      allow write: if isWebPanel() && isOwnerOf(ownerId);
      allow read: if isOwnerOf(ownerId) || isSuperAdmin();
      allow delete: if isWebPanel() && isOwnerOf(ownerId);
    }
    
    // APK FILES - Super Admin uploads
    // Path: /apk/{filename}
    match /apk/{filename} {
      allow write: if isSuperAdmin();
      allow read: if request.auth != null;
    }
    
    // GALLERY - Legacy path
    // Path: /gallery/{ownerId}/{filename}
    match /gallery/{ownerId}/{filename} {
      allow write: if isWebPanel() && isOwnerOf(ownerId);
      allow read: if isOwnerOf(ownerId) || isSuperAdmin();
      allow delete: if isWebPanel() && isOwnerOf(ownerId);
    }
    
    // CATCH-ALL DENY
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

### Storage Structure

```
storage/
├── 📁 signatures/
│   └── {ownerId}/
│       └── {bookingId}_{guestId}_{timestamp}.png
│
├── 📁 screensaver/
│   └── {ownerId}/
│       └── {imageId}.jpg
│
├── 📁 gallery/
│   └── {ownerId}/
│       └── {unitId}/
│           └── {imageId}.jpg
│
└── 📁 apk/
    └── villa_tablet_v{version}.apk
```

---

## ⚡ Cloud Functions

### Functions Configuration

**File:** `firebase.json`

```json
{
  "functions": {
    "source": "functions",
    "runtime": "nodejs20",
    "predeploy": ["npm --prefix functions run lint"]
  }
}
```

### Secrets Management

| Secret | Purpose |
|--------|---------|
| `GEMINI_API_KEY` | AI translation |
| `SMTP_HOST` | Email server |
| `SMTP_USER` | Email username |
| `SMTP_PASS` | Email password |

### Function Categories

```
functions/
├── index.js                    # Main functions file (1,265 lines)
│   │
│   ├── 👤 OWNER MANAGEMENT
│   │   ├── createOwner
│   │   ├── linkTenantId
│   │   ├── listOwners
│   │   ├── deleteOwner
│   │   ├── resetOwnerPassword
│   │   └── toggleOwnerStatus
│   │
│   ├── 🔄 TRANSLATION
│   │   ├── translateHouseRules
│   │   └── translateNotification
│   │
│   ├── 📱 TABLET
│   │   ├── registerTablet
│   │   └── tabletHeartbeat
│   │
│   ├── 👨‍💼 SUPER ADMIN
│   │   ├── addSuperAdmin
│   │   ├── removeSuperAdmin
│   │   ├── listSuperAdmins
│   │   └── getAdminLogs
│   │
│   ├── 💾 BACKUP
│   │   ├── scheduledBackup (onSchedule)
│   │   └── manualBackup
│   │
│   └── 📧 EMAIL
│       ├── sendEmailNotification
│       ├── onBookingCreated (trigger)
│       ├── sendCheckInReminders (onSchedule)
│       └── updateEmailSettings
│
└── api_versioning.js           # API version config
```

---

## 🔑 Authentication

### Custom Claims Structure

```javascript
// Set by Cloud Functions when owner is created
{
  ownerId: "tenant-uuid",     // Tenant isolation key
  role: "owner"               // Role: owner | superadmin | tablet
}
```

### Setting Custom Claims

```javascript
// In Cloud Function
await admin.auth().setCustomUserClaims(uid, {
  ownerId: tenantId,
  role: 'owner'
});
```

### Verifying Claims in Rules

```javascript
// Firestore rule
function isOwnerOf(ownerId) {
  return request.auth.token.ownerId == ownerId;
}

// Storage rule
function isOwnerOf(ownerId) {
  return request.auth.token.ownerId == ownerId;
}
```

---

## 📊 Indexes

### Composite Indexes (10 indexes)

**File:** `firestore.indexes.json`

```json
{
  "indexes": [
    {
      "collectionGroup": "bookings",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "unitId", "order": "ASCENDING" },
        { "fieldPath": "endDate", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "bookings",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "ownerId", "order": "ASCENDING" },
        { "fieldPath": "startDate", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "bookings",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "ownerId", "order": "ASCENDING" },
        { "fieldPath": "unitId", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "bookings",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "endDate", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "signatures",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "bookingId", "order": "ASCENDING" },
        { "fieldPath": "signedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "signatures",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "ownerId", "order": "ASCENDING" },
        { "fieldPath": "signedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "cleaning_logs",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "ownerId", "order": "ASCENDING" },
        { "fieldPath": "unitId", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "feedback",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "ownerId", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "screensaver_images",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "ownerId", "order": "ASCENDING" },
        { "fieldPath": "uploadedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "ai_logs",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "ownerId", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    }
  ]
}
```

### Index Usage

| Index | Query Pattern |
|-------|---------------|
| bookings (unitId, endDate) | Calendar view by unit |
| bookings (ownerId, startDate) | Owner's upcoming bookings |
| bookings (ownerId, unitId) | Filter by owner and unit |
| bookings (status, endDate) | Active bookings ending soon |
| signatures (bookingId, signedAt) | Signatures per booking |
| signatures (ownerId, signedAt) | All owner signatures |
| cleaning_logs (ownerId, unitId, timestamp) | Cleaning history |
| feedback (ownerId, timestamp) | Recent feedback |
| screensaver_images (ownerId, uploadedAt) | Screensaver order |
| ai_logs (ownerId, timestamp) | AI conversation history |

---

## 🚀 Deployment

### Deploy Commands

```bash
# Deploy all
firebase deploy

# Deploy specific service
firebase deploy --only firestore:rules
firebase deploy --only storage
firebase deploy --only functions
firebase deploy --only hosting

# Deploy specific function
firebase deploy --only functions:createOwner

# Deploy indexes
firebase deploy --only firestore:indexes
```

### CI/CD Configuration

**File:** `firebase.json`

```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "storage": {
    "rules": "storage.rules"
  },
  "functions": {
    "source": "functions",
    "runtime": "nodejs20",
    "predeploy": [
      "npm --prefix \"$RESOURCE_DIR\" run lint"
    ]
  },
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

### Environment Setup

```bash
# Set secrets
firebase functions:secrets:set GEMINI_API_KEY
firebase functions:secrets:set SMTP_HOST
firebase functions:secrets:set SMTP_USER
firebase functions:secrets:set SMTP_PASS
```

---

## 📈 Monitoring

### Firebase Console URLs

| Service | URL |
|---------|-----|
| Firestore | `console.firebase.google.com/project/[PROJECT_ID]/firestore` |
| Auth | `console.firebase.google.com/project/[PROJECT_ID]/authentication` |
| Storage | `console.firebase.google.com/project/[PROJECT_ID]/storage` |
| Functions | `console.firebase.google.com/project/[PROJECT_ID]/functions` |
| Hosting | `console.firebase.google.com/project/[PROJECT_ID]/hosting` |

### Logging

```javascript
// Cloud Function logging
const functions = require('firebase-functions');

// Info level
functions.logger.info('Info message', { structuredData: true });

// Error level
functions.logger.error('Error message', { error: err });

// View in Cloud Console
// console.cloud.google.com/logs
```

---

## 🔒 Security Checklist

| Item | Status | Notes |
|------|--------|-------|
| Firestore rules deployed | ✅ | 235 lines |
| Storage rules deployed | ✅ | 93 lines |
| Custom claims configured | ✅ | ownerId, role |
| Indexes created | ✅ | 10 composite |
| Secrets configured | ✅ | 4 secrets |
| Backup scheduled | ✅ | Daily 03:00 UTC |
| Audit logging | ✅ | admin_logs collection |
| Rate limiting | ✅ | Cloud Functions default |
| App Check | ⏳ | Ready for activation |

---

```
═══════════════════════════════════════════════════════════════════════════════
                              © 2024-2025
                         ALL RIGHTS RESERVED
              UNAUTHORIZED COPYING IS LEGALLY PROSECUTED
═══════════════════════════════════════════════════════════════════════════════
```