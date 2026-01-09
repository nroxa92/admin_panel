// FILE: lib/services/super_admin_service.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 2.0.0 - Phase 2 Multiple Super Admins
// DATE: 2026-01-09

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Service for Super Admin operations
///
/// Phase 2 Features:
/// - Multiple Super Admins support
/// - Admin activity logging
/// - Backup management
class SuperAdminService {
  static final SuperAdminService _instance = SuperAdminService._internal();
  factory SuperAdminService() => _instance;
  SuperAdminService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west3');

  // Cache for super admin check
  static const String _primaryAdminEmail = 'vestaluminasystem@gmail.com';
  final Map<String, bool> _superAdminCache = {};
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  // =====================================================
  // SUPER ADMIN CHECK
  // =====================================================

  /// Check if email is a Super Admin
  /// Uses cache to avoid frequent Firestore reads
  Future<bool> isSuperAdmin(String? email) async {
    if (email == null || email.isEmpty) return false;

    final normalizedEmail = email.toLowerCase();

    // Primary admin always passes
    if (normalizedEmail == _primaryAdminEmail) {
      return true;
    }

    // Check cache
    if (_cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration &&
        _superAdminCache.containsKey(normalizedEmail)) {
      return _superAdminCache[normalizedEmail]!;
    }

    // Check Firestore
    try {
      final doc = await _firestore
          .collection('super_admins')
          .doc(normalizedEmail)
          .get();

      final isAdmin = doc.exists && doc.data()?['active'] == true;

      // Update cache
      _superAdminCache[normalizedEmail] = isAdmin;
      _cacheTime = DateTime.now();

      return isAdmin;
    } catch (e) {
      debugPrint('❌ Error checking super admin: $e');
      // Fallback to primary admin check only
      return normalizedEmail == _primaryAdminEmail;
    }
  }

  /// Check if email is the Primary Admin
  bool isPrimaryAdmin(String? email) {
    if (email == null) return false;
    return email.toLowerCase() == _primaryAdminEmail;
  }

  /// Clear cache (call after adding/removing admins)
  void clearCache() {
    _superAdminCache.clear();
    _cacheTime = null;
  }

  // =====================================================
  // SUPER ADMIN MANAGEMENT (Primary Admin Only)
  // =====================================================

  /// Add a new Super Admin
  Future<Map<String, dynamic>> addSuperAdmin({
    required String email,
    String? displayName,
  }) async {
    try {
      final callable = _functions.httpsCallable('addSuperAdmin');
      final result = await callable.call({
        'email': email,
        'displayName': displayName,
      });

      clearCache();
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      debugPrint('❌ Error adding super admin: $e');
      rethrow;
    }
  }

  /// Remove a Super Admin
  Future<Map<String, dynamic>> removeSuperAdmin(String email) async {
    try {
      final callable = _functions.httpsCallable('removeSuperAdmin');
      final result = await callable.call({
        'email': email,
      });

      clearCache();
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      debugPrint('❌ Error removing super admin: $e');
      rethrow;
    }
  }

  /// List all Super Admins
  Future<List<SuperAdmin>> listSuperAdmins() async {
    try {
      final callable = _functions.httpsCallable('listSuperAdmins');
      final result = await callable.call();

      final admins = (result.data['admins'] as List)
          .map((a) => SuperAdmin.fromMap(Map<String, dynamic>.from(a)))
          .toList();

      return admins;
    } catch (e) {
      debugPrint('❌ Error listing super admins: $e');
      rethrow;
    }
  }

  // =====================================================
  // BACKUP MANAGEMENT
  // =====================================================

  /// Trigger manual backup
  Future<Map<String, dynamic>> triggerBackup() async {
    try {
      final callable = _functions.httpsCallable('manualBackup');
      final result = await callable.call();

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      debugPrint('❌ Error triggering backup: $e');
      rethrow;
    }
  }

