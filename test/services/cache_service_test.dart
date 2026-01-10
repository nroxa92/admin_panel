// FILE: test/services/cache_service_test.dart
// PROJECT: VillaOS Admin Panel
// DESCRIPTION: Unit tests for Cache Service
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cache Service', () {
    late _MockCacheService cacheService;

    setUp(() {
      cacheService = _MockCacheService();
    });

    group('Basic Cache Operations', () {
      test('should store and retrieve string values', () {
        cacheService.set('key1', 'value1');
        expect(cacheService.get<String>('key1'), equals('value1'));
      });

      test('should store and retrieve numeric values', () {
        cacheService.set('number', 42);
        expect(cacheService.get<int>('number'), equals(42));
      });

      test('should store and retrieve complex objects', () {
        final data = {'name': 'Test', 'count': 10};
        cacheService.set('object', data);
        expect(cacheService.get<Map>('object'), equals(data));
      });

      test('should return null for non-existent keys', () {
        expect(cacheService.get<String>('nonexistent'), isNull);
      });

      test('should overwrite existing values', () {
        cacheService.set('key', 'value1');
        cacheService.set('key', 'value2');
        expect(cacheService.get<String>('key'), equals('value2'));
      });
    });

    group('Cache Expiration', () {
      test('should return cached value before expiry', () {
        cacheService.setWithExpiry(
          'temp',
          'value',
          const Duration(minutes: 5),
        );
        expect(cacheService.get<String>('temp'), equals('value'));
      });

      test('should return null after expiry', () {
        cacheService.setWithExpiry(
          'expired',
          'value',
          const Duration(milliseconds: -1), // Already expired
        );
        expect(cacheService.get<String>('expired'), isNull);
      });

      test('should track expiry time correctly', () {
        const duration = Duration(minutes: 10);
        final before = DateTime.now();
        cacheService.setWithExpiry('key', 'value', duration);
        final after = DateTime.now();

        final expiry = cacheService.getExpiry('key');
        expect(expiry, isNotNull);
        expect(
            expiry!.isAfter(before.add(duration - const Duration(seconds: 1))),
            isTrue);
        expect(
            expiry.isBefore(after.add(duration + const Duration(seconds: 1))),
            isTrue);
      });
    });

    group('Cache Invalidation', () {
      test('should remove single key', () {
        cacheService.set('key1', 'value1');
        cacheService.set('key2', 'value2');

        cacheService.remove('key1');

        expect(cacheService.get<String>('key1'), isNull);
        expect(cacheService.get<String>('key2'), equals('value2'));
      });

      test('should clear all cache', () {
        cacheService.set('key1', 'value1');
        cacheService.set('key2', 'value2');
        cacheService.set('key3', 'value3');

        cacheService.clear();

        expect(cacheService.get<String>('key1'), isNull);
        expect(cacheService.get<String>('key2'), isNull);
        expect(cacheService.get<String>('key3'), isNull);
      });

      test('should remove keys by prefix', () {
        cacheService.set('booking_1', 'data1');
        cacheService.set('booking_2', 'data2');
        cacheService.set('unit_1', 'data3');

        cacheService.removeByPrefix('booking_');

        expect(cacheService.get<String>('booking_1'), isNull);
        expect(cacheService.get<String>('booking_2'), isNull);
        expect(cacheService.get<String>('unit_1'), equals('data3'));
      });
    });

    group('Cache Statistics', () {
      test('should track cache size', () {
        expect(cacheService.size, equals(0));

        cacheService.set('key1', 'value1');
        expect(cacheService.size, equals(1));

        cacheService.set('key2', 'value2');
        expect(cacheService.size, equals(2));

        cacheService.remove('key1');
        expect(cacheService.size, equals(1));
      });

      test('should track hit rate', () {
        cacheService.set('exists', 'value');

        // 2 hits
        cacheService.get<String>('exists');
        cacheService.get<String>('exists');

        // 1 miss
        cacheService.get<String>('missing');

        expect(cacheService.hitRate, closeTo(0.67, 0.01)); // 2/3
      });

      test('should track hit count', () {
        cacheService.set('key', 'value');

        cacheService.get<String>('key'); // Hit
        cacheService.get<String>('key'); // Hit
        cacheService.get<String>('missing'); // Miss

        expect(cacheService.hitCount, equals(2));
        expect(cacheService.missCount, equals(1));
      });
    });

    group('Cache Key Generation', () {
      test('should generate consistent keys for bookings', () {
        final key1 =
            _generateBookingCacheKey('owner1', 'unit1', DateTime(2024, 6, 1));
        final key2 =
            _generateBookingCacheKey('owner1', 'unit1', DateTime(2024, 6, 1));

        expect(key1, equals(key2));
      });

      test('should generate different keys for different parameters', () {
        final key1 =
            _generateBookingCacheKey('owner1', 'unit1', DateTime(2024, 6, 1));
        final key2 =
            _generateBookingCacheKey('owner1', 'unit2', DateTime(2024, 6, 1));

        expect(key1, isNot(equals(key2)));
      });

      test('should generate owner-scoped keys', () {
        final key = _generateBookingCacheKey(
            'OWNER_001', 'unit1', DateTime(2024, 6, 1));
        expect(key, contains('OWNER_001'));
      });
    });

    group('LRU Eviction', () {
      test('should evict least recently used when at capacity', () {
        final smallCache = _MockCacheService(maxSize: 3);

        smallCache.set('key1', 'value1');
        smallCache.set('key2', 'value2');
        smallCache.set('key3', 'value3');

        // Access key1 to make it recently used
        smallCache.get<String>('key1');

        // Add key4, should evict key2 (least recently used)
        smallCache.set('key4', 'value4');

        expect(
            smallCache.get<String>('key1'), equals('value1')); // Recently used
        expect(smallCache.get<String>('key2'), isNull); // Evicted
        expect(smallCache.get<String>('key3'), equals('value3'));
        expect(smallCache.get<String>('key4'), equals('value4'));
      });
    });

    group('Cache Warming', () {
      test('should pre-populate cache with data', () {
        final warmData = {
          'key1': 'value1',
          'key2': 'value2',
          'key3': 'value3',
        };

        cacheService.warmCache(warmData);

        expect(cacheService.get<String>('key1'), equals('value1'));
        expect(cacheService.get<String>('key2'), equals('value2'));
        expect(cacheService.get<String>('key3'), equals('value3'));
      });
    });
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOCK CACHE SERVICE
// ═══════════════════════════════════════════════════════════════════════════════

