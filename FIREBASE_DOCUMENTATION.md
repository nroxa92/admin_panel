# 🔥 VillaOS - Firebase Data Documentation

## Za: Android Tablet Team
## Verzija: 2.0 (Januar 2026)
## Super Admin Email: `master@admin.com`

---

# 📊 FIRESTORE KOLEKCIJE

## 1. `settings` (Postavke Vlasnika)

**Putanja:** `/settings/{tenantId}`

**Tko čita:** Web Panel ✅ | Tablet ✅
**Tko piše:** Web Panel ✅ | Tablet ❌

```javascript
{
  // === IDENTIFIKACIJA ===
  "ownerId": "ROKSA123",              // Tenant ID (6-12 uppercase chars)

  // === OWNER INFO (za PDF/dokumente) ===
  "ownerFirstName": "Neven",
  "ownerLastName": "Roksa", 
  "contactEmail": "neven@example.com",
  "contactPhone": "+385 91 123 4567",
  "companyName": "VillaOS d.o.o.",

  // === EMERGENCY CONTACT (za QR kodove na tabletu) ===
  "emergencyCall": "+385 91 111 2222",
  "emergencySms": "+385 91 111 2222",
  "emergencyWhatsapp": "+385 91 111 2222",
  "emergencyViber": "+385 91 111 2222",
  "emergencyEmail": "emergency@example.com",

  // === KATEGORIJE JEDINICA ===
  "categories": ["Zona A", "Zona B", "Premium"],

  // === SIGURNOSNI PIN-ovi ===
  "cleanerPin": "1234",               // 4 znamenke - za cleaner mode
  "hardResetPin": "9999",             // 4 znamenke - za hard reset tableta

  // === AI KNOWLEDGE BASE ===
  "aiConcierge": "Villa je u Splitu, blizu Dioklecijanove palače...",
  "aiHousekeeper": "Posteljina se mijenja svaka 3 dana...",
  "aiTech": "WiFi router je u hodniku, restart držanjem 10 sec...",
  "aiGuide": "Gosti vole opušten ton, savjetuj lokalne restorane...",

  // === DIGITAL INFO BOOK ===
  "welcomeMessage": "Welcome to our Villa!",  // Legacy (samo EN)
  "welcomeMessageTranslations": {             // 11 jezika
    "en": "Welcome to our beautiful villa!",
    "hr": "Dobrodošli u našu prekrasnu vilu!",
    "de": "Willkommen in unserer schönen Villa!",
    "it": "Benvenuti nella nostra bella villa!",
    "fr": "Bienvenue dans notre belle villa!",
    "es": "¡Bienvenidos a nuestra hermosa villa!",
    "pl": "Witamy w naszej pięknej willi!",
    "cz": "Vítejte v naší krásné vile!",
    "hu": "Üdvözöljük gyönyörű villánkban!",
    "sl": "Dobrodošli v naši čudoviti vili!",
    "sk": "Vitajte v našej krásnej vile!"
  },
  "houseRulesTranslations": {                 // 11 jezika
    "en": "1. No smoking inside.\n2. Quiet hours 22:00-08:00...",
    "hr": "1. Zabranjeno pušenje unutra.\n2. Noćni mir 22:00-08:00...",
    // ... ostali jezici
  },
  "cleanerChecklist": [                       // Lista zadataka za čistačice
    "Promijeni posteljinu",
    "Očisti kupaonicu",
    "Usisaj podove",
    "Provjeri minibar"
  ],

  // === TABLET TIMERS ===
  "welcomeMessageDuration": 15,               // Sekunde (10-30)
  "houseRulesDuration": 30,                   // Sekunde (20-60)

  // === CHECK-IN/OUT VREMENA ===
  "checkInTime": "16:00",
  "checkOutTime": "10:00",

  // === WIFI (globalno za sve jedinice ako nije definirano per-unit) ===
  "wifiSsid": "VillaGuest",
  "wifiPass": "welcome123",

  // === IZGLED (samo Web Panel) ===
  "themeColor": "gold",
  "themeMode": "dark1",
  "appLanguage": "hr"
}
```

---

## 2. `units` (Smještajne Jedinice)

**Putanja:** `/units/{unitId}`

**Tko čita:** Web Panel ✅ | Tablet ✅
**Tko piše:** Web Panel ✅ | Tablet ❌

