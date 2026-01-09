// FILE: lib/widgets/analytics/upcoming_bookings_card.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 3.0.0 - Phase 3 Analytics Dashboard

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../repositories/booking_repository.dart';

class UpcomingBookingsCard extends StatelessWidget {
  final List<Booking> bookings;

  const UpcomingBookingsCard({
    super.key,
    required this.bookings,
  });

  static const Color _primaryColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
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
              const Row(
                children: [
                  Icon(Icons.upcoming, color: _primaryColor, size: 22),
                  SizedBox(width: 12),
                  Text(
                    'Upcoming Bookings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full bookings list
                },
                child: const Text(
                  'View All',
                  style: TextStyle(color: _primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (bookings.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_available,
                        color: Colors.white24, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'No upcoming bookings',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => Divider(
                color: Colors.white.withValues(alpha: 0.1),
                height: 1,
              ),
              itemBuilder: (context, index) {
                return _buildBookingItem(bookings[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBookingItem(Booking booking) {
    final daysUntil = booking.checkIn.difference(DateTime.now()).inDays;

    Color statusColor;
    String statusText;

    if (daysUntil == 0) {
      statusColor = Colors.green;
      statusText = 'Today';
    } else if (daysUntil == 1) {
      statusColor = Colors.orange;
      statusText = 'Tomorrow';
    } else if (daysUntil <= 7) {
      statusColor = Colors.blue;
      statusText = 'In $daysUntil days';
    } else {
      statusColor = Colors.grey;
      statusText = 'In $daysUntil days';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Date badge
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  booking.checkIn.day.toString(),
                  style: const TextStyle(
                    color: _primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(booking.checkIn).toUpperCase(),
                  style: TextStyle(
                    color: _primaryColor.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Booking info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.guestName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.home,
                        size: 12, color: Colors.white.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Text(
                      booking.unitName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.people,
                        size: 12, color: Colors.white.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Text(
                      '${booking.guestCount} guest${booking.guestCount > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Stay duration
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${booking.stayLength} night${booking.stayLength > 1 ? 's' : ''}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
