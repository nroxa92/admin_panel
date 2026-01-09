// FILE: lib/services/performance_service.dart
// PROJECT: VillaOS - Phase 5 Enterprise Hardening
// FEATURE: Performance Monitoring
// STATUS: PRODUCTION READY

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Performance Service - Tracks app performance metrics
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  bool _isInitialized = false;
  final Map<String, _TraceData> _activeTraces = {};
  final List<PerformanceMetric> _metrics = [];

  static const int _maxMetricsHistory = 100;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    debugPrint('✅ PerformanceService: Initialized');
  }

  /// Start a custom trace
  void startTrace(String name) {
    if (_activeTraces.containsKey(name)) {
      debugPrint('⚠️ PerformanceService: Trace "$name" already running');
      return;
    }

    _activeTraces[name] = _TraceData(
      name: name,
      startTime: DateTime.now(),
    );

    debugPrint('⏱️ PerformanceService: Started trace "$name"');
  }

  /// Stop a trace and record the duration
  Duration? stopTrace(String name, {Map<String, String>? attributes}) {
    final trace = _activeTraces.remove(name);
    if (trace == null) {
      debugPrint('⚠️ PerformanceService: No active trace "$name"');
      return null;
    }

    final duration = DateTime.now().difference(trace.startTime);

    final metric = PerformanceMetric(
      name: name,
      type: MetricType.trace,
      duration: duration,
      timestamp: DateTime.now(),
      attributes: attributes ?? {},
    );

    _recordMetric(metric);

    debugPrint(
        '⏱️ PerformanceService: Trace "$name" completed in ${duration.inMilliseconds}ms');
    return duration;
  }

  /// Measure an async operation
  Future<T> measureAsync<T>(String name, Future<T> Function() operation) async {
    startTrace(name);
    try {
      final result = await operation();
      stopTrace(name, attributes: {'status': 'success'});
      return result;
    } catch (e) {
      stopTrace(name, attributes: {'status': 'error', 'error': e.toString()});
      rethrow;
    }
  }

  /// Measure a sync operation
  T measureSync<T>(String name, T Function() operation) {
    startTrace(name);
    try {
      final result = operation();
      stopTrace(name, attributes: {'status': 'success'});
      return result;
    } catch (e) {
      stopTrace(name, attributes: {'status': 'error', 'error': e.toString()});
      rethrow;
    }
  }

  /// Track screen render time
  void trackScreenLoad(String screenName, Duration loadTime) {
    final metric = PerformanceMetric(
      name: 'screen_load_$screenName',
      type: MetricType.screenLoad,
      duration: loadTime,
      timestamp: DateTime.now(),
      attributes: {'screen': screenName},
    );

    _recordMetric(metric);
    debugPrint(
        '📱 PerformanceService: Screen "$screenName" loaded in ${loadTime.inMilliseconds}ms');
  }

  /// Track API call performance
  void trackApiCall({
    required String endpoint,
    required String method,
    required Duration duration,
    required int statusCode,
    int? responseSize,
  }) {
    final metric = PerformanceMetric(
      name: 'api_$method${endpoint.replaceAll('/', '_')}',
      type: MetricType.network,
      duration: duration,
      timestamp: DateTime.now(),
      attributes: {
        'endpoint': endpoint,
        'method': method,
        'statusCode': statusCode.toString(),
        if (responseSize != null) 'responseSize': responseSize.toString(),
      },
    );

    _recordMetric(metric);
    debugPrint(
        '🌐 PerformanceService: API $method $endpoint - ${duration.inMilliseconds}ms ($statusCode)');
  }

  /// Record a custom counter metric
  void incrementCounter(String name, {int value = 1}) {
    final metric = PerformanceMetric(
      name: name,
      type: MetricType.counter,
      value: value.toDouble(),
      timestamp: DateTime.now(),
    );

    _recordMetric(metric);
    debugPrint('📊 PerformanceService: Counter "$name" += $value');
  }

  /// Record a custom gauge metric
  void recordGauge(String name, double value, {String? unit}) {
    final metric = PerformanceMetric(
      name: name,
      type: MetricType.gauge,
      value: value,
      timestamp: DateTime.now(),
      attributes: {if (unit != null) 'unit': unit},
    );

    _recordMetric(metric);
    final unitStr = unit != null ? ' $unit' : '';
    debugPrint('📊 PerformanceService: Gauge "$name" = $value$unitStr');
  }

  /// Track memory usage
  void trackMemoryUsage() {
    final metric = PerformanceMetric(
      name: 'memory_snapshot',
      type: MetricType.memory,
      timestamp: DateTime.now(),
      attributes: {'platform': kIsWeb ? 'web' : 'mobile'},
    );

    _recordMetric(metric);
  }

  void _recordMetric(PerformanceMetric metric) {
    _metrics.add(metric);

    if (_metrics.length > _maxMetricsHistory) {
      _metrics.removeRange(0, _metrics.length - _maxMetricsHistory);
    }
  }

  /// Get all recorded metrics
  List<PerformanceMetric> getMetrics() => List.unmodifiable(_metrics);

  /// Get metrics by type
  List<PerformanceMetric> getMetricsByType(MetricType type) {
    return _metrics.where((m) => m.type == type).toList();
  }

  /// Get average duration for a trace name
  Duration? getAverageDuration(String traceName) {
    final traces = _metrics
        .where(
          (m) => m.name == traceName && m.duration != null,
        )
        .toList();

    if (traces.isEmpty) return null;

    final totalMs = traces.fold<int>(
      0,
      (sum, m) => sum + (m.duration?.inMilliseconds ?? 0),
    );

    return Duration(milliseconds: totalMs ~/ traces.length);
  }

  /// Get performance summary
  PerformanceSummary getSummary() {
    final traces = getMetricsByType(MetricType.trace);
    final screens = getMetricsByType(MetricType.screenLoad);
    final network = getMetricsByType(MetricType.network);

    return PerformanceSummary(
      totalTraces: traces.length,
      avgTraceDuration: _avgDuration(traces),
      totalScreenLoads: screens.length,
      avgScreenLoadTime: _avgDuration(screens),
      totalApiCalls: network.length,
      avgApiResponseTime: _avgDuration(network),
      slowestTrace: _slowest(traces),
      slowestScreen: _slowest(screens),
      slowestApi: _slowest(network),
    );
  }

  Duration _avgDuration(List<PerformanceMetric> metrics) {
    if (metrics.isEmpty) return Duration.zero;
    final total = metrics.fold<int>(
      0,
      (sum, m) => sum + (m.duration?.inMilliseconds ?? 0),
    );
    return Duration(milliseconds: total ~/ metrics.length);
  }

  PerformanceMetric? _slowest(List<PerformanceMetric> metrics) {
    if (metrics.isEmpty) return null;
    return metrics.reduce((a, b) =>
        (a.duration?.inMilliseconds ?? 0) > (b.duration?.inMilliseconds ?? 0)
            ? a
            : b);
  }

  /// Clear all metrics
  void clearMetrics() {
    _metrics.clear();
    debugPrint('🗑️ PerformanceService: Metrics cleared');
  }

  void dispose() {
    _activeTraces.clear();
    _metrics.clear();
  }
}

