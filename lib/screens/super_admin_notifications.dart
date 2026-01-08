// FILE: lib/screens/super_admin_notifications.dart
// VERSION: 3.1 - Fixed linter warnings

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

// =============================================================================
// ACTIVITY LOG TAB
// =============================================================================
class SuperAdminActivityTab extends StatefulWidget {
  const SuperAdminActivityTab({super.key});

  @override
  State<SuperAdminActivityTab> createState() => _SuperAdminActivityTabState();
}

class _SuperAdminActivityTabState extends State<SuperAdminActivityTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final snapshot = await _firestore
          .collection('admin_logs')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();
      _logs = snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _timeAgo(dynamic ts) {
    if (ts == null) return 'Unknown';
    if (ts is! Timestamp) return 'Unknown';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  IconData _actionIcon(String action) {
    switch (action) {
      case 'CREATE_OWNER':
        return Icons.person_add;
      case 'DELETE_OWNER':
        return Icons.person_remove;
      case 'SUSPEND_OWNER':
        return Icons.block;
      case 'ACTIVE_OWNER':
        return Icons.check_circle;
      case 'RESET_PASSWORD':
        return Icons.key;
      case 'PUSH_APK_UPDATE':
        return Icons.system_update;
      case 'CREATE_NOTIFICATION':
        return Icons.campaign;
      case 'DELETE_NOTIFICATION':
        return Icons.notifications_off;
      default:
        return Icons.info;
    }
  }

  Color _actionColor(String action) {
    switch (action) {
      case 'CREATE_OWNER':
        return Colors.green;
      case 'DELETE_OWNER':
        return Colors.red;
      case 'SUSPEND_OWNER':
        return Colors.orange;
      case 'ACTIVE_OWNER':
        return Colors.green;
      case 'RESET_PASSWORD':
        return Colors.blue;
      case 'PUSH_APK_UPDATE':
        return Colors.purple;
      case 'CREATE_NOTIFICATION':
        return Colors.teal;
      case 'DELETE_NOTIFICATION':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadLogs,
      color: const Color(0xFFD4AF37),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : _logs.isEmpty
              ? ListView(children: const [
                  SizedBox(height: 100),
                  Center(
                      child: Column(children: [
                    Icon(Icons.history, color: Colors.grey, size: 60),
                    SizedBox(height: 16),
                    Text('No activity logs yet',
                        style: TextStyle(color: Colors.grey)),
                  ])),
                ])
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _logs.length,
                  itemBuilder: (_, i) {
                    final log = _logs[i];
                    final action = log['action'] ?? 'Unknown';
                    final icon = _actionIcon(action);
                    final color = _actionColor(action);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8)),
                          child: Icon(icon, color: color, size: 18),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(action.replaceAll('_', ' '),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                                if ((log['targetId'] ?? '')
                                    .toString()
                                    .isNotEmpty)
                                  Text('Target: ${log['targetId']}',
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 11)),
                                if ((log['details'] ?? '')
                                    .toString()
                                    .isNotEmpty)
                                  Text(log['details'],
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 11)),
                              ]),
                        ),
                        Text(_timeAgo(log['timestamp']),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 10)),
                      ]),
                    );
                  },
                ),
    );
  }
}

// =============================================================================
// NOTIFICATIONS TAB
// =============================================================================
class SuperAdminNotificationsTab extends StatefulWidget {
  const SuperAdminNotificationsTab({super.key});

  @override
  State<SuperAdminNotificationsTab> createState() =>
      _SuperAdminNotificationsTabState();
}

