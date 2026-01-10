# 🔥 Firebase Documentation

> **VillaOS Admin Panel** | **Version 2.2.0** | **January 2026**

---

## ⚠️ LEGAL NOTICE

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                              PROPRIETARY SOFTWARE                             ║
║  This documentation and associated software are protected by copyright law.   ║
║  Unauthorized use, reproduction, or distribution is strictly prohibited.      ║
║  © 2025-2026 All rights reserved.                                             ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## 📋 Table of Contents

1. [Project Configuration](#-project-configuration)
2. [Firestore Collections](#-firestore-collections)
3. [Security Rules](#-security-rules)
4. [Composite Indexes](#-composite-indexes)
5. [Cloud Functions](#-cloud-functions)
6. [Storage Structure](#-storage-structure)
7. [Deployment Guide](#-deployment-guide)

---

## ⚙️ Project Configuration

### Firebase Project Details

| Property | Value |
|----------|-------|
| **Project ID** | `vls-admin` |
| **Project Name** | Vesta Lumina System |
| **Region** | `europe-west3` (Frankfurt) |
| **Hosting URL** | `https://vls-admin.web.app` |
| **Functions URL** | `https://europe-west3-vls-admin.cloudfunctions.net/` |

### Services Used

| Service | Purpose | Status |
|---------|---------|--------|
| **Authentication** | User login, JWT tokens | ✅ Active |
| **Cloud Firestore** | Database | ✅ Active |
| **Cloud Storage** | File storage | ✅ Active |
| **Cloud Functions** | Serverless API | ✅ Active |
| **Hosting** | Web app hosting | ✅ Active |

### Environment Files

```
.firebaserc                 # Project configuration
firebase.json               # Deploy settings
firestore.rules             # Database security rules
firestore.indexes.json      # Composite indexes
storage.rules               # Storage security rules
```

---

## 📊 Firestore Collections

### Collection Overview (16 Collections)

```
firestore/
│
├── 👤 owners/                    # Owner/tenant accounts
├── 🏠 units/                     # Accommodation units
├── 📅 bookings/                  # Reservations
├── ⚙️ settings/                  # Tenant settings
├── 🧹 cleaning_logs/             # Cleaning records
├── 📱 tablets/                   # Registered tablet devices
├── ✍️ signatures/                # Guest document signatures
├── 💬 feedback/                  # Guest feedback
├── 🖼️ screensaver_images/        # Gallery images metadata
├── 🤖 ai_logs/                   # AI conversation logs
├── 📢 system_notifications/      # System-wide announcements
├── 📦 apk_updates/               # Tablet APK versions
├── 📝 admin_logs/                # Audit trail
├── 👑 super_admins/              # Super admin list
├── 🔗 tenant_links/              # Tenant ID mappings
└── 🎫 activation_codes/          # Account activation codes
```

### Collection Details

#### `owners/{uid}`
```javascript
{
  uid: "firebase-auth-uid",
  email: "owner@example.com",
  displayName: "Villa Owner",
  tenantId: "TENANT001",
  status: "active" | "disabled",
  createdAt: Timestamp,
  lastLogin: Timestamp
}
```

#### `units/{unitId}`
```javascript
{
  id: "unit-uuid",
  ownerId: "TENANT001",          // 🔑 Tenant isolation key
  name: "Villa Sunset",
  address: "123 Beach Road, Split",
  zone: "Zone A",
  wifiSSID: "VillaSunset_WiFi",
  wifiPassword: "welcome123",
  cleanerPIN: "1234",
  reviewLink: "https://...",
  status: "active",
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### `bookings/{bookingId}`
```javascript
{
  id: "booking-uuid",
  ownerId: "TENANT001",          // 🔑 Tenant isolation key
  unitId: "unit-uuid",
  guestName: "John Doe",
  guestCount: 2,
  startDate: Timestamp,
  endDate: Timestamp,
  checkInTime: "15:00",
  checkOutTime: "10:00",
  status: "confirmed" | "pending" | "cancelled" | "private",
  source: "airbnb" | "booking" | "direct" | "other",
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

#### `settings/{ownerId}`
```javascript
{
  ownerId: "TENANT001",
  appLanguage: "en",             // 11 supported languages
  themeColor: "gold",            // 10 color options
  themeMode: "dark2",            // 6 background options
  cleanerPIN: "0000",
  resetPIN: "1234",
  houseRules: {
    en: "No smoking. No parties...",
    hr: "Zabranjeno pušenje...",
    // ... other languages
  },
  cleanerChecklist: [
    "Check bedsheets",
    "Clean bathroom",
    "Restock supplies"
  ],
  aiKnowledge: {
    concierge: "Local restaurant recommendations...",
    housekeeper: "Cleaning product locations...",
    tech: "WiFi troubleshooting...",
    guide: "Beach directions..."
  },
  emailNotifications: true,
  contactEmail: "owner@example.com",
  companyName: "Villa Management Ltd",
  checkInTime: "15:00",
  checkOutTime: "10:00"
}
```

#### `tablets/{tabletId}`
```javascript
{
  id: "tablet-uuid",
  ownerId: "TENANT001",
  unitId: "unit-uuid",
  deviceId: "android-device-id",
  appVersion: "1.0.0",
  lastHeartbeat: Timestamp,
  batteryLevel: 85,
  isCharging: true,
  status: "online" | "offline",
  registeredAt: Timestamp
}
```

#### `super_admins/{email}`
```javascript
{
  email: "admin@example.com",
  addedAt: Timestamp,
  addedBy: "primary-admin@example.com"
}
```

#### `admin_logs/{logId}`
```javascript
{
  action: "CREATE_OWNER" | "DELETE_OWNER" | "TOGGLE_STATUS" | ...,
  performedBy: "admin@example.com",
  targetId: "affected-resource-id",
  details: { ... },
  timestamp: Timestamp
}
```

---

## 🔐 Security Rules

### Firestore Rules (235 lines)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ═══════════════════════════════════════════════════════════════
    // HELPER FUNCTIONS
    // ═══════════════════════════════════════════════════════════════
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isSuperAdmin() {
      return isAuthenticated() && 
        (request.auth.token.email == 'vestaluminasystem@gmail.com' ||
         exists(/databases/$(database)/documents/super_admins/$(request.auth.token.email)));
    }
    
    function isOwnerOf(ownerId) {
      return isAuthenticated() && 
        request.auth.token.ownerId == ownerId;
    }
    
    function isResourceOwner() {
      return isAuthenticated() && 
        resource.data.ownerId == request.auth.token.ownerId;
    }

    // ═══════════════════════════════════════════════════════════════
    // COLLECTION RULES
    // ═══════════════════════════════════════════════════════════════
    
    // Units - Owner can CRUD their own units
    match /units/{unitId} {
      allow read: if isResourceOwner() || isSuperAdmin();
      allow create: if isAuthenticated() && 
                    request.resource.data.ownerId == request.auth.token.ownerId;
      allow update, delete: if isResourceOwner() || isSuperAdmin();
    }
    
    // Bookings - Owner can CRUD their own bookings
    match /bookings/{bookingId} {
      allow read: if isResourceOwner() || isSuperAdmin();
      allow create: if isAuthenticated() && 
                    request.resource.data.ownerId == request.auth.token.ownerId;
      allow update, delete: if isResourceOwner() || isSuperAdmin();
    }
    
    // Settings - Owner can read/write their own settings
    match /settings/{ownerId} {
      allow read, write: if isOwnerOf(ownerId) || isSuperAdmin();
    }
    
    // Super Admins - Only primary admin can write
    match /super_admins/{email} {
      allow read: if isSuperAdmin();
      allow write: if request.auth.token.email == 'vestaluminasystem@gmail.com';
    }
    
    // Admin Logs - Super admins only
    match /admin_logs/{logId} {
      allow read: if isSuperAdmin();
      allow write: if false; // Only Cloud Functions can write
    }
  }
}
```

### Storage Rules (93 lines)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Helper functions
    function isSuperAdmin() {
      return request.auth != null && 
             request.auth.token.email == 'vestaluminasystem@gmail.com';
    }
    
    function isOwnerOf(ownerId) {
      return request.auth != null && 
             request.auth.token.ownerId == ownerId;
    }
    
    // Gallery images - Owner access only
    match /gallery/{ownerId}/{allPaths=**} {
      allow read: if isOwnerOf(ownerId) || isSuperAdmin();
      allow write: if isOwnerOf(ownerId) &&
                   request.resource.size < 5 * 1024 * 1024 &&
                   request.resource.contentType.matches('image/.*');
    }
    
    // APK uploads - Super admin only
    match /apk/{version}/{fileName} {
      allow read: if request.auth != null;
      allow write: if isSuperAdmin();
    }
    
    // Signatures - Owner access only
    match /signatures/{ownerId}/{allPaths=**} {
      allow read: if isOwnerOf(ownerId) || isSuperAdmin();
      allow write: if isOwnerOf(ownerId);
    }
  }
}
```

---

## 📇 Composite Indexes

### Active Indexes (11 total)

| Collection | Fields | Purpose |
|------------|--------|---------|
| `bookings` | `ownerId` ↑, `startDate` ↑ | Calendar queries |
| `bookings` | `ownerId` ↑, `unitId` ↑ | Unit bookings |
| `bookings` | `unitId` ↑, `endDate` ↑ | Overlap check |
| `bookings` | `status` ↑, `endDate` ↑ | Status filters |
| `units` | `ownerId` ↑, `createdAt` ↑ | Unit listing |
| `cleaning_logs` | `ownerId` ↑, `unitId` ↑, `timestamp` ↓ | Cleaning history |
| `feedback` | `ownerId` ↑, `timestamp` ↓ | Feedback listing |
| `signatures` | `ownerId` ↑, `signedAt` ↓ | Signature history |
| `signatures` | `bookingId` ↑, `signedAt` ↓ | Booking signatures |
| `screensaver_images` | `ownerId` ↑, `uploadedAt` ↓ | Gallery sorting |
| `ai_logs` | `ownerId` ↑, `timestamp` ↓ | AI log history |

### Index Configuration File

```json
// firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "bookings",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "ownerId", "order": "ASCENDING" },
        { "fieldPath": "startDate", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "units",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "ownerId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "ASCENDING" }
      ]
    }
    // ... additional indexes
  ]
}
```

---

## ⚡ Cloud Functions

### Function Summary (20 Functions)

| Category | Count | Functions |
|----------|-------|-----------|
| Owner Management | 6 | createOwner, linkTenantId, listOwners, deleteOwner, resetOwnerPassword, toggleOwnerStatus |
| Super Admin | 4 | addSuperAdmin, removeSuperAdmin, listSuperAdmins, getAdminLogs |
| Translation | 2 | translateHouseRules, translateNotification |
| Tablet | 2 | registerTablet, tabletHeartbeat |
| Email | 4 | sendEmailNotification, onBookingCreated, sendCheckInReminders, updateEmailSettings |
| Backup | 2 | scheduledBackup, manualBackup |

### Deployment Configuration

```json
// firebase.json
{
  "functions": {
    "source": "functions",
    "runtime": "nodejs20",
    "region": "europe-west3"
  }
}
```

---

## 📦 Storage Structure

```
storage/
├── gallery/{ownerId}/           # Gallery images
│   ├── unit_{unitId}/
│   │   └── image_001.jpg
│   └── screensaver/
│       └── slide_001.jpg
│
├── signatures/{ownerId}/        # Guest signatures
│   └── {bookingId}/
│       └── signature_{guestId}.png
│
├── apk/{version}/               # Tablet APK files
│   └── villaos_tablet_v1.0.0.apk
│
└── backups/{date}/              # Database backups
    └── backup_2026-01-10.json
```

---

## 🚀 Deployment Guide

### Prerequisites

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Select project
firebase use vls-admin
```

### Deploy Commands

```bash
# Deploy everything
firebase deploy

# Deploy only hosting (web app)
flutter build web --release
firebase deploy --only hosting

# Deploy only Firestore rules
firebase deploy --only firestore:rules

# Deploy only indexes
firebase deploy --only firestore:indexes

# Deploy only Cloud Functions
firebase deploy --only functions

# Deploy only Storage rules
firebase deploy --only storage
```

### Production Checklist

- [ ] All Firestore indexes enabled
- [ ] Security rules deployed
- [ ] Storage rules deployed
- [ ] Cloud Functions deployed
- [ ] Web app built in release mode
- [ ] Environment variables configured
- [ ] Super admin account created

---

## 📜 License Notice

```
This documentation is part of the VillaOS proprietary software.
Unauthorized reproduction, distribution, or use is strictly prohibited.

© 2025-2026 Neven Roksa (@nroxa92). All rights reserved.
```