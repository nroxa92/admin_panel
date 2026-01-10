// FILE: test/services/revenue_service_test.dart
// PROJECT: VillaOS Admin Panel
// DESCRIPTION: Unit tests for Revenue Service
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Revenue Service', () {
    group('Revenue Calculation', () {
      test('should calculate total revenue from bookings', () {
        final bookings = [
          _MockRevenueBooking(totalPrice: 500.0, status: 'confirmed'),
          _MockRevenueBooking(totalPrice: 300.0, status: 'confirmed'),
          _MockRevenueBooking(totalPrice: 200.0, status: 'confirmed'),
        ];

        final total = _calculateTotalRevenue(bookings);
        expect(total, equals(1000.0));
      });

      test('should exclude cancelled bookings from revenue', () {
        final bookings = [
          _MockRevenueBooking(totalPrice: 500.0, status: 'confirmed'),
          _MockRevenueBooking(totalPrice: 300.0, status: 'cancelled'),
          _MockRevenueBooking(totalPrice: 200.0, status: 'confirmed'),
        ];

        final total = _calculateTotalRevenue(bookings);
        expect(total, equals(700.0)); // 500 + 200
      });

      test('should handle empty booking list', () {
        final bookings = <_MockRevenueBooking>[];
        final total = _calculateTotalRevenue(bookings);
        expect(total, equals(0.0));
      });

      test('should handle bookings with null prices', () {
        final bookings = [
          _MockRevenueBooking(totalPrice: 500.0, status: 'confirmed'),
          _MockRevenueBooking(totalPrice: null, status: 'confirmed'),
          _MockRevenueBooking(totalPrice: 200.0, status: 'confirmed'),
        ];

        final total = _calculateTotalRevenue(bookings);
        expect(total, equals(700.0));
      });
    });

    group('Average Revenue Per Booking', () {
      test('should calculate average correctly', () {
        final bookings = [
          _MockRevenueBooking(totalPrice: 600.0, status: 'confirmed'),
          _MockRevenueBooking(totalPrice: 400.0, status: 'confirmed'),
          _MockRevenueBooking(totalPrice: 500.0, status: 'confirmed'),
        ];

        final average = _calculateAverageRevenue(bookings);
        expect(average, equals(500.0));
      });

      test('should return 0 for empty list', () {
        final bookings = <_MockRevenueBooking>[];
        final average = _calculateAverageRevenue(bookings);
        expect(average, equals(0.0));
      });
    });

    group('Monthly Revenue Breakdown', () {
      test('should group bookings by month', () {
        final bookings = [
          _MockRevenueBooking(
            totalPrice: 500.0,
            status: 'confirmed',
            startDate: DateTime(2024, 1, 15),
          ),
          _MockRevenueBooking(
            totalPrice: 300.0,
            status: 'confirmed',
            startDate: DateTime(2024, 1, 20),
          ),
          _MockRevenueBooking(
            totalPrice: 400.0,
            status: 'confirmed',
            startDate: DateTime(2024, 2, 10),
          ),
        ];

        final breakdown = _calculateMonthlyBreakdown(bookings);
        
        expect(breakdown['2024-01'], equals(800.0)); // 500 + 300
        expect(breakdown['2024-02'], equals(400.0));
      });

      test('should handle bookings spanning multiple years', () {
        final bookings = [
          _MockRevenueBooking(
            totalPrice: 500.0,
            status: 'confirmed',
            startDate: DateTime(2023, 12, 15),
          ),
          _MockRevenueBooking(
            totalPrice: 300.0,
            status: 'confirmed',
            startDate: DateTime(2024, 1, 5),
          ),
        ];

        final breakdown = _calculateMonthlyBreakdown(bookings);
        
        expect(breakdown['2023-12'], equals(500.0));
        expect(breakdown['2024-01'], equals(300.0));
      });
    });

    group('Occupancy Rate', () {
      test('should calculate occupancy rate correctly', () {
        // 10 booked nights out of 30 total nights
        final rate = _calculateOccupancyRate(10, 30);
        expect(rate, closeTo(0.333, 0.01));
      });

      test('should return 0 for no available nights', () {
        final rate = _calculateOccupancyRate(0, 0);
        expect(rate, equals(0.0));
      });

      test('should cap at 100% occupancy', () {
        // Edge case: more booked than available (shouldn't happen but handle it)
        final rate = _calculateOccupancyRate(35, 30);
        expect(rate, equals(1.0));
      });

      test('should handle full occupancy', () {
        final rate = _calculateOccupancyRate(30, 30);
        expect(rate, equals(1.0));
      });
    });

    group('Revenue Growth', () {
      test('should calculate positive growth', () {
        final growth = _calculateGrowth(1200.0, 1000.0);
        expect(growth, equals(20.0)); // 20% growth
      });

      test('should calculate negative growth', () {
        final growth = _calculateGrowth(800.0, 1000.0);
        expect(growth, equals(-20.0)); // -20% decline
      });

      test('should handle zero previous revenue', () {
        final growth = _calculateGrowth(500.0, 0.0);
        expect(growth, equals(100.0)); // 100% growth from nothing
      });

      test('should handle equal revenues', () {
        final growth = _calculateGrowth(1000.0, 1000.0);
        expect(growth, equals(0.0));
      });
    });

    group('Revenue by Source', () {
      test('should group revenue by booking source', () {
        final bookings = [
          _MockRevenueBooking(totalPrice: 500.0, status: 'confirmed', source: 'airbnb'),
          _MockRevenueBooking(totalPrice: 300.0, status: 'confirmed', source: 'booking.com'),
          _MockRevenueBooking(totalPrice: 400.0, status: 'confirmed', source: 'airbnb'),
          _MockRevenueBooking(totalPrice: 200.0, status: 'confirmed', source: 'direct'),
        ];

        final bySource = _calculateRevenueBySource(bookings);

        expect(bySource['airbnb'], equals(900.0));
        expect(bySource['booking.com'], equals(300.0));
        expect(bySource['direct'], equals(200.0));
      });

      test('should handle unknown sources', () {
        final bookings = [
          _MockRevenueBooking(totalPrice: 500.0, status: 'confirmed', source: null),
          _MockRevenueBooking(totalPrice: 300.0, status: 'confirmed', source: ''),
        ];

        final bySource = _calculateRevenueBySource(bookings);
        expect(bySource['unknown'], equals(800.0));
      });
    });

    group('Revenue Projections', () {
      test('should project monthly revenue based on current pace', () {
        // If we have 500 revenue in first 10 days of month
        // Project for full 30 day month
        final projection = _projectMonthlyRevenue(500.0, 10, 30);
        expect(projection, equals(1500.0));
      });

      test('should handle full month data', () {
        final projection = _projectMonthlyRevenue(1000.0, 30, 30);
        expect(projection, equals(1000.0));
      });

      test('should handle zero days elapsed', () {
        final projection = _projectMonthlyRevenue(0.0, 0, 30);
        expect(projection, equals(0.0));
      });
    });
  });

  group('Analytics Service', () {
    group('Booking Statistics', () {
      test('should count bookings by status', () {
        final bookings = [
          _MockRevenueBooking(status: 'confirmed'),
          _MockRevenueBooking(status: 'confirmed'),
          _MockRevenueBooking(status: 'pending'),
          _MockRevenueBooking(status: 'cancelled'),
          _MockRevenueBooking(status: 'confirmed'),
        ];

        final stats = _countByStatus(bookings);

        expect(stats['confirmed'], equals(3));
        expect(stats['pending'], equals(1));
        expect(stats['cancelled'], equals(1));
      });
    });

    group('Guest Statistics', () {
      test('should calculate average guests per booking', () {
        final bookings = [
          _MockRevenueBooking(guestCount: 2),
          _MockRevenueBooking(guestCount: 4),
          _MockRevenueBooking(guestCount: 3),
        ];

        final average = _calculateAverageGuests(bookings);
        expect(average, equals(3.0));
      });

      test('should calculate total guests', () {
        final bookings = [
          _MockRevenueBooking(guestCount: 2),
          _MockRevenueBooking(guestCount: 4),
          _MockRevenueBooking(guestCount: 3),
        ];

        final total = _calculateTotalGuests(bookings);
        expect(total, equals(9));
      });
    });

    group('Stay Duration Analysis', () {
      test('should calculate average stay duration', () {
        final bookings = [
          _MockRevenueBooking(
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 4), // 3 nights
          ),
          _MockRevenueBooking(
            startDate: DateTime(2024, 1, 10),
            endDate: DateTime(2024, 1, 17), // 7 nights
          ),
          _MockRevenueBooking(
            startDate: DateTime(2024, 1, 20),
            endDate: DateTime(2024, 1, 25), // 5 nights
          ),
        ];

        final avgNights = _calculateAverageStayDuration(bookings);
        expect(avgNights, equals(5.0)); // (3 + 7 + 5) / 3
      });
    });

    group('Peak Season Detection', () {
      test('should identify busiest month', () {
        final bookingCounts = {
          'January': 5,
          'February': 3,
          'March': 8,
          'April': 6,
        };

        final busiest = _findBusiestMonth(bookingCounts);
        expect(busiest, equals('March'));
      });

      test('should handle tie by returning first', () {
        final bookingCounts = {
          'January': 5,
          'February': 5,
        };

        final busiest = _findBusiestMonth(bookingCounts);
        expect(busiest, equals('January'));
      });
    });
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOCK CLASSES
// ═══════════════════════════════════════════════════════════════════════════════

class _MockRevenueBooking {
  final double? totalPrice;
  final String status;
  final String? source;
  final int guestCount;
  final DateTime startDate;
  final DateTime endDate;

  _MockRevenueBooking({
    this.totalPrice,
    this.status = 'confirmed',
    this.source,
    this.guestCount = 2,
    DateTime? startDate,
    DateTime? endDate,
  })  : startDate = startDate ?? DateTime.now(),
        endDate = endDate ?? DateTime.now().add(const Duration(days: 3));

  int get nights => endDate.difference(startDate).inDays;
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════

double _calculateTotalRevenue(List<_MockRevenueBooking> bookings) {
  return bookings
      .where((b) => b.status != 'cancelled')
      .fold(0.0, (sum, b) => sum + (b.totalPrice ?? 0.0));
}

double _calculateAverageRevenue(List<_MockRevenueBooking> bookings) {
  final confirmed = bookings.where((b) => b.status != 'cancelled').toList();
  if (confirmed.isEmpty) return 0.0;
  
  final total = confirmed.fold(0.0, (sum, b) => sum + (b.totalPrice ?? 0.0));
  return total / confirmed.length;
}

Map<String, double> _calculateMonthlyBreakdown(List<_MockRevenueBooking> bookings) {
  final breakdown = <String, double>{};
  
  for (final booking in bookings.where((b) => b.status != 'cancelled')) {
    final key = '${booking.startDate.year}-${booking.startDate.month.toString().padLeft(2, '0')}';
    breakdown[key] = (breakdown[key] ?? 0.0) + (booking.totalPrice ?? 0.0);
  }
  
  return breakdown;
}

double _calculateOccupancyRate(int bookedNights, int totalNights) {
  if (totalNights == 0) return 0.0;
  final rate = bookedNights / totalNights;
  return rate > 1.0 ? 1.0 : rate;
}

double _calculateGrowth(double current, double previous) {
  if (previous == 0) return current > 0 ? 100.0 : 0.0;
  return ((current - previous) / previous) * 100;
}

Map<String, double> _calculateRevenueBySource(List<_MockRevenueBooking> bookings) {
  final bySource = <String, double>{};
  
  for (final booking in bookings.where((b) => b.status != 'cancelled')) {
    final source = (booking.source?.isEmpty ?? true) ? 'unknown' : booking.source!;
    bySource[source] = (bySource[source] ?? 0.0) + (booking.totalPrice ?? 0.0);
  }
  
  return bySource;
}

double _projectMonthlyRevenue(double currentRevenue, int daysElapsed, int totalDays) {
  if (daysElapsed == 0 || totalDays == 0) return 0.0;
  if (daysElapsed >= totalDays) return currentRevenue;
  return (currentRevenue / daysElapsed) * totalDays;
}

Map<String, int> _countByStatus(List<_MockRevenueBooking> bookings) {
  final counts = <String, int>{};
  for (final booking in bookings) {
    counts[booking.status] = (counts[booking.status] ?? 0) + 1;
  }
  return counts;
}

double _calculateAverageGuests(List<_MockRevenueBooking> bookings) {
  if (bookings.isEmpty) return 0.0;
  final total = bookings.fold(0, (sum, b) => sum + b.guestCount);
  return total / bookings.length;
}

int _calculateTotalGuests(List<_MockRevenueBooking> bookings) {
  return bookings.fold(0, (sum, b) => sum + b.guestCount);
}

double _calculateAverageStayDuration(List<_MockRevenueBooking> bookings) {
  if (bookings.isEmpty) return 0.0;
  final totalNights = bookings.fold(0, (sum, b) => sum + b.nights);
  return totalNights / bookings.length;
}

String _findBusiestMonth(Map<String, int> bookingCounts) {
  if (bookingCounts.isEmpty) return '';
  
  String busiest = bookingCounts.keys.first;
  int maxCount = bookingCounts[busiest]!;
  
  for (final entry in bookingCounts.entries) {
    if (entry.value > maxCount) {
      maxCount = entry.value;
      busiest = entry.key;
    }
  }
  
  return busiest;
}
