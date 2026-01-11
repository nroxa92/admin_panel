# VESTA LUMINA TROUBLESHOOTING GUIDE
## Problem Resolution for Admin Panel & Tablet Terminal

**Version:** 2.1.0  
**Last Updated:** January 2026

---

## Table of Contents

1. [Admin Panel Issues](#1-admin-panel-issues)
2. [Tablet Terminal Issues](#2-tablet-terminal-issues)
3. [Connectivity Issues](#3-connectivity-issues)
4. [Authentication Issues](#4-authentication-issues)
5. [Booking & Calendar Issues](#5-booking--calendar-issues)
6. [OCR & Document Scanning Issues](#6-ocr--document-scanning-issues)
7. [Cleaning Module Issues](#7-cleaning-module-issues)
8. [Integration Issues](#8-integration-issues)
9. [Performance Issues](#9-performance-issues)
10. [Error Code Reference](#10-error-code-reference)

---

## Quick Diagnostics

Before troubleshooting, perform these quick checks:

```
☐ Internet connection working?
☐ Browser/app up to date?
☐ Firebase status: https://status.firebase.google.com
☐ Clear cache and cookies
☐ Try incognito/private mode
☐ Check system status page
```

---

## 1. Admin Panel Issues

### 1.1. Page Not Loading

**Symptoms:**
- Blank white page
- Infinite loading spinner
- "Something went wrong" message

**Solutions:**

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Clear browser cache (Ctrl+Shift+Delete) | Fresh load |
| 2 | Disable browser extensions | Extensions may interfere |
| 3 | Try different browser | Rule out browser issue |
| 4 | Check console (F12) for errors | Identify specific error |
| 5 | Hard refresh (Ctrl+Shift+R) | Force reload |

**Console Errors:**
```javascript
// Firebase initialization failed
"Firebase: Error (auth/network-request-failed)"
→ Check internet connection
→ Check if Firebase is blocked by firewall

// CORS error
"Access to fetch has been blocked by CORS policy"
→ Clear cache
→ Contact support if persists
```

### 1.2. Dashboard Not Updating

**Symptoms:**
- Old data showing
- Stats not refreshing
- New bookings not appearing

**Solutions:**
```
1. Click refresh button on dashboard
2. Log out and log back in
3. Clear browser cache
4. Check browser console for errors
5. Verify Firestore connection
```

### 1.3. Cannot Save Changes

**Symptoms:**
- "Save failed" error
- Changes revert after refresh
- Timeout errors

**Solutions:**

| Cause | Solution |
|-------|----------|
| Network timeout | Check internet speed (min 5 Mbps) |
| Session expired | Log out and log back in |
| Permission denied | Verify account permissions |
| Data validation | Check required fields |

---

## 2. Tablet Terminal Issues

### 2.1. App Crashes on Launch

**Symptoms:**
- App closes immediately
- Black screen then exit
- "App stopped" message

**Solutions:**

```
Step 1: Force stop and clear cache
─────────────────────────────────
Settings → Apps → Vesta Lumina Terminal
→ Force Stop
→ Storage → Clear Cache

Step 2: Restart tablet
─────────────────────
Hold power button → Restart

Step 3: Reinstall app
─────────────────────
Uninstall → Download fresh APK → Install

Step 4: Check Android version
─────────────────────────────
Settings → About → Android version
(Minimum: Android 8.0)
```

### 2.2. Tablet Won't Pair

**Symptoms:**
- "Invalid code" error
- Code expires before entry
- "Connection failed" message

**Solutions:**

| Issue | Solution |
|-------|----------|
| Code expired | Generate new code (valid 24h) |
| Wrong code | Double-check all 6 digits |
| Network issue | Verify WiFi connected |
| Firebase blocked | Check firewall settings |
| Time sync | Ensure tablet time is correct |

**Pairing Debug Steps:**
```
1. Verify tablet has internet
   → Open browser, visit google.com
   
2. Generate new pairing code in Admin Panel
   → Units → [Unit] → Terminal → Generate Code
   
3. Enter code within 5 minutes
   
4. If fails, check Android logs:
   → Settings → Developer Options → Logs
```

### 2.3. Screensaver Not Working

**Symptoms:**
- Screen stays on home
- No images displaying
- Black screen instead of screensaver

**Solutions:**

```
Check 1: Images uploaded?
──────────────────────────
Admin Panel → Units → [Unit] → Screensaver
→ Upload at least 1 image

Check 2: Sync completed?
────────────────────────
Tablet → Settings → Sync Now
→ Wait for "Sync complete"

Check 3: Memory available?
──────────────────────────
Settings → Storage
→ Ensure >500MB free

Check 4: Image format?
──────────────────────
Supported: JPG, PNG
Max size: 10MB per image
```

### 2.4. Kiosk Mode Issues

**Symptoms:**
- Can exit app easily
- Navigation buttons visible
- Other apps accessible

**Solutions:**

**Samsung Knox (Recommended):**
```
Knox Manage → Device Policy
1. Enable Kiosk Mode
2. Set Vesta Lumina as only app
3. Disable:
   ☐ Navigation buttons
   ☐ Status bar pull-down
   ☐ Recent apps button
   ☐ Home button
4. Deploy policy to device
```

**Generic Android:**
```
Option 1: Device Owner Mode
─────────────────────────────
adb shell dpm set-device-owner com.vestalumina.terminal/.AdminReceiver

Option 2: Screen Pinning
────────────────────────
Settings → Security → Screen pinning → Enable
Open app → Recent apps → Pin icon
```

---

## 3. Connectivity Issues

### 3.1. "No Internet Connection" Error

**Diagnostic Steps:**

```
┌─────────────────────────────────────────────────────────────┐
│               CONNECTIVITY TROUBLESHOOTING                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. Can you access other websites?                          │
│     YES → Go to step 2                                      │
│     NO  → Check WiFi/network connection                     │
│                                                              │
│  2. Can you access firebase.google.com?                     │
│     YES → Go to step 3                                      │
│     NO  → Firebase may be blocked (firewall/ISP)            │
│                                                              │
│  3. Can you access console.firebase.google.com?             │
│     YES → Issue may be temporary, retry                     │
│     NO  → Check Firebase status page                        │
│                                                              │
│  4. Check Firebase status:                                  │
│     https://status.firebase.google.com                      │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 3.2. Slow Performance

**Network Speed Requirements:**

| Action | Min. Speed | Recommended |
|--------|------------|-------------|
| Basic operations | 1 Mbps | 5 Mbps |
| Image upload | 3 Mbps | 10 Mbps |
| PDF generation | 2 Mbps | 5 Mbps |
| iCal sync | 1 Mbps | 3 Mbps |

**Speed Test:**
```
1. Visit speedtest.net
2. Run speed test
3. Check:
   - Download: Min 5 Mbps
   - Upload: Min 2 Mbps
   - Ping: Max 100ms
```

### 3.3. WebSocket Disconnects

**Symptoms:**
- Real-time updates stop
- "Reconnecting..." message
- Delayed notifications

**Solutions:**
```
1. Check for network switching (WiFi ↔ mobile)
2. Disable WiFi power saving
3. Exclude app from battery optimization
4. Use stable WiFi connection
```

---

## 4. Authentication Issues

### 4.1. Cannot Log In

| Error Message | Cause | Solution |
|---------------|-------|----------|
| "Invalid email or password" | Wrong credentials | Reset password |
| "User not found" | Account doesn't exist | Check email spelling |
| "Too many requests" | Rate limited | Wait 15 minutes |
| "Account disabled" | Admin disabled account | Contact support |
| "Network error" | Connection issue | Check internet |

### 4.2. Password Reset Not Working

**Steps:**
```
1. Click "Forgot Password"
2. Enter registered email
3. Check spam/junk folder
4. Wait up to 10 minutes
5. If no email, verify email is correct
6. Contact support if persists
```

### 4.3. Session Keeps Expiring

**Causes & Solutions:**

| Cause | Solution |
|-------|----------|
| Browser clearing cookies | Add exception for app |
| Incognito mode | Use normal mode |
| Multiple tabs | Use single tab |
| VPN issues | Disable VPN |
| Clock out of sync | Sync device time |

---

## 5. Booking & Calendar Issues

### 5.1. Bookings Not Showing

**Debug Steps:**
```
1. Check date range filter
   → Ensure correct dates selected

2. Check unit filter
   → Ensure correct unit selected

3. Refresh calendar
   → Click refresh button

4. Check booking status filter
   → May be filtered to specific status

5. Sync iCal
   → Settings → Integrations → Sync Now
```

### 5.2. Calendar Sync Failed

**iCal Troubleshooting:**

| Error | Solution |
|-------|----------|
| "Invalid URL" | Verify iCal URL is correct |
| "Access denied" | Check if URL is public |
| "Parse error" | iCal format may be invalid |
| "Timeout" | Source server may be slow |

**Verify iCal URL:**
```
1. Copy iCal URL
2. Paste in browser address bar
3. Should download .ics file
4. If 404 error → URL is wrong
5. If login page → URL is private
```

### 5.3. Booking Conflicts

**Conflict Resolution:**
```
When system shows "Booking conflict":

1. Check overlapping dates
   → Existing booking on those dates

2. Check checkout/checkin same day
   → System may not allow same-day turnover

3. Check blocked dates
   → Owner may have blocked dates

4. Resolution:
   → Modify dates
   → Cancel conflicting booking
   → Adjust checkout time settings
```

---

## 6. OCR & Document Scanning Issues

### 6.1. OCR Not Recognizing Document

**Common Issues:**

| Problem | Solution |
|---------|----------|
| Blurry image | Hold tablet steady |
| Poor lighting | Improve light conditions |
| Glare on document | Tilt document slightly |
| Wrong document type | Select correct type |
| Damaged document | Use manual entry |

**Optimal Scanning Conditions:**
```
✓ Well-lit room (natural or artificial)
✓ Document flat on surface
✓ No glare or shadows
✓ Document fills 70% of frame
✓ Hold steady for 2 seconds
✓ Clean camera lens
```

### 6.2. Wrong Data Extracted

**If OCR extracts incorrect data:**
```
1. Review extracted data on confirmation screen
2. Tap any field to edit manually
3. Correct the information
4. Proceed with corrected data
5. Consider using manual entry for problematic documents
```

### 6.3. Supported Documents

| Document Type | Countries | Success Rate |
|---------------|-----------|--------------|
| EU ID Card | All EU | 95% |
| Passport (MRZ) | Worldwide | 98% |
| Driving License | EU | 85% |
| Residence Permit | EU | 80% |

---

## 7. Cleaning Module Issues

### 7.1. Cleaner Cannot Log In

**PIN Issues:**
```
1. Verify correct 4-digit PIN
2. PIN is case-sensitive (if alphanumeric)
3. Check if cleaner account is active
4. Reset PIN in Admin Panel:
   → Cleaning → Cleaners → [Cleaner] → Reset PIN
```

### 7.2. Checklist Not Loading

**Solutions:**
```
1. Check internet connection
2. Force sync: Pull down to refresh
3. Clear app cache
4. Re-login to cleaner mode
5. Verify checklist assigned to unit
```

### 7.3. Photos Not Uploading

**Photo Upload Requirements:**
```
✓ Internet connection (WiFi recommended)
✓ Storage space available
✓ Photo permission granted
✓ Max 10 photos per log
✓ Max 5MB per photo
```

---

## 8. Integration Issues

### 8.1. Airbnb iCal Not Syncing

**Verification Steps:**
```
1. Get fresh iCal URL from Airbnb
   → Calendar → Export Calendar → Copy link

2. Test URL in browser
   → Should download .ics file

3. Re-add in Vesta Lumina
   → Settings → Integrations → Remove old → Add new

4. Manual sync
   → Click Sync Now

5. Wait 15 minutes for initial sync
```

### 8.2. Booking.com Integration

**Common Issues:**

| Issue | Solution |
|-------|----------|
| Bookings not importing | Verify iCal URL is public |
| Double bookings | Check for duplicate integrations |
| Missing details | iCal only syncs dates, not guest info |
| Delayed updates | iCal syncs hourly |

### 8.3. Email Notifications Not Sending

**Debug Steps:**
```
1. Check spam folder
2. Verify email in settings
3. Check notification preferences
4. Test with another email
5. Check SendGrid status (if admin)
```

---

## 9. Performance Issues

### 9.1. Admin Panel Slow

**Optimization Steps:**

| Area | Action |
|------|--------|
| Browser | Use Chrome for best performance |
| Cache | Clear cache and cookies |
| Extensions | Disable unnecessary extensions |
| Tabs | Close unused tabs |
| Date range | Reduce calendar date range |
| Filters | Use filters to limit data |

### 9.2. Tablet Running Slow

**Optimization:**
```
1. Close background apps
   → Recent apps → Close all

2. Clear app cache
   → Settings → Apps → Vesta Lumina → Clear cache

3. Check storage
   → Min 500MB free required

4. Restart tablet daily
   → Improves performance

5. Update app
   → Install latest version
```

### 9.3. Large File Uploads Failing

**Limits:**
```
Image uploads: Max 10MB per file
PDF generation: Max 50 pages
CSV export: Max 10,000 rows
Batch operations: Max 100 items
```

---

## 10. Error Code Reference

### 10.1. Authentication Errors

| Code | Message | Solution |
|------|---------|----------|
| AUTH001 | Invalid credentials | Check email/password |
| AUTH002 | Session expired | Log in again |
| AUTH003 | Account disabled | Contact support |
| AUTH004 | Too many attempts | Wait 15 minutes |
| AUTH005 | MFA required | Enter 2FA code |

### 10.2. Database Errors

| Code | Message | Solution |
|------|---------|----------|
| DB001 | Read failed | Check permissions |
| DB002 | Write failed | Check data validity |
| DB003 | Document not found | Resource may be deleted |
| DB004 | Permission denied | Insufficient access |
| DB005 | Quota exceeded | Contact support |

### 10.3. Network Errors

| Code | Message | Solution |
|------|---------|----------|
| NET001 | Connection timeout | Check internet |
| NET002 | Server unreachable | Check Firebase status |
| NET003 | SSL error | Check date/time settings |
| NET004 | DNS resolution failed | Try different network |

### 10.4. Function Errors

| Code | Message | Solution |
|------|---------|----------|
| FN001 | Function timeout | Retry operation |
| FN002 | Invalid input | Check data format |
| FN003 | Rate limited | Wait and retry |
| FN004 | Internal error | Contact support |

---

## Support Escalation

### When to Contact Support

```
Contact support if:
☐ Issue persists after troubleshooting
☐ Error code not in reference
☐ Data appears corrupted
☐ Security concern
☐ System outage
```

### Support Channels

| Channel | Response Time | Best For |
|---------|---------------|----------|
| In-app chat | Minutes | Quick questions |
| Email | 4-24 hours | Detailed issues |
| Phone | Immediate | Urgent issues |
| Documentation | Self-service | Common questions |

### Information to Provide

```
When contacting support, include:
☐ Account email
☐ Error message (screenshot)
☐ Steps to reproduce
☐ Device/browser info
☐ When issue started
☐ What you've tried
```

---

<p align="center">
  <strong>VESTA LUMINA TROUBLESHOOTING GUIDE</strong><br>
  <em>Version 2.1.0</em><br><br>
  © 2024-2026 Vesta Lumina d.o.o.
</p>
