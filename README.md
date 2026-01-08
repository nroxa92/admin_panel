# 🏰 VillaOS - Admin Panel

**VillaOS** (Villa Operating System) je sveobuhvatni sustav za upravljanje vilama i rentalnim nekretninama. Projekt se sastoji od **Flutter Web Admin Panela** za vlasnike nekretnina te **Android tablet aplikacije** koja se koristi u kiosk modu direktno u smještajnim jedinicama.

Backend infrastruktura je izgrađena na **Firebase** ekosustavu uključujući Cloud Functions, Firestore bazu podataka i Firebase Storage.

---

## 📊 Status Projekta

| Komponenta | Status | Napredak |
|------------|--------|----------|
| Web Admin Panel | 🟢 Production Ready | 95% |
| Tablet App | 🟡 U razvoju | 30% |
| Cloud Functions | 🟢 Aktivno | 7 funkcija |
| PDF Generator | 🟢 Kompletno | 10 tipova |
| Translations | 🟢 Kompletno | 11 jezika |

---

## 🎯 Svrha Projekta

Cilj **VillaOS** sustava je automatizirati i pojednostaviti svakodnevne operacije upravljanja smještajnim jedinicama:

- **Za vlasnike**: Centralizirani pregled svih jedinica, rezervacija i gostiju kroz intuitivni web panel
- **Za goste**: Digitalna knjiga s pravilima, WiFi podacima i kontakt informacijama putem tablet uređaja u apartmanu
- **Za čistačice**: Jednostavan check-in sustav s PIN kodom i checklistom zadataka

---

## 🚀 Ključne Funkcionalnosti

### 📱 Admin Panel (Web)

| Modul | Opis |
|-------|------|
| **🏠 Dashboard** | Real-time pregled statusa svih jedinica, dolasci/odlasci za danas i sutra, indikacija čišćenja |
| **📅 Booking Kalendar** | Drag-and-drop upravljanje rezervacijama, višemjesečni prikaz, sortiranje po zonama |
| **👥 Guest Management** | Automatsko učitavanje podataka gostiju iz eVisitor skeniranja |
| **🖨️ PDF Generator** | 10 tipova dokumenata (eVisitor lista, potpisana pravila, raspored čišćenja...) |
| **⚙️ Settings** | Personalizacija (boje, jezik), konfiguracija PIN-ova, AI knowledge base |
| **📖 Digital Book** | Upravljanje sadržajem za tablet (pravila kuće, welcome poruka, emergency kontakti) |

### 📲 Tablet App (Android - WIP)

| Modul | Opis |
|-------|------|
| **🎬 Screensaver** | Animirana prezentacija s konfigurirajućim timerima |
| **📝 Guest Check-in** | Skeniranje dokumenata, potpis pravila kuće |
| **🧹 Cleaner Mode** | PIN pristup, checklist zadataka, foto dokumentacija |
| **🆘 Emergency QR** | Brzi kontakt putem QR kodova (poziv, SMS, WhatsApp, Viber) |

### 🌍 Multi-Language Support

Potpuna podrška za **11 jezika**:

```
🇬🇧 English    🇭🇷 Hrvatski    🇩🇪 Deutsch    🇮🇹 Italiano
🇫🇷 Français   🇪🇸 Español     🇵🇱 Polski     🇨🇿 Čeština
🇭🇺 Magyar     🇸🇮 Slovenščina 🇸🇰 Slovenčina
```

### 🖨️ PDF Dokumenti (10 tipova)

1. **eVisitor Scanned Data** - Lista skeniranih gostiju
2. **Signed House Rules** - Potpisana pravila s digitalnim potpisom
3. **Cleaning Log** - Izvještaj o čišćenju
4. **Unit Schedule** - Raspored jedinice (30 dana)
5. **Textual List (Full)** - Tekstualni pregled rezervacija
6. **Textual List (Anonymous)** - Anonimizirana verzija
7. **Cleaning Schedule** - Raspored čišćenja
8. **Graphic View (Full)** - Grafički kalendar
9. **Graphic View (Anonymous)** - Anonimizirana verzija
10. **Booking History** - Kompletna arhiva

---

## 🛠️ Tehnološki Stack

### Frontend
| Tehnologija | Verzija | Svrha |
|-------------|---------|-------|
| Flutter | 3.24+ | Cross-platform UI framework |
| Dart | 3.5+ | Programski jezik |
| Provider | 6.x | State management |
| GoRouter | 14.x | Navigation |

