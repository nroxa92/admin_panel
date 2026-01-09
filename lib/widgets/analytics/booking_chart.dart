// FILE: lib/widgets/analytics/booking_chart.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 3.0.0 - Phase 3 Analytics Dashboard

import 'package:flutter/material.dart';
import '../../services/analytics_service.dart';

class BookingChart extends StatelessWidget {
  final String title;
  final List<ChartDataPoint> data;

  const BookingChart({
    super.key,
    required this.title,
    required this.data,
  });

  static const Color _primaryColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final maxValue = data.isEmpty
        ? 1.0
        : data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final safeMax = maxValue == 0 ? 1.0 : maxValue;

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
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Total: ${data.fold<int>(0, (acc, e) => acc + e.value.toInt())}',
                  style: const TextStyle(
                    color: _primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.asMap().entries.map((entry) {
                final index = entry.key;
                final point = entry.value;
                final heightRatio = point.value / safeMax;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Value label
                        Text(
                          point.value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Bar
                        Tooltip(
                          message:
                              '${point.label}: ${point.value.toInt()} bookings',
                          child: AnimatedContainer(
                            duration:
                                Duration(milliseconds: 300 + (index * 50)),
                            curve: Curves.easeOutBack,
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
                        // Label
                        Text(
                          point.label,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
