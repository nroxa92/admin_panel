// FILE: lib/services/cache_service.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 4.0.0 - Phase 4 Offline Mode

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache Service for Offline Mode
///
/// Provides local caching for critical data to enable
/// basic functionality when offline.
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  SharedPreferences? _prefs;
  bool _initialized = false;

  // Cache keys
  static const String _keyPrefix = 'vls_cache_';
  static const String _keyBookings = '${_keyPrefix}bookings';
  static const String _keyUnits = '${_keyPrefix}units';
  static const String _keySettings = '${_keyPrefix}settings';
  static const String _keyLastSync = '${_keyPrefix}last_sync';
  static const String _keyPendingActions = '${_keyPrefix}pending_actions';

  // Cache expiry (24 hours)
  static const Duration cacheExpiry = Duration(hours: 24);

  // =====================================================
  // INITIALIZATION
  // =====================================================

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      debugPrint('✅ CacheService initialized');
    } catch (e) {
      debugPrint('❌ CacheService initialization failed: $e');
    }
  }

  void _ensureInitialized() {
    if (!_initialized || _prefs == null) {
      throw StateError(
          'CacheService not initialized. Call initialize() first.');
    }
  }

  // =====================================================
  // GENERIC CACHE OPERATIONS
  // =====================================================

  /// Save data to cache with timestamp
  Future<bool> saveToCache(String key, dynamic data) async {
    _ensureInitialized();

    try {
      final cacheEntry = CacheEntry(
        data: data,
        timestamp: DateTime.now(),
      );

      final jsonString = jsonEncode(cacheEntry.toMap());
      return await _prefs!.setString(key, jsonString);
    } catch (e) {
      debugPrint('❌ CacheService.saveToCache error: $e');
      return false;
    }
  }

  /// Get data from cache (returns null if expired or not found)
  Future<T?> getFromCache<T>(String key, {Duration? maxAge}) async {
    _ensureInitialized();

    try {
      final jsonString = _prefs!.getString(key);
      if (jsonString == null) return null;

      final cacheEntry = CacheEntry.fromMap(jsonDecode(jsonString));

      // Check expiry
      final effectiveMaxAge = maxAge ?? cacheExpiry;
      if (cacheEntry.isExpired(effectiveMaxAge)) {
        await _prefs!.remove(key);
        return null;
      }

      return cacheEntry.data as T?;
    } catch (e) {
      debugPrint('❌ CacheService.getFromCache error: $e');
      return null;
    }
  }

  /// Check if cache entry exists and is valid
  Future<bool> isCacheValid(String key, {Duration? maxAge}) async {
    _ensureInitialized();

    try {
      final jsonString = _prefs!.getString(key);
      if (jsonString == null) return false;

      final cacheEntry = CacheEntry.fromMap(jsonDecode(jsonString));
      final effectiveMaxAge = maxAge ?? cacheExpiry;

      return !cacheEntry.isExpired(effectiveMaxAge);
    } catch (e) {
      return false;
    }
  }

  /// Clear specific cache entry
  Future<bool> clearCache(String key) async {
    _ensureInitialized();
    return await _prefs!.remove(key);
  }

  /// Clear all VLS cache entries
  Future<void> clearAllCache() async {
    _ensureInitialized();

    final keys = _prefs!.getKeys().where((k) => k.startsWith(_keyPrefix));
    for (final key in keys) {
      await _prefs!.remove(key);
    }
    debugPrint('🧹 All cache cleared');
  }

  // =====================================================
  // BOOKINGS CACHE
  // =====================================================

  /// Cache bookings list
  Future<bool> cacheBookings(List<Map<String, dynamic>> bookings) async {
    return saveToCache(_keyBookings, bookings);
  }

  /// Get cached bookings
  Future<List<Map<String, dynamic>>?> getCachedBookings() async {
    final data = await getFromCache<List<dynamic>>(_keyBookings);
    return data?.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // =====================================================
  // UNITS CACHE
  // =====================================================

  /// Cache units list
  Future<bool> cacheUnits(List<Map<String, dynamic>> units) async {
    return saveToCache(_keyUnits, units);
  }

  /// Get cached units
  Future<List<Map<String, dynamic>>?> getCachedUnits() async {
    final data = await getFromCache<List<dynamic>>(_keyUnits);
    return data?.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // =====================================================
  // SETTINGS CACHE
  // =====================================================

  /// Cache settings
  Future<bool> cacheSettings(Map<String, dynamic> settings) async {
    return saveToCache(_keySettings, settings);
  }

  /// Get cached settings
  Future<Map<String, dynamic>?> getCachedSettings() async {
    final data = await getFromCache<Map<String, dynamic>>(_keySettings);
    return data;
  }

  // =====================================================
  // SYNC TRACKING
  // =====================================================

  /// Update last sync timestamp
  Future<bool> updateLastSync() async {
    _ensureInitialized();
    return await _prefs!.setString(
      _keyLastSync,
      DateTime.now().toIso8601String(),
    );
  }

  /// Get last sync timestamp
  Future<DateTime?> getLastSync() async {
    _ensureInitialized();

    final timestamp = _prefs!.getString(_keyLastSync);
    if (timestamp == null) return null;

    return DateTime.tryParse(timestamp);
  }

  /// Check if sync is needed (older than specified duration)
  Future<bool> needsSync(
      {Duration threshold = const Duration(hours: 1)}) async {
    final lastSync = await getLastSync();
    if (lastSync == null) return true;

    return DateTime.now().difference(lastSync) > threshold;
  }

  // =====================================================
  // PENDING ACTIONS (Offline Queue)
  // =====================================================

  /// Add action to pending queue (for offline mode)
  Future<bool> addPendingAction(PendingAction action) async {
    _ensureInitialized();

    try {
      final actions = await getPendingActions();
      actions.add(action);

      final jsonList = actions.map((a) => a.toMap()).toList();
      return await _prefs!.setString(_keyPendingActions, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('❌ CacheService.addPendingAction error: $e');
      return false;
    }
  }

  /// Get all pending actions
  Future<List<PendingAction>> getPendingActions() async {
    _ensureInitialized();

    try {
      final jsonString = _prefs!.getString(_keyPendingActions);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((e) => PendingAction.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      debugPrint('❌ CacheService.getPendingActions error: $e');
      return [];
    }
  }

  /// Remove pending action after successful sync
  Future<bool> removePendingAction(String actionId) async {
    _ensureInitialized();

    try {
      final actions = await getPendingActions();
      actions.removeWhere((a) => a.id == actionId);

      final jsonList = actions.map((a) => a.toMap()).toList();
      return await _prefs!.setString(_keyPendingActions, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('❌ CacheService.removePendingAction error: $e');
      return false;
    }
  }

  /// Clear all pending actions
  Future<bool> clearPendingActions() async {
    _ensureInitialized();
    return await _prefs!.remove(_keyPendingActions);
  }

  /// Check if there are pending actions to sync
  Future<bool> hasPendingActions() async {
    final actions = await getPendingActions();
    return actions.isNotEmpty;
  }

  // =====================================================
  // CACHE STATS
  // =====================================================

  /// Get cache statistics
  Future<CacheStats> getStats() async {
    _ensureInitialized();

    final keys =
        _prefs!.getKeys().where((k) => k.startsWith(_keyPrefix)).toList();
    int totalSize = 0;

    for (final key in keys) {
      final value = _prefs!.getString(key);
      if (value != null) {
        totalSize += value.length;
      }
    }

    final lastSync = await getLastSync();
    final pendingActions = await getPendingActions();

    return CacheStats(
      entryCount: keys.length,
      totalSizeBytes: totalSize,
      lastSync: lastSync,
      pendingActionsCount: pendingActions.length,
    );
  }
}

// =====================================================
// MODELS
// =====================================================

class CacheEntry {
  final dynamic data;
  final DateTime timestamp;

  CacheEntry({required this.data, required this.timestamp});

  factory CacheEntry.fromMap(Map<String, dynamic> map) {
    return CacheEntry(
      data: map['data'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool isExpired(Duration maxAge) {
    return DateTime.now().difference(timestamp) > maxAge;
  }
}

class PendingAction {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  PendingAction({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  factory PendingAction.fromMap(Map<String, dynamic> map) {
    return PendingAction(
      id: map['id'],
      type: map['type'],
      data: Map<String, dynamic>.from(map['data']),
      createdAt: DateTime.parse(map['createdAt']),
      retryCount: map['retryCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  PendingAction copyWithRetry() {
    return PendingAction(
      id: id,
      type: type,
      data: data,
      createdAt: createdAt,
      retryCount: retryCount + 1,
    );
  }
}

class CacheStats {
  final int entryCount;
  final int totalSizeBytes;
  final DateTime? lastSync;
  final int pendingActionsCount;

  CacheStats({
    required this.entryCount,
    required this.totalSizeBytes,
    this.lastSync,
    required this.pendingActionsCount,
  });

  String get totalSizeFormatted {
    if (totalSizeBytes < 1024) return '$totalSizeBytes B';
    if (totalSizeBytes < 1024 * 1024) {
      return '${(totalSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Enum for pending action types
enum PendingActionType {
  createBooking,
  updateBooking,
  deleteBooking,
  updateSettings,
  addGuest,
}
