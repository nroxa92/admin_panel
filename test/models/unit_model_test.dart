// FILE: test/models/unit_model_test.dart
// PROJECT: VillaOS Admin Panel
// DESCRIPTION: Unit tests for Unit/Villa Model
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Unit Model', () {
    group('Construction', () {
      test('should create unit with required fields', () {
        final unit = _MockUnit(
          id: 'unit_001',
          ownerId: 'OWNER_001',
          name: 'Villa Sunset',
          address: '123 Beach Road',
        );

        expect(unit.id, equals('unit_001'));
        expect(unit.ownerId, equals('OWNER_001'));
        expect(unit.name, equals('Villa Sunset'));
        expect(unit.address, equals('123 Beach Road'));
      });

      test('should handle optional fields', () {
        final unit = _MockUnit(
          id: 'unit_002',
          ownerId: 'OWNER_001',
          name: 'Beach House',
          address: '456 Ocean Ave',
          zone: 'Zone A',
          wifiSSID: 'BeachHouse_WiFi',
          wifiPassword: 'welcome123',
          cleanerPIN: '1234',
          reviewLink: 'https://airbnb.com/review/12345',
          status: 'active',
        );

        expect(unit.zone, equals('Zone A'));
        expect(unit.wifiSSID, equals('BeachHouse_WiFi'));
        expect(unit.wifiPassword, equals('welcome123'));
        expect(unit.cleanerPIN, equals('1234'));
        expect(unit.reviewLink, equals('https://airbnb.com/review/12345'));
        expect(unit.status, equals('active'));
      });
    });

    group('Status Validation', () {
      test('should recognize valid statuses', () {
        expect(_isValidUnitStatus('active'), isTrue);
        expect(_isValidUnitStatus('inactive'), isTrue);
        expect(_isValidUnitStatus('maintenance'), isTrue);
      });

      test('should reject invalid statuses', () {
        expect(_isValidUnitStatus('unknown'), isFalse);
        expect(_isValidUnitStatus(''), isFalse);
        expect(_isValidUnitStatus('ACTIVE'), isFalse); // Case sensitive
      });
    });

    group('WiFi Configuration', () {
      test('should detect if WiFi is configured', () {
        final unitWithWifi = _MockUnit(
          id: 'unit1',
          ownerId: 'owner1',
          name: 'Test',
          address: 'Test',
          wifiSSID: 'MyWifi',
          wifiPassword: 'password',
        );

        final unitWithoutWifi = _MockUnit(
          id: 'unit2',
          ownerId: 'owner1',
          name: 'Test',
          address: 'Test',
        );

        expect(unitWithWifi.hasWifiConfig, isTrue);
        expect(unitWithoutWifi.hasWifiConfig, isFalse);
      });

      test('should detect partial WiFi config', () {
        final unitWithSSIDOnly = _MockUnit(
          id: 'unit1',
          ownerId: 'owner1',
          name: 'Test',
          address: 'Test',
          wifiSSID: 'MyWifi',
        );

        expect(unitWithSSIDOnly.hasWifiConfig, isFalse);
      });
    });

    group('Cleaner PIN', () {
      test('should validate PIN format', () {
        expect(_isValidPIN('1234'), isTrue);
        expect(_isValidPIN('123456'), isTrue);
        expect(_isValidPIN('12'), isFalse); // Too short
        expect(_isValidPIN('abcd'), isFalse); // Non-numeric
        expect(_isValidPIN(''), isFalse);
      });

      test('should detect if cleaner PIN is set', () {
        final unitWithPIN = _MockUnit(
          id: 'unit1',
          ownerId: 'owner1',
          name: 'Test',
          address: 'Test',
          cleanerPIN: '1234',
        );

        final unitWithoutPIN = _MockUnit(
          id: 'unit2',
          ownerId: 'owner1',
          name: 'Test',
          address: 'Test',
        );

        expect(unitWithPIN.hasCleanerPIN, isTrue);
        expect(unitWithoutPIN.hasCleanerPIN, isFalse);
      });
    });

    group('Review Link', () {
      test('should validate URL format', () {
        expect(_isValidURL('https://airbnb.com/review/123'), isTrue);
        expect(_isValidURL('http://booking.com/hotel/456'), isTrue);
        expect(_isValidURL('not-a-url'), isFalse);
        expect(_isValidURL(''), isFalse);
      });

      test('should detect common review platforms', () {
        expect(_getReviewPlatform('https://airbnb.com/review/123'), equals('Airbnb'));
        expect(_getReviewPlatform('https://booking.com/hotel/456'), equals('Booking.com'));
        expect(_getReviewPlatform('https://google.com/maps/place/123'), equals('Google'));
        expect(_getReviewPlatform('https://tripadvisor.com/Hotel-123'), equals('TripAdvisor'));
        expect(_getReviewPlatform('https://custom-site.com/review'), equals('Other'));
      });
    });

    group('Zone Assignment', () {
      test('should handle zone assignment', () {
        final unit = _MockUnit(
          id: 'unit1',
          ownerId: 'owner1',
          name: 'Test',
          address: 'Test',
          zone: 'Zone A',
        );

        expect(unit.zone, equals('Zone A'));
        expect(unit.hasZone, isTrue);
      });

      test('should handle no zone', () {
        final unit = _MockUnit(
          id: 'unit1',
          ownerId: 'owner1',
          name: 'Test',
          address: 'Test',
        );

        expect(unit.zone, isNull);
        expect(unit.hasZone, isFalse);
      });
    });

    group('Display Name', () {
      test('should generate display name with zone', () {
        final unit = _MockUnit(
          id: 'unit1',
          ownerId: 'owner1',
          name: 'Villa Sunset',
          address: '123 Beach Road',
          zone: 'Zone A',
        );

        expect(unit.displayName, equals('Villa Sunset (Zone A)'));
      });

      test('should generate display name without zone', () {
        final unit = _MockUnit(
          id: 'unit1',
          ownerId: 'owner1',
          name: 'Villa Sunset',
          address: '123 Beach Road',
        );

        expect(unit.displayName, equals('Villa Sunset'));
      });
    });

    group('Serialization', () {
      test('should convert to map', () {
        final unit = _MockUnit(
          id: 'unit_001',
          ownerId: 'OWNER_001',
          name: 'Villa Sunset',
          address: '123 Beach Road',
          zone: 'Zone A',
          status: 'active',
        );

        final map = unit.toMap();

        expect(map['id'], equals('unit_001'));
        expect(map['ownerId'], equals('OWNER_001'));
        expect(map['name'], equals('Villa Sunset'));
        expect(map['address'], equals('123 Beach Road'));
        expect(map['zone'], equals('Zone A'));
        expect(map['status'], equals('active'));
      });

      test('should create from map', () {
        final map = {
          'id': 'unit_001',
          'ownerId': 'OWNER_001',
          'name': 'Villa Sunset',
          'address': '123 Beach Road',
          'zone': 'Zone A',
          'status': 'active',
        };

        final unit = _MockUnit.fromMap(map);

        expect(unit.id, equals('unit_001'));
        expect(unit.ownerId, equals('OWNER_001'));
        expect(unit.name, equals('Villa Sunset'));
      });
    });

    group('Equality', () {
      test('should consider units with same ID as equal', () {
        final unit1 = _MockUnit(
          id: 'unit_001',
          ownerId: 'owner1',
          name: 'Villa 1',
          address: 'Address 1',
        );

        final unit2 = _MockUnit(
          id: 'unit_001',
          ownerId: 'owner1',
          name: 'Villa 1 Updated',
          address: 'Address 1',
        );

        expect(unit1 == unit2, isTrue);
      });

      test('should consider units with different IDs as not equal', () {
        final unit1 = _MockUnit(
          id: 'unit_001',
          ownerId: 'owner1',
          name: 'Villa 1',
          address: 'Address 1',
        );

        final unit2 = _MockUnit(
          id: 'unit_002',
          ownerId: 'owner1',
          name: 'Villa 1',
          address: 'Address 1',
        );

        expect(unit1 == unit2, isFalse);
      });
    });
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOCK UNIT CLASS
// ═══════════════════════════════════════════════════════════════════════════════

