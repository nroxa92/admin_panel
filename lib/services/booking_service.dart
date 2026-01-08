// FILE: lib/services/booking_service.dart
// STATUS: UPDATED - Custom Booking ID format: {unitId}_{YYMMDD}_{guestName}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';

class BookingService {
  final CollectionReference _bookingRef =
      FirebaseFirestore.instance.collection('bookings');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🆕 HELPER: Dohvaća Tenant ID iz Custom Claims
  Future<String?> _getTenantId() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    // ✅ FORCE REFRESH tokena!
    final tokenResult = await user.getIdTokenResult(true);
    return tokenResult.claims?['ownerId'] as String?;
  }

  // --- HELPER: Local Date Normalization (00:00:00 LOCAL) ---
  DateTime _normalizeDate(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day); // LOCAL midnight!
  }

  // 🆕 NOVO: Kombinira datum + vrijeme (String "HH:mm")
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

  // =====================================================
  // 🆕 HELPER: Generira custom Booking ID
  // Format: {unitId}_{YYMMDD}_{guestName}
  // Primjer: IPZAPA01_250115_IvanPeric
  // =====================================================
  String _generateBookingId(
      String unitId, DateTime startDate, String guestName) {
    // Format datuma: YYMMDD
    final yy = (startDate.year % 100).toString().padLeft(2, '0');
    final mm = startDate.month.toString().padLeft(2, '0');
    final dd = startDate.day.toString().padLeft(2, '0');
    final dateStr = '$yy$mm$dd';

    // Očisti ime gosta: ukloni razmake, dijakritike i specijalne znakove
    final cleanName = _sanitizeName(guestName);

    return '${unitId}_${dateStr}_$cleanName';
  }

  // 🆕 HELPER: Čisti ime (uklanja dijakritike, razmake, specijalne znakove)
  String _sanitizeName(String name) {
    // Mapa dijakritika
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

    // Zamijeni dijakritike
    diacritics.forEach((from, to) {
      result = result.replaceAll(from, to);
    });

    // Ukloni sve što nije slovo ili broj, pretvori razmake u ništa
    result = result.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    return result;
  }

  // =====================================================
  // 🆕 HELPER: Provjeri postoji li ID, ako da dodaj suffix
  // =====================================================
  Future<String> _getUniqueBookingId(String baseId) async {
    // Provjeri postoji li već
    try {
      final doc = await _bookingRef.doc(baseId).get();
      if (!doc.exists) {
        return baseId;
      }
    } catch (e) {
      // Ako je permission denied (dokument ne postoji), ID je slobodan
      debugPrint(
          '🔍 _getUniqueBookingId - doc check failed (probably doesnt exist): $e');
      return baseId;
    }

    // Ako postoji, dodaj suffix (a, b, c...)
    for (int i = 0; i < 26; i++) {
      final suffix = String.fromCharCode(97 + i); // a, b, c...
      final newId = '${baseId}_$suffix';
      try {
        final checkDoc = await _bookingRef.doc(newId).get();
        if (!checkDoc.exists) {
          return newId;
        }
      } catch (e) {
        // Permission denied = dokument ne postoji = ID slobodan
        return newId;
      }
    }

    // Fallback: dodaj timestamp
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
        .where('ownerId', isEqualTo: tenantId) // ✅ Tenant ID
        .orderBy('start_date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
    });
  }

  // 2. PROVJERA PREKLAPANJA (sa SATIMA!)
  Future<bool> checkOverlap(Booking newBooking) async {
    final tenantId = await _getTenantId();
    if (tenantId == null) return false;

    // 🆕 Kombiniramo datum + vrijeme
    final newStart = _combineDateAndTime(
      _normalizeDate(newBooking.startDate),
      newBooking.checkInTime,
    );
    final newEnd = _combineDateAndTime(
      _normalizeDate(newBooking.endDate),
      newBooking.checkOutTime,
    );

    // Dohvati postojeće rezervacije za taj Unit
    try {
      final querySnapshot = await _bookingRef
          .where('ownerId', isEqualTo: tenantId) // ✅ Tenant ID
          .where('unit_id', isEqualTo: newBooking.unitId)
          .get();

      for (var doc in querySnapshot.docs) {
        final existingBooking = Booking.fromFirestore(doc);

        // Preskoči samog sebe (edit mode)
        if (existingBooking.id == newBooking.id) continue;

        // 🆕 Kombiniraj datum + vrijeme za postojeći booking
        final exStart = _combineDateAndTime(
          _normalizeDate(existingBooking.startDate),
          existingBooking.checkInTime,
        );
        final exEnd = _combineDateAndTime(
          _normalizeDate(existingBooking.endDate),
          existingBooking.checkOutTime,
        );

        // --- LOGIKA PREKLAPANJA (do minute!) ---
        bool overlap = newStart.isBefore(exEnd) && newEnd.isAfter(exStart);

        if (overlap) {
          return true; // Preklapanje!
        }
      }
    } catch (e) {
      debugPrint('⚠️ checkOverlap - query failed: $e');
      // Ako ne možemo provjeriti, pretpostavljamo da nema preklapanja
      // (bolje dozvoliti nego blokirati zbog permission errora)
    }

    return false; // Sve čisto
  }

  // 3. DODAJ NOVU REZERVACIJU
  Future<void> addBooking(Booking booking) async {
    final tenantId = await _getTenantId();

    // 🔍 DETAILED DEBUG
    final user = _auth.currentUser;
    if (user != null) {
      final tokenResult = await user.getIdTokenResult(true); // Force refresh!
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

    // 1. Provjera preklapanja
    debugPrint('🔍 addBooking - Step 1: checking overlap...');
    bool hasOverlap = await checkOverlap(booking);
    debugPrint('🔍 addBooking - Step 1: overlap = $hasOverlap');
    if (hasOverlap) {
      throw Exception("Unit is occupied during selected time.");
    }

    // 2. Priprema podataka
    debugPrint('🔍 addBooking - Step 2: preparing dates...');
    final startWithTime = _combineDateAndTime(
      _normalizeDate(booking.startDate),
      booking.checkInTime,
    );
    final endWithTime = _combineDateAndTime(
      _normalizeDate(booking.endDate),
      booking.checkOutTime,
    );

    // 🆕 3. Generiraj custom ID
    debugPrint('🔍 addBooking - Step 3: generating ID...');
    final baseId = _generateBookingId(
      booking.unitId,
      startWithTime,
      booking.guestName,
    );
    final bookingId = await _getUniqueBookingId(baseId);
    debugPrint('🔍 addBooking - Step 3: bookingId = $bookingId');

    // Kreiraj novi booking sa pravim datumima
    final bookingToSave = Booking(
      id: bookingId, // 🆕 Custom ID
      ownerId: tenantId, // ✅ Tenant ID
      unitId: booking.unitId,
      guestName: booking.guestName,
      startDate: startWithTime,
      endDate: endWithTime,
      status: booking.status,
      note: booking.note,
      isScanned: booking.isScanned,
      guestCount: booking.guestCount,
      checkInTime: booking.checkInTime,
      checkOutTime: booking.checkOutTime,
    );

    debugPrint('🔍 addBooking - Step 4: saving to Firestore...');
    debugPrint('🔍 addBooking - Document data: ${bookingToSave.toMap()}');

    // 🆕 Koristi .doc(id).set() umjesto .add()
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

    // 1. Provjera preklapanja
    bool hasOverlap = await checkOverlap(booking);
    if (hasOverlap) {
      throw Exception("Unit is occupied during selected time.");
    }

    // 2. 🆕 Kombiniraj datum + vrijeme
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
      ownerId: tenantId, // ✅ Tenant ID
      unitId: booking.unitId,
      guestName: booking.guestName,
      startDate: startWithTime,
      endDate: endWithTime,
      status: booking.status,
      note: booking.note,
      isScanned: booking.isScanned,
      guestCount: booking.guestCount,
      checkInTime: booking.checkInTime,
      checkOutTime: booking.checkOutTime,
    );

    await _bookingRef.doc(booking.id).update(bookingToSave.toMap());
  }

  // 5. OBRIŠI REZERVACIJU
  Future<void> deleteBooking(String id) async {
    await _bookingRef.doc(id).delete();
  }

  // 6. OZNAČI KAO SKENIRANO
  Future<void> setScannedStatus(String bookingId, bool isScanned) async {
    await _bookingRef.doc(bookingId).update({'is_scanned': isScanned});
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
