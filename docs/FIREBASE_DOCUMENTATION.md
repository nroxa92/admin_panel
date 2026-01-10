# 🔥 Firebase Documentation

> **Vesta Lumina Admin Panel** | **Version 0.0.9 Beta** | **January 2026**
> **Part of Vesta Lumina System**

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
| **Primary Admin** | `vestaluminasystem@gmail.com` |

### Services Used

| Service | Purpose | Status |
|---------|---------|--------|
| **Authentication** | User login, JWT tokens, custom claims | ✅ Active |
| **Cloud Firestore** | NoSQL database (16 collections) | ✅ Active |
| **Cloud Storage** | File storage (gallery, signatures, APK) | ✅ Active |
| **Cloud Functions** | Serverless API (20 functions) | ✅ Active |
| **Hosting** | Web app hosting | ✅ Active |

### Configuration Files

| File | Description | Lines |
|------|-------------|-------|
| `.firebaserc` | Project configuration | - |
| `firebase.json` | Deploy settings | - |
| `firestore.rules` | Database security rules | 235 |
| `firestore.indexes.json` | Composite indexes | 86 |
| `storage.rules` | Storage security rules | 93 |

---

## 📊 Firestore Collections

### Collection Overview (16 Collections)

| # | Collection | Description | Documents |
|---|------------|-------------|-----------|
| 1 | `owners` | Owner/tenant accounts | Per owner |
| 2 | `units` | Accommodation units | Per unit |
| 3 | `bookings` | Reservations | Per booking |
| 4 | `settings` | Tenant settings | Per owner |
| 5 | `cleaning_logs` | Cleaning records | Per log entry |
| 6 | `tablets` | Registered tablet devices | Per tablet |
| 7 | `signatures` | Guest document signatures | Per signature |
| 8 | `feedback` | Guest feedback | Per feedback |
| 9 | `screensaver_images` | Gallery images metadata | Per image |
| 10 | `ai_logs` | AI conversation logs | Per conversation |
| 11 | `system_notifications` | System-wide announcements | Per notification |
| 12 | `apk_updates` | Tablet APK versions | Per version |
| 13 | `admin_logs` | Audit trail | Per action |
| 14 | `super_admins` | Super admin list | Per admin |
| 15 | `tenant_links` | Tenant ID mappings | Per tenant |
| 16 | `activation_codes` | Account activation codes | Per code |

### Collection Details

#### `owners/{uid}`
```javascript
{
  uid: "firebase-auth-uid",
  email: "owner@example.com",
  displayName: "Villa Owner",
  tenantId: "TENANT001",
  status: "active",              // active | disabled
  emailNotifications: true,
  createdAt: Timestamp,
  lastLogin: Timestamp
}
```

