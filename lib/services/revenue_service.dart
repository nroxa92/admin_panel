// FILE: lib/services/revenue_service.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 4.0.0 - Phase 4 Revenue Analytics

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Revenue Service for Financial Analytics
class RevenueService {
  static final RevenueService _instance = RevenueService._internal();
  factory RevenueService() => _instance;
  RevenueService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _ownerId;

  // =====================================================
  // INITIALIZATION
  // =====================================================

  Future<void> initialize() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final tokenResult = await user.getIdTokenResult();
    _ownerId = tokenResult.claims?['ownerId'] as String?;
  }

  void _ensureInitialized() {
    if (_ownerId == null) {
      throw StateError('RevenueService not initialized');
    }
  }

  // =====================================================
  // REVENUE OVERVIEW
  // =====================================================

  /// Get complete revenue dashboard data
  Future<RevenueDashboard> getDashboard({int? year}) async {
    _ensureInitialized();

    try {
      final targetYear = year ?? DateTime.now().year;
      final now = DateTime.now();

      // Fetch bookings for the year
      final startOfYear = DateTime(targetYear, 1, 1);
      final endOfYear = DateTime(targetYear + 1, 1, 1);

      final bookings = await _getBookingsWithRevenue(startOfYear, endOfYear);

      // Calculate monthly revenue
      final monthlyRevenue = _calculateMonthlyRevenue(bookings, targetYear);

      // Calculate totals
      double totalRevenue = 0;
      double totalNights = 0;
      int totalBookings = bookings.length;

      for (final booking in bookings) {
        totalRevenue += booking.totalPrice ?? 0;
        totalNights += booking.stayLength;
      }

      // Current month stats
      final startOfMonth = DateTime(now.year, now.month, 1);
      final currentMonthBookings = bookings
          .where((b) =>
              b.checkIn.isAfter(startOfMonth) ||
              (b.checkIn.month == now.month && b.checkIn.year == now.year))
          .toList();

      double currentMonthRevenue = 0;
      for (final booking in currentMonthBookings) {
        currentMonthRevenue += booking.totalPrice ?? 0;
      }

      // Previous month for comparison
      final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
      final endOfLastMonth = DateTime(now.year, now.month, 1);
      final lastMonthBookings = bookings
          .where((b) =>
              b.checkIn.isAfter(startOfLastMonth) &&
              b.checkIn.isBefore(endOfLastMonth))
          .toList();

      double lastMonthRevenue = 0;
      for (final booking in lastMonthBookings) {
        lastMonthRevenue += booking.totalPrice ?? 0;
      }

      // Calculate trends
      final revenueTrend = lastMonthRevenue > 0
          ? ((currentMonthRevenue - lastMonthRevenue) / lastMonthRevenue) * 100
          : 0.0;

      // Average daily rate
      final adr = totalNights > 0 ? totalRevenue / totalNights : 0.0;

      // Unit performance
      final unitPerformance = _getUnitRevenuePerformance(bookings);

      return RevenueDashboard(
        totalRevenue: totalRevenue,
        totalBookings: totalBookings,
        totalNights: totalNights.toInt(),
        averageDailyRate: adr,
        currentMonthRevenue: currentMonthRevenue,
        lastMonthRevenue: lastMonthRevenue,
        revenueTrend: revenueTrend,
        monthlyRevenue: monthlyRevenue,
        unitPerformance: unitPerformance,
        year: targetYear,
      );
    } catch (e) {
      debugPrint('❌ RevenueService.getDashboard error: $e');
      rethrow;
    }
  }

  // =====================================================
  // BOOKING REVENUE
  // =====================================================

  Future<List<BookingWithRevenue>> _getBookingsWithRevenue(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('ownerId', isEqualTo: _ownerId)
          .where('checkIn', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('checkIn', isLessThan: Timestamp.fromDate(end))
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BookingWithRevenue(
          id: doc.id,
          guestName: data['guestName'] ?? '',
          unitId: data['unitId'] ?? '',
          unitName: data['unitName'] ?? '',
          checkIn: (data['checkIn'] as Timestamp).toDate(),
          checkOut: (data['checkOut'] as Timestamp).toDate(),
          guestCount: data['guestCount'] ?? 1,
          status: data['status'] ?? 'pending',
          totalPrice: (data['totalPrice'] as num?)?.toDouble(),
          nightlyRate: (data['nightlyRate'] as num?)?.toDouble(),
          cleaningFee: (data['cleaningFee'] as num?)?.toDouble(),
          extraGuestFee: (data['extraGuestFee'] as num?)?.toDouble(),
          discount: (data['discount'] as num?)?.toDouble(),
          currency: data['currency'] ?? 'EUR',
          source: data['source'],
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ _getBookingsWithRevenue error: $e');
      rethrow;
    }
  }

  Map<String, double> _calculateMonthlyRevenue(
    List<BookingWithRevenue> bookings,
    int year,
  ) {
    final Map<String, double> monthly = {};

    for (int i = 1; i <= 12; i++) {
      monthly[i.toString().padLeft(2, '0')] = 0;
    }

    for (final booking in bookings) {
      if (booking.checkIn.year == year) {
        final month = booking.checkIn.month.toString().padLeft(2, '0');
        monthly[month] = (monthly[month] ?? 0) + (booking.totalPrice ?? 0);
      }
    }

    return monthly;
  }

  List<UnitRevenue> _getUnitRevenuePerformance(
    List<BookingWithRevenue> bookings,
  ) {
    final Map<String, UnitRevenue> unitMap = {};

    for (final booking in bookings) {
      if (!unitMap.containsKey(booking.unitId)) {
        unitMap[booking.unitId] = UnitRevenue(
          unitId: booking.unitId,
          unitName: booking.unitName,
          totalRevenue: 0,
          totalBookings: 0,
          totalNights: 0,
        );
      }

      final unit = unitMap[booking.unitId]!;
      unitMap[booking.unitId] = UnitRevenue(
        unitId: unit.unitId,
        unitName: unit.unitName,
        totalRevenue: unit.totalRevenue + (booking.totalPrice ?? 0),
        totalBookings: unit.totalBookings + 1,
        totalNights: unit.totalNights + booking.stayLength,
      );
    }

    final list = unitMap.values.toList();
    list.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    return list;
  }

  // =====================================================
  // PRICING ANALYTICS
  // =====================================================

  /// Get pricing analytics
  Future<PricingAnalytics> getPricingAnalytics({int? year}) async {
    _ensureInitialized();

    try {
      final targetYear = year ?? DateTime.now().year;
      final startOfYear = DateTime(targetYear, 1, 1);
      final endOfYear = DateTime(targetYear + 1, 1, 1);

      final bookings = await _getBookingsWithRevenue(startOfYear, endOfYear);

      if (bookings.isEmpty) {
        return PricingAnalytics.empty();
      }

      // Calculate rates
      final rates = bookings
          .where((b) => b.nightlyRate != null && b.nightlyRate! > 0)
          .map((b) => b.nightlyRate!)
          .toList();

      if (rates.isEmpty) {
        return PricingAnalytics.empty();
      }

      rates.sort();

      final minRate = rates.first;
      final maxRate = rates.last;
      final avgRate = rates.reduce((a, b) => a + b) / rates.length;
      final medianRate = rates[rates.length ~/ 2];

      // Seasonal analysis
      final seasonalRates = _analyzeSeasonalRates(bookings);

      // Source analysis
      final sourceRevenue = _analyzeRevenueBySource(bookings);

      return PricingAnalytics(
        averageNightlyRate: avgRate,
        minNightlyRate: minRate,
        maxNightlyRate: maxRate,
        medianNightlyRate: medianRate,
        seasonalRates: seasonalRates,
        revenueBySource: sourceRevenue,
      );
    } catch (e) {
      debugPrint('❌ RevenueService.getPricingAnalytics error: $e');
      rethrow;
    }
  }

  Map<String, double> _analyzeSeasonalRates(List<BookingWithRevenue> bookings) {
    final Map<String, List<double>> seasonRates = {
      'Winter': [], // Dec, Jan, Feb
      'Spring': [], // Mar, Apr, May
      'Summer': [], // Jun, Jul, Aug
      'Autumn': [], // Sep, Oct, Nov
    };

    for (final booking in bookings) {
      if (booking.nightlyRate == null) continue;

      final month = booking.checkIn.month;
      String season;

      if (month == 12 || month <= 2) {
        season = 'Winter';
      } else if (month <= 5) {
        season = 'Spring';
      } else if (month <= 8) {
        season = 'Summer';
      } else {
        season = 'Autumn';
      }

      seasonRates[season]!.add(booking.nightlyRate!);
    }

    return seasonRates.map((season, rates) {
      if (rates.isEmpty) return MapEntry(season, 0.0);
      return MapEntry(season, rates.reduce((a, b) => a + b) / rates.length);
    });
  }

  Map<String, double> _analyzeRevenueBySource(
      List<BookingWithRevenue> bookings) {
    final Map<String, double> sourceRevenue = {};

    for (final booking in bookings) {
      final source = booking.source ?? 'Direct';
      sourceRevenue[source] =
          (sourceRevenue[source] ?? 0) + (booking.totalPrice ?? 0);
    }

    return sourceRevenue;
  }

  // =====================================================
  // FORECASTING
  // =====================================================

  /// Simple revenue forecast based on historical data
  Future<RevenueForecast> getForecast({int monthsAhead = 3}) async {
    _ensureInitialized();

    try {
      final now = DateTime.now();
      final lastYear = DateTime(now.year - 1, now.month, 1);

      final bookings = await _getBookingsWithRevenue(lastYear, now);

      if (bookings.isEmpty) {
        return RevenueForecast(
          months: [],
          confidence: 0,
        );
      }

      // Calculate average monthly revenue
      final monthlyTotals = <int, double>{};
      for (final booking in bookings) {
        final monthKey = booking.checkIn.year * 12 + booking.checkIn.month;
        monthlyTotals[monthKey] =
            (monthlyTotals[monthKey] ?? 0) + (booking.totalPrice ?? 0);
      }

      final avgMonthlyRevenue =
          monthlyTotals.values.reduce((a, b) => a + b) / monthlyTotals.length;

      // Generate forecast
      final forecasts = <MonthForecast>[];
      for (int i = 1; i <= monthsAhead; i++) {
        final forecastMonth = DateTime(now.year, now.month + i, 1);

        // Apply seasonal factor (simplified)
        double seasonalFactor = 1.0;
        if (forecastMonth.month >= 6 && forecastMonth.month <= 8) {
          seasonalFactor = 1.5; // Summer peak
        } else if (forecastMonth.month == 12 || forecastMonth.month <= 2) {
          seasonalFactor = 0.7; // Winter low
        }

        forecasts.add(MonthForecast(
          month: forecastMonth,
          projectedRevenue: avgMonthlyRevenue * seasonalFactor,
          lowerBound: avgMonthlyRevenue * seasonalFactor * 0.8,
          upperBound: avgMonthlyRevenue * seasonalFactor * 1.2,
        ));
      }

      return RevenueForecast(
        months: forecasts,
        confidence: 0.7, // 70% confidence for simple model
      );
    } catch (e) {
      debugPrint('❌ RevenueService.getForecast error: $e');
      rethrow;
    }
  }

  // =====================================================
  // EXPORT
  // =====================================================

  /// Export revenue data as CSV
  Future<String> exportRevenueCsv({
    required DateTime start,
    required DateTime end,
  }) async {
    _ensureInitialized();

    try {
      final bookings = await _getBookingsWithRevenue(start, end);

      final buffer = StringBuffer();
      buffer.writeln(
          'Booking ID,Guest,Unit,Check-In,Check-Out,Nights,Nightly Rate,Total Price,Currency,Source');

      for (final booking in bookings) {
        buffer.writeln('${booking.id},'
            '"${booking.guestName}",'
            '"${booking.unitName}",'
            '${booking.checkIn.toIso8601String().split('T')[0]},'
            '${booking.checkOut.toIso8601String().split('T')[0]},'
            '${booking.stayLength},'
            '${booking.nightlyRate ?? 0},'
            '${booking.totalPrice ?? 0},'
            '${booking.currency},'
            '${booking.source ?? 'Direct'}');
      }

      return buffer.toString();
    } catch (e) {
      debugPrint('❌ RevenueService.exportRevenueCsv error: $e');
      rethrow;
    }
  }
}

