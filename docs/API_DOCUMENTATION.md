# VLS Cloud Functions API Documentation
## Version: 5.0.0 - Phase 3

Base URL: `https://europe-west3-vls-admin.cloudfunctions.net`

---

## Authentication

All endpoints require Firebase Authentication. Include the Firebase ID token in requests.

### Roles
- **Super Admin**: Full system access (managed via `super_admins` collection)
- **Owner**: Property owner with access to their own data
- **Tablet**: Device authentication for guest check-in kiosks

---

## Owner Management (Super Admin Only)

### Create Owner
Creates a new property owner account.

**Endpoint:** `createOwner`  
**Method:** `onCall`  
**Auth:** Super Admin only

**Request:**
```json
{
  "email": "owner@example.com",
  "password": "securePassword123",
  "tenantId": "ABC123",
  "displayName": "John Doe"
}
```

**Response:**
```json
{
  "success": true,
  "tenantId": "ABC123",
  "firebaseUid": "uid_xxx",
  "email": "owner@example.com",
  "message": "Owner created. They must login and enter tenant ID to activate."
}
```

**Errors:**
- `Unauthorized - Super Admin only`: Caller is not a super admin
- `Missing required fields`: email, password, or tenantId not provided
- `Invalid tenant ID format`: tenantId must be 6-12 uppercase alphanumeric
- `Tenant ID already exists`: tenantId is already in use

---

### List Owners
Returns all registered property owners.

**Endpoint:** `listOwners`  
**Method:** `onCall`  
**Auth:** Super Admin only

**Response:**
```json
{
  "success": true,
  "owners": [
    {
      "tenantId": "ABC123",
      "email": "owner@example.com",
      "displayName": "John Doe",
      "firebaseUid": "uid_xxx",
      "status": "active",
      "createdAt": "2024-01-15T10:30:00.000Z",
      "createdBy": "admin@example.com",
      "linkedAt": "2024-01-15T11:00:00.000Z"
    }
  ]
}
```

---

### Delete Owner
Permanently removes an owner and their associated data.

**Endpoint:** `deleteOwner`  
**Method:** `onCall`  
**Auth:** Super Admin only

**Request:**
```json
{
  "tenantId": "ABC123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Owner deleted successfully",
  "tenantId": "ABC123"
}
```

---

### Reset Owner Password
Resets an owner's password.

**Endpoint:** `resetOwnerPassword`  
**Method:** `onCall`  
**Auth:** Super Admin only

**Request:**
```json
{
  "tenantId": "ABC123",
  "newPassword": "newSecurePassword456"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Password reset successfully",
  "tenantId": "ABC123"
}
```

---

### Toggle Owner Status
Activates or suspends an owner account.

**Endpoint:** `toggleOwnerStatus`  
**Method:** `onCall`  
**Auth:** Super Admin only

**Request:**
```json
{
  "tenantId": "ABC123",
  "status": "suspended"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Owner suspended",
  "tenantId": "ABC123",
  "status": "suspended"
}
```

**Valid status values:** `active`, `suspended`

---

## Tenant Linking

### Link Tenant ID
Links a Firebase user to their tenant account.

**Endpoint:** `linkTenantId`  
**Method:** `onCall`  
**Auth:** Any authenticated user

**Request:**
```json
{
  "tenantId": "ABC123"
}
```

**Response:**
```json
{
  "success": true,
  "tenantId": "ABC123",
  "message": "Account activated successfully!"
}
```

**Errors:**
- `Tenant ID not found`: No matching tenant record
- `Tenant ID does not match your email`: Email mismatch
- `Your account has been suspended`: Account is suspended

---

## Super Admin Management (Primary Admin Only)

### Add Super Admin
Adds a new super admin. Only the primary admin can perform this action.

**Endpoint:** `addSuperAdmin`  
**Method:** `onCall`  
**Auth:** Primary Admin only (vestaluminasystem@gmail.com)

**Request:**
```json
{
  "email": "newadmin@example.com",
  "displayName": "Admin Name"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Super Admin newadmin@example.com added successfully"
}
```

---

### Remove Super Admin
Removes a super admin. Cannot remove the primary admin.

**Endpoint:** `removeSuperAdmin`  
**Method:** `onCall`  
**Auth:** Primary Admin only

**Request:**
```json
{
  "email": "admin@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Super Admin admin@example.com removed successfully"
}
```

---

### List Super Admins
Returns all super admins.

**Endpoint:** `listSuperAdmins`  
**Method:** `onCall`  
**Auth:** Any Super Admin

**Response:**
```json
{
  "success": true,
  "admins": [
    {
      "email": "vestaluminasystem@gmail.com",
      "displayName": "Primary Admin",
      "active": true,
      "addedAt": null,
      "addedBy": "system"
    },
    {
      "email": "admin@example.com",
      "displayName": "Secondary Admin",
      "active": true,
      "addedAt": "2024-01-20T08:00:00.000Z",
      "addedBy": "vestaluminasystem@gmail.com"
    }
  ]
}
```

---

## Translation

### Translate House Rules
Translates house rules to multiple languages using AI.

