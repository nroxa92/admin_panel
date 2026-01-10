# 🏨 Vesta Lumina System - Pregled Sustava

> **Sve što trebate znati o sustavu za upravljanje smještajem**
> **Napisano jednostavno i razumljivo**

---

## 📋 Sadržaj

1. [Što je Vesta Lumina System?](#-što-je-vesta-lumina-system)
2. [Komponente Sustava](#-komponente-sustava)
3. [Kako Sve Funkcionira Zajedno?](#-kako-sve-funkcionira-zajedno)
4. [Za Koga je Namijenjen?](#-za-koga-je-namijenjen)
5. [Što Možete Raditi?](#-što-možete-raditi)
6. [Kako Gosti Koriste Tablet?](#-kako-gosti-koriste-tablet)
7. [Sigurnost i Privatnost](#-sigurnost-i-privatnost)
8. [Česta Pitanja](#-česta-pitanja)

---

## 🎯 Što je Vesta Lumina System?

### Ukratko

**Vesta Lumina System** je kompletno rješenje za vlasnike smještajnih objekata (vila, apartmana, kuća za odmor) koji žele:

- ✅ Digitalno upravljati rezervacijama
- ✅ Automatizirati prijavu gostiju
- ✅ Profesionalno prezentirati objekt gostima
- ✅ Imati sve informacije na jednom mjestu

### Zamislite Ovako...

Prije Vesta Lumine:
```
📋 Papiri svuda
📞 Stalni pozivi gostima za upute
📝 Ručno pisanje kućnih pravila
🗓️ Excel tablice za rezervacije
😓 Kaos!
```

S Vesta Luminom:
```
💻 Sve na jednom mjestu
📱 Tablet u smještaju daje sve informacije gostima
📅 Vizualni kalendar s drag & drop
📄 Automatski PDF dokumenti
😊 Mir i red!
```

---

## 🧩 Komponente Sustava

Sustav se sastoji od **dva glavna dijela** koji rade zajedno:

### 1. Web Panel (Admin Panel) 💻

**Što je to?**
Web stranica koju vi (vlasnik) koristite na svom računalu ili mobitelu za upravljanje svime.

**Gdje se pristupa?**
Kroz web preglednik na adresi: `https://vls-admin.web.app`

**Tko koristi?**
- Vi (vlasnik smještaja)
- Vaš tim (ako ga imate)
- Super administratori (tehnička podrška)

**Što možete raditi?**
- Upravljati rezervacijama
- Dodavati smještajne jedinice
- Pisati kućna pravila
- Pregledavati statistike
- Printati dokumente

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│           💻 WEB PANEL                                      │
│                                                             │
│     Vaše "kontrolno središte" za sve operacije              │
│                                                             │
│     • Pristup: Bilo gdje s internetom                       │
│     • Uređaji: PC, laptop, tablet, mobitel                  │
│     • Korisnici: Vlasnici i administratori                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2. Client Terminal (Tablet u Smještaju) 📱

**Što je to?**
Android aplikacija koja radi na tabletu postavljenom u vašem smještaju. Gosti koriste ovaj tablet za sve informacije tijekom boravka.

**Gdje se nalazi?**
Fizički u vašem smještajnom objektu (na zidu, na stolu, na pultu).

**Tko koristi?**
- Gosti tijekom boravka
- Čistači za evidenciju čišćenja

**Što gosti mogu raditi?**
- Čitati kućna pravila (na svom jeziku!)
- Vidjeti WiFi lozinku
- Pitati AI asistenta za preporuke
- Potpisati dokumente digitalno
- Gledati lijepe slike vašeg objekta

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│           📱 TABLET U SMJEŠTAJU                             │
│                                                             │
│     "Digitalni concierge" za vaše goste                     │
│                                                             │
│     • Lokacija: Fizički u smještaju                         │
│     • Uređaj: Android tablet (kiosk mode)                   │
│     • Korisnici: Gosti i čistači                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3. Cloud Backend (Firebase) ☁️

**Što je to?**
"Oblak" - serveri koji povezuju web panel i tablet, čuvaju sve podatke i omogućuju sinkronizaciju.

**Gdje se nalazi?**
Na Google Cloud serverima u Europi (Frankfurt).

**Tko koristi?**
Nitko direktno - radi automatski u pozadini.

**Što radi?**
- Čuva sve vaše podatke sigurno
- Sinkronizira podatke između web panela i tableta
- Šalje email obavijesti
- Prevodi tekstove pomoću AI-a

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│           ☁️ CLOUD (FIREBASE)                               │
│                                                             │
│     "Mozak" sustava - sve povezuje                          │
│                                                             │
│     • Lokacija: Google Cloud (Europa)                       │
│     • Sigurnost: Enkripcija, backup                         │
│     • Dostupnost: 99.9% uptime                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Kako Sve Funkcionira Zajedno?

### Vizualni Prikaz

```
    VI (VLASNIK)                              GOSTI
         │                                      │
         ▼                                      ▼
┌─────────────────┐                  ┌─────────────────┐
│                 │                  │                 │
│   💻 WEB PANEL  │                  │   📱 TABLET     │
│                 │                  │                 │
│  • Unosite      │                  │  • Čitaju       │
│    rezervacije  │                  │    pravila      │
│  • Pišete       │                  │  • Pitaju       │
│    pravila      │                  │    AI-a         │
│  • Gledate      │                  │  • Potpisuju    │
│    statistike   │                  │    dokumente    │
│                 │                  │                 │
└────────┬────────┘                  └────────┬────────┘
         │                                    │
         │         ┌─────────────┐            │
         └────────▶│             │◀───────────┘
                   │  ☁️ CLOUD   │
                   │  (Firebase) │
                   │             │
                   │  • Čuva     │
                   │    podatke  │
                   │  • Sinkro-  │
                   │    nizira   │
                   │  • Šalje    │
                   │    emailove │
                   │             │
                   └─────────────┘
```

### Primjer u Praksi

Zamislimo scenarij s gostom Markom:

**1. Prije Dolaska**
```
Vi: Unosite rezervaciju u web panel
    - Ime: Marko Horvat
    - Dolazak: 15.01.2026.
    - Odlazak: 20.01.2026.
    - Jedinica: Vila Sunset

Cloud: Automatski sinkronizira podatke na tablet u Vili Sunset
```

**2. Dan Dolaska**
```
Marko: Dolazi u Vilu Sunset, vidi tablet na zidu

Tablet: Prikazuje personaliziranu poruku dobrodošlice:
        "Dobrodošli Marko! 🌅
         Vaš boravak: 15.01. - 20.01.2026.
         WiFi: VillaSunset_Guest
         Lozinka: Welcome2026"
```

**3. Tijekom Boravka**
```
Marko: Pita tablet "Gdje mogu večerati?"

AI na tabletu: "Preporučujem Konobu Fetivi - samo 5 minuta hoda.
               Poznati su po crnom rižotu. Rezervacije na +385..."

Marko: Želi vidjeti kućna pravila na njemačkom
       (automatski prevedeno na 11 jezika)
```

**4. Prije Odlaska**
```
Marko: Potpisuje kućna pravila digitalno na tabletu

Sustav: Sprema potpis, generira PDF

Vi: Možete preuzeti potpisani dokument iz web panela
```

**5. Nakon Odlaska**
```
Čistač: Unosi PIN, otvara checklist na tabletu
        ✓ Posteljina promijenjena
        ✓ Kupaonica očišćena
        ✓ Kuhinja pospremljena
        📸 Fotografira završeno čišćenje

Vi: Vidite u web panelu da je čišćenje završeno
```

---

## 👥 Za Koga je Namijenjen?

### Idealni Korisnici

| Tip Korisnika | Zašto je Idealno |
|---------------|------------------|
| **Vlasnici vila** | Puno informacija za goste, potreba za profesionalnim dojmom |
| **Vlasnici apartmana** | Upravljanje više jedinica s jednog mjesta |
| **Property manageri** | Pregled i kontrola nad svim objektima |
| **Agencije za iznajmljivanje** | Centralizirano upravljanje portfeljem |

### Nije Idealno Za

- Hotelske lance s postojećim PMS sustavima
- Jednokratna kratka iznajmljivanja

---

## ✨ Što Možete Raditi?

### S Web Panelom

| Funkcija | Opis |
|----------|------|
| **📅 Kalendar Rezervacija** | Vizualni pregled svih rezervacija, drag & drop premještanje |
| **🏠 Upravljanje Jedinicama** | Dodavanje vila, apartmana, soba; postavljanje WiFi-a, PIN-ova |
| **📖 Digitalna Knjiga** | Pisanje kućnih pravila, poruka dobrodošlice, AI znanja |
| **🖼️ Galerija** | Upload slika za screensaver na tabletu |
| **📊 Analitika** | Statistike prihoda, popunjenosti, izvora rezervacija |
| **📄 PDF Dokumenti** | Generiranje 10 različitih tipova dokumenata |
| **⚙️ Postavke** | Personalizacija teme, jezika, notifikacija |

### 10 Tipova PDF Dokumenata

1. **eVisitor Podaci** - Za prijavu gostiju u sustav eVisitor
2. **Kućna Pravila** - S prostorom za potpis gosta
3. **Dnevnik Čišćenja** - Checklist za čistače
4. **Raspored Jedinice** - 30-dnevni raspored jedne jedinice
5. **Tekstualna Lista (Puno)** - Sve rezervacije s detaljima
6. **Tekstualna Lista (Anon)** - Rezervacije bez osobnih podataka
7. **Raspored Čišćenja** - Kad treba čistiti koju jedinicu
8. **Grafički Kalendar (Puno)** - Vizualni prikaz s imenima
9. **Grafički Kalendar (Anon)** - Vizualni prikaz bez imena
10. **Povijest Rezervacija** - Kompletna arhiva

---

## 📱 Kako Gosti Koriste Tablet?

### Što Vide Gosti?

Kada gost dođe u smještaj, tablet prikazuje:

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│              🌅 DOBRODOŠLI U VILU SUNSET!                   │
│                                                             │
│     ─────────────────────────────────────────────────────   │
│                                                             │
│     📶 WiFi: VillaSunset_Guest                              │
│     🔑 Lozinka: Welcome2026                                 │
│                                                             │
│     ─────────────────────────────────────────────────────   │
│                                                             │
│     [📋 Kućna Pravila]  [🗺️ Vodič]  [🤖 Pitaj AI]           │
│                                                             │
│     ─────────────────────────────────────────────────────   │
│                                                             │
│     🌍 Jezik: [EN] [HR] [DE] [IT] [ES] [FR] ...            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Glavne Funkcije za Goste

| Gumb | Što Otvara |
|------|------------|
| **📋 Kućna Pravila** | Pravila boravka na odabranom jeziku |
| **🗺️ Vodič** | Informacije o okolici, plaže, restorani |
| **🤖 Pitaj AI** | Chat s AI asistentom za pitanja |
| **✍️ Potpis** | Digitalno potpisivanje dokumenata |
| **📞 Kontakt** | Hitni kontakti vlasnika |

### AI Asistent

Gosti mogu pitati AI asistenta razna pitanja:

```
Gost: "Gdje mogu jesti dobar rižot?"

AI:  "Preporučujem Konobu Fetivi! 🍽️
      
      📍 Lokacija: 5 minuta hoda od vile
      ⭐ Specijalitet: Crni rižot s lignjama
      💰 Cijene: Srednji rang (15-25€ po osobi)
      📞 Rezervacije: +385 21 123 456
      
      Trebate li upute kako doći?"
```

AI zna odgovoriti na temelju informacija koje ste vi unijeli u web panelu!

### Screensaver

Kada nitko ne koristi tablet, prikazuje se screensaver s lijepim slikama koje ste vi učitali - vaša vila, okolica, plaže, zalasci sunca...

---

## 🔒 Sigurnost i Privatnost

### Kako Štitimo Vaše Podatke?

| Mjera | Opis |
|-------|------|
| **🔐 Enkripcija** | Svi podaci su enkriptirani u prijenosu i pohrani |
| **👤 Izolacija** | Svaki vlasnik vidi samo svoje podatke |
| **🔑 JWT Autentifikacija** | Sigurni tokeni za prijavu |
| **📋 Audit Logovi** | Sve akcije se bilježe |
| **💾 Backup** | Dnevne sigurnosne kopije |

### Što Gosti NE Mogu Vidjeti?

- ❌ Podatke drugih gostiju
- ❌ Vaše financijske podatke
- ❌ Pristup administraciji
- ❌ Druge jedinice (osim svoje)

### GDPR Usklađenost

Sustav je dizajniran s poštivanjem europskih propisa o zaštiti podataka:
- Minimalno prikupljanje podataka
- Pravo na brisanje
- Transparentnost korištenja

---

## ❓ Česta Pitanja

### Općenito

**P: Trebam li instalirati neki program na računalo?**
O: Ne! Web panel se otvara u pregledniku, kao bilo koja web stranica.

**P: Mogu li pristupiti s mobitela?**
O: Da! Web panel je responzivan i radi na svim uređajima.

**P: Što ako nemam internet u smještaju?**
O: Tablet ima offline način rada i prikazuje posljednje preuzete informacije.

### Tablet

**P: Koji tablet trebam kupiti?**
O: Bilo koji Android tablet s verzijom 8.0 ili novijom. Preporučujemo 10" ekran.

**P: Mogu li gosti "pobjeći" iz aplikacije?**
O: Ne. Aplikacija radi u kiosk načinu koji onemogućuje izlazak.

**P: Što ako tablet ostane bez baterije?**
O: Preporučujemo da je tablet uvijek spojen na punjač.

### Sigurnost

**P: Mogu li gosti vidjeti moje druge rezervacije?**
O: Ne. Gosti vide samo informacije relevantne za njihov boravak.

**P: Što ako netko ukrade tablet?**
O: Tablet je beskoristan bez vaših vjerodajnica. Možete ga udaljeno deregistrirati.

### Cijena

**P: Koliko košta sustav?**
O: Kontaktirajte nas za informacije o cijenama i paketima.

**P: Ima li ugovorne obveze?**
O: Detalji ovise o odabranom paketu.

---

## 📞 Kontakt

Za dodatne informacije ili demo prezentaciju:

- **Email:** nevenroksa@gmail.com
- **GitHub:** @nroxa92
- **Web:** https://vls-admin.web.app

---

## 📊 Brzi Pregled Sustava

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         VESTA LUMINA SYSTEM                                   ║
║                    Kompletno Rješenje za Smještaj                             ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  🧩 KOMPONENTE                                                                ║
║  ─────────────────────────────────────────────────────────────────────────── ║
║  │ Web Panel          │ Za vlasnike - upravljanje svime                      ║
║  │ Tablet Aplikacija  │ Za goste - informacije i interakcija                 ║
║  │ Cloud Backend      │ Povezuje sve, čuva podatke                           ║
║                                                                               ║
║  ✨ GLAVNE FUNKCIJE                                                           ║
║  ─────────────────────────────────────────────────────────────────────────── ║
║  │ Kalendar rezervacija     │ Drag & drop, vizualni pregled                  ║
║  │ Digitalna knjiga gostiju │ Pravila, poruke, AI znanje                     ║
║  │ PDF dokumenti            │ 10 tipova za sve potrebe                       ║
║  │ Analitika                │ Prihodi, statistike, izvještaji                ║
║  │ AI asistent              │ Odgovara na pitanja gostiju                    ║
║  │ Višejezičnost            │ 11 jezika automatski                           ║
║                                                                               ║
║  🔢 BROJKE                                                                    ║
║  ─────────────────────────────────────────────────────────────────────────── ║
║  │ Podržani jezici    │ 11 (EN, HR, DE, IT, ES, FR, PL, SK, CS, HU, SL)     ║
║  │ PDF tipovi         │ 10 različitih dokumenata                             ║
║  │ Tema boja          │ 10 primarnih + 6 pozadina                            ║
║  │ Cloud Functions    │ 20 serverless funkcija                               ║
║                                                                               ║
║  🎯 ZA KOGA                                                                   ║
║  ─────────────────────────────────────────────────────────────────────────── ║
║  │ ✅ Vlasnici vila i apartmana                                              ║
║  │ ✅ Property manageri                                                       ║
║  │ ✅ Agencije za iznajmljivanje                                             ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## 📜 Napomena

```
Vesta Lumina System - Verzija 0.0.9 Beta
© 2025-2026 Sva prava pridržana.

Ovaj dokument je informativne prirode.
Funkcionalnosti se mogu razlikovati u konačnoj verziji.
```
