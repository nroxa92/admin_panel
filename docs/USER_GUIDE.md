# 📖 Vesta Lumina Admin Panel - Korisnički Priručnik

> **Verzija 0.0.9 Beta** | **Siječanj 2026**
> **Upute za vlasnike smještajnih objekata**

---

## 📋 Sadržaj

1. [Uvod](#-uvod)
2. [Prijava u Sustav](#-prijava-u-sustav)
3. [Navigacija](#-navigacija)
4. [Početna Stranica (Dashboard)](#-početna-stranica-dashboard)
5. [Upravljanje Jedinicama](#-upravljanje-jedinicama)
6. [Kalendar Rezervacija](#-kalendar-rezervacija)
7. [Digitalna Knjiga Gostiju](#-digitalna-knjiga-gostiju)
8. [Galerija Slika](#-galerija-slika)
9. [Analitika i Statistike](#-analitika-i-statistike)
10. [Postavke](#-postavke)
11. [Ispis PDF Dokumenata](#-ispis-pdf-dokumenata)
12. [Česta Pitanja (FAQ)](#-česta-pitanja-faq)

---

## 🎯 Uvod

### Što je Vesta Lumina Admin Panel?

**Vesta Lumina Admin Panel** je web aplikacija za upravljanje vašim smještajnim objektima. Omogućuje vam:

- Pregled i upravljanje svim vašim jedinicama (vilama, apartmanima, sobama)
- Vođenje kalendara rezervacija s drag & drop funkcijom
- Pripremu digitalne knjige gostiju za tablet uređaje
- Praćenje prihoda i statistika
- Generiranje PDF dokumenata (eVisitor, kućna pravila, raspored čišćenja)
- Upravljanje galerijom slika za screensaver na tabletima

### Sistemski Zahtjevi

| Zahtjev | Preporučeno |
|---------|-------------|
| Web preglednik | Chrome, Firefox, Safari, Edge (najnovije verzije) |
| Internet veza | Stabilna broadband veza |
| Rezolucija ekrana | Minimalno 1280x720, preporučeno 1920x1080 |

### Pristup Aplikaciji

🌐 **Web adresa:** `https://vls-admin.web.app`

---

## 🔐 Prijava u Sustav

### Prva Prijava (Aktivacija Računa)

Ako ste novi korisnik, administrator vam je kreirao račun. Slijedite ove korake:

1. **Otvorite email** koji ste primili od sustava
2. **Kliknite na aktivacijski link** u emailu
3. **Unesite aktivacijski kod** koji ste dobili
4. **Postavite svoju lozinku**
5. **Prijavite se** s vašom email adresom i novom lozinkom

### Redovna Prijava

1. Otvorite `https://vls-admin.web.app`
2. Unesite vašu **email adresu**
3. Unesite vašu **lozinku**
4. Kliknite **"Prijava"**

### Zaboravljena Lozinka?

1. Na stranici za prijavu kliknite **"Zaboravljena lozinka?"**
2. Unesite vašu email adresu
3. Provjerite inbox (i spam folder) za link za resetiranje
4. Slijedite upute u emailu za postavljanje nove lozinke

---

## 🧭 Navigacija

### Bočna Traka (Sidebar)

Na lijevoj strani ekrana nalazi se navigacijska traka s glavnim sekcijama:

| Ikona | Naziv | Opis |
|-------|-------|------|
| 🏠 | **Početna** | Pregled svih jedinica i brzi pristup |
| 📅 | **Kalendar** | Kalendar rezervacija s drag & drop |
| 📖 | **Digitalna Knjiga** | Postavke za tablet (pravila, poruke) |
| 🖼️ | **Galerija** | Upravljanje slikama za screensaver |
| 📊 | **Analitika** | Statistike i prihodi |
| ⚙️ | **Postavke** | Osobne postavke i konfiguracija |

### Brza Navigacija

- **Klik na logo** - vraća vas na početnu stranicu
- **Klik na ime jedinice** - otvara detalje te jedinice
- **Escape tipka** - zatvara otvorene dijaloge

---

## 🏠 Početna Stranica (Dashboard)

### Pregled Jedinica

Na početnoj stranici vidite **sve vaše smještajne jedinice** prikazane kao kartice:

```
┌─────────────────────────────────────────────────────────────┐
│  🏠 Vila Sunset                                    [Zone A] │
│  ─────────────────────────────────────────────────────────  │
│  📍 Adresa: Put Firula 25, Split                           │
│  📶 WiFi: VillaSunset_Guest                                │
│  🔑 PIN čistača: ****                                      │
│                                                             │
│  Status: ✅ Aktivna                                         │
│                                                             │
│  [📝 Uredi]  [📅 Kalendar]  [🖨️ Ispis]                      │
└─────────────────────────────────────────────────────────────┘
```

### Akcije na Kartici Jedinice

| Gumb | Funkcija |
|------|----------|
| **📝 Uredi** | Otvorite postavke jedinice (naziv, adresa, WiFi, PIN) |
| **📅 Kalendar** | Direktan skok na kalendar te jedinice |
| **🖨️ Ispis** | Brzi ispis PDF dokumenta za tu jedinicu |

### Dodavanje Nove Jedinice

1. Kliknite gumb **"+ Nova Jedinica"** u gornjem desnom kutu
2. Ispunite podatke:
   - **Naziv** (npr. "Vila Sunset")
   - **Adresa** (puna adresa objekta)
   - **Zona** (za grupiranje - npr. "Zone A", "Centar")
   - **Kategorija** (vila, apartman, soba, studio)
3. Opcionalno dodajte:
   - **WiFi naziv i lozinka** (prikazat će se gostima na tabletu)
   - **PIN čistača** (4-znamenkasti kod za pristup čistača)
   - **Link za recenziju** (Airbnb, Booking.com, Google)
4. Kliknite **"Spremi"**

---

## 📅 Kalendar Rezervacija

### Pregled Kalendara

Kalendar prikazuje sve rezervacije za vaše jedinice u vizualnom formatu:

```
          PON    UTO    SRI    ČET    PET    SUB    NED
         ─────────────────────────────────────────────────
Vila A   │▓▓▓▓▓▓▓▓▓▓▓▓▓▓│      │░░░░░░░░░░░░░░░░░░░░│
         │  Marko K.    │      │     Ana P.         │
         ─────────────────────────────────────────────────
Vila B   │              │▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│        │
         │              │    John S.       │        │
         ─────────────────────────────────────────────────

Legenda:  ▓▓▓ Potvrđeno   ░░░ Na čekanju   ▒▒▒ Privatno
```

### Boje Rezervacija

| Boja | Značenje |
|------|----------|
| 🟢 Zelena | Potvrđena rezervacija (confirmed) |
| 🟡 Žuta | Na čekanju (pending) |
| 🔴 Crvena | Otkazana (cancelled) |
| 🟣 Ljubičasta | Privatno (private) - vlasnikova rezervacija |
| ⚫ Siva | Blokirano (blocked) - nedostupno |

### Izvori Rezervacija (Ikone)

| Ikona | Izvor |
|-------|-------|
| 🏠 | Airbnb |
| 📘 | Booking.com |
| 📞 | Direktna rezervacija |
| 📋 | Ostalo |

### Kreiranje Nove Rezervacije

1. **Kliknite na prazan dan** u kalendaru
2. Ili kliknite gumb **"+ Nova Rezervacija"**
3. Ispunite podatke:
   - **Jedinica** - odaberite smještaj
   - **Ime gosta** - puno ime glavnog gosta
   - **Broj gostiju** - ukupan broj osoba
   - **Datum dolaska** - check-in datum
   - **Datum odlaska** - check-out datum
   - **Vrijeme check-in/out** - ako je drugačije od zadanog
   - **Status** - potvrđeno, na čekanju, privatno, blokirano
   - **Izvor** - Airbnb, Booking, direktno, ostalo
   - **Cijena** - ukupna cijena boravka
   - **Napomene** - posebni zahtjevi gosta
4. Kliknite **"Spremi"**

### Drag & Drop Premještanje

Za premještanje rezervacije:
1. **Kliknite i držite** rezervaciju
2. **Povucite** na novi datum ili jedinicu
3. **Pustite** za potvrdu
4. Sustav će provjeriti preklapanja i upozoriti vas ako postoji konflikt

### Uređivanje Rezervacije

1. **Kliknite na rezervaciju** u kalendaru
2. Otvorit će se panel s detaljima
3. Kliknite **"Uredi"** za izmjene
4. Ili kliknite **"Obriši"** za brisanje (s potvrdom)

### Dodavanje Podataka Gostiju (eVisitor)

Za prijavu gostiju u eVisitor sustav:

1. Otvorite rezervaciju
2. Kliknite **"Dodaj gosta"**
3. Unesite podatke:
   - Ime i prezime
   - Datum rođenja
   - Državljanstvo
   - Vrsta dokumenta (osobna/putovnica)
   - Broj dokumenta
4. Ponovite za svakog gosta
5. Podaci će se automatski spremiti i biti dostupni za PDF export

### Period Prikaza

Možete odabrati koliko dana kalendar prikazuje:

| Opcija | Prikaz |
|--------|--------|
| **7 dana** | Tjedan dana (zadano) |
| **14 dana** | Dva tjedna |
| **30 dana** | Mjesec dana |
| **Sve** | Sve rezervacije |

### Filtriranje po Zonama

Ako imate puno jedinica, možete filtrirati po zonama:

1. Kliknite na **dropdown "Zone"** iznad kalendara
2. Odaberite zonu (npr. "Zone A", "Centar")
3. Kalendar će prikazati samo jedinice iz te zone

---

## 📖 Digitalna Knjiga Gostiju

### Što je Digitalna Knjiga?

Digitalna knjiga gostiju sadržava sve informacije koje će gosti vidjeti na tabletu u vašem smještaju. Tu postavljate:

- Poruku dobrodošlice
- Kućna pravila
- Upute za goste
- Kontakte za hitne slučajeve
- Znanje za AI asistenta

### Poruka Dobrodošlice

1. Otvorite **"Digitalna Knjiga"** u navigaciji
2. Pronađite sekciju **"Poruka Dobrodošlice"**
3. Napišite personaliziranu poruku na **11 jezika**:
   - Engleski (obavezno)
   - Hrvatski
   - Njemački
   - Talijanski
   - Španjolski
   - Francuski
   - Poljski
   - Slovački
   - Češki
   - Mađarski
   - Slovenski
4. Koristite gumb **"AI Prijevod"** za automatski prijevod s engleskog

**Primjer poruke dobrodošlice:**
```
Welcome to Villa Sunset! 🌅

We're delighted to have you as our guest. This beautiful villa 
has been our family's pride for three generations.

Enjoy the stunning sea views, the private pool, and the peaceful 
garden. The beach is just a 5-minute walk away.

If you need anything, don't hesitate to contact us!

Warm regards,
The Horvat Family
```

### Kućna Pravila

1. U sekciji **"Kućna Pravila"** napišite pravila na engleskom
2. Kliknite **"AI Prijevod"** za automatski prijevod na sve jezike
3. Pregledajte i po potrebi uredite prijevode

**Primjer kućnih pravila:**
```
HOUSE RULES

🚭 No smoking inside the property
🎉 No parties or events
🔇 Quiet hours: 10 PM - 8 AM
🐕 Pets allowed only with prior approval
🚗 Parking available in the garage (code: 1234)
🗑️ Please take out trash before checkout
🔑 Return keys to the lockbox at checkout
```

### Checklist za Čistače

Definirajte zadatke koje čistači moraju obaviti:

1. Otvorite sekciju **"Checklist Čistača"**
2. Dodajte zadatke jedan po jedan:
   - ✅ Promijeniti posteljinu
   - ✅ Očistiti kupaonicu
   - ✅ Usisati sve podove
   - ✅ Obrisati kuhinjske površine
   - ✅ Nadopuniti toaletne potrepštine
   - ✅ Iznijeti smeće
   - ✅ Provjeriti minibar
   - ✅ Fotografirati prije i poslije

### AI Znanje (Concierge)

AI asistent na tabletu može odgovarati na pitanja gostiju. Ovdje definirate znanje koje AI koristi:

**Kategorije znanja:**

| Kategorija | Primjeri sadržaja |
|------------|-------------------|
| **🍽️ Concierge** | Preporuke restorana, plaže, atrakcije |
| **🧹 Domaćinstvo** | Gdje su potrepštine, kako radi perilica |
| **💻 Tehnologija** | WiFi upute, TV, klima |
| **🗺️ Vodič** | Upute do plaže, parkiranje, javni prijevoz |

**Primjer za Concierge:**
```
RECOMMENDED RESTAURANTS:
- Konoba Fetivi (5 min walk) - Best local seafood, try the black risotto
- Dioklecijan (10 min) - Traditional Dalmatian cuisine
- Pizzeria Galija (3 min) - Great pizza, family-friendly

BEACHES:
- Bačvice (10 min walk) - Sandy beach, good for families
- Kasjuni (15 min by car) - Quieter, crystal clear water

ATTRACTIONS:
- Diocletian's Palace (15 min) - UNESCO World Heritage Site
- Marjan Hill (20 min) - Hiking and stunning views
```

### Kontakt za Hitne Slučajeve

Definirajte kontakte koji će biti vidljivi gostima:

1. **Ime kontakta** (npr. "Property Manager")
2. **Telefonski broj** (s pozivnim brojem)
3. **WhatsApp** (opcionalno)

---

## 🖼️ Galerija Slika

### Svrha Galerije

Slike koje učitate ovdje prikazuju se kao **screensaver na tabletu** u vašem smještaju. Gosti vide lijepe fotografije vašeg objekta i okolice.

### Učitavanje Slika

1. Otvorite **"Galerija"** u navigaciji
2. Odaberite jedinicu za koju učitavate slike
3. Kliknite **"+ Dodaj Slike"**
4. Odaberite slike s vašeg računala (možete odabrati više odjednom)
5. Pričekajte upload
6. Slike se automatski prikazuju na tabletu

### Preporučene Specifikacije Slika

| Parametar | Preporuka |
|-----------|-----------|
| Format | JPG ili PNG |
| Rezolucija | 1920x1080 ili veća |
| Orijentacija | Horizontalna (landscape) |
| Veličina | Maksimalno 5 MB po slici |

### Organizacija Slika

- **Drag & drop** za promjenu redoslijeda
- Slike se prikazuju redoslijedom kojim su poredane
- Kliknite **🗑️** za brisanje slike

### Preporučeni Sadržaj

✅ **Dobro za screensaver:**
- Eksterijer objekta
- Interijer soba
- Pogled s balkona/terase
- Bazen i vrt
- Okolne plaže i atrakcije
- Zalasci sunca

❌ **Izbjegavajte:**
- Slike s osobama
- Niske rezolucije
- Vertikalne fotografije
- Logotipi i tekst

---

## 📊 Analitika i Statistike

### Pregled Analitike

Sekcija analitike prikazuje statistike vašeg poslovanja:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRIHOD - SIJEČANJ 2026                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  💰 Ukupni Prihod:     €12,450                             │
│  📈 vs. prošli mjesec: +15%                                │
│                                                             │
│  📊 Po izvoru:                                              │
│     Airbnb:      €6,200 (50%)                              │
│     Booking:     €4,100 (33%)                              │
│     Direktno:    €2,150 (17%)                              │
│                                                             │
│  🏠 Po jedinici:                                            │
│     Vila Sunset: €5,400                                     │
│     Apt. Blue:   €4,200                                     │
│     Studio Sea:  €2,850                                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Dostupne Statistike

| Metrika | Opis |
|---------|------|
| **Ukupni prihod** | Suma svih rezervacija u periodu |
| **Popunjenost** | Postotak zauzetih noćenja |
| **Prosječna cijena** | Prosječna cijena po noćenju |
| **Broj gostiju** | Ukupan broj gostiju |
| **Broj rezervacija** | Broj pojedinačnih rezervacija |

### Periodi za Analizu

Možete pregledati statistike za:
- Ovaj tjedan
- Ovaj mjesec
- Ova godina
- Prošla godina
- Prilagođeni period (odaberite datume)

### Export Podataka

1. Kliknite **"Export"** u gornjem desnom kutu
2. Odaberite format:
   - **CSV** - za Excel/Google Sheets
   - **PDF** - za ispis ili arhivu
3. Podaci se preuzimaju na vaše računalo

---

## ⚙️ Postavke

### Osobne Postavke

#### Promjena Jezika Sučelja

1. Otvorite **"Postavke"**
2. U sekciji **"Jezik"** odaberite željeni jezik
3. Sučelje se odmah mijenja

Podržani jezici: 🇬🇧 EN, 🇭🇷 HR, 🇩🇪 DE, 🇮🇹 IT, 🇪🇸 ES, 🇫🇷 FR, 🇵🇱 PL, 🇸🇰 SK, 🇨🇿 CS, 🇭🇺 HU, 🇸🇮 SL

#### Promjena Teme (Boje)

1. U sekciji **"Tema"** odaberite primarnu boju:
   - 🟡 Gold (Zlato)
   - 🟤 Bronze (Bronca)
   - 🔵 Royal Blue (Kraljevsko plava)
   - 🟣 Burgundy (Bordo)
   - 🟢 Emerald (Smaragdna)
   - ⚫ Slate (Škriljevac)
   - 💚 Neon Green (Neon zelena)
   - 🔷 Cyan (Cijan)
   - 💗 Hot Pink (Roza)
   - 🟠 Electric Orange (Električna narančasta)

2. Odaberite pozadinu:
   - **Dark 1** - Čista crna (za OLED ekrane)
   - **Dark 2** - Material tamna
   - **Dark 3** - Mekša tamna
   - **Light 1** - Svijetlo siva
   - **Light 2** - Prljavo bijela
   - **Light 3** - Čista bijela

#### Promjena Lozinke

1. U sekciji **"Sigurnost"** kliknite **"Promijeni Lozinku"**
2. Unesite trenutnu lozinku
3. Unesite novu lozinku (minimalno 8 znakova)
4. Potvrdite novu lozinku
5. Kliknite **"Spremi"**

### PIN Kodovi

#### PIN Čistača

Četveroznamenkasti kod koji čistači koriste za pristup cleaning workflow-u na tabletu.

1. U sekciji **"PIN Kodovi"**
2. Kliknite **"Promijeni PIN Čistača"**
3. Unesite novi 4-znamenkasti kod
4. Kliknite **"Spremi"**

#### Master PIN (Hard Reset)

Šesteroznamenkasti kod za resetiranje tableta u slučaju problema.

1. Kliknite **"Promijeni Master PIN"**
2. Unesite novi 6-znamenkasti kod
3. **VAŽNO:** Zapišite ovaj kod na sigurno mjesto!

### Email Notifikacije

Postavite koje obavijesti želite primati emailom:

| Opcija | Opis |
|--------|------|
| ✅ Nove rezervacije | Email kad dođe nova rezervacija |
| ✅ Check-in podsjetnici | Email dan prije dolaska gosta |
| ⬜ Dnevni sažetak | Dnevni pregled aktivnosti |

### Podaci Tvrtke

Unesite podatke vaše tvrtke koji će se prikazivati na dokumentima:

- **Naziv tvrtke**
- **Adresa**
- **OIB**
- **Kontakt email**
- **Kontakt telefon**

---

## 🖨️ Ispis PDF Dokumenata

### Dostupni Tipovi Dokumenata

Sustav može generirati **10 različitih PDF dokumenata**:

| # | Naziv | Opis | Korištenje |
|---|-------|------|------------|
| 1 | **eVisitor Podaci** | Podaci gostiju za eVisitor prijavu | Prijava turista |
| 2 | **Kućna Pravila** | Pravila s prostorom za potpis | Potvrda gosta |
| 3 | **Dnevnik Čišćenja** | Checklist čišćenja s vremenima | Evidencija čistača |
| 4 | **Raspored Jedinice** | 30-dnevni raspored jedne jedinice | Pregled zauzetosti |
| 5 | **Tekstualna Lista (Puno)** | Lista rezervacija s punim podacima | Interna evidencija |
| 6 | **Tekstualna Lista (Anon)** | Lista rezervacija bez osobnih podataka | Dijeljenje s partnerima |
| 7 | **Raspored Čišćenja** | Raspored čišćenja za sve jedinice | Koordinacija čistača |
| 8 | **Grafički (Puno)** | Vizualni kalendar s imenima | Pregled na zidu |
| 9 | **Grafički (Anon)** | Vizualni kalendar bez imena | Javni prikaz |
| 10 | **Povijest Rezervacija** | Kompletna povijest svih rezervacija | Arhiva i izvještaji |

### Kako Generirati PDF

#### Iz Kalendara

1. Otvorite **"Kalendar"**
2. Kliknite **"🖨️ Ispis"** u gornjem desnom kutu
3. Odaberite tip dokumenta
4. Odaberite period (ako je primjenjivo)
5. Kliknite **"Generiraj"**
6. PDF se automatski preuzima

#### Iz Kartice Jedinice

1. Na početnoj stranici pronađite jedinicu
2. Kliknite **"🖨️ Ispis"** na kartici
3. Odaberite tip dokumenta
4. PDF se generira za tu jedinicu

#### Iz Rezervacije

1. Otvorite detalje rezervacije
2. Kliknite **"🖨️ Ispis"**
3. Dostupne opcije:
   - eVisitor podaci (samo za tu rezervaciju)
   - Kućna pravila (za potpis)

---

## ❓ Česta Pitanja (FAQ)

### Prijava i Račun

**P: Zaboravio/la sam lozinku. Što da radim?**
O: Na stranici za prijavu kliknite "Zaboravljena lozinka?" i slijedite upute za resetiranje.

**P: Mogu li promijeniti email adresu?**
O: Email adresa je vaš identifikator u sustavu i ne može se promijeniti. Kontaktirajte administratora ako trebate novi račun.

**P: Zašto me sustav automatski odjavljuje?**
O: Iz sigurnosnih razloga, sesija istječe nakon 24 sata neaktivnosti.

### Kalendar i Rezervacije

**P: Mogu li uvesti rezervacije iz Airbnb-a ili Booking.com-a?**
O: Trenutno podržavamo ručni unos. iCal sinkronizacija je u planu za buduće verzije.

**P: Što znači ako je rezervacija crvena?**
O: Crvena boja označava otkazanu rezervaciju.

**P: Mogu li imati dvije rezervacije koje se preklapaju?**
O: Ne za istu jedinicu. Sustav će vas upozoriti na preklapanje.

**P: Kako mogu blokirati datume za osobnu upotrebu?**
O: Kreirajte rezervaciju sa statusom "Privatno" ili "Blokirano".

### Tablet i Gosti

**P: Kako se tablet povezuje s ovim sustavom?**
O: Tablet koristi zasebnu aplikaciju (Vesta Lumina Client Terminal) koja se sinkronizira s vašim podacima u oblaku.

**P: Mogu li gosti vidjeti osobne podatke drugih gostiju?**
O: Ne. Gosti na tabletu vide samo poruku dobrodošlice, kućna pravila i opće informacije. Osobni podaci su zaštićeni.

**P: Što ako tablet izgubi internet vezu?**
O: Tablet ima offline način rada i nastavit će prikazivati posljednje preuzete informacije.

### PDF Dokumenti

**P: U kojem formatu se spremaju PDF-ovi?**
O: Standardni PDF format kompatibilan sa svim uređajima i preglednicima.

**P: Mogu li prilagoditi izgled PDF-a s logom tvrtke?**
O: Trenutno koristimo standardni predložak. Prilagodba je planirana za buduće verzije.

### Tehnički Problemi

**P: Stranica se sporo učitava. Što da radim?**
O: Provjerite internet vezu. Pokušajte osvježiti stranicu (F5) ili očistiti cache preglednika.

**P: Neke funkcije ne rade u mom pregledniku.**
O: Preporučujemo korištenje najnovije verzije Chrome, Firefox ili Safari preglednika.

**P: Kome se mogu obratiti za pomoć?**
O: Kontaktirajte administratora sustava ili pošaljite email na podršku.

---

## 📞 Podrška

Ako imate dodatnih pitanja ili trebate pomoć:

- **Email:** nevenroksa@gmail.com
- **Radno vrijeme podrške:** Pon-Pet 9:00-17:00

---

## 📜 Napomena

```
Ovaj priručnik odnosi se na Vesta Lumina Admin Panel verziju 0.0.9 Beta.
Funkcionalnosti se mogu razlikovati u novijim verzijama.

© 2025-2026 Sva prava pridržana.
```
