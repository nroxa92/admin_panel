# Vesta Lumina System Analysis

> **Version:** 2.1.0  
> **Last Updated:** January 2026  
> **Classification:** Internal Technical Documentation  
> **© 2026 Vesta Lumina. All Rights Reserved.**

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Problem Domain Analysis](#2-problem-domain-analysis)
3. [Requirements Analysis](#3-requirements-analysis)
4. [Technology Selection Analysis](#4-technology-selection-analysis)
5. [Architecture Decisions](#5-architecture-decisions)
6. [Trade-off Analysis](#6-trade-off-analysis)
7. [Risk Assessment](#7-risk-assessment)
8. [Performance Analysis](#8-performance-analysis)
9. [Cost Analysis](#9-cost-analysis)
10. [Competitive Analysis](#10-competitive-analysis)
11. [Future Considerations](#11-future-considerations)
12. [Lessons Learned](#12-lessons-learned)

---

## 1. Executive Summary

This document provides a comprehensive technical analysis of the Vesta Lumina system, documenting key decisions, trade-offs, and rationale behind the architecture and technology choices.

### Key Findings

| Area | Decision | Confidence |
|------|----------|------------|
| Frontend Framework | Flutter | High ✅ |
| Backend Platform | Firebase | High ✅ |
| Database | Firestore (NoSQL) | Medium ⚠️ |
| AI Provider | OpenAI GPT-4 | Medium ⚠️ |
| Deployment Model | Serverless | High ✅ |

### Document Purpose

- Document technical decisions for future reference
- Explain trade-offs to stakeholders
- Guide future development decisions
- Onboard new team members
- Support audit and compliance requirements

---

## 2. Problem Domain Analysis

### 2.1 Industry Context

The vacation rental industry in Croatia and Europe faces several challenges:

```
┌─────────────────────────────────────────────────────────────────┐
│                    INDUSTRY CHALLENGES                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  REGULATORY                    OPERATIONAL                       │
│  ┌─────────────────────┐      ┌─────────────────────┐          │
│  │ • Guest registration│      │ • Manual check-ins  │          │
│  │ • eVisitor (Croatia)│      │ • Key handoffs      │          │
│  │ • GDPR compliance   │      │ • Cleaning coord.   │          │
│  │ • Tax reporting     │      │ • Multi-platform    │          │
│  └─────────────────────┘      └─────────────────────┘          │
│                                                                  │
│  GUEST EXPECTATIONS            OWNER PAIN POINTS                │
│  ┌─────────────────────┐      ┌─────────────────────┐          │
│  │ • Instant info      │      │ • Time consuming    │          │
│  │ • Self-service      │      │ • Multiple tools    │          │
│  │ • 24/7 support      │      │ • No automation     │          │
│  │ • Multilingual      │      │ • Legal complexity  │          │
│  └─────────────────────┘      └─────────────────────┘          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Target User Personas

#### Persona 1: Small Property Owner (Primary)

| Attribute | Value |
|-----------|-------|
| Properties | 1-5 units |
| Technical Level | Low to Medium |
| Primary Need | Simplicity, time-saving |
| Pain Points | Manual tasks, guest communication |
| Budget | €20-50/month per unit |

#### Persona 2: Property Manager (Secondary)

| Attribute | Value |
|-----------|-------|
| Properties | 5-50 units |
| Technical Level | Medium |
| Primary Need | Scalability, team management |
| Pain Points | Coordination, reporting |
| Budget | €15-30/month per unit |

#### Persona 3: Agency/Enterprise (Tertiary)

| Attribute | Value |
|-----------|-------|
| Properties | 50+ units |
| Technical Level | High |
| Primary Need | White-label, analytics |
| Pain Points | Brand consistency, oversight |
| Budget | Custom enterprise pricing |

### 2.3 Use Case Analysis

#### Critical Use Cases (Must Have)

| ID | Use Case | Priority | Complexity |
|----|----------|----------|------------|
| UC-01 | Guest self-check-in | P0 | High |
| UC-02 | House rules display | P0 | Low |
| UC-03 | Booking management | P0 | Medium |
| UC-04 | Cleaning task assignment | P0 | Medium |
| UC-05 | Document scanning (OCR) | P0 | High |

#### Important Use Cases (Should Have)

| ID | Use Case | Priority | Complexity |
|----|----------|----------|------------|
| UC-06 | AI assistant | P1 | High |
| UC-07 | iCal synchronization | P1 | Medium |
| UC-08 | PDF generation | P1 | Medium |
| UC-09 | Multi-language support | P1 | Medium |
| UC-10 | Analytics dashboard | P1 | Medium |

#### Nice-to-Have Use Cases

| ID | Use Case | Priority | Complexity |
|----|----------|----------|------------|
| UC-11 | Smart pricing | P2 | High |
| UC-12 | Direct bookings | P2 | High |
| UC-13 | Mobile owner app | P2 | Medium |
| UC-14 | IoT integration | P3 | High |

---

## 3. Requirements Analysis

### 3.1 Functional Requirements

#### Core System Requirements

```
FR-001: Guest Check-in System
├── FR-001.1: Display welcome screen with booking info
├── FR-001.2: Scan passport/ID via OCR
├── FR-001.3: Extract guest data automatically
├── FR-001.4: Generate guest card PDF
└── FR-001.5: Submit to eVisitor (Croatia)

FR-002: Booking Management
├── FR-002.1: Manual booking creation
├── FR-002.2: iCal import (Airbnb, Booking.com)
├── FR-002.3: Calendar visualization
├── FR-002.4: Conflict detection
└── FR-002.5: Guest notification

FR-003: Cleaning Module
├── FR-003.1: Automatic task creation on checkout
├── FR-003.2: Cleaner assignment
├── FR-003.3: Checklist completion
├── FR-003.4: Photo documentation
└── FR-003.5: Task verification
```

### 3.2 Non-Functional Requirements

| Requirement | Target | Measurement |
|-------------|--------|-------------|
| **Availability** | 99.9% uptime | Monthly monitoring |
| **Response Time** | < 200ms API | P95 latency |
| **Page Load** | < 2s | Lighthouse score |
| **Concurrent Users** | 10,000 | Load testing |
| **Data Retention** | Per GDPR | Automated cleanup |
| **Backup** | Daily | Automated |
| **Recovery** | < 4 hours RPO | Disaster recovery |

### 3.3 Constraint Analysis

#### Technical Constraints

| Constraint | Impact | Mitigation |
|------------|--------|------------|
| Firebase vendor lock-in | High | Abstraction layers |
| Android-only tablets | Medium | Web fallback option |
| No offline booking sync | Medium | Queue system |
| OpenAI rate limits | Low | Caching, fallbacks |

#### Business Constraints

| Constraint | Impact | Mitigation |
|------------|--------|------------|
| Small team (2-3 devs) | High | Firebase automation |
| Limited budget | High | Serverless model |
| Fast time-to-market | High | Flutter code sharing |
| EU data residency | Medium | Frankfurt region |

---

## 4. Technology Selection Analysis

### 4.1 Frontend Framework Analysis

#### Options Considered

| Framework | Pros | Cons | Score |
|-----------|------|------|-------|
| **Flutter** | Single codebase, fast dev, great UI | Large app size, newer | 8.5/10 |
| React Native | Large ecosystem, JS | Performance, bridge | 7/10 |
| Native (Kotlin + Swift) | Best performance | 2x development | 6/10 |
| PWA | No app install | Limited device access | 5/10 |

#### Decision: Flutter

**Rationale:**
1. **Code Sharing**: 95% code shared between web and mobile
2. **Development Speed**: 2x faster than native
3. **UI Quality**: Consistent, beautiful UI across platforms
4. **Team Skills**: Existing Dart expertise
5. **Performance**: Near-native performance (60fps)

**Trade-offs Accepted:**
- Larger app size (~15MB vs ~5MB native)
- Smaller talent pool than React Native
- Some platform-specific code needed

### 4.2 Backend Platform Analysis

#### Options Considered

| Platform | Pros | Cons | Score |
|----------|------|------|-------|
| **Firebase** | Serverless, real-time, scaling | Vendor lock-in | 8.5/10 |
| AWS Amplify | Flexible, mature | Complex setup | 7.5/10 |
| Supabase | Open source, PostgreSQL | Newer, smaller ecosystem | 7/10 |
| Custom (Node + PostgreSQL) | Full control | Ops overhead | 6/10 |

#### Decision: Firebase

**Rationale:**
1. **Serverless**: Zero infrastructure management
2. **Real-time**: Built-in Firestore real-time sync
3. **Scaling**: Automatic scaling to millions
4. **Cost**: Pay-per-use, low initial cost
5. **Integration**: Native Flutter SDK
6. **Speed**: Fast development with pre-built services

**Trade-offs Accepted:**
- Vendor lock-in to Google
- NoSQL limitations (see Database section)
- Limited querying capabilities
- Egress costs at scale

### 4.3 Database Analysis

#### Options Considered

| Database | Pros | Cons | Score |
|----------|------|------|-------|
| **Firestore** | Real-time, serverless | NoSQL limitations | 7.5/10 |
| PostgreSQL | Powerful queries, relations | Ops overhead | 8/10 |
| MongoDB | Flexible schema | Self-managed | 7/10 |
| DynamoDB | AWS native | Complex pricing | 6.5/10 |

#### Decision: Firestore (with caveats)

**Rationale:**
1. **Integration**: Native Firebase integration
2. **Real-time**: Built-in real-time sync
3. **Offline**: Automatic offline support
4. **Scaling**: Automatic sharding
5. **Security**: Declarative security rules

**Trade-offs Accepted:**
- No JOINs (denormalization required)
- Limited aggregation (count, sum)
- Complex queries need composite indexes
- Higher read costs for complex queries

**Mitigation Strategies:**
```
Problem: No JOINs
Solution: Denormalize data, duplicate where needed
Example: Store owner name in booking document

Problem: Limited aggregation
Solution: Cloud Functions for aggregations
Example: calculateMonthlyStats() function

Problem: Complex queries
Solution: Composite indexes + algolia for search
Example: Pre-built index for date + unit + status
```

### 4.4 AI Provider Analysis

#### Options Considered

| Provider | Pros | Cons | Score |
|----------|------|------|-------|
| **OpenAI GPT-4** | Best quality, easy API | Cost, dependency | 8/10 |
| Claude (Anthropic) | Good quality, longer context | Newer API | 7.5/10 |
| Google Gemini | Firebase integration | Quality inconsistent | 7/10 |
| Self-hosted (Llama) | No API costs, privacy | Ops complexity | 5/10 |

#### Decision: OpenAI GPT-4

**Rationale:**
1. **Quality**: Best conversational AI quality
2. **Multilingual**: Excellent 11-language support
3. **API Stability**: Mature, well-documented API
4. **Function Calling**: Native tool/function support
5. **Speed**: Fast response times

**Trade-offs Accepted:**
- External dependency
- Per-token costs
- Data sent to OpenAI (privacy consideration)
- Potential for model changes

**Mitigation:**
- Provider abstraction layer
- Response caching for common queries
- GDPR-compliant data handling
- Fallback to Google Gemini if needed

---

## 5. Architecture Decisions

### 5.1 Architecture Decision Records (ADRs)

#### ADR-001: Monorepo vs Multi-repo

| Aspect | Decision |
|--------|----------|
| **Status** | Accepted |
| **Decision** | Multi-repo (separate repos for tablet, admin, functions) |
| **Context** | Need to manage multiple applications with different release cycles |
| **Consequences** | + Independent deployments, + Clear boundaries, - Code duplication for shared components |

#### ADR-002: State Management

| Aspect | Decision |
|--------|----------|
| **Status** | Accepted |
| **Decision** | Riverpod 2.0 |
| **Context** | Need reactive state management with good testability |
| **Alternatives** | BLoC, Provider, GetX |
| **Consequences** | + Type-safe, + Testable, + Compile-time errors, - Learning curve |

#### ADR-003: API Design

| Aspect | Decision |
|--------|----------|
| **Status** | Accepted |
| **Decision** | Firebase callable functions (not REST) |
| **Context** | Need authenticated API calls with minimal boilerplate |
| **Consequences** | + Auto-auth, + Type safety, - Not standard REST, - Firebase lock-in |

#### ADR-004: Offline Strategy

| Aspect | Decision |
|--------|----------|
| **Status** | Accepted |
| **Decision** | Firestore offline persistence + Hive for local data |
| **Context** | Tablets must work with intermittent connectivity |
| **Consequences** | + Robust offline, + Automatic sync, - Conflict resolution complexity |

#### ADR-005: Multi-tenancy Model

| Aspect | Decision |
|--------|----------|
| **Status** | Accepted |
| **Decision** | Shared database with tenant isolation via security rules |
| **Context** | Need to support multiple organizations in single deployment |
| **Alternatives** | Separate databases per tenant |
| **Consequences** | + Lower cost, + Simpler ops, - Complex security rules, - Noisy neighbor risk |

### 5.2 Data Model Decisions

#### Denormalization Strategy

```
TRADITIONAL RELATIONAL:                FIRESTORE DENORMALIZED:
                                       
┌─────────────┐    ┌─────────────┐    ┌─────────────────────────────┐
│   Booking   │    │    Unit     │    │         Booking             │
├─────────────┤    ├─────────────┤    ├─────────────────────────────┤
│ booking_id  │    │ unit_id     │    │ booking_id                  │
│ unit_id  ───┼───►│ name        │    │ unit_id                     │
│ guest_name  │    │ owner_id    │    │ unit_name (denormalized)    │
│ check_in    │    └─────────────┘    │ owner_id (denormalized)     │
└─────────────┘                       │ guest_name                  │
      │                               │ check_in                    │
      │ JOIN required                 └─────────────────────────────┘
      ▼                                        │
 More queries                           Single read = all data
```

#### Document Size Limits

| Collection | Avg Doc Size | Max Doc Size | Strategy |
|------------|--------------|--------------|----------|
| users | 2 KB | 10 KB | Single doc |
| units | 5 KB | 20 KB | Single doc |
| bookings | 3 KB | 15 KB | Single doc |
| cleaning_logs | 10 KB | 50 KB | Subcollection for photos |
| ai_conversations | Variable | 100 KB | Pagination |

---

## 6. Trade-off Analysis

### 6.1 Speed vs. Quality

| Decision | Speed Gained | Quality Impact | Verdict |
|----------|--------------|----------------|---------|
| Firebase over custom backend | +6 months | -10% flexibility | ✅ Accept |
| Flutter over native | +4 months | -5% performance | ✅ Accept |
| NoSQL over SQL | +2 months | -15% query power | ⚠️ Monitor |
| OpenAI over self-hosted | +3 months | +30% quality | ✅ Accept |

### 6.2 Cost vs. Capability

| Decision | Monthly Cost | Capability Gained | ROI |
|----------|--------------|-------------------|-----|
| Firebase Blaze plan | ~$200 | Full features | High |
| OpenAI API | ~$150 | AI assistant | High |
| Sentry monitoring | ~$30 | Error tracking | Medium |
| SendGrid email | ~$20 | Transactional email | High |

### 6.3 Security vs. Usability

| Decision | Security Level | Usability Impact | Balance |
|----------|----------------|------------------|---------|
| PIN for cleaners | Medium | Easy login | ✅ Good |
| Email/password for owners | High | Standard UX | ✅ Good |
| Token for tablets | High | Seamless | ✅ Good |
| 2FA for super admins | Very High | Extra step | ✅ Appropriate |

### 6.4 Consistency vs. Availability

Following CAP theorem, our choices:

| Scenario | Priority | Trade-off |
|----------|----------|-----------|
| Booking creation | Consistency | Wait for confirmation |
| Dashboard stats | Availability | Eventually consistent (5 min) |
| Guest check-in | Availability | Offline-first, sync later |
| Payment processing | Consistency | Synchronous confirmation |

---

## 7. Risk Assessment

### 7.1 Technical Risks

| Risk | Probability | Impact | Mitigation | Owner |
|------|-------------|--------|------------|-------|
| Firebase outage | Low | High | Multi-region, offline mode | DevOps |
| OpenAI API changes | Medium | Medium | Abstraction layer, fallback | Backend |
| Data breach | Low | Critical | Encryption, security audits | Security |
| Performance degradation | Medium | Medium | Monitoring, caching | Backend |
| Dependency vulnerabilities | Medium | Medium | Automated scanning | DevOps |

### 7.2 Business Risks

| Risk | Probability | Impact | Mitigation | Owner |
|------|-------------|--------|------------|-------|
| Competitor feature parity | High | Medium | Continuous innovation | Product |
| Regulation changes | Medium | High | Modular compliance layer | Legal |
| Key person dependency | Medium | High | Documentation, cross-training | HR |
| Pricing pressure | Medium | Medium | Value differentiation | Sales |

### 7.3 Risk Matrix

```
              │ Low Impact │ Med Impact │ High Impact │ Critical  │
──────────────┼────────────┼────────────┼─────────────┼───────────┤
High Prob     │            │ Competitor │             │           │
              │            │            │             │           │
──────────────┼────────────┼────────────┼─────────────┼───────────┤
Medium Prob   │            │ OpenAI API │ Regulations │           │
              │            │ Perf degr. │ Key person  │           │
──────────────┼────────────┼────────────┼─────────────┼───────────┤
Low Prob      │            │            │ Firebase    │ Data      │
              │            │            │ outage      │ breach    │
──────────────┼────────────┼────────────┼─────────────┼───────────┤
```

---

## 8. Performance Analysis

### 8.1 Current Metrics

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| API P50 Latency | < 100ms | 85ms | ✅ |
| API P95 Latency | < 200ms | 175ms | ✅ |
| API P99 Latency | < 500ms | 420ms | ✅ |
| Web LCP | < 2.5s | 2.1s | ✅ |
| Web FID | < 100ms | 45ms | ✅ |
| Web CLS | < 0.1 | 0.05 | ✅ |
| Mobile Cold Start | < 3s | 2.8s | ✅ |
| Firestore Read/Write | < 50ms | 35ms | ✅ |

### 8.2 Bottleneck Analysis

```
Request Flow with Timing:
                                                          
┌─────────┐  50ms  ┌─────────┐  35ms  ┌─────────┐  20ms  ┌─────────┐
│ Client  │───────►│ CDN/    │───────►│ Cloud   │───────►│Firestore│
│ Request │        │ Hosting │        │Function │        │ Query   │
└─────────┘        └─────────┘        └─────────┘        └─────────┘
                                           │
                                           │ 80ms (if AI)
                                           ▼
                                      ┌─────────┐
                                      │ OpenAI  │
                                      │   API   │
                                      └─────────┘

Total P95: 175ms (without AI), 350ms (with AI)
```

### 8.3 Optimization Opportunities

| Opportunity | Effort | Impact | Priority |
|-------------|--------|--------|----------|
| CDN caching for static | Low | Medium | P1 |
| Firestore composite indexes | Low | High | P0 |
| AI response caching | Medium | High | P1 |
| Image lazy loading | Low | Medium | P2 |
| Bundle size reduction | Medium | Medium | P2 |

---

## 9. Cost Analysis

### 9.1 Infrastructure Costs (Monthly)

| Service | Small (10 units) | Medium (100 units) | Large (1000 units) |
|---------|------------------|--------------------|--------------------|
| Firestore | $5 | $30 | $200 |
| Cloud Functions | $5 | $25 | $150 |
| Cloud Storage | $2 | $15 | $100 |
| Firebase Hosting | $0 | $5 | $25 |
| Firebase Auth | $0 | $0 | $50 |
| **Subtotal Firebase** | **$12** | **$75** | **$525** |
| OpenAI API | $20 | $80 | $400 |
| SendGrid | $0 | $20 | $50 |
| Sentry | $0 | $30 | $80 |
| **Total** | **$32** | **$205** | **$1,055** |

### 9.2 Cost Per Unit Analysis

| Scale | Total Cost | Cost/Unit | Gross Margin Target |
|-------|------------|-----------|---------------------|
| 10 units | $32 | $3.20 | 85% (price: $21/unit) |
| 100 units | $205 | $2.05 | 90% (price: $20/unit) |
| 1000 units | $1,055 | $1.06 | 93% (price: $15/unit) |

### 9.3 Development Cost Analysis

| Phase | Duration | Team Size | Cost Estimate |
|-------|----------|-----------|---------------|
| MVP (v1.0) | 6 months | 2 devs | €80,000 |
| Enhancement (v2.0) | 4 months | 3 devs | €70,000 |
| Current (v2.1) | 2 months | 2 devs | €25,000 |
| **Total to Date** | **12 months** | - | **€175,000** |

---

## 10. Competitive Analysis

### 10.1 Market Landscape

| Competitor | Focus | Strengths | Weaknesses |
|------------|-------|-----------|------------|
| Guesty | Enterprise | Full PMS, integrations | Expensive, complex |
| Hostaway | Mid-market | Channel manager | No tablet solution |
| Lodgify | Small owners | Website builder | Limited automation |
| **Vesta Lumina** | **All segments** | **Tablet + AI, local focus** | **Newer entrant** |

### 10.2 Feature Comparison

| Feature | Vesta Lumina | Guesty | Hostaway | Lodgify |
|---------|:------------:|:------:|:--------:|:-------:|
| Guest Tablet | ✅ | ❌ | ❌ | ❌ |
| AI Assistant | ✅ | 🔄 | ❌ | ❌ |
| OCR Check-in | ✅ | ❌ | ❌ | ❌ |
| iCal Sync | ✅ | ✅ | ✅ | ✅ |
| Cleaning Module | ✅ | ✅ | ✅ | ❌ |
| Direct Bookings | 🔄 | ✅ | ✅ | ✅ |
| Channel Manager | 🔄 | ✅ | ✅ | ❌ |
| Croatian Localization | ✅ | ❌ | ❌ | ❌ |
| eVisitor Integration | ✅ | ❌ | ❌ | ❌ |
| White-label | ✅ | ✅ | ❌ | ❌ |

Legend: ✅ Available | 🔄 Planned | ❌ Not Available

### 10.3 Competitive Advantages

1. **Only solution with in-unit guest tablet**
2. **AI-powered concierge in 11 languages**
3. **Deep Croatian/regional market focus**
4. **eVisitor integration built-in**
5. **Lower price point than enterprise solutions**

---

## 11. Future Considerations

### 11.1 Technical Roadmap

```
2026 Q1          2026 Q2          2026 Q3          2026 Q4
    │                │                │                │
    ▼                ▼                ▼                ▼
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│ v2.2.0  │     │ v2.3.0  │     │ v3.0.0  │     │ v3.1.0  │
│         │     │         │     │         │     │         │
│ Smart   │     │ Mobile  │     │ Channel │     │ IoT     │
│ Pricing │     │ Apps    │     │ Manager │     │ Integ.  │
│         │     │ (iOS/   │     │         │     │         │
│ Revenue │     │ Android)│     │ Direct  │     │ Smart   │
│ Dash    │     │         │     │ Booking │     │ Locks   │
└─────────┘     └─────────┘     └─────────┘     └─────────┘
```

### 11.2 Scalability Considerations

| Current Limit | Threshold | Action Required |
|---------------|-----------|-----------------|
| Firestore reads | 1M/day | Sharding strategy |
| Cloud Functions | 1000 concurrent | Increase quota |
| OpenAI tokens | 90K/min | Caching layer |
| Single tenant DB | 10K properties | Multi-region |

### 11.3 Technology Watch

| Technology | Potential Use | Timeline |
|------------|---------------|----------|
| Edge Functions | Reduce latency | 2026 |
| WebAssembly | Performance | 2026-2027 |
| Local LLMs | Privacy, cost | 2026-2027 |
| Blockchain | Guest identity | 2027+ |

---

## 12. Lessons Learned

### 12.1 What Worked Well

| Decision | Why It Worked |
|----------|---------------|
| Flutter for both platforms | 70% faster development |
| Firebase serverless | Zero ops overhead |
| Riverpod state management | Excellent testability |
| Feature-based architecture | Easy team scaling |
| AI-first approach | Strong differentiator |

### 12.2 What Could Be Improved

| Issue | Impact | Recommendation |
|-------|--------|----------------|
| NoSQL limitations | Complex reporting | Consider read replicas to SQL |
| Large initial bundle | 3s cold start | Code splitting |
| Vendor lock-in | Migration risk | Abstraction layers |
| Test coverage | 65% coverage | Increase to 80% |

### 12.3 Recommendations for Future

1. **Invest in abstraction layers** for easier provider switching
2. **Improve monitoring** with custom business metrics
3. **Consider hybrid database** (Firestore + PostgreSQL for analytics)
4. **Increase test coverage** before v3.0 release
5. **Document architecture decisions** immediately (this document!)

---

## Document Information

| Property | Value |
|----------|-------|
| Document ID | SYSAN-001 |
| Version | 2.1.0 |
| Last Updated | January 2026 |
| Author | Vesta Lumina Engineering Team |
| Classification | Internal Technical |

---

**© 2026 Vesta Lumina. All Rights Reserved.**

*This document contains proprietary technical analysis. Unauthorized distribution is prohibited.*
