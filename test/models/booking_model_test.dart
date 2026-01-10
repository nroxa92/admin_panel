// FILE: test/models/booking_model_test.dart
// PROJECT: VillaOS Admin Panel
// DESCRIPTION: Unit tests for Booking Model
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Booking Model', () {
    group('Construction', () {
      test('should create booking with required fields', () {
        final booking = _MockBooking(
          id: 'booking_001',
          ownerId: 'OWNER_001',
          unitId: 'UNIT_001',
          guestName: 'John Doe',
          guestCount: 2,
          startDate: DateTime(2024, 6, 15),
          endDate: DateTime(2024, 6, 20),
          status: 'confirmed',
        );

        expect(booking.id, equals('booking_001'));
        expect(booking.ownerId, equals('OWNER_001'));
        expect(booking.unitId, equals('UNIT_001'));
        expect(booking.guestName, equals('John Doe'));
        expect(booking.guestCount, equals(2));
        expect(booking.status, equals('confirmed'));
      });

      test('should handle optional fields', () {
        final booking = _MockBooking(
          id: 'booking_002',
          ownerId: 'OWNER_001',
          unitId: 'UNIT_001',
          guestName: 'Jane Doe',
          guestCount: 1,
          startDate: DateTime(2024, 7, 1),
          endDate: DateTime(2024, 7, 5),
          status: 'confirmed',
          totalPrice: 599.99,
          currency: 'EUR',
          source: 'airbnb',
          notes: 'Early check-in requested',
        );

        expect(booking.totalPrice, equals(599.99));
        expect(booking.currency, equals('EUR'));
        expect(booking.source, equals('airbnb'));
        expect(booking.notes, equals('Early check-in requested'));
      });
    });

    group('Duration Calculation', () {
      test('should calculate nights correctly', () {
        final booking = _MockBooking(
          id: 'test',
          ownerId: 'owner',
          unitId: 'unit',
          guestName: 'Guest',
          guestCount: 1,
          startDate: DateTime(2024, 6, 15),
          endDate: DateTime(2024, 6, 20),
          status: 'confirmed',
        );

        expect(booking.nights, equals(5));
      });

      test('should handle same day booking (0 nights)', () {
        final booking = _MockBooking(
          id: 'test',
          ownerId: 'owner',
          unitId: 'unit',
          guestName: 'Guest',
          guestCount: 1,
          startDate: DateTime(2024, 6, 15),
          endDate: DateTime(2024, 6, 15),
          status: 'confirmed',
        );

        expect(booking.nights, equals(0));
      });

      test('should calculate long stay correctly', () {
        final booking = _MockBooking(
          id: 'test',
          ownerId: 'owner',
          unitId: 'unit',
          guestName: 'Guest',
          guestCount: 1,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
          status: 'confirmed',
        );

        expect(booking.nights, equals(30));
      });
    });

    group('Status Validation', () {
      test('should recognize valid statuses', () {
        final validStatuses = ['confirmed', 'pending', 'cancelled', 'private'];

        for (final status in validStatuses) {
          expect(_isValidStatus(status), isTrue,
              reason: 'Status "$status" should be valid');
        }
      });

      test('should reject invalid statuses', () {
        final invalidStatuses = ['invalid', 'unknown', '', 'CONFIRMED'];

        for (final status in invalidStatuses) {
          expect(_isValidStatus(status), isFalse,
              reason: 'Status "$status" should be invalid');
        }
      });
    });

    group('Date Overlap Detection', () {
      test('should detect overlapping bookings', () {
        final booking1Start = DateTime(2024, 6, 15);
        final booking1End = DateTime(2024, 6, 20);
        final booking2Start = DateTime(2024, 6, 18);
        final booking2End = DateTime(2024, 6, 25);

        expect(
          _datesOverlap(booking1Start, booking1End, booking2Start, booking2End),
          isTrue,
        );
      });

      test('should detect adjacent bookings as non-overlapping', () {
        // Check-out day = Check-in day (allowed)
        final booking1Start = DateTime(2024, 6, 15);
        final booking1End = DateTime(2024, 6, 20);
        final booking2Start = DateTime(2024, 6, 20);
        final booking2End = DateTime(2024, 6, 25);

        expect(
          _datesOverlap(booking1Start, booking1End, booking2Start, booking2End),
          isFalse,
        );
      });

      test('should detect completely separate bookings', () {
        final booking1Start = DateTime(2024, 6, 1);
        final booking1End = DateTime(2024, 6, 5);
        final booking2Start = DateTime(2024, 6, 15);
        final booking2End = DateTime(2024, 6, 20);

        expect(
          _datesOverlap(booking1Start, booking1End, booking2Start, booking2End),
          isFalse,
        );
      });

      test('should detect booking within another booking', () {
        // Booking 2 is completely inside Booking 1
        final booking1Start = DateTime(2024, 6, 1);
        final booking1End = DateTime(2024, 6, 30);
        final booking2Start = DateTime(2024, 6, 10);
        final booking2End = DateTime(2024, 6, 15);

        expect(
          _datesOverlap(booking1Start, booking1End, booking2Start, booking2End),
          isTrue,
        );
      });
    });

    group('Price Calculation', () {
      test('should calculate price per night', () {
        final booking = _MockBooking(
          id: 'test',
          ownerId: 'owner',
          unitId: 'unit',
          guestName: 'Guest',
          guestCount: 1,
          startDate: DateTime(2024, 6, 15),
          endDate: DateTime(2024, 6, 20), // 5 nights
          status: 'confirmed',
          totalPrice: 500.0,
        );

        expect(booking.pricePerNight, equals(100.0));
      });

      test('should handle zero nights gracefully', () {
        final booking = _MockBooking(
          id: 'test',
          ownerId: 'owner',
          unitId: 'unit',
          guestName: 'Guest',
          guestCount: 1,
          startDate: DateTime(2024, 6, 15),
          endDate: DateTime(2024, 6, 15), // 0 nights
          status: 'confirmed',
          totalPrice: 100.0,
        );

        expect(booking.pricePerNight, equals(0.0)); // Avoid division by zero
      });

      test('should handle null price', () {
        final booking = _MockBooking(
          id: 'test',
          ownerId: 'owner',
          unitId: 'unit',
          guestName: 'Guest',
          guestCount: 1,
          startDate: DateTime(2024, 6, 15),
          endDate: DateTime(2024, 6, 20),
          status: 'confirmed',
          totalPrice: null,
        );

        expect(booking.pricePerNight, equals(0.0));
      });
    });

    group('Active Booking Check', () {
      test('should identify currently active booking', () {
        final now = DateTime.now();
        final booking = _MockBooking(
          id: 'test',
          ownerId: 'owner',
          unitId: 'unit',
          guestName: 'Guest',
          guestCount: 1,
          startDate: now.subtract(const Duration(days: 2)),
          endDate: now.add(const Duration(days: 2)),
          status: 'confirmed',
        );

        expect(booking.isActive, isTrue);
      });

      test('should identify past booking as inactive', () {
        final now = DateTime.now();
        final booking = _MockBooking(
          id: 'test',
          ownerId: 'owner',
          unitId: 'unit',
          guestName: 'Guest',
          guestCount: 1,
          startDate: now.subtract(const Duration(days: 10)),
          endDate: now.subtract(const Duration(days: 5)),
          status: 'confirmed',
        );

        expect(booking.isActive, isFalse);
      });

      test('should identify future booking as inactive', () {
        final now = DateTime.now();
        final booking = _MockBooking(
          id: 'test',
          ownerId: 'owner',
          unitId: 'unit',
          guestName: 'Guest',
          guestCount: 1,
          startDate: now.add(const Duration(days: 5)),
          endDate: now.add(const Duration(days: 10)),
          status: 'confirmed',
        );

        expect(booking.isActive, isFalse);
      });

      test('should identify cancelled booking as inactive', () {
        final now = DateTime.now();
        final booking = _MockBooking(
          id: 'test',
          ownerId: 'owner',
          unitId: 'unit',
          guestName: 'Guest',
          guestCount: 1,
          startDate: now.subtract(const Duration(days: 2)),
          endDate: now.add(const Duration(days: 2)),
          status: 'cancelled', // Cancelled
        );

        expect(booking.isActive, isFalse);
      });
    });

    group('Serialization', () {
      test('should convert to map correctly', () {
        final booking = _MockBooking(
          id: 'booking_001',
          ownerId: 'OWNER_001',
          unitId: 'UNIT_001',
          guestName: 'John Doe',
          guestCount: 2,
          startDate: DateTime(2024, 6, 15),
          endDate: DateTime(2024, 6, 20),
          status: 'confirmed',
          totalPrice: 500.0,
          currency: 'EUR',
        );

        final map = booking.toMap();

        expect(map['id'], equals('booking_001'));
        expect(map['ownerId'], equals('OWNER_001'));
        expect(map['unitId'], equals('UNIT_001'));
        expect(map['guestName'], equals('John Doe'));
        expect(map['guestCount'], equals(2));
        expect(map['status'], equals('confirmed'));
        expect(map['totalPrice'], equals(500.0));
        expect(map['currency'], equals('EUR'));
      });
    });
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOCK BOOKING CLASS
// ═══════════════════════════════════════════════════════════════════════════════