class _SuperAdminNotificationsTabState
    extends State<SuperAdminNotificationsTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west3');

  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _owners = [];
  bool _isLoading = true;

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
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadNotifications(),
      _loadOwners(),
    ]);
  }

  Future<void> _loadOwners() async {
    try {
      final snapshot = await _firestore.collection('tenant_links').get();
      _owners = snapshot.docs.map((d) {
        final data = d.data();
        return <String, dynamic>{
          'tenantId': d.id,
          'email': data['email'] ?? '',
          'displayName': data['displayName'] ?? d.id,
          'status': data['status'] ?? 'pending',
        };
      }).toList();
      // Filter only active owners
      _owners = _owners.where((o) => o['status'] == 'active').toList();
    } catch (e) {
      debugPrint('Error loading owners: $e');
    }
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final snapshot = await _firestore
          .collection('system_notifications')
          .orderBy('createdAt', descending: true)
          .get();
      _notifications =
          snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showCreateDialog() async {
    final messageCtrl = TextEditingController();
    String selectedPriority = 'blue';
    String selectedLanguage = 'en';
    bool isTranslating = false;
    Map<String, String> translations = {};
    final Set<String> selectedOwners = {};
    bool sendToAll = true;

    const languages = [
      'en',
      'hr',
      'de',
      'it',
      'sk',
      'cz',
      'es',
      'fr',
      'pl',
      'hu',
      'sl'
    ];
    const languageNames = {
      'en': '🇬🇧 English',
      'hr': '🇭🇷 Hrvatski',
      'de': '🇩🇪 Deutsch',
      'it': '🇮🇹 Italiano',
      'sk': '🇸🇰 Slovenčina',
      'cz': '🇨🇿 Čeština',
      'es': '🇪🇸 Español',
      'fr': '🇫🇷 Français',
      'pl': '🇵🇱 Polski',
      'hu': '🇭🇺 Magyar',
      'sl': '🇸🇮 Slovenščina',
    };

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Row(children: [
            Icon(Icons.campaign, color: Color(0xFFD4AF37)),
            SizedBox(width: 10),
            Text('New Notification', style: TextStyle(color: Colors.white)),
          ]),
          content: SizedBox(
            width: 600,
            height: 600,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Priority selection
                  const Text('Priority Level',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: priorityColors.entries.map((e) {
                      final isSelected = selectedPriority == e.key;
                      return GestureDetector(
                        onTap: () =>
                            setDialogState(() => selectedPriority = e.key),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? e.value.withValues(alpha: 0.3)
                                : const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: isSelected
                                    ? e.value
                                    : Colors.grey.withValues(alpha: 0.3),
                                width: isSelected ? 2 : 1),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(priorityIcons[e.key],
                                color: e.value, size: 18),
                            const SizedBox(width: 6),
                            Text(e.key.toUpperCase(),
                                style: TextStyle(
                                    color: e.value,
                                    fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Target Owners Selection
                  const Text('Send To:',
                      style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Checkbox(
                      value: sendToAll,
                      onChanged: (v) => setDialogState(() {
                        sendToAll = v ?? true;
                        if (sendToAll) selectedOwners.clear();
                      }),
                      activeColor: const Color(0xFFD4AF37),
                    ),
                    const Text('All Owners',
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 20),
                    Checkbox(
                      value: !sendToAll,
                      onChanged: (v) =>
                          setDialogState(() => sendToAll = !(v ?? false)),
                      activeColor: const Color(0xFFD4AF37),
                    ),
                    const Text('Select Specific',
                        style: TextStyle(color: Colors.white)),
                  ]),

                  if (!sendToAll) ...[
                    const SizedBox(height: 8),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      child: _owners.isEmpty
                          ? const Center(
                              child: Text('No active owners',
                                  style: TextStyle(color: Colors.grey)))
                          : ListView(
                              padding: const EdgeInsets.all(8),
                              children: _owners.map((owner) {
                                final tid = owner['tenantId'] as String;
                                return CheckboxListTile(
                                  value: selectedOwners.contains(tid),
                                  onChanged: (v) => setDialogState(() {
                                    if (v == true) {
                                      selectedOwners.add(tid);
                                    } else {
                                      selectedOwners.remove(tid);
                                    }
                                  }),
                                  title: Text(owner['displayName'],
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 13)),
                                  subtitle: Text(tid,
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 11)),
                                  activeColor: const Color(0xFFD4AF37),
                                  checkColor: Colors.black,
                                  dense: true,
                                );
                              }).toList(),
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text('Selected: ${selectedOwners.length} owners',
                        style: const TextStyle(
                            color: Colors.orange, fontSize: 11)),
                  ],
                  const SizedBox(height: 16),

                  // Source language
                  const Text('Write message in:',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedLanguage,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF2C2C2C),
                        style: const TextStyle(color: Colors.white),
                        items: languages
                            .map((l) => DropdownMenuItem(
                                value: l, child: Text(languageNames[l] ?? l)))
                            .toList(),
                        onChanged: (v) =>
                            setDialogState(() => selectedLanguage = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Message
                  const Text('Message *',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: messageCtrl,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter notification message...',
                      hintStyle: TextStyle(color: Colors.grey[700]),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFD4AF37))),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Translate button
                  ElevatedButton.icon(
                    onPressed: isTranslating || messageCtrl.text.isEmpty
                        ? null
                        : () async {
                            setDialogState(() => isTranslating = true);
                            try {
                              final result = await _functions
                                  .httpsCallable('translateNotification')
                                  .call({
                                'text': messageCtrl.text,
                                'sourceLanguage': selectedLanguage,
                                'targetLanguages': languages
                                    .where((l) => l != selectedLanguage)
                                    .toList(),
                              });

                              translations = Map<String, String>.from(
                                  result.data['translations'] ?? {});
                              translations[selectedLanguage] = messageCtrl.text;

                              if (context.mounted) {
                                setDialogState(() => isTranslating = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          '✅ Translated to all languages!'),
                                      backgroundColor: Colors.green),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                setDialogState(() => isTranslating = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Translation error: $e'),
                                      backgroundColor: Colors.red),
                                );
                              }
                            }
                          },
                    icon: isTranslating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black))
                        : const Icon(Icons.translate),
                    label: Text(isTranslating
                        ? 'Translating...'
                        : '🌍 Translate to All Languages'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black),
                  ),
                  const SizedBox(height: 12),

                  if (translations.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 18),
                        const SizedBox(width: 10),
                        Text('✅ Translated to ${translations.length} languages',
                            style: const TextStyle(color: Colors.green)),
                      ]),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.grey))),
            ElevatedButton.icon(
              onPressed: messageCtrl.text.isEmpty ||
                      (!sendToAll && selectedOwners.isEmpty)
                  ? null
                  : () {
                      if (translations.isEmpty) {
                        for (final l in languages) {
                          translations[l] = messageCtrl.text;
                        }
                      }
                      Navigator.pop(ctx, {
                        'message': messageCtrl.text,
                        'priority': selectedPriority,
                        'sourceLanguage': selectedLanguage,
                        'translations': translations,
                        'sendToAll': sendToAll,
                        'targetOwners':
                            sendToAll ? <String>[] : selectedOwners.toList(),
                      });
                    },
              icon: const Icon(Icons.send),
              label: const Text('PUBLISH'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      await _createNotification(result);
    }
  }

  Future<void> _createNotification(Map<String, dynamic> data) async {
    try {
      final sendToAll = data['sendToAll'] as bool? ?? true;
      final targetOwners = data['targetOwners'] as List<String>? ?? [];

      await _firestore.collection('system_notifications').add({
        'message': data['message'],
        'priority': data['priority'],
        'sourceLanguage': data['sourceLanguage'],
        'translations': data['translations'],
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'Super Admin',
        'dismissedBy': [],
        'sendToAll': sendToAll,
        'targetOwners': targetOwners,
      });

      final targetDesc = sendToAll
          ? 'all_owners'
          : '${targetOwners.length} owners: ${targetOwners.join(", ")}';

      await _firestore.collection('admin_logs').add({
        'action': 'CREATE_NOTIFICATION',
        'targetId': targetDesc,
        'details':
            '${data['priority'].toString().toUpperCase()}: ${data['message'].toString().substring(0, data['message'].toString().length.clamp(0, 50))}...',
        'timestamp': FieldValue.serverTimestamp(),
        'performedBy': 'Super Admin',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '✅ Notification published to ${sendToAll ? "all owners" : "${targetOwners.length} selected owners"}!'),
          backgroundColor: Colors.green,
        ));
        _loadNotifications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _toggleActive(String id, bool currentActive) async {
    try {
      await _firestore
          .collection('system_notifications')
          .doc(id)
          .update({'active': !currentActive});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(currentActive
              ? '⏸️ Notification deactivated'
              : '✅ Notification activated'),
          backgroundColor: currentActive ? Colors.orange : Colors.green,
        ));
        _loadNotifications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deleteNotification(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Notification?',
            style: TextStyle(color: Colors.white)),
        content: const Text('This cannot be undone.',
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      try {
        await _firestore.collection('system_notifications').doc(id).delete();
        await _firestore.collection('admin_logs').add({
          'action': 'DELETE_NOTIFICATION',
          'targetId': id,
          'details': 'Notification deleted',
          'timestamp': FieldValue.serverTimestamp(),
          'performedBy': 'Super Admin',
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('✅ Deleted'), backgroundColor: Colors.green));
          _loadNotifications();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  String _formatDate(dynamic ts) {
    if (ts == null) return 'N/A';
    if (ts is Timestamp) return ts.toDate().toString().substring(0, 16);
    return ts.toString();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFFD4AF37),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('📢 System Notifications',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: _showCreateDialog,
                icon: const Icon(Icons.add),
                label: const Text('NEW'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Notifications appear as a banner and popup for all owners when they login.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 24),
          const Text('🟢 Active Notifications',
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
              : _notifications.where((n) => n['active'] == true).isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                          child: Text('No active notifications',
                              style: TextStyle(color: Colors.grey))),
                    )
                  : Column(
                      children: _notifications
                          .where((n) => n['active'] == true)
                          .map((n) => _notificationCard(n))
                          .toList(),
                    ),
          const SizedBox(height: 32),
          const Text('⚫ Inactive Notifications',
              style:
                  TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _notifications.where((n) => n['active'] != true).isEmpty
              ? Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                      child: Text('No inactive notifications',
                          style: TextStyle(color: Colors.grey))),
                )
              : Column(
                  children: _notifications
                      .where((n) => n['active'] != true)
                      .map((n) => _notificationCard(n))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _notificationCard(Map<String, dynamic> n) {
    final priority = n['priority'] as String? ?? 'blue';
    final color = priorityColors[priority] ?? Colors.blue;
    final icon = priorityIcons[priority] ?? Icons.info;
    final isActive = n['active'] == true;
    final dismissedCount = (n['dismissedBy'] as List?)?.length ?? 0;
    final sendToAll = n['sendToAll'] as bool? ?? true;
    final targetOwners = (n['targetOwners'] as List?)?.length ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isActive
                ? color.withValues(alpha: 0.5)
                : Colors.grey.withValues(alpha: 0.2),
            width: isActive ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isActive ? 0.15 : 0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(priority.toUpperCase(),
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
              const SizedBox(width: 8),
              // Target badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: sendToAll
                      ? Colors.blue.withValues(alpha: 0.2)
                      : Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  sendToAll ? '🌍 ALL' : '👥 $targetOwners',
                  style: TextStyle(
                      color: sendToAll ? Colors.blue : Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 11),
                ),
              ),
              const Spacer(),
              if (isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Text('ACTIVE',
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 11)),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Text('INACTIVE',
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 11)),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(n['message'] ?? '',
                  style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey,
                      fontSize: 14)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  Text('Created: ${_formatDate(n['createdAt'])}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  Text('Dismissed: $dismissedCount',
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  Text('Languages: ${(n['translations'] as Map?)?.length ?? 1}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  Text(
                      sendToAll
                          ? 'Target: All Owners'
                          : 'Target: $targetOwners owners',
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(11)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton.icon(
                onPressed: () => _toggleActive(n['id'], isActive),
                icon: Icon(isActive ? Icons.pause : Icons.play_arrow, size: 18),
                label: Text(isActive ? 'Deactivate' : 'Activate'),
                style: TextButton.styleFrom(
                    foregroundColor: isActive ? Colors.orange : Colors.green),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _deleteNotification(n['id']),
                icon: const Icon(Icons.delete, size: 18),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