```javascript
{
  "ownerId": "ROKSA123",
  "ownerEmail": "neven@example.com",
  "name": "Villa Sunset",
  "address": "Ulica 123, Split",
  "category": "Premium",              // null = "Bez kategorije"
  "wifi_ssid": "VillaSunset_Guest",
  "wifi_pass": "sunset2024",
  "contacts": {
    "phone": "+385 91 123 4567",
    "email": "villa@example.com"
  },
  "cleaner_pin": "5678",              // Override globalnog PIN-a
  "review_link": "https://g.page/...",
  "created_at": Timestamp
}
```

**Unit ID Format:** `{OWNER_INITIALS}-{CATEGORY_PREFIX}-{UNIT_NAME}`

---

## 3. `bookings` (Rezervacije)

**Putanja:** `/bookings/{bookingId}`

**Tko čita:** Web Panel ✅ | Tablet ✅
**Tko piše:** Web Panel ✅ | Tablet ❌ (samo označi is_scanned)

```javascript
{
  "ownerId": "ROKSA123",
  "unit_id": "NR-PREM-SUNSET",
  "guest_name": "John Smith",
  "guest_count": 4,
  "start_date": Timestamp,
  "end_date": Timestamp,
  "check_in_time": "16:00",
  "check_out_time": "10:00",
  "status": "confirmed",              // confirmed, booking.com, airbnb, private, blocked
  "is_scanned": false,
  "note": "Late arrival ~20:00"
}
```

### Status Boje (za UI):
| Status | Boja |
|--------|------|
| `confirmed` | 🟢 Green |
| `booking.com` | 🔵 Blue |
| `airbnb` | 🟠 Orange |
| `private` | 🟡 Yellow |
| `blocked` | 🔴 Red |

---

## 4. `bookings/{bookingId}/guests` (Subcollection)

**Putanja:** `/bookings/{bookingId}/guests/{guestId}`

**Tko čita:** Web Panel ✅ | Tablet ✅
**Tko piše:** Web Panel ❌ | Tablet ✅ (nakon skeniranja)

```javascript
{
  "first_name": "John",
  "last_name": "Smith",
  "full_name": "SMITH JOHN",
  "document_number": "AB1234567",
  "document_type": "P",               // P = Passport, ID = ID Card
  "nationality": "GBR",               // ISO 3166-1 alpha-3
  "date_of_birth": "1985-06-15",
  "sex": "M",
  "expiry_date": "2030-12-31",
  "timestamp": Timestamp,
  "scanned_by": "tablet_villa_sunset"
}
```

---

## 5. `signatures` (Potpisi Pravila)

**Putanja:** `/signatures/{signatureId}`

**Tko čita:** Web Panel ✅ | Tablet ❌
**Tko piše:** Web Panel ❌ | Tablet ✅

```javascript
{
  "unit_id": "NR-PREM-SUNSET",
  "booking_id": "abc123",
  "owner_id": "ROKSA123",
  "signature_url": "gs://bucket/signatures/...",  // Firebase Storage URL
  "guest_name": "John Smith",
  "signed_at": Timestamp,
  "language": "en",
  "device_id": "tablet_villa_sunset"
}
```

---

## 6. `cleaning_logs` (Zapisnici Čišćenja)

**Putanja:** `/cleaning_logs/{logId}`

```javascript
{
  "unit_id": "NR-PREM-SUNSET",
  "ownerId": "ROKSA123",
  "cleaner_name": "Ana K.",
  "tasks_completed": {
    "Promijeni posteljinu": true,
    "Očisti kupaonicu": true,
    "Usisaj podove": true,
    "Provjeri minibar": false
  },
  "notes": "Nedostaje sapun u kupaonici",
  "status": "completed",              // completed, inspection_needed
  "timestamp": Timestamp
}
```

---

# 👑 SUPER ADMIN KOLEKCIJE (NOVO!)

## 7. `tenant_links` (Owner Accounts)

**Putanja:** `/tenant_links/{tenantId}`

**Tko čita:** Super Admin ✅ | Owner ❌ | Tablet ❌
**Tko piše:** Super Admin ✅ (via Cloud Functions)

```javascript
{
  "tenantId": "ROKSA123",
  "firebaseUid": "abc123xyz",
  "email": "owner@admin.com",         // Login email (npr. owner1@admin.com)
  "displayName": "Neven Roksa",
  "status": "active",                 // "pending" | "active" | "suspended"
  "createdAt": Timestamp,
  "linkedAt": Timestamp               // Kada je aktivirao account
}
```

---

## 8. `tablets` (Registrirani Tableti)

**Putanja:** `/tablets/{tabletId}`

**Tko čita:** Super Admin ✅ | Owner ✅ (svoje) | Tablet ✅ (svoj)
**Tko piše:** Super Admin ✅ | Tablet ✅ (heartbeat update)