#### `units/{unitId}`
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
  reviewLink: "https://airbnb.com/rooms/...",
  contactOptions: {
    phone: "+385 91 123 4567",
    whatsapp: "+385 91 123 4567"
  },
  status: "active",
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### `bookings/{bookingId}`
```javascript
{
  id: "booking-uuid",
  ownerId: "TENANT001",          // Tenant isolation key
  unitId: "unit-uuid",
  guestName: "John Doe",
  guestCount: 2,
  startDate: Timestamp,
  endDate: Timestamp,
  checkInTime: "15:00",
  checkOutTime: "10:00",
  status: "confirmed",           // confirmed | pending | cancelled | private | blocked
  source: "airbnb",              // airbnb | booking | direct | other
  totalPrice: 500.00,
  currency: "EUR",
  notes: "Early check-in requested",
  isScanned: true,
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
  appLanguage: "en",
  themeColor: "gold",
  themeMode: "dark2",
  cleanerPin: "0000",
  hardResetPin: "123456",
  companyName: "Villa Management Ltd",
  contactEmail: "owner@example.com",
  checkInTime: "15:00",
  checkOutTime: "10:00",
  emailNotifications: true,
  houseRules: {
    en: "No smoking. No parties. Quiet hours 10pm-8am.",
    hr: "Zabranjeno pušenje. Zabranjene zabave. Sati tišine 22-08h.",
    de: "Rauchen verboten. Keine Partys. Ruhezeiten 22-08 Uhr.",
    it: "Vietato fumare. Niente feste. Ore di silenzio 22-08.",
    es: "Prohibido fumar. No se permiten fiestas. Horas de silencio 22-08.",
    fr: "Interdiction de fumer. Pas de fêtes. Heures calmes 22h-8h.",
    pl: "Zakaz palenia. Zakaz imprez. Cisza nocna 22-08.",
    sk: "Zákaz fajčenia. Žiadne párty. Nočný kľud 22-08.",
    cs: "Zákaz kouření. Žádné večírky. Noční klid 22-08.",
    hu: "Dohányzni tilos. Nincs buli. Csendes órák 22-08.",
    sl: "Prepovedano kajenje. Brez zabav. Mirne ure 22-08."
  },
  cleanerChecklist: [
    "Check and replace bedsheets",
    "Clean bathroom thoroughly",
    "Restock toiletries",
    "Take out trash",
    "Vacuum all floors",
    "Wipe kitchen surfaces"
  ],
  aiKnowledge: {
    concierge: "Recommended restaurants: Konoba Fetivi (seafood), Dioklecijan (traditional). Best beaches: Bačvice, Kasjuni.",
    housekeeper: "Cleaning supplies in utility closet. Washer/dryer in basement.",
    tech: "WiFi router in living room. Reset by unplugging for 30 seconds. Smart TV: press Source -> HDMI1.",
    guide: "Parking available in garage (code: 1234). Beach is 5 min walk. Supermarket 2 blocks north."
  },
  welcomeMessage: {
    en: "Welcome to Villa Sunset! We hope you enjoy your stay.",
    hr: "Dobrodošli u Villu Sunset! Nadamo se da ćete uživati u boravku."
  },
  emergencyContact: {
    name: "Property Manager",
    phone: "+385 91 123 4567"
  }
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
  status: "online",              // online | offline
  registeredAt: Timestamp
}
```

#### `cleaning_logs/{logId}`
```javascript
{
  id: "log-uuid",
  ownerId: "TENANT001",
  unitId: "unit-uuid",
  cleanerName: "Maria",
  status: "completed",           // pending | in_progress | completed
  checklist: [
    { task: "Check bedsheets", completed: true },
    { task: "Clean bathroom", completed: true },
    { task: "Restock supplies", completed: true }
  ],
  notes: "Extra towels requested",
  photos: ["storage-url-1", "storage-url-2"],
  timestamp: Timestamp,
  completedAt: Timestamp
}
```

#### `signatures/{signatureId}`
```javascript
{
  id: "signature-uuid",
  ownerId: "TENANT001",
  bookingId: "booking-uuid",
  guestName: "John Doe",
  documentType: "house_rules",   // house_rules | evisitor
  signatureUrl: "storage-url",
  signedAt: Timestamp
}
```

#### `feedback/{feedbackId}`
```javascript
{
  id: "feedback-uuid",
  ownerId: "TENANT001",
  unitId: "unit-uuid",
  bookingId: "booking-uuid",
  rating: 5,
  comment: "Amazing stay!",
  timestamp: Timestamp
}
```

#### `ai_logs/{logId}`
```javascript
{
  id: "log-uuid",
  ownerId: "TENANT001",
  unitId: "unit-uuid",
  question: "Where is the nearest restaurant?",
  answer: "The nearest restaurant is Konoba Fetivi, 5 minutes walk...",
  category: "concierge",
  timestamp: Timestamp
}
```

