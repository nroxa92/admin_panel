# 🔥 VillaOS - Firebase Data Documentation

## Za: Android Tablet Team & Backend Developers
## Verzija: 3.1 (Januar 2026)
## Super Admin Email: `master@admin.com`

---

# 📋 SADRŽAJ

1. [Firestore Kolekcije](#-firestore-kolekcije)
2. [Authentication & Claims](#-authentication--claims)
3. [Cloud Functions](#-cloud-functions)
4. [Storage Structure](#-storage-structure)
5. [Security Rules](#-security-rules)
6. [Indexes](#-indexes)
7. [Data Flow Diagrams](#-data-flow-diagrams)

---

# 📊 FIRESTORE KOLEKCIJE

## Pregled (17 Kolekcija)

| # | Kolekcija | Dokument ID | Opis |
|---|-----------|-------------|------|
| 1 | `app_config` | fixed IDs | API ključevi, APK verzija |
| 2 | `tenant_links` | tenantId | Owner računi |
| 3 | `settings` | ownerId | Postavke vlasnika |
| 4 | `units` | auto-generated | Smještajne jedinice |
| 5 | `bookings` | auto-generated | Rezervacije |
| 6 | `bookings/{id}/guests` | auto-generated | Gosti (subcollection) |
| 7 | `signatures` | auto-generated | Potpisi kućnog reda |
| 8 | `check_ins` | auto-generated | OCR scan eventi |
| 9 | `cleaning_logs` | auto-generated | Izvještaji čistačica |
| 10 | `feedback` | auto-generated | Ocjene gostiju |
| 11 | `gallery` | auto-generated | Legacy galerija |
| 12 | `screensaver_images` | auto-generated | Slike za screensaver |
| 13 | `ai_logs` | auto-generated | AI chat povijest |
| 14 | `tablets` | tabletId | Registrirani uređaji |
| 15 | `archived_bookings` | auto-generated | Arhivirane rezervacije |
| 16 | `system_notifications` | auto-generated | Super Admin obavijesti |
| 17 | `apk_updates` | auto-generated | APK deployment history |
| 18 | `admin_logs` | auto-generated | Audit trail |

---

## 1. `app_config` (Globalna Konfiguracija)

**Putanja:** `/app_config/{configId}`

**Tko čita:** Svi autentificirani ✅
**Tko piše:** Super Admin ✅

### Document: `api_keys`
```javascript
{
  "geminiApiKey": "AIza...",           // Google Gemini API
  "mapsApiKey": "AIza...",             // Google Maps API
  "translateApiKey": "AIza..."         // Google Translate API
}
```

### Document: `apk_version`
```javascript
{
  "currentVersion": "1.2.3",           // Trenutna verzija
  "minVersion": "1.0.0",               // Minimalna podržana
  "apkUrl": "gs://bucket/apk/v1.2.3.apk",
  "releaseNotes": "Bug fixes...",
  "updatedAt": Timestamp,
  "updatedBy": "master@admin.com"
}
```

---

## 2. `tenant_links` (Owner Računi)

**Putanja:** `/tenant_links/{tenantId}`

**Tko čita:** Super Admin ✅
**Tko piše:** Super Admin ✅ | Cloud Functions ✅

```javascript
{
  "tenantId": "ROKSA123",              // 6-12 uppercase chars
  "email": "neven@example.com",
  "uid": "firebase-auth-uid-abc123",
  "displayName": "Neven Roksa",
  "status": "active",                  // active | disabled
  "createdAt": Timestamp,
  "createdBy": "master@admin.com",
  "disabledAt": null,                  // Timestamp when disabled
  "disabledBy": null
}
```

---

## 3. `settings` (Postavke Vlasnika)

**Putanja:** `/settings/{ownerId}`

**Tko čita:** Web Panel ✅ | Tablet ✅
**Tko piše:** Web Panel ✅ | Tablet ❌

```javascript
{
  // === IDENTIFIKACIJA ===
  "ownerId": "ROKSA123",

  // === OWNER INFO ===
  "ownerFirstName": "Neven",
  "ownerLastName": "Roksa",
  "contactEmail": "neven@example.com",
  "contactPhone": "+385 91 123 4567",
  "companyName": "VillaOS d.o.o.",

  // === EMERGENCY CONTACT ===
  "emergencyCall": "+385 91 111 2222",
  "emergencySms": "+385 91 111 2222",
  "emergencyWhatsapp": "+385 91 111 2222",
  "emergencyViber": "+385 91 111 2222",
  "emergencyEmail": "emergency@example.com",

  // === KATEGORIJE JEDINICA ===
  "categories": ["Zgrada 1", "Zgrada 2", "Premium"],

  // === SIGURNOSNI PIN-ovi ===
  "cleanerPin": "1234",                // 4 znamenke
  "hardResetPin": "9999",              // 4 znamenke

  // === AI KNOWLEDGE BASE ===
  "aiConcierge": "Villa je u Splitu...",
  "aiHousekeeper": "Posteljina se mijenja...",
  "aiTech": "WiFi router je u hodniku...",
  "aiGuide": "Gosti vole opušten ton...",

  // === DIGITAL INFO BOOK ===
  "welcomeMessageTranslations": {
    "en": "Welcome to our beautiful villa!",
    "hr": "Dobrodošli u našu prekrasnu vilu!",
    "de": "Willkommen in unserer schönen Villa!",
    "it": "Benvenuti nella nostra bella villa!",
    "fr": "Bienvenue dans notre belle villa!",
    "es": "¡Bienvenidos a nuestra hermosa villa!",
    "pl": "Witamy w naszej pięknej willi!",
    "cs": "Vítejte v naší krásné vile!",
    "hu": "Üdvözöljük gyönyörű villánkban!",
    "sl": "Dobrodošli v naši čudoviti vili!",
    "sk": "Vitajte v našej krásnej vile!"
  },
  "houseRulesTranslations": {
    "en": "1. No smoking inside.\n2. Quiet hours 22:00-08:00...",
    "hr": "1. Zabranjeno pušenje unutra.\n2. Noćni mir 22:00-08:00...",
    // ... ostali jezici
  },
  "cleanerChecklist": [
    "Promijeni posteljinu",
    "Očisti kupaonicu",
    "Usisaj podove",
    "Provjeri minibar"
  ],

  // === SCREENSAVER CONFIG ===
  "screensaver_config": {
    "delay": 60,                       // Sekunde prije pokretanja
    "duration": 10,                    // Sekunde po slajdu
    "transitions": ["fade", "slide", "zoom"]  // Efekti
  },

  // === TIMERS ===
  "welcomeMessageDuration": 15,        // Sekunde (10-30)
  "houseRulesDuration": 30,            // Sekunde (20-60)

  // === CHECK-IN/OUT ===
  "checkInTime": "16:00",
  "checkOutTime": "10:00",

  // === WIFI (globalno) ===
  "wifiSsid": "VillaGuest",
  "wifiPass": "welcome123",

  // === IZGLED (Web Panel) ===
  "themeColor": "gold",
  "themeMode": "dark1",
  "appLanguage": "hr"
}
```

---

## 4. `units` (Smještajne Jedinice)

**Putanja:** `/units/{unitId}`

**Tko čita:** Web Panel ✅ | Tablet ✅ (svoje)
**Tko piše:** Web Panel ✅

```javascript
{
  "id": "unit_abc123",
  "ownerId": "ROKSA123",
  "ownerEmail": "neven@example.com",
  "name": "Apartman 1",
  "address": "Ulica Palih Boraca 15, Split",
  "category": "Zgrada 1",              // Zona/kategorija
  
  // WiFi (per-unit override)
  "wifiSsid": "Apartman1_Guest",
  "wifiPass": "apt1pass123",
  
  // Operations
  "cleanerPin": "1234",                // Override globalnog
  "reviewLink": "https://g.page/review/...",
  
  // Contact options za goste
  "contactOptions": {
    "phone": "+385 91 123 4567",
    "whatsapp": "+385 91 123 4567",
    "email": "contact@villa.com"
  },
  
  "createdAt": Timestamp
}
```

---

## 5. `bookings` (Rezervacije)

**Putanja:** `/bookings/{bookingId}`

**Tko čita:** Web Panel ✅ | Tablet ✅
**Tko piše:** Web Panel ✅ (create/update/delete) | Tablet ✅ (update only)

```javascript
{
  "id": "booking_xyz789",
  "ownerId": "ROKSA123",
  "unitId": "unit_abc123",
  "guestName": "Ivan Horvat",
  "guestCount": 4,
  
  // Datumi
  "startDate": Timestamp,              // Check-in datum
  "endDate": Timestamp,                // Check-out datum
  "checkInTime": "16:00",              // Sat check-ina
  "checkOutTime": "10:00",             // Sat check-outa
  
  // Status
  "status": "confirmed",               // confirmed|pending|blocked|private
  "isScanned": false,                  // true nakon OCR check-ina
  
  // Izvor
  "source": "booking.com",             // booking.com|airbnb|private|other
  
  // Notes
  "note": "VIP gosti, late check-in",
  
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

### 5.1 `bookings/{bookingId}/guests` (Subcollection)

**Putanja:** `/bookings/{bookingId}/guests/{guestId}`

```javascript
{
  "id": "guest_001",
  "firstName": "Ivan",
  "lastName": "Horvat",
  "dateOfBirth": "1985-03-15",
  "nationality": "HR",
  "documentType": "ID_CARD",           // ID_CARD|PASSPORT|DRIVING_LICENSE
  "documentNumber": "123456789",
  "documentExpiry": "2028-03-15",
  
  // Adresa
  "address": "Ilica 100",
  "city": "Zagreb",
  "postalCode": "10000",
  "country": "HR",
  
  // Signature
  "signatureUrl": "https://storage.../signatures/...",
  "signedAt": Timestamp,
  
  // OCR scan info
  "scannedAt": Timestamp,
  "scannedBy": "tablet_abc"            // Tablet ID koji je skenirao
}
```

---

## 6. `signatures` (Potpisi Kućnog Reda)

**Putanja:** `/signatures/{signatureId}`

**Tko čita:** Web Panel ✅
**Tko piše:** Web Panel ✅ | Tablet ✅ (create)

```javascript
{
  "id": "sig_abc123",
  "ownerId": "ROKSA123",
  "bookingId": "booking_xyz789",
  "unitId": "unit_abc123",
  "guestName": "Ivan Horvat",
  
  // Signature data
  "signatureUrl": "https://storage.../signatures/sig_abc123.png",
  "signedAt": Timestamp,
  "language": "hr",                    // Jezik na kojem je potpisano
  
  // Device info
  "tabletId": "tablet_abc",
  "ipAddress": "192.168.1.100"
}
```

---

## 7. `check_ins` (OCR Scan Eventi)

**Putanja:** `/check_ins/{checkInId}`

**Tko čita:** Web Panel ✅
**Tko piše:** Tablet ✅ (create)

```javascript
{
  "id": "checkin_abc123",
  "ownerId": "ROKSA123",
  "bookingId": "booking_xyz789",
  "unitId": "unit_abc123",
  
  // Scan info
  "scannedAt": Timestamp,
  "tabletId": "tablet_abc",
  "scanMethod": "OCR",                 // OCR|MANUAL
  
  // Guest data from scan
  "guestData": {
    "firstName": "Ivan",
    "lastName": "Horvat",
    "documentType": "ID_CARD",
    "documentNumber": "123456789",
    "nationality": "HR"
  },
  
  // Raw OCR result (za debugging)
  "rawOcrText": "...",
  "confidence": 0.95
}
```

---

## 8. `cleaning_logs` (Izvještaji Čistačica)

**Putanja:** `/cleaning_logs/{logId}`

**Tko čita:** Web Panel ✅
**Tko piše:** Tablet ✅ (create)

```javascript
{
  "id": "clean_abc123",
  "ownerId": "ROKSA123",
  "unitId": "unit_abc123",
  
  // Cleaning info
  "timestamp": Timestamp,
  "cleanerName": "Marija",             // Uneseno na tabletu
  "tabletId": "tablet_abc",
  
  // Checklist results
  "completedTasks": [
    "Promijeni posteljinu",
    "Očisti kupaonicu",
    "Usisaj podove"
  ],
  "skippedTasks": [
    "Provjeri minibar"
  ],
  
  // Notes
  "notes": "Nedostaje sapun u kupaonici",
  
  // Photos (optional)
  "photoUrls": [
    "https://storage.../cleaning/photo1.jpg"
  ]
}
```

---

## 9. `feedback` (Ocjene Gostiju)

**Putanja:** `/feedback/{feedbackId}`

**Tko čita:** Web Panel ✅
**Tko piše:** Tablet ✅ (create) | Web Panel ✅ (update read status)

```javascript
{
  "id": "feedback_abc123",
  "ownerId": "ROKSA123",
  "unitId": "unit_abc123",
  "bookingId": "booking_xyz789",       // Optional
  
  // Rating
  "rating": 5,                         // 1-5 stars
  "comment": "Prekrasan boravak!",
  
  // Meta
  "timestamp": Timestamp,
  "language": "hr",
  "tabletId": "tablet_abc",
  
  // Admin
  "isRead": false,
  "readAt": null
}
```

---

## 10. `gallery` (Legacy Galerija)

**Putanja:** `/gallery/{imageId}`

> ⚠️ **LEGACY** - Novi kod koristi `screensaver_images`

```javascript
{
  "id": "img_abc123",
  "ownerId": "ROKSA123",
  "url": "https://storage.../gallery/image1.jpg",
  "path": "gallery/ROKSA123/image1.jpg",
  "fileName": "image1.jpg",
  "uploadedAt": Timestamp
}
```

---

## 11. `screensaver_images` (Slike za Screensaver)

**Putanja:** `/screensaver_images/{imageId}`

**Tko čita:** Web Panel ✅ | Tablet ✅
**Tko piše:** Web Panel ✅

```javascript
{
  "id": "scr_abc123",
  "ownerId": "ROKSA123",
  "url": "https://storage.../screensaver/ROKSA123/image1.jpg",
  "path": "screensaver/ROKSA123/image1.jpg",
  "fileName": "sunset_villa.jpg",
  "uploadedAt": Timestamp
}
```

**Index potreban:** `ownerId` (ASC) + `uploadedAt` (DESC)

---

## 12. `ai_logs` (AI Chat Povijest)

**Putanja:** `/ai_logs/{logId}`

**Tko čita:** Web Panel ✅
**Tko piše:** Tablet ✅ (create)

```javascript
{
  "id": "ai_abc123",
  "ownerId": "ROKSA123",
  "unitId": "unit_abc123",
  
  // Chat
  "question": "Where is the nearest restaurant?",
  "answer": "The nearest restaurant is...",
  "persona": "concierge",              // concierge|housekeeper|tech|guide
  
  // Meta
  "timestamp": Timestamp,
  "language": "en",
  "tabletId": "tablet_abc",
  
  // AI info
  "model": "gemini-1.5-flash",
  "tokensUsed": 150
}
```

---

## 13. `tablets` (Registrirani Uređaji)

**Putanja:** `/tablets/{tabletId}`

**Tko čita:** Web Panel ✅ | Super Admin ✅
**Tko piše:** Super Admin ✅ | Tablet ✅ (heartbeat update)

```javascript
{
  "tabletId": "tablet_abc123",
  "ownerId": "ROKSA123",
  "unitId": "unit_abc123",             // Assigned unit
  
  // Device info
  "deviceModel": "Samsung Galaxy Tab A8",
  "androidVersion": "13",
  "appVersion": "1.2.3",
  
  // Status
  "status": "active",                  // active|inactive|pending_update
  "lastHeartbeat": Timestamp,
  "isOnline": true,
  
  // Battery
  "batteryLevel": 85,
  "isCharging": true,
  
  // Update status
  "updateStatus": "idle",              // idle|downloading|installing|failed
  "updateError": null,
  "pendingVersion": null,
  
  // Auth
  "email": "tablet_abc123@villa.local",
  "uid": "firebase-auth-uid-tablet",
  
  // Registration
  "registeredAt": Timestamp,
  "registeredBy": "master@admin.com"
}
```

---

## 14. `archived_bookings` (Arhivirane Rezervacije)

**Putanja:** `/archived_bookings/{bookingId}`

Ista struktura kao `bookings`, plus:

```javascript
{
  // ... svi booking fields ...
  "archivedAt": Timestamp,
  "archivedBy": "system"               // system|manual
}
```

---

## 15. `system_notifications` (Super Admin Obavijesti)

**Putanja:** `/system_notifications/{notificationId}`

**Tko čita:** Super Admin ✅ | Owners ✅ (svoje)
**Tko piše:** Super Admin ✅

```javascript
{
  "id": "notif_abc123",
  "title": "Scheduled Maintenance",
  "message": "System will be down for maintenance...",
  "type": "info",                      // info|warning|critical
  
  // Targeting
  "sendToAll": true,                   // true = all owners
  "targetOwners": [],                  // ili ["OWNER1", "OWNER2"]
  
  // Status
  "createdAt": Timestamp,
  "createdBy": "master@admin.com",
  "expiresAt": Timestamp,              // Auto-dismiss after
  
  // Dismissals
  "dismissedBy": ["OWNER1", "OWNER3"]  // Owners who dismissed
}
```

---

## 16. `apk_updates` (APK Deployment History)

**Putanja:** `/apk_updates/{updateId}`

**Tko čita:** Super Admin ✅ | Tablets ✅
**Tko piše:** Super Admin ✅

```javascript
{
  "id": "update_abc123",
  "version": "1.2.3",
  "apkUrl": "https://storage.../apk/villa_tablet_1.2.3.apk",
  "apkSize": 45000000,                 // bytes
  "releaseNotes": "Bug fixes and improvements",
  
  // Targeting
  "targetAll": false,
  "targetOwners": ["ROKSA123"],
  "targetTablets": ["tablet_abc"],
  
  // Status
  "status": "deployed",                // pending|deployed|cancelled
  "deployedAt": Timestamp,
  "deployedBy": "master@admin.com",
  
  // Results
  "successCount": 5,
  "failedCount": 1,
  "failedTablets": ["tablet_xyz"]
}
```

---

## 17. `admin_logs` (Audit Trail)

**Putanja:** `/admin_logs/{logId}`

**Tko čita:** Super Admin ✅
**Tko piše:** Super Admin ✅ | Cloud Functions ✅

```javascript
{
  "id": "log_abc123",
  "action": "CREATE_OWNER",
  "actor": "master@admin.com",
  "target": "ROKSA123",
  "details": {
    "email": "neven@example.com",
    "displayName": "Neven Roksa"
  },
  "timestamp": Timestamp,
  "ipAddress": "192.168.1.1"
}
```

**Actions:**
- `CREATE_OWNER`, `DISABLE_OWNER`, `ENABLE_OWNER`
- `REGISTER_TABLET`, `DEACTIVATE_TABLET`
- `DEPLOY_APK`, `SEND_NOTIFICATION`
- `UPDATE_CONFIG`, `DELETE_DATA`

---

# 🔐 AUTHENTICATION & CLAIMS

## Custom Claims Structure

```javascript
// Web Panel Owner
{
  "ownerId": "ROKSA123",
  "role": "owner"
}

// Web Panel Admin (future)
{
  "ownerId": "ROKSA123",
  "role": "admin"
}

// Tablet
{
  "ownerId": "ROKSA123",
  "unitId": "unit_abc123",
  "role": "tablet"
}

// Super Admin (no custom claims, email check only)
// email == "master@admin.com"
```

## Auth Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      AUTHENTICATION FLOW                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. User enters email/password                                   │
│                    │                                             │
│                    ▼                                             │
│  2. Firebase Auth validates credentials                          │
│                    │                                             │
│                    ▼                                             │
│  3. Get ID Token with Custom Claims                             │
│                    │                                             │
│                    ▼                                             │
│  4. Route based on claims:                                       │
│     ┌─────────────────────────────────────────────┐             │
│     │ email == "master@admin.com"                 │             │
│     │         → SuperAdminScreen                  │             │
│     ├─────────────────────────────────────────────┤             │
│     │ role == "owner" && ownerId exists           │             │
│     │         → OwnerDashboard                    │             │
│     ├─────────────────────────────────────────────┤             │
│     │ role == "tablet" && unitId exists           │             │
│     │         → TabletApp                         │             │
│     ├─────────────────────────────────────────────┤             │
│     │ No claims                                   │             │
│     │         → TenantSetupScreen                 │             │
│     └─────────────────────────────────────────────┘             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

# ☁️ CLOUD FUNCTIONS

## Functions List (10)

| Function | Trigger | Description |
|----------|---------|-------------|
| `createOwner` | Callable | Create new tenant account |
| `disableOwner` | Callable | Disable tenant account |
| `refreshOwnerClaims` | Callable | Refresh JWT claims |
| `registerTablet` | Callable | Register new tablet |
| `deactivateTablet` | Callable | Deactivate tablet |
| `deployApkToAll` | Callable | Push APK to all tablets |
| `deployApkToOwner` | Callable | Push APK to owner's tablets |
| `tabletHeartbeat` | Callable | Update tablet status |
| `translateHouseRules` | Callable | Auto-translate content |
| `cleanupOldBookings` | Scheduled | Archive old bookings |

## Function Signatures

### createOwner
```javascript
// Request
{
  "email": "owner@example.com",
  "password": "securepass123",
  "tenantId": "TENANT123",
  "displayName": "Owner Name"
}

// Response
{
  "success": true,
  "uid": "firebase-uid",
  "tenantId": "TENANT123"
}
```

### registerTablet
```javascript
// Request
{
  "tabletId": "tablet_abc123",
  "ownerId": "TENANT123",
  "unitId": "unit_xyz",
  "deviceModel": "Samsung Tab A8"
}

// Response
{
  "success": true,
  "email": "tablet_abc123@villa.local",
  "password": "auto-generated"
}
```

---

# 📦 STORAGE STRUCTURE

```
Firebase Storage
├── screensaver/
│   └── {ownerId}/
│       ├── image1.jpg
│       ├── image2.jpg
│       └── ...
│
├── signatures/
│   └── {ownerId}/
│       └── {signatureId}.png
│
├── cleaning/
│   └── {ownerId}/
│       └── {logId}/
│           ├── photo1.jpg
│           └── photo2.jpg
│
└── apk/
    ├── villa_tablet_1.0.0.apk
    ├── villa_tablet_1.1.0.apk
    └── villa_tablet_1.2.3.apk
```

---

# 🔐 SECURITY RULES

## Firestore Rules Summary

```javascript
// Helper Functions
isAuthenticated()    // User is logged in
isSuperAdmin()       // email == 'master@admin.com'
isWebPanel()         // Has ownerId, role != 'tablet'
isTablet()           // role == 'tablet'
isResourceOwner()    // ownerId matches document
isRequestOwner()     // ownerId matches new document

// Access Matrix
┌─────────────────────┬───────┬───────┬────────┬─────────────┐
│ Collection          │ Read  │ Create│ Update │ Delete      │
├─────────────────────┼───────┼───────┼────────┼─────────────┤
│ app_config          │ Auth  │ SA    │ SA     │ SA          │
│ tenant_links        │ SA    │ SA    │ SA     │ SA          │
│ settings            │ Owner │ Owner │ Owner  │ Owner       │
│ units               │ Owner │ WP    │ WP     │ WP          │
│ bookings            │ Owner │ WP    │ Owner  │ WP          │
│ bookings/guests     │ Owner │ Owner │ Owner  │ WP          │
│ signatures          │ Owner │ Owner │ WP     │ WP          │
│ check_ins           │ Owner │ Owner │ WP     │ WP          │
│ cleaning_logs       │ Owner │ Owner │ WP     │ WP          │
│ feedback            │ Owner │ Owner │ WP     │ SA          │
│ gallery             │ Owner │ WP    │ WP     │ WP          │
│ screensaver_images  │ Owner │ WP    │ WP     │ WP          │
│ ai_logs             │ Owner │ Owner │ SA     │ SA          │
│ tablets             │ Owner │ SA    │ Owner  │ SA          │
│ archived_bookings   │ Owner │ WP    │ SA     │ SA          │
│ system_notifications│ Target│ SA    │ SA+Own │ SA          │
│ apk_updates         │ SA+Tab│ SA    │ SA     │ SA          │
│ admin_logs          │ SA    │ SA    │ SA     │ SA          │
└─────────────────────┴───────┴───────┴────────┴─────────────┘

Legend: SA=Super Admin, WP=Web Panel, Owner=Owner+Tablet, Auth=Any authenticated
```

---

# 📇 INDEXES

## Required Composite Indexes

| Collection | Field 1 | Field 2 | Query Scope |
|------------|---------|---------|-------------|
| `screensaver_images` | ownerId (ASC) | uploadedAt (DESC) | Collection |
| `bookings` | ownerId (ASC) | startDate (ASC) | Collection |
| `bookings` | unitId (ASC) | startDate (ASC) | Collection |
| `cleaning_logs` | unitId (ASC) | timestamp (DESC) | Collection |
| `cleaning_logs` | ownerId (ASC) | timestamp (DESC) | Collection |
| `feedback` | ownerId (ASC) | timestamp (DESC) | Collection |
| `ai_logs` | ownerId (ASC) | timestamp (DESC) | Collection |
| `check_ins` | ownerId (ASC) | scannedAt (DESC) | Collection |

---

# 📊 DATA FLOW DIAGRAMS

## Guest Check-in Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    GUEST CHECK-IN FLOW                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Tablet displays active booking                               │
│                    │                                             │
│                    ▼                                             │
│  2. Guest scans ID document (OCR)                               │
│                    │                                             │
│                    ▼                                             │
│  3. Create check_in document                                     │
│                    │                                             │
│                    ▼                                             │
│  4. Add guest to bookings/{id}/guests                           │
│                    │                                             │
│                    ▼                                             │
│  5. Display House Rules                                          │
│                    │                                             │
│                    ▼                                             │
│  6. Capture signature                                            │
│                    │                                             │
│                    ▼                                             │
│  7. Upload signature to Storage                                  │
│                    │                                             │
│                    ▼                                             │
│  8. Create signature document                                    │
│                    │                                             │
│                    ▼                                             │
│  9. Update booking.isScanned = true                             │
│                    │                                             │
│                    ▼                                             │
│  10. Show Welcome Message                                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Cleaning Report Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                   CLEANING REPORT FLOW                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Cleaner enters PIN on tablet                                │
│                    │                                             │
│                    ▼                                             │
│  2. Display cleaning checklist                                   │
│                    │                                             │
│                    ▼                                             │
│  3. Cleaner marks tasks complete                                │
│                    │                                             │
│                    ▼                                             │
│  4. Optional: Take photos                                        │
│                    │                                             │
│                    ▼                                             │
│  5. Upload photos to Storage                                     │
│                    │                                             │
│                    ▼                                             │
│  6. Create cleaning_log document                                 │
│                    │                                             │
│                    ▼                                             │
│  7. Web Panel shows cleaning complete                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

# 📈 STATISTICS

| Metric | Value |
|--------|-------|
| **Firestore Collections** | 17 |
| **Cloud Functions** | 10 |
| **Composite Indexes** | 8 |
| **Storage Buckets** | 4 paths |
| **Supported Languages** | 11 |
| **Security Rule Lines** | 375 |

---

*Last Updated: January 9, 2026*
*Version: 3.1*
