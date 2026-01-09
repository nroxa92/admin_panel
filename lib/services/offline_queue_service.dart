// FILE: lib/services/offline_queue_service.dart
// PROJECT: VillaOS - Phase 5 Enterprise Hardening
// FEATURE: Offline Queue with Auto-Sync
// STATUS: PRODUCTION READY

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';

/// Offline Queue Service - Queues operations when offline, syncs when online
class OfflineQueueService {
  static final OfflineQueueService _instance = OfflineQueueService._internal();
  factory OfflineQueueService() => _instance;
  OfflineQueueService._internal();

  final ConnectivityService _connectivity = ConnectivityService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _queueKey = 'vls_offline_queue';
  static const String _lastSyncKey = 'vls_last_sync';
  static const int _maxRetries = 3;
  static const int _maxQueueSize = 100;

  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  final List<QueuedOperation> _queue = [];

  bool _isInitialized = false;
  bool _isSyncing = false;
  int _pendingCount = 0;

  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  int get pendingCount => _pendingCount;
  bool get hasPendingOperations => _queue.isNotEmpty;
  bool get isSyncing => _isSyncing;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadQueue();
    _connectivity.onOnline(_onBackOnline);
    _isInitialized = true;
    debugPrint('✅ OfflineQueueService: Initialized (${_queue.length} pending)');
  }

  Future<void> enqueue(QueuedOperation operation) async {
    if (_queue.length >= _maxQueueSize) {
      debugPrint('⚠️ OfflineQueueService: Queue full, removing oldest');
      _queue.removeAt(0);
    }

    _queue.add(operation);
    _pendingCount = _queue.length;
    await _saveQueue();

    _syncStatusController.add(SyncStatus(
      state: SyncState.pending,
      pendingCount: _pendingCount,
      message: 'Operation queued for sync',
    ));

    debugPrint(
        '📥 OfflineQueueService: Queued ${operation.type} -> ${operation.collection}');
  }

  Future<String> queueCreate({
    required String collection,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    final id = documentId ?? _firestore.collection(collection).doc().id;

    final operation = QueuedOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OperationType.create,
      collection: collection,
      documentId: id,
      data: data,
      timestamp: DateTime.now(),
    );

    await enqueue(operation);
    return id;
  }

  Future<void> queueUpdate({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    final operation = QueuedOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OperationType.update,
      collection: collection,
      documentId: documentId,
      data: data,
      timestamp: DateTime.now(),
      merge: merge,
    );

    await enqueue(operation);
  }

  Future<void> queueDelete({
    required String collection,
    required String documentId,
  }) async {
    final operation = QueuedOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OperationType.delete,
      collection: collection,
      documentId: documentId,
      data: const {},
      timestamp: DateTime.now(),
    );

    await enqueue(operation);
  }

  void _onBackOnline() {
    debugPrint('🌐 OfflineQueueService: Back online, starting sync...');
    syncNow();
  }

  Future<SyncResult> syncNow() async {
    if (_isSyncing) {
      return SyncResult(success: false, message: 'Sync already in progress');
    }

    if (_queue.isEmpty) {
      return SyncResult(success: true, message: 'No pending operations');
    }

    if (!_connectivity.isOnline) {
      return SyncResult(success: false, message: 'Device is offline');
    }

    _isSyncing = true;
    _syncStatusController.add(SyncStatus(
      state: SyncState.syncing,
      pendingCount: _queue.length,
      message: 'Syncing ${_queue.length} operations...',
    ));

    int successCount = 0;
    int failCount = 0;
    final failedOperations = <QueuedOperation>[];

    while (_queue.isNotEmpty) {
      final operation = _queue.first;

      try {
        await _executeOperation(operation);
        _queue.removeAt(0);
        successCount++;

        _syncStatusController.add(SyncStatus(
          state: SyncState.syncing,
          pendingCount: _queue.length,
          message: 'Synced $successCount operations...',
        ));
      } catch (e) {
        debugPrint('❌ OfflineQueueService: Failed to sync: $e');

        operation.retryCount++;

        if (operation.retryCount >= _maxRetries) {
          _queue.removeAt(0);
          failedOperations.add(operation);
          failCount++;
        } else {
          _queue.removeAt(0);
          _queue.add(operation);
        }
      }
    }

    await _saveQueue();
    _pendingCount = _queue.length;
    _isSyncing = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

    final result = SyncResult(
      success: failCount == 0,
      syncedCount: successCount,
      failedCount: failCount,
      failedOperations: failedOperations,
      message: 'Synced $successCount, failed $failCount',
    );

    _syncStatusController.add(SyncStatus(
      state: failCount == 0 ? SyncState.synced : SyncState.error,
      pendingCount: _queue.length,
      message: result.message,
    ));

    debugPrint('✅ OfflineQueueService: Sync complete - ${result.message}');
    return result;
  }

  Future<void> _executeOperation(QueuedOperation operation) async {
    final docRef =
        _firestore.collection(operation.collection).doc(operation.documentId);

    switch (operation.type) {
      case OperationType.create:
        await docRef.set({
          ...operation.data,
          'createdAt': FieldValue.serverTimestamp(),
          'syncedAt': FieldValue.serverTimestamp(),
          '_offlineCreated': true,
        });
        break;

      case OperationType.update:
        if (operation.merge) {
          await docRef.set({
            ...operation.data,
            'updatedAt': FieldValue.serverTimestamp(),
            'syncedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } else {
          await docRef.update({
            ...operation.data,
            'updatedAt': FieldValue.serverTimestamp(),
            'syncedAt': FieldValue.serverTimestamp(),
          });
        }
        break;

      case OperationType.delete:
        await docRef.delete();
        break;
    }

    debugPrint(
        '✅ Executed ${operation.type} on ${operation.collection}/${operation.documentId}');
  }

  Future<void> _loadQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);

      if (queueJson != null) {
        final List<dynamic> decoded = jsonDecode(queueJson);
        _queue.clear();
        _queue.addAll(decoded.map(
            (e) => QueuedOperation.fromJson(Map<String, dynamic>.from(e))));
        _pendingCount = _queue.length;
        debugPrint(
            '📂 OfflineQueueService: Loaded ${_queue.length} queued operations');
      }
    } catch (e) {
      debugPrint('❌ OfflineQueueService: Failed to load queue: $e');
    }
  }

  Future<void> _saveQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = jsonEncode(_queue.map((e) => e.toJson()).toList());
      await prefs.setString(_queueKey, queueJson);
    } catch (e) {
      debugPrint('❌ OfflineQueueService: Failed to save queue: $e');
    }
  }

  Future<void> clearQueue() async {
    _queue.clear();
    _pendingCount = 0;
    await _saveQueue();

    _syncStatusController.add(SyncStatus(
      state: SyncState.synced,
      pendingCount: 0,
      message: 'Queue cleared',
    ));
  }

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getString(_lastSyncKey);
    return lastSync != null ? DateTime.parse(lastSync) : null;
  }

  void dispose() {
    _syncStatusController.close();
  }
}

