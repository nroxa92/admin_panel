// FILE: lib/screens/super_admin_tablets.dart
// VERSION: 3.1 - Fixed linter warnings

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// =============================================================================
// TABLETS TAB
// =============================================================================
class SuperAdminTabletsTab extends StatefulWidget {
  final List<Map<String, dynamic>> owners;
  const SuperAdminTabletsTab({super.key, required this.owners});

  @override
  State<SuperAdminTabletsTab> createState() => _SuperAdminTabletsTabState();
}

class _SuperAdminTabletsTabState extends State<SuperAdminTabletsTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _tablets = [];
  bool _isLoading = true;
  String _filter = 'all';

  int _totalTablets = 0;
  int _onlineTablets = 0;

  @override
  void initState() {
    super.initState();
    _loadTablets();
  }

  Future<void> _loadTablets() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final snapshot = await _firestore.collection('tablets').get();
      final now = DateTime.now();

      List<Map<String, dynamic>> tablets = [];
      int online = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final lastHeartbeat = data['lastHeartbeat'] as Timestamp?;

        bool isOnline = false;
        if (lastHeartbeat != null) {
          isOnline = now.difference(lastHeartbeat.toDate()).inMinutes < 5;
        }
        if (isOnline) online++;

        tablets.add({
          'deviceId': doc.id,
          'unitId': data['unitId'] ?? 'N/A',
          'ownerId': data['ownerId'] ?? 'N/A',
          'ownerName': data['ownerName'] ?? 'N/A',
          'unitName': data['unitName'] ?? 'N/A',
          'appVersion': data['appVersion'] ?? 'Unknown',
          'lastHeartbeat': lastHeartbeat,
          'isOnline': isOnline,
          'model': data['model'] ?? 'Unknown',
          'osVersion': data['osVersion'] ?? 'Unknown',
          'pendingUpdate': data['pendingUpdate'] ?? false,
          'pendingVersion': data['pendingVersion'] ?? '',
          'updateStatus': data['updateStatus'] ??
              '', // 'pending', 'downloading', 'downloaded', 'installed', 'failed'
          'updateError': data['updateError'] ?? '',
          'updatePushedAt': data['updatePushedAt'],
          'updateDownloadedAt': data['updateDownloadedAt'],
          'updateInstalledAt': data['updateInstalledAt'],
        });
      }

      tablets.sort(
          (a, b) => (a['ownerId'] as String).compareTo(b['ownerId'] as String));

      if (mounted) {
        setState(() {
          _tablets = tablets;
          _totalTablets = tablets.length;
          _onlineTablets = online;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredTablets {
    if (_filter == 'online') {
      return _tablets.where((t) => t['isOnline'] == true).toList();
    }
    if (_filter == 'offline') {
      return _tablets.where((t) => t['isOnline'] != true).toList();
    }
    if (_filter == 'pending') {
      return _tablets.where((t) => t['pendingUpdate'] == true).toList();
    }
    return _tablets;
  }

  Map<String, List<Map<String, dynamic>>> get _tabletsByOwner {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final t in _filteredTablets) {
      final ownerId = t['ownerId'] as String;
      map.putIfAbsent(ownerId, () => []).add(t);
    }
    return map;
  }

  String _timeAgo(dynamic ts) {
    if (ts == null) return 'Never';
    if (ts is! Timestamp) return 'Unknown';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadTablets,
      color: const Color(0xFFD4AF37),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _statCard(
                  'Total', '$_totalTablets', Icons.tablet_android, Colors.blue),
              _statCard('Online', '$_onlineTablets', Icons.wifi, Colors.green),
              _statCard('Offline', '${_totalTablets - _onlineTablets}',
                  Icons.wifi_off, Colors.red),
              _statCard(
                  'Pending',
                  '${_tablets.where((t) => t['pendingUpdate'] == true).length}',
                  Icons.system_update,
                  Colors.orange),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            children: [
              _filterChip('All', 'all'),
              _filterChip('Online', 'online'),
              _filterChip('Offline', 'offline'),
              _filterChip('Pending Update', 'pending'),
            ],
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const Center(
                  child: Padding(
                      padding: EdgeInsets.all(60),
                      child:
                          CircularProgressIndicator(color: Color(0xFFD4AF37))))
              : _tablets.isEmpty
                  ? _emptyState()
                  : Column(
                      children: _tabletsByOwner.entries
                          .map((entry) => _ownerSection(entry.key, entry.value))
                          .toList(),
                    ),
        ],
      ),
    );
  }

  Widget _ownerSection(String ownerId, List<Map<String, dynamic>> tablets) {
    final ownerName = tablets.isNotEmpty ? tablets.first['ownerName'] : ownerId;
    final onlineCount = tablets.where((t) => t['isOnline'] == true).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  radius: 18,
                  child: Text(ownerName[0].toUpperCase(),
                      style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ownerName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text(ownerId,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('${tablets.length} tablets',
                      style: const TextStyle(color: Colors.blue, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('$onlineCount online',
                      style:
                          const TextStyle(color: Colors.green, fontSize: 12)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: tablets.map((t) => _tabletCard(t)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabletCard(Map<String, dynamic> t) {
    final isOnline = t['isOnline'] == true;
    final hasPending = t['pendingUpdate'] == true;
    final updateStatus = t['updateStatus'] as String? ?? '';
    final updateError = t['updateError'] as String? ?? '';

    // Determine update status color and icon
    Color updateColor = Colors.orange;
    IconData updateIcon = Icons.pending;
    String updateLabel = 'PENDING';

    switch (updateStatus) {
      case 'downloading':
        updateColor = Colors.blue;
        updateIcon = Icons.downloading;
        updateLabel = 'DOWNLOADING';
        break;
      case 'downloaded':
        updateColor = Colors.cyan;
        updateIcon = Icons.download_done;
        updateLabel = 'DOWNLOADED';
        break;
      case 'installed':
        updateColor = Colors.green;
        updateIcon = Icons.check_circle;
        updateLabel = 'INSTALLED';
        break;
      case 'failed':
        updateColor = Colors.red;
        updateIcon = Icons.error;
        updateLabel = 'FAILED';
        break;
    }

    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isOnline
                ? Colors.green.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isOnline ? Icons.wifi : Icons.wifi_off,
                  color: isOnline ? Colors.green : Colors.grey, size: 16),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(t['unitName'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
          Text('v${t['appVersion']}',
              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11)),
          Text(t['model'],
              style: const TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 4),
          Text(isOnline ? '🟢 Online' : '⚫ ${_timeAgo(t['lastHeartbeat'])}',
              style: TextStyle(
                  color: isOnline ? Colors.green : Colors.grey, fontSize: 10)),
          // Update Status
          if (hasPending || updateStatus.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: updateColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: updateColor.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(updateIcon, color: updateColor, size: 12),
                  const SizedBox(width: 4),
                  Text(updateLabel,
                      style: TextStyle(
                          color: updateColor,
                          fontSize: 8,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (t['pendingVersion'] != null &&
                (t['pendingVersion'] as String).isNotEmpty)
              Text('→ v${t['pendingVersion']}',
                  style: const TextStyle(color: Colors.orange, fontSize: 9)),
            if (updateError.isNotEmpty)
              Text(updateError,
                  style: const TextStyle(color: Colors.red, fontSize: 8),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }

  Widget _statCard(String t, String v, IconData i, Color c) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withValues(alpha: 0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(i, color: c, size: 22),
        const SizedBox(height: 8),
        Text(v,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        Text(t, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ]),
    );
  }

  Widget _filterChip(String l, String v) {
    final sel = _filter == v;
    return FilterChip(
      label: Text(l),
      selected: sel,
      onSelected: (_) => setState(() => _filter = v),
      selectedColor: const Color(0xFFD4AF37).withValues(alpha: 0.3),
      checkmarkColor: const Color(0xFFD4AF37),
      labelStyle: TextStyle(
          color: sel ? const Color(0xFFD4AF37) : Colors.grey, fontSize: 13),
      backgroundColor: const Color(0xFF2A2A2A),
      side: BorderSide(
          color: sel
              ? const Color(0xFFD4AF37)
              : Colors.grey.withValues(alpha: 0.3)),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12)),
      child: const Center(
          child: Column(children: [
        Icon(Icons.tablet_android, color: Colors.grey, size: 60),
        SizedBox(height: 16),
        Text('No tablets registered', style: TextStyle(color: Colors.grey)),
      ])),
    );
  }
}

// =============================================================================
// APK UPDATES TAB
// =============================================================================
class SuperAdminApkTab extends StatefulWidget {
  final List<Map<String, dynamic>> owners;
  const SuperAdminApkTab({super.key, required this.owners});

  @override
  State<SuperAdminApkTab> createState() => _SuperAdminApkTabState();
}

class _SuperAdminApkTabState extends State<SuperAdminApkTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _currentVersion = '';
  String _currentUrl = '';
  List<Map<String, dynamic>> _updateHistory = [];
  List<Map<String, dynamic>> _tablets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final configDoc =
          await _firestore.collection('app_config').doc('tablet_app').get();
      if (configDoc.exists) {
        final data = configDoc.data()!;
        _currentVersion = data['currentVersion'] ?? '1.0.0';
        _currentUrl = data['apkUrl'] ?? '';
      }

      final historySnap = await _firestore
          .collection('apk_updates')
          .orderBy('pushedAt', descending: true)
          .limit(20)
          .get();
      _updateHistory =
          historySnap.docs.map((d) => {'id': d.id, ...d.data()}).toList();

      final tabletsSnap = await _firestore.collection('tablets').get();
      _tablets =
          tabletsSnap.docs.map((d) => {'deviceId': d.id, ...d.data()}).toList();

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, List<Map<String, dynamic>>> get _tabletsByOwner {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final t in _tablets) {
      final ownerId = t['ownerId'] as String? ?? 'Unknown';
      map.putIfAbsent(ownerId, () => []).add(t);
    }
    return map;
  }

  Future<void> _showDeployDialog() async {
    final versionCtrl = TextEditingController(text: _currentVersion);
    final urlCtrl = TextEditingController(text: _currentUrl);
    bool forceUpdate = false;
    final Set<String> tempSelected = {};

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Row(children: [
            Icon(Icons.system_update, color: Color(0xFFD4AF37)),
            SizedBox(width: 10),
            Text('Deploy APK Update', style: TextStyle(color: Colors.white)),
          ]),
          content: SizedBox(
            width: 600,
            height: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline,
                          color: Colors.blue, size: 18),
                      const SizedBox(width: 10),
                      Text('Current: $_currentVersion',
                          style: const TextStyle(color: Colors.blue)),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: versionCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('New Version *', '1.0.1'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: urlCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('APK URL *',
                        'https://storage.googleapis.com/.../app.apk'),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Checkbox(
                      value: forceUpdate,
                      onChanged: (v) =>
                          setDialogState(() => forceUpdate = v ?? false),
                      activeColor: const Color(0xFFD4AF37),
                    ),
                    const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Force Update',
                              style: TextStyle(color: Colors.white)),
                          Text('Auto-download & install',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 11)),
                        ]),
                  ]),
                  const SizedBox(height: 20),
                  const Text('Select Owners to Update:',
                      style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                    child: _tabletsByOwner.isEmpty
                        ? const Center(
                            child: Text('No tablets found',
                                style: TextStyle(color: Colors.grey)))
                        : ListView(
                            padding: const EdgeInsets.all(8),
                            children: [
                              CheckboxListTile(
                                value: tempSelected.length ==
                                    _tabletsByOwner.length,
                                onChanged: (v) => setDialogState(() {
                                  if (v == true) {
                                    tempSelected.addAll(_tabletsByOwner.keys);
                                  } else {
                                    tempSelected.clear();
                                  }
                                }),
                                title: const Text('🌍 SELECT ALL',
                                    style: TextStyle(
                                        color: Color(0xFFD4AF37),
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    '${_tablets.length} tablets total',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 11)),
                                activeColor: const Color(0xFFD4AF37),
                                checkColor: Colors.black,
                                dense: true,
                              ),
                              const Divider(color: Colors.grey),
                              ..._tabletsByOwner.entries.map((entry) {
                                final ownerId = entry.key;
                                final tablets = entry.value;
                                final ownerName = tablets.isNotEmpty
                                    ? tablets.first['ownerName'] ?? ownerId
                                    : ownerId;
                                return CheckboxListTile(
                                  value: tempSelected.contains(ownerId),
                                  onChanged: (v) => setDialogState(() {
                                    if (v == true) {
                                      tempSelected.add(ownerId);
                                    } else {
                                      tempSelected.remove(ownerId);
                                    }
                                  }),
                                  title: Text(ownerName,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                  subtitle: Text(
                                      '$ownerId • ${tablets.length} tablet(s)',
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 11)),
                                  activeColor: const Color(0xFFD4AF37),
                                  checkColor: Colors.black,
                                  dense: true,
                                );
                              }),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      const Icon(Icons.devices, color: Colors.orange, size: 18),
                      const SizedBox(width: 10),
                      Builder(builder: (context) {
                        int count = 0;
                        for (final oid in tempSelected) {
                          count += _tabletsByOwner[oid]?.length ?? 0;
                        }
                        return Text('$count tablet(s) will receive this update',
                            style: const TextStyle(color: Colors.orange));
                      }),
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
              onPressed: () {
                if (versionCtrl.text.isEmpty || urlCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Fill version & URL'),
                      backgroundColor: Colors.red));
                  return;
                }
                if (tempSelected.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Select at least one owner'),
                      backgroundColor: Colors.red));
                  return;
                }
                Navigator.pop(ctx, {
                  'version': versionCtrl.text,
                  'url': urlCtrl.text,
                  'force': forceUpdate,
                  'owners': tempSelected.toList(),
                });
              },
              icon: const Icon(Icons.cloud_upload, size: 18),
              label: const Text('DEPLOY'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      await _deployUpdate(result);
    }
  }

  Future<void> _deployUpdate(Map<String, dynamic> params) async {
    try {
      final version = params['version'] as String;
      final url = params['url'] as String;
      final force = params['force'] as bool;
      final owners = params['owners'] as List<String>;

      await _firestore.collection('app_config').doc('tablet_app').set({
        'currentVersion': version,
        'apkUrl': url,
        'updatedAt': FieldValue.serverTimestamp(),
        'forceUpdate': force,
      }, SetOptions(merge: true));

      final batch = _firestore.batch();
      int count = 0;

      for (final ownerId in owners) {
        final tablets = _tabletsByOwner[ownerId] ?? [];
        for (final tablet in tablets) {
          final ref = _firestore.collection('tablets').doc(tablet['deviceId']);
          batch.update(ref, {
            'pendingUpdate': true,
            'pendingVersion': version,
            'pendingApkUrl': url,
            'forceUpdate': force,
            'updatePushedAt': FieldValue.serverTimestamp(),
          });
          count++;
        }
      }

      await batch.commit();

      await _firestore.collection('apk_updates').add({
        'version': version,
        'apkUrl': url,
        'forceUpdate': force,
        'targetOwners': owners,
        'tabletsCount': count,
        'pushedAt': FieldValue.serverTimestamp(),
        'pushedBy': 'Super Admin',
      });

      await _firestore.collection('admin_logs').add({
        'action': 'PUSH_APK_UPDATE',
        'targetId': owners.join(', '),
        'details':
            'v$version → $count tablets (${force ? 'FORCED' : 'optional'})',
        'timestamp': FieldValue.serverTimestamp(),
        'performedBy': 'Super Admin',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('✅ Update v$version pushed to $count tablets!'),
          backgroundColor: Colors.green,
        ));
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  InputDecoration _inputDeco(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.grey),
      hintStyle: TextStyle(color: Colors.grey[700]),
      filled: true,
      fillColor: Colors.black26,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD4AF37))),
    );
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  const Color(0xFF1E1E1E)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.android, color: Color(0xFFD4AF37), size: 32),
                  SizedBox(width: 12),
                  Text('Current Version',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 16),
                Text(_currentVersion.isEmpty ? 'Not set' : _currentVersion,
                    style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 36,
                        fontWeight: FontWeight.w800)),
                if (_currentUrl.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('URL: $_currentUrl',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                      overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 24),
                Row(children: [
                  ElevatedButton.icon(
                    onPressed: _showDeployDialog,
                    icon: const Icon(Icons.rocket_launch),
                    label: const Text('DEPLOY UPDATE'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14)),
                  ),
                  const SizedBox(width: 16),
                  Text('${_tablets.length} tablets registered',
                      style: const TextStyle(color: Colors.grey)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('📱 Tablets by Owner',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
              : _tabletsByOwner.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                          child: Text('No tablets found',
                              style: TextStyle(color: Colors.grey))),
                    )
                  : Column(
                      children: _tabletsByOwner.entries.map((entry) {
                        final ownerId = entry.key;
                        final tablets = entry.value;
                        final ownerName = tablets.isNotEmpty
                            ? tablets.first['ownerName'] ?? ownerId
                            : ownerId;
                        final online =
                            tablets.where((t) => t['isOnline'] == true).length;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.2)),
                          ),
                          child: Row(children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFFD4AF37)
                                  .withValues(alpha: 0.2),
                              radius: 20,
                              child: Text(ownerName[0].toUpperCase(),
                                  style: const TextStyle(
                                      color: Color(0xFFD4AF37),
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ownerName,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                    Text(ownerId,
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12)),
                                  ]),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16)),
                              child: Text('${tablets.length} tablets',
                                  style: const TextStyle(
                                      color: Colors.blue, fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16)),
                              child: Text('$online online',
                                  style: const TextStyle(
                                      color: Colors.green, fontSize: 12)),
                            ),
                          ]),
                        );
                      }).toList(),
                    ),
          const SizedBox(height: 32),
          const Text('📜 Update History',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _updateHistory.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                      child: Text('No updates yet',
                          style: TextStyle(color: Colors.grey))),
                )
              : Column(
                  children: _updateHistory
                      .map((u) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: (u['forceUpdate'] == true
                                          ? Colors.red
                                          : Colors.green)
                                      .withValues(alpha: 0.3)),
                            ),
                            child: Row(children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4AF37)
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.system_update,
                                    color: Color(0xFFD4AF37), size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Text('v${u['version']}',
                                            style: const TextStyle(
                                                color: Color(0xFFD4AF37),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        const SizedBox(width: 10),
                                        if (u['forceUpdate'] == true)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                                color: Colors.red
                                                    .withValues(alpha: 0.2),
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: const Text('FORCED',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 9,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                      ]),
                                      const SizedBox(height: 4),
                                      Text(
                                          '${u['tabletsCount']} tablets • ${(u['targetOwners'] as List?)?.length ?? 0} owners',
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12)),
                                    ]),
                              ),
                              Text(_formatDate(u['pushedAt']),
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 11)),
                            ]),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }
}
