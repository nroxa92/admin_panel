// FILE: test/helpers/test_helpers.dart
// PROJECT: VillaOS Admin Panel
// DESCRIPTION: Test helpers, mocks, and utilities
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// TEST DATA GENERATORS
// ═══════════════════════════════════════════════════════════════════════════════

/// Generate mock booking data
Map<String, dynamic> createMockBookingData({
  String? id,
  String? ownerId,
  String? unitId,
  String? guestName,
  int? guestCount,
  DateTime? startDate,
  DateTime? endDate,
  String? status,
  double? totalPrice,
  String? currency,
  String? source,
}) {
  final now = DateTime.now();
  return {
    'id': id ?? 'booking_${now.millisecondsSinceEpoch}',
    'ownerId': ownerId ?? 'TEST_OWNER_001',
    'unitId': unitId ?? 'UNIT_001',
    'guestName': guestName ?? 'Test Guest',
    'guestCount': guestCount ?? 2,
    'startDate': Timestamp.fromDate(startDate ?? now),
    'endDate': Timestamp.fromDate(endDate ?? now.add(const Duration(days: 3))),
    'status': status ?? 'confirmed',
    'totalPrice': totalPrice ?? 299.99,
    'currency': currency ?? 'EUR',
    'source': source ?? 'direct',
    'notes': '',
    'createdAt': Timestamp.fromDate(now),
    'updatedAt': Timestamp.fromDate(now),
  };
}

/// Generate mock unit data
Map<String, dynamic> createMockUnitData({
  String? id,
  String? ownerId,
  String? name,
  String? address,
  String? zone,
  String? status,
}) {
  return {
    'id': id ?? 'unit_001',
    'ownerId': ownerId ?? 'TEST_OWNER_001',
    'name': name ?? 'Villa Sunset',
    'address': address ?? '123 Beach Road, Split',
    'zone': zone ?? 'Zone A',
    'wifiSSID': 'VillaSunset_WiFi',
    'wifiPassword': 'welcome123',
    'cleanerPIN': '1234',
    'reviewLink': 'https://airbnb.com/review/12345',
    'status': status ?? 'active',
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
  };
}

/// Generate mock guest data
Map<String, dynamic> createMockGuestData({
  String? firstName,
  String? lastName,
  String? nationality,
  String? documentType,
  String? documentNumber,
}) {
  return {
    'firstName': firstName ?? 'John',
    'lastName': lastName ?? 'Doe',
    'dateOfBirth': Timestamp.fromDate(DateTime(1990, 5, 15)),
    'nationality': nationality ?? 'USA',
    'documentType': documentType ?? 'passport',
    'documentNumber': documentNumber ?? 'AB1234567',
    'scannedAt': Timestamp.now(),
  };
}

/// Generate mock settings data
Map<String, dynamic> createMockSettingsData({
  String? ownerId,
  String? language,
  String? primaryColor,
}) {
  return {
    'ownerId': ownerId ?? 'TEST_OWNER_001',
    'language': language ?? 'en',
    'primaryColor': primaryColor ?? '#D4AF37',
    'backgroundTone': 'dark',
    'cleanerPIN': '0000',
    'resetPIN': '1234',
    'houseRules': {
      'en': 'No smoking. No parties.',
      'hr': 'Zabranjeno pušenje. Zabranjena zabave.',
    },
    'cleanerChecklist': [
      'Check bedsheets',
      'Clean bathroom',
      'Restock supplies'
    ],
    'aiKnowledge': {
      'concierge': '',
      'housekeeper': '',
      'tech': '',
      'guide': '',
    },
    'contactEmail': 'owner@test.com',
    'ownerFirstName': 'Test',
    'ownerLastName': 'Owner',
    'companyName': 'Test Villas Ltd',
    'emailNotifications': true,
    'checkInTime': '15:00',
    'checkOutTime': '10:00',
  };
}

