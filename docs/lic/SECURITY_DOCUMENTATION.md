# VESTA LUMINA SECURITY DOCUMENTATION
## Security Architecture & Audit Report

**Version:** 2.1.0  
**Last Audit:** January 2026  
**Classification:** CONFIDENTIAL

---

## ⚠️ CONFIDENTIAL - INTERNAL USE ONLY

```
This document contains sensitive security information.
Distribution is strictly limited to authorized personnel.
```

---

## Table of Contents

1. [Security Overview](#1-security-overview)
2. [Authentication & Authorization](#2-authentication--authorization)
3. [Data Protection](#3-data-protection)
4. [Infrastructure Security](#4-infrastructure-security)
5. [Application Security](#5-application-security)
6. [Compliance](#6-compliance)
7. [Incident Response](#7-incident-response)
8. [Security Audit Checklist](#8-security-audit-checklist)

---

## 1. Security Overview

### 1.1. Security Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      SECURITY LAYERS                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    NETWORK LAYER                          │   │
│  │  • TLS 1.3 encryption                                    │   │
│  │  • DDoS protection (Cloudflare)                          │   │
│  │  • WAF rules                                             │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                  APPLICATION LAYER                        │   │
│  │  • Input validation                                      │   │
│  │  • Output encoding                                       │   │
│  │  • CSRF protection                                       │   │
│  │  • Content Security Policy                               │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                 AUTHENTICATION LAYER                      │   │
│  │  • Firebase Auth                                         │   │
│  │  • JWT tokens with custom claims                         │   │
│  │  • Role-based access control                             │   │
│  │  • Multi-factor authentication (optional)                │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    DATA LAYER                             │   │
│  │  • AES-256 encryption at rest                            │   │
│  │  • Field-level encryption for PII                        │   │
│  │  • Firestore security rules                              │   │
│  │  • Automatic data retention policies                     │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2. Security Principles

| Principle | Implementation |
|-----------|----------------|
| **Defense in Depth** | Multiple security layers |
| **Least Privilege** | Minimal access rights |
| **Fail Secure** | Default deny on errors |
| **Complete Mediation** | Every access checked |
| **Separation of Duties** | Role-based access |

### 1.3. Security Certifications

| Certification | Status | Expiry |
|---------------|--------|--------|
| GDPR Compliant | ✅ Active | N/A |
| ISO 27001 | 🔄 In Progress | - |
| SOC 2 Type II | 📋 Planned | - |

---

## 2. Authentication & Authorization

### 2.1. Authentication Methods

| Method | Use Case | Security Level |
|--------|----------|----------------|
| Email/Password | Owner login | Standard |
| Email/Password + 2FA | Owner login (enhanced) | High |
| Custom Token | Tablet terminals | Standard |
| Anonymous Auth | Guest check-in | Limited |
| PIN Code | Cleaner access | Limited |

### 2.2. Password Policy

```
Minimum requirements:
• Length: 8 characters minimum
• Complexity: At least one uppercase, lowercase, number
• History: Cannot reuse last 5 passwords
• Expiry: No forced expiry (NIST recommendation)
• Lockout: 5 failed attempts = 15 minute lockout
```

### 2.3. JWT Token Structure

```json
{
  "alg": "RS256",
  "typ": "JWT"
}
.
{
  "uid": "user_abc123",
  "email": "owner@example.com",
  "ownerId": "owner_xyz789",
  "role": "owner",
  "permissions": ["read", "write"],
  "iat": 1704067200,
  "exp": 1704153600,
  "iss": "https://securetoken.google.com/vestalumina"
}
.
[signature]
```

### 2.4. Role-Based Access Control (RBAC)

| Role | Level | Permissions |
|------|-------|-------------|
| Super Admin | 3 | Full system access |
| Brand Admin | 2 | Own brand + assigned owners |
| Owner | 1 | Own data only |
| Cleaner | 0.5 | Cleaning tasks only |
| Guest | 0 | Check-in flow only |

### 2.5. Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(ownerId) {
      return isAuthenticated() && 
             request.auth.token.ownerId == ownerId;
    }
    
    function isSuperAdmin() {
      return isAuthenticated() && 
             request.auth.token.role == 'super_admin';
    }
    
    function isValidBooking() {
      return request.resource.data.checkIn is timestamp &&
             request.resource.data.checkOut is timestamp &&
             request.resource.data.checkOut > request.resource.data.checkIn;
    }
    
    // Owner documents - isolated by ownerId
    match /owners/{ownerId} {
      allow read: if isOwner(ownerId) || isSuperAdmin();
      allow write: if isOwner(ownerId) || isSuperAdmin();
      
      // Units subcollection
      match /units/{unitId} {
        allow read: if isOwner(ownerId) || isSuperAdmin();
        allow write: if isOwner(ownerId) || isSuperAdmin();
        
        // Bookings subcollection
        match /bookings/{bookingId} {
          allow read: if isOwner(ownerId) || isSuperAdmin();
          allow create: if isOwner(ownerId) && isValidBooking();
          allow update: if isOwner(ownerId);
          allow delete: if isOwner(ownerId);
        }
      }
      
      // Cleaning logs
      match /cleaning_logs/{logId} {
        allow read: if isOwner(ownerId) || isSuperAdmin();
        allow create: if isOwner(ownerId) || 
                        request.auth.token.role == 'cleaner';
      }
    }
    
    // Super admin only
    match /super_admin/{document=**} {
      allow read, write: if isSuperAdmin();
    }
    
    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## 3. Data Protection

### 3.1. Data Classification

| Classification | Examples | Protection |
|----------------|----------|------------|
| **Public** | Marketing content | None required |
| **Internal** | Analytics, logs | Access control |
| **Confidential** | Business data | Encryption + access control |
| **Restricted** | PII, financial | Encryption + audit + access control |

### 3.2. Encryption Standards

| Data State | Algorithm | Key Size |
|------------|-----------|----------|
| In Transit | TLS 1.3 | 256-bit |
| At Rest | AES-256-GCM | 256-bit |
| Backups | AES-256 | 256-bit |
| Document fields | AES-256-GCM | 256-bit |

### 3.3. PII Data Handling

```
Personal Identifiable Information (PII):
─────────────────────────────────────────
• Guest names
• Passport/ID numbers
• Date of birth
• Email addresses
• Phone numbers
• Signatures
• Nationality

Protection measures:
• Encrypted at rest
• Encrypted in transit
• Access logging
• Auto-deletion after checkout
• GDPR export/delete capabilities
```

### 3.4. Data Retention

| Data Type | Retention Period | Deletion Method |
|-----------|------------------|-----------------|
| Guest PII | 30 days post-checkout | Automatic |
| Booking records | 7 years | Manual |
| Audit logs | 2 years | Automatic |
| Error logs | 90 days | Automatic |
| Analytics | 2 years | Manual |
| Signatures | 30 days | Automatic |

### 3.5. Backup Security

```
Backup Configuration:
─────────────────────
• Frequency: Daily (01:00 UTC)
• Retention: 30 days
• Location: europe-west3 (Frankfurt)
• Encryption: AES-256
• Access: Super Admin only
• Testing: Monthly restore test
```

---

## 4. Infrastructure Security

### 4.1. Cloud Infrastructure

| Component | Provider | Security Features |
|-----------|----------|-------------------|
| Hosting | Firebase Hosting | HTTPS, CDN, DDoS |
| Database | Cloud Firestore | Encryption, rules |
| Storage | Cloud Storage | Encryption, ACL |
| Functions | Cloud Functions | VPC, IAM |
| Auth | Firebase Auth | OAuth 2.0, MFA |

### 4.2. Network Security

```
┌─────────────────────────────────────────────────────────────┐
│                    NETWORK ARCHITECTURE                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Internet                                                   │
│      │                                                      │
│      ▼                                                      │
│  ┌──────────────┐                                          │
│  │  Cloudflare  │ ← DDoS protection, WAF                   │
│  │     CDN      │ ← SSL termination                        │
│  └──────┬───────┘                                          │
│         │                                                   │
│         ▼                                                   │
│  ┌──────────────┐                                          │
│  │   Firebase   │ ← Load balancing                         │
│  │   Hosting    │ ← HTTPS only                             │
│  └──────┬───────┘                                          │
│         │                                                   │
│         ▼                                                   │
│  ┌──────────────────────────────────────────┐              │
│  │          Google Cloud VPC                 │              │
│  │  ┌────────────┐  ┌────────────────────┐  │              │
│  │  │ Firestore  │  │  Cloud Functions   │  │              │
│  │  │ (private)  │  │  (private egress)  │  │              │
│  │  └────────────┘  └────────────────────┘  │              │
│  └──────────────────────────────────────────┘              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 4.3. Access Control

| Resource | Access Method | Audit |
|----------|---------------|-------|
| Firebase Console | Google Account + 2FA | ✅ |
| Cloud Functions | IAM roles | ✅ |
| Firestore | Security rules | ✅ |
| Storage | Security rules | ✅ |
| GitHub | SSH keys + 2FA | ✅ |

---

## 5. Application Security

### 5.1. Input Validation

```dart
// Server-side validation (Cloud Functions)
function validateBookingData(data: BookingData): ValidationResult {
  const errors: string[] = [];
  
  // Required fields
  if (!data.checkIn) errors.push('checkIn is required');
  if (!data.checkOut) errors.push('checkOut is required');
  if (!data.guestName) errors.push('guestName is required');
  
  // Format validation
  if (data.guestEmail && !isValidEmail(data.guestEmail)) {
    errors.push('Invalid email format');
  }
  
  // Business logic validation
  if (data.checkOut <= data.checkIn) {
    errors.push('checkOut must be after checkIn');
  }
  
  // Sanitization
  data.guestName = sanitizeString(data.guestName);
  data.notes = sanitizeString(data.notes);
  
  return { valid: errors.length === 0, errors, data };
}
```

### 5.2. Output Encoding

```dart
// Client-side encoding
String encodeHtml(String input) {
  return input
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#x27;');
}
```

### 5.3. Content Security Policy

```http
Content-Security-Policy: 
  default-src 'self';
  script-src 'self' https://www.gstatic.com https://apis.google.com;
  style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
  font-src 'self' https://fonts.gstatic.com;
  img-src 'self' data: https://storage.googleapis.com;
  connect-src 'self' https://*.googleapis.com https://*.firebaseio.com;
  frame-src https://accounts.google.com;
```

### 5.4. Dependency Security

```bash
# Check for vulnerabilities
npm audit
flutter pub outdated

# Automated scanning
# GitHub Dependabot enabled
# Snyk integration for CI/CD
```

### 5.5. Secure Coding Practices

| Practice | Implementation |
|----------|----------------|
| No hardcoded secrets | Environment variables |
| Parameterized queries | Firestore SDK |
| Error handling | No stack traces to client |
| Logging | No PII in logs |
| Session management | Firebase Auth tokens |

---

## 6. Compliance

### 6.1. GDPR Compliance

| Requirement | Implementation | Status |
|-------------|----------------|--------|
| Lawful basis | Consent + Contract | ✅ |
| Data minimization | Collect only necessary | ✅ |
| Right to access | Export function | ✅ |
| Right to erasure | Delete function | ✅ |
| Data portability | JSON/CSV export | ✅ |
| Breach notification | Incident process | ✅ |
| DPO appointed | Yes | ✅ |
| Privacy policy | Published | ✅ |
| Cookie consent | Implemented | ✅ |

### 6.2. Data Processing Agreement (DPA)

```
DPA Structure:
─────────────
• Parties: Vesta Lumina (Processor) + Customer (Controller)
• Purpose: Property management services
• Data types: Guest PII, booking data
• Sub-processors: Listed and updated
• Security measures: Documented
• Breach notification: 24 hours
• Audit rights: Included
• Data return/deletion: Upon termination
```

### 6.3. eVisitor Compliance (Croatia)

| Requirement | Implementation |
|-------------|----------------|
| Guest registration | Automated from check-in |
| Data submission | API integration ready |
| Record retention | 3 years minimum |
| Authority access | Export capability |

---

## 7. Incident Response

### 7.1. Incident Classification

| Severity | Description | Response Time |
|----------|-------------|---------------|
| **Critical** | Data breach, system down | 15 minutes |
| **High** | Security vulnerability exploited | 1 hour |
| **Medium** | Potential vulnerability found | 4 hours |
| **Low** | Security improvement needed | 24 hours |

### 7.2. Incident Response Process

```
┌─────────────────────────────────────────────────────────────┐
│                 INCIDENT RESPONSE FLOW                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. DETECTION                                               │
│     │                                                       │
│     ▼                                                       │
│  2. TRIAGE (15 min)                                         │
│     • Classify severity                                     │
│     • Assign incident commander                             │
│     │                                                       │
│     ▼                                                       │
│  3. CONTAINMENT (1-4 hours)                                 │
│     • Isolate affected systems                              │
│     • Preserve evidence                                     │
│     │                                                       │
│     ▼                                                       │
│  4. ERADICATION                                             │
│     • Remove threat                                         │
│     • Patch vulnerabilities                                 │
│     │                                                       │
│     ▼                                                       │
│  5. RECOVERY                                                │
│     • Restore systems                                       │
│     • Verify integrity                                      │
│     │                                                       │
│     ▼                                                       │
│  6. POST-INCIDENT                                           │
│     • Root cause analysis                                   │
│     • Update procedures                                     │
│     • Document lessons learned                              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 7.3. Contact List

| Role | Contact | Available |
|------|---------|-----------|
| Security Lead | security@vestalumina.com | 24/7 |
| Incident Commander | incident@vestalumina.com | 24/7 |
| Legal | legal@vestalumina.com | Business hours |
| DPO | dpo@vestalumina.com | Business hours |

---

## 8. Security Audit Checklist

### 8.1. Monthly Audit

```
☐ Review access logs
☐ Check failed login attempts
☐ Verify backup integrity
☐ Review Firestore rules changes
☐ Check dependency vulnerabilities
☐ Review error logs for anomalies
☐ Verify SSL certificate expiry
☐ Check API rate limiting
```

### 8.2. Quarterly Audit

```
☐ Full security rules audit
☐ Penetration testing
☐ Access rights review
☐ Third-party vendor security review
☐ Incident response drill
☐ Employee security training
☐ Policy review and update
☐ GDPR compliance check
```

### 8.3. Annual Audit

```
☐ External security assessment
☐ Full compliance audit
☐ Disaster recovery test
☐ Security architecture review
☐ Vendor contract review
☐ Insurance review
☐ Certification renewal
```

---

## Appendix A: Security Contacts

| Emergency | Contact |
|-----------|---------|
| Security Hotline | +385 XX XXX XXXX |
| Email | security@vestalumina.com |
| PGP Key | [Available on request] |

---

<p align="center">
  <strong>VESTA LUMINA SECURITY DOCUMENTATION</strong><br>
  <em>CONFIDENTIAL</em><br>
  Version 2.1.0<br><br>
  © 2024-2026 Vesta Lumina d.o.o.
</p>
