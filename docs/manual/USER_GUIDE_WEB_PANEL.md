# Vesta Lumina Web Panel - User Guide

> **For Property Owners & Managers**  
> **Version:** 2.1.0  
> **Last Updated:** January 2026  
> **© 2026 Vesta Lumina. All Rights Reserved.**

---

## Dobrodošli! / Welcome!

Ovaj vodič će vam pomoći da maksimalno iskoristite Vesta Lumina sustav za upravljanje vašim smještajnim jedinicama.

This guide will help you get the most out of the Vesta Lumina system for managing your rental properties.

---

## Table of Contents

1. [Getting Started](#1-getting-started)
2. [Dashboard Overview](#2-dashboard-overview)
3. [Managing Units](#3-managing-units)
4. [Booking Calendar](#4-booking-calendar)
5. [Guest Management](#5-guest-management)
6. [Cleaning Module](#6-cleaning-module)
7. [AI Assistant Setup](#7-ai-assistant-setup)
8. [Reports & PDFs](#8-reports--pdfs)
9. [Tablet Management](#9-tablet-management)
10. [Settings & Profile](#10-settings--profile)
11. [Tips & Best Practices](#11-tips--best-practices)
12. [Troubleshooting](#12-troubleshooting)

---

## 1. Getting Started

### 1.1 Accessing the Panel

Open your web browser and go to:

```
https://admin.vestalumina.com
```

**Supported Browsers:**
- ✅ Google Chrome (recommended)
- ✅ Mozilla Firefox
- ✅ Microsoft Edge
- ✅ Safari
- ⚠️ Internet Explorer (not supported)

### 1.2 Logging In

1. Enter your email address
2. Enter your password
3. Click **"Sign In"**

```
┌─────────────────────────────────────┐
│         VESTA LUMINA                │
│                                     │
│  Email: ________________________    │
│                                     │
│  Password: ____________________     │
│                                     │
│  [Forgot Password?]                 │
│                                     │
│       [ Sign In ]                   │
│                                     │
└─────────────────────────────────────┘
```

**First Time Login?**
- Check your email for the invitation link
- Create your password (min. 8 characters)
- Complete your profile setup

### 1.3 Language Selection

Click the language icon in the top-right corner to select your preferred language:

🇭🇷 Hrvatski | 🇬🇧 English | 🇩🇪 Deutsch | 🇮🇹 Italiano | 🇸🇮 Slovenščina | 🇫🇷 Français | 🇪🇸 Español | 🇵🇹 Português | 🇵🇱 Polski | 🇨🇿 Čeština | 🇳🇱 Nederlands

---

## 2. Dashboard Overview

After logging in, you'll see your main dashboard:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🏠 VESTA LUMINA                              [🔔] [👤] [🌐 HR]    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌───────────┐ │
│  │  TODAY'S    │  │   ACTIVE    │  │   THIS      │  │  CLEANING │ │
│  │  CHECK-INS  │  │   GUESTS    │  │   MONTH     │  │   TASKS   │ │
│  │      3      │  │      8      │  │  €4,250     │  │     2     │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └───────────┘ │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    UPCOMING BOOKINGS                         │   │
│  │                                                              │   │
│  │  Today    │ Apartment Sea View  │ Check-in  │ Müller Family │   │
│  │  Today    │ Studio Downtown     │ Check-in  │ John Smith    │   │
│  │  Tomorrow │ Apartment Sea View  │ Check-out │ Garcia Family │   │
│  │  Tomorrow │ Villa Sunset        │ Check-in  │ Novak         │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    QUICK ACTIONS                             │   │
│  │                                                              │   │
│  │  [+ New Booking]  [📋 View Calendar]  [📊 Reports]          │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Dashboard Widgets

| Widget | Description |
|--------|-------------|
| **Today's Check-ins** | Number of guests arriving today |
| **Active Guests** | Current guests across all units |
| **This Month** | Revenue for current month |
| **Cleaning Tasks** | Pending cleaning tasks |
| **Upcoming Bookings** | Next 7 days of arrivals/departures |

---

## 3. Managing Units

### 3.1 View Your Units

Navigate to **Units** in the sidebar menu.

```
┌─────────────────────────────────────────────────────────────────────┐
│  UNITS                                            [+ Add New Unit]  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ [🖼️]  Apartment Sea View                                     │  │
│  │       Split, Croatia                                          │  │
│  │       Sleeps: 4  │  Bedrooms: 2  │  Status: 🟢 Active        │  │
│  │       Current: Garcia Family (until tomorrow)                 │  │
│  │                                         [Edit] [View Tablet]  │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ [🖼️]  Studio Downtown                                        │  │
│  │       Split, Croatia                                          │  │
│  │       Sleeps: 2  │  Bedrooms: 1  │  Status: 🟢 Active        │  │
│  │       Current: Available                                      │  │
│  │                                         [Edit] [View Tablet]  │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.2 Adding a New Unit

1. Click **"+ Add New Unit"**
2. Fill in the basic information:

| Field | Description | Required |
|-------|-------------|----------|
| Unit Name | Display name (e.g., "Apartment Sea View") | ✅ |
| Address | Full address | ✅ |
| City | City/Town | ✅ |
| Country | Select from dropdown | ✅ |
| Description | Detailed description | ❌ |
| Sleeps | Maximum guests | ✅ |
| Bedrooms | Number of bedrooms | ✅ |
| Bathrooms | Number of bathrooms | ✅ |

3. Upload photos (recommended: at least 5 high-quality photos)
4. Click **"Save Unit"**

### 3.3 Editing Unit Details

Click **"Edit"** on any unit to modify:

- **Basic Info** - Name, address, capacity
- **Photos** - Add, remove, reorder images
- **Amenities** - WiFi, parking, AC, etc.
- **House Rules** - Kućni red / House rules
- **Check-in/out Times** - Default times
- **Pricing** - Base price, cleaning fee

### 3.4 House Rules (Kućni Red)

This is what guests see on their tablet. Make it clear and helpful:

**Example House Rules:**
```
1. CHECK-IN: 15:00 - 20:00
2. CHECK-OUT: by 10:00
3. NO SMOKING inside the apartment
4. NO PARTIES or events
5. QUIET HOURS: 22:00 - 08:00
6. PETS: Not allowed
7. WIFI Password: Welcome2024
8. EMERGENCY: Call +385 91 123 4567
```

---

## 4. Booking Calendar

### 4.1 Calendar View

Navigate to **Calendar** in the sidebar.

```
┌─────────────────────────────────────────────────────────────────────┐
│  CALENDAR                    [◄ Jan 2026 ►]    [Month] [Week] [Day]│
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│          Mon    Tue    Wed    Thu    Fri    Sat    Sun             │
│  Week 1   1      2      3      4      5      6      7              │
│          ░░░░░░░░░░░░░░░░░░░  ████████████████████████             │
│  Sea     Garcia Family        John Smith ──────────────            │
│  View                                                               │
│          ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░                         │
│  Studio  Available                                                  │
│                                                                     │
│          ████████████████████████████████████████████              │
│  Villa   Novak Family ─────────────────────────────────            │
│                                                                     │
│  Legend: ████ Confirmed  ░░░░ Pending  ──── Cleaning               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 4.2 Creating a New Booking

**Method 1: Click on Calendar**
1. Click on the start date
2. Drag to the end date
3. Fill in guest details

**Method 2: Use "New Booking" Button**
1. Click **"+ New Booking"**
2. Select unit
3. Choose dates
4. Enter guest information

### 4.3 Booking Details Form

| Field | Description |
|-------|-------------|
| Guest Name | Full name of primary guest |
| Email | Guest email for notifications |
| Phone | Contact number |
| Check-in Date | Arrival date |
| Check-out Date | Departure date |
| Number of Guests | Adults + children |
| Source | Airbnb, Booking.com, Direct, etc. |
| Total Price | Booking total |
| Notes | Internal notes |

### 4.4 iCal Synchronization

Sync bookings from Airbnb and Booking.com automatically!

**Setup Steps:**

1. Go to **Settings → Integrations**
2. Click **"Add iCal Feed"**
3. Paste the iCal URL from Airbnb/Booking.com
4. Select the unit to sync
5. Click **"Save"**

**Finding your iCal URL:**

**Airbnb:**
1. Go to your listing
2. Click "Pricing and availability"
3. Scroll to "Connect calendars"
4. Copy the "Export calendar" link

**Booking.com:**
1. Go to "Property" tab
2. Click "Sync calendars"
3. Copy the iCal link

**Sync Settings:**
- Automatic sync every 15 minutes
- Manual sync available with refresh button
- Conflict detection and alerts

### 4.5 Drag-and-Drop Features

| Action | How To |
|--------|--------|
| Move booking | Drag the booking to new dates |
| Extend booking | Drag the edge of the booking |
| Copy booking | Hold Ctrl + drag |
| Quick view | Hover over booking |

---

## 5. Guest Management

### 5.1 Guest List

View all guests from **Guests** menu:

```
┌─────────────────────────────────────────────────────────────────────┐
│  GUESTS                               [🔍 Search]  [📥 Export CSV] │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Name           │ Unit          │ Check-in   │ Status    │ Actions │
│  ───────────────┼───────────────┼────────────┼───────────┼─────────│
│  Garcia Family  │ Sea View      │ 05.01.2026 │ 🟢 Active │ [View]  │
│  John Smith     │ Studio        │ 06.01.2026 │ 🟡 Today  │ [View]  │
│  Müller Family  │ Villa Sunset  │ 07.01.2026 │ ⏳ Coming │ [View]  │
│  Novak Family   │ Villa Sunset  │ 15.01.2026 │ ⏳ Coming │ [View]  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 5.2 Guest Profile

Click on any guest to see:

- **Contact Information** - Name, email, phone
- **Booking Details** - Dates, unit, price
- **Documents** - Scanned passport/ID (if using tablet)
- **Communication** - Message history
- **History** - Previous stays

### 5.3 Guest Check-in via Tablet

When guests check in on the tablet:

1. You receive a notification
2. Guest data is automatically captured
3. Documents are scanned and stored
4. eVisitor data is prepared (Croatia)

### 5.4 Manual Guest Registration

If tablet check-in isn't used:

1. Open the booking
2. Click **"Register Guest"**
3. Enter guest details manually
4. Upload document photo if available
5. Save

---

## 6. Cleaning Module

### 6.1 Overview

The cleaning module helps you manage cleaning tasks efficiently:

```
┌─────────────────────────────────────────────────────────────────────┐
│  CLEANING                                     [+ Assign Task]      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  📋 TODAY'S TASKS                                            │   │
│  │                                                              │   │
│  │  🟡 Apartment Sea View                                       │   │
│  │     Check-out: Garcia Family (10:00)                        │   │
│  │     Assigned: Maria K.  │  Status: In Progress              │   │
│  │     [View Details]                                           │   │
│  │                                                              │   │
│  │  🔴 Studio Downtown                                          │   │
│  │     Check-out: Available                                     │   │
│  │     Assigned: Not assigned  │  Status: Pending              │   │
│  │     [Assign Cleaner]                                         │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 6.2 Adding Cleaners

1. Go to **Cleaning → Team**
2. Click **"+ Add Cleaner"**
3. Enter cleaner information:

| Field | Description |
|-------|-------------|
| Name | Full name |
| Phone | Contact number |
| Email | Email address (optional) |
| PIN | 4-digit login code |
| Units | Which units they can clean |

### 6.3 Cleaning Checklists

Create custom checklists for each unit:

**Example Checklist:**
```
☐ Living Area
  ☐ Vacuum floors
  ☐ Dust surfaces
  ☐ Clean windows
  ☐ Check TV remote batteries

☐ Kitchen
  ☐ Clean counters
  ☐ Wash dishes / run dishwasher
  ☐ Clean refrigerator
  ☐ Restock coffee/tea

☐ Bathroom
  ☐ Scrub toilet
  ☐ Clean shower/tub
  ☐ Replace towels
  ☐ Restock toiletries

☐ Bedroom
  ☐ Change bed linens
  ☐ Make bed
  ☐ Vacuum floor
  ☐ Check closet

☐ Final Check
  ☐ Set AC to 24°C
  ☐ Close all windows
  ☐ Lock doors
  ☐ Take photos
```

### 6.4 Task Assignment

**Automatic Assignment:**
- Tasks created automatically on check-out day
- Assign default cleaner per unit

**Manual Assignment:**
1. Open the task
2. Select cleaner from dropdown
3. Set priority if needed
4. Add special instructions

### 6.5 Photo Documentation

Cleaners can upload photos as proof of work:
- Before photos (optional)
- After photos (required)
- Problem photos (if issues found)

You can view all photos in the task details.

---

## 7. AI Assistant Setup

### 7.1 Knowledge Base

The AI Assistant uses your knowledge base to answer guest questions.

Navigate to **AI Setup → Knowledge Base**

```
┌─────────────────────────────────────────────────────────────────────┐
│  AI KNOWLEDGE BASE                              [+ Add Category]   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  📍 Local Recommendations                    [Edit] [Delete] │   │
│  │     15 entries                                               │   │
│  │     Restaurants, beaches, attractions                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  🏠 Property Information                     [Edit] [Delete] │   │
│  │     8 entries                                                │   │
│  │     WiFi, parking, appliances                                │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  🚗 Transportation                           [Edit] [Delete] │   │
│  │     5 entries                                                │   │
│  │     Bus, taxi, car rental                                    │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 7.2 Adding Knowledge Entries

1. Click on a category
2. Click **"+ Add Entry"**
3. Fill in the form:

| Field | Example |
|-------|---------|
| Question | "Where is the nearest beach?" |
| Answer | "Bačvice beach is 500m away. Walk down the main street, turn left at the pharmacy. Open 24/7, free entry." |
| Tags | beach, swimming, nearby |

### 7.3 Recommended Topics

Add information about:

| Category | Topics |
|----------|--------|
| **Property** | WiFi password, AC instructions, TV channels, appliances |
| **Local** | Restaurants, beaches, attractions, shopping |
| **Transport** | Bus routes, taxi numbers, parking, airport shuttle |
| **Emergency** | Hospital, pharmacy, police, your contact |
| **Practical** | Garbage days, recycling, noise rules |

### 7.4 Testing the AI

Click **"Test AI"** to chat with your assistant and verify answers.

---

## 8. Reports & PDFs

### 8.1 Available Reports

Navigate to **Reports** menu:

| Report | Description |
|--------|-------------|
| **Monthly Overview** | Bookings, revenue, occupancy |
| **Occupancy Report** | % of days booked per unit |
| **Revenue Report** | Income by unit, source, period |
| **Guest Statistics** | Countries, repeat guests |
| **Cleaning Report** | Tasks completed, time spent |

### 8.2 Generating PDFs

1. Select report type
2. Choose date range
3. Select units (or all)
4. Click **"Generate PDF"**

### 8.3 Available PDF Documents

| Document | Description |
|----------|-------------|
| Guest Card | Welcome card for guest |
| House Rules | Formatted house rules |
| Invoice | Booking invoice |
| Cleaning Checklist | Printable checklist |
| Monthly Report | Full monthly summary |
| Registration Form | Guest registration form |
| Key Handover | Key handover document |
| Damage Report | Property damage report |
| Check-in Instructions | Pre-arrival email content |
| Tax Report | Tax summary for accountant |

### 8.4 Automatic Reports

Set up automatic email reports:

1. Go to **Settings → Reports**
2. Enable **"Weekly Summary Email"**
3. Choose day of week
4. Select report type

---

## 9. Tablet Management

### 9.1 Tablet Overview

View and manage your tablets:

```
┌─────────────────────────────────────────────────────────────────────┐
│  TABLETS                                        [+ Pair New Tablet]│
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  📱 Tablet-001                                              │   │
│  │     Unit: Apartment Sea View                                 │   │
│  │     Status: 🟢 Online  │  Last seen: 2 min ago              │   │
│  │     Battery: 85%  │  WiFi: Strong                           │   │
│  │                              [Settings] [Restart] [Unpair]   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  📱 Tablet-002                                              │   │
│  │     Unit: Studio Downtown                                    │   │
│  │     Status: 🔴 Offline  │  Last seen: 3 hours ago           │   │
│  │     Battery: --  │  WiFi: --                                │   │
│  │                              [Settings] [Troubleshoot]       │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 9.2 Pairing a New Tablet

1. Install Vesta Lumina app on tablet
2. Open app and select **"Pair with Owner"**
3. In web panel, click **"+ Pair New Tablet"**
4. Enter the 6-digit code shown on tablet
5. Assign to a unit
6. Tablet is now paired!

### 9.3 Tablet Settings

Configure each tablet:

| Setting | Description |
|---------|-------------|
| **Unit Assignment** | Which unit this tablet is for |
| **Screensaver** | Delay before screensaver starts |
| **Auto-brightness** | Adjust to lighting |
| **Kiosk Mode** | Lock to Vesta Lumina app |
| **Language** | Default language |
| **Welcome Message** | Custom greeting |

### 9.4 Screensaver Customization

1. Click **"Screensaver Settings"**
2. Upload your images (1920x1080 recommended)
3. Add custom text overlay
4. Set rotation interval
5. Save changes

---

## 10. Settings & Profile

### 10.1 Profile Settings

Click your name in the top-right corner:

| Setting | Description |
|---------|-------------|
| **Name** | Your display name |
| **Email** | Login email (cannot change) |
| **Phone** | Contact number |
| **Password** | Change password |
| **Language** | Interface language |
| **Notifications** | Email preferences |

### 10.2 Organization Settings

For account administrators:

| Setting | Description |
|---------|-------------|
| **Company Name** | Your business name |
| **Address** | Business address |
| **Logo** | Upload your logo |
| **Default Currency** | EUR, USD, etc. |
| **Time Zone** | Your time zone |
| **Tax Settings** | VAT/tax configuration |

### 10.3 Notification Settings

Configure when you receive alerts:

| Notification | Email | Push |
|--------------|:-----:|:----:|
| New booking | ✅ | ✅ |
| Guest check-in | ❌ | ✅ |
| Cleaning completed | ❌ | ✅ |
| Tablet offline | ✅ | ✅ |
| Weekly summary | ✅ | ❌ |

---

## 11. Tips & Best Practices

### 11.1 Time-Saving Tips

| Tip | Benefit |
|-----|---------|
| Set up iCal sync first | Automatic booking import |
| Create checklist templates | Faster task creation |
| Use default cleaners | Auto-assignment |
| Build AI knowledge base | Fewer guest questions |
| Enable auto-reports | Weekly insights |

### 11.2 Best Practices

**For Better Guest Experience:**
- ✅ Keep house rules clear and concise
- ✅ Add local recommendations to AI
- ✅ Upload high-quality screensaver images
- ✅ Set custom welcome messages

**For Efficient Management:**
- ✅ Check dashboard daily
- ✅ Review cleaning photos
- ✅ Keep contact info updated
- ✅ Export reports monthly for accounting

**For Security:**
- ✅ Use strong passwords
- ✅ Review tablet access regularly
- ✅ Log out of shared computers
- ✅ Keep cleaner PINs confidential

### 11.3 Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl + N` | New booking |
| `Ctrl + S` | Save |
| `Ctrl + F` | Search |
| `Esc` | Close modal |
| `←` `→` | Navigate calendar |

---

## 12. Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| Can't log in | Check email/password, try "Forgot Password" |
| Calendar not syncing | Verify iCal URL, check last sync time |
| Tablet showing offline | Check WiFi, restart tablet |
| PDF not generating | Try different browser, clear cache |
| Booking conflict | Check calendar for overlapping dates |

### Getting Help

**Self-Service:**
- 📖 Help Center: help.vestalumina.com
- 💬 In-app chat: Click "?" icon

**Contact Support:**
- 📧 Email: support@vestalumina.com
- 📞 Phone: +385 1 234 5678
- ⏰ Hours: Mon-Fri 9:00-18:00 CET

**Emergency (24/7):**
- 📞 +385 91 VESTA-00

---

## Quick Reference Card

### Daily Tasks
- [ ] Check dashboard for today's arrivals
- [ ] Verify cleaning tasks assigned
- [ ] Review any guest messages

### Weekly Tasks
- [ ] Review occupancy for next 2 weeks
- [ ] Check tablet battery levels
- [ ] Update AI knowledge if needed

### Monthly Tasks
- [ ] Generate monthly report
- [ ] Review cleaner performance
- [ ] Update seasonal pricing
- [ ] Export data for accounting

---

**© 2026 Vesta Lumina. All Rights Reserved.**

*Need help? Contact support@vestalumina.com*
