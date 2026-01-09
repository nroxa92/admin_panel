// FILE: lib/config/app_config.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 2.1.0 - Phase 2 Production Readiness

import 'package:flutter/foundation.dart';

/// Centralized Application Configuration
class AppConfig {
  AppConfig._();

  // =====================================================
  // APP INFO
  // =====================================================

  static const String appName = 'VLS Admin Panel';
  static const String appVersion = '2.1.0';
  static const String appBuildNumber = '2';

  // =====================================================
  // FIREBASE CONFIG
  // =====================================================

  static const String firebaseProjectId = 'vls-admin';
  static const String functionsRegion = 'europe-west3';

  // =====================================================
  // SUPER ADMIN (Phase 2: Multiple Admins)
  // =====================================================

  /// Primary Super Admin (cannot be removed)
  static const String primaryAdminEmail = 'vestaluminasystem@gmail.com';

  /// Quick check if email is primary admin
  static bool isPrimaryAdmin(String? email) {
    if (email == null) return false;
    return email.toLowerCase() == primaryAdminEmail.toLowerCase();
  }

  // =====================================================
  // SECURITY SETTINGS
  // =====================================================

  static const int maxPinAttempts = 5;
  static const int pinLockoutMinutes = 15;
  static const int sessionTimeoutMinutes = 30;
  static const int minPinLength = 4;
  static const int maxPinLength = 6;

  // =====================================================
  // FEATURE FLAGS
  // =====================================================

  static const bool enableSentry = !kDebugMode;
  static const bool enableConnectivityMonitoring = true;
  static const bool enableSessionTimeout = true;

  /// Phase 2: Multiple Super Admins
  static const bool enableMultipleSuperAdmins = true;

  /// Phase 2: Automatic Backups
  static const bool enableAutomaticBackups = true;

  /// Phase 2: Admin Activity Logging
  static const bool enableAdminLogging = true;

  // =====================================================
  // BACKUP SETTINGS (Phase 2)
  // =====================================================

  /// How many days to keep backups
  static const int backupRetentionDays = 30;

  /// Collections to backup
  static const List<String> backupCollections = [
    'tenant_links',
    'settings',
    'units',
    'bookings',
    'tablets',
    'super_admins',
  ];

  // =====================================================
  // UI SETTINGS
  // =====================================================

  static const int defaultPrimaryColorValue = 0xFFD4AF37;
  static const int defaultBackgroundColorValue = 0xFF121212;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackbarDuration = Duration(seconds: 3);

  // =====================================================
  // BUSINESS RULES
  // =====================================================

  static const List<String> supportedLanguages = [
    'en',
    'hr',
    'de',
    'it',
    'sk',
    'hu',
    'fr',
    'es',
    'pl',
    'cz',
    'sl'
  ];

  static const String defaultLanguage = 'en';
  static const String defaultCheckInTime = '15:00';
  static const String defaultCheckOutTime = '10:00';

  // =====================================================
  // DEBUG HELPERS
  // =====================================================

  static void printConfig() {
    if (!kDebugMode) return;

    debugPrint('═══════════════════════════════════════════');
    debugPrint('📋 VLS APP CONFIG v$appVersion (Phase 2)');
    debugPrint('═══════════════════════════════════════════');
    debugPrint('Firebase: $firebaseProjectId');
    debugPrint('Primary Admin: $primaryAdminEmail');
    debugPrint('Multiple Admins: $enableMultipleSuperAdmins');
    debugPrint('Auto Backup: $enableAutomaticBackups');
    debugPrint('Admin Logging: $enableAdminLogging');
    debugPrint('Sentry: $enableSentry');
    debugPrint('═══════════════════════════════════════════');
  }
}