// =====================================================
// DATA MODELS
// =====================================================

class BookingWithRevenue {
  final String id;
  final String guestName;
  final String unitId;
  final String unitName;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guestCount;
  final String status;
  final double? totalPrice;
  final double? nightlyRate;
  final double? cleaningFee;
  final double? extraGuestFee;
  final double? discount;
  final String currency;
  final String? source;

  BookingWithRevenue({
    required this.id,
    required this.guestName,
    required this.unitId,
    required this.unitName,
    required this.checkIn,
    required this.checkOut,
    required this.guestCount,
    required this.status,
    this.totalPrice,
    this.nightlyRate,
    this.cleaningFee,
    this.extraGuestFee,
    this.discount,
    required this.currency,
    this.source,
  });

  int get stayLength => checkOut.difference(checkIn).inDays;
}

class RevenueDashboard {
  final double totalRevenue;
  final int totalBookings;
  final int totalNights;
  final double averageDailyRate;
  final double currentMonthRevenue;
  final double lastMonthRevenue;
  final double revenueTrend;
  final Map<String, double> monthlyRevenue;
  final List<UnitRevenue> unitPerformance;
  final int year;

  RevenueDashboard({
    required this.totalRevenue,
    required this.totalBookings,
    required this.totalNights,
    required this.averageDailyRate,
    required this.currentMonthRevenue,
    required this.lastMonthRevenue,
    required this.revenueTrend,
    required this.monthlyRevenue,
    required this.unitPerformance,
    required this.year,
  });

