// FILE: lib/services/cleaning_service.dart
// VERSION: 2.0 - camelCase Migration
// DATE: 2026-01-09

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cleaning_log_model.dart';

class CleaningService {
  final CollectionReference _logsRef =
      FirebaseFirestore.instance.collection('cleaning_logs');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // HELPER: Dohvaća Tenant ID iz Custom Claims
  Future<String?> _getTenantId() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final tokenResult = await user.getIdTokenResult();
    return tokenResult.claims?['ownerId'] as String?;
  }

  // 1. SPREMI NOVI IZVJEŠTAJ (Zove čistačica)
  Future<void> saveCleaningLog(CleaningLog log) async {
    await _logsRef.add(log.toMap());
  }

  // 2. DOHVATI POVIJEST ČIŠĆENJA ZA APARTMAN (Zove Owner)
  Stream<List<CleaningLog>> getLogsForUnit(String unitId) async* {
    final tenantId = await _getTenantId();
    if (tenantId == null) {
      yield [];
      return;
    }

    yield* _logsRef
        .where('ownerId', isEqualTo: tenantId)
        .where('unitId', isEqualTo: unitId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CleaningLog.fromFirestore(doc))
          .toList();
    });
  }

  // 3. DOHVATI ZADNJI STATUS (Za Dashboard semafor)
  Future<CleaningLog?> getLastLog(String unitId) async {
    final tenantId = await _getTenantId();
    if (tenantId == null) return null;

    final snapshot = await _logsRef
        .where('ownerId', isEqualTo: tenantId)
        .where('unitId', isEqualTo: unitId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return CleaningLog.fromFirestore(snapshot.docs.first);
    }
    return null;
  }
}