// =====================================================
// DATA MODELS
// =====================================================

enum OperationType { create, update, delete }

enum SyncState { pending, syncing, synced, error }

class QueuedOperation {
  final String id;
  final OperationType type;
  final String collection;
  final String documentId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool merge;
  int retryCount;

  QueuedOperation({
    required this.id,
    required this.type,
    required this.collection,
    required this.documentId,
    required this.data,
    required this.timestamp,
    this.merge = true,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'collection': collection,
        'documentId': documentId,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'merge': merge,
        'retryCount': retryCount,
      };

  factory QueuedOperation.fromJson(Map<String, dynamic> json) =>
      QueuedOperation(
        id: json['id'] as String,
        type: OperationType.values.firstWhere((e) => e.name == json['type']),
        collection: json['collection'] as String,
        documentId: json['documentId'] as String,
        data: Map<String, dynamic>.from(json['data'] as Map),
        timestamp: DateTime.parse(json['timestamp'] as String),
        merge: json['merge'] as bool? ?? true,
        retryCount: json['retryCount'] as int? ?? 0,
      );
}

class SyncStatus {
  final SyncState state;
  final int pendingCount;
  final String message;

  SyncStatus({
    required this.state,
    required this.pendingCount,
    required this.message,
  });
}

class SyncResult {
  final bool success;
  final int syncedCount;
  final int failedCount;
  final List<QueuedOperation> failedOperations;
  final String message;

  SyncResult({
    required this.success,
    this.syncedCount = 0,
    this.failedCount = 0,
    this.failedOperations = const [],
    required this.message,
  });
}
