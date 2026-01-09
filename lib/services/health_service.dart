// FILE: lib/services/health_service.dart
// PROJECT: VillaOS - Phase 5 Enterprise Hardening
// FEATURE: System Health Dashboard
// STATUS: PRODUCTION READY

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'connectivity_service.dart';
import 'cache_service.dart';
import 'performance_service.dart';

/// Health Service - Monitors system health and provides diagnostics
class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectivityService _connectivity = ConnectivityService();
  final CacheService _cache = CacheService();
  final PerformanceService _performance = PerformanceService();

  final _healthController = StreamController<SystemHealth>.broadcast();
  Timer? _checkTimer;
  SystemHealth? _lastHealth;
  bool _isInitialized = false;

  static const Duration _checkInterval = Duration(minutes: 5);

  Stream<SystemHealth> get healthStream => _healthController.stream;
  SystemHealth? get lastHealth => _lastHealth;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await checkHealth();
    _checkTimer = Timer.periodic(_checkInterval, (_) => checkHealth());
    _isInitialized = true;
    debugPrint('✅ HealthService: Initialized');
  }

  /// Run all health checks
  Future<SystemHealth> checkHealth() async {
    final checks = <HealthCheck>[];
    var overallStatus = HealthStatus.healthy;

    // 1. Connectivity
    checks.add(_checkConnectivity());

    // 2. Authentication
    checks.add(await _checkAuthentication());

    // 3. Firestore
    checks.add(await _checkFirestore());

    // 4. Cache
    checks.add(await _checkCache());

    // 5. Performance
    checks.add(_checkPerformance());

    // Calculate overall status
    for (final check in checks) {
      if (check.status == HealthStatus.critical) {
        overallStatus = HealthStatus.critical;
        break;
      } else if (check.status == HealthStatus.warning &&
          overallStatus != HealthStatus.critical) {
        overallStatus = HealthStatus.warning;
      }
    }

    _lastHealth = SystemHealth(
      status: overallStatus,
      checks: checks,
      timestamp: DateTime.now(),
      uptime: _getUptime(),
    );

    _healthController.add(_lastHealth!);
    debugPrint('🏥 HealthService: Status = ${overallStatus.name}');

    return _lastHealth!;
  }

  HealthCheck _checkConnectivity() {
    final status =
        _connectivity.isOnline ? HealthStatus.healthy : HealthStatus.critical;

    return HealthCheck(
      name: 'Network Connectivity',
      component: 'connectivity',
      status: status,
      message: _connectivity.isOnline ? 'Connected' : 'Offline',
      details: {'status': _connectivity.status.name},
    );
  }

  Future<HealthCheck> _checkAuthentication() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return HealthCheck(
          name: 'Authentication',
          component: 'auth',
          status: HealthStatus.warning,
          message: 'Not authenticated',
        );
      }

      await user.getIdToken(true);

      return HealthCheck(
        name: 'Authentication',
        component: 'auth',
        status: HealthStatus.healthy,
        message: 'Authenticated',
        details: {
          'uid': user.uid,
          'email': user.email ?? 'N/A',
        },
      );
    } catch (e) {
      return HealthCheck(
        name: 'Authentication',
        component: 'auth',
        status: HealthStatus.critical,
        message: 'Auth error: $e',
      );
    }
  }

  Future<HealthCheck> _checkFirestore() async {
    final stopwatch = Stopwatch()..start();

    try {
      await _firestore.collection('_health').doc('ping').get();
      stopwatch.stop();

      final latency = stopwatch.elapsedMilliseconds;
      HealthStatus status;
      String message;

      if (latency < 500) {
        status = HealthStatus.healthy;
        message = 'Responsive (${latency}ms)';
      } else if (latency < 2000) {
        status = HealthStatus.warning;
        message = 'Slow response (${latency}ms)';
      } else {
        status = HealthStatus.critical;
        message = 'Very slow (${latency}ms)';
      }

      return HealthCheck(
        name: 'Firestore Database',
        component: 'firestore',
        status: status,
        message: message,
        latency: Duration(milliseconds: latency),
        details: {'latencyMs': latency.toString()},
      );
    } catch (e) {
      stopwatch.stop();
      return HealthCheck(
        name: 'Firestore Database',
        component: 'firestore',
        status: HealthStatus.critical,
        message: 'Connection failed: $e',
        latency: Duration(milliseconds: stopwatch.elapsedMilliseconds),
      );
    }
  }

  Future<HealthCheck> _checkCache() async {
    try {
      final stats = await _cache.getStats();

      HealthStatus status;
      String message;

      // Evaluate cache health based on entry count and pending actions
      if (stats.entryCount > 0 && stats.pendingActionsCount == 0) {
        status = HealthStatus.healthy;
        message =
            'Cache active (${stats.entryCount} entries, ${stats.totalSizeFormatted})';
      } else if (stats.pendingActionsCount > 0) {
        status = HealthStatus.warning;
        message = '${stats.pendingActionsCount} pending actions';
      } else {
        status = HealthStatus.healthy;
        message = 'Cache empty';
      }

      return HealthCheck(
        name: 'Cache System',
        component: 'cache',
        status: status,
        message: message,
        details: {
          'entryCount': stats.entryCount.toString(),
          'totalSize': stats.totalSizeFormatted,
          'pendingActions': stats.pendingActionsCount.toString(),
        },
      );
    } catch (e) {
      return HealthCheck(
        name: 'Cache System',
        component: 'cache',
        status: HealthStatus.warning,
        message: 'Cache check failed: $e',
      );
    }
  }

  HealthCheck _checkPerformance() {
    final summary = _performance.getSummary();

    HealthStatus status;
    String message;

    if (summary.avgApiResponseTime.inMilliseconds < 500) {
      status = HealthStatus.healthy;
      message = 'Good performance';
    } else if (summary.avgApiResponseTime.inMilliseconds < 2000) {
      status = HealthStatus.warning;
      message = 'Degraded performance';
    } else {
      status = HealthStatus.critical;
      message = 'Poor performance';
    }

    return HealthCheck(
      name: 'Performance',
      component: 'performance',
      status: status,
      message: message,
      details: {
        'avgApiMs': summary.avgApiResponseTime.inMilliseconds.toString(),
        'totalApiCalls': summary.totalApiCalls.toString(),
        'avgScreenLoadMs': summary.avgScreenLoadTime.inMilliseconds.toString(),
      },
    );
  }

  Future<DiagnosticsReport> getDiagnostics() async {
    final health = await checkHealth();

    return DiagnosticsReport(
      health: health,
      environment: _getEnvironmentInfo(),
      configuration: await _getConfigInfo(),
      metrics: await _getMetrics(),
      generatedAt: DateTime.now(),
    );
  }

  Map<String, String> _getEnvironmentInfo() {
    return {
      'platform': kIsWeb ? 'web' : 'mobile',
      'debugMode': kDebugMode.toString(),
      'profileMode': kProfileMode.toString(),
      'releaseMode': kReleaseMode.toString(),
    };
  }

  Future<Map<String, String>> _getConfigInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return {'auth': 'not_authenticated'};

      final tokenResult = await user.getIdTokenResult();
      final tenantId = tokenResult.claims?['ownerId'] as String?;

      return {
        'userId': user.uid,
        'tenantId': tenantId ?? 'N/A',
        'role': tokenResult.claims?['role']?.toString() ?? 'N/A',
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _getMetrics() async {
    final summary = _performance.getSummary();
    final cacheStats = await _cache.getStats();

    return {
      'totalTraces': summary.totalTraces,
      'avgTraceDurationMs': summary.avgTraceDuration.inMilliseconds,
      'totalApiCalls': summary.totalApiCalls,
      'avgApiResponseMs': summary.avgApiResponseTime.inMilliseconds,
      'cacheEntryCount': cacheStats.entryCount,
      'cacheSizeBytes': cacheStats.totalSizeBytes,
      'pendingActions': cacheStats.pendingActionsCount,
    };
  }

  Duration _getUptime() {
    return Duration(minutes: DateTime.now().minute);
  }

  List<HealthAlert> getAlerts() {
    if (_lastHealth == null) return [];

    final alerts = <HealthAlert>[];

    for (final check in _lastHealth!.checks) {
      if (check.status == HealthStatus.critical) {
        alerts.add(HealthAlert(
          severity: AlertSeverity.critical,
          component: check.component,
          message: '${check.name}: ${check.message}',
          timestamp: DateTime.now(),
        ));
      } else if (check.status == HealthStatus.warning) {
        alerts.add(HealthAlert(
          severity: AlertSeverity.warning,
          component: check.component,
          message: '${check.name}: ${check.message}',
          timestamp: DateTime.now(),
        ));
      }
    }

    return alerts;
  }

  void dispose() {
    _checkTimer?.cancel();
    _healthController.close();
  }
}