/// Generate mock cleaning log data
Map<String, dynamic> createMockCleaningLogData({
  String? unitId,
  String? status,
}) {
  return {
    'ownerId': 'TEST_OWNER_001',
    'unitId': unitId ?? 'UNIT_001',
    'cleanerName': 'Maria',
    'status': status ?? 'completed',
    'timestamp': Timestamp.now(),
    'notes': 'All clean',
    'photoUrls': [],
  };
}

// ═══════════════════════════════════════════════════════════════════════════════
// WIDGET TEST HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

/// Wrap a widget with MaterialApp for testing
Widget wrapWithMaterialApp(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? _buildTestTheme(),
    home: Scaffold(body: child),
  );
}

/// Wrap a widget with all necessary providers for testing
Widget wrapWithProviders(Widget child) {
  return MaterialApp(
    theme: _buildTestTheme(),
    home: child,
  );
}

/// Build test theme matching production
ThemeData _buildTestTheme() {
  return ThemeData.dark().copyWith(
    primaryColor: const Color(0xFFD4AF37),
    scaffoldBackgroundColor: const Color(0xFF0a0a0a),
    cardColor: const Color(0xFF1E1E1E),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.black,
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// DATE/TIME HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

/// Get date range for testing (this week)
DateTimeRange getThisWeekRange() {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 6));
  return DateTimeRange(start: startOfWeek, end: endOfWeek);
}

/// Get date range for testing (this month)
DateTimeRange getThisMonthRange() {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0);
  return DateTimeRange(start: startOfMonth, end: endOfMonth);
}

/// Create a list of consecutive dates
List<DateTime> getConsecutiveDates(int count, {DateTime? startFrom}) {
  final start = startFrom ?? DateTime.now();
  return List.generate(count, (i) => start.add(Duration(days: i)));
}

// ═══════════════════════════════════════════════════════════════════════════════
// VALIDATION HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

/// Validate email format
bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

/// Validate tenant ID format
bool isValidTenantId(String tenantId) {
  return RegExp(r'^[A-Z0-9]{6,12}$').hasMatch(tenantId);
}

/// Validate PIN format
bool isValidPIN(String pin) {
  return RegExp(r'^\d{4,6}$').hasMatch(pin);
}

// ═══════════════════════════════════════════════════════════════════════════════
// ASYNC TEST HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

/// Wait for async operations to complete
Future<void> pumpAndSettle(WidgetTester tester, {Duration? duration}) async {
  await tester.pumpAndSettle(duration ?? const Duration(seconds: 1));
}

/// Wait for a specific condition
Future<void> waitFor(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
  Duration interval = const Duration(milliseconds: 100),
}) async {
  final stopwatch = Stopwatch()..start();
  while (!condition() && stopwatch.elapsed < timeout) {
    await Future.delayed(interval);
  }
  if (!condition()) {
    throw TimeoutException('Condition not met within timeout', timeout);
  }
}

/// Exception for timeout
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  TimeoutException(this.message, this.timeout);

  @override
  String toString() =>
      'TimeoutException: $message (after ${timeout.inSeconds}s)';
}

// ═══════════════════════════════════════════════════════════════════════════════
// REVENUE TEST HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

/// Generate mock revenue data for testing
List<Map<String, dynamic>> generateMockRevenueData({
  int months = 12,
  double baseAmount = 5000.0,
}) {
  final now = DateTime.now();
  return List.generate(months, (i) {
    final month = DateTime(now.year, now.month - i, 1);
    final variation = (i % 3 == 0)
        ? 1.2
        : (i % 2 == 0)
            ? 0.8
            : 1.0;
    return {
      'month': month.toIso8601String(),
      'revenue': baseAmount * variation,
      'bookings': (10 + i) * variation.toInt(),
      'occupancy': 0.6 + (i * 0.02),
    };
  });
}

/// Calculate expected occupancy rate
double calculateOccupancy(int bookedNights, int totalNights) {
  if (totalNights == 0) return 0.0;
  return bookedNights / totalNights;
}
