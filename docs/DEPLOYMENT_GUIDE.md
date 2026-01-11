# VESTA LUMINA DEPLOYMENT GUIDE
## Firebase Setup & Tablet Provisioning

**Version:** 2.1.0  
**Last Updated:** January 2026

---

## ⚠️ PROPRIETARY - CONFIDENTIAL

```
This documentation is confidential and proprietary to Vesta Lumina d.o.o.
For authorized deployment personnel only.
```

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Firebase Project Setup](#2-firebase-project-setup)
3. [Admin Panel Deployment](#3-admin-panel-deployment)
4. [Cloud Functions Deployment](#4-cloud-functions-deployment)
5. [Tablet Terminal Setup](#5-tablet-terminal-setup)
6. [Tablet Provisioning](#6-tablet-provisioning)
7. [Post-Deployment Verification](#7-post-deployment-verification)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. Prerequisites

### 1.1. Required Tools

| Tool | Version | Purpose |
|------|---------|---------|
| Node.js | 18+ | Cloud Functions runtime |
| Flutter | 3.32+ | App development |
| Firebase CLI | Latest | Firebase deployment |
| Android Studio | Latest | Android SDK & emulator |
| Git | Latest | Version control |

### 1.2. Required Accounts

| Account | Purpose |
|---------|---------|
| Google Cloud | Firebase hosting |
| Firebase | Backend services |
| Sentry | Error monitoring |
| SendGrid | Email delivery |
| OpenAI | AI chatbot |

### 1.3. Environment Setup

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install Flutter
# Follow: https://docs.flutter.dev/get-started/install

# Verify installations
node --version    # Should be 18+
flutter --version # Should be 3.32+
firebase --version
```

---

## 2. Firebase Project Setup

### 2.1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add Project"
3. Enter project name: `vestalumina-[environment]`
4. Disable Google Analytics (or configure separately)
5. Click "Create Project"

### 2.2. Enable Services

```
Firebase Console → Project Settings → Enable:
☑ Authentication
☑ Cloud Firestore
☑ Cloud Storage
☑ Cloud Functions
☑ Cloud Messaging
☑ Hosting
```

### 2.3. Configure Authentication

```
Authentication → Sign-in method → Enable:
☑ Email/Password
☑ Anonymous (for guest check-in)
```

### 2.4. Create Firestore Database

```
Firestore Database → Create Database
1. Select "Start in production mode"
2. Choose location: europe-west3 (Frankfurt)
3. Click "Enable"
```

### 2.5. Configure Storage

```
Storage → Get Started
1. Select "Start in production mode"  
2. Choose location: europe-west3
3. Click "Done"
```

### 2.6. Set Up Cloud Functions Region

```bash
# In functions/src/index.ts
export const region = 'europe-west3';
```

### 2.7. Firebase Configuration File

Create `firebase.json`:

```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "functions": {
    "source": "functions",
    "predeploy": [
      "npm --prefix functions run lint",
      "npm --prefix functions run build"
    ]
  },
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  },
  "storage": {
    "rules": "storage.rules"
  }
}
```

---

## 3. Admin Panel Deployment

### 3.1. Clone Repository

```bash
git clone https://github.com/nroxa92/admin_panel.git
cd admin_panel
```

### 3.2. Configure Environment

Create `.env` file:

```env
# Firebase Configuration
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abc123

# External Services
SENTRY_DSN=https://xxx@sentry.io/xxx
OPENAI_API_KEY=sk-xxx
SENDGRID_API_KEY=SG.xxx

# App Configuration
APP_ENV=production
APP_URL=https://app.vestalumina.com
```

### 3.3. Generate Firebase Options

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure --project=your-project-id

# This generates lib/firebase_options.dart
```

### 3.4. Build Web App

```bash
# Get dependencies
flutter pub get

# Build for web (production)
flutter build web --release --web-renderer canvaskit

# Output: build/web/
```

### 3.5. Deploy to Firebase Hosting

```bash
# Deploy hosting only
firebase deploy --only hosting

# Or deploy everything
firebase deploy
```

### 3.6. Configure Custom Domain (Optional)

```
Firebase Console → Hosting → Add custom domain
1. Enter domain: app.vestalumina.com
2. Verify ownership via DNS TXT record
3. Add A records pointing to Firebase IPs
4. Wait for SSL certificate provisioning
```

---

## 4. Cloud Functions Deployment

### 4.1. Navigate to Functions Directory

```bash
cd functions
```

### 4.2. Install Dependencies

```bash
npm install
```

### 4.3. Configure Environment Variables

```bash
# Set function configuration
firebase functions:config:set \
  sendgrid.key="SG.xxx" \
  openai.key="sk-xxx" \
  sentry.dsn="https://xxx@sentry.io/xxx" \
  app.url="https://app.vestalumina.com"

# Verify configuration
firebase functions:config:get
```

### 4.4. Build Functions

```bash
npm run build
```

### 4.5. Deploy Functions

```bash
# Deploy all functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:createBooking

# Deploy function group
firebase deploy --only functions:booking*
```

### 4.6. Verify Deployment

```bash
# List deployed functions
firebase functions:list

# Check function logs
firebase functions:log --only createBooking
```

---

## 5. Tablet Terminal Setup

### 5.1. Clone Repository

```bash
git clone https://github.com/nroxa92/tablet_terminal.git
cd tablet_terminal
```

### 5.2. Configure Firebase

```bash
# Configure Firebase for Android
flutterfire configure --project=your-project-id --platforms=android
```

### 5.3. Update Android Configuration

Edit `android/app/build.gradle`:

```gradle
android {
    namespace "com.vestalumina.terminal"
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.vestalumina.terminal"
        minSdkVersion 26
        targetSdkVersion 34
        versionCode 30
        versionName "3.0.0"
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 5.4. Configure Signing

Create `android/key.properties`:

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=vestalumina
storeFile=/path/to/vestalumina.keystore
```

### 5.5. Build APK

```bash
# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### 5.6. Build App Bundle (for Play Store)

```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## 6. Tablet Provisioning

### 6.1. Hardware Requirements

| Requirement | Specification |
|-------------|---------------|
| **Device** | Android tablet, 10"+ screen |
| **Android** | 8.0 (API 26) or newer |
| **RAM** | 2GB minimum, 4GB recommended |
| **Storage** | 16GB minimum |
| **Camera** | 5MP+ rear camera |
| **WiFi** | 802.11ac recommended |

### 6.2. Recommended Devices

| Device | Price Range | Rating |
|--------|-------------|--------|
| Samsung Galaxy Tab A8 | €€ | ⭐⭐⭐⭐ |
| Samsung Galaxy Tab S6 Lite | €€€ | ⭐⭐⭐⭐⭐ |
| Lenovo Tab M10 Plus | €€ | ⭐⭐⭐⭐ |
| Xiaomi Pad 5 | €€ | ⭐⭐⭐⭐ |

### 6.3. Initial Device Setup

```
1. Power on tablet
2. Skip Google account setup (or use dedicated account)
3. Connect to WiFi
4. Update Android to latest version
5. Disable automatic updates
```

### 6.4. Install Application

**Method 1: Direct APK Install**
```
1. Enable "Unknown Sources" in Settings
2. Transfer APK to tablet via USB or download link
3. Open APK file and install
4. Disable "Unknown Sources" after installation
```

**Method 2: MDM Deployment**
```
1. Enroll device in MDM solution (e.g., Knox, Scalefusion)
2. Push APK through MDM
3. Configure kiosk policies
```

### 6.5. Pair Terminal with Unit

```
1. Open Vesta Lumina Terminal app
2. App shows pairing screen with input field
3. In Admin Panel: Units → [Unit] → Terminal → Generate Code
4. Enter 6-digit code on tablet
5. Tablet connects and syncs data
6. Status changes to "Connected" in Admin Panel
```

### 6.6. Configure Kiosk Mode

**Samsung Knox (Recommended)**
```
Knox Manage → Device → Kiosk Mode
1. Enable Kiosk Mode
2. Add Vesta Lumina Terminal to allowed apps
3. Disable navigation buttons
4. Disable status bar pull-down
5. Configure auto-restart on crash
```

**Android Device Owner Mode**
```bash
# Set device owner via ADB
adb shell dpm set-device-owner com.vestalumina.terminal/.AdminReceiver

# Lock task mode is then enabled automatically by the app
```

### 6.7. Physical Installation

```
Mounting Recommendations:
┌────────────────────────────────────────┐
│                                        │
│   ┌──────────────────────────────┐    │
│   │                              │    │
│   │    TABLET                    │    │  Wall mount at
│   │    (landscape orientation)   │    │  eye level
│   │                              │    │  (120-140cm)
│   │                              │    │
│   └──────────────────────────────┘    │
│                                        │
│   Power cable routed through wall     │
│   or cable management channel         │
│                                        │
└────────────────────────────────────────┘

Checklist:
☐ Secure wall mount installed
☐ Tablet locked in mount (anti-theft)
☐ Power cable connected and secured
☐ Camera unobstructed (for OCR)
☐ Screen visible without glare
☐ WiFi signal strong (>-60 dBm)
```

### 6.8. Post-Installation Checklist

```
☐ App launches on boot
☐ Screensaver activates after timeout
☐ Touch screen responsive
☐ Camera working (test OCR)
☐ WiFi connected and stable
☐ Data syncing with Admin Panel
☐ Notifications receiving
☐ Sound working (if enabled)
☐ Kiosk mode preventing exit
☐ Physical security verified
```

---

## 7. Post-Deployment Verification

### 7.1. Admin Panel Checks

| Check | Command/Action | Expected Result |
|-------|----------------|-----------------|
| Hosting live | Visit URL | Login page loads |
| Auth working | Create test user | User created |
| Firestore connected | Create unit | Unit appears in console |
| Functions deployed | Call test function | Success response |
| Storage working | Upload image | File in bucket |

### 7.2. Tablet Terminal Checks

| Check | Action | Expected Result |
|-------|--------|-----------------|
| App installs | Install APK | App appears |
| Pairing works | Enter code | Terminal paired |
| Data syncs | Create booking | Appears on tablet |
| OCR working | Scan document | Data extracted |
| Signature works | Sign house rules | PNG saved |
| Kiosk mode | Try to exit | Prevented |

### 7.3. Integration Checks

| Integration | Test | Expected |
|-------------|------|----------|
| iCal sync | Import calendar | Bookings created |
| Email | Trigger notification | Email received |
| Push notification | Send test | Notification appears |
| AI chatbot | Ask question | Response received |

### 7.4. Load Testing

```bash
# Use Artillery for load testing
npm install -g artillery

# Create test scenario
artillery run load-test.yml

# Expected results:
# - Response time < 500ms (p95)
# - Error rate < 0.1%
# - Concurrent users: 100+
```

---

## 8. Troubleshooting

### 8.1. Common Issues

#### Firebase Authentication Failed
```
Error: Firebase Auth error
Solution:
1. Verify firebase_options.dart is correct
2. Check API key restrictions in Google Cloud Console
3. Ensure domain is authorized in Firebase Auth settings
```

#### Cloud Functions Timeout
```
Error: Function execution took X ms, finished with status: 'timeout'
Solution:
1. Increase function timeout in firebase.json
2. Optimize function code
3. Check for infinite loops or blocking calls
```

#### Tablet Not Pairing
```
Error: Invalid access code
Solution:
1. Verify code hasn't expired (24h default)
2. Check tablet has internet connection
3. Regenerate code in Admin Panel
4. Check Firestore rules allow terminal access
```

#### OCR Not Working
```
Error: ML Kit initialization failed
Solution:
1. Verify Google Play Services installed
2. Check camera permissions granted
3. Ensure good lighting conditions
4. Restart app
```

### 8.2. Logs and Monitoring

#### Firebase Functions Logs
```bash
# Real-time logs
firebase functions:log

# Specific function
firebase functions:log --only createBooking

# With timestamp filter
firebase functions:log --since 1h
```

#### Sentry Error Tracking
```
Sentry Dashboard → Issues → Filter by:
- Environment: production
- Release: 3.0.0
- Tag: tablet_terminal
```

#### Firestore Usage
```
Firebase Console → Firestore → Usage
- Monitor read/write operations
- Check billing alerts
- Review slow queries
```

### 8.3. Rollback Procedures

#### Hosting Rollback
```bash
# List releases
firebase hosting:releases:list

# Rollback to previous
firebase hosting:rollback
```

#### Functions Rollback
```bash
# Deploy specific version from git
git checkout v2.0.0
cd functions && npm run build
firebase deploy --only functions
```

### 8.4. Support Escalation

| Level | Contact | Response Time |
|-------|---------|---------------|
| L1 | support@vestalumina.com | 4h |
| L2 | tech@vestalumina.com | 2h |
| L3 | emergency@vestalumina.com | 1h |

---

## Appendix A: Environment Checklist

### Development
```
☐ Firebase project: vestalumina-dev
☐ Hosting URL: dev.vestalumina.com
☐ Functions: development endpoints
☐ Test data seeded
```

### Staging
```
☐ Firebase project: vestalumina-staging
☐ Hosting URL: staging.vestalumina.com
☐ Functions: staging endpoints
☐ Production-like data
```

### Production
```
☐ Firebase project: vestalumina-prod
☐ Hosting URL: app.vestalumina.com
☐ Functions: production endpoints
☐ Real customer data
☐ Monitoring enabled
☐ Backups configured
```

---

## Appendix B: Security Checklist

```
☐ Firestore rules deployed and tested
☐ Storage rules deployed and tested
☐ API keys restricted by domain/app
☐ Environment variables secured
☐ HTTPS enforced
☐ Auth tokens expire appropriately
☐ Rate limiting configured
☐ Error messages don't leak info
☐ Audit logging enabled
☐ Backup encryption verified
```

---

<p align="center">
  <strong>VESTA LUMINA DEPLOYMENT GUIDE</strong><br>
  <em>Version 2.1.0</em><br><br>
  © 2024-2026 Vesta Lumina d.o.o. All rights reserved.
</p>