**Endpoint:** `translateHouseRules`  
**Method:** `onCall`  
**Auth:** Any authenticated owner

**Request:**
```json
{
  "text": "No smoking allowed. Quiet hours from 10 PM to 8 AM.",
  "sourceLang": "en",
  "targetLangs": ["hr", "de", "it"]
}
```

**Response:**
```json
{
  "success": true,
  "translations": {
    "hr": "Zabranjeno pušenje. Tihe sate od 22:00 do 08:00.",
    "de": "Rauchen verboten. Ruhezeiten von 22:00 bis 08:00 Uhr.",
    "it": "Vietato fumare. Ore di silenzio dalle 22:00 alle 08:00."
  }
}
```

---

### Translate Notification
Translates system notifications (Super Admin only).

**Endpoint:** `translateNotification`  
**Method:** `onCall`  
**Auth:** Super Admin only

**Request:**
```json
{
  "text": "System maintenance scheduled",
  "sourceLanguage": "en",
  "targetLanguages": ["hr", "de"]
}
```

**Response:**
```json
{
  "translations": {
    "en": "System maintenance scheduled",
    "hr": "Zakazano održavanje sustava",
    "de": "Systemwartung geplant"
  }
}
```

---

## Tablet Management

### Register Tablet
Registers a new tablet device for a unit.

**Endpoint:** `registerTablet`  
**Method:** `onCall`  
**Auth:** Any (uses tenantId from request)

**Request:**
```json
{
  "tenantId": "ABC123",
  "unitId": "unit_xxx"
}
```

**Response:**
```json
{
  "success": true,
  "tabletId": "tablet_xxx",
  "firebaseUid": "uid_xxx",
  "customToken": "eyJhbGciOiJS...",
  "message": "Tablet registered successfully!"
}
```

---

### Tablet Heartbeat
Reports tablet status and checks for updates.

**Endpoint:** `tabletHeartbeat`  
**Method:** `onCall`  
**Auth:** Tablet role only

**Request:**
```json
{
  "appVersion": "1.2.0",
  "batteryLevel": 85,
  "isCharging": true,
  "updateStatus": "idle"
}
```

**Response:**
```json
{
  "success": true,
  "pendingUpdate": false,
  "pendingVersion": "",
  "pendingApkUrl": "",
  "forceUpdate": false
}
```

---

## Backup (Super Admin Only)

### Manual Backup
Triggers an immediate backup of all collections.

**Endpoint:** `manualBackup`  
**Method:** `onCall`  
**Auth:** Super Admin only

**Response:**
```json
{
  "success": true,
  "backupId": "manual_2024-01-20T10-30-00-000Z",
  "totalDocuments": 1250,
  "message": "Backup completed successfully"
}
```

---

### Scheduled Backup
Automatically runs daily at 3:00 AM (Europe/Zagreb timezone).

**Endpoint:** `scheduledBackup`  
**Method:** `onSchedule`  
**Schedule:** `0 3 * * *`

**Behavior:**
- Backs up: `tenant_links`, `settings`, `units`, `bookings`, `tablets`, `super_admins`
- Stores metadata in `backups` collection
- Stores data if < 1MB
- Cleans up backups older than 30 days

---

## Admin Logs

### Get Admin Logs
Returns admin activity logs.

**Endpoint:** `getAdminLogs`  
**Method:** `onCall`  
**Auth:** Super Admin only

**Request:**
```json
{
  "limit": 100
}
```

**Response:**
```json
{
  "success": true,
  "logs": [
    {
      "id": "log_xxx",
      "adminEmail": "admin@example.com",
      "action": "CREATE_OWNER",
      "details": {
        "tenantId": "ABC123",
        "ownerEmail": "owner@example.com"
      },
      "timestamp": "2024-01-20T10:30:00.000Z"
    }
  ]
}
```

**Logged Actions:**
- `CREATE_OWNER`
- `DELETE_OWNER`
- `RESET_PASSWORD`
- `TOGGLE_STATUS`
- `ADD_SUPER_ADMIN`
- `REMOVE_SUPER_ADMIN`
- `MANUAL_BACKUP`

---

## Error Handling

All endpoints return errors in the following format:

```json
{
  "code": "functions/invalid-argument",
  "message": "Error description"
}
```

Common error codes:
- `unauthenticated`: No valid authentication token
- `permission-denied`: Insufficient permissions
- `invalid-argument`: Invalid request parameters
- `not-found`: Resource not found
- `already-exists`: Resource already exists
- `internal`: Internal server error

---

## Rate Limits

- **Translation endpoints**: 10 requests per minute per user
- **Backup endpoints**: 1 request per 5 minutes
- **Other endpoints**: 100 requests per minute per user

---

## Changelog

### Version 5.0.0 (Phase 3)
- Added multiple super admin support
- Added automatic scheduled backups
- Added manual backup endpoint
- Added admin activity logging
- Updated all super admin checks to use Firestore

### Version 4.0.0 (Phase 2)
- Initial production release
- 10 core Cloud Functions
- Tablet management
- AI translation