#### `system_notifications/{notificationId}`
```javascript
{
  id: "notification-uuid",
  title: "System Maintenance",
  message: "Scheduled maintenance on January 15, 2026 from 2-4 AM UTC.",
  type: "info",                  // info | warning | critical
  active: true,
  createdAt: Timestamp,
  expiresAt: Timestamp
}
```

#### `apk_updates/{version}`
```javascript
{
  version: "1.0.0",
  downloadUrl: "storage-url/apk/1.0.0/app.apk",
  releaseNotes: "Initial release of Vesta Lumina Client Terminal",
  mandatory: false,
  minSdkVersion: 26,
  createdAt: Timestamp
}
```

#### `admin_logs/{logId}`
```javascript
{
  id: "log-uuid",
  action: "CREATE_OWNER",        // CREATE_OWNER | DELETE_OWNER | TOGGLE_STATUS | RESET_PASSWORD | ADD_ADMIN | REMOVE_ADMIN
  performedBy: "admin@example.com",
  targetId: "affected-resource-id",
  details: {
    email: "newowner@example.com",
    tenantId: "TENANT002"
  },
  timestamp: Timestamp
}
```

#### `super_admins/{email}`
```javascript
{
  email: "admin@example.com",
  addedAt: Timestamp,
  addedBy: "vestaluminasystem@gmail.com"
}
```

#### `tenant_links/{tenantId}`
```javascript
{
  tenantId: "TENANT001",
  uid: "firebase-auth-uid",
  email: "owner@example.com",
  linkedAt: Timestamp
}
```