```javascript
{
  // === IDENTIFIKACIJA ===
  "tabletId": "tab_abc123",
  "firebaseUid": "uid_xyz789",
  "ownerId": "ROKSA123",
  "unitId": "NR-PREM-SUNSET",
  "ownerName": "Neven Roksa",
  "unitName": "Villa Sunset",
  
  // === DEVICE INFO ===
  "model": "Samsung Galaxy Tab A8",
  "osVersion": "Android 13",
  "appVersion": "1.0.0",
  
  // === STATUS ===
  "status": "active",                 // "active" | "replaced"
  "lastActiveAt": Timestamp,          // Zadnji heartbeat
  "batteryLevel": 85,                 // 0-100
  "isCharging": false,
  
  // === APK UPDATE ===
  "pendingUpdate": false,
  "pendingVersion": "1.0.1",
  "pendingApkUrl": "gs://bucket/apk/...",
  "forceUpdate": false,
  
  // === UPDATE STATUS TRACKING (NOVO!) ===
  "updateStatus": "",                 // "pending" | "downloading" | "downloaded" | "installed" | "failed"
  "updateError": "",                  // Error message if failed
  "updatePushedAt": Timestamp,        // Kada je Super Admin push-ao
  "updateDownloadedAt": Timestamp,    // Kada je tablet skinuo APK
  "updateInstalledAt": Timestamp,     // Kada je instalacija završila
  
  // === METADATA ===
  "registeredAt": Timestamp
}
```

### Update Status Flow:
```
1. Super Admin pushes → pendingUpdate: true, updateStatus: ''
2. Tablet heartbeat → updateStatus: 'pending'
3. Download starts → updateStatus: 'downloading'
4. Download done → updateStatus: 'downloaded'
5. Install done → updateStatus: 'installed', pendingUpdate: false
   (or) Error → updateStatus: 'failed', updateError: 'message'
```

---

## 9. `system_notifications` (Obavijesti za Ownere) (NOVO!)

**Putanja:** `/system_notifications/{notificationId}`

**Tko čita:** Super Admin ✅ | Owner ✅ (svoje)
**Tko piše:** Super Admin ✅ | Owner ✅ (samo dismissedBy)

```javascript
{
  // === SADRŽAJ ===
  "message": "Scheduled maintenance on Sunday 10:00-12:00",
  "priority": "yellow",               // "red" | "yellow" | "green" | "blue"
  "sourceLanguage": "en",
  "translations": {                   // Auto-generirano AI-jem (11 jezika)
    "en": "Scheduled maintenance on Sunday 10:00-12:00",
    "hr": "Planirano održavanje u nedjelju 10:00-12:00",
    "de": "Geplante Wartung am Sonntag 10:00-12:00",
    // ... ostali jezici
  },
  
  // === TARGETING (NOVO!) ===
  "sendToAll": true,                  // true = svi owneri
  "targetOwners": [],                 // Ako sendToAll=false, lista tenant ID-eva
  
  // === STATUS ===
  "active": true,
  "dismissedBy": ["OWNER123", "OWNER456"],  // Owneri koji su dismiss-ali
  
  // === METADATA ===
  "createdAt": Timestamp,
  "createdBy": "Super Admin"
}
```

### Priority Boje:
| Priority | Boja | Ikona | Korištenje |
|----------|------|-------|------------|
| `red` | 🔴 | error | Critical/Urgent |
| `yellow` | 🟡 | warning | Warning/Important |
| `green` | 🟢 | check_circle | Success/Info |
| `blue` | 🔵 | info | General Info |

---

## 10. `apk_updates` (APK Update History) (NOVO!)

**Putanja:** `/apk_updates/{updateId}`

**Tko čita:** Super Admin ✅ | Tablet ✅
**Tko piše:** Super Admin ✅

```javascript
{
  "version": "1.0.1",
  "apkUrl": "gs://bucket/apk/villaos_1.0.1.apk",
  "targetOwners": ["ROKSA123", "VILLA456"],  // Prazno = svi
  "forceUpdate": false,
  "tabletCount": 5,                   // Broj tableta koji trebaju update
  "pushedAt": Timestamp,
  "pushedBy": "Super Admin"
}
```

---

## 11. `admin_logs` (Activity Log) (NOVO!)

**Putanja:** `/admin_logs/{logId}`

**Tko čita:** Super Admin ✅
**Tko piše:** Super Admin ✅ (automatski)