### Backend (Firebase)
| Servis | Region | Svrha |
|--------|--------|-------|
| **Firestore** | europe-west3 | NoSQL baza podataka |
| **Cloud Functions** | europe-west3 | Serverless backend (Node.js 18) |
| **Authentication** | - | Email/Password + Custom Claims |
| **Storage** | europe-west3 | Slike, potpisi, dokumenti |
| **Hosting** | - | Web app deployment |

### Cloud Functions (7 aktivnih)

```javascript
translateText       // AI prijevod sadržaja
processSignature    // Obrada digitalnih potpisa  
generateReport      // Generiranje izvještaja
sendNotification    // Push notifikacije
cleanupOldData      // Scheduled maintenance
validateBooking     // Validacija rezervacija
syncEvisitor        // eVisitor integracija
```

---

## 📂 Struktura Repozitorija

```
villa_admin/
├── lib/
│   ├── config/           # Translations, constants
│   │   └── translations.dart   # 11 jezika, 130+ ključeva
│   ├── models/           # Data models
│   │   ├── unit_model.dart
│   │   ├── booking_model.dart
│   │   ├── settings_model.dart
│   │   └── cleaning_log_model.dart
│   ├── providers/        # State management
│   │   └── app_provider.dart
│   ├── screens/          # UI screens
│   │   ├── dashboard_screen.dart
│   │   ├── booking_screen.dart
│   │   ├── settings_screen.dart
│   │   └── digital_book_screen.dart
│   ├── services/         # Firebase services
│   │   ├── units_service.dart
│   │   ├── booking_service.dart
│   │   ├── settings_service.dart
│   │   ├── cleaning_service.dart
│   │   └── pdf_service.dart
│   ├── widgets/          # Reusable components
│   │   └── unit_widgets.dart
│   └── main.dart         # App entry point
├── functions/            # Firebase Cloud Functions (Node.js)
│   ├── index.js
│   └── package.json
├── web/                  # Web-specific config
│   ├── index.html
│   └── manifest.json
├── assets/               # Static resources
│   ├── images/
│   └── fonts/
├── pubspec.yaml          # Flutter dependencies
└── README.md
```

---

## 🔐 Sigurnosni Model

### Multi-Tenant Arhitektura

Sustav koristi **Custom Claims** za izolaciju podataka između različitih vlasnika:

```
User Authentication
       ↓
Custom Claims: { ownerId: "xxx", role: "owner" }
       ↓
Firestore Security Rules (ownerId filter)
       ↓
Izolirani podaci po tenant-u
```

## 📈 Roadmap

### ✅ Završeno 
- [x] Dashboard s real-time statusom
- [x] Booking kalendar (drag & drop)
- [x] PDF generator (10 tipova)
- [x] Multi-language (11 jezika)
- [x] Settings & personalizacija
- [x] Digital Book management
- [x] Cleaning status indikacija

### 🔄 U tijeku 
- [ ] Tablet app - Guest check-in flow
- [ ] Tablet app - Cleaner mode
- [ ] Push notifikacije
- [ ] Offline support

---

## 👨‍💻 Razvoj

Projekt je razvijan s fokusom na:

- Production-ready kod
- Best practices
- Comprehensive error handling
- Multi-language architecture
- Scalable Firebase struktura

---

## ⛔️ Licenca i Autorska Prava

**© Copyright 2024-2025 nroxa92. Sva prava pridržana.**

Ovaj softver i povezani izvorni kod su **intelektualno vlasništvo autora**. Kod je javno dostupan na GitHubu isključivo u svrhu **prezentacije (portfolio)** i **nije otvorenog koda (Not Open Source)**.

### Strogo je zabranjeno:

1. ❌ Kopiranje, umnožavanje ili distribucija koda u bilo kojem obliku
2. ❌ Korištenje ovog projekta ili njegovih dijelova u komercijalne ili privatne svrhe
3. ❌ Modificiranje izvornog koda ili stvaranje izvedenih djela (derivative works)
4. ❌ Reverse engineering ili dekompilacija

> ⚠️ **Bilo kakvo neovlašteno korištenje smatrat će se kršenjem autorskih prava i bit će poduzete odgovarajuće pravne mjere.**

---

## 📬 Kontakt

Za upite vezane uz ovaj projekt:
- **GitHub**: [@nroxa92](https://github.com/nroxa92)

---
---

**VillaOS** - Simplifying Property Management 🏰