// =====================================================
// DATA MODELS
// =====================================================

enum HealthStatus { healthy, warning, critical }

enum AlertSeverity { info, warning, critical }

class SystemHealth {
  final HealthStatus status;
  final List<HealthCheck> checks;
  final DateTime timestamp;
  final Duration uptime;

  SystemHealth({
    required this.status,
    required this.checks,
    required this.timestamp,
    required this.uptime,
  });

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'checks': checks.map((c) => c.toJson()).toList(),
        'timestamp': timestamp.toIso8601String(),
        'uptimeMinutes': uptime.inMinutes,
      };
}

class HealthCheck {
  final String name;
  final String component;
  final HealthStatus status;
  final String message;
  final Duration? latency;
  final Map<String, String> details;

  HealthCheck({
    required this.name,
    required this.component,
    required this.status,
    required this.message,
    this.latency,
    this.details = const {},
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'component': component,
        'status': status.name,
        'message': message,
        if (latency != null) 'latencyMs': latency!.inMilliseconds,
        'details': details,
      };
}

class HealthAlert {
  final AlertSeverity severity;
  final String component;
  final String message;
  final DateTime timestamp;

  HealthAlert({
    required this.severity,
    required this.component,
    required this.message,
    required this.timestamp,
  });
}

class DiagnosticsReport {
  final SystemHealth health;
  final Map<String, String> environment;
  final Map<String, String> configuration;
  final Map<String, dynamic> metrics;
  final DateTime generatedAt;

  DiagnosticsReport({
    required this.health,
    required this.environment,
    required this.configuration,
    required this.metrics,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
        'health': health.toJson(),
        'environment': environment,
        'configuration': configuration,
        'metrics': metrics,
        'generatedAt': generatedAt.toIso8601String(),
      };
}