```javascript
{
  "action": "CREATE_OWNER",           // CREATE_OWNER, DELETE_OWNER, SUSPEND_OWNER, PUSH_UPDATE, CREATE_NOTIFICATION, etc.
  "targetId": "ROKSA123",             // Tenant ID ili opis
  "details": "Created owner with email owner@admin.com",
  "timestamp": Timestamp,
  "performedBy": "Super Admin"
}
```

---

## 12. `app_config` (Global Config)

**Putanja:** `/app_config/{configId}`

**Tko čita:** Super Admin ✅ | Owner ✅ | Tablet ✅
**Tko piše:** Super Admin ✅

```javascript
// /app_config/tablet_app
{
  "currentVersion": "1.0.0",
  "apkUrl": "gs://bucket/apk/villaos_latest.apk",
  "updatedAt": Timestamp,
  "forceUpdate": false
}

// /app_config/api_keys (za Tablet)
{
  "geminiApiKey": "AIza...",          // Za AI chat
  "mapsApiKey": "AIza..."             // Za Google Maps
}
```

---

# 📦 FIREBASE STORAGE

## Putanje:

```
/apk/{filename}                              # APK files
/apk/{version}/{filename}                    # Verzionirana putanja
/screensaver/{ownerId}/{imageId}             # Screensaver slike
/signatures/{ownerId}/{filename}             # Potpisi gostiju
/units/{ownerId}/{unitId}/{filename}         # Slike jedinica
/exports/{ownerId}/{filename}                # PDF exporti
```

## Storage Rules Pristup:

| Putanja | Super Admin | Owner | Tablet |
|---------|-------------|-------|--------|
| `/apk/**` | ✅ Write | ❌ | 🔵 Read |
| `/screensaver/{ownerId}/**` | ✅ Full | ✅ Own | 🔵 Read |
| `/signatures/{ownerId}/**` | ✅ Full | ✅ Read | ✅ Write |
| `/units/{ownerId}/**` | ✅ Full | ✅ Own | 🔵 Read |
| `/exports/{ownerId}/**` | ✅ Full | ✅ Own | ❌ |

---

# ☁️ CLOUD FUNCTIONS

## Dostupne Funkcije (region: `europe-west3`):

| # | Funkcija | Poziva | Opis |
|---|----------|--------|------|
| 1 | `createOwner` | Super Admin | Kreira novog vlasnika |
| 2 | `linkTenantId` | Owner | Aktivira account |
| 3 | `listOwners` | Super Admin | Lista svih vlasnika |
| 4 | `deleteOwner` | Super Admin | Briše vlasnika |
| 5 | `resetOwnerPassword` | Super Admin | Reset lozinke |
| 6 | `toggleOwnerStatus` | Super Admin | Suspend/Activate |
| 7 | `translateHouseRules` | Owner | AI prijevod (Gemini) |
| 8 | `registerTablet` | Tablet | Registrira tablet |
| 9 | `tabletHeartbeat` | Tablet | Ping + update check |
| 10 | `translateNotification` | Super Admin | Prijevod obavijesti |

### Primjer poziva `translateHouseRules`:

```dart
final result = await FirebaseFunctions
  .instanceFor(region: 'europe-west3')
  .httpsCallable('translateHouseRules')
  .call({
    'text': 'Welcome to our villa!',
    'sourceLang': 'en',
    'targetLangs': ['hr', 'de', 'it'],
  });
```

### Primjer poziva `tabletHeartbeat`:

```dart
final result = await FirebaseFunctions
  .instanceFor(region: 'europe-west3')
  .httpsCallable('tabletHeartbeat')
  .call({
    'appVersion': '1.0.0',
    'batteryLevel': 85,
    'isCharging': false,
    'updateStatus': 'installed',      // Optional: report update progress
    'updateError': '',                // Optional: report errors
  });

// Response:
// {
//   success: true,
//   pendingUpdate: true,
//   pendingVersion: '1.0.1',
//   pendingApkUrl: 'gs://...',
//   forceUpdate: false,
// }
```

---

# 🔐 FIRESTORE SECURITY RULES

**Super Admin Email:** `master@admin.com`

## Claims Structure:
```javascript
// Super Admin (email-based, no claims)
{ email: 'master@admin.com' }

// Owner (Web Panel)
{ ownerId: 'ROKSA123', role: 'owner' }

// Tablet
{ ownerId: 'ROKSA123', unitId: 'NR-PREM-SUNSET', role: 'tablet' }
```

## Pristup po kolekcijama:

