# VESTA LUMINA RELEASE NOTES
## Version History & Changelog

---

## Release Notes Template

```
## Version X.Y.Z (YYYY-MM-DD)

### 🎉 New Features
- Feature description with user benefit

### 🔧 Improvements
- Improvement description

### 🐛 Bug Fixes
- Bug fix description (Issue #XXX)

### 🔒 Security
- Security update description

### ⚠️ Breaking Changes
- Breaking change with migration guide

### 📝 Notes
- Additional information
```

---

# Admin Panel Releases

## Version 2.1.0 (2026-01-15)

### 🎉 New Features

**Enhanced Analytics Dashboard**
- Added real-time occupancy heatmap visualization
- New revenue forecasting based on historical data
- Guest demographics breakdown by nationality and source
- Comparative period analysis (YoY, MoM)

**Advanced PDF Generation**
- 10 new PDF document types including damage reports
- Custom branding on all PDF documents
- Batch PDF generation for multiple bookings
- QR code integration on guest documents

**Super Admin Panel**
- Platform-wide statistics dashboard
- White-label brand management
- Subscription and billing management
- Bulk owner operations

### 🔧 Improvements

- Calendar drag-and-drop performance improved by 40%
- Search now includes fuzzy matching for guest names
- Booking list pagination increased to 100 items
- Image upload compression reduces file size by 60%
- Dark mode contrast improvements
- Mobile responsive layout fixes

### 🐛 Bug Fixes