  /// Get list of backups
  Future<List<BackupInfo>> getBackups({int limit = 30}) async {
    try {
      final snapshot = await _firestore
          .collection('backups')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => BackupInfo.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting backups: $e');
      rethrow;
    }
  }

  // =====================================================
  // ADMIN LOGS
  // =====================================================

  /// Get admin activity logs
  Future<List<AdminLog>> getAdminLogs({int limit = 100}) async {
    try {
      final callable = _functions.httpsCallable('getAdminLogs');
      final result = await callable.call({'limit': limit});

      final logs = (result.data['logs'] as List)
          .map((l) => AdminLog.fromMap(Map<String, dynamic>.from(l)))
          .toList();

      return logs;
    } catch (e) {
      debugPrint('❌ Error getting admin logs: $e');
      rethrow;
    }
  }

  /// Stream admin logs in real-time
  Stream<List<AdminLog>> streamAdminLogs({int limit = 50}) {
    return _firestore
        .collection('admin_logs')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AdminLog.fromFirestore(doc)).toList());
  }
}

// =====================================================
// DATA MODELS
// =====================================================

class SuperAdmin {
  final String email;
  final String displayName;
  final bool active;
  final DateTime? addedAt;
  final String? addedBy;

  SuperAdmin({
    required this.email,
    required this.displayName,
    required this.active,
    this.addedAt,
    this.addedBy,
  });

  factory SuperAdmin.fromMap(Map<String, dynamic> map) {
    return SuperAdmin(
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      active: map['active'] ?? false,
      addedAt: map['addedAt'] != null ? DateTime.parse(map['addedAt']) : null,
      addedBy: map['addedBy'],
    );
  }

  bool get isPrimary => email.toLowerCase() == 'vestaluminasystem@gmail.com';
}

class BackupInfo {
  final String backupId;
  final DateTime? timestamp;
  final String status;
  final int totalDocuments;
  final List<String> collections;
  final String? triggeredBy;
  final String type;

  BackupInfo({
    required this.backupId,
    this.timestamp,
    required this.status,
    required this.totalDocuments,
    required this.collections,
    this.triggeredBy,
    required this.type,
  });

  factory BackupInfo.fromMap(String id, Map<String, dynamic> map) {
    return BackupInfo(
      backupId: id,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
      status: map['status'] ?? 'unknown',
      totalDocuments: map['totalDocuments'] ?? 0,
      collections: List<String>.from(map['collections'] ?? []),
      triggeredBy: map['triggeredBy'],
      type: map['type'] ?? 'scheduled',
    );
  }
}

class AdminLog {
  final String id;
  final String adminEmail;
  final String action;
  final Map<String, dynamic> details;
  final DateTime? timestamp;

  AdminLog({
    required this.id,
    required this.adminEmail,
    required this.action,
    required this.details,
    this.timestamp,
  });

  factory AdminLog.fromMap(Map<String, dynamic> map) {
    return AdminLog(
      id: map['id'] ?? '',
      adminEmail: map['adminEmail'] ?? '',
      action: map['action'] ?? '',
      details: Map<String, dynamic>.from(map['details'] ?? {}),
      timestamp:
          map['timestamp'] != null ? DateTime.parse(map['timestamp']) : null,
    );
  }

  factory AdminLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminLog(
      id: doc.id,
      adminEmail: data['adminEmail'] ?? '',
      action: data['action'] ?? '',
      details: Map<String, dynamic>.from(data['details'] ?? {}),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  String get actionDisplay {
    switch (action) {
      case 'CREATE_OWNER':
        return 'Created Owner';
      case 'DELETE_OWNER':
        return 'Deleted Owner';
      case 'RESET_PASSWORD':
        return 'Reset Password';
      case 'TOGGLE_STATUS':
        return 'Changed Status';
      case 'ADD_SUPER_ADMIN':
        return 'Added Super Admin';
      case 'REMOVE_SUPER_ADMIN':
        return 'Removed Super Admin';
      case 'MANUAL_BACKUP':
        return 'Manual Backup';
      default:
        return action;
    }
  }
}
