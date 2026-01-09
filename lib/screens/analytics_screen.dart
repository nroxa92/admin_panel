// FILE: lib/screens/analytics_screen.dart
// STATUS: UPDATED - Added booking statistics + translations
// FEATURES: Monthly/Yearly bookings, Occupancy rate, Avg stay, Feedback, AI Questions

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

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
    final startOfYear = DateTime(now.year, 1, 1);

    // 1. BOOKINGS - All bookings for this owner
    final bookingsSnapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('ownerId', isEqualTo: tenantId)
        .get();

    final allBookings = bookingsSnapshot.docs;

    // Filter bookings this month
    final bookingsThisMonth = allBookings.where((doc) {
      final data = doc.data();
      final startDate = (data['startDate'] as Timestamp?)?.toDate();
      return startDate != null && startDate.isAfter(startOfMonth);
    }).length;

    // Filter bookings this year
    final bookingsThisYear = allBookings.where((doc) {
      final data = doc.data();
      final startDate = (data['startDate'] as Timestamp?)?.toDate();
      return startDate != null && startDate.isAfter(startOfYear);
    }).length;

    // 2. UNITS - Count for occupancy calculation
    final unitsSnapshot = await FirebaseFirestore.instance
        .collection('units')
        .where('ownerId', isEqualTo: tenantId)
        .get();

    final totalUnits = unitsSnapshot.docs.length;

    // 3. OCCUPANCY RATE (last 30 days)
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    int totalOccupiedNights = 0;
    int totalNights = 0;
    double avgStayNights = 0;

    if (allBookings.isNotEmpty) {
      for (var doc in allBookings) {
        final data = doc.data();
        final startDate = (data['startDate'] as Timestamp?)?.toDate();
        final endDate = (data['endDate'] as Timestamp?)?.toDate();

        if (startDate != null && endDate != null) {
          // Calculate nights for this booking
          final nights = endDate.difference(startDate).inDays;
          totalNights += nights;

          // Check if booking overlaps with last 30 days
          if (endDate.isAfter(thirtyDaysAgo) && startDate.isBefore(now)) {
            final overlapStart =
                startDate.isBefore(thirtyDaysAgo) ? thirtyDaysAgo : startDate;
            final overlapEnd = endDate.isAfter(now) ? now : endDate;
            totalOccupiedNights += overlapEnd.difference(overlapStart).inDays;
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
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<AppProvider>().translate;

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _fetchAnalyticsData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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

          return ListView(
            padding: const EdgeInsets.all(30),
            children: [
              // HEADER
              Text(t('analytics_title'),
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 5),
              Text(t('analytics_subtitle'),
                  style: Theme.of(context).textTheme.bodyMedium),
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
              const SizedBox(height: 20),

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
