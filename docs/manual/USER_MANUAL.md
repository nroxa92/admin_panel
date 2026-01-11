# VESTA LUMINA USER MANUAL
## Korisnički Priručnik / User Guide

**Verzija / Version:** 2.1.0  
**Datum / Date:** Siječanj / January 2026

---

## Sadržaj / Table of Contents

**HRVATSKI**
1. [Uvod](#1-uvod)
2. [Početak Rada](#2-početak-rada)
3. [Upravljanje Jedinicama](#3-upravljanje-jedinicama)
4. [Upravljanje Rezervacijama](#4-upravljanje-rezervacijama)
5. [Prijava Gostiju](#5-prijava-gostiju)
6. [Kućni Red](#6-kućni-red)
7. [Čišćenje](#7-čišćenje)
8. [AI Asistent](#8-ai-asistent)
9. [Izvještaji](#9-izvještaji)
10. [Postavke](#10-postavke)

**ENGLISH**
11. [Introduction](#11-introduction)
12. [Getting Started](#12-getting-started)
13. [Unit Management](#13-unit-management)
14. [Booking Management](#14-booking-management)
15. [Guest Check-in](#15-guest-check-in)
16. [House Rules](#16-house-rules)
17. [Cleaning](#17-cleaning)
18. [AI Assistant](#18-ai-assistant)
19. [Reports](#19-reports)
20. [Settings](#20-settings)

---

# HRVATSKI

## 1. Uvod

### 1.1. O Sustavu

Vesta Lumina je integrirani sustav za upravljanje kratkoročnim iznajmljivanjem koji se sastoji od:

- **Admin Panel** - Web aplikacija za vlasnike
- **Tablet Terminal** - Aplikacija za samoposlužnu prijavu gostiju

### 1.2. Preduvjeti

- Računalo s modernim web preglednikom (Chrome, Firefox, Safari, Edge)
- Internet veza
- Android tablet za terminal (opcionalno, ali preporučeno)

---

## 2. Početak Rada

### 2.1. Registracija

1. Posjetite https://app.vestalumina.com
2. Kliknite "Registracija"
3. Unesite email i lozinku
4. Potvrdite email adresu klikom na link
5. Prijavite se u sustav

### 2.2. Prvo Prijavljivanje

Nakon prve prijave, sustav vas vodi kroz postavljanje:

```
┌─────────────────────────────────────────┐
│         DOBRODOŠLI U VESTA LUMINA       │
├─────────────────────────────────────────┤
│                                         │
│  Koraci postavljanja:                   │
│                                         │
│  [✓] 1. Kreirajte profil               │
│  [ ] 2. Dodajte prvu jedinicu          │
│  [ ] 3. Postavite kućni red            │
│  [ ] 4. Povežite kalendar              │
│  [ ] 5. Instalirajte tablet (opcion.)  │
│                                         │
└─────────────────────────────────────────┘
```

### 2.3. Navigacija

```
┌─────────────────────────────────────────────────────────────┐
│  🏠 Vesta Lumina                              👤 Profil    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📊 Nadzorna ploča                                         │
│  📅 Rezervacije                                            │
│  🏨 Jedinice                                               │
│  👥 Gosti                                                  │
│  🧹 Čišćenje                                               │
│  📋 Kućni red                                              │
│  🤖 AI Asistent                                            │
│  📈 Izvještaji                                             │
│  ⚙️ Postavke                                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Upravljanje Jedinicama

### 3.1. Dodavanje Nove Jedinice

1. Idite na **Jedinice** u izborniku
2. Kliknite **"+ Nova Jedinica"**
3. Ispunite podatke:

| Polje | Opis | Primjer |
|-------|------|---------|
| Naziv | Ime jedinice | Apartman Sunset |
| Tip | Vrsta smještaja | Apartman |
| Adresa | Puna adresa | Obala 45, Split |
| Kapacitet | Maks. broj gostiju | 6 |
| Spavaće sobe | Broj soba | 2 |
| Kupaonice | Broj kupaonica | 1 |

4. Kliknite **"Spremi"**

### 3.2. WiFi Podaci

Za svaku jedinicu možete postaviti WiFi podatke koji se prikazuju gostima:

1. Otvorite jedinicu
2. Idite na karticu **"WiFi"**
3. Unesite:
   - Naziv mreže (SSID)
   - Lozinka
4. Kliknite **"Spremi"**

### 3.3. Povezivanje Tableta

1. Otvorite jedinicu
2. Idite na karticu **"Terminal"**
3. Kliknite **"Generiraj Kod"**
4. Na tabletu unesite prikazani 6-znamenkasti kod
5. Status se mijenja u "Povezan"

---

## 4. Upravljanje Rezervacijama

### 4.1. Kalendar

Kalendar prikazuje sve rezervacije za odabranu jedinicu:

```
┌─────────────────────────────────────────────────────────────┐
│  ◄ Veljača 2026 ►                          [Tjedan] [Mjesec]│
├─────┬─────┬─────┬─────┬─────┬─────┬─────────────────────────┤
│ Pon │ Uto │ Sri │ Čet │ Pet │ Sub │ Ned                     │
├─────┼─────┼─────┼─────┼─────┼─────┼─────────────────────────┤
│     │     │     │     │     │  1  │  2                      │
│     │     │     │     │     │     │                         │
├─────┼─────┴─────┴─────┴─────┴─────┴─────────────────────────┤
│  3  │░░░░░░░░░░ John Doe ░░░░░░░░░░│  8  │  9               │
│     │░░░░░░░░░░ (15-20.02) ░░░░░░░░│     │                  │
├─────┼─────────────────────────────────────┴─────────────────┤
│ 10  │ 11  │ 12  │ 13  │ 14  │ 15  │ 16                      │
└─────┴─────┴─────┴─────┴─────┴─────┴─────────────────────────┘
```

### 4.2. Kreiranje Rezervacije

**Metoda 1: Ručni Unos**
1. Kliknite na datum u kalendaru
2. Ili kliknite **"+ Nova Rezervacija"**
3. Ispunite podatke:

| Polje | Obavezno | Opis |
|-------|----------|------|
| Check-in | ✓ | Datum dolaska |
| Check-out | ✓ | Datum odlaska |
| Ime gosta | ✓ | Puno ime |
| Email | ✓ | Email adresa |
| Telefon | - | Kontakt broj |
| Broj odraslih | ✓ | Odrasle osobe |
| Broj djece | - | Djeca |
| Cijena | - | Ukupna cijena |
| Izvor | - | Airbnb, Booking, direktno |
| Napomene | - | Posebni zahtjevi |

4. Kliknite **"Spremi"**

**Metoda 2: iCal Sinkronizacija**
1. Idite na **Postavke** → **Integracije**
2. Kliknite **"+ Dodaj Kalendar"**
3. Zalijepite iCal URL iz Airbnb/Booking.com
4. Odaberite jedinicu
5. Kliknite **"Poveži"**

### 4.3. Statusi Rezervacija

| Status | Boja | Značenje |
|--------|------|----------|
| Potvrđena | 🟢 Zelena | Rezervacija aktivna |
| Na čekanju | 🟡 Žuta | Čeka potvrdu |
| Prijavljen | 🔵 Plava | Gost se prijavio |
| Završena | ⚫ Siva | Gost otišao |
| Otkazana | 🔴 Crvena | Rezervacija otkazana |

### 4.4. Drag & Drop

Možete premještati rezervacije povlačenjem:
- Povucite rezervaciju na novi datum za promjenu
- Sustav automatski provjerava konflikte

---

## 5. Prijava Gostiju

### 5.1. Proces na Tabletu

Kada gost dođe, koristi tablet terminal:

```
┌─────────────────────────────────────────┐
│                                         │
│         DOBRODOŠLI / WELCOME            │
│                                         │
│    Dodirnite zaslon za početak          │
│    Tap to start                         │
│                                         │
└─────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────┐
│                                         │
│    Unesite referentni broj rezervacije  │
│                                         │
│    [ VL-2026-ABC123 ]                   │
│                                         │
│         [NASTAVI]                       │
│                                         │
└─────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────┐
│                                         │
│    Skenirajte osobni dokument           │
│                                         │
│         📷 [SKENIRAJ]                   │
│                                         │
│    ili [RUČNI UNOS]                     │
│                                         │
└─────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────┐
│                                         │
│    Kućni red                            │
│                                         │
│    ☐ Zabranjeno pušenje                 │
│    ☐ Vrijeme mira 22:00-08:00           │
│    ☐ Maksimalno 6 gostiju               │
│                                         │
│    [PRIHVAĆAM]                          │
│                                         │
└─────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────┐
│                                         │
│    Digitalni potpis                     │
│                                         │
│    ┌─────────────────────────┐          │
│    │                         │          │
│    │   [Potpišite ovdje]     │          │
│    │                         │          │
│    └─────────────────────────┘          │
│                                         │
│    [POTVRDI]                            │
│                                         │
└─────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────┐
│                                         │
│    ✓ PRIJAVA USPJEŠNA!                  │
│                                         │
│    WiFi: Guest_WiFi                     │
│    Lozinka: welcome123                  │
│                                         │
│    Ugodan boravak!                      │
│                                         │
└─────────────────────────────────────────┘
```

### 5.2. Pregled Prijava

U Admin Panelu možete pratiti sve prijave:

1. Idite na **Gosti**
2. Vidite listu svih prijavljenih gostiju
3. Kliknite na gosta za detalje:
   - Skenirani podaci
   - Potpis
   - Vrijeme prijave

---

## 6. Kućni Red

### 6.1. Kreiranje Kućnog Reda

1. Idite na **Kućni Red**
2. Odaberite jedinicu
3. Kliknite **"Uredi"**
4. Dodajte pravila:

```
Primjer kućnog reda:
─────────────────────
1. Zabranjeno pušenje u apartmanu
2. Vrijeme mira: 22:00 - 08:00
3. Zabranjena organizacija zabava
4. Maksimalno 6 gostiju
5. Kućni ljubimci nisu dozvoljeni
6. Ključeve ostaviti na recepciji pri odlasku
```

### 6.2. Višejezična Podrška

Možete dodati prijevode na 11 jezika:
- 🇬🇧 Engleski
- 🇭🇷 Hrvatski
- 🇩🇪 Njemački
- 🇮🇹 Talijanski
- 🇸🇮 Slovenski
- 🇫🇷 Francuski
- 🇪🇸 Španjolski
- 🇵🇹 Portugalski
- 🇳🇱 Nizozemski
- 🇵🇱 Poljski
- 🇨🇿 Češki

---

## 7. Čišćenje

### 7.1. Upravljanje Čistačima

1. Idite na **Čišćenje** → **Čistači**
2. Dodajte čistača:
   - Ime i prezime
   - Telefon
   - Email
   - PIN kod (za pristup tabletu)

### 7.2. Check-liste

Kreirajte check-liste za čistače:

```
☐ Spavaća soba
  ☐ Promijenjena posteljina
  ☐ Usisano
  ☐ Obrisana prašina
  
☐ Kupaonica
  ☐ Očišćena sanitarija
  ☐ Novi ručnici
  ☐ Dopunjeni toaletni papir
  
☐ Kuhinja
  ☐ Oprana suđe
  ☐ Očišćene površine
  ☐ Prazan hladnjak
  
☐ Opće
  ☐ Prozori zatvoreni
  ☐ Klima isključena
  ☐ Smeće izneseno
```

### 7.3. Pregled Logova

Pratite dovršena čišćenja:
- Vrijeme početka i završetka
- Trajanje
- Fotografije
- Prijavljeni problemi

---

## 8. AI Asistent

### 8.1. Baza Znanja

Konfigurirajte odgovore AI asistenta:

1. Idite na **AI Asistent**
2. Odaberite jedinicu
3. Dodajte pitanja i odgovore:

| Pitanje | Odgovor |
|---------|---------|
| Gdje je najbliža plaža? | Plaža Bačvice je udaljena 500m, 5 minuta hoda. |
| Kako koristiti klimu? | Daljinski je na noćnom ormariću. Postavite na 24°C za ugodnu temperaturu. |
| Ima li parking? | Da, parking je uključen. Mjesto #12 u garaži. |

### 8.2. Pregled Razgovora

Možete pregledati sve razgovore gostiju s AI asistentom:
- Vrijeme razgovora
- Pitanja i odgovori
- Zadovoljstvo gosta

---

## 9. Izvještaji

### 9.1. Dostupni Izvještaji

| Izvještaj | Sadržaj |
|-----------|---------|
| Mjesečni pregled | Prihodi, popunjenost, prosječna cijena |
| Popunjenost | Stopa popunjenosti po jedinicama |
| Prihodi | Prihodi po izvorima i jedinicama |
| Demografija gostiju | Nacionalnosti, izvori rezervacija |
| Performanse čišćenja | Trajanje, kvaliteta |

### 9.2. Generiranje Izvještaja

1. Idite na **Izvještaji**
2. Odaberite tip izvještaja
3. Postavite period (od - do)
4. Odaberite jedinice
5. Kliknite **"Generiraj"**
6. Preuzmite kao PDF ili Excel

---

## 10. Postavke

### 10.1. Profil

- Ime i prezime
- Email
- Telefon
- Naziv tvrtke
- OIB

### 10.2. Sigurnost

- Promjena lozinke
- Dvostruka autentifikacija (2FA)
- Aktivne sesije

### 10.3. Obavijesti

Konfigurirajte koje obavijesti želite primati:

| Obavijest | Email | Push | SMS |
|-----------|-------|------|-----|
| Nova rezervacija | ✓ | ✓ | - |
| Prijava gosta | ✓ | ✓ | - |
| Čišćenje završeno | ✓ | ✓ | - |
| Problem prijavljen | ✓ | ✓ | ✓ |

### 10.4. Integracije

- Airbnb iCal
- Booking.com iCal
- Google Calendar
- Vlastiti PMS

---

# ENGLISH

## 11. Introduction

### 11.1. About the System

Vesta Lumina is an integrated short-term rental management system consisting of:

- **Admin Panel** - Web application for owners
- **Tablet Terminal** - App for guest self-service check-in

### 11.2. Prerequisites

- Computer with modern web browser (Chrome, Firefox, Safari, Edge)
- Internet connection
- Android tablet for terminal (optional but recommended)

---

## 12. Getting Started

### 12.1. Registration

1. Visit https://app.vestalumina.com
2. Click "Register"
3. Enter email and password
4. Confirm email address by clicking the link
5. Log in to the system

### 12.2. First Login

After first login, the system guides you through setup:

```
┌─────────────────────────────────────────┐
│       WELCOME TO VESTA LUMINA           │
├─────────────────────────────────────────┤
│                                         │
│  Setup steps:                           │
│                                         │
│  [✓] 1. Create profile                 │
│  [ ] 2. Add first unit                 │
│  [ ] 3. Set up house rules             │
│  [ ] 4. Connect calendar               │
│  [ ] 5. Install tablet (optional)      │
│                                         │
└─────────────────────────────────────────┘
```

### 12.3. Navigation

```
┌─────────────────────────────────────────────────────────────┐
│  🏠 Vesta Lumina                              👤 Profile    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📊 Dashboard                                              │
│  📅 Bookings                                               │
│  🏨 Units                                                  │
│  👥 Guests                                                 │
│  🧹 Cleaning                                               │
│  📋 House Rules                                            │
│  🤖 AI Assistant                                           │
│  📈 Reports                                                │
│  ⚙️ Settings                                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 13. Unit Management

### 13.1. Adding a New Unit

1. Go to **Units** in the menu
2. Click **"+ New Unit"**
3. Fill in the details:

| Field | Description | Example |
|-------|-------------|---------|
| Name | Unit name | Apartment Sunset |
| Type | Property type | Apartment |
| Address | Full address | Obala 45, Split |
| Capacity | Max guests | 6 |
| Bedrooms | Number of bedrooms | 2 |
| Bathrooms | Number of bathrooms | 1 |

4. Click **"Save"**

### 13.2. WiFi Details

For each unit, you can set WiFi details displayed to guests:

1. Open the unit
2. Go to **"WiFi"** tab
3. Enter:
   - Network name (SSID)
   - Password
4. Click **"Save"**

### 13.3. Connecting Tablet

1. Open the unit
2. Go to **"Terminal"** tab
3. Click **"Generate Code"**
4. Enter the displayed 6-digit code on tablet
5. Status changes to "Connected"

---

## 14. Booking Management

### 14.1. Calendar

The calendar displays all bookings for the selected unit.

### 14.2. Creating a Booking

**Method 1: Manual Entry**
1. Click on a date in the calendar
2. Or click **"+ New Booking"**
3. Fill in details:

| Field | Required | Description |
|-------|----------|-------------|
| Check-in | ✓ | Arrival date |
| Check-out | ✓ | Departure date |
| Guest name | ✓ | Full name |
| Email | ✓ | Email address |
| Phone | - | Contact number |
| Adults | ✓ | Number of adults |
| Children | - | Number of children |
| Price | - | Total price |
| Source | - | Airbnb, Booking, direct |
| Notes | - | Special requests |

4. Click **"Save"**

**Method 2: iCal Sync**
1. Go to **Settings** → **Integrations**
2. Click **"+ Add Calendar"**
3. Paste iCal URL from Airbnb/Booking.com
4. Select unit
5. Click **"Connect"**

### 14.3. Booking Statuses

| Status | Color | Meaning |
|--------|-------|---------|
| Confirmed | 🟢 Green | Active booking |
| Pending | 🟡 Yellow | Awaiting confirmation |
| Checked-in | 🔵 Blue | Guest arrived |
| Completed | ⚫ Gray | Guest left |
| Cancelled | 🔴 Red | Booking cancelled |

---

## 15. Guest Check-in

### 15.1. Process on Tablet

When a guest arrives, they use the tablet terminal for self-service check-in with OCR document scanning and digital signature.

### 15.2. Viewing Check-ins

In Admin Panel you can track all check-ins:
1. Go to **Guests**
2. View list of all checked-in guests
3. Click on guest for details

---

## 16. House Rules

### 16.1. Creating House Rules

1. Go to **House Rules**
2. Select unit
3. Click **"Edit"**
4. Add rules

### 16.2. Multi-language Support

You can add translations in 11 languages.

---

## 17. Cleaning

### 17.1. Managing Cleaners

1. Go to **Cleaning** → **Cleaners**
2. Add cleaner with name, phone, email, and PIN

### 17.2. Checklists

Create checklists for cleaners with tasks for each room.

### 17.3. Viewing Logs

Track completed cleanings with times, photos, and reported issues.

---

## 18. AI Assistant

### 18.1. Knowledge Base

Configure AI assistant responses with questions and answers about your property.

### 18.2. Reviewing Conversations

View all guest conversations with the AI assistant.

---

## 19. Reports

### 19.1. Available Reports

| Report | Content |
|--------|---------|
| Monthly Overview | Revenue, occupancy, average price |
| Occupancy | Occupancy rate by units |
| Revenue | Revenue by sources and units |
| Guest Demographics | Nationalities, booking sources |
| Cleaning Performance | Duration, quality |

### 19.2. Generating Reports

1. Go to **Reports**
2. Select report type
3. Set date range
4. Select units
5. Click **"Generate"**
6. Download as PDF or Excel

---

## 20. Settings

### 20.1. Profile

- Name, email, phone
- Company name, tax ID

### 20.2. Security

- Change password
- Two-factor authentication (2FA)
- Active sessions

### 20.3. Notifications

Configure which notifications you want to receive via email, push, or SMS.

### 20.4. Integrations

- Airbnb iCal
- Booking.com iCal
- Google Calendar
- Custom PMS

---

## Quick Reference Card

| Action | Where | How |
|--------|-------|-----|
| Add unit | Units | Click "+ New Unit" |
| Add booking | Bookings | Click date or "+ New Booking" |
| Connect tablet | Units → Terminal | Generate code, enter on tablet |
| Add cleaner | Cleaning → Cleaners | Click "+ Add Cleaner" |
| Generate report | Reports | Select type, dates, generate |
| Edit house rules | House Rules | Select unit, edit |
| Configure AI | AI Assistant | Select unit, add Q&A |

---

## Support / Podrška

**Email:** support@vestalumina.com  
**Phone / Telefon:** +385 XX XXX XXXX  
**Hours / Radno vrijeme:** Mon-Fri 09:00-17:00 CET

---

<p align="center">
  <strong>VESTA LUMINA</strong><br>
  <em>Korisnički Priručnik / User Manual</em><br>
  Verzija / Version 2.1.0<br><br>
  © 2024-2026 Vesta Lumina d.o.o.
</p>
