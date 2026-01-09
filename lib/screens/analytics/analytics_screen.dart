// FILE: lib/screens/analytics/analytics_screen.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 3.0.0 - Phase 3 Analytics Dashboard

import 'package:flutter/material.dart';
import '../../services/analytics_service.dart';
import '../../widgets/analytics/stat_card.dart';
import '../../widgets/analytics/booking_chart.dart';
import '../../widgets/analytics/occupancy_chart.dart';
import '../../widgets/analytics/upcoming_bookings_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  static const Color _primaryColor = Color(0xFFD4AF37);

  final AnalyticsService _analyticsService = AnalyticsService();

  bool _isLoading = true;
  String? _error;
  DashboardData? _data;
  List<ChartDataPoint>? _occupancyData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _analyticsService.initialize();

      final results = await Future.wait([
        _analyticsService.getDashboardData(),
        _analyticsService.getMonthlyOccupancy(DateTime.now().year),
      ]);

      setState(() {
        _data = results[0] as DashboardData;
        _occupancyData = results[1] as List<ChartDataPoint>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _primaryColor),
            SizedBox(height: 16),
            Text(
              'Loading analytics...',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Error loading analytics',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    if (_data == null) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: _primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildOverviewCards(),
            const SizedBox(height: 24),
            _buildTodaySection(),
            const SizedBox(height: 24),
            _buildChartsSection(),
            const SizedBox(height: 24),
            _buildPerformanceSection(),
            const SizedBox(height: 24),
            _buildUpcomingBookings(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Year ${DateTime.now().year} Overview',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, color: Colors.white54),
              tooltip: 'Refresh',
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _exportData,
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Export'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor.withValues(alpha: 0.2),
                foregroundColor: _primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          title: 'Bookings This Month',
          value: _data!.totalBookingsThisMonth.toString(),
          icon: Icons.calendar_month,
          trend: _data!.bookingTrend,
          color: _primaryColor,
        ),
        StatCard(
          title: 'Guests This Month',
          value: _data!.totalGuestsThisMonth.toString(),
          icon: Icons.people,
          trend: _data!.guestTrend,
          color: Colors.blue,
        ),
        StatCard(
          title: 'Total Units',
          value: '${_data!.activeUnits}/${_data!.totalUnits}',
          subtitle: 'Active',
          icon: Icons.home,
          color: Colors.green,
        ),
        StatCard(
          title: 'Total Capacity',
          value: _data!.totalCapacity.toString(),
          subtitle: 'Guests',
          icon: Icons.group,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildTodaySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.today, color: _primaryColor, size: 24),
              SizedBox(width: 12),
              Text(
                'Today',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTodayCard(
                  'Check-ins',
                  _data!.todayCheckIns,
                  Icons.login,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTodayCard(
                  'Check-outs',
                  _data!.todayCheckOuts,
                  Icons.logout,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard(String title, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    final bookingChartData = _data!.monthlyBookings.entries.map((e) {
      final monthNum = int.parse(e.key);
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
      return ChartDataPoint(
          label: months[monthNum - 1], value: e.value.toDouble());
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BookingChart(
            title: 'Monthly Bookings',
            data: bookingChartData,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OccupancyChart(
            title: 'Monthly Occupancy Rate',
            data: _occupancyData ?? [],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Metrics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Avg. Stay Length',
                  '${_data!.averageStayLength.toStringAsFixed(1)} nights',
                  Icons.nightlight,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Completion Rate',
                  '${_data!.completionRate.toStringAsFixed(1)}%',
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Cancellation Rate',
                  '${_data!.cancellationRate.toStringAsFixed(1)}%',
                  Icons.cancel,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Year Total',
                  '${_data!.totalBookingsThisYear} bookings',
                  Icons.calendar_today,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: _primaryColor, size: 32),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUpcomingBookings() {
    return UpcomingBookingsCard(
      bookings: _data!.upcomingBookings,
    );
  }

  Future<void> _exportData() async {
    try {
      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);

      final csv = await _analyticsService.exportToCsv(
        start: startOfYear,
        end: now,
      );

      debugPrint('CSV Export:\n$csv');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export ready! Check console for CSV data.'),
            backgroundColor: Color(0xFFD4AF37),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
