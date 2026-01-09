// FILE: lib/services/app_check_service.dart
// PROJECT: VillaOS - Phase 5 Enterprise Hardening
// FEATURE: Firebase App Check - Security Hardening (STUB VERSION)
// STATUS: READY - Add firebase_app_check package when needed

import 'dart:async';
import 'package:flutter/foundation.dart';

/// App Check Service - Protects backend from abuse
/// STUB VERSION - Works without firebase_app_check package
class AppCheckService {
  static final AppCheckService _instance = AppCheckService._internal();
  factory AppCheckService() => _instance;
  AppCheckService._internal();

  bool _isInitialized = false;
  bool _isEnabled = false;
  String? _currentToken;
  DateTime? _tokenExpiry;

  bool get isEnabled => _isEnabled;
  bool get hasValidToken =>
      _currentToken != null &&
      _tokenExpiry != null &&
      _tokenExpiry!.isAfter(DateTime.now());

  /// Initialize App Check (STUB - no-op until package added)
  Future<void> initialize({bool forceDebugProvider = false}) async {
    if (_isInitialized) return;
    _isEnabled = false;
    _isInitialized = true;
    debugPrint('✅ AppCheckService: Initialized (STUB MODE)');
  }

  /// Get App Check token (STUB - returns null)
  Future<String?> getToken({bool forceRefresh = false}) async => null;

  /// Get limited-use token (STUB - returns null)
  Future<String?> getLimitedUseToken() async => null;

  /// Set auto-refresh (STUB - no-op)
  Future<void> setTokenAutoRefreshEnabled(bool enabled) async {}

  /// Debug info
  Map<String, dynamic> getDebugInfo() => {
        'isInitialized': _isInitialized,
        'isEnabled': _isEnabled,
        'mode': 'STUB',
      };

  void dispose() {
    _currentToken = null;
    _tokenExpiry = null;
  }
}
