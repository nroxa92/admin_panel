// FILE: lib/screens/analytics_screen.dart
// STATUS: FIXED (Koristi Tenant ID iz Custom Claims)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  // 🆕 HELPER: Dohvaća Tenant ID iz Custom Claims
  Future<String?> _getTenantId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final tokenResult = await user.getIdTokenResult();
    return tokenResult.claims?['ownerId'] as String?;
  }

  Future<Map<String, dynamic>> _fetchAnalyticsData() async {
    final tenantId = await _getTenantId();
    if (tenantId == null) return {};

    // 1. FEEDBACK (Limitirano na zadnjih 50 da štedimo reads)
    final feedbackSnapshot = await FirebaseFirestore.instance
        .collection('feedback')
        .where('ownerId', isEqualTo: tenantId) // ✅ Tenant ID
        .orderBy('timestamp', descending: true)
        .limit(50) // OPTIMIZACIJA
        .get();

    final feedbackDocs = feedbackSnapshot.docs;

    // Izračun prosječne ocjene (na bazi zadnjih 50)
    double averageRating = 0.0;
    if (feedbackDocs.isNotEmpty) {
      final totalRating = feedbackDocs.fold<int>(0, (prevTotal, doc) {
        final data = doc.data();
        return prevTotal + (data['rating'] as int? ?? 0);
      });
      averageRating = totalRating / feedbackDocs.length;
    }

    // 2. AI PITANJA (Limitirano na zadnjih 100)
    final aiSnapshot = await FirebaseFirestore.instance
        .collection('ai_logs')
        .where('ownerId', isEqualTo: tenantId) // ✅ Tenant ID
        .orderBy('timestamp', descending: true)
        .limit(100) // OPTIMIZACIJA
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
      'total_feedback': feedbackDocs.length,
      'average_rating': averageRating,
      'feedback_docs': feedbackDocs,
      'top_questions': sortedQuestions.take(5).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _fetchAnalyticsData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading data: ${snapshot.error}"));
          }

          final stats = snapshot.data ?? {};
          final totalFeedback = stats['total_feedback'] as int? ?? 0;
          final averageRating = stats['average_rating'] as double? ?? 0.0;
          final feedbackDocs =
              stats['feedback_docs'] as List<QueryDocumentSnapshot>? ?? [];
          final topQuestions =
              stats['top_questions'] as List<MapEntry<String, int>>? ?? [];

          return ListView(
            padding: const EdgeInsets.all(30),
            children: [
              Text("Guest Insights",
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 5),
              Text("Overview of guest satisfaction (Last 50) and AI queries.",
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      "Recent Reviews",
                      totalFeedback.toString(),
                      Icons.rate_review,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      "Average Rating",
                      averageRating.toStringAsFixed(1),
                      Icons.star,
                      Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text("Top AI Questions (What guests are asking)",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 15),
              _buildTopQuestions(context, topQuestions),
              const SizedBox(height: 40),
              Text("Recent Feedback",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 15),
              _buildFeedbackTable(context, feedbackDocs),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color)),
              Text(title,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopQuestions(
      BuildContext context, List<MapEntry<String, int>> questions) {
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
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text("No AI questions logged yet.",
                  style: TextStyle(color: Colors.grey)),
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

  Widget _buildFeedbackTable(
      BuildContext context, List<QueryDocumentSnapshot> docs) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (docs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(30),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12)),
        child: const Text("No reviews yet."),
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
          columns: const [
            DataColumn(
                label: Text("DATE",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text("RATING",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text("COMMENT",
                    style: TextStyle(fontWeight: FontWeight.bold))),
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
