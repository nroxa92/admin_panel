// FILE: test/repositories/booking_repository_test.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 3.0.0 - Phase 3 Unit Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:villa_admin/repositories/booking_repository.dart';
import 'package:villa_admin/repositories/base_repository.dart';

void main() {
  group('Booking Model', () {
    test('should calculate stay length correctly', () {
      final booking = Booking(
        id: 'test',
        ownerId: 'owner1',
        unitId: 'unit1',
        unitName: 'Villa Test',
        guestName: 'John Doe',
        guestCount: 2,
        checkIn: DateTime(2024, 1, 1),
        checkOut: DateTime(2024, 1, 5),
        status: 'confirmed',
      );

      expect(booking.stayLength, equals(4));
    });

    test('should calculate 1 night stay correctly', () {
      final booking = Booking(
        id: 'test',
        ownerId: 'owner1',
        unitId: 'unit1',
        unitName: 'Villa Test',
        guestName: 'John Doe',
        guestCount: 1,
        checkIn: DateTime(2024, 1, 1),
        checkOut: DateTime(2024, 1, 2),
        status: 'confirmed',
      );

      expect(booking.stayLength, equals(1));
    });

    test('should create valid map from booking', () {
      final booking = Booking(
        id: 'test',
        ownerId: 'owner1',
        unitId: 'unit1',
        unitName: 'Villa Test',
        guestName: 'John Doe',
        guestEmail: 'john@test.com',
        guestPhone: '+1234567890',
        guestCount: 2,
        checkIn: DateTime(2024, 1, 1),
        checkOut: DateTime(2024, 1, 5),
        status: 'confirmed',
        notes: 'Late arrival',
        source: 'direct',
      );

      final map = booking.toMap();

      expect(map['ownerId'], equals('owner1'));
      expect(map['unitId'], equals('unit1'));
      expect(map['unitName'], equals('Villa Test'));
      expect(map['guestName'], equals('John Doe'));
      expect(map['guestEmail'], equals('john@test.com'));
      expect(map['guestPhone'], equals('+1234567890'));
      expect(map['guestCount'], equals(2));
      expect(map['status'], equals('confirmed'));
      expect(map['notes'], equals('Late arrival'));
      expect(map['source'], equals('direct'));
      expect(map['checkIn'], isA<Timestamp>());
      expect(map['checkOut'], isA<Timestamp>());
    });
  });

  group('Guest Model', () {
    test('should return full name correctly', () {
      final guest = Guest(
        id: 'guest1',
        firstName: 'John',
        lastName: 'Doe',
      );

      expect(guest.fullName, equals('John Doe'));
    });

    test('should create valid map from guest', () {
      final guest = Guest(
        id: 'guest1',
        firstName: 'John',
        lastName: 'Doe',
        documentType: 'passport',
        documentNumber: 'AB123456',
        nationality: 'US',
        dateOfBirth: DateTime(1990, 5, 15),
        signatureUrl: 'https://example.com/sig.png',
      );

      final map = guest.toMap();

      expect(map['firstName'], equals('John'));
      expect(map['lastName'], equals('Doe'));
      expect(map['documentType'], equals('passport'));
      expect(map['documentNumber'], equals('AB123456'));
      expect(map['nationality'], equals('US'));
      expect(map['signatureUrl'], equals('https://example.com/sig.png'));
      expect(map['dateOfBirth'], isA<Timestamp>());
    });

    test('should handle null optional fields', () {
      final guest = Guest(
        id: 'guest1',
        firstName: 'John',
        lastName: 'Doe',
      );

      final map = guest.toMap();

      expect(map['documentType'], isNull);
      expect(map['documentNumber'], isNull);
      expect(map['nationality'], isNull);
      expect(map['dateOfBirth'], isNull);
      expect(map['signatureUrl'], isNull);
    });
  });

  group('BookingStats Model', () {
    test('should calculate completion rate correctly', () {
      final stats = BookingStats(
        totalBookings: 100,
        totalGuests: 200,
        totalNights: 300,
        completedBookings: 80,
        cancelledBookings: 10,
        averageStayLength: 3.0,
      );

      expect(stats.completionRate, equals(80.0));
    });

    test('should calculate cancellation rate correctly', () {
      final stats = BookingStats(
        totalBookings: 100,
        totalGuests: 200,
        totalNights: 300,
        completedBookings: 80,
        cancelledBookings: 10,
        averageStayLength: 3.0,
      );

      expect(stats.cancellationRate, equals(10.0));
    });

    test('should handle zero bookings for rates', () {
      final stats = BookingStats(
        totalBookings: 0,
        totalGuests: 0,
        totalNights: 0,
        completedBookings: 0,
        cancelledBookings: 0,
        averageStayLength: 0,
      );

      expect(stats.completionRate, equals(0.0));
      expect(stats.cancellationRate, equals(0.0));
    });
  });

  group('QueryFilter', () {
    test('should create equals filter', () {
      final filter = QueryFilter.equals('field', 'value');

      expect(filter.field, equals('field'));
      expect(filter.operator, equals(FilterOperator.equals));
      expect(filter.value, equals('value'));
    });

    test('should create greaterThan filter', () {
      final filter = QueryFilter.greaterThan('count', 10);

      expect(filter.field, equals('count'));
      expect(filter.operator, equals(FilterOperator.greaterThan));
      expect(filter.value, equals(10));
    });

    test('should create lessThan filter', () {
      final filter = QueryFilter.lessThan('price', 100);

      expect(filter.field, equals('price'));
      expect(filter.operator, equals(FilterOperator.lessThan));
      expect(filter.value, equals(100));
    });
  });

  group('RepositoryResult', () {
    test('should create success result', () {
      final result = RepositoryResult.success('data');

      expect(result.success, isTrue);
      expect(result.data, equals('data'));
      expect(result.error, isNull);
    });

    test('should create failure result', () {
      final result = RepositoryResult<String>.failure('error message');

      expect(result.success, isFalse);
      expect(result.data, isNull);
      expect(result.error, equals('error message'));
    });
  });
}