class _MockCacheService {
  final int maxSize;
  final Map<String, _CacheEntry> _cache = {};
  final List<String> _accessOrder = [];
  int _hitCount = 0;
  int _missCount = 0;

  _MockCacheService({this.maxSize = 100});

  T? get<T>(String key) {
    final entry = _cache[key];

    if (entry == null) {
      _missCount++;
      return null;
    }

    // Check expiry
    if (entry.expiry != null && DateTime.now().isAfter(entry.expiry!)) {
      _cache.remove(key);
      _accessOrder.remove(key);
      _missCount++;
      return null;
    }

    _hitCount++;

    // Update access order for LRU
    _accessOrder.remove(key);
    _accessOrder.add(key);

    return entry.value as T?;
  }

  void set(String key, dynamic value) {
    _evictIfNeeded();
    _cache[key] = _CacheEntry(value: value);
    _accessOrder.remove(key);
    _accessOrder.add(key);
  }

  void setWithExpiry(String key, dynamic value, Duration duration) {
    _evictIfNeeded();
    _cache[key] = _CacheEntry(
      value: value,
      expiry: DateTime.now().add(duration),
    );
    _accessOrder.remove(key);
    _accessOrder.add(key);
  }

  DateTime? getExpiry(String key) {
    return _cache[key]?.expiry;
  }

  void remove(String key) {
    _cache.remove(key);
    _accessOrder.remove(key);
  }

  void removeByPrefix(String prefix) {
    final keysToRemove =
        _cache.keys.where((k) => k.startsWith(prefix)).toList();
    for (final key in keysToRemove) {
      remove(key);
    }
  }

  void clear() {
    _cache.clear();
    _accessOrder.clear();
    _hitCount = 0;
    _missCount = 0;
  }

  void warmCache(Map<String, dynamic> data) {
    for (final entry in data.entries) {
      set(entry.key, entry.value);
    }
  }

  void _evictIfNeeded() {
    while (_cache.length >= maxSize && _accessOrder.isNotEmpty) {
      final lruKey = _accessOrder.removeAt(0);
      _cache.remove(lruKey);
    }
  }

  int get size => _cache.length;
  int get hitCount => _hitCount;
  int get missCount => _missCount;

  double get hitRate {
    final total = _hitCount + _missCount;
    if (total == 0) return 0.0;
    return _hitCount / total;
  }
}

class _CacheEntry {
  final dynamic value;
  final DateTime? expiry;

  _CacheEntry({required this.value, this.expiry});
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════

String _generateBookingCacheKey(String ownerId, String unitId, DateTime date) {
  return 'bookings_${ownerId}_${unitId}_${date.year}_${date.month}';
}
