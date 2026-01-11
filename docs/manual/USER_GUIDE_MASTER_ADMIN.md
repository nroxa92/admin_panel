# Vesta Lumina Master Admin Guide

> **For System Administrators & Vesta Lumina Team**  
> **Version:** 2.1.0  
> **Last Updated:** January 2026  
> **Classification:** STRICTLY CONFIDENTIAL  
> **© 2026 Vesta Lumina. All Rights Reserved.**

---

## ⚠️ NOTICE

This document is intended for **Vesta Lumina Master Administrators only**. Master Admin access provides complete system control across all tenants and organizations. Handle with extreme care.

---

## Table of Contents

1. [Master Admin Overview](#1-master-admin-overview)
2. [System Dashboard](#2-system-dashboard)
3. [Tenant Management](#3-tenant-management)
4. [Super Admin Management](#4-super-admin-management)
5. [Global Configuration](#5-global-configuration)
6. [Infrastructure Monitoring](#6-infrastructure-monitoring)
7. [Security Operations](#7-security-operations)
8. [Billing & Subscriptions](#8-billing--subscriptions)
9. [Feature Flags & Rollouts](#9-feature-flags--rollouts)
10. [Support Operations](#10-support-operations)
11. [Disaster Recovery](#11-disaster-recovery)
12. [Compliance & Auditing](#12-compliance--auditing)

---

## 1. Master Admin Overview

### 1.1 Role Definition

The **Master Admin** is the highest privilege level in Vesta Lumina, reserved for core team members responsible for:

- System-wide configuration
- Multi-tenant oversight
- Infrastructure management
- Security operations
- Billing administration
- Feature deployment

### 1.2 Access Requirements

| Requirement | Details |
|-------------|---------|
| **Authentication** | Email + Password + 2FA (mandatory) |
| **IP Restriction** | Whitelist only (optional) |
| **Session Timeout** | 2 hours maximum |
| **Audit Logging** | All actions logged |
| **Access Review** | Quarterly review required |

### 1.3 Master Admin Console

Access via:
```
https://master.vestalumina.com
```

Or via main admin panel:
```
https://admin.vestalumina.com → Settings → Master Console
```

---

## 2. System Dashboard

### 2.1 Global Metrics

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  🔐 MASTER ADMIN CONSOLE                            [🔔] [👤 Master] [⚙️]      │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  SYSTEM HEALTH                                                                  │
│  ════════════════════════════════════════════════════════════════════════════   │
│                                                                                  │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐    │
│  │   STATUS   │ │   TENANTS  │ │ PROPERTIES │ │   USERS    │ │   MRR      │    │
│  │  🟢 100%   │ │     45     │ │   1,247    │ │    892     │ │  €18,470   │    │
│  │  Uptime    │ │   Active   │ │   Total    │ │   Active   │ │  Monthly   │    │
│  └────────────┘ └────────────┘ └────────────┘ └────────────┘ └────────────┘    │
│                                                                                  │
│  INFRASTRUCTURE                                                                 │
│  ════════════════════════════════════════════════════════════════════════════   │
│                                                                                  │
│  Cloud Functions:  🟢 OK  (24/24 healthy)    Response: 145ms avg               │
│  Firestore:        🟢 OK  (1.2M docs)        Reads: 45K/hr                     │
│  Cloud Storage:    🟢 OK  (125 GB used)      Bandwidth: 12 GB/day              │
│  Firebase Auth:    🟢 OK  (892 active)       Logins: 234 today                 │
│                                                                                  │
│  ALERTS                                                                         │
│  ════════════════════════════════════════════════════════════════════════════   │
│                                                                                  │
│  🟡 WARN  High API usage: Tenant "Split Agency" at 85% quota                   │
│  ℹ️ INFO  New tenant signup: "Adriatic Villas" pending approval                │
│  ℹ️ INFO  Scheduled maintenance: Feb 1, 2026 02:00-04:00 CET                   │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Real-Time Metrics

| Metric | Current | 24h Avg | Alert Threshold |
|--------|---------|---------|-----------------|
| API Latency | 145ms | 152ms | > 500ms |
| Error Rate | 0.02% | 0.03% | > 1% |
| Active Sessions | 234 | 198 | > 1000 |
| Function Invocations | 12.4K/hr | 10.8K/hr | > 50K/hr |
| Firestore Reads | 45K/hr | 42K/hr | > 200K/hr |
| Firestore Writes | 8K/hr | 7.2K/hr | > 50K/hr |

### 2.3 System Health Checks

Automated health checks every 60 seconds:

| Check | Endpoint | Expected |
|-------|----------|----------|
| API Health | `/api/health` | 200 OK |
| Auth Service | `/auth/verify` | 200 OK |
| Database | Firestore ping | < 100ms |
| Storage | GCS ping | < 200ms |
| AI Service | OpenAI ping | < 500ms |
| Email | SendGrid ping | < 300ms |

---

## 3. Tenant Management

### 3.1 Tenant List

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  TENANTS                                              [+ New Tenant] [Export]  │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  Organization       │ Plan       │ Properties │ MRR      │ Status    │ Actions │
│  ═══════════════════│════════════│════════════│══════════│═══════════│═════════│
│  Split Coastal DMC  │ Enterprise │ 47         │ €470     │ 🟢 Active │ [⚙️]    │
│  Zagreb Apartments  │ Business   │ 23         │ €230     │ 🟢 Active │ [⚙️]    │
│  Adriatic Villas    │ -          │ -          │ -        │ 🟡 Pending│ [⚙️]    │
│  Istria Luxury      │ Enterprise │ 82         │ €820     │ 🟢 Active │ [⚙️]    │
│  Dalmatia Tours     │ Business   │ 31         │ €310     │ 🟢 Active │ [⚙️]    │
│  Individual Owner   │ Starter    │ 2          │ €20      │ 🟢 Active │ [⚙️]    │
│                                                                                  │
│  Showing 1-6 of 45 tenants                                [◄] [1] [2] ... [►]  │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Creating New Tenant

1. Click **"+ New Tenant"**
2. Fill tenant information:

| Field | Required | Notes |
|-------|----------|-------|
| Organization Name | ✅ | Company name |
| Legal Entity | ✅ | Registered name |
| Tax ID / OIB | ✅ | For invoicing |
| Country | ✅ | Primary country |
| Admin Email | ✅ | Super Admin email |
| Admin Name | ✅ | Super Admin name |
| Plan | ✅ | Starter/Business/Enterprise |
| Trial Days | ❌ | Default: 14 days |

3. Click **"Create Tenant"**
4. System automatically:
   - Creates Firestore collections
   - Sets up security rules
   - Sends welcome email
   - Creates Super Admin account

### 3.3 Tenant Configuration

Click ⚙️ on any tenant to access:

#### General Settings
| Setting | Description |
|---------|-------------|
| Organization Details | Name, address, contacts |
| Billing Information | Payment method, invoicing |
| Plan & Limits | Subscription tier, quotas |
| Feature Access | Enabled features |

#### Data Isolation
```
Tenant Data Path: /tenants/{tenantId}/...

Security Rule:
match /tenants/{tenantId}/{document=**} {
  allow read, write: if request.auth.token.tenantId == tenantId
                     || request.auth.token.role == 'master_admin';
}
```

#### Impersonation Mode
⚠️ **Use with extreme caution!**

1. Click **"Impersonate Super Admin"**
2. Confirm with 2FA
3. View system as tenant's Super Admin
4. All actions logged with your Master Admin ID
5. Exit impersonation when done

### 3.4 Tenant Lifecycle

```
    ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
    │ PENDING │────►│  TRIAL  │────►│ ACTIVE  │────►│ CHURNED │
    └─────────┘     └─────────┘     └─────────┘     └─────────┘
         │               │               │               │
         │               │               │               │
         ▼               ▼               ▼               ▼
    [Approval]      [14 days]     [Subscription]   [Retention
     Required        trial          active         window 30d]
                                      │               │
                                      ▼               ▼
                               ┌─────────┐     ┌─────────┐
                               │SUSPENDED│     │ DELETED │
                               └─────────┘     └─────────┘
```

### 3.5 Tenant Deletion

**WARNING: Irreversible action!**

1. Suspend tenant first (30-day retention)
2. Verify no outstanding invoices
3. Export data for compliance (if requested)
4. Request deletion with written approval
5. Confirm deletion with 2FA
6. Data permanently removed

---

## 4. Super Admin Management

### 4.1 All Super Admins

View Super Admins across all tenants:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  SUPER ADMINS                                                    [🔍 Search]   │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  Name             │ Email                  │ Organization      │ Last Login    │
│  ═════════════════│════════════════════════│═══════════════════│═══════════════│
│  Marko Petrović   │ marko@splitcoastal.hr  │ Split Coastal DMC │ 2 hours ago   │
│  Ana Jurić        │ ana@zagrebapt.com      │ Zagreb Apartments │ 1 day ago     │
│  Ivan Matić       │ ivan@istrialux.hr      │ Istria Luxury     │ 3 hours ago   │
│  Petra Kovačević  │ petra@dalmatiatours.hr │ Dalmatia Tours    │ 5 hours ago   │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Create Super Admin

For new or existing tenant:

1. Select tenant
2. Click **"Add Super Admin"**
3. Enter details:
   - Name
   - Email
   - Phone (optional)
4. Send invitation email
5. Super Admin sets password on first login

### 4.3 Reset Super Admin Access

If Super Admin locked out:

1. Find Super Admin in list
2. Click **"Reset Access"**
3. Choose action:
   - Reset password (email sent)
   - Reset 2FA
   - Unlock account
4. Confirm with Master Admin 2FA
5. Notify Super Admin

---

## 5. Global Configuration

### 5.1 System Settings

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  GLOBAL CONFIGURATION                                                           │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  GENERAL                                                                        │
│  ─────────────────────────────────────────────────────────────────────────────  │
│  Default Language:        Croatian [▼]                                          │
│  Default Currency:        EUR [▼]                                               │
│  Default Timezone:        Europe/Zagreb [▼]                                     │
│  Maintenance Mode:        ⭕ Off  ◉ On (shows maintenance page)                 │
│                                                                                  │
│  FEATURES                                                                       │
│  ─────────────────────────────────────────────────────────────────────────────  │
│  AI Assistant:            ✅ Enabled globally                                   │
│  OCR Scanning:            ✅ Enabled globally                                   │
│  iCal Sync:               ✅ Enabled globally                                   │
│  White-Label:             ✅ Enterprise only                                    │
│  Custom Domain:           ✅ Enterprise only                                    │
│                                                                                  │
│  SECURITY                                                                       │
│  ─────────────────────────────────────────────────────────────────────────────  │
│  2FA Required (Admins):   ✅ Yes                                                │
│  Session Timeout:         4 hours [▼]                                           │
│  Password Min Length:     12 characters [▼]                                     │
│  Max Login Attempts:      5 [▼]                                                 │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 5.2 API Keys Management

| Service | Key Location | Rotation |
|---------|--------------|----------|
| OpenAI | Secret Manager | 90 days |
| Google Vision | Secret Manager | Annual |
| SendGrid | Secret Manager | 90 days |
| Sentry | Secret Manager | Annual |
| Stripe | Secret Manager | 90 days |

### 5.3 Email Templates

Global email templates (can be overridden by tenants):

| Template | Purpose | Variables |
|----------|---------|-----------|
| welcome_email | New user signup | {name}, {org}, {login_url} |
| password_reset | Password reset | {name}, {reset_url}, {expiry} |
| booking_confirm | Booking confirmation | {guest}, {unit}, {dates} |
| invoice | Monthly invoice | {org}, {amount}, {items} |
| alert | System alert | {type}, {message}, {action} |

---

## 6. Infrastructure Monitoring

### 6.1 Firebase Console

Quick access to Firebase services:

| Service | Direct Link | Purpose |
|---------|-------------|---------|
| Firestore | console.firebase.google.com/firestore | Database |
| Functions | console.firebase.google.com/functions | Backend |
| Storage | console.firebase.google.com/storage | Files |
| Auth | console.firebase.google.com/auth | Users |
| Hosting | console.firebase.google.com/hosting | Web apps |

### 6.2 Cloud Functions Monitoring

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  CLOUD FUNCTIONS                                             [Refresh] [Logs]  │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  Function               │ Invocations │ Errors │ Avg Time │ Memory │ Status    │
│  ═══════════════════════│═════════════│════════│══════════│════════│══════════ │
│  createBooking          │ 1,245       │ 3      │ 125ms    │ 256MB  │ 🟢 OK     │
│  processCheckIn         │ 892         │ 0      │ 245ms    │ 512MB  │ 🟢 OK     │
│  syncICalFeed           │ 4,521       │ 12     │ 890ms    │ 256MB  │ 🟡 WARN   │
│  generatePDF            │ 523         │ 1      │ 1,250ms  │ 1GB    │ 🟢 OK     │
│  processAIChat          │ 2,341       │ 5      │ 450ms    │ 512MB  │ 🟢 OK     │
│  scanDocument           │ 421         │ 2      │ 1,890ms  │ 1GB    │ 🟢 OK     │
│                                                                                  │
│  [View All 24 Functions]                                                        │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 6.3 Error Tracking (Sentry)

| Error Level | Count (24h) | Top Issue |
|-------------|-------------|-----------|
| 🔴 Fatal | 0 | - |
| 🟠 Error | 12 | iCal parse failure |
| 🟡 Warning | 45 | Rate limit approached |
| 🔵 Info | 234 | Debug logs |

### 6.4 Performance Alerts

Configure alerts for:

| Metric | Warning | Critical | Action |
|--------|---------|----------|--------|
| API Latency | > 300ms | > 500ms | Page on-call |
| Error Rate | > 0.5% | > 1% | Page on-call |
| Function Timeout | > 30s | > 60s | Auto-scale |
| Database Size | > 80% | > 95% | Notify team |

---

## 7. Security Operations

### 7.1 Security Dashboard

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  SECURITY CENTER                                                                │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  THREAT OVERVIEW                                                                │
│  ─────────────────────────────────────────────────────────────────────────────  │
│                                                                                  │
│  Failed Logins (24h):     23          Blocked IPs:           5                  │
│  Suspicious Activity:     2           Security Alerts:       0                  │
│                                                                                  │
│  RECENT SECURITY EVENTS                                                         │
│  ─────────────────────────────────────────────────────────────────────────────  │
│                                                                                  │
│  🟡 10:45  Multiple failed logins: user@example.com (5 attempts)               │
│  🟡 09:23  New device login: marko@splitcoastal.hr from Germany                │
│  🟢 08:15  Password changed: ana@zagrebapt.com                                  │
│  🟢 07:30  2FA enabled: ivan@istrialux.hr                                       │
│                                                                                  │
│  [View Security Logs]  [IP Blocklist]  [Security Rules]                         │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 7.2 IP Blocklist

Manage blocked IPs:

| IP Address | Reason | Blocked Date | Expires |
|------------|--------|--------------|---------|
| 192.0.2.1 | Brute force | Jan 10, 2026 | Jan 17, 2026 |
| 198.51.100.5 | Suspicious | Jan 9, 2026 | Never |

### 7.3 Security Audit Log

All Master Admin actions are logged:

```json
{
  "timestamp": "2026-01-11T10:45:00Z",
  "actor": "master_admin@vestalumina.com",
  "action": "tenant.impersonate",
  "target": "tenant_splitcoastal",
  "ip": "203.0.113.45",
  "userAgent": "Chrome/120.0",
  "result": "success"
}
```

### 7.4 Emergency Actions

| Action | Purpose | Confirmation |
|--------|---------|--------------|
| **Global Lockdown** | Disable all logins | 2FA + Reason |
| **Force Logout All** | End all sessions | 2FA |
| **Disable Tenant** | Suspend tenant | 2FA + Reason |
| **Revoke API Keys** | Invalidate all keys | 2FA |

---

## 8. Billing & Subscriptions

### 8.1 Revenue Dashboard

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  REVENUE                                              [Jan 2026 ▼] [Export]    │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  MRR: €18,470    │    ARR: €221,640    │    Growth: +12% MoM                   │
│                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                         MRR TREND                                        │   │
│  │                                                                          │   │
│  │  €20K ┤                                              ████                │   │
│  │       │                                    ████      ████                │   │
│  │  €15K ┤                          ████      ████      ████                │   │
│  │       │                ████      ████      ████      ████                │   │
│  │  €10K ┤      ████      ████      ████      ████      ████                │   │
│  │       │      ████      ████      ████      ████      ████                │   │
│  │   €5K ┤      ████      ████      ████      ████      ████                │   │
│  │       │      ████      ████      ████      ████      ████                │   │
│  │    €0 ┼─────────────────────────────────────────────────────             │   │
│  │         Aug     Sep     Oct     Nov     Dec     Jan                      │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
│  BREAKDOWN BY PLAN                                                              │
│  Enterprise (12 tenants):  €10,240  │  55%                                     │
│  Business (25 tenants):    €6,230   │  34%                                     │
│  Starter (8 tenants):      €2,000   │  11%                                     │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 8.2 Invoice Management

| Status | Count | Amount |
|--------|-------|--------|
| 🟢 Paid | 42 | €16,890 |
| 🟡 Pending | 3 | €1,580 |
| 🔴 Overdue | 0 | €0 |

### 8.3 Subscription Plans

| Plan | Price | Limits | Features |
|------|-------|--------|----------|
| **Starter** | €10/prop/mo | 5 properties | Basic features |
| **Business** | €10/prop/mo | 50 properties | + AI, + Reports |
| **Enterprise** | €10/prop/mo | Unlimited | + White-label, + API |

### 8.4 Stripe Integration

- Dashboard: dashboard.stripe.com
- Webhook endpoint: `/api/webhooks/stripe`
- Events handled: `invoice.paid`, `subscription.updated`, `payment_failed`

---

## 9. Feature Flags & Rollouts

### 9.1 Feature Flag Dashboard

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  FEATURE FLAGS                                              [+ New Flag]        │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  Flag Name              │ Status     │ Rollout    │ Tenants     │ Actions      │
│  ═══════════════════════│════════════│════════════│═════════════│══════════════│
│  new_calendar_ui        │ 🟢 Enabled │ 100%       │ All         │ [⚙️]         │
│  ai_voice_mode          │ 🟡 Beta    │ 25%        │ 12 tenants  │ [⚙️]         │
│  smart_pricing          │ 🟡 Beta    │ 10%        │ 5 tenants   │ [⚙️]         │
│  channel_manager        │ 🔴 Dev     │ 0%         │ Internal    │ [⚙️]         │
│  mobile_app             │ 🔴 Dev     │ 0%         │ Internal    │ [⚙️]         │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 9.2 Creating Feature Flag

| Setting | Description |
|---------|-------------|
| Flag Name | Unique identifier (snake_case) |
| Description | What the feature does |
| Default | Off for new tenants |
| Rollout % | Percentage of tenants |
| Specific Tenants | Override for specific tenants |

### 9.3 Rollout Strategy

```
    ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
    │  INTERNAL   │────►│   BETA      │────►│   GRADUAL   │────►│    GA       │
    │   (0%)      │     │  (5-10%)    │     │  (25-75%)   │     │   (100%)    │
    └─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
         │                   │                   │                   │
    Internal team       Select tenants      Expand slowly       All tenants
    testing only        for feedback        monitor metrics      enabled
```

---

## 10. Support Operations

### 10.1 Support Queue

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  SUPPORT TICKETS                                         [🔍] [Filter ▼]       │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  #1245  Split Coastal    "iCal sync not working"       🔴 High    2h ago       │
│  #1244  Zagreb Apts      "Need invoice correction"     🟡 Medium  5h ago       │
│  #1243  Individual       "How to add new unit"         🟢 Low     1 day ago    │
│                                                                                  │
│  Open: 3  │  In Progress: 2  │  Resolved Today: 8  │  Avg Response: 2.5h       │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 10.2 Common Support Actions

| Issue | Master Admin Action |
|-------|---------------------|
| Login issues | Reset password/2FA |
| Billing dispute | Adjust invoice, issue credit |
| Data request (GDPR) | Export tenant data |
| Bug report | Create internal ticket |
| Feature request | Log for product review |

### 10.3 Escalation Path

```
Level 1: Support Team (support@vestalumina.com)
    │
    ▼ Escalate after 4 hours
Level 2: Senior Support (senior-support@vestalumina.com)
    │
    ▼ Escalate for system issues
Level 3: Engineering (engineering@vestalumina.com)
    │
    ▼ Escalate for critical/security
Level 4: Master Admin (master@vestalumina.com)
```

---

## 11. Disaster Recovery

### 11.1 Backup Status

| Data Type | Frequency | Retention | Last Backup |
|-----------|-----------|-----------|-------------|
| Firestore | Daily | 30 days | 2 hours ago |
| Storage | Daily | 30 days | 3 hours ago |
| Functions Config | On change | Forever | Jan 10, 2026 |
| Secrets | On change | Forever | Jan 8, 2026 |

### 11.2 Recovery Procedures

#### Firestore Point-in-Time Recovery

```bash
# Export current state
gcloud firestore export gs://vesta-lumina-backups/$(date +%Y%m%d)

# Restore from backup
gcloud firestore import gs://vesta-lumina-backups/20260110
```

#### Full System Recovery

1. **Assess Damage**
   - Identify affected services
   - Determine data loss window

2. **Communicate**
   - Enable maintenance mode
   - Notify affected tenants

3. **Restore**
   - Restore from latest backup
   - Verify data integrity
   - Test critical functions

4. **Resume**
   - Disable maintenance mode
   - Monitor for issues
   - Post-mortem report

### 11.3 Emergency Contacts

| Role | Contact | Method |
|------|---------|--------|
| Engineering Lead | +385 91 XXX XXXX | Phone/SMS |
| CTO | +385 91 XXX XXXX | Phone/SMS |
| Firebase Support | Firebase Console | Ticket |
| Stripe Support | dashboard.stripe.com | Ticket |

---

## 12. Compliance & Auditing

### 12.1 GDPR Compliance

| Requirement | Implementation | Status |
|-------------|----------------|--------|
| Data inventory | Documented | ✅ |
| Lawful basis | Contracts, consent | ✅ |
| Subject rights | Self-service + manual | ✅ |
| Data retention | Automated deletion | ✅ |
| Breach notification | Process documented | ✅ |
| DPO | Designated | ✅ |

### 12.2 Data Subject Requests

Handle GDPR requests:

| Request Type | SLA | Process |
|--------------|-----|---------|
| Access (SAR) | 30 days | Export tenant data |
| Erasure | 30 days | Delete tenant + data |
| Portability | 30 days | Export in JSON format |
| Rectification | 30 days | Update records |

### 12.3 Audit Log Retention

| Log Type | Retention | Purpose |
|----------|-----------|---------|
| Security logs | 2 years | Security audit |
| Access logs | 1 year | Compliance |
| Transaction logs | 7 years | Financial audit |
| Error logs | 90 days | Debugging |

### 12.4 Compliance Reports

Generate for auditors:

- SOC 2 Type II (if applicable)
- GDPR compliance report
- Security audit summary
- Access control review

---

## Quick Reference

### Master Admin Commands

| Command | Description |
|---------|-------------|
| `Ctrl + Shift + M` | Master Console |
| `Ctrl + Shift + T` | Tenant List |
| `Ctrl + Shift + L` | Audit Logs |
| `Ctrl + Shift + S` | System Status |

### Emergency Procedures

| Situation | Action |
|-----------|--------|
| Security breach | Global lockdown → Investigate → Notify |
| System down | Check Firebase status → Restore → Notify |
| Data loss | Assess → Restore from backup → Post-mortem |
| Billing issue | Pause billing → Investigate → Resolve |

---

**© 2026 Vesta Lumina. All Rights Reserved.**

*STRICTLY CONFIDENTIAL - Master Admin access only.*
*Unauthorized access is prohibited and monitored.*
