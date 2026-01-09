// FILE: lib/services/connectivity_service.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 2.0.0 - Phase 1 Production Readiness

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Connectivity Service - Network monitoring
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  final _statusController = StreamController<ConnectivityStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;
  bool _isInitialized = false;

  final List<VoidCallback> _onOnlineCallbacks = [];
  final List<VoidCallback> _onOfflineCallbacks = [];

  // =====================================================
  // GETTERS
  // =====================================================

  ConnectivityStatus get status => _currentStatus;
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;
  bool get isOnline => _currentStatus == ConnectivityStatus.online;
  bool get isOffline => _currentStatus == ConnectivityStatus.offline;

  // =====================================================
  // INITIALIZATION
  // =====================================================

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _checkConnectivity();

    _subscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
      onError: (error) {
        debugPrint('❌ ConnectivityService: Error: $error');
        _updateStatus(ConnectivityStatus.unknown);
      },
    );

    _isInitialized = true;
    debugPrint('✅ ConnectivityService: Initialized (status: $_currentStatus)');
  }

  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _handleConnectivityChange(results);
    } catch (e) {
      debugPrint('❌ ConnectivityService: Check failed: $e');
      _updateStatus(ConnectivityStatus.unknown);
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final newStatus = _mapResultsToStatus(results);

    if (newStatus != _currentStatus) {
      final wasOffline = _currentStatus == ConnectivityStatus.offline;
      final isNowOnline = newStatus == ConnectivityStatus.online;

      _updateStatus(newStatus);

      if (wasOffline && isNowOnline) {
        _triggerOnlineCallbacks();
      } else if (newStatus == ConnectivityStatus.offline) {
        _triggerOfflineCallbacks();
      }
    }
  }

  ConnectivityStatus _mapResultsToStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return ConnectivityStatus.offline;
    }

    for (final result in results) {
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.vpn) {
        return ConnectivityStatus.online;
      }
    }

    return ConnectivityStatus.unknown;
  }

  void _updateStatus(ConnectivityStatus newStatus) {
    _currentStatus = newStatus;
    _statusController.add(newStatus);
    debugPrint('📡 ConnectivityService: Status changed to $newStatus');
  }

  // =====================================================
  // CALLBACKS
  // =====================================================

  void onOnline(VoidCallback callback) {
    _onOnlineCallbacks.add(callback);
  }

  void onOffline(VoidCallback callback) {
    _onOfflineCallbacks.add(callback);
  }

  void removeOnlineCallback(VoidCallback callback) {
    _onOnlineCallbacks.remove(callback);
  }

  void removeOfflineCallback(VoidCallback callback) {
    _onOfflineCallbacks.remove(callback);
  }

  void _triggerOnlineCallbacks() {
    for (final callback in _onOnlineCallbacks) {
      try {
        callback();
      } catch (e) {
        debugPrint('❌ ConnectivityService: Callback error: $e');
      }
    }
  }

  void _triggerOfflineCallbacks() {
    for (final callback in _onOfflineCallbacks) {
      try {
        callback();
      } catch (e) {
        debugPrint('❌ ConnectivityService: Callback error: $e');
      }
    }
  }

  // =====================================================
  // UTILITIES
  // =====================================================

  Future<ConnectivityStatus> refresh() async {
    await _checkConnectivity();
    return _currentStatus;
  }

  Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (isOnline) return true;

    final completer = Completer<bool>();
    Timer? timer;
    StreamSubscription<ConnectivityStatus>? subscription;

    timer = Timer(timeout, () {
      subscription?.cancel();
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    subscription = statusStream.listen((status) {
      if (status == ConnectivityStatus.online) {
        timer?.cancel();
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      }
    });

    return completer.future;
  }

  void dispose() {
    _subscription?.cancel();
    _statusController.close();
    _onOnlineCallbacks.clear();
    _onOfflineCallbacks.clear();
    _isInitialized = false;
  }
}

enum ConnectivityStatus {
  online,
  offline,
  unknown,
}
