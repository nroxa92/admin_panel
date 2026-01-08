// FILE: lib/screens/super_admin_screen.dart
// VERSION: 3.1 - Fixed linter warnings

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'super_admin_tablets.dart';
import 'super_admin_notifications.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west3');

  late TabController _tabController;

  List<Map<String, dynamic>> _owners = [];
  bool _isLoadingOwners = true;
  String _ownerFilter = 'all';
  String _searchQuery = '';

  int _totalOwners = 0;
  int _activeOwners = 0;
  int _pendingOwners = 0;
  int _totalUnits = 0;
  int _totalBookings = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadOwners();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOwners() async {
    if (!mounted) return;
    setState(() => _isLoadingOwners = true);

    try {
      final snapshot = await _firestore.collection('tenant_links').get();

      List<Map<String, dynamic>> owners = [];
      int totalUnits = 0;
      int totalBookings = 0;
      int active = 0;
      int pending = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final tenantId = doc.id;

        int unitCount = 0;
        int bookingCount = 0;
        try {
          final unitsSnap = await _firestore
              .collection('units')
              .where('ownerId', isEqualTo: tenantId)
              .get();
          unitCount = unitsSnap.size;
          totalUnits += unitCount;

          final bookingsSnap = await _firestore
              .collection('bookings')
              .where('ownerId', isEqualTo: tenantId)
              .get();
          bookingCount = bookingsSnap.size;
          totalBookings += bookingCount;
        } catch (_) {}

        final status = data['status'] ?? 'pending';
        if (status == 'active') active++;
        if (status == 'pending') pending++;

        owners.add({
          'tenantId': tenantId,
          'email': data['email'] ?? 'N/A',
          'displayName': data['displayName'] ?? 'N/A',
          'status': status,
          'createdAt': data['createdAt'],
          'linkedAt': data['linkedAt'],
          'firebaseUid': data['firebaseUid'],
          'unitCount': unitCount,
          'bookingCount': bookingCount,
        });
      }

      if (mounted) {
        setState(() {
          _owners = owners;
          _totalOwners = owners.length;
          _activeOwners = active;
          _pendingOwners = pending;
          _totalUnits = totalUnits;
          _totalBookings = totalBookings;
          _isLoadingOwners = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingOwners = false);
        _showError('Error: $e');
      }
    }
  }

  Future<void> _showCreateOwnerDialog() async {
    final tenantIdCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final displayNameCtrl = TextEditingController();

    final result = await showDialog<Map<String, String>?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(children: [
          Icon(Icons.person_add, color: Color(0xFFD4AF37)),
          SizedBox(width: 10),
          Text('Create Owner', style: TextStyle(color: Colors.white))
        ]),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                    controller: tenantIdCtrl,
                    label: 'Tenant ID *',
                    hint: 'ROKSA123 (6-12 A-Z, 0-9)',
                    textCapitalization: TextCapitalization.characters),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: emailCtrl,
                    label: 'Email *',
                    hint: 'owner@example.com',
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: _buildTextField(
                          controller: passwordCtrl,
                          label: 'Password *',
                          hint: 'Min 6 chars')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => passwordCtrl.text = _generatePassword(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12)),
                    child: const Text('Gen',
                        style: TextStyle(color: Colors.black)),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: displayNameCtrl,
                    label: 'Display Name',
                    hint: 'John Doe'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              final tid = tenantIdCtrl.text.trim().toUpperCase();
              final email = emailCtrl.text.trim();
              final pass = passwordCtrl.text;
              if (tid.isEmpty || email.isEmpty || pass.isEmpty) {
                _showError('Fill all fields');
                return;
              }
              if (!RegExp(r'^[A-Z0-9]{6,12}$').hasMatch(tid)) {
                _showError('Invalid Tenant ID');
                return;
              }
              if (pass.length < 6) {
                _showError('Password min 6 chars');
                return;
              }
              Navigator.pop(ctx, {
                'tenantId': tid,
                'email': email,
                'password': pass,
                'displayName': displayNameCtrl.text.trim().isNotEmpty
                    ? displayNameCtrl.text.trim()
                    : email.split('@')[0]
              });
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37)),
            child: const Text('CREATE',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      try {
        final r = await _functions.httpsCallable('createOwner').call(result);
        await _logActivity(
            'CREATE_OWNER', result['tenantId']!, result['email']!, 'Created');
        if (mounted) {
          _showSuccessDialog(
              '✅ Created!\n\n📧 ${r.data['email']}\n🆔 ${r.data['tenantId']}\n🔑 ${result['password']}');
          _loadOwners();
        }
      } catch (e) {
        if (mounted) _showError('Error: $e');
      }
    }
  }

  void _showOwnerDetailsDialog(Map<String, dynamic> o) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(children: [
          const Icon(Icons.info_outline, color: Color(0xFFD4AF37)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(o['displayName'] ?? o['tenantId'],
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis))
        ]),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow('Tenant ID', o['tenantId'], isHighlight: true),
                  _detailRow('Email', o['email']),
                  _detailRow('Status', o['status'], isStatus: true),
                  _detailRow('UID', o['firebaseUid'] ?? 'N/A', isMono: true),
                  const Divider(color: Colors.grey, height: 24),
                  _detailRow('Units', '${o['unitCount']}'),
                  _detailRow('Bookings', '${o['bookingCount']}'),
                  _detailRow('Created', _formatDate(o['createdAt'])),
                ]),
          ),
        ),
        actions: [
          TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _resetPassword(o['tenantId'], o['email']);
              },
              icon: const Icon(Icons.key, size: 18),
              label: const Text('Reset PW'),
              style: TextButton.styleFrom(foregroundColor: Colors.orange)),
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  Future<void> _resetPassword(String tid, String email) async {
    final ctrl = TextEditingController();
    final pw = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title:
            const Text('Reset Password', style: TextStyle(color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('For "$tid"', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          _buildTextField(
              controller: ctrl, label: 'New Password', hint: 'Min 6 chars'),
          TextButton(
              onPressed: () => ctrl.text = _generatePassword(),
              child: const Text('🎲 Generate',
                  style: TextStyle(color: Color(0xFFD4AF37)))),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
              onPressed: () {
                if (ctrl.text.length >= 6) {
                  Navigator.pop(ctx, ctrl.text);
                } else {
                  _showError('Min 6 chars');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Reset')),
        ],
      ),
    );
    if (pw != null && mounted) {
      try {
        await _functions
            .httpsCallable('resetOwnerPassword')
            .call({'tenantId': tid, 'newPassword': pw});
        await _logActivity('RESET_PASSWORD', tid, email, 'Reset');
        if (mounted) _showSuccessDialog('✅ Reset!\n\nNew: $pw');
      } catch (e) {
        if (mounted) _showError('Error: $e');
      }
    }
  }

  Future<void> _toggleStatus(String tid, String status, String email) async {
    final newStatus = status == 'active' ? 'suspended' : 'active';
    final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: Text('${newStatus == 'active' ? 'Activate' : 'Suspend'}?',
                  style: const TextStyle(color: Colors.white)),
              content: Text('Tenant: $tid',
                  style: const TextStyle(color: Colors.grey)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            newStatus == 'active' ? Colors.green : Colors.red),
                    child: Text(newStatus.toUpperCase())),
              ],
            ));
    if (ok == true && mounted) {
      try {
        await _functions
            .httpsCallable('toggleOwnerStatus')
            .call({'tenantId': tid, 'status': newStatus});
        await _logActivity(
            '${newStatus.toUpperCase()}_OWNER', tid, email, newStatus);
        if (mounted) {
          _showSnack('✅ $newStatus!', Colors.green);
          _loadOwners();
        }
      } catch (e) {
        if (mounted) _showError('Error: $e');
      }
    }
  }

  Future<void> _deleteOwner(String tid, String email) async {
    final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Row(children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 10),
                Text('DELETE?', style: TextStyle(color: Colors.red))
              ]),
              content: Text('Permanently delete $tid?',
                  style: const TextStyle(color: Colors.grey)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('DELETE')),
              ],
            ));
    if (ok != true || !mounted) return;

    final ctrl = TextEditingController();
    final ok2 = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text('Type Tenant ID',
                  style: TextStyle(color: Colors.white)),
              content: TextField(
                  controller: ctrl,
                  style: const TextStyle(color: Colors.white),
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                      hintText: tid,
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: const OutlineInputBorder())),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                    onPressed: () {
                      if (ctrl.text.toUpperCase() == tid.toUpperCase()) {
                        Navigator.pop(ctx, true);
                      } else {
                        _showError('Mismatch');
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('CONFIRM')),
              ],
            ));
    if (ok2 == true && mounted) {
      try {
        await _functions.httpsCallable('deleteOwner').call({'tenantId': tid});
        await _logActivity('DELETE_OWNER', tid, email, 'Deleted');
        if (mounted) {
          _showSnack('✅ Deleted!', Colors.green);
          _loadOwners();
        }
      } catch (e) {
        if (mounted) _showError('Error: $e');
      }
    }
  }

  Future<void> _logActivity(
      String action, String tid, String email, String details) async {
    try {
      await _firestore.collection('admin_logs').add({
        'action': action,
        'targetId': tid,
        'targetEmail': email,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
        'performedBy': 'Super Admin'
      });
    } catch (_) {}
  }

  String _generatePassword() {
    const c = 'ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789!@#\$%^&*';
    final r = DateTime.now().microsecondsSinceEpoch;
    return List.generate(16, (i) => c[(r + i * 7) % c.length]).join();
  }

  String _formatDate(dynamic ts) {
    if (ts == null) return 'N/A';
    if (ts is Timestamp) return ts.toDate().toString().substring(0, 16);
    return ts.toString();
  }

  void _showError(String m) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(m), backgroundColor: Colors.red));
    }
  }

  void _showSnack(String m, Color c) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(m), backgroundColor: c));
    }
  }

  void _showSuccessDialog(String m) {
    if (mounted) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  content: Text(m, style: const TextStyle(color: Colors.white)),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('OK',
                            style: TextStyle(color: Color(0xFFD4AF37))))
                  ]));
    }
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      String? hint,
      TextInputType? keyboardType,
      TextCapitalization textCapitalization = TextCapitalization.none}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
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
      ),
    );
  }

  Widget _detailRow(String l, String v,
      {bool isHighlight = false, bool isStatus = false, bool isMono = false}) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(l, style: const TextStyle(color: Colors.grey)),
          if (isStatus)
            _statusBadge(v)
          else
            Flexible(
                child: Text(v,
                    style: TextStyle(
                        color: isHighlight
                            ? const Color(0xFFD4AF37)
                            : Colors.white,
                        fontWeight:
                            isHighlight ? FontWeight.bold : FontWeight.normal,
                        fontFamily: isMono ? 'monospace' : null,
                        fontSize: isMono ? 11 : 14),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis)),
        ]));
  }

  Widget _statusBadge(String s) {
    final c = s == 'active'
        ? Colors.green
        : s == 'suspended'
            ? Colors.red
            : Colors.orange;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
            color: c.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.withValues(alpha: 0.5))),
        child: Text(s.toUpperCase(),
            style: TextStyle(
                color: c, fontSize: 11, fontWeight: FontWeight.bold)));
  }

  Widget _statCard(String t, String v, IconData i, Color c) {
    return Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.withValues(alpha: 0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(i, color: c, size: 24),
          const SizedBox(height: 10),
          Text(v,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(t, style: const TextStyle(color: Colors.grey, fontSize: 11))
        ]));
  }

  Widget _filterChip(String l, String v) {
    final sel = _ownerFilter == v;
    return FilterChip(
        label: Text(l),
        selected: sel,
        onSelected: (_) => setState(() => _ownerFilter = v),
        selectedColor: const Color(0xFFD4AF37).withValues(alpha: 0.3),
        checkmarkColor: const Color(0xFFD4AF37),
        labelStyle: TextStyle(
            color: sel ? const Color(0xFFD4AF37) : Colors.grey, fontSize: 13),
        backgroundColor: const Color(0xFF2A2A2A),
        side: BorderSide(
            color: sel
                ? const Color(0xFFD4AF37)
                : Colors.grey.withValues(alpha: 0.3)));
  }

  List<Map<String, dynamic>> get _filteredOwners {
    var l = _owners;
    if (_ownerFilter != 'all') {
      l = l.where((o) => o['status'] == _ownerFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      l = l
          .where((o) =>
              (o['tenantId']?.toString().toLowerCase().contains(q) ?? false) ||
              (o['email']?.toString().toLowerCase().contains(q) ?? false) ||
              (o['displayName']?.toString().toLowerCase().contains(q) ?? false))
          .toList();
    }
    return l;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14141E),
        elevation: 0,
        title: const Row(children: [
          Icon(Icons.admin_panel_settings, color: Color(0xFFD4AF37), size: 28),
          SizedBox(width: 12),
          Text('SUPER ADMIN',
              style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2))
        ]),
        bottom: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFFD4AF37),
            labelColor: const Color(0xFFD4AF37),
            unselectedLabelColor: Colors.grey,
            isScrollable: true,
            tabs: const [
              Tab(icon: Icon(Icons.people), text: 'Owners'),
              Tab(icon: Icon(Icons.tablet_android), text: 'Tablets'),
              Tab(icon: Icon(Icons.system_update), text: 'APK'),
              Tab(icon: Icon(Icons.history), text: 'Activity'),
              Tab(icon: Icon(Icons.campaign), text: 'Notify'),
            ]),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadOwners,
              tooltip: 'Refresh'),
          IconButton(
              icon: const Icon(Icons.logout, color: Colors.grey),
              onPressed: () async {
                final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                            backgroundColor: const Color(0xFF1E1E1E),
                            title: const Text('Logout?',
                                style: TextStyle(color: Colors.white)),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel')),
                              ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Logout'))
                            ]));
                if (ok == true && mounted) {
                  await FirebaseAuth.instance.signOut();
                }
              },
              tooltip: 'Logout'),
          const SizedBox(width: 16),
        ],
      ),
      body: TabBarView(controller: _tabController, children: [
        _buildOwnersTab(),
        SuperAdminTabletsTab(owners: _owners),
        SuperAdminApkTab(owners: _owners),
        const SuperAdminActivityTab(),
        const SuperAdminNotificationsTab(),
      ]),
    );
  }

  Widget _buildOwnersTab() {
    return RefreshIndicator(
      onRefresh: _loadOwners,
      color: const Color(0xFFD4AF37),
      child: ListView(padding: const EdgeInsets.all(24), children: [
        Wrap(spacing: 16, runSpacing: 16, children: [
          _statCard('Total', '$_totalOwners', Icons.people, Colors.blue),
          _statCard(
              'Active', '$_activeOwners', Icons.check_circle, Colors.green),
          _statCard('Pending', '$_pendingOwners', Icons.hourglass_empty,
              Colors.orange),
          _statCard('Units', '$_totalUnits', Icons.home, Colors.purple),
          _statCard(
              'Bookings', '$_totalBookings', Icons.calendar_today, Colors.teal),
        ]),
        const SizedBox(height: 24),
        Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                  width: 300,
                  child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF1E1E1E),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none)))),
              _filterChip('All', 'all'),
              _filterChip('Active', 'active'),
              _filterChip('Pending', 'pending'),
              _filterChip('Suspended', 'suspended'),
              ElevatedButton.icon(
                  onPressed: _showCreateOwnerDialog,
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: const Text('NEW',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14))),
            ]),
        const SizedBox(height: 16),
        _isLoadingOwners
            ? const Center(
                child: Padding(
                    padding: EdgeInsets.all(60),
                    child: CircularProgressIndicator(color: Color(0xFFD4AF37))))
            : Container(
                decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.grey.withValues(alpha: 0.2))),
                child: _filteredOwners.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(60),
                        child: Center(
                            child: Text('No owners',
                                style: TextStyle(color: Colors.grey))))
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredOwners.length,
                        separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: Colors.grey.withValues(alpha: 0.2)),
                        itemBuilder: (_, i) => _ownerRow(_filteredOwners[i])),
              ),
      ]),
    );
  }

  Widget _ownerRow(Map<String, dynamic> o) {
    return InkWell(
      onTap: () => _showOwnerDetailsDialog(o),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(children: [
            CircleAvatar(
                backgroundColor: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                radius: 20,
                child: Text(
                    (o['displayName'] ?? o['tenantId'])[0].toUpperCase(),
                    style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold))),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(o['displayName'] ?? 'N/A',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  Text('${o['tenantId']} • ${o['email']}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      overflow: TextOverflow.ellipsis)
                ])),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12)),
                child: Text('${o['unitCount']}',
                    style:
                        const TextStyle(color: Colors.purple, fontSize: 10))),
            const SizedBox(width: 10),
            _statusBadge(o['status']),
            PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                color: const Color(0xFF2A2A2A),
                onSelected: (v) {
                  if (v == 'details') _showOwnerDetailsDialog(o);
                  if (v == 'toggle') {
                    _toggleStatus(o['tenantId'], o['status'], o['email']);
                  }
                  if (v == 'reset') _resetPassword(o['tenantId'], o['email']);
                  if (v == 'delete') _deleteOwner(o['tenantId'], o['email']);
                },
                itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'details',
                          child: Text('👁️ Details',
                              style: TextStyle(color: Colors.white))),
                      PopupMenuItem(
                          value: 'toggle',
                          child: Text(
                              o['status'] == 'active'
                                  ? '⏸️ Suspend'
                                  : '▶️ Activate',
                              style: const TextStyle(color: Colors.white))),
                      const PopupMenuItem(
                          value: 'reset',
                          child: Text('🔑 Reset PW',
                              style: TextStyle(color: Colors.white))),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                          value: 'delete',
                          child: Text('🗑️ Delete',
                              style: TextStyle(color: Colors.red))),
                    ]),
          ])),
    );
  }
}
