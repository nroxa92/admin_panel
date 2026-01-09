// FILE: lib/config/app_config.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 2.0.0 - Phase 1 Production Readiness

import 'package:flutter/foundation.dart';

/// Centralized Application Configuration
class AppConfig {
  AppConfig._();

  // =====================================================
  // APP INFO
  // =====================================================

  static const String appName = 'VLS Admin Panel';
  static const String appVersion = '2.0.0';
  static const String appBuildNumber = '1';

  // =====================================================
  // FIREBASE CONFIG
  // =====================================================

  static const String firebaseProjectId = 'vls-admin';
  static const String functionsRegion = 'europe-west3';

  // =====================================================
  // SUPER ADMIN
  // =====================================================

  static const String superAdminEmail = 'vestaluminasystem@gmail.com';

  static bool isSuperAdmin(String? email) {
    if (email == null) return false;
    return email.toLowerCase() == superAdminEmail.toLowerCase();
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
    debugPrint('📋 VLS APP CONFIG v$appVersion');
    debugPrint('═══════════════════════════════════════════');
    debugPrint('Firebase: $firebaseProjectId');
    debugPrint('Super Admin: $superAdminEmail');
    debugPrint('Sentry: $enableSentry');
    debugPrint('═══════════════════════════════════════════');
  }
}
