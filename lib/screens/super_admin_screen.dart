// FILE: lib/screens/super_admin_screen.dart
// OPIS: Super Admin Dashboard - SAMO za nevenroksa@gmail.com
// VERSION: 2.1 - Fixed all deprecation warnings
// FEATURES:
//   - Owner Management (CRUD, Status Toggle, Password Reset)
//   - Search & Filter
//   - Tablet Management (Online/Offline, Groups, Mass APK Updates)
//   - Activity Log
//   - Statistics (Owners, Units, Bookings, Tablets)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  List<Map<String, dynamic>> _tablets = [];
  List<Map<String, dynamic>> _activityLogs = [];

  bool _isLoadingOwners = true;
  bool _isLoadingTablets = true;
  bool _isLoadingLogs = true;

  String _ownerFilter = 'all';
  String _tabletFilter = 'all';
  String _searchQuery = '';

  int _totalOwners = 0;
  int _activeOwners = 0;
  int _pendingOwners = 0;
  int _totalUnits = 0;
  int _totalBookings = 0;
  int _totalTablets = 0;
  int _onlineTablets = 0;

  String _currentApkVersion = '';
  String _latestApkUrl = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadOwners(),
      _loadTablets(),
      _loadActivityLogs(),
      _loadApkVersion(),
    ]);
  }

  // =============================================================================
  // LOAD OWNERS
  // =============================================================================
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
          final unitsSnapshot = await _firestore
              .collection('units')
              .where('ownerId', isEqualTo: tenantId)
              .get();
          unitCount = unitsSnapshot.size;
          totalUnits += unitCount;

          final bookingsSnapshot = await _firestore
              .collection('bookings')
              .where('ownerId', isEqualTo: tenantId)
              .get();
          bookingCount = bookingsSnapshot.size;
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
        _showError('Error loading owners: $e');
      }
    }
  }

  // =============================================================================
  // LOAD TABLETS
  // =============================================================================
  Future<void> _loadTablets() async {
    if (!mounted) return;
    setState(() => _isLoadingTablets = true);

    try {
      final snapshot = await _firestore.collection('tablets').get();

      List<Map<String, dynamic>> tablets = [];
      int online = 0;
      final now = DateTime.now();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final lastHeartbeat = data['lastHeartbeat'] as Timestamp?;

        bool isOnline = false;
        if (lastHeartbeat != null) {
          final diff = now.difference(lastHeartbeat.toDate());
          isOnline = diff.inMinutes < 5;
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
          'group': data['group'] ?? 'default',
          'model': data['model'] ?? 'Unknown',
          'osVersion': data['osVersion'] ?? 'Unknown',
          'pendingUpdate': data['pendingUpdate'] ?? false,
          'pendingVersion': data['pendingVersion'] ?? '',
        });
      }

      if (mounted) {
        setState(() {
          _tablets = tablets;
          _totalTablets = tablets.length;
          _onlineTablets = online;
          _isLoadingTablets = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTablets = false);
        _showError('Error loading tablets: $e');
      }
    }
  }

  // =============================================================================
  // LOAD ACTIVITY LOGS
  // =============================================================================
  Future<void> _loadActivityLogs() async {
    if (!mounted) return;
    setState(() => _isLoadingLogs = true);

    try {
      final snapshot = await _firestore
          .collection('admin_logs')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      List<Map<String, dynamic>> logs = [];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        logs.add({
          'id': doc.id,
          'action': data['action'] ?? 'Unknown',
          'targetId': data['targetId'] ?? '',
          'targetEmail': data['targetEmail'] ?? '',
          'details': data['details'] ?? '',
          'timestamp': data['timestamp'],
          'performedBy': data['performedBy'] ?? 'System',
        });
      }

      if (mounted) {
        setState(() {
          _activityLogs = logs;
          _isLoadingLogs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _activityLogs = [];
          _isLoadingLogs = false;
        });
      }
    }
  }

  // =============================================================================
  // LOAD APK VERSION
  // =============================================================================
  Future<void> _loadApkVersion() async {
    try {
      final doc =
          await _firestore.collection('app_config').doc('tablet_app').get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _currentApkVersion = data['currentVersion'] ?? '1.0.0';
          _latestApkUrl = data['apkUrl'] ?? '';
        });
      }
    } catch (_) {}
  }

  // =============================================================================
  // LOG ACTIVITY
  // =============================================================================
  Future<void> _logActivity(String action, String targetId, String targetEmail,
      String details) async {
    try {
      await _firestore.collection('admin_logs').add({
        'action': action,
        'targetId': targetId,
        'targetEmail': targetEmail,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
        'performedBy': 'Super Admin',
      });
    } catch (_) {}
  }

  // =============================================================================
  // CREATE OWNER
  // =============================================================================
  Future<void> _showCreateOwnerDialog() async {
    final tenantIdController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final displayNameController = TextEditingController();

    final result = await showDialog<Map<String, String>?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Row(
            children: [
              Icon(Icons.person_add, color: Color(0xFFD4AF37)),
              SizedBox(width: 10),
              Text('Create New Owner', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    controller: tenantIdController,
                    label: 'Tenant ID *',
                    hint: 'e.g., ROKSA123 (6-12 chars, A-Z, 0-9)',
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: emailController,
                    label: 'Email *',
                    hint: 'owner@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: passwordController,
                          label: 'Password *',
                          hint: 'Min 6 characters',
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          passwordController.text = _generatePassword();
                          setDialogState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                        ),
                        child: const Text('Generate',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: displayNameController,
                    label: 'Display Name (Optional)',
                    hint: 'e.g., John Doe',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final tenantId = tenantIdController.text.trim().toUpperCase();
                final email = emailController.text.trim();
                final password = passwordController.text;
                final displayName = displayNameController.text.trim();

                if (tenantId.isEmpty || email.isEmpty || password.isEmpty) {
                  _showError('Please fill in all required fields');
                  return;
                }

                if (!RegExp(r'^[A-Z0-9]{6,12}$').hasMatch(tenantId)) {
                  _showError(
                      'Invalid Tenant ID format (6-12 uppercase letters/numbers)');
                  return;
                }

                if (password.length < 6) {
                  _showError('Password must be at least 6 characters');
                  return;
                }

                Navigator.pop(ctx, {
                  'tenantId': tenantId,
                  'email': email,
                  'password': password,
                  'displayName': displayName.isNotEmpty
                      ? displayName
                      : email.split('@')[0],
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
      ),
    );

    if (result != null && mounted) {
      try {
        final funcResult =
            await _functions.httpsCallable('createOwner').call(result);

        await _logActivity('CREATE_OWNER', result['tenantId']!,
            result['email']!, 'Created new owner account');

        if (mounted) {
          _showSuccessDialog(
            '✅ Owner Created!\n\n'
            '📧 Email: ${funcResult.data['email']}\n'
            '🆔 Tenant ID: ${funcResult.data['tenantId']}\n'
            '🔑 Password: ${result['password']}\n\n'
            '⚠️ Send credentials to owner!',
          );
          _loadOwners();
          _loadActivityLogs();
        }
      } catch (e) {
        if (mounted) _showError('Error: $e');
      }
    }
  }

  // =============================================================================
  // VIEW OWNER DETAILS
  // =============================================================================
  void _showOwnerDetailsDialog(Map<String, dynamic> owner) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFFD4AF37)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                owner['displayName'] ?? owner['tenantId'],
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Tenant ID', owner['tenantId'], isHighlight: true),
                _detailRow('Email', owner['email']),
                _detailRow('Display Name', owner['displayName']),
                _detailRow('Status', owner['status'], isStatus: true),
                _detailRow('Firebase UID', owner['firebaseUid'] ?? 'N/A',
                    isMono: true),
                const Divider(color: Colors.grey, height: 24),
                _detailRow('Units', '${owner['unitCount']}'),
                _detailRow('Bookings', '${owner['bookingCount']}'),
                _detailRow('Created', _formatDate(owner['createdAt'])),
                _detailRow(
                    'Linked',
                    owner['linkedAt'] != null
                        ? _formatDate(owner['linkedAt'])
                        : 'Not yet'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _resetPassword(owner['tenantId'], owner['email']);
            },
            icon: const Icon(Icons.key, size: 18),
            label: const Text('Reset Password'),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  // =============================================================================
  // RESET PASSWORD
  // =============================================================================
  Future<void> _resetPassword(String tenantId, String email) async {
    final passwordController = TextEditingController();

    final newPassword = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title:
            const Text('Reset Password', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reset password for "$tenantId"',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            _buildTextField(
              controller: passwordController,
              label: 'New Password',
              hint: 'Min 6 characters',
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => passwordController.text = _generatePassword(),
              child: const Text('🎲 Generate Strong Password',
                  style: TextStyle(color: Color(0xFFD4AF37))),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (passwordController.text.length >= 6) {
                Navigator.pop(ctx, passwordController.text);
              } else {
                _showError('Password must be at least 6 characters');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (newPassword != null && mounted) {
      try {
        await _functions.httpsCallable('resetOwnerPassword').call({
          'tenantId': tenantId,
          'newPassword': newPassword,
        });
        await _logActivity(
            'RESET_PASSWORD', tenantId, email, 'Password reset by Super Admin');
        if (mounted) {
          _showSuccessDialog(
              '✅ Password reset for $tenantId\n\nNew password: $newPassword');
          _loadActivityLogs();
        }
      } catch (e) {
        if (mounted) _showError('Error: $e');
      }
    }
  }

  // =============================================================================
  // TOGGLE STATUS
  // =============================================================================
  Future<void> _toggleStatus(
      String tenantId, String currentStatus, String email) async {
    final newStatus = currentStatus == 'active' ? 'suspended' : 'active';
    final action = newStatus == 'active' ? 'ACTIVATE' : 'SUSPEND';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title:
            Text('$action Owner?', style: const TextStyle(color: Colors.white)),
        content: Text(
          newStatus == 'suspended'
              ? '⚠️ Owner will be logged out and cannot access the panel.\n\nTenant ID: $tenantId'
              : '✅ Owner will be able to login again.\n\nTenant ID: $tenantId',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  newStatus == 'active' ? Colors.green : Colors.red,
            ),
            child: Text(action, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _functions.httpsCallable('toggleOwnerStatus').call({
          'tenantId': tenantId,
          'status': newStatus,
        });
        await _logActivity('${action}_OWNER', tenantId, email,
            'Owner ${newStatus == "active" ? "activated" : "suspended"}');
        if (mounted) {
          _showSnack(
              '✅ Owner ${newStatus == 'active' ? 'activated' : 'suspended'}!',
              Colors.green);
          _loadOwners();
          _loadActivityLogs();
        }
      } catch (e) {
        if (mounted) _showError('Error: $e');
      }
    }
  }

  // =============================================================================
  // DELETE OWNER
  // =============================================================================
  Future<void> _deleteOwner(String tenantId, String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 10),
            Text('DELETE OWNER?', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Text(
          '⚠️ This will PERMANENTLY delete:\n'
          '  • Owner account\n'
          '  • Settings document\n'
          '  • Authentication data\n\n'
          'Units and bookings will NOT be deleted.\n\n'
          'Tenant ID: $tenantId\n\n'
          '🔴 THIS CANNOT BE UNDONE!',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final confirmController = TextEditingController();
    final doubleConfirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Type Tenant ID to confirm',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: confirmController,
          style: const TextStyle(color: Colors.white),
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: tenantId,
            hintStyle: const TextStyle(color: Colors.grey),
            border: const OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (confirmController.text.toUpperCase() ==
                  tenantId.toUpperCase()) {
                Navigator.pop(ctx, true);
              } else {
                _showError('Tenant ID does not match');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('CONFIRM DELETE',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (doubleConfirmed == true && mounted) {
      try {
        await _functions
            .httpsCallable('deleteOwner')
            .call({'tenantId': tenantId});
        await _logActivity(
            'DELETE_OWNER', tenantId, email, 'Owner permanently deleted');
        if (mounted) {
          _showSnack('✅ Owner $tenantId deleted!', Colors.green);
          _loadOwners();
          _loadActivityLogs();
        }
      } catch (e) {
        if (mounted) _showError('Error: $e');
      }
    }
  }

  // =============================================================================
  // APK UPDATE MANAGEMENT - MASS UPDATE
  // =============================================================================
  Future<void> _showApkUpdateDialog() async {
    final versionController = TextEditingController(text: _currentApkVersion);
    final urlController = TextEditingController(text: _latestApkUrl);
    String selectedGroup = 'all';
    bool forceUpdate = false;

    final groups = ['all', 'default', 'beta', 'test', 'production'];

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Row(
            children: [
              Icon(Icons.system_update, color: Color(0xFFD4AF37)),
              SizedBox(width: 10),
              Text('Push APK Update', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color:
                              const Color(0xFF1565C0).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Color(0xFF1565C0), size: 20),
                        const SizedBox(width: 10),
                        Text('Current deployed: $_currentApkVersion',
                            style: const TextStyle(color: Color(0xFF1565C0))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: versionController,
                    label: 'New Version *',
                    hint: 'e.g., 1.0.1',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: urlController,
                    label: 'APK Download URL *',
                    hint: 'https://storage.googleapis.com/.../app.apk',
                  ),
                  const SizedBox(height: 16),
                  const Text('Target Group',
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
                        value: selectedGroup,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF2C2C2C),
                        style: const TextStyle(color: Colors.white),
                        items: groups
                            .map((g) => DropdownMenuItem(
                                  value: g,
                                  child: Text(g == 'all'
                                      ? '🌍 All Tablets'
                                      : '📱 Group: $g'),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setDialogState(() => selectedGroup = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: forceUpdate,
                        onChanged: (v) =>
                            setDialogState(() => forceUpdate = v ?? false),
                        activeColor: const Color(0xFFD4AF37),
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Force Update',
                                style: TextStyle(color: Colors.white)),
                            Text('Tablet will auto-download and install',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<int>(
                    future: _countAffectedTablets(selectedGroup),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.devices,
                                color: Color(0xFFFF9800), size: 20),
                            const SizedBox(width: 10),
                            Text('$count tablet(s) will receive this update',
                                style:
                                    const TextStyle(color: Color(0xFFFF9800))),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (versionController.text.isEmpty ||
                    urlController.text.isEmpty) {
                  _showError('Please fill in version and URL');
                  return;
                }
                Navigator.pop(ctx, {
                  'version': versionController.text,
                  'url': urlController.text,
                  'group': selectedGroup,
                  'force': forceUpdate,
                });
              },
              icon: const Icon(Icons.cloud_upload, size: 18),
              label: const Text('Push Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      try {
        await _firestore.collection('app_config').doc('tablet_app').set({
          'currentVersion': result['version'],
          'apkUrl': result['url'],
          'updatedAt': FieldValue.serverTimestamp(),
          'targetGroup': result['group'],
          'forceUpdate': result['force'],
        }, SetOptions(merge: true));

        final batch = _firestore.batch();

        Query<Map<String, dynamic>> query = _firestore.collection('tablets');
        if (result['group'] != 'all') {
          query = query.where('group', isEqualTo: result['group']);
        }

        final tablets = await query.get();
        for (final tablet in tablets.docs) {
          batch.update(tablet.reference, {
            'pendingUpdate': true,
            'pendingVersion': result['version'],
            'pendingApkUrl': result['url'],
            'forceUpdate': result['force'],
            'updatePushedAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();

        await _logActivity('PUSH_APK_UPDATE', result['group'], '',
            'Version ${result['version']} pushed to ${tablets.size} tablet(s)${result['force'] ? ' (FORCED)' : ''}');

        if (mounted) {
          _showSuccessDialog(
            '✅ APK Update Pushed!\n\n'
            'Version: ${result['version']}\n'
            'Group: ${result['group']}\n'
            'Tablets: ${tablets.size}\n'
            'Force Update: ${result['force'] ? 'Yes' : 'No'}',
          );
          _loadApkVersion();
          _loadTablets();
          _loadActivityLogs();
        }
      } catch (e) {
        if (mounted) _showError('Error: $e');
      }
    }
  }

  Future<int> _countAffectedTablets(String group) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('tablets');
      if (group != 'all') {
        query = query.where('group', isEqualTo: group);
      }
      final snapshot = await query.get();
      return snapshot.size;
    } catch (_) {
      return 0;
    }
  }

  // =============================================================================
  // TABLET GROUP MANAGEMENT
  // =============================================================================
  Future<void> _changeTabletGroup(Map<String, dynamic> tablet) async {
    String selectedGroup = tablet['group'] ?? 'default';
    final groups = ['default', 'beta', 'test', 'production'];

    final newGroup = await showDialog<String?>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text('Change Group: ${tablet['unitName']}',
              style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: groups
                .map((g) => ListTile(
                      leading: Icon(
                        selectedGroup == g
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: selectedGroup == g
                            ? const Color(0xFFD4AF37)
                            : Colors.grey,
                      ),
                      title:
                          Text(g, style: const TextStyle(color: Colors.white)),
                      onTap: () => setDialogState(() => selectedGroup = g),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, selectedGroup),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37)),
              child: const Text('Save', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );

    if (newGroup != null && mounted) {
      await _firestore.collection('tablets').doc(tablet['deviceId']).update({
        'group': newGroup,
      });
      _showSnack('✅ Tablet moved to group: $newGroup', Colors.green);
      _loadTablets();
    }
  }

  // =============================================================================
  // HELPERS
  // =============================================================================
  String _generatePassword() {
    const chars =
        'ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789!@#\$%^&*';
    String password = '';
    final rand = DateTime.now().microsecondsSinceEpoch;
    for (int i = 0; i < 16; i++) {
      password += chars[(rand + i * 7) % chars.length];
    }
    return password;
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      return timestamp.toDate().toString().substring(0, 16);
    }
    return timestamp.toString();
  }

  String _timeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Never';
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else {
      return 'Unknown';
    }

    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _showSuccessDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        content: Text(message, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
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
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD4AF37)),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value,
      {bool isHighlight = false, bool isStatus = false, bool isMono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          if (isStatus)
            _statusBadge(value)
          else
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  color: isHighlight ? const Color(0xFFD4AF37) : Colors.white,
                  fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                  fontFamily: isMono ? 'monospace' : null,
                  fontSize: isMono ? 11 : 14,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'suspended':
        color = Colors.red;
        break;
      case 'online':
        color = Colors.green;
        break;
      case 'offline':
        color = Colors.grey;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredOwners {
    var list = _owners;

    if (_ownerFilter != 'all') {
      list = list.where((o) => o['status'] == _ownerFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list
          .where((o) =>
              (o['tenantId']?.toString().toLowerCase().contains(query) ??
                  false) ||
              (o['email']?.toString().toLowerCase().contains(query) ?? false) ||
              (o['displayName']?.toString().toLowerCase().contains(query) ??
                  false))
          .toList();
    }

    return list;
  }

  List<Map<String, dynamic>> get _filteredTablets {
    var list = _tablets;

    if (_tabletFilter == 'online') {
      list = list.where((t) => t['isOnline'] == true).toList();
    } else if (_tabletFilter == 'offline') {
      list = list.where((t) => t['isOnline'] != true).toList();
    } else if (_tabletFilter != 'all') {
      list = list.where((t) => t['group'] == _tabletFilter).toList();
    }

    return list;
  }

  Map<String, int> _getTabletGroups() {
    final groups = <String, int>{};
    for (final tablet in _tablets) {
      final group = tablet['group'] ?? 'default';
      groups[group] = (groups[group] ?? 0) + 1;
    }
    return groups;
  }

  // =============================================================================
  // BUILD
  // =============================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14141E),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings,
                color: Color(0xFFD4AF37), size: 28),
            SizedBox(width: 12),
            Text(
              'SUPER ADMIN',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFD4AF37),
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Owners'),
            Tab(icon: Icon(Icons.tablet_android), text: 'Tablets'),
            Tab(icon: Icon(Icons.history), text: 'Activity'),
            Tab(icon: Icon(Icons.system_update), text: 'Updates'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAllData,
            tooltip: 'Refresh All',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  title: const Text('Logout?',
                      style: TextStyle(color: Colors.white)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await FirebaseAuth.instance.signOut();
              }
            },
            tooltip: 'Logout',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOwnersTab(),
          _buildTabletsTab(),
          _buildActivityTab(),
          _buildUpdatesTab(),
        ],
      ),
    );
  }

  // =============================================================================
  // TAB 1: OWNERS
  // =============================================================================
  Widget _buildOwnersTab() {
    return RefreshIndicator(
      onRefresh: _loadOwners,
      color: const Color(0xFFD4AF37),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _statCard(
                  'Total Owners', '$_totalOwners', Icons.people, Colors.blue),
              _statCard(
                  'Active', '$_activeOwners', Icons.check_circle, Colors.green),
              _statCard('Pending', '$_pendingOwners', Icons.hourglass_empty,
                  Colors.orange),
              _statCard(
                  'Total Units', '$_totalUnits', Icons.home, Colors.purple),
              _statCard('Total Bookings', '$_totalBookings',
                  Icons.calendar_today, Colors.teal),
            ],
          ),
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
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              _filterChip('All', 'all', isOwner: true),
              _filterChip('Active', 'active', isOwner: true),
              _filterChip('Pending', 'pending', isOwner: true),
              _filterChip('Suspended', 'suspended', isOwner: true),
              ElevatedButton.icon(
                onPressed: _showCreateOwnerDialog,
                icon: const Icon(Icons.add, color: Colors.black),
                label: const Text('NEW OWNER',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoadingOwners
              ? const Center(
                  child: Padding(
                  padding: EdgeInsets.all(60),
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                ))
              : Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: _filteredOwners.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(60),
                          child: Center(
                            child: Text('No owners found',
                                style: TextStyle(color: Colors.grey)),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredOwners.length,
                          separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: Colors.grey.withValues(alpha: 0.2)),
                          itemBuilder: (context, index) =>
                              _ownerRow(_filteredOwners[index]),
                        ),
                ),
        ],
      ),
    );
  }

  // =============================================================================
  // TAB 2: TABLETS
  // =============================================================================
  Widget _buildTabletsTab() {
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
              _statCard('Total Tablets', '$_totalTablets', Icons.tablet_android,
                  Colors.blue),
              _statCard('Online', '$_onlineTablets', Icons.wifi, Colors.green),
              _statCard('Offline', '${_totalTablets - _onlineTablets}',
                  Icons.wifi_off, Colors.red),
              _statCard(
                  'Current APK',
                  _currentApkVersion.isEmpty ? 'N/A' : _currentApkVersion,
                  Icons.android,
                  Colors.teal),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _filterChip('All', 'all', isOwner: false),
              _filterChip('Online', 'online', isOwner: false),
              _filterChip('Offline', 'offline', isOwner: false),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showApkUpdateDialog,
                icon: const Icon(Icons.system_update, color: Colors.black),
                label: const Text('PUSH UPDATE',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoadingTablets
              ? const Center(
                  child: Padding(
                  padding: EdgeInsets.all(60),
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                ))
              : _filteredTablets.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(60),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(Icons.tablet_android,
                                color: Colors.grey, size: 60),
                            SizedBox(height: 16),
                            Text('No tablets registered yet',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 350,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: _filteredTablets.length,
                      itemBuilder: (context, index) =>
                          _tabletCard(_filteredTablets[index]),
                    ),
        ],
      ),
    );
  }

  // =============================================================================
  // TAB 3: ACTIVITY LOG
  // =============================================================================
  Widget _buildActivityTab() {
    return RefreshIndicator(
      onRefresh: _loadActivityLogs,
      color: const Color(0xFFD4AF37),
      child: _isLoadingLogs
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : _activityLogs.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 100),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, color: Colors.grey, size: 60),
                          SizedBox(height: 16),
                          Text('No activity logs yet',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _activityLogs.length,
                  itemBuilder: (context, index) =>
                      _activityLogItem(_activityLogs[index]),
                ),
    );
  }

  // =============================================================================
  // TAB 4: APK UPDATES
  // =============================================================================
  Widget _buildUpdatesTab() {
    return ListView(
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
              const Row(
                children: [
                  Icon(Icons.android, color: Color(0xFFD4AF37), size: 32),
                  SizedBox(width: 12),
                  Text('Current Deployed Version',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Text(_currentApkVersion.isEmpty ? 'Not set' : _currentApkVersion,
                  style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 36,
                      fontWeight: FontWeight.w800)),
              if (_latestApkUrl.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'URL: $_latestApkUrl',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showApkUpdateDialog,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Push New Version'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Tablets by Group',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ..._getTabletGroups().entries.map((entry) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.folder, color: Colors.blue),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            entry.key == 'default'
                                ? 'Default Group'
                                : 'Group: ${entry.key}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text('${entry.value} tablet(s)',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _tabletFilter = entry.key;
                        _tabController.animateTo(1);
                      });
                    },
                    child: const Text('View',
                        style: TextStyle(color: Color(0xFFD4AF37))),
                  ),
                ],
              ),
            )),
        if (_getTabletGroups().isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('No tablet groups yet',
                  style: TextStyle(color: Colors.grey)),
            ),
          ),
      ],
    );
  }

  // =============================================================================
  // WIDGET BUILDERS
  // =============================================================================
  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 170,
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
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value, {required bool isOwner}) {
    final isSelected = isOwner ? _ownerFilter == value : _tabletFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() {
        if (isOwner) {
          _ownerFilter = value;
        } else {
          _tabletFilter = value;
        }
      }),
      selectedColor: const Color(0xFFD4AF37).withValues(alpha: 0.3),
      checkmarkColor: const Color(0xFFD4AF37),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFFD4AF37) : Colors.grey,
        fontSize: 13,
      ),
      backgroundColor: const Color(0xFF2A2A2A),
      side: BorderSide(
        color: isSelected
            ? const Color(0xFFD4AF37)
            : Colors.grey.withValues(alpha: 0.3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _ownerRow(Map<String, dynamic> owner) {
    return InkWell(
      onTap: () => _showOwnerDetailsDialog(owner),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFD4AF37).withValues(alpha: 0.2),
              radius: 20,
              child: Text(
                (owner['displayName'] ?? owner['tenantId'])[0].toUpperCase(),
                style: const TextStyle(
                    color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    owner['displayName'] ?? 'N/A',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${owner['tenantId']} • ${owner['email']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${owner['unitCount']} units',
                style: const TextStyle(color: Colors.purple, fontSize: 10),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${owner['bookingCount']} res',
                style: const TextStyle(color: Colors.teal, fontSize: 10),
              ),
            ),
            const SizedBox(width: 10),
            _statusBadge(owner['status']),
            const SizedBox(width: 6),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
              color: const Color(0xFF2A2A2A),
              onSelected: (value) {
                switch (value) {
                  case 'details':
                    _showOwnerDetailsDialog(owner);
                    break;
                  case 'toggle':
                    _toggleStatus(
                        owner['tenantId'], owner['status'], owner['email']);
                    break;
                  case 'reset':
                    _resetPassword(owner['tenantId'], owner['email']);
                    break;
                  case 'delete':
                    _deleteOwner(owner['tenantId'], owner['email']);
                    break;
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'details',
                    child: Text('👁️ View Details',
                        style: TextStyle(color: Colors.white))),
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(
                    owner['status'] == 'active' ? '⏸️ Suspend' : '▶️ Activate',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const PopupMenuItem(
                    value: 'reset',
                    child: Text('🔑 Reset Password',
                        style: TextStyle(color: Colors.white))),
                const PopupMenuDivider(),
                const PopupMenuItem(
                    value: 'delete',
                    child: Text('🗑️ Delete',
                        style: TextStyle(color: Colors.red))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabletCard(Map<String, dynamic> tablet) {
    final isOnline = tablet['isOnline'] == true;
    final hasPendingUpdate = tablet['pendingUpdate'] == true;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOnline
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOnline ? Icons.wifi : Icons.wifi_off,
                color: isOnline ? Colors.green : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tablet['unitName'] ?? 'Unknown',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasPendingUpdate)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('UPDATE',
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 8,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Owner: ${tablet['ownerName']}',
              style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text('Version: ${tablet['appVersion']}',
              style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text('Group: ${tablet['group']}',
              style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOnline
                    ? '🟢 Online'
                    : '⚫ ${_timeAgo(tablet['lastHeartbeat'])}',
                style: TextStyle(
                    color: isOnline ? Colors.green : Colors.grey, fontSize: 10),
              ),
              TextButton(
                onPressed: () => _changeTabletGroup(tablet),
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, minimumSize: const Size(40, 24)),
                child: const Text('Group',
                    style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activityLogItem(Map<String, dynamic> log) {
    IconData icon;
    Color color;

    switch (log['action']) {
      case 'CREATE_OWNER':
        icon = Icons.person_add;
        color = Colors.green;
        break;
      case 'DELETE_OWNER':
        icon = Icons.person_remove;
        color = Colors.red;
        break;
      case 'SUSPEND_OWNER':
        icon = Icons.block;
        color = Colors.orange;
        break;
      case 'ACTIVATE_OWNER':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'RESET_PASSWORD':
        icon = Icons.key;
        color = Colors.blue;
        break;
      case 'PUSH_APK_UPDATE':
        icon = Icons.system_update;
        color = Colors.purple;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log['action'].toString().replaceAll('_', ' '),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
                if (log['targetId'].toString().isNotEmpty)
                  Text('Target: ${log['targetId']}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                if (log['details'].toString().isNotEmpty)
                  Text(log['details'],
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Text(
            _timeAgo(log['timestamp']),
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