#### `activation_codes/{code}`
```javascript
{
  code: "ABC123XYZ",
  tenantId: "TENANT001",
  email: "owner@example.com",
  used: false,
  createdAt: Timestamp,
  expiresAt: Timestamp
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
    
    function isWebPanel() {
      return isAuthenticated() && 
        request.auth.token.role == 'owner';
    }
    
    function isTablet() {
      return isAuthenticated() && 
        request.auth.token.role == 'tablet';
    }
    
    function isOwnerOf(ownerId) {
      return isAuthenticated() && 
        request.auth.token.ownerId == ownerId;
    }
    
    function isResourceOwner() {
      return isAuthenticated() && 
        resource.data.ownerId == request.auth.token.ownerId;
    }
    
    function isRequestOwner() {
      return isAuthenticated() && 
        request.resource.data.ownerId == request.auth.token.ownerId;
    }

    // ═══════════════════════════════════════════════════════════════
    // SUPER ADMINS COLLECTION
    // ═══════════════════════════════════════════════════════════════
    
    match /super_admins/{email} {
      allow read: if isSuperAdmin();
      allow write: if request.auth.token.email == 'vestaluminasystem@gmail.com';
    }

    // ═══════════════════════════════════════════════════════════════
    // OWNERS COLLECTION
    // ═══════════════════════════════════════════════════════════════
    
    match /owners/{ownerId} {
      allow read: if isSuperAdmin() || isOwnerOf(ownerId);
      allow write: if isSuperAdmin();
    }

    // ═══════════════════════════════════════════════════════════════
    // UNITS COLLECTION
    // ═══════════════════════════════════════════════════════════════
    
    match /units/{unitId} {
      allow read: if isResourceOwner() || isSuperAdmin();
      allow create: if isAuthenticated() && isRequestOwner();
      allow update, delete: if isResourceOwner() || isSuperAdmin();
    }

    // ═══════════════════════════════════════════════════════════════
    // BOOKINGS COLLECTION
    // ═══════════════════════════════════════════════════════════════
    
    match /bookings/{bookingId} {
      allow read: if isResourceOwner() || isSuperAdmin();
      allow create: if isAuthenticated() && isRequestOwner();
      allow update, delete: if isResourceOwner() || isSuperAdmin();
    }

    // ═══════════════════════════════════════════════════════════════
    // SETTINGS COLLECTION
    // ═══════════════════════════════════════════════════════════════
    
    match /settings/{ownerId} {
      allow read, write: if isOwnerOf(ownerId) || isSuperAdmin();
    }

    // ═══════════════════════════════════════════════════════════════
    // CLEANING LOGS COLLECTION
    // ═══════════════════════════════════════════════════════════════
    
    match /cleaning_logs/{logId} {
      allow read: if isResourceOwner() || isSuperAdmin();
      allow create: if isAuthenticated() && isRequestOwner();
      allow update, delete: if isResourceOwner() || isSuperAdmin();
    }

    // ═══════════════════════════════════════════════════════════════
    // TABLETS COLLECTION
    // ═══════════════════════════════════════════════════════════════
    
    match /tablets/{tabletId} {
      allow read: if isResourceOwner() || isSuperAdmin() || isTablet();
      allow write: if isResourceOwner() || isSuperAdmin();
    }

    // ═══════════════════════════════════════════════════════════════
    // SIGNATURES COLLECTION
    // ═══════════════════════════════════════════════════════════════
    
    match /signatures/{signatureId} {
      allow read: if isResourceOwner() || isSuperAdmin();
      allow create: if isAuthenticated();
      allow update, delete: if isResourceOwner() || isSuperAdmin();
    }

    // ═══════════════════════════════════════════════════════════════
    // FEEDBACK COLLECTION
    // ═══════════════════════════════════════════════════════════════
    
    match /feedback/{feedbackId} {
      allow read: if isResourceOwner() || isSuperAdmin();
      allow create: if isAuthenticated();
      allow update, delete: if isResourceOwner() || isSuperAdmin();
    }

    // ═══════════════════════════════════════════════════════════════
    // AI LOGS COLLECTION
    // ═══════════════════════════════════════════════════════════════
    
    match /ai_logs/{logId} {
      allow read: if isResourceOwner() || isSuperAdmin();
      allow create: if isAuthenticated();
      allow update, delete: if false; // Immutable
    }

    // ═══════════════════════════════════════════════════════════════
    // SCREENSAVER IMAGES COLLECTION
    // ═══════════════════════════════════════════════════════════════
    
    match /screensaver_images/{imageId} {
      allow read: if isResourceOwner() || isSuperAdmin();
      allow write: if isResourceOwner() || isSuperAdmin();
    }

    // ═══════════════════════════════════════════════════════════════
    // SYSTEM NOTIFICATIONS (Read-only for all authenticated)
    // ═══════════════════════════════════════════════════════════════
    
    match /system_notifications/{notificationId} {
      allow read: if isAuthenticated();
      allow write: if isSuperAdmin();
    }

    // ═══════════════════════════════════════════════════════════════
    // APK UPDATES (Read for all, write for super admin)
    // ═══════════════════════════════════════════════════════════════
    
    match /apk_updates/{version} {
      allow read: if isAuthenticated();
      allow write: if isSuperAdmin();
    }

    // ═══════════════════════════════════════════════════════════════
    // ADMIN LOGS (Super admin read-only, Cloud Functions write)
    // ═══════════════════════════════════════════════════════════════
    
    match /admin_logs/{logId} {
      allow read: if isSuperAdmin();
      allow write: if false; // Only Cloud Functions can write
    }

    // ═══════════════════════════════════════════════════════════════
    // TENANT LINKS (System use only)
    // ═══════════════════════════════════════════════════════════════
    
    match /tenant_links/{tenantId} {
      allow read: if isSuperAdmin();
      allow write: if false; // Only Cloud Functions can write
    }

    // ═══════════════════════════════════════════════════════════════
    // ACTIVATION CODES (System use only)
    // ═══════════════════════════════════════════════════════════════
    
    match /activation_codes/{code} {
      allow read, write: if false; // Only Cloud Functions can access
    }
  }
}
```

