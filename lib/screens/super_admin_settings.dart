// FILE: lib/screens/super_admin_settings.dart
// VERSION: 1.0 - Settings Tab with Admin Management & Brand Editor
// DATE: 2026-01-10

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../services/brand_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SETTINGS TAB - Super Admins, Default Brand, Backups, Logs
// ═══════════════════════════════════════════════════════════════════════════

class SuperAdminSettingsTab extends StatefulWidget {
  const SuperAdminSettingsTab({super.key});

  @override
  State<SuperAdminSettingsTab> createState() => _SuperAdminSettingsTabState();
}

class _SuperAdminSettingsTabState extends State<SuperAdminSettingsTab>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west3');
  final BrandService _brandService = BrandService();

  late TabController _subTabController;

  // Data
  List<Map<String, dynamic>> _superAdmins = [];
  List<Map<String, dynamic>> _logs = [];
  Brand? _defaultBrand;
  bool _isLoading = true;

  // Brand Edit Controllers
  final _brandNameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _supportEmailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _logoUrlController = TextEditingController();
  String _brandPrimaryColor = '#D4AF37';

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _subTabController.dispose();
    _brandNameController.dispose();
    _taglineController.dispose();
    _supportEmailController.dispose();
    _websiteController.dispose();
    _logoUrlController.dispose();
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
        _loadSuperAdmins(),
        _loadDefaultBrand(),
        _loadLogs(),
      ]);

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('❌ Error loading settings data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSuperAdmins() async {
    final snapshot = await _firestore.collection('super_admins').get();

    _superAdmins = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'email': doc.id,
        'level': data['level'] ?? 2,
        'brandId': data['brandId'],
        'active': data['active'] ?? true,
        'createdAt': data['createdAt'],
        'createdBy': data['createdBy'] ?? 'unknown',
      };
    }).toList();

    _superAdmins.sort((a, b) {
      // Sort by level (3 first), then by email
      final levelCompare = (b['level'] as int).compareTo(a['level'] as int);
      if (levelCompare != 0) return levelCompare;
      return (a['email'] as String).compareTo(b['email'] as String);
    });
  }

  Future<void> _loadDefaultBrand() async {
    _defaultBrand = await _brandService.getDefaultBrand();

    if (_defaultBrand != null) {
      _brandNameController.text = _defaultBrand!.name;
      _taglineController.text = _defaultBrand!.tagline;
      _supportEmailController.text = _defaultBrand!.supportEmail;
      _websiteController.text = _defaultBrand!.websiteUrl;
      _logoUrlController.text = _defaultBrand!.logoUrl;
      _brandPrimaryColor = _defaultBrand!.primaryColor;
    }
  }

  Future<void> _loadLogs() async {
    final snapshot = await _firestore
        .collection('admin_logs')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .get();

    _logs = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'action': data['action'] ?? '',
        'adminEmail': data['adminEmail'] ?? '',
        'details': data['details'] ?? {},
        'timestamp': data['timestamp'],
      };
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUPER ADMIN ACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _addSuperAdmin() async {
    final emailController = TextEditingController();
    String selectedBrandId = '';
    int selectedLevel = 2;

    // Load brands for dropdown
    final brands = await _brandService.getAllBrands();

    if (!mounted) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Color(0xFFD4AF37)),
              SizedBox(width: 12),
              Text('Add Super Admin',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Email *', Icons.email),
                ),
                const SizedBox(height: 16),

                // Level
                const Text('Admin Level',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _levelOption(
                        'Level 2 - Brand Admin',
                        'Can manage one brand',
                        2,
                        selectedLevel,
                        (v) => setDialogState(() => selectedLevel = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _levelOption(
                        'Level 3 - Master',
                        'Full access to everything',
                        3,
                        selectedLevel,
                        (v) => setDialogState(() => selectedLevel = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Brand (only for Level 2)
                if (selectedLevel == 2) ...[
                  const Text('Assigned Brand',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: selectedBrandId.isEmpty ? null : selectedBrandId,
                      hint: const Text('Select brand',
                          style: TextStyle(color: Colors.grey)),
                      dropdownColor: const Color(0xFF2A2A2A),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: brands.map((b) {
                        return DropdownMenuItem(
                          value: b.id,
                          child: Text(b.name,
                              style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (v) =>
                          setDialogState(() => selectedBrandId = v ?? ''),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (emailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email is required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (selectedLevel == 2 && selectedBrandId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a brand for Level 2 admin'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx, {
                  'email': emailController.text.trim().toLowerCase(),
                  'level': selectedLevel,
                  'brandId': selectedLevel == 2 ? selectedBrandId : null,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
              ),
              child: const Text('Add', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;

    try {
      final callable = _functions.httpsCallable('addSuperAdmin');
      await callable.call(result);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Super Admin added!'),
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

  Widget _levelOption(String title, String subtitle, int level,
      int selectedLevel, Function(int) onSelect) {
    final isSelected = selectedLevel == level;
    final color = level == 3 ? Colors.purple : Colors.blue;

    return GestureDetector(
      onTap: () => onSelect(level),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  level == 3 ? Icons.shield : Icons.admin_panel_settings,
                  color: isSelected ? color : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? color : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleAdminStatus(Map<String, dynamic> admin) async {
    if (admin['email'] == 'vestaluminasystem@gmail.com') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot modify Master Master account'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newStatus = !(admin['active'] ?? true);

    try {
      await _firestore
          .collection('super_admins')
          .doc(admin['email'])
          .update({'active': newStatus});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Admin ${newStatus ? 'activated' : 'deactivated'}'),
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

  Future<void> _removeAdmin(Map<String, dynamic> admin) async {
    if (admin['email'] == 'vestaluminasystem@gmail.com') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot remove Master Master account'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title:
            const Text('Remove Admin?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Remove ${admin['email']} from Super Admins?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final callable = _functions.httpsCallable('removeSuperAdmin');
      await callable.call({'email': admin['email']});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin removed'),
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
  // BRAND ACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _saveDefaultBrand() async {
    try {
      await _brandService.updateBrand('vesta-lumina', {
        'name': _brandNameController.text.trim(),
        'appName': _brandNameController.text.trim(),
        'tagline': _taglineController.text.trim(),
        'supportEmail': _supportEmailController.text.trim(),
        'websiteUrl': _websiteController.text.trim(),
        'logoUrl': _logoUrlController.text.trim(),
        'primaryColor': _brandPrimaryColor,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Default brand updated!'),
            backgroundColor: Colors.green,
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

  // ═══════════════════════════════════════════════════════════════════════════
  // BACKUP ACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _triggerBackup() async {
    try {
      final callable = _functions.httpsCallable('manualBackup');
      await callable.call({});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup started!'),
            backgroundColor: Colors.green,
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

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD UI
  // ═══════════════════════════════════════════════════════════════════════════

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
      );
    }

    return Column(
      children: [
        Container(
          color: const Color(0xFF1E1E1E),
          child: TabBar(
            controller: _subTabController,
            indicatorColor: const Color(0xFFD4AF37),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Super Admins'),
              Tab(text: 'Default Brand'),
              Tab(text: 'Backups'),
              Tab(text: 'Logs'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              _buildSuperAdminsTab(),
              _buildDefaultBrandTab(),
              _buildBackupsTab(),
              _buildLogsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuperAdminsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield, color: Color(0xFFD4AF37), size: 28),
              const SizedBox(width: 12),
              const Text(
                'Super Admins',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addSuperAdmin,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Admin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Admin list
          ..._superAdmins.map((admin) => _adminCard(admin)),
        ],
      ),
    );
  }

  Widget _adminCard(Map<String, dynamic> admin) {
    final level = admin['level'] ?? 2;
    final isActive = admin['active'] ?? true;
    final isMaster = admin['email'] == 'vestaluminasystem@gmail.com';
    final color = level >= 3 ? Colors.purple : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? color.withValues(alpha: 0.5)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  level >= 3 ? Icons.shield : Icons.admin_panel_settings,
                  color: color,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'L$level',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
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
                      admin['email'],
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isMaster) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'MASTER',
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (!isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'INACTIVE',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (admin['brandId'] != null)
                  Text(
                    'Brand: ${admin['brandId']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),
          ),

          // Actions
          if (!isMaster) ...[
            IconButton(
              icon: Icon(
                isActive ? Icons.pause : Icons.play_arrow,
                color: isActive ? Colors.orange : Colors.green,
              ),
              onPressed: () => _toggleAdminStatus(admin),
              tooltip: isActive ? 'Deactivate' : 'Activate',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeAdmin(admin),
              tooltip: 'Remove',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultBrandTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.store, color: Color(0xFFD4AF37), size: 28),
              const SizedBox(width: 12),
              const Text(
                'Default Brand (Vesta Lumina)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _saveDefaultBrand,
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Domain: ${_defaultBrand?.domain ?? 'vestalumina.com'} (cannot be changed)',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 24),

          // Brand fields
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column - Text fields
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    TextField(
                      controller: _brandNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration:
                          _inputDecoration('Brand Name', Icons.business),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _taglineController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Tagline', Icons.short_text),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _supportEmailController,
                      style: const TextStyle(color: Colors.white),
                      decoration:
                          _inputDecoration('Support Email', Icons.email),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _websiteController,
                      style: const TextStyle(color: Colors.white),
                      decoration:
                          _inputDecoration('Website URL', Icons.language),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _logoUrlController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Logo URL', Icons.image),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right column - Color & Preview
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Primary Color',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        '#D4AF37',
                        '#FF5722',
                        '#2196F3',
                        '#4CAF50',
                        '#9C27B0',
                        '#E91E63',
                        '#00BCD4',
                        '#795548',
                      ].map((color) {
                        final isSelected = _brandPrimaryColor == color;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _brandPrimaryColor = color),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(
                                  int.parse(color.replaceFirst('#', '0xFF'))),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Preview
                    const Text('Preview',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Color(int.parse(_brandPrimaryColor
                                  .replaceFirst('#', '0xFF'))),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.home,
                                color: Colors.white, size: 30),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _brandNameController.text.isEmpty
                                ? 'Brand Name'
                                : _brandNameController.text,
                            style: TextStyle(
                              color: Color(int.parse(_brandPrimaryColor
                                  .replaceFirst('#', '0xFF'))),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _taglineController.text.isEmpty
                                ? 'Your tagline here'
                                : _taglineController.text,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackupsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.backup, color: Color(0xFFD4AF37), size: 28),
              const SizedBox(width: 12),
              const Text(
                'Backups',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _triggerBackup,
                icon: const Icon(Icons.cloud_upload, size: 18),
                label: const Text('Manual Backup'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Backup info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.green, size: 20),
                    SizedBox(width: 12),
                    Text('Scheduled Backup',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Automatic backups run daily at 3:00 AM CET',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 12),
                    Text('Backup Contents',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '• tenant_links\n• settings\n• units\n• bookings\n• brands\n• tablets\n• super_admins',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: Color(0xFFD4AF37), size: 28),
              const SizedBox(width: 12),
              const Text(
                'Admin Activity Logs',
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

          // Log entries
          _logs.isEmpty
              ? const Center(
                  child:
                      Text('No logs yet', style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _logs.length,
                  itemBuilder: (ctx, i) => _logEntry(_logs[i]),
                ),
        ],
      ),
    );
  }

  Widget _logEntry(Map<String, dynamic> log) {
    final timestamp = log['timestamp'] as Timestamp?;
    final timeStr = timestamp != null
        ? '${timestamp.toDate().day}/${timestamp.toDate().month} ${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
        : 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            timeStr,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              log['action'] ?? '',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              log['adminEmail'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
