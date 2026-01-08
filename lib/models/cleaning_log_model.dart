// FILE: lib/models/cleaning_log_model.dart
// STATUS: FIXED (Safe Boolean Map Parsing & Null-Safety)

import 'package:cloud_firestore/cloud_firestore.dart';

class CleaningLog {
  final String id;
  final String unitId;
  final String ownerId;
  final String cleanerName;
  final DateTime timestamp;
  final Map<String, bool> tasksCompleted;
  final String notes;
  final String status; // "completed", "inspection_needed"

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
      unitId: data['unit_id']?.toString() ?? '',
      ownerId: data['ownerId']?.toString() ?? '',
      cleanerName: data['cleaner_name']?.toString() ?? 'Staff',

      // FIX: Sigurno parsiranje datuma
      timestamp: _parseDate(data['timestamp']),

      // FIX: Sigurno parsiranje Mape zadataka (sprječava crash na non-bool vrijednostima)
      tasksCompleted: _parseTasks(data['tasks_completed']),

      notes: data['notes']?.toString() ?? '',
      status: data['status']?.toString() ?? 'completed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unit_id': unitId,
      'ownerId': ownerId,
      'cleaner_name': cleanerName,
      'timestamp': Timestamp.fromDate(timestamp),
      'tasks_completed': tasksCompleted,
      'notes': notes,
      'status': status,
    };
  }

  // --- HELPERI ---

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
          // Osiguraj da je ključ String, a vrijednost Bool
          if (v is bool) {
            safeMap[k.toString()] = v;
          } else {
            // Fallback za čudne podatke (npr. 1/0 ili stringovi)
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
