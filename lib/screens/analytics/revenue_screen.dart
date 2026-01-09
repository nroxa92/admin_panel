// FILE: lib/screens/analytics/revenue_screen.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 4.0.0 - Phase 4 Revenue Analytics

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/revenue_service.dart';
import '../../widgets/analytics/stat_card.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  static const Color _primaryColor = Color(0xFFD4AF37);

  final RevenueService _revenueService = RevenueService();
  final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: '€', decimalDigits: 2);

  bool _isLoading = true;
  String? _error;
  RevenueDashboard? _dashboard;
  PricingAnalytics? _pricing;
  int _selectedYear = DateTime.now().year;

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
      await _revenueService.initialize();

      final results = await Future.wait([
        _revenueService.getDashboard(year: _selectedYear),
        _revenueService.getPricingAnalytics(year: _selectedYear),
      ]);

      setState(() {
        _dashboard = results[0] as RevenueDashboard;
        _pricing = results[1] as PricingAnalytics;
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
            Text('Loading revenue data...',
                style: TextStyle(color: Colors.white54)),
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
            Text(_error!, style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
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
            _buildRevenueChart(),
            const SizedBox(height: 24),
            _buildUnitPerformance(),
            const SizedBox(height: 24),
            _buildPricingAnalytics(),
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
              'Revenue Analytics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Financial overview for $_selectedYear',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
        Row(
          children: [
            // Year selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _primaryColor.withValues(alpha: 0.3)),
              ),
              child: DropdownButton<int>(
                value: _selectedYear,
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white),
                underline: const SizedBox(),
                items: List.generate(5, (i) {
                  final year = DateTime.now().year - i;
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
                }),
                onChanged: (year) {
                  if (year != null) {
                    setState(() => _selectedYear = year);
                    _loadData();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
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
          title: 'Total Revenue',
          value: _currencyFormat.format(_dashboard!.totalRevenue),
          icon: Icons.euro,
          color: _primaryColor,
        ),
        StatCard(
          title: 'This Month',
          value: _currencyFormat.format(_dashboard!.currentMonthRevenue),
          icon: Icons.calendar_today,
          trend: _dashboard!.revenueTrend,
          color: Colors.green,
        ),
        StatCard(
          title: 'Avg. Daily Rate',
          value: _currencyFormat.format(_dashboard!.averageDailyRate),
          icon: Icons.hotel,
          color: Colors.blue,
        ),
        StatCard(
          title: 'Total Nights',
          value: _dashboard!.totalNights.toString(),
          subtitle: '${_dashboard!.totalBookings} bookings',
          icon: Icons.nightlight,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildRevenueChart() {
    final months = [
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

    final maxRevenue = _dashboard!.monthlyRevenue.values
        .fold<double>(1, (max, val) => val > max ? val : max);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Revenue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Total: ${_currencyFormat.format(_dashboard!.totalRevenue)}',
                  style: const TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(12, (index) {
                final monthKey = (index + 1).toString().padLeft(2, '0');
                final revenue = _dashboard!.monthlyRevenue[monthKey] ?? 0;
                final heightRatio = revenue / maxRevenue;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          revenue > 0 ? _currencyFormat.format(revenue) : '-',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 9,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Tooltip(
                          message:
                              '${months[index]}: ${_currencyFormat.format(revenue)}',
                          child: AnimatedContainer(
                            duration:
                                Duration(milliseconds: 300 + (index * 50)),
                            height: (heightRatio * 150).clamp(4.0, 150.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  _primaryColor,
                                  _primaryColor.withValues(alpha: 0.6),
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          months[index],
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitPerformance() {
    if (_dashboard!.unitPerformance.isEmpty) {
      return const SizedBox.shrink();
    }

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
            'Unit Performance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...(_dashboard!.unitPerformance.take(5).map((unit) {
            final percentage = _dashboard!.totalRevenue > 0
                ? (unit.totalRevenue / _dashboard!.totalRevenue) * 100
                : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        unit.unitName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _currencyFormat.format(unit.totalRevenue),
                        style: const TextStyle(
                          color: _primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.white12,
                            valueColor:
                                const AlwaysStoppedAnimation(_primaryColor),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${unit.totalBookings} bookings · ${unit.totalNights} nights · ADR: ${_currencyFormat.format(unit.averageNightlyRate)}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            );
          })),
        ],
      ),
    );
  }

  Widget _buildPricingAnalytics() {
    if (_pricing == null || _pricing!.averageNightlyRate == 0) {
      return const SizedBox.shrink();
    }

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
            'Pricing Analytics',
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
                child: _buildPricingCard(
                  'Average Rate',
                  _currencyFormat.format(_pricing!.averageNightlyRate),
                  Icons.show_chart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPricingCard(
                  'Min Rate',
                  _currencyFormat.format(_pricing!.minNightlyRate),
                  Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPricingCard(
                  'Max Rate',
                  _currencyFormat.format(_pricing!.maxNightlyRate),
                  Icons.arrow_upward,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPricingCard(
                  'Median Rate',
                  _currencyFormat.format(_pricing!.medianNightlyRate),
                  Icons.horizontal_rule,
                ),
              ),
            ],
          ),
          if (_pricing!.seasonalRates.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Seasonal Rates',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: _pricing!.seasonalRates.entries.map((entry) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.value > 0
                              ? _currencyFormat.format(entry.value)
                              : '-',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: _primaryColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    try {
      final startOfYear = DateTime(_selectedYear, 1, 1);
      final endOfYear = DateTime(_selectedYear + 1, 1, 1);

      final csv = await _revenueService.exportRevenueCsv(
        start: startOfYear,
        end: endOfYear,
      );

      debugPrint('Revenue CSV Export:\n$csv');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export ready! Check console for CSV data.'),
            backgroundColor: _primaryColor,
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
