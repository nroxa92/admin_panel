// FILE: lib/utils/performance_utils.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 4.0.0 - Phase 4 Performance Optimization

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// =====================================================
// DEBOUNCER
// =====================================================

/// Debouncer for preventing excessive API calls
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

// =====================================================
// THROTTLER
// =====================================================

/// Throttler for rate limiting actions
class Throttler {
  final Duration duration;
  DateTime? _lastRun;

  Throttler({this.duration = const Duration(milliseconds: 500)});

  bool run(VoidCallback action) {
    final now = DateTime.now();

    if (_lastRun == null || now.difference(_lastRun!) >= duration) {
      _lastRun = now;
      action();
      return true;
    }
    return false;
  }

  void reset() {
    _lastRun = null;
  }
}

// =====================================================
// PAGINATED LIST
// =====================================================

/// Paginated data holder with loading state
class PaginatedList<T> {
  final List<T> items;
  final bool hasMore;
  final bool isLoading;
  final String? error;
  final DocumentSnapshot? lastDocument;

  const PaginatedList({
    this.items = const [],
    this.hasMore = true,
    this.isLoading = false,
    this.error,
    this.lastDocument,
  });

  PaginatedList<T> copyWith({
    List<T>? items,
    bool? hasMore,
    bool? isLoading,
    String? error,
    DocumentSnapshot? lastDocument,
  }) {
    return PaginatedList<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastDocument: lastDocument ?? this.lastDocument,
    );
  }

  PaginatedList<T> appendItems(
    List<T> newItems, {
    bool? hasMore,
    DocumentSnapshot? lastDocument,
  }) {
    return PaginatedList<T>(
      items: [...items, ...newItems],
      hasMore: hasMore ?? this.hasMore,
      isLoading: false,
      error: null,
      lastDocument: lastDocument ?? this.lastDocument,
    );
  }

  static PaginatedList<T> loading<T>() {
    return const PaginatedList(isLoading: true);
  }

  static PaginatedList<T> withError<T>(String error) {
    return PaginatedList(error: error, isLoading: false, hasMore: false);
  }
}

// =====================================================
// PAGINATION CONTROLLER
// =====================================================

/// Controller for managing paginated Firestore queries
class PaginationController<T> {
  final Query<Map<String, dynamic>> baseQuery;
  final int pageSize;
  final T Function(DocumentSnapshot<Map<String, dynamic>>) fromFirestore;

  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;
  final List<T> _items = [];

  PaginationController({
    required this.baseQuery,
    required this.fromFirestore,
    this.pageSize = 20,
  });

  List<T> get items => List.unmodifiable(_items);
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  bool get isEmpty => _items.isEmpty && !_isLoading;

  /// Load initial page
  Future<void> loadInitial() async {
    if (_isLoading) return;

    _isLoading = true;
    _items.clear();
    _lastDocument = null;
    _hasMore = true;

    try {
      final snapshot = await baseQuery.limit(pageSize).get();

      if (snapshot.docs.isEmpty) {
        _hasMore = false;
      } else {
        _lastDocument = snapshot.docs.last;
        _items.addAll(snapshot.docs.map((doc) => fromFirestore(doc)));
        _hasMore = snapshot.docs.length >= pageSize;
      }
    } finally {
      _isLoading = false;
    }
  }

  /// Load next page
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore || _lastDocument == null) return;

    _isLoading = true;

    try {
      final snapshot = await baseQuery
          .startAfterDocument(_lastDocument!)
          .limit(pageSize)
          .get();

      if (snapshot.docs.isEmpty) {
        _hasMore = false;
      } else {
        _lastDocument = snapshot.docs.last;
        _items.addAll(snapshot.docs.map((doc) => fromFirestore(doc)));
        _hasMore = snapshot.docs.length >= pageSize;
      }
    } finally {
      _isLoading = false;
    }
  }

  /// Refresh list
  Future<void> refresh() async {
    await loadInitial();
  }

  /// Clear all data
  void clear() {
    _items.clear();
    _lastDocument = null;
    _hasMore = true;
    _isLoading = false;
  }
}

// =====================================================
// LAZY LOADER WIDGET
// =====================================================

/// Widget that loads more data when scrolled to bottom
class LazyLoader extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final double threshold;

  const LazyLoader({
    super.key,
    required this.child,
    required this.onLoadMore,
    required this.hasMore,
    this.isLoading = false,
    this.threshold = 200.0,
  });

  @override
  State<LazyLoader> createState() => _LazyLoaderState();
}

