// FILE: lib/models/unit_model.dart
// VERSION: 2.0 - camelCase Migration
// DATE: 2026-01-09

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
  final String? category;
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
    this.category,
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
      wifiSsid: data['wifiSsid']?.toString() ?? '',
      wifiPass: data['wifiPass']?.toString() ?? '',
      contactOptions: _parseContacts(data['contactOptions']),
      category: _parseCategory(data['category']),
      cleanerPin: data['cleanerPin']?.toString() ?? '',
      reviewLink: data['reviewLink']?.toString() ?? '',
      createdAt: _parseDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'name': name,
      'address': address,
      'wifiSsid': wifiSsid,
      'wifiPass': wifiPass,
      'contactOptions': contactOptions,
      'category': category,
      'cleanerPin': cleanerPin,
      'reviewLink': reviewLink,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  String get categoryDisplay => category ?? 'Bez kategorije';

  // --- HELPERS ---

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
        return val
            .map((key, value) => MapEntry(key.toString(), value.toString()));
      } catch (_) {
        return {};
      }
    }
    return {};
  }

  static String? _parseCategory(dynamic val) {
    if (val == null) return null;
    final str = val.toString().trim();
    if (str.isEmpty) return null;
    return str;
  }
}
