// FILE: lib/models/booking_model.dart
// STATUS: UPDATED (Added check-in/out time support)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Booking {
  final String id;
  final String ownerId;
  final String unitId;
  final String guestName;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String note;
  final bool isScanned;
  final int guestCount;

  // ðŸ†• NOVO: Sati za check-in i check-out (format "HH:mm")
  final String checkInTime;
  final String checkOutTime;

  Booking({
    required this.id,
    required this.ownerId,
    required this.unitId,
    required this.guestName,
    required this.startDate,
    required this.endDate,
    this.status = 'confirmed',
    this.note = '',
    this.isScanned = false,
    this.guestCount = 1,
    this.checkInTime = '15:00', // ðŸ†• Default check-in
    this.checkOutTime = '10:00', // ðŸ†• Default check-out
  });

  Color get color {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'booking.com':
      case 'booking':
        return Colors.blue;
      case 'private':
        return Colors.yellow;
      case 'airbnb':
        return Colors.orange;
      case 'closed':
      case 'blocked':
        return Colors.red;
      case 'other':
      default:
        return Colors.purple;
    }
  }

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Booking(
      id: doc.id,
      ownerId: data['ownerId']?.toString() ?? '',
      unitId: data['unit_id']?.toString() ?? '',
      guestName: data['guest_name']?.toString() ?? 'Unknown',

      // Datumi se Äitaju kao Å¡to su spremljeni (sa satima!)
      startDate: _parseDate(data['start_date']),
      endDate: _parseDate(data['end_date']),

      status: data['status']?.toString() ?? 'confirmed',
      note: data['note']?.toString() ?? '',
      isScanned: data['is_scanned'] == true,
      guestCount: _parseInt(data['guest_count'], defaultValue: 1),

      // ðŸ†• NOVO: ÄŒitaj sate (ako postoje, inaÄe default)
      checkInTime: data['check_in_time']?.toString() ?? '15:00',
      checkOutTime: data['check_out_time']?.toString() ?? '10:00',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'unit_id': unitId,
      'guest_name': guestName,

      // Datumi se spremaju sa satima (kombinirano!)
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),

      'status': status,
      'note': note,
      'is_scanned': isScanned,
      'guest_count': guestCount,

      // ðŸ†• NOVO: Spremi sate odvojeno
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
    };
  }

  // --- HELPERI ZA SIGURNOST ---

  static DateTime _parseDate(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is Timestamp) return val.toDate();
    if (val is String) {
      try {
        return DateTime.parse(val);
      } catch (_) {}
    }
    return DateTime.now();
  }

  static int _parseInt(dynamic val, {int defaultValue = 0}) {
    if (val == null) return defaultValue;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? defaultValue;
    return defaultValue;
  }
}
