// FILE: lib/models/unit_model.dart
// STATUS: UPDATED - Added category field for unit grouping

import 'package:cloud_firestore/cloud_firestore.dart';

class Unit {
  final String id;
  final String ownerId;
  final String ownerEmail;
  final String name;
  final String address;
  final String wifiSsid;
  final String wifiPass;
  final Map<String, String> contactOptions;

  // ========================================
  // KATEGORIJA (NOVO!)
  // ========================================
  final String? category; // null = "Bez kategorije"

  // ========================================
  // OSTALI PODACI
  // ========================================
  final String cleanerPin;
  final String reviewLink;
  final DateTime? createdAt;

  Unit({
    required this.id,
    required this.ownerId,
    required this.ownerEmail,
    required this.name,
    required this.address,
    required this.wifiSsid,
    required this.wifiPass,
    required this.contactOptions,
    this.category, // NOVO! (nullable)
    this.cleanerPin = '',
    this.reviewLink = '',
    this.createdAt,
  });

  factory Unit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Unit(
      id: doc.id,
      ownerId: data['ownerId']?.toString() ?? '',
      ownerEmail: data['ownerEmail']?.toString() ?? '',
      name: data['name']?.toString() ?? 'Unknown Unit',
      address: data['address']?.toString() ?? '',
      wifiSsid: data['wifi_ssid']?.toString() ?? '',
      wifiPass: data['wifi_pass']?.toString() ?? '',

      // FIX: Sigurno parsiranje Mape (sprječava crash ako je format krivi)
      contactOptions: _parseContacts(data['contacts']),

      // ✅ NOVO: Kategorija (null ako ne postoji ili je prazan string)
      category: _parseCategory(data['category']),

      cleanerPin: data['cleaner_pin']?.toString() ?? '',
      reviewLink: data['review_link']?.toString() ?? '',

      // FIX: Sigurno parsiranje datuma
      createdAt: _parseDate(data['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'name': name,
      'address': address,
      'wifi_ssid': wifiSsid,
      'wifi_pass': wifiPass,
      'contacts': contactOptions,
      // ✅ NOVO: Kategorija (sprema null ako nema)
      'category': category,
      'cleaner_pin': cleanerPin,
      'review_link': reviewLink,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  // ========================================
  // HELPER: Display name za kategoriju
  // ========================================
  String get categoryDisplay => category ?? 'Bez kategorije';

  // --- HELPERI ---

  static DateTime? _parseDate(dynamic val) {
    if (val == null) return null;
    if (val is Timestamp) return val.toDate();
    if (val is String) {
      try {
        return DateTime.parse(val);
      } catch (_) {}
    }
    return null;
  }

  static Map<String, String> _parseContacts(dynamic val) {
    if (val == null) return {};
    if (val is Map) {
      try {
        // Sigurna konverzija: pretvori ključeve i vrijednosti u String
        return val
            .map((key, value) => MapEntry(key.toString(), value.toString()));
      } catch (_) {
        return {};
      }
    }
    return {};
  }

  // ✅ NOVO: Parser za kategoriju
  static String? _parseCategory(dynamic val) {
    if (val == null) return null;
    final str = val.toString().trim();
    if (str.isEmpty) return null;
    return str;
  }
}
