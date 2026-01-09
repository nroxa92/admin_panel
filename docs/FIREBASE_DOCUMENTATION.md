# 🔥 VillaOS Firebase Documentation

**Unified Firebase Backend for Web Panel & Tablet**

Ovaj dokument opisuje kompletnu Firebase arhitekturu koju dijele Web Panel i Tablet aplikacija.

---

## 📋 Sadržaj

- [Pregled Arhitekture](#-pregled-arhitekture)
- [Autentikacija & Custom Claims](#-autentikacija--custom-claims)
- [Firestore Kolekcije](#-firestore-kolekcije)
- [Firebase Storage](#-firebase-storage)
- [Security Rules](#-security-rules)
- [Firestore Indexi](#-firestore-indexi)
- [Cloud Functions](#-cloud-functions)
- [GDPR & Data Cleanup](#-gdpr--data-cleanup)

---

## 🏗️ Pregled Arhitekture

```
┌────────────────────────────────────────────────────────────────┐
│                        FIREBASE PROJECT                         │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐        │
│   │    Auth     │    │  Firestore  │    │   Storage   │        │
│   │   Custom    │    │   Database  │    │    Files    │        │
│   │   Claims    │    │             │    │             │        │
│   └──────┬──────┘    └──────┬──────┘    └──────┬──────┘        │
│          │                  │                  │                │
│          └──────────────────┼──────────────────┘                │
│                             │                                   │
│                    ┌────────┴────────┐                         │
│                    │ Cloud Functions │                         │
│                    └────────┬────────┘                         │
│                             │                                   │
└─────────────────────────────┼───────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
        ┌─────┴─────┐   ┌─────┴─────┐   ┌─────┴─────┐
        │ Web Panel │   │  Tablet   │   │  Super    │
        │  (Owner)  │   │  (Kiosk)  │   │  Admin    │
        └───────────┘   └───────────┘   └───────────┘
```

---

## 🔐 Autentikacija & Custom Claims

### Tipovi korisnika:

| Tip | Custom Claims | Opis |
|-----|---------------|------|
| **Super Admin** | `email: "master@admin.com"` | Full access, upravlja svime |
| **Owner** | `ownerId: "X", role: "owner"` | Vlasnik apartmana, Web Panel |
| **Admin** | `ownerId: "X", role: "admin"` | Pomoćnik vlasnika |
| **Tablet** | `ownerId: "X", unitId: "Y", role: "tablet"` | Kiosk uređaj |

### Claims struktura:

```javascript
// Web Panel Owner
{
  ownerId: "TENANT_abc123",
  role: "owner"
}

// Web Panel Admin
{
  ownerId: "TENANT_abc123", 
  role: "admin"
}

// Tablet
{
  ownerId: "TENANT_abc123",
  unitId: "unit_xyz789",
  role: "tablet"
}
```

### Tenant Isolation:

Svaki vlasnik (`ownerId`) vidi **SAMO** svoje podatke. Ovo se provjerava u Security Rules.

---

## 📊 Firestore Kolekcije

### Naming Convention:

> ⚠️ **KRITIČNO:** Sva polja koriste **camelCase** standard!

```
✅ guestName, startDate, endDate, unitId, ownerId
❌ guest_name, start_date, end_date, unit_id, owner_id
```

---

### 1. `bookings` - Rezervacije

**Pristup:** Web Panel (CRUD), Tablet (Read/Update)

```javascript
{
  // Identifikacija
  ownerId: "TENANT_abc123",        // Tenant ID
  unitId: "unit_xyz789",           // Unit reference
  
  // Guest info
  guestName: "Ivan Horvat",        // Ime gosta (iz booking platforme)
  guestEmail: "ivan@email.com",    // Email (optional)
  guestPhone: "+385...",           // Telefon (optional)
  guestCount: 4,                   // Broj gostiju
  
  // Dates
  startDate: Timestamp,            // Check-in datum
  endDate: Timestamp,              // Check-out datum
  checkInTime: "15:00",            // Vrijeme check-ina
  checkOutTime: "10:00",           // Vrijeme check-outa
  
  // Status
  status: "confirmed",             // confirmed | checked_in | archived
  isScanned: false,                // Da li su dokumenti skenirani
  scannedAt: Timestamp,            // Kada je skeniranje završeno
  scannedGuestCount: 0,            // Koliko gostiju je skenirano
  
  // Meta
  createdAt: Timestamp,
  updatedAt: Timestamp,
  source: "manual",                // manual | airbnb | booking_com
  note: "Late arrival"             // Napomena
}
```

#### Subcollection: `bookings/{bookingId}/guests`

```javascript
{
  // Osobni podaci (iz MRZ)
  firstName: "Ivan",
  lastName: "Horvat",
  dateOfBirth: "15.03.1985",
  placeOfBirth: "Zagreb",
  countryOfBirth: "HRV",
  sex: "M",
  nationality: "HRV",
  
  // Dokument
  documentType: "ID_CARD",          // ID_CARD | PASSPORT
  documentNumber: "123456789",
  issuingCountry: "HRV",
  
  // Prebivalište
  residenceCountry: "HRV",
  residenceCity: "Zagreb",
  
  // Potpis
  signatureUrl: "https://...",      // Firebase Storage URL
  signedAt: Timestamp,
  
  // Meta
  createdAt: Timestamp,
  scannedAt: Timestamp
}
```

---

### 2. `units` - Nekretnine

**Pristup:** Web Panel (CRUD), Tablet (Read)

```javascript
{
  ownerId: "TENANT_abc123",
  
  // Basic info
  name: "Apartman Sunce",
  address: "Ulica 123, Split",
  
  // WiFi
  wifiSsid: "GuestWiFi",
  wifiPass: "password123",
  
  // Contact
  contactPhone: "+385...",
  contactOptions: {
    phone: "+385...",
    whatsapp: "+385...",
    viber: "+385..."
  },
  
  // Meta
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

---

### 3. `settings` - Owner postavke

**Document ID:** `{ownerId}`  
**Pristup:** Web Panel (CRUD), Tablet (Read)

```javascript
{
  // PINs
  cleanerPin: "1234",               // PIN za čistačice
  hardResetPin: "9999",             // Factory reset PIN
  
  // AI Prompts
  aiConcierge: "You are a helpful...",
  aiHousekeeper: "...",
  aiGuide: "...",
  aiTech: "...",
  
  // House Rules
  houseRulesTranslations: {
    en: "Welcome to our property...",
    hr: "Dobrodošli u našu nekretninu...",
    de: "Willkommen in unserer..."
  },
  
  // Cleaner
  cleanerChecklist: [               // ⚠️ NE "cleanerTasks"!
    "Change bed linen",
    "Clean bathroom",
    "Vacuum floors",
    "Empty trash"
  ],
  
  // Misc
  googleReviewUrl: "https://g.page/...",
  
  // Meta
  updatedAt: Timestamp
}
```

---

### 4. `signatures` - Potpisi

**Pristup:** Tablet (Create), Web Panel (Read/Delete)

```javascript
{
  ownerId: "TENANT_abc123",
  bookingId: "booking_xyz",         // ⚠️ KRITIČNO za GDPR cleanup!
  unitId: "unit_xyz789",
  
  guestName: "Ivan Horvat",
  signatureUrl: "https://...",      // Firebase Storage URL (NE Base64!)
  
  signedAt: Timestamp,
  language: "hr",
  rulesVersion: "2026-01-09",
  platform: "Android Kiosk"
}
```

---

### 5. `cleaning_logs` - Čišćenje

**Pristup:** Tablet (Create), Web Panel (Read)

```javascript
{
  ownerId: "TENANT_abc123",
  unitId: "unit_xyz789",
  bookingId: "booking_xyz",         // Optional
  
  tasks: {
    "Change bed linen": true,
    "Clean bathroom": true,
    "Vacuum floors": false
  },
  completedCount: 2,
  totalCount: 3,
  notes: "Guest left early",
  status: "partial",                // completed | partial
  
  timestamp: Timestamp,
  platform: "Android Kiosk"
}
```

---

### 6. `feedback` - Povratne informacije

**Pristup:** Tablet (Create), Web Panel (Read/Update)

```javascript
{
  ownerId: "TENANT_abc123",
  unitId: "unit_xyz789",
  
  rating: 5,                        // 1-5
  comment: "Great stay!",
  guestName: "Ivan Horvat",
  
  isRead: false,
  timestamp: Timestamp,
  language: "en",
  platform: "Android Kiosk"
}
```

---

### 7. `screensaver_images` - Galerija

**Pristup:** Web Panel (CRUD), Tablet (Read)

```javascript
{
  ownerId: "TENANT_abc123",
  url: "https://firebasestorage...",
  filename: "beach.jpg",
  uploadedAt: Timestamp
}
```

---

### 8. `ai_logs` - AI Chat

**Pristup:** Tablet (Create), Web Panel (Read)

```javascript
{
  ownerId: "TENANT_abc123",
  unitId: "unit_xyz789",
  
  agentId: "concierge",
  userMessage: "Where is the beach?",
  aiResponse: "The nearest beach is...",
  
  timestamp: Timestamp,
  language: "en"
}
```

---

### 9. `check_ins` - OCR Events (Legacy)

**Pristup:** Tablet (Create), Web Panel (Read)

```javascript
{
  ownerId: "TENANT_abc123",
  unitId: "unit_xyz789",
  
  docType: "ID_CARD",
  guestData: { ... },
  status: "pending_review",
  
  timestamp: Timestamp,
  platform: "Android Kiosk",
  language: "hr"
}
```

---

### 10. `tablets` - Registrirani uređaji

**Pristup:** Cloud Function (Create), Tablet (Update), Web Panel (Read)

```javascript
{
  ownerId: "TENANT_abc123",
  unitId: "unit_xyz789",
  
  deviceId: "abc123...",
  appVersion: "5.1.0",
  
  lastHeartbeat: Timestamp,
  batteryLevel: 85,
  isCharging: true,
  
  updateStatus: "idle",             // idle | downloading | installing | error
  updateError: null,
  
  registeredAt: Timestamp
}
```

---

### 11. `app_config` - Globalne postavke

**Pristup:** Super Admin (CRUD), Authenticated (Read)

```javascript
// Document: "api_keys"
{
  geminiApiKey: "AIza...",
  mapsApiKey: "AIza...",
  weatherApiKey: "..."
}

// Document: "apk_version"
{
  currentVersion: "5.1.0",
  downloadUrl: "https://...",
  releaseNotes: "Bug fixes",
  releasedAt: Timestamp
}
```

---

### 12. `archived_bookings` - Arhiva

**Pristup:** Web Panel (Create/Read), Super Admin (Delete)

```javascript
{
  // Kopija originalnog bookinga
  ...originalBookingData,
  
  originalBookingId: "booking_xyz",
  archivedAt: Timestamp,
  status: "archived",
  guests: [ ... ]                   // Flattened guests array
}
```

---

## 📁 Firebase Storage

### Struktura:

```
firebase-storage/
├── apk/
│   └── {version}/
│       └── app-release.apk         # APK updates
├── screensaver/
│   └── {ownerId}/
│       └── {imageId}.jpg           # Screensaver slike
├── signatures/
│   └── {ownerId}/
│       └── {bookingId}_{timestamp}.png  # Potpisi gostiju
├── units/
│   └── {ownerId}/
│       └── {unitId}/
│           └── {imageId}.jpg       # Slike nekretnina
└── exports/
    └── {ownerId}/
        └── report_{date}.pdf       # PDF exporti
```

### Storage URLs vs Base64:

> ⚠️ **KRITIČNO:** Potpisi se spremaju kao **Storage URL-ovi**, NE kao Base64!

```javascript
// ✅ ISPRAVNO
signatureUrl: "https://firebasestorage.googleapis.com/..."

// ❌ NEISPRAVNO
signatureImage: "data:image/png;base64,iVBORw0KGgo..."
```

---

## 🔒 Security Rules

### Firestore Rules (firestore.rules):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isSuperAdmin() {
      return isAuthenticated() && 
             request.auth.token.email == 'master@admin.com';
    }
    
    function isWebPanel() {
      return isAuthenticated() && 
             request.auth.token.ownerId != null &&
             request.auth.token.role != 'tablet';
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
             request.auth.token.ownerId == resource.data.ownerId;
    }
    
    // ... rules per collection
  }
}
```

### Storage Rules (storage.rules):

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Signatures - Tablet upload, Web Panel read/delete
    match /signatures/{ownerId}/{filename} {
      allow write: if request.auth.token.role == 'tablet' && 
                     request.auth.token.ownerId == ownerId;
      allow read, delete: if request.auth.token.ownerId == ownerId;
    }
    
    // Screensaver - Web Panel upload, Tablet read
    match /screensaver/{ownerId}/{imageId} {
      allow write: if request.auth.token.role != 'tablet' && 
                     request.auth.token.ownerId == ownerId;
      allow read: if request.auth.token.ownerId == ownerId;
    }
    
    // ... other rules
  }
}
```

---

## 📇 Firestore Indexi

### Potrebni composite indexi:

| Collection | Field 1 | Field 2 | Field 3 |
|------------|---------|---------|---------|
| `bookings` | `unitId` ↑ | `endDate` ↑ | - |
| `bookings` | `ownerId` ↑ | `startDate` ↑ | - |
| `bookings` | `ownerId` ↑ | `unitId` ↑ | - |
| `bookings` | `status` ↑ | `endDate` ↑ | - |
| `signatures` | `bookingId` ↑ | `signedAt` ↓ | - |
| `signatures` | `ownerId` ↑ | `signedAt` ↓ | - |
| `cleaning_logs` | `ownerId` ↑ | `unitId` ↑ | `timestamp` ↓ |
| `feedback` | `ownerId` ↑ | `timestamp` ↓ | - |
| `screensaver_images` | `ownerId` ↑ | `uploadedAt` ↓ | - |
| `ai_logs` | `ownerId` ↑ | `timestamp` ↓ | - |

### firestore.indexes.json:

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
      "collectionGroup": "signatures",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "bookingId", "order": "ASCENDING" },
        { "fieldPath": "signedAt", "order": "DESCENDING" }
      ]
    }
  ]
}
```

Deploy:
```bash
firebase deploy --only firestore:indexes
```

---

## ⚡ Cloud Functions

### Funkcije:

| Funkcija | Trigger | Opis |
|----------|---------|------|
| `createOwner` | HTTPS Callable | Kreira novog vlasnika s custom claims |
| `registerTablet` | HTTPS Callable | Registrira tablet uređaj |
| `generateTabletCode` | HTTPS Callable | Generira 6-znamenkasti kod |
| `cleanupExpiredData` | Scheduled | GDPR cleanup potpisa |
| `onBookingArchived` | Firestore Trigger | Briše guest podatke |

---

## 🗑️ GDPR & Data Cleanup

### Automatsko brisanje:

1. **Nakon Checkout-a (Cleaner Finish):**
   - Briši slike potpisa iz Storage
   - Briši signature dokumente iz Firestore
   - Briši goste iz subcollection
   - Arhiviraj booking

2. **Scheduled Cleanup (dnevno):**
   - Pronađi završene bookinge starije od X dana
   - Izvrši cleanup

### Cleanup Flow:

```
Cleaner Finish
      │
      ▼
┌─────────────────────────────────────┐
│  1. Delete signatures from Storage  │
│  2. Delete signature documents      │
│  3. Delete guests subcollection     │
│  4. Archive booking                 │
└─────────────────────────────────────┘
      │
      ▼
   Complete
```

### Kritična polja za cleanup:

```javascript
// Signature MORA imati bookingId za cleanup!
{
  bookingId: "booking_xyz",   // ⚠️ OBAVEZNO!
  signatureUrl: "https://..." // Za brisanje iz Storage
}
```

---

## 📝 Quick Reference

### Web Panel pristup:

```javascript
// Čitanje bookinga za vlasnika
db.collection('bookings')
  .where('ownerId', '==', currentUser.ownerId)
  .orderBy('startDate', 'desc')
```

### Tablet pristup:

```javascript
// Dohvati aktivnu rezervaciju za unit
db.collection('bookings')
  .where('unitId', '==', tabletUnitId)
  .where('endDate', '>=', now)
  .orderBy('endDate')
  .limit(1)
```

### Spremi gosta u subcollection:

```javascript
db.collection('bookings')
  .doc(bookingId)
  .collection('guests')
  .add(guestData)
```

---

## 🔗 Povezano

- [VillaOS Web Panel](https://github.com/nroxa92/villa-web-panel)
- [VillaOS Tablet](https://github.com/nroxa92/tablet_terminal)

---

**Verzija:** 3.1  
**Datum:** 2026-01-09  
**Autor:** VillaOS Team
