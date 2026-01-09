// FILE: lib/models/booking_model.dart
// VERSION: 2.0 - camelCase Migration
// DATE: 2026-01-09

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
    this.checkInTime = '15:00',
    this.checkOutTime = '10:00',
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
      unitId: data['unitId']?.toString() ?? '',
      guestName: data['guestName']?.toString() ?? 'Unknown',
      startDate: _parseDate(data['startDate']),
      endDate: _parseDate(data['endDate']),
      status: data['status']?.toString() ?? 'confirmed',
      note: data['note']?.toString() ?? '',
      isScanned: data['isScanned'] == true,
      guestCount: _parseInt(data['guestCount'], defaultValue: 1),
      checkInTime: data['checkInTime']?.toString() ?? '15:00',
      checkOutTime: data['checkOutTime']?.toString() ?? '10:00',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'unitId': unitId,
      'guestName': guestName,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status,
      'note': note,
      'isScanned': isScanned,
      'guestCount': guestCount,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
    };
  }

  // --- HELPERS ---

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
