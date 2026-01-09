// FILE: lib/services/error_service.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 2.0.0 - Phase 1 Production Readiness

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Centralized Error Service with Sentry Integration
class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();

  bool _isInitialized = false;

  // =====================================================
  // INITIALIZATION
  // =====================================================

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (kDebugMode) {
      debugPrint('🐛 ErrorService: DEBUG mode - Sentry disabled');
      _isInitialized = true;
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = const String.fromEnvironment(
          'SENTRY_DSN',
          defaultValue: '',
        );
        options.environment = kDebugMode ? 'development' : 'production';
        options.tracesSampleRate = 0.3;
        options.release = 'vls-admin@2.0.0';
        options.attachScreenshot = false;
        options.beforeSend = _beforeSend;
      },
    );

    _isInitialized = true;
    debugPrint('✅ ErrorService: Sentry initialized');
  }

  FutureOr<SentryEvent?> _beforeSend(SentryEvent event, Hint hint) {
    final exceptionValue = event.exceptions?.firstOrNull?.value ?? '';

    if (exceptionValue.contains('SocketException') ||
        exceptionValue.contains('TimeoutException') ||
        exceptionValue.contains('permission-denied')) {
      return null;
    }

    return event;
  }

  // =====================================================
  // USER CONTEXT
  // =====================================================

  void setUserContext({
    required String? tenantId,
    required String? email,
    String? role,
  }) {
    if (!_isInitialized || kDebugMode) return;

    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: tenantId,
        email: email,
        data: {
          if (role != null) 'role': role,
        },
      ));
    });
  }

  void clearUserContext() {
    if (!_isInitialized || kDebugMode) return;

    Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }

  Future<void> setUserFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      clearUserContext();
      return;
    }

    final tokenResult = await user.getIdTokenResult();
    final claims = tokenResult.claims;

    setUserContext(
      tenantId: claims?['ownerId'] as String?,
      email: user.email,
      role: claims?['role'] as String?,
    );
  }

  // =====================================================
  // ERROR CAPTURE
  // =====================================================

  Future<void> captureException(
    dynamic exception, {
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? extras,
    ErrorSeverity severity = ErrorSeverity.error,
  }) async {
    debugPrint('❌ Error${context != null ? ' [$context]' : ''}: $exception');
    if (stackTrace != null && kDebugMode) {
      debugPrint(stackTrace.toString());
    }

    if (kDebugMode || !_isInitialized) return;

    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (context != null) {
          scope.setTag('context', context);
        }
        if (extras != null) {
          scope.setContexts('extras', extras);
        }
        scope.level = _mapSeverity(severity);
      },
    );
  }

  Future<void> captureMessage(
    String message, {
    ErrorSeverity severity = ErrorSeverity.info,
    Map<String, dynamic>? extras,
  }) async {
    debugPrint('📝 Message [${severity.name}]: $message');

    if (kDebugMode || !_isInitialized) return;

    await Sentry.captureMessage(
      message,
      level: _mapSeverity(severity),
      withScope: (scope) {
        if (extras != null) {
          scope.setContexts('extras', extras);
        }
      },
    );
  }

  SentryLevel _mapSeverity(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.debug:
        return SentryLevel.debug;
      case ErrorSeverity.info:
        return SentryLevel.info;
      case ErrorSeverity.warning:
        return SentryLevel.warning;
      case ErrorSeverity.error:
        return SentryLevel.error;
      case ErrorSeverity.fatal:
        return SentryLevel.fatal;
    }
  }

  // =====================================================
  // BREADCRUMBS
  // =====================================================

  void addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
  }) {
    if (kDebugMode || !_isInitialized) return;

    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      category: category,
      data: data,
      timestamp: DateTime.now(),
    ));
  }

  void trackScreenView(String screenName) {
    addBreadcrumb(
      message: 'Viewed $screenName',
      category: 'navigation',
      data: {'screen': screenName},
    );
  }

  void trackAction(String action, {Map<String, dynamic>? data}) {
    addBreadcrumb(
      message: action,
      category: 'user_action',
      data: data,
    );
  }

  // =====================================================
  // SPECIFIC ERROR HELPERS
  // =====================================================

  Future<void> captureFirebaseError(
    dynamic error, {
    required String operation,
    String? collection,
    String? documentId,
    StackTrace? stackTrace,
  }) async {
    await captureException(
      error,
      stackTrace: stackTrace,
      context: 'Firebase.$operation',
      extras: {
        'collection': collection,
        'documentId': documentId,
      },
    );
  }

  Future<void> captureAuthError(
    dynamic error, {
    required String operation,
    String? email,
    StackTrace? stackTrace,
  }) async {
    await captureException(
      error,
      stackTrace: stackTrace,
      context: 'Auth.$operation',
      extras: {
        'operation': operation,
        'email_domain': email?.split('@').lastOrNull,
      },
      severity: ErrorSeverity.warning,
    );
  }
}

enum ErrorSeverity {
  debug,
  info,
  warning,
  error,
  fatal,
}
