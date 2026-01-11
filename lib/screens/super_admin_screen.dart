// FILE: lib/screens/super_admin_screen.dart
// VERSION: 5.1 - Auto-initialization for Master Admin
// DATE: 2026-01-11

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

import 'super_admin_retail.dart';
import 'super_admin_white_label.dart';
import 'super_admin_exit.dart';
import 'super_admin_settings.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ADMIN LEVEL ENUM
// ═══════════════════════════════════════════════════════════════════════════

enum AdminLevel {
  owner, // Level 1 - Regular owner (shouldn't reach this screen)
  superAdmin, // Level 2 - Brand Super Admin
  masterMaster, // Level 3 - God mode
}

// ═══════════════════════════════════════════════════════════════════════════
// SUPER ADMIN SCREEN - Main Container
// ═══════════════════════════════════════════════════════════════════════════

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late TabController _tabController;

  // Admin info
  AdminLevel _adminLevel = AdminLevel.owner;
  String? _adminBrandId;
  String _adminEmail = '';
  bool _isLoading = true;

  // Master tabs based on level
  List<Tab> _tabs = [];
  List<Widget> _tabViews = [];

  // Master admin email (hardcoded for bootstrap)
  static const String _masterAdminEmail = 'vestaluminasystem@gmail.com';

  @override
  void initState() {
    super.initState();
    _detectAdminLevel();
  }

  @override
  void dispose() {
    if (_tabs.isNotEmpty) {
      _tabController.dispose();
    }
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTO-INITIALIZATION (creates required documents if missing)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _ensureDefaultDocuments() async {
    // 1. Create default brand if missing
    final brandDoc =
        await _firestore.collection('brands').doc('vesta-lumina').get();
    if (!brandDoc.exists) {
      await _firestore.collection('brands').doc('vesta-lumina').set({
        'id': 'vesta-lumina',
        'name': 'Vesta Lumina',
        'domain': 'vestalumina.com',
        'type': 'retail',
        'isLocked': true,
        'primaryColor': '#D4AF37',
        'secondaryColor': '#1E1E1E',
        'accentColor': '#FFFFFF',
        'appName': 'Vesta Lumina',
        'tagline': 'Smart Property Management',
        'supportEmail': 'support@vestalumina.com',
        'websiteUrl': 'https://vestalumina.com',
        'logoUrl': '',
        'logoLightUrl': '',
        'faviconUrl': '',
        'splashImageUrl': '',
        'clientCount': 0,
        'totalUnits': 0,
        'totalBookings': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Created default brand: vesta-lumina');
    }

    // 2. Create master admin document if missing
    final adminDoc = await _firestore
        .collection('super_admins')
        .doc(_masterAdminEmail)
        .get();
    if (!adminDoc.exists) {
      await _firestore.collection('super_admins').doc(_masterAdminEmail).set({
        'email': _masterAdminEmail,
        'level': 3,
        'brandId': null,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'system',
      });
      debugPrint('✅ Created master admin: $_masterAdminEmail');
    }

    // 3. Create exit_config if missing
    final exitDoc =
        await _firestore.collection('exit_config').doc('settings').get();
    if (!exitDoc.exists) {
      await _firestore.collection('exit_config').doc('settings').set({
        'retailMonthlyBase': 29.99,
        'retailPerUnit': 4.99,
        'retailSetupFee': 199.0,
        'whiteLabelMonthlyBase': 99.99,
        'whiteLabelPerUnit': 2.99,
        'whiteLabelSetupFee': 499.0,
        'firebaseMonthlyCost': 50.0,
        'maintenanceHourlyRate': 50.0,
        'maintenanceHoursMonthly': 10.0,
        'multiplierLow': 3.0,
        'multiplierMid': 7.0,
        'multiplierHigh': 12.0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Created exit_config: settings');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ADMIN LEVEL DETECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _detectAdminLevel() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Navigator.of(context).pop();
        return;
      }

      _adminEmail = user.email?.toLowerCase() ?? '';

      // ═══════════════════════════════════════════════════════════════════════
      // MASTER ADMIN AUTO-INITIALIZATION
      // If this is the master admin, ensure all required documents exist
      // ═══════════════════════════════════════════════════════════════════════
      if (_adminEmail == _masterAdminEmail) {
        await _ensureDefaultDocuments();
      }

      // Check super_admins collection
      final adminDoc =
          await _firestore.collection('super_admins').doc(_adminEmail).get();

      if (!adminDoc.exists) {
        // Not a super admin, shouldn't be here
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context
                  .read<AppProvider>()
                  .translate('super_admin_access_denied')),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop();
        }
        return;
      }

      final adminData = adminDoc.data()!;
      final level = adminData['level'] ?? 2;
      final brandId = adminData['brandId'] as String?;
      final isActive = adminData['active'] ?? false;

      if (!isActive) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context
                  .read<AppProvider>()
                  .translate('super_admin_deactivated')),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop();
        }
        return;
      }

      // Determine admin level
      if (level >= 3 || _adminEmail == _masterAdminEmail) {
        _adminLevel = AdminLevel.masterMaster;
        _adminBrandId = null; // Can see all brands
      } else {
        _adminLevel = AdminLevel.superAdmin;
        _adminBrandId = brandId;
      }

      _buildTabs();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('❌ Error detecting admin level: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        Navigator.of(context).pop();
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD TABS BASED ON LEVEL
  // ═══════════════════════════════════════════════════════════════════════════

  void _buildTabs() {
    if (_adminLevel == AdminLevel.masterMaster) {
      // Level 3: Full access
      _tabs = const [
        Tab(icon: Icon(Icons.store), text: 'RETAIL'),
        Tab(icon: Icon(Icons.label), text: 'WHITE LABEL'),
        Tab(icon: Icon(Icons.trending_up), text: 'EXIT'),
        Tab(icon: Icon(Icons.settings), text: 'SETTINGS'),
      ];
      _tabViews = const [
        SuperAdminRetailTab(),
        SuperAdminWhiteLabelTab(),
        SuperAdminExitTab(),
        SuperAdminSettingsTab(),
      ];
    } else {
      // Level 2: Brand-restricted access
      _tabs = const [
        Tab(icon: Icon(Icons.people), text: 'OWNERS'),
        Tab(icon: Icon(Icons.tablet_android), text: 'TABLETS'),
        Tab(icon: Icon(Icons.notifications), text: 'NOTIFICATIONS'),
      ];
      _tabViews = [
        SuperAdminRetailTab(brandFilter: _adminBrandId),
        SuperAdminRetailTab(brandFilter: _adminBrandId, initialTab: 1),
        SuperAdminRetailTab(brandFilter: _adminBrandId, initialTab: 3),
      ];
    }

    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD UI
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFFD4AF37)),
              const SizedBox(height: 20),
              Text(
                'Verifying admin access...',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            // Admin level badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _adminLevel == AdminLevel.masterMaster
                    ? Colors.purple.withValues(alpha: 0.3)
                    : Colors.blue.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _adminLevel == AdminLevel.masterMaster
                      ? Colors.purple
                      : Colors.blue,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _adminLevel == AdminLevel.masterMaster
                        ? Icons.shield
                        : Icons.admin_panel_settings,
                    size: 16,
                    color: _adminLevel == AdminLevel.masterMaster
                        ? Colors.purple
                        : Colors.blue,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _adminLevel == AdminLevel.masterMaster ? 'MASTER' : 'ADMIN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _adminLevel == AdminLevel.masterMaster
                          ? Colors.purple
                          : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Super Admin Panel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Logged in as
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _adminEmail,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFD4AF37),
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.grey,
          indicatorWeight: 3,
          tabs: _tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabViews,
      ),
    );
  }
}