class _LazyLoaderState extends State<LazyLoader> {
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - widget.threshold) {
            if (widget.hasMore && !widget.isLoading) {
              widget.onLoadMore();
            }
          }
        }
        return false;
      },
      child: widget.child,
    );
  }
}

// =====================================================
// CACHED IMAGE WITH PLACEHOLDER
// =====================================================

/// Image widget with loading placeholder and error handling
class CachedNetworkImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const CachedNetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    Widget image = Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoading(loadingProgress);
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildError();
      },
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[800],
          child: const Icon(Icons.image, color: Colors.grey),
        );
  }

  Widget _buildLoading(ImageChunkEvent progress) {
    final percent = progress.expectedTotalBytes != null
        ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
        : null;

    return Container(
      width: width,
      height: height,
      color: Colors.grey[900],
      child: Center(
        child: CircularProgressIndicator(
          value: percent,
          strokeWidth: 2,
          color: const Color(0xFFD4AF37),
        ),
      ),
    );
  }

  Widget _buildError() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[800],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
  }
}

// =====================================================
// MEMOIZER
// =====================================================

/// Simple memoization for expensive computations
class Memoizer<T, R> {
  final Map<T, R> _cache = {};
  final R Function(T) _compute;

  Memoizer(this._compute);

  R call(T input) {
    if (_cache.containsKey(input)) {
      return _cache[input]!;
    }
    final result = _compute(input);
    _cache[input] = result;
    return result;
  }

  void clear() {
    _cache.clear();
  }

  void remove(T input) {
    _cache.remove(input);
  }

  int get cacheSize => _cache.length;
}

// =====================================================
// ASYNC MEMOIZER
// =====================================================

/// Memoization for async operations with expiry
class AsyncMemoizer<T, R> {
  final Map<T, _CachedValue<R>> _cache = {};
  final Future<R> Function(T) _compute;
  final Duration expiry;

  AsyncMemoizer(this._compute, {this.expiry = const Duration(minutes: 5)});

  Future<R> call(T input) async {
    final cached = _cache[input];

    if (cached != null && !cached.isExpired(expiry)) {
      return cached.value;
    }

    final result = await _compute(input);
    _cache[input] = _CachedValue(result, DateTime.now());
    return result;
  }

  void invalidate(T input) {
    _cache.remove(input);
  }

  void clearAll() {
    _cache.clear();
  }
}

class _CachedValue<R> {
  final R value;
  final DateTime timestamp;

  _CachedValue(this.value, this.timestamp);

  bool isExpired(Duration expiry) {
    return DateTime.now().difference(timestamp) > expiry;
  }
}

// =====================================================
// BATCH PROCESSOR
// =====================================================

/// Process items in batches to avoid overwhelming the system
class BatchProcessor<T> {
  final int batchSize;
  final Duration delayBetweenBatches;

  BatchProcessor({
    this.batchSize = 10,
    this.delayBetweenBatches = const Duration(milliseconds: 100),
  });

  Future<List<R>> process<R>(
    List<T> items,
    Future<R> Function(T item) processor, {
    void Function(int processed, int total)? onProgress,
  }) async {
    final results = <R>[];

    for (int i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize).toList();
      final batchResults = await Future.wait(batch.map(processor));
      results.addAll(batchResults);

      onProgress?.call(results.length, items.length);

      if (i + batchSize < items.length) {
        await Future.delayed(delayBetweenBatches);
      }
    }

    return results;
  }
}

// =====================================================
// PERFORMANCE MONITOR
// =====================================================

/// Simple performance monitoring utility
class PerformanceMonitor {
  static final Map<String, List<Duration>> _measurements = {};

  static Stopwatch start() => Stopwatch()..start();

  static void record(String operation, Stopwatch stopwatch) {
    stopwatch.stop();
    _measurements.putIfAbsent(operation, () => []);
    _measurements[operation]!.add(stopwatch.elapsed);

    // Keep only last 100 measurements per operation
    if (_measurements[operation]!.length > 100) {
      _measurements[operation]!.removeAt(0);
    }
  }

  static Duration? getAverage(String operation) {
    final measurements = _measurements[operation];
    if (measurements == null || measurements.isEmpty) return null;

    final totalMs =
        measurements.fold<int>(0, (acc, d) => acc + d.inMilliseconds);
    return Duration(milliseconds: totalMs ~/ measurements.length);
  }

  static Map<String, Duration> getAllAverages() {
    return Map.fromEntries(
      _measurements.entries
          .map((e) => MapEntry(e.key, getAverage(e.key)!))
          .where((e) => e.value != Duration.zero),
    );
  }

  static void clear() {
    _measurements.clear();
  }
}