| Kolekcija | Super Admin | Owner | Tablet |
|-----------|-------------|-------|--------|
| `settings` | ✅ Full | ✅ Own | 🔵 Read |
| `units` | ✅ Full | ✅ Own | 🔵 Read |
| `bookings` | ✅ Full | ✅ Own | 🔵 Read + update |
| `bookings/*/guests` | ✅ Full | ✅ Own | ✅ Write |
| `signatures` | ✅ Full | ✅ Own | ✅ Write |
| `cleaning_logs` | ✅ Full | ✅ Own | ✅ Write |
| `feedback` | ✅ Full | ✅ Own | ✅ Write |
| `tenant_links` | ✅ Full | ❌ | ❌ |
| `tablets` | ✅ Full | 🔵 Read | 🔵 Update |
| `system_notifications` | ✅ Full | 🔵 Read + dismiss | ❌ |
| `apk_updates` | ✅ Full | ❌ | 🔵 Read |
| `admin_logs` | ✅ Full | ❌ | ❌ |
| `app_config` | ✅ Full | 🔵 Read | 🔵 Read |

---

# 📱 TABLET APP - ŠTO TREBA ČITATI

## Pri pokretanju (jednom):
1. `settings/{tenantId}` → Cijeli dokument
2. `units/{unitId}` → Jedinica za ovaj tablet
3. `app_config/api_keys` → API ključevi

## Na Guest Screen:
1. `bookings` WHERE `unit_id == thisUnit` AND `start_date <= today <= end_date`

## Za Cleaner Mode:
1. Verify PIN against `settings.cleanerPin`
2. Read `settings.cleanerChecklist`

## Za APK Update Check:
1. Call `tabletHeartbeat()` every 60s
2. Check response `pendingUpdate`
3. If true → download from `pendingApkUrl`

---

# 📱 TABLET APP - ŠTO TREBA PISATI

## Nakon skeniranja dokumenta:
```dart
// Dodaj gosta u subcollection
await firestore
  .collection('bookings')
  .doc(bookingId)
  .collection('guests')
  .add(guestData);

// Označi booking kao skeniran
await firestore
  .collection('bookings')
  .doc(bookingId)
  .update({'is_scanned': true});
```

## Nakon potpisa pravila:
```dart
// Upload sliku u Storage
final ref = storage.ref('signatures/$ownerId/${bookingId}_$timestamp.png');
await ref.putData(signatureBytes);
final url = await ref.getDownloadURL();

// Spremi u Firestore
await firestore.collection('signatures').add({
  'unit_id': unitId,
  'booking_id': bookingId,
  'owner_id': ownerId,
  'signature_url': url,
  'guest_name': guestName,
  'signed_at': FieldValue.serverTimestamp(),
  'language': selectedLanguage,
});
```

## Heartbeat s update statusom:
```dart
// Pozovi svakih 60 sekundi
final result = await functions.httpsCallable('tabletHeartbeat').call({
  'appVersion': currentVersion,
  'batteryLevel': batteryPercent,
  'isCharging': isPluggedIn,
  'updateStatus': updateState,    // 'pending', 'downloading', 'downloaded', 'installed', 'failed'
  'updateError': errorMessage,    // Samo ako failed
});

// Provjeri ima li pending update
if (result.data['pendingUpdate'] == true) {
  final apkUrl = result.data['pendingApkUrl'];
  // Download and install APK...
}
```

---

# 🌐 PODRŽANI JEZICI

| Kod | Jezik |
|-----|-------|
| `en` | English |
| `hr` | Hrvatski |
| `de` | Deutsch |
| `it` | Italiano |
| `fr` | Français |
| `es` | Español |
| `pl` | Polski |
| `cz` | Čeština |
| `hu` | Magyar |
| `sl` | Slovenščina |
| `sk` | Slovenčina |

---

# ⚠️ VAŽNE NAPOMENE

1. **Timestamps:** Uvijek koristi `Timestamp.fromDate()` za spremanje
2. **ownerId:** UVIJEK provjeri da je prisutan u svakom dokumentu
3. **PIN format:** Točno 4 znamenke kao String ("1234")
4. **Jezični kodovi:** Koristi 2-char kodove, osim `cz` za češki
5. **Signature URL:** Preferiraj `signature_url` nad `signature_base64`
6. **Super Admin:** Email je `master@admin.com`
7. **Update Status:** Tablet MORA reportirati progress kroz heartbeat
8. **Region:** Sve Cloud Functions su na `europe-west3`

---

**Dokument generirao:** Claude AI  
**Datum:** Januar 2026  
**Web Panel verzija:** 2.0 Production Ready  
**Super Admin verzija:** 1.0