- Fixed calendar not showing bookings spanning months (#234)
- Fixed iCal sync duplicating cancelled bookings (#241)
- Fixed PDF generation timeout for large documents (#248)
- Fixed cleaner PIN reset not sending notification (#252)
- Fixed house rules not saving in certain languages (#259)

### 🔒 Security

- Upgraded to Firebase SDK 10.x with security patches
- Added rate limiting on password reset endpoint
- Improved session token rotation
- Enhanced XSS protection in text inputs

### 📝 Notes

- Minimum browser versions: Chrome 90+, Firefox 90+, Safari 14+
- Database migration runs automatically on first login
- iCal integrations need to be re-synced after upgrade

---

## Version 2.0.0 (2025-11-01)

### 🎉 New Features

**Multi-tenant Architecture**
- Support for white-label partners
- Brand-level administration
- Custom domains per brand
- Isolated data per tenant

**AI Assistant Configuration**
- Custom knowledge base per unit
- Conversation transcript viewer
- Response quality analytics
- Multi-language AI responses

**Advanced Cleaning Module**
- Digital checklists with photos
- Cleaner performance metrics
- Issue reporting and tracking
- Automatic task assignment

### 🔧 Improvements

- Complete UI redesign with new theme system
- 10 color themes + 6 background tones
- Improved navigation structure
- Faster initial load time (50% improvement)

### ⚠️ Breaking Changes

- API endpoint `/v1/bookings` deprecated, use `/v2/bookings`
- Old iCal format no longer supported
- Cleaner PIN now requires 4 digits minimum

---

## Version 1.8.0 (2025-09-01)

### 🎉 New Features

**Drag-and-Drop Calendar**
- Visual booking management
- Drag to reschedule bookings
- Click to create new booking
- Multi-unit view option

**iCal Synchronization**
- Airbnb calendar import
- Booking.com calendar import
- Google Calendar sync
- Automatic hourly updates

### 🐛 Bug Fixes

- Fixed booking overlap detection (#189)
- Fixed timezone issues in calendar (#195)
- Fixed email notifications not sending (#201)

---

## Version 1.5.0 (2025-07-01)

### 🎉 New Features

**AI Assistant Integration**
- GPT-4 powered chatbot
- Property-specific responses
- 11 language support
- Conversation history

**Guest Feedback Module**
- Post-stay feedback collection
- Rating system
- Review management
- Analytics dashboard

---

## Version 1.0.0 (2025-05-01)

### 🎉 Initial Release

**Core Features**
- Owner dashboard
- Unit management
- Booking management
- Guest management
- Basic reporting
- Multi-language support (11 languages)
- Firebase authentication
- Firestore database

---

# Tablet Terminal Releases

## Version 3.0.0 (2026-01-15)

### 🎉 New Features

**Multi-Guest Check-in**
- Support for multiple guests per booking
- Individual document scanning for each guest
- Group signature option
- Guest count verification

**Enhanced OCR**
- Improved passport MRZ reading
- Support for more EU ID card formats
- Better handling of damaged documents
- Automatic field correction suggestions

**Offline Mode Improvements**
- Full check-in flow available offline
- Queue system for pending syncs
- Automatic retry on reconnection
- Graceful degradation

### 🔧 Improvements

- Faster camera initialization (2s → 0.5s)
- Smoother signature capture
- Reduced app memory usage by 30%
- Better error messages
- Improved accessibility

### 🐛 Bug Fixes

- Fixed OCR crash on certain Samsung devices (#178)
- Fixed signature not saving on slow networks (#185)
- Fixed screensaver images not rotating (#191)
- Fixed language selection resetting (#197)
- Fixed kiosk mode escape on Android 13 (#203)

### 🔒 Security

- Upgraded ML Kit to latest version
- Improved local data encryption
- Enhanced kiosk mode lockdown
- Automatic session timeout

### 📝 Notes

- Requires Android 8.0 (API 26) or higher
- Recommended: 4GB RAM for best performance
- Camera permission required for OCR

---

## Version 2.5.0 (2025-11-01)

### 🎉 New Features

**AI Chatbot**
- In-app chat with AI assistant
- Property-specific knowledge
- Multi-language conversations
- Offline FAQ fallback

**Cleaner Mode**
- PIN-protected access
- Digital checklists
- Photo documentation
- Issue reporting

### 🐛 Bug Fixes

- Fixed pairing timeout issues (#156)
- Fixed WiFi info not displaying (#162)
- Fixed house rules scroll (#168)

---

## Version 2.0.0 (2025-09-01)

### 🎉 New Features

**Offline Support**
- Hive local database
- Offline check-in queue
- Automatic sync
- Network status indicator

**Enhanced Screensaver**
- Image slideshow
- Customizable timing
- Touch to wake
- Clock overlay option

---

## Version 1.5.0 (2025-07-01)

### 🎉 New Features

**Digital Signature**
- Smooth signature pad
- PNG export
- Retry option
- Multi-language labels

**House Rules Display**
- Formatted rules display
- Mandatory acceptance
- Language auto-detection
- Scroll indicator

---

## Version 1.0.0 (2025-05-01)

### 🎉 Initial Release

**Core Features**
- Tablet pairing
- Guest check-in flow
- OCR document scanning
- WiFi info display
- Basic screensaver
- Multi-language (11 languages)

---

# Cloud Functions Releases

## Version 2.1.0 (2026-01-15)

### 🎉 New Functions

| Function | Description |
|----------|-------------|
| `generateDamageReport` | Generate property damage PDF |
| `batchExportBookings` | Export multiple bookings |
| `calculateOccupancy` | Compute occupancy statistics |
| `processWebhook` | Handle external webhooks |

### 🔧 Improvements

- All functions migrated to Node.js 18
- TypeScript strict mode enabled
- Response time reduced by 25%
- Memory usage optimized

### 🐛 Bug Fixes

- Fixed PDF generation memory leak (#89)
- Fixed iCal parser timezone bug (#94)
- Fixed notification batching (#98)

---

## Upgrade Guide

### From 2.0.x to 2.1.0

```
1. Backup your data
   → Admin Panel → Settings → Export Data

2. Update dependencies
   → flutter pub upgrade

3. Deploy new functions
   → firebase deploy --only functions

4. Clear browser cache
   → Users should clear cache

5. Re-sync iCal integrations
   → Settings → Integrations → Sync All

6. Verify functionality
   → Test key workflows
```

### Database Migrations

Version 2.1.0 includes automatic migrations:
- `booking.guests` field restructured
- `owner.settings` new fields added
- `cleaning_logs` new schema

Migrations run automatically on first access.

---

## Deprecation Notices

### Deprecated in 2.1.0

| Item | Replacement | Removal |
|------|-------------|---------|
| API v1 endpoints | API v2 | Version 3.0 |
| Legacy PDF format | New PDF engine | Version 2.3 |
| Old notification API | FCM v2 | Version 2.5 |

### Removed in 2.1.0

- Legacy booking import format
- Old cleaner PIN format (3 digits)
- Deprecated theme settings

---

## Known Issues

### Version 2.1.0

| Issue | Workaround | Status |
|-------|------------|--------|
| Calendar slow with 500+ bookings | Use date filters | In progress |
| PDF timeout on weak network | Retry or use better connection | Investigating |
| OCR fails on glossy IDs | Tilt to reduce glare | By design |

---

## Roadmap

### Version 2.2.0 (Q2 2026)

- [ ] Channel manager integration
- [ ] Dynamic pricing engine
- [ ] Guest messaging
- [ ] Payment processing

### Version 2.3.0 (Q3 2026)

- [ ] Mobile app for owners
- [ ] Voice check-in option
- [ ] Advanced analytics
- [ ] API marketplace

### Version 3.0.0 (Q4 2026)

- [ ] Complete UI overhaul
- [ ] Machine learning insights
- [ ] Multi-property management
- [ ] Enterprise features

---

## Feedback

We value your feedback! Please share:

- **Feature requests:** feedback@vestalumina.com
- **Bug reports:** Use in-app "Report Issue"
- **General feedback:** Use thumbs up/down in app

---

<p align="center">
  <strong>VESTA LUMINA RELEASE NOTES</strong><br>
  <em>Keeping you informed</em><br><br>
  © 2024-2026 Vesta Lumina d.o.o.
</p>