### Storage Rules (93 lines)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // ═══════════════════════════════════════════════════════════════
    // HELPER FUNCTIONS
    // ═══════════════════════════════════════════════════════════════
    
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
             request.auth.token.role == 'owner';
    }
    
    function isValidImage() {
      return request.resource.size < 5 * 1024 * 1024 &&
             request.resource.contentType.matches('image/.*');
    }
    
    function isValidAPK() {
      return request.resource.size < 100 * 1024 * 1024 &&
             request.resource.contentType == 'application/vnd.android.package-archive';
    }

    // ═══════════════════════════════════════════════════════════════
    // GALLERY IMAGES
    // ═══════════════════════════════════════════════════════════════
    
    match /gallery/{ownerId}/{allPaths=**} {
      allow read: if isOwnerOf(ownerId) || isSuperAdmin() || isTablet();
      allow write: if (isOwnerOf(ownerId) || isSuperAdmin()) && isValidImage();
      allow delete: if isOwnerOf(ownerId) || isSuperAdmin();
    }

    // ═══════════════════════════════════════════════════════════════
    // SIGNATURES
    // ═══════════════════════════════════════════════════════════════
    
    match /signatures/{ownerId}/{allPaths=**} {
      allow read: if isOwnerOf(ownerId) || isSuperAdmin();
      allow write: if (isOwnerOf(ownerId) || isTablet()) && isValidImage();
      allow delete: if isOwnerOf(ownerId) || isSuperAdmin();
    }

    // ═══════════════════════════════════════════════════════════════
    // CLEANING PHOTOS
    // ═══════════════════════════════════════════════════════════════
    
    match /cleaning/{ownerId}/{allPaths=**} {
      allow read: if isOwnerOf(ownerId) || isSuperAdmin();
      allow write: if isOwnerOf(ownerId) && isValidImage();
      allow delete: if isOwnerOf(ownerId) || isSuperAdmin();
    }

    // ═══════════════════════════════════════════════════════════════
    // APK UPLOADS (Super admin only)
    // ═══════════════════════════════════════════════════════════════
    
    match /apk/{version}/{fileName} {
      allow read: if request.auth != null;
      allow write: if isSuperAdmin() && isValidAPK();
      allow delete: if isSuperAdmin();
    }

    // ═══════════════════════════════════════════════════════════════
    // BACKUPS (Super admin only)
    // ═══════════════════════════════════════════════════════════════
    
    match /backups/{allPaths=**} {
      allow read: if isSuperAdmin();
      allow write: if false; // Only Cloud Functions can write
    }
  }
}
```

---

## 📇 Composite Indexes

### Active Indexes (11 total)

| # | Collection | Fields | Purpose |
|---|------------|--------|---------|
| 1 | `bookings` | ownerId ↑, startDate ↑ | Calendar queries |
| 2 | `bookings` | ownerId ↑, unitId ↑ | Unit-specific bookings |
| 3 | `bookings` | unitId ↑, endDate ↑ | Overlap checking |
| 4 | `bookings` | status ↑, endDate ↑ | Status filtering |
| 5 | `units` | ownerId ↑, createdAt ↑ | Unit listing |
| 6 | `cleaning_logs` | ownerId ↑, unitId ↑, timestamp ↓ | Cleaning history |
| 7 | `feedback` | ownerId ↑, timestamp ↓ | Feedback listing |
| 8 | `signatures` | ownerId ↑, signedAt ↓ | Signature history |
| 9 | `signatures` | bookingId ↑, signedAt ↓ | Booking signatures |
| 10 | `screensaver_images` | ownerId ↑, uploadedAt ↓ | Gallery sorting |
| 11 | `ai_logs` | ownerId ↑, timestamp ↓ | AI log history |

### Index Configuration (firestore.indexes.json)

```json
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
        { "fieldPath": "unitId", "order": "ASCENDING" },
        { "fieldPath": "endDate", "order": "ASCENDING" }
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
      "collectionGroup": "units",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "ownerId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "ASCENDING" }
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
      "collectionGroup": "signatures",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "ownerId", "order": "ASCENDING" },
        { "fieldPath": "signedAt", "order": "DESCENDING" }
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

