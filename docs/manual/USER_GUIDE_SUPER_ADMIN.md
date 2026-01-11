# Vesta Lumina Super Admin Guide

> **For Agency Managers & Multi-Property Administrators**  
> **Version:** 2.1.0  
> **Last Updated:** January 2026  
> **Classification:** Confidential  
> **© 2026 Vesta Lumina. All Rights Reserved.**

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Super Admin Dashboard](#2-super-admin-dashboard)
3. [Organization Management](#3-organization-management)
4. [User Management](#4-user-management)
5. [Property Groups](#5-property-groups)
6. [Multi-Property Calendar](#6-multi-property-calendar)
7. [Team & Permissions](#7-team--permissions)
8. [Analytics & Reporting](#8-analytics--reporting)
9. [White-Label Configuration](#9-white-label-configuration)
10. [Billing & Invoicing](#10-billing--invoicing)
11. [System Settings](#11-system-settings)
12. [Best Practices](#12-best-practices)

---

## 1. Introduction

### What is Super Admin?

As a **Super Admin**, you have elevated privileges to manage multiple properties, users, and organizations within the Vesta Lumina ecosystem. This role is designed for:

- Property management agencies
- Hotel chains
- White-label partners
- Multi-property owners

### Super Admin Capabilities

| Capability | Description |
|------------|-------------|
| **Multi-property view** | See all properties in one dashboard |
| **User management** | Create and manage owner accounts |
| **Team coordination** | Manage cleaning teams across properties |
| **Cross-property analytics** | Aggregate reporting and insights |
| **White-label** | Custom branding for your organization |
| **Billing oversight** | View and manage subscription billing |

### Accessing Super Admin Panel

```
https://admin.vestalumina.com/super
```

Your account must be granted Super Admin privileges by Vesta Lumina or your Master Admin.

---

## 2. Super Admin Dashboard

### Overview Screen

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  🏢 SUPER ADMIN DASHBOARD                    [🔔 12] [👤 Admin] [🌐]       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐│
│  │ PROPERTIES │ │   USERS    │ │  BOOKINGS  │ │  REVENUE   │ │ OCCUPANCY  ││
│  │     47     │ │     23     │ │    312     │ │  €48,250   │ │    78%     ││
│  │  Active    │ │  Active    │ │ This Month │ │ This Month │ │ This Month ││
│  └────────────┘ └────────────┘ └────────────┘ └────────────┘ └────────────┘│
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     ORGANIZATION OVERVIEW                            │   │
│  │                                                                      │   │
│  │  Property Groups    Active Users    Today's Arrivals    Cleaning    │   │
│  │  ═══════════════   ════════════    ════════════════    ═════════   │   │
│  │  Split Coastal (12)   8 owners      15 check-ins       6 tasks     │   │
│  │  Zagreb Urban (8)     5 owners       8 check-ins       4 tasks     │   │
│  │  Istria Resort (15)   6 owners      12 check-ins       8 tasks     │   │
│  │  Dalmatia Villas (12) 4 owners       9 check-ins       5 tasks     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  ALERTS & NOTIFICATIONS                                              │   │
│  │  ⚠️  3 tablets offline (Split Coastal)                              │   │
│  │  📊  Weekly report ready for download                                │   │
│  │  👤  New user registration pending approval                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Dashboard Widgets

| Widget | Description | Drill-down |
|--------|-------------|------------|
| **Properties** | Total active properties | View property list |
| **Users** | Active user accounts | View user list |
| **Bookings** | Bookings this month | View booking calendar |
| **Revenue** | Total revenue this month | View revenue report |
| **Occupancy** | Average occupancy rate | View occupancy report |

### Quick Actions

| Action | Shortcut |
|--------|----------|
| Add new property owner | `Ctrl + Shift + N` |
| View all properties | `Ctrl + P` |
| Generate report | `Ctrl + R` |
| Search | `Ctrl + F` |

---

## 3. Organization Management

### 3.1 Organization Profile

Navigate to **Organization → Profile**

| Setting | Description |
|---------|-------------|
| **Organization Name** | Your company/agency name |
| **Legal Entity** | Registered business name |
| **Tax ID** | VAT/OIB number |
| **Address** | Registered business address |
| **Contact Email** | Primary contact email |
| **Contact Phone** | Primary contact number |
| **Website** | Company website |
| **Logo** | Organization logo (for white-label) |

### 3.2 Organization Structure

```
                    ┌─────────────────────┐
                    │   YOUR AGENCY       │
                    │   (Super Admin)     │
                    └──────────┬──────────┘
                               │
        ┌──────────────────────┼──────────────────────┐
        │                      │                      │
        ▼                      ▼                      ▼
┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│ Property      │     │ Property      │     │ Property      │
│ Group A       │     │ Group B       │     │ Group C       │
│ (12 units)    │     │ (8 units)     │     │ (15 units)    │
└───────┬───────┘     └───────┬───────┘     └───────┬───────┘
        │                     │                     │
   ┌────┴────┐           ┌────┴────┐           ┌────┴────┐
   │         │           │         │           │         │
Owner 1   Owner 2     Owner 3   Owner 4     Owner 5   Owner 6
(3 units) (4 units)   (5 units) (3 units)   (8 units) (7 units)
```

### 3.3 Subscription & Limits

View your subscription details:

| Plan Feature | Your Limit | Current Usage |
|--------------|------------|---------------|
| Properties | 100 | 47 |
| Users | 50 | 23 |
| Tablets | 100 | 42 |
| API Calls | 100,000/mo | 45,000 |
| Storage | 50 GB | 12 GB |

---

## 4. User Management

### 4.1 User List

Navigate to **Users → All Users**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  USERS                                [+ Add User]  [📥 Export]  [🔍]      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Name            │ Email                │ Role    │ Properties │ Status    │
│  ════════════════│══════════════════════│═════════│════════════│══════════ │
│  Marko Horvat    │ marko@agency.hr      │ Owner   │ 4          │ 🟢 Active │
│  Ana Kovač       │ ana@agency.hr        │ Owner   │ 3          │ 🟢 Active │
│  Petra Babić     │ petra@example.com    │ Owner   │ 2          │ 🟡 Pending│
│  Ivan Novak      │ ivan@agency.hr       │ Manager │ 8          │ 🟢 Active │
│  Maria K.        │ maria.clean@mail.com │ Cleaner │ 12         │ 🟢 Active │
│                                                                              │
│  Showing 1-5 of 23 users                              [◄] [1] [2] [3] [►]   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Adding New Users

1. Click **"+ Add User"**
2. Select user role:

| Role | Permissions |
|------|-------------|
| **Owner** | Full access to assigned properties |
| **Manager** | View + edit for assigned properties |
| **Viewer** | Read-only access |
| **Cleaner** | Cleaning tasks only |

3. Fill in user details:

| Field | Required | Notes |
|-------|----------|-------|
| Name | ✅ | Full name |
| Email | ✅ | Login email |
| Phone | ❌ | Contact number |
| Role | ✅ | Select from dropdown |
| Properties | ✅ | Assign properties |
| Send Invite | ✅ | Email invitation |

4. Click **"Create User"**

### 4.3 User Permissions Matrix

| Permission | Owner | Manager | Viewer | Cleaner |
|------------|:-----:|:-------:|:------:|:-------:|
| View dashboard | ✅ | ✅ | ✅ | ❌ |
| Manage units | ✅ | ✅ | ❌ | ❌ |
| Create bookings | ✅ | ✅ | ❌ | ❌ |
| Edit bookings | ✅ | ✅ | ❌ | ❌ |
| View guests | ✅ | ✅ | ✅ | ❌ |
| Manage cleaning | ✅ | ✅ | ❌ | ✅ |
| Generate reports | ✅ | ✅ | ✅ | ❌ |
| Manage tablets | ✅ | ✅ | ❌ | ❌ |
| View financials | ✅ | ❌ | ❌ | ❌ |
| Edit AI knowledge | ✅ | ✅ | ❌ | ❌ |

### 4.4 Bulk User Operations

Select multiple users for bulk actions:
- ☐ Activate/Deactivate
- ☐ Change role
- ☐ Assign to property group
- ☐ Send notification
- ☐ Export to CSV

---

## 5. Property Groups

### 5.1 Creating Property Groups

Organize properties logically:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PROPERTY GROUPS                                         [+ New Group]     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  📍 SPLIT COASTAL                                      [⚙️] [📊]    │   │
│  │     12 properties  │  8 owners  │  78% occupancy  │  €12,400/mo    │   │
│  │                                                                      │   │
│  │     Properties: Apartment Sea View, Studio Downtown, Villa Sunset...│   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  📍 ZAGREB URBAN                                       [⚙️] [📊]    │   │
│  │     8 properties   │  5 owners  │  65% occupancy  │  €8,200/mo     │   │
│  │                                                                      │   │
│  │     Properties: City Center Loft, Business Suite, Old Town Apt...   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.2 Group Settings

| Setting | Description |
|---------|-------------|
| **Group Name** | Display name |
| **Region** | Geographic region |
| **Default Settings** | Apply to all properties in group |
| **Assigned Managers** | Who can manage this group |
| **Cleaning Team** | Default cleaners for group |
| **Analytics** | Group-level reporting |

### 5.3 Moving Properties Between Groups

1. Select property
2. Click **"Move to Group"**
3. Select target group
4. Confirm move

---

## 6. Multi-Property Calendar

### 6.1 Cross-Property View

See all properties in one calendar:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  MULTI-PROPERTY CALENDAR               [◄ January 2026 ►]   [Filter ▼]    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Property          │ Mon 5 │ Tue 6 │ Wed 7 │ Thu 8 │ Fri 9 │ Sat 10│ Sun 11│
│  ══════════════════│═══════│═══════│═══════│═══════│═══════│═══════│═══════│
│                    │       │       │       │       │       │       │       │
│  Sea View          │▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│       │
│  (Split)           │ Garcia────────│ Smith─────────────────────────        │
│                    │       │       │       │       │       │       │       │
│  Studio Downtown   │       │░░░░░░░░░░░░░░░░░░░░░░░│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│       │
│  (Split)           │       │ Available             │ Müller────────        │
│                    │       │       │       │       │       │       │       │
│  City Loft         │▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│       │
│  (Zagreb)          │ Novak─────────────────────────────────────────        │
│                    │       │       │       │       │       │       │       │
│  Villa Sunset      │───────│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│       │
│  (Istria)          │Cleanup│ Wagner────────────────────────────────        │
│                                                                              │
│  Legend: ▓▓▓ Occupied  ░░░ Pending  ─── Cleaning/Blocked                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.2 Calendar Filters

| Filter | Options |
|--------|---------|
| **Property Group** | All, Split Coastal, Zagreb Urban, etc. |
| **Owner** | Filter by property owner |
| **Status** | Confirmed, Pending, Blocked |
| **Date Range** | Week, Month, Quarter |

### 6.3 Bulk Operations

Select date range across properties for:
- Block dates (maintenance)
- Apply pricing rules
- Assign cleaning tasks
- Generate reports

---

## 7. Team & Permissions

### 7.1 Team Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  TEAM MANAGEMENT                                          [+ Add Member]   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  👤 SUPER ADMINS (2)                                                 │   │
│  │     Your Name (you)  │  Co-Admin Name                               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  👥 PROPERTY OWNERS (15)                                             │   │
│  │     Marko H.  │  Ana K.  │  Ivan N.  │  ... [View All]              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  🧹 CLEANING TEAM (8)                                                │   │
│  │     Maria K.  │  Petra B.  │  Josip M.  │  ... [View All]           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.2 Custom Permission Sets

Create custom permission sets for your team:

1. Navigate to **Team → Permission Sets**
2. Click **"+ New Permission Set"**
3. Define permissions:

```
Permission Set: "Property Manager - Limited"

✅ View all properties in group
✅ Edit booking details
✅ Assign cleaning tasks
❌ Delete bookings
❌ View financial reports
❌ Manage users
❌ Edit organization settings
```

### 7.3 Audit Log

Track team activities:

| Timestamp | User | Action | Details |
|-----------|------|--------|---------|
| 10:45 | Marko H. | Created booking | Unit: Sea View, Guest: Smith |
| 10:32 | Maria K. | Completed task | Unit: Studio, Task: Cleaning |
| 09:15 | Ana K. | Updated unit | Unit: Villa Sunset, Field: Price |

---

## 8. Analytics & Reporting

### 8.1 Analytics Dashboard

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ANALYTICS                              [Date Range: Jan 2026 ▼] [Export]  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        REVENUE BY GROUP                              │   │
│  │                                                                      │   │
│  │  €15K ┤                                    ████                     │   │
│  │       │                          ████      ████                     │   │
│  │  €10K ┤            ████          ████      ████      ████          │   │
│  │       │   ████     ████   ████   ████      ████      ████          │   │
│  │   €5K ┤   ████     ████   ████   ████      ████      ████          │   │
│  │       │   ████     ████   ████   ████      ████      ████          │   │
│  │    €0 ┼───────────────────────────────────────────────────          │   │
│  │         Split    Zagreb   Istria  Dalmatia  Other    Total          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  KEY METRICS                                                         │   │
│  │                                                                      │   │
│  │  Avg. Daily Rate    Occupancy Rate    RevPAR        Avg. Stay      │   │
│  │      €125              78%             €97.50        4.2 nights    │   │
│  │    (+8% MoM)        (+5% MoM)        (+12% MoM)    (-0.3 nights)   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8.2 Available Reports

| Report | Description | Frequency |
|--------|-------------|-----------|
| **Executive Summary** | High-level KPIs | Weekly/Monthly |
| **Revenue Report** | Detailed revenue breakdown | Monthly |
| **Occupancy Report** | Occupancy by property/group | Weekly |
| **Booking Source** | Airbnb vs Booking vs Direct | Monthly |
| **Guest Demographics** | Countries, repeat guests | Monthly |
| **Cleaning Performance** | Task completion, time | Weekly |
| **Tablet Status** | Online/offline, battery | Daily |

### 8.3 Scheduled Reports

Configure automatic report delivery:

1. Go to **Analytics → Scheduled Reports**
2. Click **"+ New Schedule"**
3. Configure:

| Setting | Options |
|---------|---------|
| Report Type | Select from dropdown |
| Frequency | Daily, Weekly, Monthly |
| Day/Time | When to generate |
| Recipients | Email addresses |
| Format | PDF, Excel, CSV |

---

## 9. White-Label Configuration

### 9.1 Branding Settings

Customize the appearance for your organization:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  WHITE-LABEL SETTINGS                                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  BRANDING                                                                   │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                                                              │
│  Logo:           [Upload Logo]    Current: agency_logo.png                  │
│  Favicon:        [Upload Icon]    Current: favicon.ico                      │
│  Primary Color:  [#2563EB]        ████                                      │
│  Secondary:      [#1E40AF]        ████                                      │
│  Accent:         [#3B82F6]        ████                                      │
│                                                                              │
│  CUSTOM DOMAIN                                                              │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                                                              │
│  Domain:         admin.youragency.com                                       │
│  Status:         🟢 Active (SSL Configured)                                │
│  [Edit DNS Settings]                                                        │
│                                                                              │
│  EMAIL TEMPLATES                                                            │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                                                              │
│  From Name:      Your Agency Name                                           │
│  From Email:     bookings@youragency.com                                    │
│  [Customize Templates]                                                      │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 9.2 Custom Domain Setup

1. Add CNAME record to your DNS:
   ```
   admin.youragency.com → custom.vestalumina.com
   ```

2. Request SSL certificate (automatic)

3. Verify domain in settings

4. Domain active within 24 hours

### 9.3 Email Customization

Customize email templates for:
- Booking confirmations
- Check-in instructions
- Guest reminders
- Owner notifications
- Weekly reports

---

## 10. Billing & Invoicing

### 10.1 Subscription Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  BILLING                                                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  CURRENT PLAN: Enterprise                                                   │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                                                              │
│  Properties:     47 / 100                                                   │
│  Users:          23 / 50                                                    │
│  Tablets:        42 / 100                                                   │
│                                                                              │
│  Monthly Cost:   €470 (€10/property)                                        │
│  Next Invoice:   February 1, 2026                                           │
│  Payment Method: VISA ****4242                                              │
│                                                                              │
│  [Change Plan]  [Update Payment]  [View Invoices]                           │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 10.2 Invoice History

| Date | Invoice # | Amount | Status |
|------|-----------|--------|--------|
| Jan 1, 2026 | INV-2026-001 | €470.00 | ✅ Paid |
| Dec 1, 2025 | INV-2025-012 | €450.00 | ✅ Paid |
| Nov 1, 2025 | INV-2025-011 | €430.00 | ✅ Paid |

### 10.3 Owner Billing

If you bill property owners:

1. Go to **Billing → Owner Billing**
2. Configure billing rules:
   - Per-property fee
   - Per-booking percentage
   - Flat monthly fee
3. Generate invoices automatically
4. Track payment status

---

## 11. System Settings

### 11.1 Global Settings

| Setting | Description | Default |
|---------|-------------|---------|
| **Default Language** | Interface language | Croatian |
| **Default Currency** | For pricing/reports | EUR |
| **Time Zone** | Organization time zone | CET |
| **Date Format** | DD.MM.YYYY or MM/DD/YYYY | DD.MM.YYYY |
| **First Day of Week** | Monday or Sunday | Monday |

### 11.2 Integration Settings

Manage organization-wide integrations:

| Integration | Status | Scope |
|-------------|--------|-------|
| OpenAI API | ✅ Active | All properties |
| SendGrid | ✅ Active | All properties |
| Sentry | ✅ Active | All properties |
| Google Analytics | ❌ Not configured | - |

### 11.3 Security Settings

| Setting | Recommendation |
|---------|----------------|
| **Two-Factor Auth** | Required for Super Admins |
| **Session Timeout** | 4 hours |
| **Password Policy** | Minimum 12 characters |
| **IP Whitelist** | Optional for extra security |

---

## 12. Best Practices

### 12.1 Organization Tips

| Practice | Benefit |
|----------|---------|
| Use property groups | Easier management |
| Assign regional managers | Distributed oversight |
| Set up automated reports | Stay informed |
| Regular audit log review | Security monitoring |
| Maintain user permissions | Principle of least privilege |

### 12.2 Scaling Tips

| Scale | Recommendation |
|-------|----------------|
| **10-25 properties** | 1 Super Admin sufficient |
| **25-50 properties** | Add regional managers |
| **50-100 properties** | Dedicated cleaning coordinator |
| **100+ properties** | Full team structure |

### 12.3 Common Workflows

**Onboarding New Property Owner:**
1. Create user account
2. Assign properties
3. Send welcome email with training
4. Schedule onboarding call
5. Monitor first month activity

**Monthly Review:**
1. Check analytics dashboard
2. Review occupancy trends
3. Verify tablet status
4. Audit user permissions
5. Generate owner reports

**Incident Response:**
1. Check alerts dashboard
2. Identify affected properties
3. Contact relevant owners
4. Resolve issue
5. Document in audit log

---

## Quick Reference

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl + Shift + D` | Dashboard |
| `Ctrl + Shift + P` | Properties |
| `Ctrl + Shift + U` | Users |
| `Ctrl + Shift + R` | Reports |
| `Ctrl + Shift + S` | Settings |

### Support Contacts

| Level | Contact | Response Time |
|-------|---------|---------------|
| Standard | support@vestalumina.com | 24 hours |
| Priority | priority@vestalumina.com | 4 hours |
| Emergency | +385 91 VESTA-00 | 1 hour |

---

**© 2026 Vesta Lumina. All Rights Reserved.**

*Confidential - For Super Admin use only.*
