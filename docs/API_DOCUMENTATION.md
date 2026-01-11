# VESTA LUMINA API DOCUMENTATION
## Cloud Functions & Firestore API Reference

**Version:** 2.1.0  
**Last Updated:** January 2026  
**Base URL:** `https://europe-west3-vestalumina.cloudfunctions.net`

---

## ⚠️ PROPRIETARY - CONFIDENTIAL

```
This documentation is confidential and proprietary to Vesta Lumina d.o.o.
Unauthorized distribution or use is strictly prohibited.
```

---

## Table of Contents

1. [Authentication](#1-authentication)
2. [Cloud Functions API](#2-cloud-functions-api)
3. [Firestore Data Models](#3-firestore-data-models)
4. [Real-time Subscriptions](#4-real-time-subscriptions)
5. [Error Handling](#5-error-handling)
6. [Rate Limits](#6-rate-limits)
7. [Webhooks](#7-webhooks)

---

## 1. Authentication

### 1.1. Authentication Methods

| Method | Use Case | Token Type |
|--------|----------|------------|
| Firebase Auth (Email/Password) | Admin Panel users | ID Token |
| Firebase Auth (Custom Token) | Tablet terminals | Custom Token |
| API Key | Partner integrations | API Key Header |
| Anonymous Auth | Guest check-in | Anonymous Token |

### 1.2. Token Structure

```json
{
  "uid": "user_abc123",
  "email": "owner@example.com",
  "ownerId": "owner_xyz789",
  "role": "owner",
  "permissions": ["read", "write", "delete"],
  "iat": 1704067200,
  "exp": 1704153600
}
```

### 1.3. Custom Claims

| Claim | Type | Description |
|-------|------|-------------|
| `ownerId` | string | Owner document ID for data isolation |
| `role` | string | User role: `super_admin`, `brand_admin`, `owner`, `cleaner` |
| `brandId` | string | White-label brand ID (if applicable) |
| `permissions` | array | Granular permissions array |

### 1.4. Authentication Headers

```http
Authorization: Bearer <firebase_id_token>
X-API-Key: <partner_api_key>
Content-Type: application/json
```

---

## 2. Cloud Functions API

### 2.1. Booking Functions

#### `createBooking`
Creates a new booking for a unit.

```http
POST /createBooking
```

**Request Body:**
```json
{
  "unitId": "unit_abc123",
  "checkIn": "2026-02-15",
  "checkOut": "2026-02-20",
  "guestName": "John Doe",
  "guestEmail": "john@example.com",
  "guestPhone": "+385911234567",
  "adults": 2,
  "children": 1,
  "totalPrice": 750.00,
  "currency": "EUR",
  "source": "direct",
  "notes": "Late arrival expected"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "bookingId": "booking_xyz789",
  "confirmationCode": "VL-2026-ABC123",
  "message": "Booking created successfully"
}
```

**Error Responses:**
| Code | Description |
|------|-------------|
| 400 | Invalid request body |
| 401 | Unauthorized |
| 409 | Booking conflict (dates overlap) |
| 500 | Internal server error |

---

#### `updateBooking`
Updates an existing booking.

```http
PUT /updateBooking
```

**Request Body:**
```json
{
  "bookingId": "booking_xyz789",
  "updates": {
    "checkOut": "2026-02-22",
    "totalPrice": 900.00,
    "notes": "Extended stay"
  }
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "bookingId": "booking_xyz789",
  "message": "Booking updated successfully"
}
```

---

#### `cancelBooking`
Cancels a booking.

```http
POST /cancelBooking
```

**Request Body:**
```json
{
  "bookingId": "booking_xyz789",
  "reason": "Guest request",
  "refundAmount": 500.00
}
```

---

#### `getBookingsByDateRange`
Retrieves bookings within a date range.

```http
GET /getBookingsByDateRange?unitId={unitId}&startDate={date}&endDate={date}
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| unitId | string | Yes | Unit document ID |
| startDate | string | Yes | Start date (YYYY-MM-DD) |
| endDate | string | Yes | End date (YYYY-MM-DD) |
| status | string | No | Filter by status |

**Response (200 OK):**
```json
{
  "success": true,
  "bookings": [
    {
      "id": "booking_xyz789",
      "checkIn": "2026-02-15",
      "checkOut": "2026-02-20",
      "guestName": "John Doe",
      "status": "confirmed",
      "checkedIn": false
    }
  ],
  "total": 1
}
```

---

### 2.2. Guest Functions

#### `processCheckin`
Processes guest check-in from tablet terminal.

```http
POST /processCheckin
```

**Request Body:**
```json
{
  "bookingId": "booking_xyz789",
  "guests": [
    {
      "firstName": "John",
      "lastName": "Doe",
      "dateOfBirth": "1985-03-15",
      "nationality": "HR",
      "documentType": "ID_CARD",
      "documentNumber": "123456789",
      "documentExpiry": "2028-05-20",
      "isMainGuest": true
    },
    {
      "firstName": "Jane",
      "lastName": "Doe",
      "dateOfBirth": "1988-07-22",
      "nationality": "HR",
      "documentType": "ID_CARD",
      "documentNumber": "987654321",
      "documentExpiry": "2027-11-10",
      "isMainGuest": false
    }
  ],
  "signatureData": "base64_encoded_png",
  "acceptedRules": true,
  "acceptedAt": "2026-02-15T14:30:00Z"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "checkinId": "checkin_abc123",
  "wifiCredentials": {
    "ssid": "Guest_WiFi",
    "password": "welcome123"
  },
  "message": "Check-in completed successfully"
}
```

---

#### `processOCR`
Processes OCR scan from document image.

```http
POST /processOCR
```

**Request Body:**
```json
{
  "imageData": "base64_encoded_image",
  "documentType": "ID_CARD",
  "country": "HR"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "extractedData": {
    "firstName": "JOHN",
    "lastName": "DOE",
    "dateOfBirth": "1985-03-15",
    "documentNumber": "123456789",
    "expiryDate": "2028-05-20",
    "nationality": "HRV",
    "sex": "M"
  },
  "confidence": 0.95,
  "rawText": "..."
}
```

---

#### `exportGuestData` (GDPR)
Exports all guest data for GDPR compliance.

```http
POST /exportGuestData
```

**Request Body:**
```json
{
  "guestEmail": "john@example.com",
  "format": "json"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "downloadUrl": "https://storage.../export_abc123.json",
  "expiresAt": "2026-02-16T14:30:00Z"
}
```

---

#### `deleteGuestData` (GDPR)
Deletes all guest data for GDPR compliance.

```http
POST /deleteGuestData
```

**Request Body:**
```json
{
  "guestEmail": "john@example.com",
  "confirmDeletion": true
}
```

---

### 2.3. PDF Generation Functions

#### `generatePDF`
Generates various PDF documents.

```http
POST /generatePDF
```

**Request Body:**
```json
{
  "type": "booking_confirmation",
  "bookingId": "booking_xyz789",
  "language": "hr",
  "options": {
    "includeQR": true,
    "includeMap": false
  }
}
```

**PDF Types:**
| Type | Description |
|------|-------------|
| `booking_confirmation` | Booking confirmation for guest |
| `house_rules` | House rules document |
| `guest_registration` | eVisitor format registration |
| `cleaning_checklist` | Cleaner task list |
| `invoice` | Payment invoice |
| `receipt` | Payment receipt |
| `key_handover` | Key collection form |
| `damage_report` | Property damage documentation |
| `monthly_report` | Owner analytics summary |
| `gdpr_export` | Guest data export |

**Response (200 OK):**
```json
{
  "success": true,
  "pdfUrl": "https://storage.../document_abc123.pdf",
  "expiresAt": "2026-02-16T14:30:00Z"
}
```

---

### 2.4. Integration Functions

#### `syncIcal`
Imports bookings from iCal feed.

```http
POST /syncIcal
```

**Request Body:**
```json
{
  "unitId": "unit_abc123",
  "icalUrl": "https://www.airbnb.com/calendar/ical/12345.ics",
  "source": "airbnb"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "imported": 5,
  "updated": 2,
  "skipped": 1,
  "errors": []
}
```

---

#### `sendPushNotification`
Sends push notification to device.

```http
POST /sendPushNotification
```

**Request Body:**
```json
{
  "targetUserId": "user_abc123",
  "title": "New Booking",
  "body": "You have a new booking for Feb 15-20",
  "data": {
    "type": "new_booking",
    "bookingId": "booking_xyz789"
  }
}
```

---

### 2.5. Tablet Terminal Functions

#### `generateAccessCode`
Creates tablet pairing code.

```http
POST /generateAccessCode
```

**Request Body:**
```json
{
  "unitId": "unit_abc123",
  "validityHours": 24
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "accessCode": "ABC123",
  "expiresAt": "2026-02-16T14:30:00Z"
}
```

---

#### `validateAccessCode`
Validates tablet pairing code.

```http
POST /validateAccessCode
```

**Request Body:**
```json
{
  "accessCode": "ABC123",
  "deviceId": "device_xyz789"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "unitId": "unit_abc123",
  "ownerId": "owner_xyz789",
  "customToken": "firebase_custom_token_here"
}
```

---

#### `revokeAccess`
Revokes tablet access.

```http
POST /revokeAccess
```

**Request Body:**
```json
{
  "terminalId": "terminal_abc123",
  "reason": "Device replaced"
}
```

---

### 2.6. AI Chatbot Functions

#### `chatbotWebhook`
Handles AI chatbot messages.

```http
POST /chatbotWebhook
```

**Request Body:**
```json
{
  "unitId": "unit_abc123",
  "sessionId": "session_xyz789",
  "message": "What is the WiFi password?",
  "language": "en"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "response": "The WiFi network name is 'Guest_WiFi' and the password is 'welcome123'.",
  "sessionId": "session_xyz789",
  "suggestedActions": [
    "Show house rules",
    "Contact owner"
  ]
}
```

---

### 2.7. Cleaning Functions

#### `submitCleaningLog`
Submits cleaning completion log.

```http
POST /submitCleaningLog
```

**Request Body:**
```json
{
  "unitId": "unit_abc123",
  "cleanerId": "cleaner_xyz789",
  "checklistItems": [
    {"item": "bedroom_clean", "completed": true},
    {"item": "bathroom_clean", "completed": true},
    {"item": "kitchen_clean", "completed": true},
    {"item": "linens_changed", "completed": true}
  ],
  "photos": [
    "base64_photo_1",
    "base64_photo_2"
  ],
  "issues": [],
  "notes": "All clean, no issues found",
  "duration": 75
}
```

---

### 2.8. Report Functions

#### `generateReport`
Generates analytics report.

```http
POST /generateReport
```

**Request Body:**
```json
{
  "type": "monthly_summary",
  "dateRange": {
    "start": "2026-01-01",
    "end": "2026-01-31"
  },
  "unitIds": ["unit_abc123", "unit_def456"],
  "format": "pdf"
}
```

**Report Types:**
| Type | Description |
|------|-------------|
| `monthly_summary` | Monthly overview with key metrics |
| `occupancy` | Occupancy rate analysis |
| `revenue` | Revenue breakdown |
| `guest_demographics` | Guest nationality/source analysis |
| `cleaning_performance` | Cleaner efficiency metrics |

---

## 3. Firestore Data Models

### 3.1. Owner Document

```
/owners/{ownerId}
```

```json
{
  "email": "owner@example.com",
  "displayName": "John Owner",
  "phone": "+385911234567",
  "company": "Apartments d.o.o.",
  "taxId": "12345678901",
  "address": {
    "street": "Ulica 123",
    "city": "Zagreb",
    "postalCode": "10000",
    "country": "HR"
  },
  "subscription": {
    "plan": "professional",
    "status": "active",
    "validUntil": "2027-01-15T00:00:00Z"
  },
  "settings": {
    "language": "hr",
    "timezone": "Europe/Zagreb",
    "currency": "EUR",
    "notifications": {
      "email": true,
      "push": true,
      "sms": false
    }
  },
  "createdAt": "2025-05-01T10:00:00Z",
  "updatedAt": "2026-01-10T15:30:00Z"
}
```

### 3.2. Unit Document

```
/owners/{ownerId}/units/{unitId}
```

```json
{
  "name": "Apartment Sunset",
  "type": "apartment",
  "address": {
    "street": "Obala 45",
    "city": "Split",
    "postalCode": "21000",
    "country": "HR",
    "coordinates": {
      "lat": 43.5081,
      "lng": 16.4402
    }
  },
  "capacity": {
    "maxGuests": 6,
    "bedrooms": 2,
    "beds": 3,
    "bathrooms": 1
  },
  "amenities": ["wifi", "ac", "parking", "tv"],
  "wifi": {
    "ssid": "Guest_WiFi",
    "password": "welcome123"
  },
  "checkInTime": "15:00",
  "checkOutTime": "10:00",
  "status": "active",
  "createdAt": "2025-06-15T10:00:00Z"
}
```

### 3.3. Booking Document

```
/owners/{ownerId}/units/{unitId}/bookings/{bookingId}
```

```json
{
  "confirmationCode": "VL-2026-ABC123",
  "checkIn": "2026-02-15",
  "checkOut": "2026-02-20",
  "nights": 5,
  "guestName": "John Doe",
  "guestEmail": "john@example.com",
  "guestPhone": "+385911234567",
  "adults": 2,
  "children": 1,
  "totalPrice": 750.00,
  "currency": "EUR",
  "source": "airbnb",
  "externalId": "HMABCD123",
  "status": "confirmed",
  "checkedIn": false,
  "checkedInAt": null,
  "guests": [
    {
      "firstName": "John",
      "lastName": "Doe",
      "dateOfBirth": "1985-03-15",
      "nationality": "HR",
      "documentType": "ID_CARD",
      "documentNumber": "123456789",
      "isMainGuest": true
    }
  ],
  "signatureUrl": "https://storage.../signature_abc123.png",
  "notes": "Late arrival expected",
  "createdAt": "2026-01-20T10:00:00Z",
  "updatedAt": "2026-02-15T14:30:00Z"
}
```

### 3.4. House Rules Document

```
/owners/{ownerId}/units/{unitId}/house_rules
```

```json
{
  "rules": {
    "en": [
      "No smoking inside the apartment",
      "Quiet hours: 22:00 - 08:00",
      "No parties or events",
      "Maximum 6 guests allowed"
    ],
    "hr": [
      "Zabranjeno pušenje u apartmanu",
      "Vrijeme mira: 22:00 - 08:00",
      "Zabranjena organizacija zabava",
      "Maksimalno 6 gostiju"
    ]
  },
  "mandatoryAcceptance": true,
  "signatureRequired": true,
  "updatedAt": "2026-01-10T10:00:00Z"
}
```

### 3.5. Cleaning Log Document

```
/owners/{ownerId}/cleaning_logs/{logId}
```

```json
{
  "unitId": "unit_abc123",
  "cleanerId": "cleaner_xyz789",
  "cleanerName": "Ana Cleaner",
  "bookingId": "booking_xyz789",
  "status": "completed",
  "startedAt": "2026-02-15T11:00:00Z",
  "completedAt": "2026-02-15T12:15:00Z",
  "duration": 75,
  "checklist": [
    {"item": "bedroom_clean", "completed": true},
    {"item": "bathroom_clean", "completed": true},
    {"item": "kitchen_clean", "completed": true},
    {"item": "linens_changed", "completed": true}
  ],
  "photos": [
    "https://storage.../photo1.jpg",
    "https://storage.../photo2.jpg"
  ],
  "issues": [],
  "notes": "All clean"
}
```

### 3.6. Terminal Document

```
/owners/{ownerId}/terminals/{terminalId}
```

```json
{
  "unitId": "unit_abc123",
  "deviceId": "device_xyz789",
  "deviceModel": "Samsung Galaxy Tab A8",
  "androidVersion": "13",
  "appVersion": "3.0.0",
  "status": "active",
  "lastSeen": "2026-02-15T14:30:00Z",
  "pairedAt": "2025-12-01T10:00:00Z"
}
```

---

## 4. Real-time Subscriptions

### 4.1. Firestore Listeners

#### Booking Updates
```dart
FirebaseFirestore.instance
  .collection('owners')
  .doc(ownerId)
  .collection('units')
  .doc(unitId)
  .collection('bookings')
  .where('checkIn', isGreaterThanOrEqualTo: startDate)
  .snapshots()
  .listen((snapshot) {
    // Handle booking updates
  });
```

#### Terminal Status
```dart
FirebaseFirestore.instance
  .collection('owners')
  .doc(ownerId)
  .collection('terminals')
  .snapshots()
  .listen((snapshot) {
    // Handle terminal status updates
  });
```

---

## 5. Error Handling

### 5.1. Error Response Format

```json
{
  "success": false,
  "error": {
    "code": "BOOKING_CONFLICT",
    "message": "The selected dates overlap with an existing booking",
    "details": {
      "conflictingBookingId": "booking_abc123",
      "conflictDates": ["2026-02-16", "2026-02-17"]
    }
  }
}
```

### 5.2. Error Codes

| Code | HTTP | Description |
|------|------|-------------|
| `INVALID_REQUEST` | 400 | Malformed request body |
| `UNAUTHORIZED` | 401 | Invalid or missing authentication |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `BOOKING_CONFLICT` | 409 | Date overlap with existing booking |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests |
| `INTERNAL_ERROR` | 500 | Server error |
| `SERVICE_UNAVAILABLE` | 503 | Temporary unavailability |

---

## 6. Rate Limits

### 6.1. Default Limits

| Endpoint Category | Requests/min | Requests/hour |
|-------------------|--------------|---------------|
| Read operations | 300 | 10,000 |
| Write operations | 60 | 1,000 |
| PDF generation | 10 | 100 |
| OCR processing | 20 | 200 |
| iCal sync | 5 | 50 |

### 6.2. Partner API Limits

| Tier | Requests/min | Requests/day |
|------|--------------|--------------|
| Silver | 60 | 10,000 |
| Gold | 120 | 50,000 |
| Platinum | 300 | 200,000 |
| Diamond | Unlimited | Unlimited |

### 6.3. Rate Limit Headers

```http
X-RateLimit-Limit: 300
X-RateLimit-Remaining: 245
X-RateLimit-Reset: 1704067260
```

---

## 7. Webhooks

### 7.1. Webhook Events

| Event | Description |
|-------|-------------|
| `booking.created` | New booking created |
| `booking.updated` | Booking modified |
| `booking.cancelled` | Booking cancelled |
| `checkin.completed` | Guest checked in |
| `checkout.completed` | Guest checked out |
| `cleaning.completed` | Cleaning finished |
| `terminal.online` | Tablet came online |
| `terminal.offline` | Tablet went offline |

### 7.2. Webhook Payload

```json
{
  "event": "booking.created",
  "timestamp": "2026-02-15T14:30:00Z",
  "data": {
    "bookingId": "booking_xyz789",
    "unitId": "unit_abc123",
    "ownerId": "owner_xyz789"
  },
  "signature": "sha256=abc123..."
}
```

### 7.3. Webhook Configuration

```http
POST /configureWebhook
```

**Request Body:**
```json
{
  "url": "https://partner.example.com/webhook",
  "events": ["booking.created", "checkin.completed"],
  "secret": "your_webhook_secret"
}
```

---

## Appendix A: SDK Examples

### Dart/Flutter

```dart
import 'package:cloud_functions/cloud_functions.dart';

final functions = FirebaseFunctions.instanceFor(region: 'europe-west3');

// Create booking
final result = await functions.httpsCallable('createBooking').call({
  'unitId': 'unit_abc123',
  'checkIn': '2026-02-15',
  'checkOut': '2026-02-20',
  'guestName': 'John Doe',
});

print('Booking ID: ${result.data['bookingId']}');
```

### JavaScript/TypeScript

```typescript
import { getFunctions, httpsCallable } from 'firebase/functions';

const functions = getFunctions(app, 'europe-west3');
const createBooking = httpsCallable(functions, 'createBooking');

const result = await createBooking({
  unitId: 'unit_abc123',
  checkIn: '2026-02-15',
  checkOut: '2026-02-20',
  guestName: 'John Doe',
});

console.log('Booking ID:', result.data.bookingId);
```

---

<p align="center">
  <strong>VESTA LUMINA API</strong><br>
  <em>Version 2.1.0</em><br><br>
  © 2024-2026 Vesta Lumina d.o.o. All rights reserved.
</p>