---

## ⚡ Cloud Functions

### Function Summary (20 Functions, 1,507 lines)

| # | Category | Function | Type | Lines |
|---|----------|----------|------|-------|
| 1 | Owner | createOwner | onCall | ~80 |
| 2 | Owner | linkTenantId | onCall | ~60 |
| 3 | Owner | listOwners | onCall | ~40 |
| 4 | Owner | deleteOwner | onCall | ~70 |
| 5 | Owner | resetOwnerPassword | onCall | ~30 |
| 6 | Owner | toggleOwnerStatus | onCall | ~50 |
| 7 | Translation | translateHouseRules | onCall | ~80 |
| 8 | Translation | translateNotification | onCall | ~60 |
| 9 | Tablet | registerTablet | onCall | ~50 |
| 10 | Tablet | tabletHeartbeat | onCall | ~40 |
| 11 | Super Admin | addSuperAdmin | onCall | ~60 |
| 12 | Super Admin | removeSuperAdmin | onCall | ~50 |
| 13 | Super Admin | listSuperAdmins | onCall | ~40 |
| 14 | Super Admin | getAdminLogs | onCall | ~50 |
| 15 | Backup | scheduledBackup | onSchedule | ~100 |
| 16 | Backup | manualBackup | onCall | ~80 |
| 17 | Email | sendEmailNotification | onCall | ~60 |
| 18 | Email | onBookingCreated | onDocumentCreated | ~70 |
| 19 | Email | sendCheckInReminders | onSchedule | ~80 |
| 20 | Email | updateEmailSettings | onCall | ~40 |

---

## 📦 Storage Structure

```
storage/
│
├── 📂 gallery/
│   └── 📂 {ownerId}/
│       ├── 📂 unit_{unitId}/
│       │   ├── 📄 image_001.jpg
│       │   ├── 📄 image_002.jpg
│       │   └── 📄 image_003.jpg
│       └── 📂 screensaver/
│           ├── 📄 slide_001.jpg
│           ├── 📄 slide_002.jpg
│           └── 📄 slide_003.jpg
│
├── 📂 signatures/
│   └── 📂 {ownerId}/
│       └── 📂 {bookingId}/
│           ├── 📄 signature_guest1.png
│           └── 📄 signature_guest2.png
│
├── 📂 cleaning/
│   └── 📂 {ownerId}/
│       └── 📂 {logId}/
│           ├── 📄 photo_before.jpg
│           └── 📄 photo_after.jpg
│
├── 📂 apk/
│   ├── 📂 1.0.0/
│   │   └── 📄 vesta_lumina_client_terminal_1.0.0.apk
│   └── 📂 1.0.1/
│       └── 📄 vesta_lumina_client_terminal_1.0.1.apk
│
└── 📂 backups/
    ├── 📂 2026-01-09/
    │   └── 📄 backup_2026-01-09_03-00.json
    └── 📂 2026-01-10/
        └── 📄 backup_2026-01-10_03-00.json
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
cd functions && npm install && cd ..
firebase deploy --only functions

# Deploy only Storage rules
firebase deploy --only storage
```

### Production Checklist

| # | Task | Status |
|---|------|--------|
| 1 | All Firestore indexes enabled | ✅ |
| 2 | Firestore security rules deployed | ✅ |
| 3 | Storage security rules deployed | ✅ |
| 4 | Cloud Functions deployed (20) | ✅ |
| 5 | Web app built in release mode | ✅ |
| 6 | Primary super admin configured | ✅ |
| 7 | Environment variables set | ✅ |
| 8 | Custom domain configured | ⏳ |

---

## 📜 License Notice

```
This documentation is part of the Vesta Lumina System proprietary software.
Unauthorized reproduction, distribution, or use is strictly prohibited.

© 2025-2026 Neven Roksa (@nroxa92). All rights reserved.
```
