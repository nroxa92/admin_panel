// FILE: lib/widgets/system_notification_banner.dart
// OPIS: Banner + Popup za sistemske obavijesti kod ownera
// KORIŠTENJE: Dodaj na vrh svake stranice u owner dashboardu

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Widget koji prikazuje aktivne sistemske obavijesti
///
/// Korištenje u main.dart ili bilo kojoj stranici:
/// ```dart
/// Column(
///   children: [
///     const SystemNotificationBanner(), // <-- Dodaj na vrh
///     Expanded(child: YourContent()),
///   ],
/// )
/// ```
class SystemNotificationBanner extends StatefulWidget {
  final String ownerLanguage;

  const SystemNotificationBanner({
    super.key,
    this.ownerLanguage = 'en',
  });

  @override
  State<SystemNotificationBanner> createState() =>
      _SystemNotificationBannerState();
}

class _SystemNotificationBannerState extends State<SystemNotificationBanner> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _ownerId;

  static const Map<String, Color> priorityColors = {
    'red': Colors.red,
    'yellow': Colors.amber,
    'green': Colors.green,
    'blue': Colors.blue,
  };

  static const Map<String, IconData> priorityIcons = {
    'red': Icons.error,
    'yellow': Icons.warning,
    'green': Icons.check_circle,
    'blue': Icons.info,
  };

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Dohvati owner ID iz custom claims
    final idToken = await user.getIdTokenResult();
    _ownerId = idToken.claims?['tenantId'] as String?;

    if (_ownerId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('system_notifications')
          .where('active', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final notifications = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final dismissedBy = List<String>.from(data['dismissedBy'] ?? []);

        // Prikaži samo one koje owner nije dismissao
        if (!dismissedBy.contains(_ownerId)) {
          notifications.add({
            'id': doc.id,
            ...data,
          });
        }
      }

      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });

        // Prikaži popup za prvu (najnoviju) notifikaciju
        if (notifications.isNotEmpty) {
          _showPopupDialog(notifications.first);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _dismissNotification(String notificationId) async {
    if (_ownerId == null) return;

    try {
      await _firestore
          .collection('system_notifications')
          .doc(notificationId)
          .update({
        'dismissedBy': FieldValue.arrayUnion([_ownerId]),
      });

      setState(() {
        _notifications.removeWhere((n) => n['id'] == notificationId);
      });
    } catch (e) {
      debugPrint('Error dismissing notification: $e');
    }
  }

  void _showPopupDialog(Map<String, dynamic> notification) {
    final priority = notification['priority'] as String? ?? 'blue';
    final color = priorityColors[priority] ?? Colors.blue;
    final icon = priorityIcons[priority] ?? Icons.info;

    // Dohvati prijevod za owner-ov jezik
    final translations =
        notification['translations'] as Map<String, dynamic>? ?? {};
    final message =
        translations[widget.ownerLanguage] ?? notification['message'] ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color, width: 2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('System Notification',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text(
                    priority.toUpperCase(),
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Text(
            message,
            style:
                const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _dismissNotification(notification['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('GOT IT'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: _notifications.map((n) {
        final priority = n['priority'] as String? ?? 'blue';
        final color = priorityColors[priority] ?? Colors.blue;
        final icon = priorityIcons[priority] ?? Icons.info;

        final translations = n['translations'] as Map<String, dynamic>? ?? {};
        final message =
            translations[widget.ownerLanguage] ?? n['message'] ?? '';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            border:
                Border(bottom: BorderSide(color: color.withValues(alpha: 0.3))),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: color, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _dismissNotification(n['id']),
                icon: Icon(Icons.close, color: color, size: 18),
                tooltip: 'Dismiss',
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// =============================================================================
// PRIMJER KORIŠTENJA U MAIN LAYOUT
// =============================================================================
/*

U lib/main.dart, u MainLayout widgetu:

class MainLayout extends StatelessWidget {
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 👇 DODAJ OVO
          Consumer<AppProvider>(
            builder: (context, provider, _) => SystemNotificationBanner(
              ownerLanguage: provider.settings?.appLanguage ?? 'en',
            ),
          ),
          // 👇 EXISTING CONTENT
          Expanded(child: child),
        ],
      ),
      drawer: NavDrawer(),
    );
  }
}

*/
