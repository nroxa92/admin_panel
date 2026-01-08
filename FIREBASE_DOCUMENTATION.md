# 🔥 VillaOS - Firebase Data Documentation

## Za: Android Tablet Team
## Verzija: 1.0 (Januar 2026)

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

  // === TABLET TIMERS (NOVO!) ===
  "welcomeMessageDuration": 15,               // Sekunde (10-30)
  "houseRulesDuration": 30,                   // Sekunde (20-60)

  // === CHECK-IN/OUT VREMENA ===
  "checkInTime": "16:00",
  "checkOutTime": "10:00",

  // === WIFI (globalno za sve jedinice ako nije definirano per-unit) ===
  "wifiSsid": "VillaGuest",
  "wifiPass": "welcome123",

  // === IZGLED (samo Web Panel) ===
  "themeColor": "gold",                       // gold, teal, coral, rose...
  "themeMode": "dark1",                       // dark1, dark2, dark3, light1...
  "appLanguage": "hr"                         // en, hr, de, it, fr, es, pl, cz, hu, sl, sk
}
```

---

## 2. `units` (Smještajne Jedinice)

**Putanja:** `/units/{unitId}`

**Tko čita:** Web Panel ✅ | Tablet ✅
**Tko piše:** Web Panel ✅ | Tablet ❌

```javascript
{
  // === IDENTIFIKACIJA ===
  "ownerId": "ROKSA123",              // Tenant ID
  "ownerEmail": "neven@example.com",

  // === OSNOVNI PODACI ===
  "name": "Villa Sunset",
  "address": "Ulica 123, Split",
  "category": "Premium",              // null = "Bez kategorije"

  // === WIFI (per-unit override) ===
  "wifi_ssid": "VillaSunset_Guest",
  "wifi_pass": "sunset2024",

  // === KONTAKTI (legacy) ===
  "contacts": {
    "phone": "+385 91 123 4567",
    "email": "villa@example.com"
  },

  // === SIGURNOST ===
  "cleaner_pin": "5678",              // Override globalnog PIN-a
  "review_link": "https://g.page/...",

  // === METADATA ===
  "created_at": Timestamp
}
```

**Unit ID Format:** `{OWNER_INITIALS}-{CATEGORY_PREFIX}-{UNIT_NAME}`
- Primjer: `NR-PREM-SUNSET` (Neven Roksa, Premium, Sunset)

---

## 3. `bookings` (Rezervacije)

**Putanja:** `/bookings/{bookingId}`

**Tko čita:** Web Panel ✅ | Tablet ✅
**Tko piše:** Web Panel ✅ | Tablet ❌ (samo označi is_scanned)

```javascript
{
  // === IDENTIFIKACIJA ===
  "ownerId": "ROKSA123",
  "unit_id": "NR-PREM-SUNSET",

  // === GOST ===
  "guest_name": "John Smith",
  "guest_count": 4,

  // === DATUMI (Timestamp!) ===
  "start_date": Timestamp,            // Check-in datum + vrijeme
  "end_date": Timestamp,              // Check-out datum + vrijeme
  "check_in_time": "16:00",           // String format HH:mm
  "check_out_time": "10:00",          // String format HH:mm

  // === STATUS ===
  "status": "confirmed",              // confirmed, booking.com, airbnb, private, blocked
  "is_scanned": false,                // true nakon što gost skenira dokument
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
| `other` | 🟣 Purple |

---

## 4. `bookings/{bookingId}/guests` (Subcollection)

**Putanja:** `/bookings/{bookingId}/guests/{guestId}`

**Tko čita:** Web Panel ✅ | Tablet ✅
**Tko piše:** Web Panel ❌ | Tablet ✅ (nakon skeniranja)

```javascript
{
  // === OSOBNI PODACI (iz MRZ skeniranja) ===
  "first_name": "John",
  "last_name": "Smith",
  "full_name": "SMITH JOHN",
  "document_number": "AB1234567",
  "document_type": "P",               // P = Passport, ID = ID Card
  "nationality": "GBR",               // ISO 3166-1 alpha-3
  "date_of_birth": "1985-06-15",      // YYYY-MM-DD string
  "sex": "M",                         // M / F
  "expiry_date": "2030-12-31",        // YYYY-MM-DD string

  // === METADATA ===
  "timestamp": Timestamp,             // Kada je skenirano
  "scanned_by": "tablet_villa_sunset" // Device ID
}
```

---

## 5. `signatures` (Potpisi Pravila)

**Putanja:** `/signatures/{signatureId}`

**Tko čita:** Web Panel ✅ | Tablet ❌
**Tko piše:** Web Panel ❌ | Tablet ✅

```javascript
{
  // === VEZE ===
  "unit_id": "NR-PREM-SUNSET",
  "booking_id": "abc123",
  "owner_id": "ROKSA123",

  // === POTPIS ===
  "signature_url": "gs://bucket/signatures/...",  // Firebase Storage URL
  "signature_base64": "data:image/png;base64,...", // Legacy (deprecated)

  // === GOST ===
  "guest_name": "John Smith",

  // === METADATA ===
  "signed_at": Timestamp,
  "language": "en",                   // Jezik pravila koja je potpisao
  "device_id": "tablet_villa_sunset"
}
```

---

## 6. `cleaning_logs` (Zapisnici Čišćenja)

**Putanja:** `/cleaning_logs/{logId}`

**Tko čita:** Web Panel ✅ | Tablet ❌
**Tko piše:** Web Panel ❌ | Tablet ✅

```javascript
{
  // === VEZE ===
  "unit_id": "NR-PREM-SUNSET",
  "ownerId": "ROKSA123",

  // === ČISTAČ ===
  "cleaner_name": "Ana K.",

  // === ZADACI ===
  "tasks_completed": {
    "Promijeni posteljinu": true,
    "Očisti kupaonicu": true,
    "Usisaj podove": true,
    "Provjeri minibar": false
  },

  // === BILJEŠKE ===
  "notes": "Nedostaje sapun u kupaonici",
  "status": "completed",              // completed, inspection_needed

  // === METADATA ===
  "timestamp": Timestamp
}
```

---

# 📁 FIREBASE STORAGE

## Putanje:

```
/signatures/{ownerId}/{unitId}/{bookingId}_{timestamp}.png
/cleaning_photos/{ownerId}/{unitId}/{logId}_{photoIndex}.jpg
```

---

# ☁️ CLOUD FUNCTIONS

## Dostupne Funkcije (region: `europe-west3`):

| Funkcija | Poziva | Opis |
|----------|--------|------|
| `createOwner` | Super Admin | Kreira novog vlasnika |
| `translateText` | Web Panel | AI prijevod (Gemini) |
| `verifyCleanerPin` | Tablet | Provjera PIN-a čistačice |

### Primjer poziva `translateText`:

```dart
final result = await FirebaseFunctions
  .instanceFor(region: 'europe-west3')
  .httpsCallable('translateText')
  .call({
    'text': 'Welcome to our villa!',
    'sourceLang': 'en',
    'targetLang': 'hr',
  });
```

---

# 🔐 FIRESTORE SECURITY RULES (Ključno!)

Sve kolekcije su filtrirane po `ownerId`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Settings - samo vlasnik čita/piše
    match /settings/{tenantId} {
      allow read, write: if request.auth.token.ownerId == tenantId;
    }
    
    // Units - filtrirano po ownerId
    match /units/{unitId} {
      allow read, write: if request.auth.token.ownerId == resource.data.ownerId;
    }
    
    // Bookings + subcollections
    match /bookings/{bookingId} {
      allow read, write: if request.auth.token.ownerId == resource.data.ownerId;
      
      match /guests/{guestId} {
        allow read, write: if request.auth.token.ownerId == get(/databases/$(database)/documents/bookings/$(bookingId)).data.ownerId;
      }
    }
  }
}
```

---

# 📱 TABLET APP - ŠTO TREBA ČITATI

## Pri pokretanju (jednom):
1. `settings/{tenantId}` → Cijeli dokument
2. `units/{unitId}` → Jedinica za ovaj tablet

## Na Guest Screen:
1. `bookings` WHERE `unit_id == thisUnit` AND `start_date <= today <= end_date`

## Za Cleaner Mode:
1. Verify PIN against `settings.cleanerPin`
2. Read `settings.cleanerChecklist`

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
final ref = storage.ref('signatures/$ownerId/$unitId/${bookingId}_$timestamp.png');
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

## Nakon čišćenja:
```dart
await firestore.collection('cleaning_logs').add({
  'unit_id': unitId,
  'ownerId': ownerId,
  'cleaner_name': cleanerName,
  'tasks_completed': tasksMap,
  'notes': notes,
  'status': allComplete ? 'completed' : 'inspection_needed',
  'timestamp': FieldValue.serverTimestamp(),
});
```

---

# 🌍 PODRŽANI JEZICI

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

1. **Timestamps:** Uvijek koristi `Timestamp.fromDate()` za spremanje, nikad stringove
2. **ownerId:** UVIJEK provjeri da je prisutan u svakom dokumentu
3. **PIN format:** Točno 4 znamenke kao String ("1234", ne 1234)
4. **Jezični kodovi:** Koristi 2-char kodove (en, hr, de...), osim `cz` za češki
5. **Signature URL:** Preferiraj `signature_url` nad `signature_base64` (novi format)

---

**Dokument generirao:** Claude AI
**Datum:** Januar 2026
**Web Panel verzija:** 1.0 Production Ready