class _MockBooking {
  final String id;
  final String ownerId;
  final String unitId;
  final String guestName;
  final int guestCount;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final double? totalPrice;
  final String? currency;
  final String? source;
  final String? notes;

  _MockBooking({
    required this.id,
    required this.ownerId,
    required this.unitId,
    required this.guestName,
    required this.guestCount,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.totalPrice,
    this.currency,
    this.source,
    this.notes,
  });

  int get nights => endDate.difference(startDate).inDays;

  double get pricePerNight {
    if (totalPrice == null || nights == 0) return 0.0;
    return totalPrice! / nights;
  }

  bool get isActive {
    if (status == 'cancelled') return false;
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'unitId': unitId,
      'guestName': guestName,
      'guestCount': guestCount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'totalPrice': totalPrice,
      'currency': currency,
      'source': source,
      'notes': notes,
    };
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════

bool _isValidStatus(String status) {
  const validStatuses = ['confirmed', 'pending', 'cancelled', 'private'];
  return validStatuses.contains(status);
}

bool _datesOverlap(
  DateTime start1,
  DateTime end1,
  DateTime start2,
  DateTime end2,
) {
  // Two ranges overlap if one starts before the other ends
  // BUT checkout day = checkin day is allowed
  return start1.isBefore(end2) && start2.isBefore(end1);
}
