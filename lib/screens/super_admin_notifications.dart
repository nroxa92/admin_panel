// FILE: lib/screens/super_admin_notifications.dart
// VERSION: 2.0 - Enhanced Notifications with Brand Support
// DATE: 2026-01-10

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SUPER ADMIN NOTIFICATIONS TAB
// ═══════════════════════════════════════════════════════════════════════════

class SuperAdminNotificationsTab extends StatefulWidget {
  final String? brandFilter;

  const SuperAdminNotificationsTab({super.key, this.brandFilter});

  @override
  State<SuperAdminNotificationsTab> createState() =>
      _SuperAdminNotificationsTabState();
}

class _SuperAdminNotificationsTabState
    extends State<SuperAdminNotificationsTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west3');

  // Data
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _owners = [];
  bool _isLoading = true;

  // New notification form
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedType = 'info';
  List<String> _selectedRecipients = [];
  bool _sendToAll = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DATA LOADING
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _loadNotifications(),
        _loadOwners(),
      ]);

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('❌ Error loading notifications: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadNotifications() async {
    Query query = _firestore
        .collection('system_notifications')
        .orderBy('createdAt', descending: true)
        .limit(50);

    final snapshot = await query.get();

    _notifications = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  Future<void> _loadOwners() async {
    Query query = _firestore.collection('tenant_links');

    if (widget.brandFilter != null) {
      query = query.where('brandId', isEqualTo: widget.brandFilter);
    }

    final snapshot = await query.get();

    _owners = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'tenantId': doc.id,
        'email': data['email'] ?? '',
        'displayName': data['displayName'] ?? doc.id,
        'brandId': data['brandId'] ?? 'vesta-lumina',
      };
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATION ACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _sendNotification() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title and message are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final callable = _functions.httpsCallable('sendSystemNotification');
      await callable.call({
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'type': _selectedType,
        'sendToAll': _sendToAll,
        'recipients': _sendToAll ? [] : _selectedRecipients,
        'brandId': widget.brandFilter,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification sent!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _titleController.clear();
        _messageController.clear();
        setState(() {
          _selectedType = 'info';
          _sendToAll = true;
          _selectedRecipients = [];
        });

        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteNotification(String id) async {
    try {
      await _firestore.collection('system_notifications').doc(id).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD UI
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.notifications_active,
                  color: Color(0xFFD4AF37), size: 28),
              const SizedBox(width: 12),
              const Text(
                'System Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // New Notification Form
          _buildNewNotificationForm(),
          const SizedBox(height: 32),

          // Past Notifications
          const Text(
            'Sent Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _notifications.isEmpty
              ? _emptyState()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _notifications.length,
                  itemBuilder: (ctx, i) => _notificationCard(_notifications[i]),
                ),
        ],
      ),
    );
  }

  Widget _buildNewNotificationForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.create, color: Color(0xFFD4AF37), size: 20),
              SizedBox(width: 8),
              Text(
                'New Notification',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Title
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Title *', Icons.title),
          ),
          const SizedBox(height: 16),

          // Message
          TextField(
            controller: _messageController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: _inputDecoration('Message *', Icons.message),
          ),
          const SizedBox(height: 16),

          // Type selector
          Row(
            children: [
              const Text('Type: ', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 12),
              _typeChip('info', Icons.info, Colors.blue),
              const SizedBox(width: 8),
              _typeChip('warning', Icons.warning, Colors.orange),
              const SizedBox(width: 8),
              _typeChip('success', Icons.check_circle, Colors.green),
              const SizedBox(width: 8),
              _typeChip('error', Icons.error, Colors.red),
            ],
          ),
          const SizedBox(height: 16),

          // Recipients
          Row(
            children: [
              const Text('Recipients: ', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 12),
              FilterChip(
                label: const Text('All Owners'),
                selected: _sendToAll,
                onSelected: (v) => setState(() => _sendToAll = v),
                selectedColor: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                checkmarkColor: const Color(0xFFD4AF37),
                labelStyle: TextStyle(
                  color: _sendToAll ? const Color(0xFFD4AF37) : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Select Specific'),
                selected: !_sendToAll,
                onSelected: (v) => setState(() => _sendToAll = !v),
                selectedColor: Colors.blue.withValues(alpha: 0.3),
                checkmarkColor: Colors.blue,
                labelStyle: TextStyle(
                  color: !_sendToAll ? Colors.blue : Colors.grey,
                ),
              ),
            ],
          ),

          // Specific recipients (if not sending to all)
          if (!_sendToAll) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(maxHeight: 150),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _owners.length,
                itemBuilder: (ctx, i) {
                  final owner = _owners[i];
                  final isSelected =
                      _selectedRecipients.contains(owner['tenantId']);
                  return CheckboxListTile(
                    dense: true,
                    title: Text(
                      owner['displayName'],
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    subtitle: Text(
                      owner['email'],
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    value: isSelected,
                    activeColor: const Color(0xFFD4AF37),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _selectedRecipients.add(owner['tenantId']);
                        } else {
                          _selectedRecipients.remove(owner['tenantId']);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_selectedRecipients.length} selected',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
          const SizedBox(height: 20),

          // Send button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sendNotification,
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Send Notification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeChip(String type, IconData icon, Color color) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? color : Colors.grey),
            const SizedBox(width: 4),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _notificationCard(Map<String, dynamic> notification) {
    final type = notification['type'] ?? 'info';
    final color = _getTypeColor(type);
    final icon = _getTypeIcon(type);
    final timestamp = notification['createdAt'] as Timestamp?;
    final timeStr = timestamp != null
        ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year} ${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
        : 'Unknown';
    final recipientCount = notification['recipientCount'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification['title'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      timeStr,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification['message'] ?? '',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.people, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '$recipientCount recipients',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
            onPressed: () => _deleteNotification(notification['id']),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'warning':
        return Colors.orange;
      case 'success':
        return Colors.green;
      case 'error':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'warning':
        return Icons.warning;
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off,
              size: 64, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text('No notifications sent yet',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
