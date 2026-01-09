// FILE: lib/services/analytics_service.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 3.0.0 - Phase 3 Analytics Dashboard

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../repositories/booking_repository.dart';
import '../repositories/units_repository.dart';

/// Analytics Service
///
/// Provides comprehensive analytics and statistics for the dashboard.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _ownerId;
  BookingRepository? _bookingRepo;
  UnitsRepository? _unitsRepo;

  // =====================================================
  // INITIALIZATION
  // =====================================================

  Future<void> initialize() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final tokenResult = await user.getIdTokenResult();
    _ownerId = tokenResult.claims?['ownerId'] as String?;

    if (_ownerId != null) {
      _bookingRepo = BookingRepository(ownerId: _ownerId!);
      _unitsRepo = UnitsRepository(ownerId: _ownerId!);
    }
  }

  void _ensureInitialized() {
    if (_ownerId == null || _bookingRepo == null) {
      throw StateError(
          'AnalyticsService not initialized. Call initialize() first.');
    }
  }

  // =====================================================
  // DASHBOARD OVERVIEW
  // =====================================================

  /// Get complete dashboard data
  Future<DashboardData> getDashboardData() async {
    _ensureInitialized();

    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfYear = DateTime(now.year, 1, 1);
      final lastMonth = DateTime(now.year, now.month - 1, 1);

      // Parallel fetch for performance
      final results = await Future.wait([
        _bookingRepo!.getStats(since: startOfMonth),
        _bookingRepo!.getStats(since: startOfYear),
        _bookingRepo!.getStats(since: lastMonth),
        _unitsRepo!.getStats(),
        _bookingRepo!.getTodayCheckIns(),
        _bookingRepo!.getTodayCheckOuts(),
        _bookingRepo!.getUpcomingBookings(limit: 5),
        _bookingRepo!.getBookingCountByMonth(now.year),
      ]);

      final thisMonthStats = results[0] as BookingStats;
      final yearStats = results[1] as BookingStats;
      final lastMonthStats = results[2] as BookingStats;
      final unitStats = results[3] as UnitStats;
      final todayCheckIns = results[4] as List<Booking>;
      final todayCheckOuts = results[5] as List<Booking>;
      final upcomingBookings = results[6] as List<Booking>;
      final monthlyBookings = results[7] as Map<String, int>;

      // Calculate trends
      final bookingTrend = _calculateTrend(
        thisMonthStats.totalBookings,
        lastMonthStats.totalBookings,
      );
      final guestTrend = _calculateTrend(
        thisMonthStats.totalGuests,
        lastMonthStats.totalGuests,
      );

      return DashboardData(
        // Overview stats
        totalBookingsThisMonth: thisMonthStats.totalBookings,
        totalGuestsThisMonth: thisMonthStats.totalGuests,
        totalBookingsThisYear: yearStats.totalBookings,
        totalGuestsThisYear: yearStats.totalGuests,

        // Unit stats
        totalUnits: unitStats.totalUnits,
        activeUnits: unitStats.activeUnits,
        totalCapacity: unitStats.totalCapacity,

        // Today
        todayCheckIns: todayCheckIns.length,
        todayCheckOuts: todayCheckOuts.length,

        // Trends
        bookingTrend: bookingTrend,
        guestTrend: guestTrend,

        // Performance
        averageStayLength: yearStats.averageStayLength,
        completionRate: yearStats.completionRate,
        cancellationRate: yearStats.cancellationRate,

        // Lists
        upcomingBookings: upcomingBookings,
        todayCheckInsList: todayCheckIns,
        todayCheckOutsList: todayCheckOuts,

        // Chart data
        monthlyBookings: monthlyBookings,
      );
    } catch (e) {
      debugPrint('❌ AnalyticsService.getDashboardData error: $e');
      rethrow;
    }
  }

  double _calculateTrend(int current, int previous) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous) * 100;
  }

  // =====================================================
  // BOOKING ANALYTICS
  // =====================================================

  /// Get booking trends by period
  Future<List<ChartDataPoint>> getBookingTrends({
    required TrendPeriod period,
    int? year,
  }) async {
    _ensureInitialized();

    try {
      final targetYear = year ?? DateTime.now().year;
      final monthlyData =
          await _bookingRepo!.getBookingCountByMonth(targetYear);

      return monthlyData.entries.map((e) {
        final monthNum = int.parse(e.key);
        final monthName = _getMonthName(monthNum);
        return ChartDataPoint(
          label: monthName,
          value: e.value.toDouble(),
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ AnalyticsService.getBookingTrends error: $e');
      rethrow;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  // =====================================================
  // OCCUPANCY ANALYTICS
  // =====================================================

  /// Get occupancy rate for period
  Future<double> getOccupancyRate({
    required DateTime start,
    required DateTime end,
  }) async {
    _ensureInitialized();

    try {
      final unitCount = await _unitsRepo!.getUnitCount();
      if (unitCount == 0) return 0.0;

      return await _bookingRepo!.getOccupancyRate(start, end, unitCount);
    } catch (e) {
      debugPrint('❌ AnalyticsService.getOccupancyRate error: $e');
      rethrow;
    }
  }

  /// Get monthly occupancy rates
  Future<List<ChartDataPoint>> getMonthlyOccupancy(int year) async {
    _ensureInitialized();

    try {
      final unitCount = await _unitsRepo!.getUnitCount();
      if (unitCount == 0) {
        return List.generate(
            12,
            (i) => ChartDataPoint(
                  label: _getMonthName(i + 1),
                  value: 0,
                ));
      }

      final List<ChartDataPoint> results = [];

      for (int month = 1; month <= 12; month++) {
        final start = DateTime(year, month, 1);
        final end = DateTime(year, month + 1, 1);

        final rate =
            await _bookingRepo!.getOccupancyRate(start, end, unitCount);
        results.add(ChartDataPoint(
          label: _getMonthName(month),
          value: rate,
        ));
      }

      return results;
    } catch (e) {
      debugPrint('❌ AnalyticsService.getMonthlyOccupancy error: $e');
      rethrow;
    }
  }

  // =====================================================
  // GUEST ANALYTICS
  // =====================================================

  /// Get guest statistics
  Future<GuestAnalytics> getGuestAnalytics({DateTime? since}) async {
    _ensureInitialized();

    try {
      final stats = await _bookingRepo!.getStats(since: since);

      // Get nationality distribution (requires aggregation)
      final nationalities = await _getNationalityDistribution(since: since);

      return GuestAnalytics(
        totalGuests: stats.totalGuests,
        averageGroupSize: stats.totalBookings > 0
            ? stats.totalGuests / stats.totalBookings
            : 0,
        nationalityDistribution: nationalities,
      );
    } catch (e) {
      debugPrint('❌ AnalyticsService.getGuestAnalytics error: $e');
      rethrow;
    }
  }

  Future<Map<String, int>> _getNationalityDistribution(
      {DateTime? since}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('bookings')
          .where('ownerId', isEqualTo: _ownerId);

      if (since != null) {
        query = query.where('checkIn',
            isGreaterThanOrEqualTo: Timestamp.fromDate(since));
      }

      final snapshot = await query.get();
      final Map<String, int> distribution = {};

      for (final doc in snapshot.docs) {
        // Get guests subcollection
        final guestsSnapshot = await doc.reference.collection('guests').get();
        for (final guestDoc in guestsSnapshot.docs) {
          final nationality = guestDoc.data()['nationality'] as String?;
          if (nationality != null && nationality.isNotEmpty) {
            distribution[nationality] = (distribution[nationality] ?? 0) + 1;
          }
        }
      }

      return distribution;
    } catch (e) {
      debugPrint('❌ getNationalityDistribution error: $e');
      return {};
    }
  }

  // =====================================================
  // UNIT ANALYTICS
  // =====================================================

  /// Get unit performance
  Future<List<UnitPerformance>> getUnitPerformance({DateTime? since}) async {
    _ensureInitialized();

    try {
      final units = await _unitsRepo!.getOwnerUnits();
      final List<UnitPerformance> performance = [];

      for (final unit in units) {
        final bookings = await _bookingRepo!.getByUnit(unit.id);

        // Filter by date if needed
        final filteredBookings = since != null
            ? bookings.where((b) => b.checkIn.isAfter(since)).toList()
            : bookings;

        final totalNights =
            filteredBookings.fold<int>(0, (acc, b) => acc + b.stayLength);
        final totalGuests =
            filteredBookings.fold<int>(0, (acc, b) => acc + b.guestCount);

        performance.add(UnitPerformance(
          unitId: unit.id,
          unitName: unit.name,
          totalBookings: filteredBookings.length,
          totalNights: totalNights,
          totalGuests: totalGuests,
          averageStay: filteredBookings.isNotEmpty
              ? totalNights / filteredBookings.length
              : 0,
        ));
      }

      // Sort by bookings descending
      performance.sort((a, b) => b.totalBookings.compareTo(a.totalBookings));

      return performance;
    } catch (e) {
      debugPrint('❌ AnalyticsService.getUnitPerformance error: $e');
      rethrow;
    }
  }

  // =====================================================
  // EXPORT
  // =====================================================

  /// Export analytics as CSV
  Future<String> exportToCsv({
    required DateTime start,
    required DateTime end,
  }) async {
    _ensureInitialized();

    try {
      final bookings = await _bookingRepo!.getByDateRange(start, end);

      final buffer = StringBuffer();
      buffer.writeln(
          'Booking ID,Unit,Guest Name,Check-In,Check-Out,Guests,Status');

      for (final booking in bookings) {
        buffer.writeln('${booking.id},'
            '${booking.unitName},'
            '${booking.guestName},'
            '${booking.checkIn.toIso8601String().split('T')[0]},'
            '${booking.checkOut.toIso8601String().split('T')[0]},'
            '${booking.guestCount},'
            '${booking.status}');
      }

      return buffer.toString();
    } catch (e) {
      debugPrint('❌ AnalyticsService.exportToCsv error: $e');
      rethrow;
    }
  }
}

// =====================================================
// DATA MODELS
// =====================================================

class DashboardData {
  // Overview
  final int totalBookingsThisMonth;
  final int totalGuestsThisMonth;
  final int totalBookingsThisYear;
  final int totalGuestsThisYear;

  // Units
  final int totalUnits;
  final int activeUnits;
  final int totalCapacity;

  // Today
  final int todayCheckIns;
  final int todayCheckOuts;

  // Trends
  final double bookingTrend;
  final double guestTrend;

  // Performance
  final double averageStayLength;
  final double completionRate;
  final double cancellationRate;

  // Lists
  final List<Booking> upcomingBookings;
  final List<Booking> todayCheckInsList;
  final List<Booking> todayCheckOutsList;

  // Charts
  final Map<String, int> monthlyBookings;

  DashboardData({
    required this.totalBookingsThisMonth,
    required this.totalGuestsThisMonth,
    required this.totalBookingsThisYear,
    required this.totalGuestsThisYear,
    required this.totalUnits,
    required this.activeUnits,
    required this.totalCapacity,
    required this.todayCheckIns,
    required this.todayCheckOuts,
    required this.bookingTrend,
    required this.guestTrend,
    required this.averageStayLength,
    required this.completionRate,
    required this.cancellationRate,
    required this.upcomingBookings,
    required this.todayCheckInsList,
    required this.todayCheckOutsList,
    required this.monthlyBookings,
  });
}

class ChartDataPoint {
  final String label;
  final double value;

  ChartDataPoint({required this.label, required this.value});
}

class GuestAnalytics {
  final int totalGuests;
  final double averageGroupSize;
  final Map<String, int> nationalityDistribution;

  GuestAnalytics({
    required this.totalGuests,
    required this.averageGroupSize,
    required this.nationalityDistribution,
  });
}

class UnitPerformance {
  final String unitId;
  final String unitName;
  final int totalBookings;
  final int totalNights;
  final int totalGuests;
  final double averageStay;

  UnitPerformance({
    required this.unitId,
    required this.unitName,
    required this.totalBookings,
    required this.totalNights,
    required this.totalGuests,
    required this.averageStay,
  });
}

enum TrendPeriod {
  daily,
  weekly,
  monthly,
  yearly,
}
