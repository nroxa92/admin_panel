// FILE: lib/services/settings_service.dart
// OPIS: Servis za dohvat i spremanje postavki vile.
// STATUS: FIXED - Removed merge:true to clean up duplicate snake_case fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/settings_model.dart';

class SettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🆕 HELPER: Dohvaća Tenant ID iz Custom Claims
  Future<String?> _getTenantId() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final tokenResult = await user.getIdTokenResult();
    return tokenResult.claims?['ownerId'] as String?;
  }

  // 1. DOHVATI POSTAVKE (Stream)
  // Sluša promjene u realnom vremenu. Ako dokument ne postoji, vraća default.
  Stream<VillaSettings> getSettingsStream() async* {
    final tenantId = await _getTenantId();

    // Ako nema tenantId, vrati prazan default model
    if (tenantId == null) {
      yield VillaSettings(ownerId: '');
      return;
    }

    yield* _firestore
        .collection('settings')
        .doc(tenantId) // ✅ Koristi Tenant ID ("TEST22")
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        // Prvi put? Vrati default s ID-om vlasnika
        return VillaSettings(ownerId: tenantId);
      }
      return VillaSettings.fromFirestore(snapshot);
    });
  }

  // 2. SPREMI POSTAVKE
  // ✅ FIXED: Removed SetOptions(merge: true) to fully replace document
  // This will DELETE old snake_case fields (cleaner_pin, hard_reset_pin, etc.)
  Future<void> saveSettings(VillaSettings settings) async {
    final tenantId = await _getTenantId();
    if (tenantId == null) return;

    // Pretvaramo model u Mapu za Firebase
    Map<String, dynamic> data = settings.toMap();

    // SIGURNOSNI OSIGURAČ:
    // Uvijek forsiraj da je ownerId jednak Tenant ID-u.
    data['ownerId'] = tenantId; // ✅ "TEST22"

    // ✅ FIXED: Full document replace instead of merge
    // Old snake_case fields will be automatically deleted
    await _firestore
        .collection('settings')
        .doc(tenantId) // ✅ Koristi Tenant ID
        .set(data); // ✅ No merge option = full replace
  }
}
