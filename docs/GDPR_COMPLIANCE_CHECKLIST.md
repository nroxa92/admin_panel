# VESTA LUMINA GDPR COMPLIANCE CHECKLIST
## General Data Protection Regulation Compliance Guide

**Version:** 2.1.0  
**Last Updated:** January 2026  
**DPO Contact:** dpo@vestalumina.com

---

## Table of Contents

1. [Overview](#1-overview)
2. [Data Inventory](#2-data-inventory)
3. [Lawful Basis](#3-lawful-basis)
4. [Data Subject Rights](#4-data-subject-rights)
5. [Security Measures](#5-security-measures)
6. [Data Processing Agreements](#6-data-processing-agreements)
7. [Breach Notification](#7-breach-notification)
8. [Compliance Checklist](#8-compliance-checklist)

---

## 1. Overview

### 1.1. GDPR Applicability

Vesta Lumina processes personal data of EU residents and is therefore subject to GDPR requirements.

| Role | Entity | Responsibilities |
|------|--------|------------------|
| **Data Controller** | Property Owner (Customer) | Determines purpose and means of processing |
| **Data Processor** | Vesta Lumina d.o.o. | Processes data on behalf of Controller |
| **Data Subject** | Guest | Individual whose data is processed |

### 1.2. Key Principles

| Principle | Implementation |
|-----------|----------------|
| **Lawfulness** | Consent or contract basis |
| **Fairness** | Transparent processing |
| **Transparency** | Clear privacy notices |
| **Purpose Limitation** | Specific, explicit purposes |
| **Data Minimization** | Only necessary data collected |
| **Accuracy** | Keep data up to date |
| **Storage Limitation** | Delete when no longer needed |
| **Integrity & Confidentiality** | Appropriate security |
| **Accountability** | Demonstrate compliance |

---

## 2. Data Inventory

### 2.1. Personal Data Collected

| Data Category | Data Elements | Purpose | Retention |
|---------------|---------------|---------|-----------|
| **Guest Identity** | Name, DOB, nationality | Legal requirement (eVisitor) | 30 days |
| **Document Data** | ID/Passport number, expiry | Legal requirement | 30 days |
| **Contact Data** | Email, phone | Communication | 30 days |
| **Signature** | Digital signature image | House rules acceptance | 30 days |
| **Booking Data** | Dates, unit, price | Contract fulfillment | 7 years |
| **Usage Data** | App interactions, chat logs | Service improvement | 90 days |

### 2.2. Special Category Data

```
⚠️ Vesta Lumina does NOT intentionally collect special category data:
• Health data
• Biometric data
• Religious beliefs
• Political opinions
• Sexual orientation
• Trade union membership

If such data is inadvertently captured (e.g., in notes),
it is deleted upon discovery.
```

### 2.3. Data Flow Map

```
┌─────────────────────────────────────────────────────────────────┐
│                         DATA FLOW                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  GUEST                    TABLET                  ADMIN PANEL   │
│    │                        │                          │        │
│    │ 1. Enter booking ref   │                          │        │
│    ├───────────────────────►│                          │        │
│    │                        │                          │        │
│    │ 2. Scan document       │                          │        │
│    ├───────────────────────►│                          │        │
│    │                        │ 3. OCR extract           │        │
│    │                        ├─────────►ML Kit          │        │
│    │                        │                          │        │
│    │ 4. Confirm data        │                          │        │
│    ├───────────────────────►│                          │        │
│    │                        │                          │        │
│    │ 5. Sign house rules    │                          │        │
│    ├───────────────────────►│                          │        │
│    │                        │ 6. Store in Firestore    │        │
│    │                        ├─────────────────────────►│        │
│    │                        │                          │        │
│    │                        │                    7. View data   │
│    │                        │                          │        │
│    │                        │        8. Auto-delete after 30d   │
│    │                        │                          │        │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Lawful Basis

### 3.1. Lawful Basis by Processing Activity

| Activity | Lawful Basis | Documentation |
|----------|--------------|---------------|
| Guest check-in | Contract + Legal obligation | Terms of Service |
| eVisitor reporting | Legal obligation | Croatian law |
| House rules signature | Contract | Digital signature |
| Email notifications | Legitimate interest | Privacy policy |
| Marketing emails | Consent | Explicit opt-in |
| Analytics | Legitimate interest | Privacy policy |
| AI chat logs | Legitimate interest | Privacy notice |

### 3.2. Consent Management

```
Consent Requirements:
─────────────────────
☐ Freely given (no pre-ticked boxes)
☐ Specific (granular options)
☐ Informed (clear language)
☐ Unambiguous (affirmative action)
☐ Withdrawable (easy opt-out)

Consent Records Stored:
• What was consented to
• When consent was given
• How consent was given
• Who gave consent
```

### 3.3. Legitimate Interest Assessment (LIA)

```
Purpose: Processing chat logs for service improvement

1. Identify legitimate interest:
   ✓ Improving AI responses
   ✓ Identifying common guest questions

2. Necessity test:
   ✓ Chat analysis is necessary for improvement
   ✓ No less intrusive alternative

3. Balancing test:
   ✓ Minimal privacy impact (anonymized)
   ✓ Expected by data subjects
   ✓ Benefits outweigh risks

Conclusion: Processing is justified under legitimate interest
```

---

## 4. Data Subject Rights

### 4.1. Rights Implementation

| Right | Implementation | Response Time |
|-------|----------------|---------------|
| **Access** | Export via Admin Panel | 30 days |
| **Rectification** | Edit via Admin Panel | 72 hours |
| **Erasure** | Delete function | 30 days |
| **Restriction** | Flag in database | 72 hours |
| **Portability** | JSON/CSV export | 30 days |
| **Object** | Opt-out mechanism | 72 hours |

### 4.2. Right of Access (Article 15)

**Process:**
1. Guest/Owner submits request via email to dpo@vestalumina.com
2. Verify identity (email confirmation)
3. Gather all personal data
4. Provide data in common format (PDF/JSON)
5. Include processing information

**Information to Provide:**
```
☐ Categories of personal data
☐ Purpose of processing
☐ Recipients of data
☐ Retention period
☐ Data source (if not from data subject)
☐ Existence of automated decision-making
☐ Right to lodge complaint with supervisory authority
```

### 4.3. Right to Erasure (Article 17)

**Eligibility Conditions:**
```
☐ Data no longer necessary for original purpose
☐ Consent withdrawn
☐ Objection to processing
☐ Unlawful processing
☐ Legal obligation to erase
```

**Exemptions:**
```
☐ Legal obligation to retain (e.g., tax records)
☐ Legal claims defense
☐ Public interest
```

**Erasure Process:**
1. Verify eligibility
2. Check for exemptions
3. Delete from all systems (Firestore, Storage, backups)
4. Notify sub-processors
5. Confirm deletion to data subject

### 4.4. Data Portability (Article 20)

**Export Formats:**
- JSON (machine-readable)
- CSV (spreadsheet compatible)
- PDF (human-readable)

**Data Included:**
```json
{
  "guest_data": {
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+385911234567"
  },
  "bookings": [
    {
      "confirmation": "VL-2026-ABC123",
      "check_in": "2026-02-15",
      "check_out": "2026-02-20",
      "unit": "Apartment Sunset"
    }
  ],
  "chat_history": [...],
  "export_date": "2026-02-20T10:00:00Z"
}
```

---

## 5. Security Measures

### 5.1. Technical Measures

| Measure | Description | Status |
|---------|-------------|--------|
| Encryption in transit | TLS 1.3 | ✅ |
| Encryption at rest | AES-256 | ✅ |
| Access control | RBAC + Firestore rules | ✅ |
| Pseudonymization | Guest IDs | ✅ |
| Logging | Audit trail | ✅ |
| Backup | Daily encrypted | ✅ |

### 5.2. Organizational Measures

| Measure | Description | Status |
|---------|-------------|--------|
| Privacy training | Annual staff training | ✅ |
| Access management | Need-to-know basis | ✅ |
| Incident response | Documented process | ✅ |
| DPO appointed | Contact: dpo@vestalumina.com | ✅ |
| Vendor assessment | Sub-processor vetting | ✅ |

### 5.3. Privacy by Design

```
Implemented Features:
─────────────────────
☐ Data minimization by default
☐ Automatic data deletion
☐ Granular consent options
☐ Privacy settings easily accessible
☐ Secure defaults (no public sharing)
☐ End-to-end encryption for sensitive data
```

---

## 6. Data Processing Agreements

### 6.1. Sub-processors

| Sub-processor | Purpose | Location | DPA |
|---------------|---------|----------|-----|
| Google Cloud (Firebase) | Infrastructure | EU | ✅ |
| Sentry | Error monitoring | EU | ✅ |
| SendGrid | Email delivery | EU | ✅ |
| OpenAI | AI chat | USA (SCCs) | ✅ |

### 6.2. DPA Requirements

```
Required DPA Clauses:
─────────────────────
☐ Subject matter and duration
☐ Nature and purpose of processing
☐ Types of personal data
☐ Categories of data subjects
☐ Obligations and rights of controller
☐ Instructions for processing
☐ Confidentiality
☐ Security measures
☐ Sub-processor requirements
☐ Data subject assistance
☐ Audit rights
☐ Deletion/return upon termination
```

### 6.3. International Transfers

| Destination | Mechanism | Documentation |
|-------------|-----------|---------------|
| USA (OpenAI) | Standard Contractual Clauses | ✅ |
| Other EU | Adequate protection | N/A |

---

## 7. Breach Notification

### 7.1. Breach Categories

| Category | Risk Level | Notification Required |
|----------|------------|----------------------|
| Unauthorized access | High | Supervisory authority + data subjects |
| Accidental disclosure | Medium | Supervisory authority |
| Data loss (with backup) | Low | Internal documentation |

### 7.2. Notification Timeline

```
┌──────────────────────────────────────────────────────────────┐
│                   BREACH NOTIFICATION TIMELINE                │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  Breach Detected                                             │
│       │                                                      │
│       ▼ [Immediately]                                        │
│  Incident Commander notified                                 │
│       │                                                      │
│       ▼ [Within 24 hours]                                    │
│  Risk assessment completed                                   │
│       │                                                      │
│       ▼ [Within 72 hours]                                    │
│  Supervisory authority notified (if required)                │
│       │                                                      │
│       ▼ [Without undue delay]                                │
│  Data subjects notified (if high risk)                       │
│       │                                                      │
│       ▼ [Ongoing]                                            │
│  Documentation and remediation                               │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### 7.3. Breach Documentation

```
Required Documentation:
───────────────────────
☐ Nature of breach
☐ Categories and number of data subjects affected
☐ Categories and number of records affected
☐ Contact point for more information
☐ Likely consequences
☐ Measures taken or proposed
☐ Timeline of events
☐ Root cause analysis
☐ Preventive measures implemented
```

---

## 8. Compliance Checklist

### 8.1. Initial Compliance

```
GOVERNANCE
☐ DPO appointed (if required)
☐ Privacy policy published
☐ Cookie policy published
☐ Internal privacy procedures documented

DATA INVENTORY
☐ Data mapping completed
☐ Lawful basis documented for each processing activity
☐ Retention periods defined
☐ Special category data identified

TECHNICAL MEASURES
☐ Encryption implemented
☐ Access controls configured
☐ Audit logging enabled
☐ Backup procedures tested

DATA SUBJECT RIGHTS
☐ Access request process documented
☐ Erasure request process documented
☐ Portability export available
☐ Consent mechanism implemented

CONTRACTS
☐ DPA with all sub-processors
☐ SCCs for international transfers
☐ Customer DPA template available
```

### 8.2. Ongoing Compliance

**Weekly:**
```
☐ Review access logs for anomalies
☐ Process any data subject requests
☐ Check consent withdrawal requests
```

**Monthly:**
```
☐ Review data retention compliance
☐ Verify automatic deletion functioning
☐ Update sub-processor list if changed
☐ Review security incidents
```

**Quarterly:**
```
☐ DPIA for new processing activities
☐ Privacy training for new staff
☐ Review and update privacy policy
☐ Test data subject request processes
```

**Annually:**
```
☐ Full compliance audit
☐ Update Records of Processing Activities (RoPA)
☐ Review all DPAs
☐ Conduct breach simulation
☐ Update LIAs
☐ Privacy training for all staff
```

### 8.3. Records of Processing Activities (RoPA)

| Field | Example |
|-------|---------|
| Controller name | [Property Owner] |
| Processor name | Vesta Lumina d.o.o. |
| Processing purpose | Guest check-in management |
| Data categories | Identity, contact, booking |
| Data subject categories | Guests |
| Recipients | eVisitor (legal requirement) |
| International transfers | OpenAI (SCCs) |
| Retention period | 30 days (PII), 7 years (booking) |
| Security measures | Encryption, access control |

---

## Appendix A: Privacy Notice Template

```
PRIVACY NOTICE FOR GUESTS
─────────────────────────

Who we are:
[Property Owner Name] uses Vesta Lumina for guest management.

What data we collect:
• Name, date of birth, nationality
• Passport/ID number
• Email and phone number
• Digital signature

Why we collect it:
• Legal requirement (guest registration)
• Contract fulfillment (accommodation)

How long we keep it:
• Guest data: 30 days after checkout
• Booking records: 7 years (legal requirement)

Your rights:
• Access your data
• Correct your data
• Delete your data
• Object to processing
• Data portability

Contact:
[Property Owner Email]
DPO: dpo@vestalumina.com
```

---

## Appendix B: Supervisory Authorities

| Country | Authority | Contact |
|---------|-----------|---------|
| Croatia | AZOP | azop.hr |
| Germany | BfDI | bfdi.bund.de |
| France | CNIL | cnil.fr |
| Italy | Garante | garanteprivacy.it |
| Slovenia | IP-RS | ip-rs.si |

---

<p align="center">
  <strong>VESTA LUMINA GDPR COMPLIANCE</strong><br>
  <em>Checklist Version 2.1.0</em><br><br>
  © 2024-2026 Vesta Lumina d.o.o.
</p>
