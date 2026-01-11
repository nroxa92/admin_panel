// FILE: lib/services/booking_service.dart
// VERSION: 3.0 - Added source/guests/scannedAt/updatedAt support
// DATE: 2026-01-11

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';

class BookingService {
  final CollectionReference _bookingRef =
      FirebaseFirestore.instance.collection('bookings');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // HELPER: Dohvaća Tenant ID iz Custom Claims
  Future<String?> _getTenantId() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final tokenResult = await user.getIdTokenResult(true);
    return tokenResult.claims?['ownerId'] as String?;
  }

  // HELPER: Local Date Normalization (00:00:00 LOCAL)
  DateTime _normalizeDate(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  // HELPER: Kombinira datum + vrijeme (String "HH:mm")
  DateTime _combineDateAndTime(DateTime date, String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 15;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }

  // HELPER: Generira custom Booking ID
  // Format: {unitId}_{YYMMDD}_{guestName}
  String _generateBookingId(
      String unitId, DateTime startDate, String guestName) {
    final yy = (startDate.year % 100).toString().padLeft(2, '0');
    final mm = startDate.month.toString().padLeft(2, '0');
    final dd = startDate.day.toString().padLeft(2, '0');
    final dateStr = '$yy$mm$dd';

    final cleanName = _sanitizeName(guestName);

    return '${unitId}_${dateStr}_$cleanName';
  }

  // HELPER: Čisti ime (uklanja dijakritike, razmake, specijalne znakove)
  String _sanitizeName(String name) {
    const diacritics = {
      'č': 'c',
      'ć': 'c',
      'đ': 'd',
      'š': 's',
      'ž': 'z',
      'Č': 'C',
      'Ć': 'C',
      'Đ': 'D',
      'Š': 'S',
      'Ž': 'Z',
      'ä': 'a',
      'ö': 'o',
      'ü': 'u',
      'ß': 'ss',
      'Ä': 'A',
      'Ö': 'O',
      'Ü': 'U',
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ã': 'a',
      'å': 'a',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ý': 'y',
      'ÿ': 'y',
      'ñ': 'n',
      'Ñ': 'N',
    };

    String result = name;

    diacritics.forEach((from, to) {
      result = result.replaceAll(from, to);
    });

    result = result.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    return result;
  }

  // HELPER: Provjeri postoji li ID, ako da dodaj suffix
  Future<String> _getUniqueBookingId(String baseId) async {
    try {
      final doc = await _bookingRef.doc(baseId).get();
      if (!doc.exists) {
        return baseId;
      }
    } catch (e) {
      debugPrint(
          '🔍 _getUniqueBookingId - doc check failed (probably doesnt exist): $e');
      return baseId;
    }

    for (int i = 0; i < 26; i++) {
      final suffix = String.fromCharCode(97 + i);
      final newId = '${baseId}_$suffix';
      try {
        final checkDoc = await _bookingRef.doc(newId).get();
        if (!checkDoc.exists) {
          return newId;
        }
      } catch (e) {
        return newId;
      }
    }

    return '${baseId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  // 1. DOHVATI REZERVACIJE (SAMO MOJE)
  Stream<List<Booking>> getBookingsStream() async* {
    final tenantId = await _getTenantId();
    if (tenantId == null) {
      yield [];
      return;
    }

    yield* _bookingRef
        .where('ownerId', isEqualTo: tenantId)
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
    });
  }

  // 2. PROVJERA PREKLAPANJA (sa SATIMA!)
  Future<bool> checkOverlap(Booking newBooking) async {
    final tenantId = await _getTenantId();
    if (tenantId == null) return false;

    final newStart = _combineDateAndTime(
      _normalizeDate(newBooking.startDate),
      newBooking.checkInTime,
    );
    final newEnd = _combineDateAndTime(
      _normalizeDate(newBooking.endDate),
      newBooking.checkOutTime,
    );

    try {
      final querySnapshot = await _bookingRef
          .where('ownerId', isEqualTo: tenantId)
          .where('unitId', isEqualTo: newBooking.unitId)
          .get();

      for (var doc in querySnapshot.docs) {
        final existingBooking = Booking.fromFirestore(doc);

        if (existingBooking.id == newBooking.id) continue;

        final exStart = _combineDateAndTime(
          _normalizeDate(existingBooking.startDate),
          existingBooking.checkInTime,
        );
        final exEnd = _combineDateAndTime(
          _normalizeDate(existingBooking.endDate),
          existingBooking.checkOutTime,
        );

        bool overlap = newStart.isBefore(exEnd) && newEnd.isAfter(exStart);

        if (overlap) {
          return true;
        }
      }
    } catch (e) {
      debugPrint('⚠️ checkOverlap - query failed: $e');
    }

    return false;
  }

  // 3. DODAJ NOVU REZERVACIJU
  Future<void> addBooking(Booking booking) async {
    final tenantId = await _getTenantId();

    final user = _auth.currentUser;
    if (user != null) {
      final tokenResult = await user.getIdTokenResult(true);
      debugPrint('🔍 addBooking - User UID: ${user.uid}');
      debugPrint('🔍 addBooking - User Email: ${user.email}');
      debugPrint('🔍 addBooking - Token Claims: ${tokenResult.claims}');
      debugPrint(
          '🔍 addBooking - ownerId from claims: ${tokenResult.claims?['ownerId']}');
      debugPrint(
          '🔍 addBooking - role from claims: ${tokenResult.claims?['role']}');
    }

    debugPrint('🔍 addBooking - tenantId: $tenantId');

    if (tenantId == null) {
      debugPrint('❌ addBooking - tenantId is NULL! Cannot save.');
      throw Exception('Not authenticated or missing ownerId claim');
    }

    debugPrint('🔍 addBooking - Step 1: checking overlap...');
    bool hasOverlap = await checkOverlap(booking);
    debugPrint('🔍 addBooking - Step 1: overlap = $hasOverlap');
    if (hasOverlap) {
      throw Exception("Unit is occupied during selected time.");
    }

    debugPrint('🔍 addBooking - Step 2: preparing dates...');
    final startWithTime = _combineDateAndTime(
      _normalizeDate(booking.startDate),
      booking.checkInTime,
    );
    final endWithTime = _combineDateAndTime(
      _normalizeDate(booking.endDate),
      booking.checkOutTime,
    );

    debugPrint('🔍 addBooking - Step 3: generating ID...');
    final baseId = _generateBookingId(
      booking.unitId,
      startWithTime,
      booking.guestName,
    );
    final bookingId = await _getUniqueBookingId(baseId);
    debugPrint('🔍 addBooking - Step 3: bookingId = $bookingId');

    final bookingToSave = Booking(
      id: bookingId,
      ownerId: tenantId,
      unitId: booking.unitId,
      guestName: booking.guestName,
      startDate: startWithTime,
      endDate: endWithTime,
      status: booking.status,
      source: booking.source, // v3.0
      note: booking.note,
      isScanned: booking.isScanned,
      guestCount: booking.guestCount,
      scannedGuestCount: booking.scannedGuestCount, // v3.0
      checkInTime: booking.checkInTime,
      checkOutTime: booking.checkOutTime,
      guests: booking.guests, // v3.0
      scannedAt: booking.scannedAt, // v3.0
      updatedAt: DateTime.now(), // v3.0
    );

    debugPrint('🔍 addBooking - Step 4: saving to Firestore...');
    debugPrint('🔍 addBooking - Document data: ${bookingToSave.toMap()}');

    try {
      await _bookingRef.doc(bookingId).set(bookingToSave.toMap());
      debugPrint('✅ addBooking - SUCCESS');
    } catch (e) {
      debugPrint('❌ addBooking - FIRESTORE ERROR: $e');
      rethrow;
    }
  }

  // 4. AŽURIRAJ REZERVACIJU
  Future<void> updateBooking(Booking booking) async {
    final tenantId = await _getTenantId();
    if (tenantId == null) return;

    bool hasOverlap = await checkOverlap(booking);
    if (hasOverlap) {
      throw Exception("Unit is occupied during selected time.");
    }

    final startWithTime = _combineDateAndTime(
      _normalizeDate(booking.startDate),
      booking.checkInTime,
    );
    final endWithTime = _combineDateAndTime(
      _normalizeDate(booking.endDate),
      booking.checkOutTime,
    );

    final bookingToSave = Booking(
      id: booking.id,
      ownerId: tenantId,
      unitId: booking.unitId,
      guestName: booking.guestName,
      startDate: startWithTime,
      endDate: endWithTime,
      status: booking.status,
      source: booking.source, // v3.0
      note: booking.note,
      isScanned: booking.isScanned,
      guestCount: booking.guestCount,
      scannedGuestCount: booking.scannedGuestCount, // v3.0
      checkInTime: booking.checkInTime,
      checkOutTime: booking.checkOutTime,
      guests: booking.guests, // v3.0
      scannedAt: booking.scannedAt, // v3.0
      updatedAt: DateTime.now(), // v3.0
    );

    await _bookingRef.doc(booking.id).update(bookingToSave.toMap());
  }

  // 5. OBRIŠI REZERVACIJU
  Future<void> deleteBooking(String id) async {
    await _bookingRef.doc(id).delete();
  }

  // 6. OZNAČI KAO SKENIRANO
  Future<void> setScannedStatus(String bookingId, bool isScanned) async {
    await _bookingRef.doc(bookingId).update({'isScanned': isScanned});
  }

  // 7. DOHVATI GOSTE (Za PDF liste)
  Future<List<Map<String, dynamic>>> getGuestsOnce(String bookingId) async {
    try {
      final snapshot = await _bookingRef
          .doc(bookingId)
          .collection('guests')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }
}