// =====================================================
// DATA MODELS
// =====================================================

enum MetricType { trace, screenLoad, network, counter, gauge, memory }

class _TraceData {
  final String name;
  final DateTime startTime;

  _TraceData({required this.name, required this.startTime});
}

class PerformanceMetric {
  final String name;
  final MetricType type;
  final Duration? duration;
  final double? value;
  final DateTime timestamp;
  final Map<String, String> attributes;

  PerformanceMetric({
    required this.name,
    required this.type,
    this.duration,
    this.value,
    required this.timestamp,
    this.attributes = const {},
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type.name,
        if (duration != null) 'durationMs': duration!.inMilliseconds,
        if (value != null) 'value': value,
        'timestamp': timestamp.toIso8601String(),
        'attributes': attributes,
      };
}

class PerformanceSummary {
  final int totalTraces;
  final Duration avgTraceDuration;
  final int totalScreenLoads;
  final Duration avgScreenLoadTime;
  final int totalApiCalls;
  final Duration avgApiResponseTime;
  final PerformanceMetric? slowestTrace;
  final PerformanceMetric? slowestScreen;
  final PerformanceMetric? slowestApi;

  PerformanceSummary({
    required this.totalTraces,
    required this.avgTraceDuration,
    required this.totalScreenLoads,
    required this.avgScreenLoadTime,
    required this.totalApiCalls,
    required this.avgApiResponseTime,
    this.slowestTrace,
    this.slowestScreen,
    this.slowestApi,
  });
}
