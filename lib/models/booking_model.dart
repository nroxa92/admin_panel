// FILE: lib/models/booking_model.dart
// VERSION: 3.0 - Guest Array + Source/Status Separation
// DATE: 2026-01-11
// CHANGES:
//   - Added guests array (from Tablet check-in)
//   - Added scannedAt, updatedAt timestamps
//   - Added source field (airbnb, booking, manual, other)
//   - Separated statusColor and sourceColor
//   - Added scannedGuestCount for progress tracking
//   - Backwards compatible: 'color' getter still works

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Booking {
  final String id;
  final String ownerId;
  final String unitId;
  final String guestName;
  final DateTime startDate;
  final DateTime endDate;
  final String
      status; // confirmed, pending, cancelled, checked_in, checked_out, blocked
  final String source; // airbnb, booking, manual, other
  final String note;
  final bool isScanned;
  final int guestCount;
  final int scannedGuestCount;
  final String checkInTime;
  final String checkOutTime;
  final List<Map<String, dynamic>> guests; // Guest data from Tablet MRZ scan
  final DateTime? scannedAt; // When first guest was scanned
  final DateTime? updatedAt; // Last modification timestamp

  Booking({
    required this.id,
    required this.ownerId,
    required this.unitId,
    required this.guestName,
    required this.startDate,
    required this.endDate,
    this.status = 'confirmed',
    this.source = 'manual',
    this.note = '',
    this.isScanned = false,
    this.guestCount = 1,
    this.scannedGuestCount = 0,
    this.checkInTime = '15:00',
    this.checkOutTime = '10:00',
    this.guests = const [],
    this.scannedAt,
    this.updatedAt,
  });

  // =====================================================
  // STATUS COLOR (booking workflow state)
  // =====================================================
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.amber;
      case 'cancelled':
        return Colors.grey;
      case 'checked_in':
        return Colors.teal;
      case 'checked_out':
        return Colors.blueGrey;
      case 'blocked':
      case 'closed':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }

  // =====================================================
  // SOURCE COLOR (booking origin platform)
  // =====================================================
  Color get sourceColor {
    switch (source.toLowerCase()) {
      case 'airbnb':
        return const Color(0xFFFF5A5F); // Airbnb coral
      case 'booking':
      case 'booking.com':
        return const Color(0xFF003580); // Booking.com blue
      case 'vrbo':
        return const Color(0xFF3D67FF); // VRBO blue
      case 'expedia':
        return const Color(0xFFFFCC00); // Expedia yellow
      case 'manual':
        return Colors.green;
      case 'private':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // =====================================================
  // BACKWARDS COMPATIBLE: Original 'color' getter
  // Uses SOURCE for display (matches original behavior)
  // =====================================================
  Color get color {
    // First check if status indicates special state
    if (status.toLowerCase() == 'blocked' || status.toLowerCase() == 'closed') {
      return Colors.red;
    }
    if (status.toLowerCase() == 'cancelled') {
      return Colors.grey;
    }

    // Otherwise use source for color (original behavior)
    switch (source.toLowerCase()) {
      case 'airbnb':
        return Colors.orange;
      case 'booking':
      case 'booking.com':
        return Colors.blue;
      case 'private':
        return Colors.yellow;
      case 'manual':
      case 'confirmed':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  // =====================================================
  // HELPER: Check if all guests are scanned
  // =====================================================
  bool get allGuestsScanned => scannedGuestCount >= guestCount;

  // =====================================================
  // HELPER: Scan progress (0.0 - 1.0)
  // =====================================================
  double get scanProgress {
    if (guestCount <= 0) return 0.0;
    return (scannedGuestCount / guestCount).clamp(0.0, 1.0);
  }

  // =====================================================
  // FACTORY: From Firestore Document
  // =====================================================
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Parse guests array safely
    List<Map<String, dynamic>> guestsList = [];
    if (data['guests'] != null) {
      try {
        final rawList = data['guests'] as List;
        guestsList =
            rawList.map((g) => Map<String, dynamic>.from(g as Map)).toList();
      } catch (e) {
        // debugPrint('⚠️ Failed to parse guests: $e');
      }
    }

    // Determine source from data or fallback to status (backwards compat)
    String bookingSource = data['source']?.toString() ?? '';
    if (bookingSource.isEmpty) {
      // Fallback: check if status contains source info (old data)
      final statusVal = data['status']?.toString().toLowerCase() ?? '';
      if (statusVal == 'airbnb' ||
          statusVal == 'booking' ||
          statusVal == 'booking.com' ||
          statusVal == 'private') {
        bookingSource = statusVal;
      } else {
        bookingSource = 'manual';
      }
    }

    // Determine actual status
    String bookingStatus = data['status']?.toString() ?? 'confirmed';
    // If status contains source info, normalize to 'confirmed'
    if (bookingStatus.toLowerCase() == 'airbnb' ||
        bookingStatus.toLowerCase() == 'booking' ||
        bookingStatus.toLowerCase() == 'booking.com' ||
        bookingStatus.toLowerCase() == 'private') {
      bookingStatus = 'confirmed';
    }

    return Booking(
      id: doc.id,
      ownerId: data['ownerId']?.toString() ?? '',
      unitId: data['unitId']?.toString() ?? '',
      guestName: data['guestName']?.toString() ?? 'Unknown',
      startDate: _parseDate(data['startDate']),
      endDate: _parseDate(data['endDate']),
      status: bookingStatus,
      source: bookingSource,
      note: data['note']?.toString() ?? '',
      isScanned: data['isScanned'] == true,
      guestCount: _parseInt(data['guestCount'], defaultValue: 1),
      scannedGuestCount: _parseInt(data['scannedGuestCount'], defaultValue: 0),
      checkInTime: data['checkInTime']?.toString() ?? '15:00',
      checkOutTime: data['checkOutTime']?.toString() ?? '10:00',
      guests: guestsList,
      scannedAt: _parseDateNullable(data['scannedAt']),
      updatedAt: _parseDateNullable(data['updatedAt']),
    );
  }

  // =====================================================
  // TO MAP: For Firestore Write
  // =====================================================
  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'unitId': unitId,
      'guestName': guestName,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status,
      'source': source,
      'note': note,
      'isScanned': isScanned,
      'guestCount': guestCount,
      'scannedGuestCount': scannedGuestCount,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'guests': guests,
      if (scannedAt != null) 'scannedAt': Timestamp.fromDate(scannedAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  // =====================================================
  // COPY WITH: For immutable updates
  // =====================================================
  Booking copyWith({
    String? id,
    String? ownerId,
    String? unitId,
    String? guestName,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? source,
    String? note,
    bool? isScanned,
    int? guestCount,
    int? scannedGuestCount,
    String? checkInTime,
    String? checkOutTime,
    List<Map<String, dynamic>>? guests,
    DateTime? scannedAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      unitId: unitId ?? this.unitId,
      guestName: guestName ?? this.guestName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      source: source ?? this.source,
      note: note ?? this.note,
      isScanned: isScanned ?? this.isScanned,
      guestCount: guestCount ?? this.guestCount,
      scannedGuestCount: scannedGuestCount ?? this.scannedGuestCount,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      guests: guests ?? this.guests,
      scannedAt: scannedAt ?? this.scannedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // =====================================================
  // HELPERS: Date & Int Parsing
  // =====================================================
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

  static DateTime? _parseDateNullable(dynamic val) {
    if (val == null) return null;
    if (val is Timestamp) return val.toDate();
    if (val is String) {
      try {
        return DateTime.parse(val);
      } catch (_) {}
    }
    return null;
  }

  static int _parseInt(dynamic val, {int defaultValue = 0}) {
    if (val == null) return defaultValue;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? defaultValue;
    return defaultValue;
  }

  // =====================================================
  // TO STRING: Debug Helper
  // =====================================================
  @override
  String toString() {
    return 'Booking(id: $id, guest: $guestName, unit: $unitId, '
        'status: $status, source: $source, isScanned: $isScanned, '
        'guests: ${guests.length}, scannedAt: $scannedAt)';
  }
}