  double get averageBookingValue =>
      totalBookings > 0 ? totalRevenue / totalBookings : 0;
}

class UnitRevenue {
  final String unitId;
  final String unitName;
  final double totalRevenue;
  final int totalBookings;
  final int totalNights;

  UnitRevenue({
    required this.unitId,
    required this.unitName,
    required this.totalRevenue,
    required this.totalBookings,
    required this.totalNights,
  });

  double get averageBookingValue =>
      totalBookings > 0 ? totalRevenue / totalBookings : 0;

  double get averageNightlyRate =>
      totalNights > 0 ? totalRevenue / totalNights : 0;
}

class PricingAnalytics {
  final double averageNightlyRate;
  final double minNightlyRate;
  final double maxNightlyRate;
  final double medianNightlyRate;
  final Map<String, double> seasonalRates;
  final Map<String, double> revenueBySource;

  PricingAnalytics({
    required this.averageNightlyRate,
    required this.minNightlyRate,
    required this.maxNightlyRate,
    required this.medianNightlyRate,
    required this.seasonalRates,
    required this.revenueBySource,
  });

  factory PricingAnalytics.empty() {
    return PricingAnalytics(
      averageNightlyRate: 0,
      minNightlyRate: 0,
      maxNightlyRate: 0,
      medianNightlyRate: 0,
      seasonalRates: {},
      revenueBySource: {},
    );
  }
}

class RevenueForecast {
  final List<MonthForecast> months;
  final double confidence;

  RevenueForecast({
    required this.months,
    required this.confidence,
  });
}

class MonthForecast {
  final DateTime month;
  final double projectedRevenue;
  final double lowerBound;
  final double upperBound;

  MonthForecast({
    required this.month,
    required this.projectedRevenue,
    required this.lowerBound,
    required this.upperBound,
  });
}