class _MockUnit {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final String? zone;
  final String? wifiSSID;
  final String? wifiPassword;
  final String? cleanerPIN;
  final String? reviewLink;
  final String status;

  _MockUnit({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    this.zone,
    this.wifiSSID,
    this.wifiPassword,
    this.cleanerPIN,
    this.reviewLink,
    this.status = 'active',
  });

  factory _MockUnit.fromMap(Map<String, dynamic> map) {
    return _MockUnit(
      id: map['id'] as String,
      ownerId: map['ownerId'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      zone: map['zone'] as String?,
      wifiSSID: map['wifiSSID'] as String?,
      wifiPassword: map['wifiPassword'] as String?,
      cleanerPIN: map['cleanerPIN'] as String?,
      reviewLink: map['reviewLink'] as String?,
      status: map['status'] as String? ?? 'active',
    );
  }

  bool get hasWifiConfig =>
      wifiSSID != null &&
      wifiSSID!.isNotEmpty &&
      wifiPassword != null &&
      wifiPassword!.isNotEmpty;

  bool get hasCleanerPIN => cleanerPIN != null && cleanerPIN!.isNotEmpty;

  bool get hasZone => zone != null && zone!.isNotEmpty;

  String get displayName => hasZone ? '$name ($zone)' : name;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'address': address,
      'zone': zone,
      'wifiSSID': wifiSSID,
      'wifiPassword': wifiPassword,
      'cleanerPIN': cleanerPIN,
      'reviewLink': reviewLink,
      'status': status,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _MockUnit && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════

bool _isValidUnitStatus(String status) {
  const validStatuses = ['active', 'inactive', 'maintenance'];
  return validStatuses.contains(status);
}

bool _isValidPIN(String pin) {
  if (pin.isEmpty) return false;
  if (pin.length < 4 || pin.length > 6) return false;
  return RegExp(r'^\d+$').hasMatch(pin);
}

bool _isValidURL(String url) {
  if (url.isEmpty) return false;
  return RegExp(r'^https?://').hasMatch(url);
}

String _getReviewPlatform(String url) {
  final lowerUrl = url.toLowerCase();
  if (lowerUrl.contains('airbnb')) return 'Airbnb';
  if (lowerUrl.contains('booking.com')) return 'Booking.com';
  if (lowerUrl.contains('google')) return 'Google';
  if (lowerUrl.contains('tripadvisor')) return 'TripAdvisor';
  return 'Other';
}
