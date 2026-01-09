// FILE: lib/repositories/booking_repository.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 3.0.0 - Phase 3 Repository Pattern

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'base_repository.dart';

/// Booking Repository
///
/// Handles all booking-related database operations.
/// Extends BaseRepository for standard CRUD operations.
class BookingRepository extends BaseRepository<Booking> {
  final String ownerId;

  BookingRepository({
    required this.ownerId,
    super.firestore,
  }) : super(collectionPath: 'bookings');

  @override
  Booking fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Booking.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(Booking model) {
    return model.toMap();
  }

  // =====================================================
  // OWNER-SCOPED QUERIES
  // =====================================================

  /// Get all bookings for owner
  Future<List<Booking>> getOwnerBookings() async {
    return query(
      filters: [QueryFilter.equals('ownerId', ownerId)],
      orderBy: 'checkIn',
      descending: true,
    );
  }

  /// Stream owner's bookings
  Stream<List<Booking>> streamOwnerBookings() {
    return streamQuery(
      filters: [QueryFilter.equals('ownerId', ownerId)],
      orderBy: 'checkIn',
      descending: true,
    );
  }

  /// Get bookings by unit
  Future<List<Booking>> getByUnit(String unitId) async {
    return query(
      filters: [
        QueryFilter.equals('ownerId', ownerId),
        QueryFilter.equals('unitId', unitId),
      ],
      orderBy: 'checkIn',
      descending: true,
    );
  }

