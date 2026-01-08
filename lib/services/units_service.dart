// FILE: lib/services/units_service.dart
// STATUS: UPDATED - Added auto ID generation and category management

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/unit_model.dart';

class UnitsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _unitsRef => _firestore.collection('units');
  CollectionReference get _bookingsRef => _firestore.collection('bookings');
  CollectionReference get _cleaningLogsRef =>
      _firestore.collection('cleaning_logs');

  // ========================================
  // HELPER: Dohvaća Tenant ID iz Custom Claims
  // ========================================
  Future<String?> _getTenantId() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    // ✅ FORCE REFRESH tokena!
    final tokenResult = await user.getIdTokenResult(true);
    return tokenResult.claims?['ownerId'] as String?;
  }

  // ========================================
  // 1. DOHVATI JEDINICE
  // ========================================
  Stream<List<Unit>> getUnitsStream() async* {
    final tenantId = await _getTenantId();
    if (tenantId == null) {
      yield [];
      return;
    }

    yield* _unitsRef
        .where('ownerId', isEqualTo: tenantId)
        .orderBy('created_at', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Unit.fromFirestore(doc)).toList();
    });
  }

  // ========================================
  // 2. SPREMI JEDINICU
  // ========================================
  Future<void> saveUnit(Unit unit) async {
    final tenantId = await _getTenantId();

    // 🔍 DEBUG
    debugPrint('🔍 saveUnit - tenantId: $tenantId');

    if (tenantId == null) {
      debugPrint('❌ saveUnit - tenantId is NULL! Cannot save.');
      throw Exception('Not authenticated or missing ownerId claim');
    }

    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('❌ saveUnit - user is NULL!');
      throw Exception('User not logged in');
    }

    debugPrint('🔍 saveUnit - user.email: ${user.email}');

    Map<String, dynamic> data = unit.toMap();
    data['ownerId'] = tenantId;
    data['ownerEmail'] = user.email;

    debugPrint('🔍 saveUnit - saving unit ${unit.id} with ownerId: $tenantId');

    await _unitsRef.doc(unit.id).set(data, SetOptions(merge: true));

    debugPrint('✅ saveUnit - SUCCESS');
  }

  // ========================================
  // 3. OBRIŠI JEDINICU + CASCADE DELETE
  // ========================================
  Future<void> deleteUnit(String unitId) async {
    final tenantId = await _getTenantId();
    if (tenantId == null) return;

    // KORAK A: Obriši sve REZERVACIJE vezane uz ovaj Unit
    final bookingSnapshot = await _bookingsRef
        .where('unit_id', isEqualTo: unitId)
        .where('ownerId', isEqualTo: tenantId)
        .get();

    WriteBatch batch = _firestore.batch();

    for (var doc in bookingSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // KORAK B: Obriši sve CLEANING LOGOVE vezane uz ovaj Unit
    final cleaningSnapshot = await _cleaningLogsRef
        .where('unit_id', isEqualTo: unitId)
        .where('ownerId', isEqualTo: tenantId)
        .get();

    for (var doc in cleaningSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // KORAK C: Obriši samu JEDINICU
    batch.delete(_unitsRef.doc(unitId));

    await batch.commit();
  }

  // ========================================
  // 4. NOVO: Dohvati broj jedinica (za redni broj)
  // ========================================
  Future<int> getUnitCount() async {
    final tenantId = await _getTenantId();
    if (tenantId == null) return 0;

    final snapshot =
        await _unitsRef.where('ownerId', isEqualTo: tenantId).get();

    return snapshot.docs.length;
  }

  // ========================================
  // 5. NOVO: Generiraj jedinstveni Unit ID
  // ========================================
  /// Format: [I][P][C][NNN][##]
  /// - I = Prvo slovo imena vlasnika
  /// - P = Prvo slovo prezimena vlasnika
  /// - C = Prvo slovo kategorije (ili "0" ako nema)
  /// - NNN = Prva 3 slova imena jedinice
  /// - ## = Redni broj (01-99)
  ///
  /// Primjer: IPZAPA01 (Ivan Perić, Zgrada, Apartman, #1)
  Future<String> generateUnitId({
    required String ownerFirstName,
    required String ownerLastName,
    String? category,
    required String unitName,
  }) async {
    // 1. Prvo slovo imena vlasnika (uppercase)
    final firstInitial = _getFirstLetter(ownerFirstName);

    // 2. Prvo slovo prezimena vlasnika (uppercase)
    final lastInitial = _getFirstLetter(ownerLastName);

    // 3. Prvo slovo kategorije ili "0"
    final categoryInitial = (category != null && category.trim().isNotEmpty)
        ? _getFirstLetter(category)
        : '0';

    // 4. Prva 3 slova imena jedinice (uppercase, padded)
    final nameCode = _getFirstThreeLetters(unitName);

    // 5. Redni broj (sljedeći slobodan)
    final nextNumber = await _getNextUnitNumber();
    final numberCode = nextNumber.toString().padLeft(2, '0');

    // Sastavi ID
    final generatedId =
        '$firstInitial$lastInitial$categoryInitial$nameCode$numberCode';

    return generatedId.toUpperCase();
  }

  // ========================================
  // 6. NOVO: Dohvati sljedeći redni broj
  // ========================================
  Future<int> _getNextUnitNumber() async {
    final count = await getUnitCount();
    return count + 1;
  }

  // ========================================
  // 7. NOVO: Dodaj kategoriju u settings
  // ========================================
  Future<void> addCategory(String categoryName) async {
    final tenantId = await _getTenantId();
    if (tenantId == null) {
      debugPrint('❌ addCategory - tenantId is NULL!');
      throw Exception('Not authenticated');
    }

    final trimmedName = categoryName.trim();
    if (trimmedName.isEmpty) {
      debugPrint('❌ addCategory - empty category name');
      return;
    }

    debugPrint('🔍 addCategory - adding "$trimmedName" for tenant $tenantId');

    // Dohvati iz SETTINGS kolekcije (ne owners!)
    final settingsRef = _firestore.collection('settings').doc(tenantId);
    final settingsDoc = await settingsRef.get();
    final data = settingsDoc.data() ?? {};

    List<String> currentCategories = [];
    if (data['categories'] != null) {
      currentCategories = List<String>.from(data['categories']);
    }

    // Provjeri da ne postoji već
    if (currentCategories.contains(trimmedName)) {
      debugPrint('⚠️ addCategory - "$trimmedName" already exists');
      return;
    }

    // Dodaj novu kategoriju
    currentCategories.add(trimmedName);

    // Spremi u SETTINGS kolekciju
    await settingsRef.set(
      {'categories': currentCategories},
      SetOptions(merge: true),
    );

    debugPrint('✅ addCategory - SUCCESS, categories: $currentCategories');
  }

  // ========================================
  // 8. NOVO: Ukloni kategoriju iz settings
  // ========================================
  Future<void> removeCategory(String categoryName) async {
    final tenantId = await _getTenantId();
    if (tenantId == null) return;

    // Koristi SETTINGS kolekciju
    final settingsRef = _firestore.collection('settings').doc(tenantId);
    final settingsDoc = await settingsRef.get();
    final data = settingsDoc.data() ?? {};

    List<String> currentCategories = [];
    if (data['categories'] != null) {
      currentCategories = List<String>.from(data['categories']);
    }

    currentCategories.remove(categoryName);

    await settingsRef.set(
      {'categories': currentCategories},
      SetOptions(merge: true),
    );
  }

  // ========================================
  // 9. NOVO: Dohvati kategorije
  // ========================================
  Future<List<String>> getCategories() async {
    final tenantId = await _getTenantId();
    if (tenantId == null) return [];

    // Koristi SETTINGS kolekciju
    final settingsDoc =
        await _firestore.collection('settings').doc(tenantId).get();
    final data = settingsDoc.data() ?? {};

    if (data['categories'] != null) {
      return List<String>.from(data['categories']);
    }
    return [];
  }

  // ========================================
  // HELPER: Dohvati prvo slovo (uppercase)
  // ========================================
  String _getFirstLetter(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 'X';

    // Ukloni dijakritike za ID
    final normalized = _removeDiacritics(trimmed[0]);
    return normalized.toUpperCase();
  }

  // ========================================
  // HELPER: Dohvati prva 3 slova (uppercase, padded)
  // ========================================
  String _getFirstThreeLetters(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 'XXX';

    // Ukloni razmake i uzmi prva 3 slova
    final noSpaces = trimmed.replaceAll(' ', '');
    final normalized = _removeDiacritics(noSpaces);

    if (normalized.length >= 3) {
      return normalized.substring(0, 3).toUpperCase();
    } else {
      return normalized.toUpperCase().padRight(3, 'X');
    }
  }

  // ========================================
  // HELPER: Ukloni dijakritike (č→c, š→s, ž→z, itd.)
  // ========================================
  String _removeDiacritics(String text) {
    const diacritics = {
      'č': 'c',
      'ć': 'c',
      'š': 's',
      'ž': 'z',
      'đ': 'd',
      'Č': 'C',
      'Ć': 'C',
      'Š': 'S',
      'Ž': 'Z',
      'Đ': 'D',
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
      'ñ': 'n',
      'Ñ': 'N',
    };

    String result = text;
    diacritics.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }
}
