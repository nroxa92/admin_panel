// FILE: lib/models/cleaning_log_model.dart
// VERSION: 2.0 - camelCase Migration
// DATE: 2026-01-09

import 'package:cloud_firestore/cloud_firestore.dart';

class CleaningLog {
  final String id;
  final String unitId;
  final String ownerId;
  final String cleanerName;
  final DateTime timestamp;
  final Map<String, bool> tasksCompleted;
  final String notes;
  final String status;

  CleaningLog({
    required this.id,
    required this.unitId,
    required this.ownerId,
    required this.cleanerName,
    required this.timestamp,
    required this.tasksCompleted,
    this.notes = '',
    this.status = 'completed',
  });

  factory CleaningLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return CleaningLog(
      id: doc.id,
      unitId: data['unitId']?.toString() ?? '',
      ownerId: data['ownerId']?.toString() ?? '',
      cleanerName: data['cleanerName']?.toString() ?? 'Staff',
      timestamp: _parseDate(data['timestamp']),
      tasksCompleted: _parseTasks(data['tasksCompleted']),
      notes: data['notes']?.toString() ?? '',
      status: data['status']?.toString() ?? 'completed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unitId': unitId,
      'ownerId': ownerId,
      'cleanerName': cleanerName,
      'timestamp': Timestamp.fromDate(timestamp),
      'tasksCompleted': tasksCompleted,
      'notes': notes,
      'status': status,
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

  static Map<String, bool> _parseTasks(dynamic val) {
    if (val == null) return {};
    if (val is Map) {
      try {
        final Map<String, bool> safeMap = {};
        val.forEach((k, v) {
          if (v is bool) {
            safeMap[k.toString()] = v;
          } else {
            safeMap[k.toString()] = false;
          }
        });
        return safeMap;
      } catch (_) {
        return {};
      }
    }
    return {};
  }
}
