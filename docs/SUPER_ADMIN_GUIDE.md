# 👨‍💼 Vesta Lumina Super Admin Priručnik

> **Verzija 0.0.9 Beta** | **Siječanj 2026**
> **Upute za administratore sustava**

---

## ⚠️ Važna Napomena

Ovaj priručnik namijenjen je **isključivo super administratorima** sustava. Super admini imaju pristup svim podacima svih vlasnika i mogu upravljati cijelim sustavom.

**Primarni super admin:** vestaluminasystem@gmail.com

---

## 📋 Sadržaj

1. [Uloga Super Admina](#-uloga-super-admina)
2. [Pristup Super Admin Panelu](#-pristup-super-admin-panelu)
3. [Upravljanje Vlasnicima](#-upravljanje-vlasnicima)
4. [Upravljanje Tabletima](#-upravljanje-tabletima)
5. [Sistemske Notifikacije](#-sistemske-notifikacije)
6. [Audit Logovi](#-audit-logovi)
7. [Backup i Oporavak](#-backup-i-oporavak)
8. [Sigurnosne Smjernice](#-sigurnosne-smjernice)

---

## 👤 Uloga Super Admina

### Što je Super Admin?

Super admin je administrator s najvišom razinom pristupa u sustavu. Odgovornosti uključuju:

| Odgovornost | Opis |
|-------------|------|
| **Upravljanje vlasnicima** | Kreiranje, uređivanje, deaktivacija vlasničkih računa |
| **Upravljanje tabletima** | Registracija, praćenje, ažuriranje tablet uređaja |
| **Sistemske obavijesti** | Slanje važnih obavijesti svim korisnicima |
| **Nadzor sustava** | Praćenje zdravlja sustava i rješavanje problema |
| **Backup** | Pokretanje i praćenje sigurnosnih kopija |
| **Audit** | Pregled svih administrativnih akcija |

### Hijerarhija Pristupa

```
┌─────────────────────────────────────────────────────────────┐
│                    PRIMARNI SUPER ADMIN                      │
│              vestaluminasystem@gmail.com                     │
│  ─────────────────────────────────────────────────────────  │
│  • Može dodavati/uklanjati druge super admine               │
│  • Puni pristup svim funkcijama                             │
│  • Ne može biti uklonjen iz sustava                         │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    SEKUNDARNI SUPER ADMINI                   │
│  ─────────────────────────────────────────────────────────  │
│  • Puni pristup svim funkcijama osim upravljanja adminima   │
│  • Mogu biti uklonjeni od primarnog admina                  │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                         VLASNICI                             │
│  ─────────────────────────────────────────────────────────  │
│  • Pristup samo vlastitim podacima (tenant izolacija)       │
│  • Ne vide podatke drugih vlasnika                          │
│  • Ne mogu pristupiti admin funkcijama                      │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔐 Pristup Super Admin Panelu

### Prijava

1. Otvorite `https://vls-admin.web.app`
2. Prijavite se s vašim super admin email-om
3. Sustav automatski prepoznaje vašu ulogu
4. U navigaciji će se pojaviti **"Admin"** sekcija

### Navigacija Admin Panela

Super admin ima dodatne opcije u bočnoj traci:

| Ikona | Naziv | Funkcija |
|-------|-------|----------|
| 👥 | **Vlasnici** | Upravljanje vlasničkim računima |
| 📱 | **Tableti** | Upravljanje registriranim tabletima |
| 📢 | **Obavijesti** | Slanje sistemskih notifikacija |

---

## 👥 Upravljanje Vlasnicima

### Pregled Svih Vlasnika

Stranica "Vlasnici" prikazuje listu svih registriranih vlasnika:

```
┌─────────────────────────────────────────────────────────────────────────┐
│  VLASNICI                                            [+ Novi Vlasnik]   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  👤 Marko Horvat                                                        │
│     📧 marko@example.com                                                │
│     🏷️ Tenant ID: TENANT001                                             │
│     📅 Registriran: 15.12.2025.                                         │
│     ✅ Status: Aktivan                                                  │
│     [Uredi] [Reset Lozinke] [Deaktiviraj]                              │
│  ───────────────────────────────────────────────────────────────────── │
│  👤 Ana Kovač                                                           │
│     📧 ana@example.com                                                  │
│     🏷️ Tenant ID: TENANT002                                             │
│     📅 Registriran: 20.12.2025.                                         │
│     ✅ Status: Aktivan                                                  │
│     [Uredi] [Reset Lozinke] [Deaktiviraj]                              │
│  ───────────────────────────────────────────────────────────────────── │
│  👤 Ivan Novak                                                          │
│     📧 ivan@example.com                                                 │
│     🏷️ Tenant ID: TENANT003                                             │
│     📅 Registriran: 02.01.2026.                                         │
│     ⛔ Status: Deaktiviran                                              │
│     [Uredi] [Reset Lozinke] [Aktiviraj]                                │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Kreiranje Novog Vlasnika

1. Kliknite **"+ Novi Vlasnik"**
2. Ispunite podatke:

| Polje | Opis | Primjer |
|-------|------|---------|
| **Email** | Email adresa vlasnika | vlasnik@email.com |
| **Ime i prezime** | Puno ime vlasnika | Marko Horvat |
| **Tenant ID** | Jedinstveni identifikator | TENANT001 |

3. Kliknite **"Kreiraj"**

### Što se Događa Nakon Kreiranja?

1. Sustav kreira Firebase Auth korisnika
2. Postavlja custom claims (ownerId, role)
3. Kreira dokument u `owners` kolekciji
4. Šalje aktivacijski email vlasniku
5. Vlasnik prima email s uputama za aktivaciju

### Aktivacijski Proces Vlasnika

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│  Admin      │      │   Sustav    │      │   Vlasnik   │      │   Sustav    │
│  kreira     │ ──▶  │   šalje     │ ──▶  │   klikne    │ ──▶  │   aktivira  │
│  račun      │      │   email     │      │   link      │      │   račun     │
└─────────────┘      └─────────────┘      └─────────────┘      └─────────────┘
```

### Reset Lozinke Vlasnika

Ako vlasnik zaboravi lozinku:

1. Pronađite vlasnika u listi
2. Kliknite **"Reset Lozinke"**
3. Potvrdite akciju
4. Vlasnik će primiti email za resetiranje lozinke

### Deaktivacija/Aktivacija Vlasnika

**Deaktivacija** onemogućuje pristup bez brisanja podataka:

1. Kliknite **"Deaktiviraj"** pored vlasnika
2. Potvrdite akciju
3. Vlasnik više ne može pristupiti sustavu
4. Svi podaci ostaju sačuvani

**Reaktivacija:**
1. Kliknite **"Aktiviraj"** pored deaktiviranog vlasnika
2. Vlasnik može ponovno pristupiti

### Brisanje Vlasnika

⚠️ **OPREZ: Brisanje je trajno i nepovratno!**

1. Kliknite **"Obriši"** (dostupno samo za deaktivirane vlasnike)
2. Unesite potvrdu (ime vlasnika)
3. Potvrdite brisanje

**Što se briše:**
- Firebase Auth korisnik
- Svi dokumenti vlasnika u Firestore-u
- Sve slike u Storage-u
- Svi povezani tableti se odregistriraju

---

## 📱 Upravljanje Tabletima

### Pregled Registriranih Tableta

```
┌─────────────────────────────────────────────────────────────────────────┐
│  TABLETI                                                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  📱 Tablet #1 - Vila Sunset                                             │
│     🏷️ Device ID: ABC123XYZ                                             │
│     👤 Vlasnik: Marko Horvat (TENANT001)                                │
│     📦 Verzija: 0.0.5                                                   │
│     🔋 Baterija: 85% (punjenje)                                         │
│     🟢 Status: Online (zadnji heartbeat: prije 2 min)                   │
│     [Detalji] [Deregistriraj]                                          │
│  ───────────────────────────────────────────────────────────────────── │
│  📱 Tablet #2 - Apartman Blue                                           │
│     🏷️ Device ID: DEF456ABC                                             │
│     👤 Vlasnik: Ana Kovač (TENANT002)                                   │
│     📦 Verzija: 0.0.4                           ⚠️ Potrebna nadogradnja │
│     🔋 Baterija: 42%                                                    │
│     🟡 Status: Offline (zadnji heartbeat: prije 3 sata)                 │
│     [Detalji] [Deregistriraj]                                          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Status Tableta

| Status | Ikona | Značenje |
|--------|-------|----------|
| **Online** | 🟢 | Heartbeat primljen u zadnjih 15 minuta |
| **Idle** | 🟡 | Heartbeat primljen u zadnjih 60 minuta |
| **Offline** | 🔴 | Nema heartbeata više od 60 minuta |

### Heartbeat Mehanizam

Tablet šalje "heartbeat" signal svakih 5 minuta koji uključuje:
- Razinu baterije
- Status punjenja
- Verziju aplikacije
- Status mreže

### Upravljanje APK Verzijama

#### Upload Nove Verzije

1. Kliknite **"+ Nova Verzija APK"**
2. Ispunite podatke:
   - **Verzija** (npr. 0.0.6)
   - **Release notes** (opis promjena)
   - **Mandatory** (obavezna nadogradnja da/ne)
3. Učitajte APK datoteku
4. Kliknite **"Upload"**

#### Distribucija Ažuriranja

Kada učitate novu verziju:
1. Tableti primaju obavijest o novoj verziji pri sljedećem heartbeatu
2. Ako je **Mandatory = true**, tablet se automatski ažurira
3. Ako je **Mandatory = false**, vlasnik odlučuje kada ažurirati

### Deregistracija Tableta

1. Kliknite **"Deregistriraj"** pored tableta
2. Potvrdite akciju
3. Tablet se odspaja od sustava
4. Za ponovnu registraciju potrebno je ponovno upariti tablet

---

## 📢 Sistemske Notifikacije

### Vrste Notifikacija

| Tip | Ikona | Korištenje |
|-----|-------|------------|
| **Info** | ℹ️ | Opće informacije, nova funkcionalnost |
| **Warning** | ⚠️ | Upozorenja, planirano održavanje |
| **Critical** | 🚨 | Hitne obavijesti, prekidi usluge |

### Kreiranje Notifikacije

1. Otvorite **"Obavijesti"** u admin panelu
2. Kliknite **"+ Nova Obavijest"**
3. Ispunite:

| Polje | Opis |
|-------|------|
| **Naslov** | Kratki naslov (do 100 znakova) |
| **Poruka** | Detaljna poruka (do 500 znakova) |
| **Tip** | Info / Warning / Critical |
| **Aktivna** | Da li je trenutno vidljiva |
| **Istječe** | Datum kada automatski nestaje |

4. Kliknite **"Objavi"**

### Primjer Notifikacija

**Info notifikacija:**
```
Naslov: Nova Funkcionalnost! 🎉
Poruka: Sada možete exportati kalendar u iCal format. 
        Pronađite opciju u meniju Kalendar > Export.
Tip: Info
Istječe: 15.01.2026.
```

**Warning notifikacija:**
```
Naslov: Planirano Održavanje
Poruka: Sustav će biti nedostupan 12.01.2026. od 02:00 do 04:00 
        zbog redovnog održavanja. Ispričavamo se na neugodnosti.
Tip: Warning
Istječe: 12.01.2026.
```

**Critical notifikacija:**
```
Naslov: Hitno - Sigurnosno Ažuriranje
Poruka: Molimo sve korisnike da promijene lozinke. 
        Postavke > Sigurnost > Promijeni Lozinku
Tip: Critical
Istječe: (bez isteka dok admin ne makne)
```

### Gdje se Prikazuju Notifikacije?

- **Web panel:** Banner na vrhu ekrana
- **Tablet:** Pop-up obavijest pri pokretanju

---

## 📋 Audit Logovi

### Što se Logira?

Svaka administrativna akcija se automatski bilježi:

| Akcija | Opis |
|--------|------|
| `CREATE_OWNER` | Kreiranje novog vlasnika |
| `DELETE_OWNER` | Brisanje vlasnika |
| `TOGGLE_STATUS` | Aktivacija/deaktivacija vlasnika |
| `RESET_PASSWORD` | Resetiranje lozinke |
| `ADD_ADMIN` | Dodavanje super admina |
| `REMOVE_ADMIN` | Uklanjanje super admina |
| `UPLOAD_APK` | Upload nove verzije APK-a |
| `CREATE_NOTIFICATION` | Kreiranje sistemske obavijesti |
| `MANUAL_BACKUP` | Pokretanje ručnog backupa |

### Pregled Logova

```
┌─────────────────────────────────────────────────────────────────────────┐
│  AUDIT LOGOVI                                         [Export] [Filter] │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  10.01.2026. 14:32:15                                                   │
│  Akcija: CREATE_OWNER                                                   │
│  Admin: vestaluminasystem@gmail.com                                     │
│  Detalji: Kreiran vlasnik ivan@example.com (TENANT003)                 │
│  ───────────────────────────────────────────────────────────────────── │
│  10.01.2026. 12:15:43                                                   │
│  Akcija: UPLOAD_APK                                                     │
│  Admin: admin2@example.com                                              │
│  Detalji: Uploadana verzija 0.0.6 (mandatory: false)                   │
│  ───────────────────────────────────────────────────────────────────── │
│  09.01.2026. 18:22:01                                                   │
│  Akcija: TOGGLE_STATUS                                                  │
│  Admin: vestaluminasystem@gmail.com                                     │
│  Detalji: Deaktiviran vlasnik stari@example.com                        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Filtriranje Logova

Možete filtrirati po:
- **Vremenskom periodu** (danas, tjedan, mjesec, prilagođeno)
- **Tipu akcije** (CREATE_OWNER, DELETE_OWNER, itd.)
- **Administratoru** (koji admin je napravio akciju)

### Export Logova

1. Kliknite **"Export"**
2. Odaberite format (CSV ili PDF)
3. Odaberite period
4. Preuzmite datoteku

---

## 💾 Backup i Oporavak

### Automatski Backup

Sustav automatski kreira backup svaki dan u **03:00 UTC**:
- Sve Firestore kolekcije
- Metadata (bez slika zbog veličine)

### Ručni Backup

Za trenutni backup:

1. Otvorite admin panel
2. Kliknite **"Backup"** u gornjem desnom kutu
3. Odaberite opcije:
   - ☑️ Uključi slike (povećava vrijeme i veličinu)
4. Kliknite **"Pokreni Backup"**
5. Pričekajte završetak (može trajati nekoliko minuta)

### Lokacija Backupa

Backupi se spremaju u Firebase Storage:
```
storage/
└── backups/
    ├── 2026-01-09/
    │   └── backup_2026-01-09_03-00.json
    ├── 2026-01-10/
    │   └── backup_2026-01-10_03-00.json
    └── manual/
        └── backup_2026-01-10_14-32.json
```

### Oporavak iz Backupa

⚠️ **Oporavak zahtijeva tehničko znanje i pristup Firebase konzoli.**

Za oporavak kontaktirajte tehničku podršku ili slijedite internu dokumentaciju.

---

## 🔒 Sigurnosne Smjernice

### Najbolje Prakse za Super Admine

1. **Koristite jaku lozinku**
   - Minimalno 12 znakova
   - Kombinacija slova, brojeva i simbola
   - Ne koristite istu lozinku za druge servise

2. **Omogućite dvofaktorsku autentifikaciju (2FA)**
   - Koristite authenticator app (Google Authenticator, Authy)

3. **Ne dijelite pristupne podatke**
   - Svaki admin treba vlastiti račun
   - Nikad ne šaljite lozinke emailom

4. **Redovito pregledavajte audit logove**
   - Tražite sumnjive aktivnosti
   - Provjerite nepoznate IP adrese

5. **Ograničite broj super admina**
   - Samo osobe koje trebaju puni pristup
   - Uklonite admine koji više ne rade na projektu

### Postupak u Slučaju Sigurnosnog Incidenta

1. **Identificirajte** - Što se dogodilo? Tko je pogođen?
2. **Izolirajte** - Deaktivirajte kompromitirane račune
3. **Obavijestite** - Informirajte pogođene vlasnike
4. **Ispravite** - Resetirajte lozinke, zakrpajte ranjivosti
5. **Dokumentirajte** - Zabilježite incident za buduću referencu

---

## 📞 Kontakt za Tehničku Podršku

Za probleme koji zahtijevaju tehničku intervenciju:

- **Email:** nevenroksa@gmail.com
- **GitHub:** @nroxa92

---

## 📜 Napomena

```
Ovaj priručnik namijenjen je isključivo ovlaštenim super administratorima.
Neovlašteno dijeljenje ili korištenje ovih informacija je zabranjeno.

© 2025-2026 Sva prava pridržana.
Vesta Lumina System - verzija 0.0.9 Beta
```