  /// Get bookings in date range
  Future<List<Booking>> getByDateRange(DateTime start, DateTime end) async {
    try {
      final snapshot = await collection
          .where('ownerId', isEqualTo: ownerId)
          .where('checkIn', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('checkIn', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('checkIn')
          .get();

      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('❌ BookingRepository.getByDateRange error: $e');
      rethrow;
    }
  }

  /// Get active bookings (checked in, not checked out)
  Future<List<Booking>> getActiveBookings() async {
    return query(
      filters: [
        QueryFilter.equals('ownerId', ownerId),
        QueryFilter.equals('status', 'checked_in'),
      ],
    );
  }

  /// Get upcoming bookings
  Future<List<Booking>> getUpcomingBookings({int limit = 10}) async {
    try {
      final now = DateTime.now();
      final snapshot = await collection
          .where('ownerId', isEqualTo: ownerId)
          .where('checkIn', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('checkIn')
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('❌ BookingRepository.getUpcomingBookings error: $e');
      rethrow;
    }
  }

  /// Get today's check-ins
  Future<List<Booking>> getTodayCheckIns() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final snapshot = await collection
          .where('ownerId', isEqualTo: ownerId)
          .where('checkIn',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('checkIn', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('❌ BookingRepository.getTodayCheckIns error: $e');
      rethrow;
    }
  }

  /// Get today's check-outs
  Future<List<Booking>> getTodayCheckOuts() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final snapshot = await collection
          .where('ownerId', isEqualTo: ownerId)
          .where('checkOut',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('checkOut', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('❌ BookingRepository.getTodayCheckOuts error: $e');
      rethrow;
    }
  }

  // =====================================================
  // ANALYTICS QUERIES
  // =====================================================

  /// Get booking count by month
  Future<Map<String, int>> getBookingCountByMonth(int year) async {
    final startOfYear = DateTime(year, 1, 1);
    final endOfYear = DateTime(year + 1, 1, 1);

    try {
      final snapshot = await collection
          .where('ownerId', isEqualTo: ownerId)
          .where('checkIn',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
          .where('checkIn', isLessThan: Timestamp.fromDate(endOfYear))
          .get();

      final Map<String, int> countByMonth = {};

      for (int i = 1; i <= 12; i++) {
        countByMonth[i.toString().padLeft(2, '0')] = 0;
      }

      for (final doc in snapshot.docs) {
        final checkIn = (doc.data()['checkIn'] as Timestamp).toDate();
        final month = checkIn.month.toString().padLeft(2, '0');
        countByMonth[month] = (countByMonth[month] ?? 0) + 1;
      }

      return countByMonth;
    } catch (e) {
      debugPrint('❌ BookingRepository.getBookingCountByMonth error: $e');
      rethrow;
    }
  }

  /// Get total guest count
  Future<int> getTotalGuestCount({DateTime? since}) async {
    try {
      Query<Map<String, dynamic>> query =
          collection.where('ownerId', isEqualTo: ownerId);

      if (since != null) {
        query = query.where('checkIn',
            isGreaterThanOrEqualTo: Timestamp.fromDate(since));
      }

      final snapshot = await query.get();

      int totalGuests = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        totalGuests += (data['guestCount'] as int?) ?? 1;
      }

      return totalGuests;
    } catch (e) {
      debugPrint('❌ BookingRepository.getTotalGuestCount error: $e');
      rethrow;
    }
  }

  /// Get occupancy rate
  Future<double> getOccupancyRate(
      DateTime start, DateTime end, int totalUnits) async {
    try {
      final bookings = await getByDateRange(start, end);

      final totalDays = end.difference(start).inDays;
      final totalPossibleNights = totalDays * totalUnits;

      int bookedNights = 0;
      for (final booking in bookings) {
        final bookingStart =
            booking.checkIn.isAfter(start) ? booking.checkIn : start;
        final bookingEnd =
            booking.checkOut.isBefore(end) ? booking.checkOut : end;
        bookedNights += bookingEnd.difference(bookingStart).inDays;
      }

      if (totalPossibleNights == 0) return 0.0;
      return (bookedNights / totalPossibleNights) * 100;
    } catch (e) {
      debugPrint('❌ BookingRepository.getOccupancyRate error: $e');
      rethrow;
    }
  }

  /// Get booking statistics
  Future<BookingStats> getStats({DateTime? since}) async {
    try {
      Query<Map<String, dynamic>> query =
          collection.where('ownerId', isEqualTo: ownerId);

      if (since != null) {
        query = query.where('checkIn',
            isGreaterThanOrEqualTo: Timestamp.fromDate(since));
      }

      final snapshot = await query.get();

      int totalBookings = snapshot.docs.length;
      int totalGuests = 0;
      int totalNights = 0;
      int completedBookings = 0;
      int cancelledBookings = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        totalGuests += (data['guestCount'] as int?) ?? 1;

        final checkIn = (data['checkIn'] as Timestamp).toDate();
        final checkOut = (data['checkOut'] as Timestamp).toDate();
        totalNights += checkOut.difference(checkIn).inDays;

        final status = data['status'] as String?;
        if (status == 'completed' || status == 'checked_out') {
          completedBookings++;
        } else if (status == 'cancelled') {
          cancelledBookings++;
        }
      }

      return BookingStats(
        totalBookings: totalBookings,
        totalGuests: totalGuests,
        totalNights: totalNights,
        completedBookings: completedBookings,
        cancelledBookings: cancelledBookings,
        averageStayLength: totalBookings > 0 ? totalNights / totalBookings : 0,
      );
    } catch (e) {
      debugPrint('❌ BookingRepository.getStats error: $e');
      rethrow;
    }
  }

  // =====================================================
  // GUEST SUBCOLLECTION
  // =====================================================

  /// Get guests for booking
  Future<List<Guest>> getGuests(String bookingId) async {
    try {
      final snapshot =
          await collection.doc(bookingId).collection('guests').get();

      return snapshot.docs.map((doc) => Guest.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('❌ BookingRepository.getGuests error: $e');
      rethrow;
    }
  }

  /// Add guest to booking
  Future<String> addGuest(String bookingId, Guest guest) async {
    try {
      final docRef = await collection
          .doc(bookingId)
          .collection('guests')
          .add(guest.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('❌ BookingRepository.addGuest error: $e');
      rethrow;
    }
  }

  /// Update booking status
  Future<void> updateStatus(String bookingId, String status) async {
    await update(bookingId, {'status': status});
  }
}

// =====================================================
// BOOKING MODEL
// =====================================================

class Booking {
  final String id;
  final String ownerId;
  final String unitId;
  final String unitName;
  final String guestName;
  final String? guestEmail;
  final String? guestPhone;
  final int guestCount;
  final DateTime checkIn;
  final DateTime checkOut;
  final String status;
  final String? notes;
  final String? source;
  final DateTime? createdAt;

  Booking({
    required this.id,
    required this.ownerId,
    required this.unitId,
    required this.unitName,
    required this.guestName,
    this.guestEmail,
    this.guestPhone,
    required this.guestCount,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    this.notes,
    this.source,
    this.createdAt,
  });

  factory Booking.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Booking(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      unitId: data['unitId'] ?? '',
      unitName: data['unitName'] ?? '',
      guestName: data['guestName'] ?? '',
      guestEmail: data['guestEmail'],
      guestPhone: data['guestPhone'],
      guestCount: data['guestCount'] ?? 1,
      checkIn: (data['checkIn'] as Timestamp).toDate(),
      checkOut: (data['checkOut'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      notes: data['notes'],
      source: data['source'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'unitId': unitId,
      'unitName': unitName,
      'guestName': guestName,
      'guestEmail': guestEmail,
      'guestPhone': guestPhone,
      'guestCount': guestCount,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      'status': status,
      'notes': notes,
      'source': source,
    };
  }

  int get stayLength => checkOut.difference(checkIn).inDays;
}

// =====================================================
// GUEST MODEL
// =====================================================

class Guest {
  final String id;
  final String firstName;
  final String lastName;
  final String? documentType;
  final String? documentNumber;
  final String? nationality;
  final DateTime? dateOfBirth;
  final String? signatureUrl;

  Guest({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.documentType,
    this.documentNumber,
    this.nationality,
    this.dateOfBirth,
    this.signatureUrl,
  });

  factory Guest.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Guest(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      documentType: data['documentType'],
      documentNumber: data['documentNumber'],
      nationality: data['nationality'],
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      signatureUrl: data['signatureUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'nationality': nationality,
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'signatureUrl': signatureUrl,
    };
  }

  String get fullName => '$firstName $lastName';
}

// =====================================================
// BOOKING STATS MODEL
// =====================================================

class BookingStats {
  final int totalBookings;
  final int totalGuests;
  final int totalNights;
  final int completedBookings;
  final int cancelledBookings;
  final double averageStayLength;

  BookingStats({
    required this.totalBookings,
    required this.totalGuests,
    required this.totalNights,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.averageStayLength,
  });

  double get completionRate =>
      totalBookings > 0 ? (completedBookings / totalBookings) * 100 : 0;

  double get cancellationRate =>
      totalBookings > 0 ? (cancelledBookings / totalBookings) * 100 : 0;
}
