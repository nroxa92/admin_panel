// FILE: lib/config/app_config.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 4.0.0 - Phase 4 Complete

import 'package:flutter/foundation.dart';

/// Centralized Application Configuration
class AppConfig {
  AppConfig._();

  // =====================================================
  // APP INFO
  // =====================================================

  static const String appName = 'VLS Admin Panel';
  static const String appVersion = '4.0.0';
  static const String appBuildNumber = '4';

  // =====================================================
  // FIREBASE CONFIG
  // =====================================================

  static const String firebaseProjectId = 'vls-admin';
  static const String functionsRegion = 'europe-west3';

  // =====================================================
  // SUPER ADMIN
  // =====================================================

  static const String primaryAdminEmail = 'vestaluminasystem@gmail.com';

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

  // Phase 1 Features
  static const bool enableSentry = !kDebugMode;
  static const bool enableConnectivityMonitoring = true;
  static const bool enableSessionTimeout = true;

  // Phase 2 Features
  static const bool enableMultipleSuperAdmins = true;
  static const bool enableAutomaticBackups = true;
  static const bool enableAdminLogging = true;

  // Phase 3 Features
  static const bool enableAnalyticsDashboard = true;
  static const bool enableRepositoryPattern = true;
  static const bool enableUnitTests = true;

  // Phase 4 Features
  static const bool enableOfflineMode = true;
  static const bool enableEmailNotifications = true;
  static const bool enableCalendarExport = true;
  static const bool enableRevenueAnalytics = true;
  static const bool enablePerformanceOptimization = true;

  // =====================================================
  // CACHE SETTINGS (Phase 4)
  // =====================================================

  static const Duration cacheExpiry = Duration(hours: 24);
  static const Duration syncInterval = Duration(hours: 1);
  static const int maxPendingActions = 100;

  // =====================================================
  // EMAIL SETTINGS (Phase 4)
  // =====================================================

  static const int reminderDaysBeforeCheckIn = 1;
  static const bool defaultEmailNotifications = true;

  // =====================================================
  // CALENDAR SETTINGS (Phase 4)
  // =====================================================

  static const String icalTimezone = 'Europe/Zagreb';
  static const String defaultCurrency = 'EUR';

  // =====================================================
  // BACKUP SETTINGS
  // =====================================================

  static const int backupRetentionDays = 30;

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
  // PAGINATION SETTINGS (Phase 4)
  // =====================================================

  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const double lazyLoadThreshold = 200.0;

  // =====================================================
  // ANALYTICS SETTINGS
  // =====================================================

  static const int analyticsDefaultLimit = 100;
  static const int analyticsChartMonths = 12;
  static const int analyticsUpcomingBookingsLimit = 5;

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
    debugPrint('📋 VLS APP CONFIG v$appVersion (Phase 4)');
    debugPrint('═══════════════════════════════════════════');
    debugPrint('Firebase: $firebaseProjectId');
    debugPrint('Primary Admin: $primaryAdminEmail');
    debugPrint('───────────────────────────────────────────');
    debugPrint('Phase 1: Error Tracking, Security');
    debugPrint('Phase 2: Multi-Admin, Backup, Logging');
    debugPrint('Phase 3: Analytics, Repository, Tests');
    debugPrint('Phase 4: Offline, Email, Calendar, Revenue');
    debugPrint('───────────────────────────────────────────');
    debugPrint('Offline Mode: $enableOfflineMode');
    debugPrint('Email Notifications: $enableEmailNotifications');
    debugPrint('Calendar Export: $enableCalendarExport');
    debugPrint('Revenue Analytics: $enableRevenueAnalytics');
    debugPrint('═══════════════════════════════════════════');
  }
}
