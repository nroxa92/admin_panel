// FILE: lib/screens/super_admin_retail.dart
// VERSION: 1.0 - Retail Tab with Sub-tabs
// DATE: 2026-01-10

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

import 'super_admin_tablets.dart';
import 'super_admin_notifications.dart';
// SuperAdminApkTab is already in super_admin_tablets.dart

// ═══════════════════════════════════════════════════════════════════════════
// RETAIL TAB - Main Container for Retail Operations
// ═══════════════════════════════════════════════════════════════════════════

class SuperAdminRetailTab extends StatefulWidget {
  final String? brandFilter; // For Level 2 admins
  final int initialTab;

  const SuperAdminRetailTab({
    super.key,
    this.brandFilter,
    this.initialTab = 0,
  });

  @override
  State<SuperAdminRetailTab> createState() => _SuperAdminRetailTabState();
}

class _SuperAdminRetailTabState extends State<SuperAdminRetailTab>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west3');

  late TabController _subTabController;

  // Data
  List<Map<String, dynamic>> _owners = [];
  bool _isLoadingOwners = true;
  String _ownerFilter = 'all';
  String _searchQuery = '';

  // Stats
  int _totalOwners = 0;
  int _activeOwners = 0;
  int _pendingOwners = 0;
  int _totalUnits = 0;
  int _totalBookings = 0;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _loadOwners();
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DATA LOADING
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _loadOwners() async {
    if (!mounted) return;
    setState(() => _isLoadingOwners = true);

    try {
      Query query = _firestore.collection('tenant_links');

      // Filter by brand for Level 2 admins, or show only Vesta Lumina for retail
      if (widget.brandFilter != null) {
        query = query.where('brandId', isEqualTo: widget.brandFilter);
      } else {
        // Master admin in Retail tab - show only retail (Vesta Lumina)
        query = query.where('brandId', isEqualTo: 'vesta-lumina');
      }

      final snapshot = await query.get();

      List<Map<String, dynamic>> owners = [];
      int totalUnits = 0;
      int totalBookings = 0;
      int active = 0;
      int pending = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final tenantId = doc.id;

        int unitCount = 0;
        int bookingCount = 0;
        bool emailNotifications = true;

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

          final settingsDoc =
              await _firestore.collection('settings').doc(tenantId).get();
          if (settingsDoc.exists) {
            emailNotifications =
                settingsDoc.data()?['emailNotifications'] ?? true;
          }
        } catch (_) {}

        final status = data['status'] ?? 'pending';
        if (status == 'active') active++;
        if (status == 'pending') pending++;

        owners.add({
          'tenantId': tenantId,
          'email': data['email'] ?? '',
          'displayName': data['displayName'] ?? tenantId,
          'status': status,
          'createdAt': data['createdAt'],
          'unitCount': unitCount,
          'bookingCount': bookingCount,
          'emailNotifications': emailNotifications,
          'brandId': data['brandId'] ?? 'vesta-lumina',
          'type': data['type'] ?? 'retail',
        });
      }

      owners.sort((a, b) {
        final aDate = a['createdAt'] as Timestamp?;
        final bDate = b['createdAt'] as Timestamp?;
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate);
      });

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
      debugPrint('❌ Error loading owners: $e');
      if (mounted) setState(() => _isLoadingOwners = false);
    }
  }

  List<Map<String, dynamic>> get _filteredOwners {
    var filtered = _owners;

    if (_ownerFilter == 'active') {
      filtered = filtered.where((o) => o['status'] == 'active').toList();
    } else if (_ownerFilter == 'pending') {
      filtered = filtered.where((o) => o['status'] == 'pending').toList();
    } else if (_ownerFilter == 'suspended') {
      filtered = filtered.where((o) => o['status'] == 'suspended').toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((o) {
        final name = (o['displayName'] ?? '').toString().toLowerCase();
        final email = (o['email'] ?? '').toString().toLowerCase();
        final tenant = (o['tenantId'] ?? '').toString().toLowerCase();
        return name.contains(query) ||
            email.contains(query) ||
            tenant.contains(query);
      }).toList();
    }

    return filtered;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // OWNER ACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _createOwner() async {
    final t = context.read<AppProvider>().translate;
    final emailController = TextEditingController();
    final nameController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: [
            const Icon(Icons.person_add, color: Color(0xFFD4AF37)),
            const SizedBox(width: 12),
            Text(t('create_new_owner'),
                style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '${t('email')} *',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.email, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '${t('name')} *',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.person, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Color(0xFFD4AF37), size: 18),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Brand: Vesta Lumina (Retail)\nA temporary password will be generated.',
                        style:
                            TextStyle(color: Color(0xFFD4AF37), fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('btn_cancel'),
                style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isEmpty || nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t('msg_required_fields')),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(ctx, {
                'email': emailController.text.trim(),
                'name': nameController.text.trim(),
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
            ),
            child: Text(t('btn_create'),
                style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (result == null) return;

    try {
      final callable = _functions.httpsCallable('createOwner');
      final response = await callable.call({
        'email': result['email'],
        'displayName': result['name'],
        'brandId': 'vesta-lumina',
        'type': 'retail',
      });

      if (mounted) {
        final data = response.data as Map<String, dynamic>;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${t('owner_created')} ${t('temp_password')}: ${data['tempPassword']}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 10),
          ),
        );
        _loadOwners();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleOwnerStatus(Map<String, dynamic> owner) async {
    final currentStatus = owner['status'] ?? 'pending';
    final newStatus = currentStatus == 'active' ? 'suspended' : 'active';

    try {
      final callable = _functions.httpsCallable('toggleOwnerStatus');
      await callable.call({
        'tenantId': owner['tenantId'],
        'newStatus': newStatus,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Owner ${newStatus == 'active' ? 'activated' : 'suspended'}'),
            backgroundColor: Colors.green,
          ),
        );
        _loadOwners();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteOwner(Map<String, dynamic> owner) async {
    final t = context.read<AppProvider>().translate;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 12),
            Text(t('delete_owner_confirm'),
                style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'This will permanently delete "${owner['displayName']}" and all their data.\n\nThis action cannot be undone!',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t('btn_cancel'),
                style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(t('btn_delete'),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final callable = _functions.httpsCallable('deleteOwner');
      await callable.call({'tenantId': owner['tenantId']});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('owner_deleted')),
            backgroundColor: Colors.green,
          ),
        );
        _loadOwners();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _resetPassword(Map<String, dynamic> owner) async {
    try {
      final callable = _functions.httpsCallable('resetOwnerPassword');
      final response = await callable.call({'tenantId': owner['tenantId']});

      if (mounted) {
        final data = response.data as Map<String, dynamic>;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New password: ${data['newPassword']}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 10),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleEmailNotifications(Map<String, dynamic> owner) async {
    final currentValue = owner['emailNotifications'] ?? true;
    final newValue = !currentValue;

    try {
      await _firestore.collection('settings').doc(owner['tenantId']).update({
        'emailNotifications': newValue,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Email notifications ${newValue ? 'enabled' : 'disabled'}'),
            backgroundColor: Colors.green,
          ),
        );
        _loadOwners();
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
    return Column(
      children: [
        // Sub-tabs
        Container(
          color: const Color(0xFF1E1E1E),
          child: TabBar(
            controller: _subTabController,
            indicatorColor: const Color(0xFFD4AF37),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'Owners'),
              Tab(text: 'Tablets'),
              Tab(text: 'APK Updates'),
              Tab(text: 'Notifications'),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              _buildOwnersTab(),
              SuperAdminTabletsTab(owners: _owners),
              SuperAdminApkTab(owners: _owners),
              const SuperAdminNotificationsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOwnersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with stats
          Row(
            children: [
              const Icon(Icons.store, color: Color(0xFFD4AF37), size: 28),
              const SizedBox(width: 12),
              const Text(
                'Retail Owners',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _createOwner,
                icon: const Icon(Icons.add, size: 18),
                label: Text(context.read<AppProvider>().translate('new_owner')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _statCard('Total', '$_totalOwners', Icons.people, Colors.blue),
              _statCard(
                  'Active', '$_activeOwners', Icons.check_circle, Colors.green),
              _statCard(
                  'Pending', '$_pendingOwners', Icons.pending, Colors.orange),
              _statCard(
                  'Units', '$_totalUnits', Icons.apartment, Colors.purple),
              _statCard('Bookings', '$_totalBookings', Icons.calendar_month,
                  Colors.cyan),
            ],
          ),
          const SizedBox(height: 24),

          // Search and filters
          Row(
            children: [
              // Search
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search owners...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Filters
              _filterChip('All', 'all'),
              const SizedBox(width: 8),
              _filterChip('Active', 'active'),
              const SizedBox(width: 8),
              _filterChip('Pending', 'pending'),
              const SizedBox(width: 8),
              _filterChip('Suspended', 'suspended'),
              const SizedBox(width: 16),
              // Refresh
              IconButton(
                onPressed: _loadOwners,
                icon: const Icon(Icons.refresh, color: Colors.grey),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Owners list
          _isLoadingOwners
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
              : _filteredOwners.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox,
                              size: 64,
                              color: Colors.grey.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          const Text('No owners found',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredOwners.length,
                      itemBuilder: (ctx, i) => _ownerCard(_filteredOwners[i]),
                    ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _ownerFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _ownerFilter = value),
      selectedColor: const Color(0xFFD4AF37).withValues(alpha: 0.3),
      checkmarkColor: const Color(0xFFD4AF37),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFFD4AF37) : Colors.grey,
      ),
      backgroundColor: const Color(0xFF2A2A2A),
      side: BorderSide(
        color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
      ),
    );
  }

  Widget _ownerCard(Map<String, dynamic> owner) {
    final status = owner['status'] ?? 'pending';
    final statusColor = status == 'active'
        ? Colors.green
        : status == 'pending'
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            backgroundColor: statusColor.withValues(alpha: 0.2),
            child: Text(
              (owner['displayName'] ?? 'U')[0].toUpperCase(),
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      owner['displayName'] ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  owner['email'] ?? '',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _infoChip(Icons.apartment, '${owner['unitCount']} units'),
                    const SizedBox(width: 8),
                    _infoChip(Icons.calendar_month,
                        '${owner['bookingCount']} bookings'),
                    const SizedBox(width: 8),
                    _infoChip(
                      owner['emailNotifications'] == true
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      owner['emailNotifications'] == true
                          ? 'Email ON'
                          : 'Email OFF',
                      color: owner['emailNotifications'] == true
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  owner['emailNotifications'] == true
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: owner['emailNotifications'] == true
                      ? Colors.green
                      : Colors.grey,
                ),
                onPressed: () => _toggleEmailNotifications(owner),
                tooltip: 'Toggle Email Notifications',
              ),
              IconButton(
                icon: const Icon(Icons.key, color: Colors.orange),
                onPressed: () => _resetPassword(owner),
                tooltip: 'Reset Password',
              ),
              IconButton(
                icon: Icon(
                  status == 'active' ? Icons.pause : Icons.play_arrow,
                  color: status == 'active' ? Colors.orange : Colors.green,
                ),
                onPressed: () => _toggleOwnerStatus(owner),
                tooltip: status == 'active' ? 'Suspend' : 'Activate',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteOwner(owner),
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, {Color color = Colors.grey}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }
}
