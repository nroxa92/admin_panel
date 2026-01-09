// FILE: lib/widgets/analytics/occupancy_chart.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 3.0.0 - Phase 3 Analytics Dashboard

import 'package:flutter/material.dart';
import '../../services/analytics_service.dart';

class OccupancyChart extends StatelessWidget {
  final String title;
  final List<ChartDataPoint> data;

  const OccupancyChart({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final avgOccupancy = data.isEmpty
        ? 0.0
        : data.map((e) => e.value).reduce((a, b) => a + b) / data.length;

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
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Avg: ${avgOccupancy.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.blue,
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
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: _LineChartPainter(data: data),
            ),
          ),
          const SizedBox(height: 12),
          // X-axis labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data.map((point) {
              return Expanded(
                child: Text(
                  point.label,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;

  _LineChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blue.withValues(alpha: 0.3),
          Colors.blue.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final dotPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    // Draw grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Calculate points
    final points = <Offset>[];
    final stepX = size.width / (data.length - 1).clamp(1, data.length);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height -
          (data[i].value / 100 * size.height).clamp(0, size.height);
      points.add(Offset(x, y));
    }

    // Draw filled area
    if (points.isNotEmpty) {
      final fillPath = Path();
      fillPath.moveTo(0, size.height);
      fillPath.lineTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      }

      fillPath.lineTo(size.width, size.height);
      fillPath.close();

      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw line
    if (points.length > 1) {
      final linePath = Path();
      linePath.moveTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }

      canvas.drawPath(linePath, paint);
    }

    // Draw dots and labels
    for (int i = 0; i < points.length; i++) {
      // Outer glow
      canvas.drawCircle(
        points[i],
        6,
        Paint()..color = Colors.blue.withValues(alpha: 0.3),
      );
      // Inner dot
      canvas.drawCircle(points[i], 4, dotPaint);
      canvas.drawCircle(
        points[i],
        2,
        Paint()..color = Colors.white,
      );

      // Value label
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${data[i].value.toStringAsFixed(0)}%',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final labelY = points[i].dy - 14;
      textPainter.paint(
        canvas,
        Offset(points[i].dx - textPainter.width / 2,
            labelY.clamp(0, size.height - 12)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
