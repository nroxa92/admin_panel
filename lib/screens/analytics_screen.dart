// FILE: lib/screens/analytics_screen.dart
// STATUS: PHASE 4 COMPLETE - Revenue Analytics + Calendar Export
// FEATURES: Booking stats, Occupancy, Revenue, Calendar Export, Feedback, AI Questions

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/calendar_service.dart';
import '../repositories/booking_repository.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final CalendarService _calendarService = CalendarService();
  final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: '€', decimalDigits: 0);

  bool _isExporting = false;
  int _selectedYear = DateTime.now().year;

  Future<String?> _getTenantId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final tokenResult = await user.getIdTokenResult();
    return tokenResult.claims?['ownerId'] as String?;
  }

  Future<Map<String, dynamic>> _fetchAnalyticsData() async {
    final tenantId = await _getTenantId();
    if (tenantId == null) return {};

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfYear = DateTime(_selectedYear, 1, 1);
    final endOfYear = DateTime(_selectedYear + 1, 1, 1);

    // 1. BOOKINGS - All bookings for this owner
    final bookingsSnapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('ownerId', isEqualTo: tenantId)
        .get();

    final allBookings = bookingsSnapshot.docs;

    // Filter bookings this month
    final bookingsThisMonth = allBookings.where((doc) {
      final data = doc.data();
      final checkIn = (data['checkIn'] as Timestamp?)?.toDate();
      return checkIn != null && checkIn.isAfter(startOfMonth);
    }).length;

    // Filter bookings this year
    final bookingsThisYear = allBookings.where((doc) {
      final data = doc.data();
      final checkIn = (data['checkIn'] as Timestamp?)?.toDate();
      return checkIn != null &&
          checkIn.isAfter(startOfYear) &&
          checkIn.isBefore(endOfYear);
    }).length;

    // 2. UNITS - Count for occupancy calculation
    final unitsSnapshot = await FirebaseFirestore.instance
        .collection('units')
        .where('ownerId', isEqualTo: tenantId)
        .get();

    final totalUnits = unitsSnapshot.docs.length;

    // 3. OCCUPANCY RATE & REVENUE (last 30 days / this year)
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    int totalOccupiedNights = 0;
    int totalNights = 0;
    double avgStayNights = 0;

    // Revenue calculation
    double totalRevenue = 0;
    double revenueThisMonth = 0;
    Map<String, double> monthlyRevenue = {};

    // Initialize monthly revenue
    for (int i = 1; i <= 12; i++) {
      monthlyRevenue[i.toString().padLeft(2, '0')] = 0;
    }

    if (allBookings.isNotEmpty) {
      for (var doc in allBookings) {
        final data = doc.data();
        final checkIn = (data['checkIn'] as Timestamp?)?.toDate();
        final checkOut = (data['checkOut'] as Timestamp?)?.toDate();
        final price = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;

        if (checkIn != null && checkOut != null) {
          // Calculate nights for this booking
          final nights = checkOut.difference(checkIn).inDays;
          totalNights += nights;

          // Check if booking overlaps with last 30 days
          if (checkOut.isAfter(thirtyDaysAgo) && checkIn.isBefore(now)) {
            final overlapStart =
                checkIn.isBefore(thirtyDaysAgo) ? thirtyDaysAgo : checkIn;
            final overlapEnd = checkOut.isAfter(now) ? now : checkOut;
            totalOccupiedNights += overlapEnd.difference(overlapStart).inDays;
          }

          // Revenue calculation for selected year
          if (checkIn.year == _selectedYear) {
            totalRevenue += price;
            final month = checkIn.month.toString().padLeft(2, '0');
            monthlyRevenue[month] = (monthlyRevenue[month] ?? 0) + price;

            // This month revenue
            if (checkIn.month == now.month && checkIn.year == now.year) {
              revenueThisMonth += price;
            }
          }
        }
      }

      // Average stay calculation
      if (allBookings.isNotEmpty && totalNights > 0) {
        avgStayNights = totalNights / allBookings.length;
      }
    }

    // Occupancy rate = occupied nights / (units * 30 days) * 100
    double occupancyRate = 0;
    if (totalUnits > 0) {
      occupancyRate = (totalOccupiedNights / (totalUnits * 30)) * 100;
      if (occupancyRate > 100) occupancyRate = 100;
    }

    // ADR (Average Daily Rate)
    double adr = totalNights > 0 ? totalRevenue / totalNights : 0;

    // 4. FEEDBACK (Last 50)
    final feedbackSnapshot = await FirebaseFirestore.instance
        .collection('feedback')
        .where('ownerId', isEqualTo: tenantId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();

    final feedbackDocs = feedbackSnapshot.docs;

    double averageRating = 0.0;
    if (feedbackDocs.isNotEmpty) {
      final totalRating = feedbackDocs.fold<int>(0, (prevTotal, doc) {
        final data = doc.data();
        return prevTotal + (data['rating'] as int? ?? 0);
      });
      averageRating = totalRating / feedbackDocs.length;
    }

    // 5. AI QUESTIONS (Last 100)
    final aiSnapshot = await FirebaseFirestore.instance
        .collection('ai_logs')
        .where('ownerId', isEqualTo: tenantId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .get();

    Map<String, int> topQuestions = {};
    for (var doc in aiSnapshot.docs) {
      final q = doc.data()['question'] as String? ?? 'N/A';
      final cleanQ = q.trim();
      topQuestions[cleanQ] = (topQuestions[cleanQ] ?? 0) + 1;
    }

    final sortedQuestions = topQuestions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'bookings_this_month': bookingsThisMonth,
      'bookings_this_year': bookingsThisYear,
      'occupancy_rate': occupancyRate,
      'avg_stay_nights': avgStayNights,
      'total_feedback': feedbackDocs.length,
      'average_rating': averageRating,
      'feedback_docs': feedbackDocs,
      'top_questions': sortedQuestions.take(5).toList(),
      // Revenue data
      'total_revenue': totalRevenue,
      'revenue_this_month': revenueThisMonth,
      'monthly_revenue': monthlyRevenue,
      'adr': adr,
      'total_units': totalUnits,
      'total_nights': totalNights,
      // For calendar export
      'all_bookings': allBookings,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<AppProvider>().translate;
    final provider = context.watch<AppProvider>();
    final primaryColor = provider.primaryColor;

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _fetchAnalyticsData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: primaryColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final stats = snapshot.data ?? {};
          final bookingsThisMonth = stats['bookings_this_month'] as int? ?? 0;
          final bookingsThisYear = stats['bookings_this_year'] as int? ?? 0;
          final occupancyRate = stats['occupancy_rate'] as double? ?? 0.0;
          final avgStayNights = stats['avg_stay_nights'] as double? ?? 0.0;
          final totalFeedback = stats['total_feedback'] as int? ?? 0;
          final averageRating = stats['average_rating'] as double? ?? 0.0;
          final feedbackDocs =
              stats['feedback_docs'] as List<QueryDocumentSnapshot>? ?? [];
          final topQuestions =
              stats['top_questions'] as List<MapEntry<String, int>>? ?? [];

          // Revenue data
          final totalRevenue = stats['total_revenue'] as double? ?? 0.0;
          final revenueThisMonth =
              stats['revenue_this_month'] as double? ?? 0.0;
          final monthlyRevenue =
              stats['monthly_revenue'] as Map<String, double>? ?? {};
          final adr = stats['adr'] as double? ?? 0.0;
          final totalNightsSold = stats['total_nights'] as int? ?? 0;
          final allBookings =
              stats['all_bookings'] as List<QueryDocumentSnapshot>? ?? [];

          return ListView(
            padding: const EdgeInsets.all(30),
            children: [
              // HEADER WITH YEAR SELECTOR
              _buildHeader(context, t, primaryColor),
              const SizedBox(height: 30),

              // ROW 1: BOOKING STATS
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      t('bookings_this_month'),
                      bookingsThisMonth.toString(),
                      Icons.calendar_month,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      t('bookings_this_year'),
                      bookingsThisYear.toString(),
                      Icons.calendar_today,
                      Colors.indigo,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ROW 2: OCCUPANCY & AVG STAY
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      t('occupancy_rate'),
                      "${occupancyRate.toStringAsFixed(1)}%",
                      Icons.hotel,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      t('avg_stay_nights'),
                      "${avgStayNights.toStringAsFixed(1)} ${t('nights')}",
                      Icons.nights_stay,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // ==================== REVENUE SECTION ====================
              _buildSectionHeader(
                  context, t('revenue_section'), Icons.euro, primaryColor),
              const SizedBox(height: 20),

              // REVENUE STATS ROW
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      t('total_revenue'),
                      _currencyFormat.format(totalRevenue),
                      Icons.euro,
                      primaryColor,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      t('revenue_this_month'),
                      _currencyFormat.format(revenueThisMonth),
                      Icons.trending_up,
                      Colors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      t('average_daily_rate'),
                      _currencyFormat.format(adr),
                      Icons.price_check,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      t('total_nights_sold'),
                      totalNightsSold.toString(),
                      Icons.nightlight_round,
                      Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // MONTHLY REVENUE CHART
              _buildRevenueChart(context, monthlyRevenue, primaryColor, t),
              const SizedBox(height: 40),

              // ==================== CALENDAR EXPORT SECTION ====================
              _buildSectionHeader(context, t('calendar_export'),
                  Icons.calendar_month, primaryColor),
              const SizedBox(height: 20),
              _buildCalendarExportCard(context, allBookings, t, primaryColor),
              const SizedBox(height: 40),

              // ==================== FEEDBACK SECTION ====================
              // ROW 3: FEEDBACK STATS
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      t('recent_reviews'),
                      totalFeedback.toString(),
                      Icons.rate_review,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      t('average_rating'),
                      averageRating.toStringAsFixed(1),
                      Icons.star,
                      Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // TOP AI QUESTIONS
              Text(t('top_ai_questions'),
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 15),
              _buildTopQuestions(context, topQuestions, t),
              const SizedBox(height: 40),

              // RECENT FEEDBACK TABLE
              Text(t('recent_reviews'),
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 15),
              _buildFeedbackTable(context, feedbackDocs, t),
              const SizedBox(height: 50),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, String Function(String) t, Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('analytics_title'),
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 5),
            Text(t('analytics_subtitle'),
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        // Year selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
          ),
          child: DropdownButton<int>(
            value: _selectedYear,
            dropdownColor: Theme.of(context).cardColor,
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
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
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Text(title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
      ],
    );
  }

  Widget _buildRevenueChart(
      BuildContext context,
      Map<String, double> monthlyRevenue,
      Color primaryColor,
      String Function(String) t) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    final maxRevenue = monthlyRevenue.values
        .fold<double>(1, (max, val) => val > max ? val : max);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('monthly_revenue_chart'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(12, (index) {
                final monthKey = (index + 1).toString().padLeft(2, '0');
                final revenue = monthlyRevenue[monthKey] ?? 0;
                final heightRatio = maxRevenue > 0 ? revenue / maxRevenue : 0.0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (revenue > 0)
                          Text(
                            _currencyFormat.format(revenue),
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontSize: 8,
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
                            height: (heightRatio * 120.0)
                                .clamp(4.0, 120.0)
                                .toDouble(),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  primaryColor,
                                  primaryColor.withValues(alpha: 0.6),
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
                          months[index].substring(0, 1),
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 10,
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

  Widget _buildCalendarExportCard(
      BuildContext context,
      List<QueryDocumentSnapshot> bookings,
      String Function(String) t,
      Color primaryColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('export_bookings_calendar'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          const SizedBox(height: 8),
          Text(t('export_calendar_description'),
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 13,
              )),
          const SizedBox(height: 20),
          Row(
            children: [
              // iCal Export Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      _isExporting ? null : () => _exportICal(bookings, t),
                  icon: _isExporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.download),
                  label: Text(t('export_ical')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Google Calendar Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showCalendarOptions(bookings, t),
                  icon: const Icon(Icons.calendar_month),
                  label: Text(t('add_to_calendar')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportICal(List<QueryDocumentSnapshot> bookingDocs,
      String Function(String) t) async {
    setState(() => _isExporting = true);

    try {
      // Convert to Booking objects
      final bookings = bookingDocs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Booking(
          id: doc.id,
          ownerId: data['ownerId'] ?? '',
          unitId: data['unitId'] ?? '',
          unitName: data['unitName'] ?? '',
          guestName: data['guestName'] ?? '',
          guestEmail: data['guestEmail'],
          guestPhone: data['guestPhone'],
          checkIn: (data['checkIn'] as Timestamp).toDate(),
          checkOut: (data['checkOut'] as Timestamp).toDate(),
          guestCount: data['guestCount'] ?? 1,
          status: data['status'] ?? 'confirmed',
          notes: data['notes'],
        );
      }).toList();

      final icalContent = _calendarService.generateICal(
        bookings: bookings,
        calendarName: 'VLS Bookings $_selectedYear',
      );

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: icalContent));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('ical_copied_clipboard')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t('export_failed')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _showCalendarOptions(
      List<QueryDocumentSnapshot> bookingDocs, String Function(String) t) {
    final primaryColor = context.read<AppProvider>().primaryColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('choose_calendar_app'),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_month, color: Colors.blue),
              ),
              title: const Text('Google Calendar'),
              subtitle: Text(t('open_in_browser')),
              onTap: () {
                Navigator.pop(context);
                _openGoogleCalendarInstructions(t);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.mail, color: Colors.orange),
              ),
              title: const Text('Outlook'),
              subtitle: Text(t('open_in_browser')),
              onTap: () {
                Navigator.pop(context);
                _openOutlookInstructions(t);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.copy, color: primaryColor),
              ),
              title: Text(t('copy_ical_data')),
              subtitle: Text(t('paste_in_any_calendar')),
              onTap: () {
                Navigator.pop(context);
                _exportICal(bookingDocs, t);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _openGoogleCalendarInstructions(String Function(String) t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('google_calendar_instructions')),
        content: Text(t('google_calendar_steps')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('ok')),
          ),
        ],
      ),
    );
  }

  void _openOutlookInstructions(String Function(String) t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('outlook_instructions')),
        content: Text(t('outlook_steps')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('ok')),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                Text(title,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopQuestions(BuildContext context,
      List<MapEntry<String, int>> questions, String Function(String) t) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (questions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(t('no_ai_questions'),
                  style: const TextStyle(color: Colors.grey)),
            ),
          ...questions.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text("${entry.value}x",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor)),
                ),
                const SizedBox(width: 15),
                Expanded(
                    child: Text(entry.key,
                        style: const TextStyle(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
              ]))),
        ],
      ),
    );
  }

  Widget _buildFeedbackTable(BuildContext context,
      List<QueryDocumentSnapshot> docs, String Function(String) t) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (docs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(30),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12)),
        child: Text(t('no_reviews')),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
              Theme.of(context).primaryColor.withValues(alpha: 0.05)),
          columns: [
            DataColumn(
                label: Text(t('date_col'),
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text(t('rating_col'),
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text(t('comment_col'),
                    style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final Timestamp? ts = data['timestamp'];
            final String dateStr =
                ts != null ? DateFormat('dd.MM.yyyy').format(ts.toDate()) : "-";
            final rating = data['rating'] as int? ?? 0;
            final comment = data['comment'] as String? ?? '-';
            return DataRow(cells: [
              DataCell(Text(dateStr,
                  style: const TextStyle(fontFamily: 'monospace'))),
              DataCell(Row(
                  children: List.generate(
                      5,
                      (index) => Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16)))),
              DataCell(Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Text(comment, overflow: TextOverflow.ellipsis))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
