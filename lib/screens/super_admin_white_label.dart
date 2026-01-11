// FILE: lib/screens/super_admin_white_label.dart
// VERSION: 1.0 - White Label Brand & Client Management
// DATE: 2026-01-10

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../services/brand_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// WHITE LABEL TAB - Brand & Client Management
// ═══════════════════════════════════════════════════════════════════════════

class SuperAdminWhiteLabelTab extends StatefulWidget {
  const SuperAdminWhiteLabelTab({super.key});

  @override
  State<SuperAdminWhiteLabelTab> createState() =>
      _SuperAdminWhiteLabelTabState();
}

class _SuperAdminWhiteLabelTabState extends State<SuperAdminWhiteLabelTab>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west3');
  final BrandService _brandService = BrandService();

  late TabController _subTabController;

  // Data
  List<Brand> _brands = [];
  Brand? _selectedBrand;
  List<Map<String, dynamic>> _clients = [];
  bool _isLoadingBrands = true;
  bool _isLoadingClients = false;

  // Stats
  int _totalBrands = 0;
  int _totalClients = 0;
  int _totalUnits = 0;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 3, vsync: this);
    _loadBrands();
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DATA LOADING
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _loadBrands() async {
    if (!mounted) return;
    setState(() => _isLoadingBrands = true);

    try {
      final brands = await _brandService.getBrandsByType('white_label');

      int totalClients = 0;
      int totalUnits = 0;

      for (final brand in brands) {
        totalClients += brand.clientCount;
        totalUnits += brand.totalUnits;
      }

      if (mounted) {
        setState(() {
          _brands = brands;
          _totalBrands = brands.length;
          _totalClients = totalClients;
          _totalUnits = totalUnits;
          _isLoadingBrands = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading brands: $e');
      if (mounted) setState(() => _isLoadingBrands = false);
    }
  }

  Future<void> _loadClientsForBrand(Brand brand) async {
    if (!mounted) return;
    setState(() {
      _selectedBrand = brand;
      _isLoadingClients = true;
    });

    try {
      final clients = await _brandService.getBrandClients(brand.id);

      // Enrich with additional data
      List<Map<String, dynamic>> enrichedClients = [];
      for (final client in clients) {
        final tenantId = client['tenantId'];
        int unitCount = 0;
        int bookingCount = 0;

        try {
          final unitsSnap = await _firestore
              .collection('units')
              .where('ownerId', isEqualTo: tenantId)
              .get();
          unitCount = unitsSnap.size;

          final bookingsSnap = await _firestore
              .collection('bookings')
              .where('ownerId', isEqualTo: tenantId)
              .get();
          bookingCount = bookingsSnap.size;
        } catch (_) {}

        enrichedClients.add({
          ...client,
          'unitCount': unitCount,
          'bookingCount': bookingCount,
        });
      }

      if (mounted) {
        setState(() {
          _clients = enrichedClients;
          _isLoadingClients = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading clients: $e');
      if (mounted) setState(() => _isLoadingClients = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BRAND ACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _createBrand() async {
    final t = context.read<AppProvider>().translate;
    final nameController = TextEditingController();
    final domainController = TextEditingController();
    final taglineController = TextEditingController();
    String primaryColor = '#D4AF37';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Row(
            children: [
              const Icon(Icons.add_business, color: Color(0xFFD4AF37)),
              const SizedBox(width: 12),
              Text(t('create_new_brand'),
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Name
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration:
                        _inputDecoration('Brand Name *', Icons.business),
                  ),
                  const SizedBox(height: 16),

                  // Domain (FIXED after creation)
                  TextField(
                    controller: domainController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                        'Domain * (e.g. hotel-sunset.com)', Icons.language),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Domain cannot be changed after creation!',
                            style:
                                TextStyle(color: Colors.orange, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tagline
                  TextField(
                    controller: taglineController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Tagline', Icons.short_text),
                  ),
                  const SizedBox(height: 16),

                  // Primary Color
                  Text(t('primary_color'),
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      '#D4AF37', // Gold
                      '#FF5722', // Orange
                      '#2196F3', // Blue
                      '#4CAF50', // Green
                      '#9C27B0', // Purple
                      '#E91E63', // Pink
                      '#00BCD4', // Cyan
                      '#795548', // Brown
                    ].map((color) {
                      final isSelected = primaryColor == color;
                      return GestureDetector(
                        onTap: () => setDialogState(() => primaryColor = color),
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
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    domainController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context
                          .read<AppProvider>()
                          .translate('name_domain_required')),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx, {
                  'name': nameController.text.trim(),
                  'domain': domainController.text.trim().toLowerCase(),
                  'tagline': taglineController.text.trim(),
                  'primaryColor': primaryColor,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
              ),
              child:
                  const Text('Create', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;

    try {
      await _brandService.createBrand(
        name: result['name'],
        domain: result['domain'],
        type: 'white_label',
        primaryColor: result['primaryColor'],
        tagline: result['tagline'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(context.read<AppProvider>().translate('brand_created')),
            backgroundColor: Colors.green,
          ),
        );
        _loadBrands();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _editBrand(Brand brand) async {
    final t = context.read<AppProvider>().translate;
    final nameController = TextEditingController(text: brand.name);
    final taglineController = TextEditingController(text: brand.tagline);
    final supportEmailController =
        TextEditingController(text: brand.supportEmail);
    final websiteController = TextEditingController(text: brand.websiteUrl);
    String primaryColor = brand.primaryColor;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Row(
            children: [
              const Icon(Icons.edit, color: Color(0xFFD4AF37)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('edit_brand'),
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    Text(brand.domain,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Domain (READ ONLY)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock, color: Colors.grey, size: 16),
                        const SizedBox(width: 8),
                        Text('Domain: ${brand.domain}',
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Brand Name', Icons.business),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: taglineController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Tagline', Icons.short_text),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: supportEmailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Support Email', Icons.email),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: websiteController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Website URL', Icons.language),
                  ),
                  const SizedBox(height: 16),

                  // Primary Color
                  Text(t('primary_color'),
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
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
                      final isSelected = primaryColor == color;
                      return GestureDetector(
                        onTap: () => setDialogState(() => primaryColor = color),
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
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx, {
                  'name': nameController.text.trim(),
                  'appName': nameController.text.trim(),
                  'tagline': taglineController.text.trim(),
                  'supportEmail': supportEmailController.text.trim(),
                  'websiteUrl': websiteController.text.trim(),
                  'primaryColor': primaryColor,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;

    try {
      await _brandService.updateBrand(brand.id, result);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(context.read<AppProvider>().translate('brand_updated')),
            backgroundColor: Colors.green,
          ),
        );
        _loadBrands();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteBrand(Brand brand) async {
    if (brand.clientCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              context.read<AppProvider>().translate('cannot_delete_brand')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete Brand?', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'This will permanently delete "${brand.name}".\n\nThis action cannot be undone!',
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
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _brandService.deleteBrand(brand.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(context.read<AppProvider>().translate('brand_deleted')),
            backgroundColor: Colors.green,
          ),
        );
        _loadBrands();
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
  // CLIENT ACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _createClient() async {
    if (_selectedBrand == null) return;

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Create New Client',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text('Brand: ${_selectedBrand!.name}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
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
                  labelText: 'Email * (must be @${_selectedBrand!.domain})',
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
                decoration: _inputDecoration('Display Name *', Icons.person),
              ),
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
              if (emailController.text.isEmpty || nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all required fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Validate email domain
              final emailDomain =
                  emailController.text.split('@').last.toLowerCase();
              if (emailDomain != _selectedBrand!.domain) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Email must be @${_selectedBrand!.domain}'),
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
            child: const Text('Create', style: TextStyle(color: Colors.black)),
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
        'brandId': _selectedBrand!.id,
        'type': 'white_label',
      });

      if (mounted) {
        final data = response.data as Map<String, dynamic>;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Client created! Temp password: ${data['tempPassword']}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 10),
          ),
        );
        _loadClientsForBrand(_selectedBrand!);
        _loadBrands(); // Update stats
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
    final t = context.read<AppProvider>().translate;

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
              Tab(text: 'Brands'),
              Tab(text: 'Clients'),
              Tab(text: 'Stats'),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              _buildBrandsTab(),
              _buildClientsTab(),
              _buildStatsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBrandsTab() {
    final t = context.read<AppProvider>().translate;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.label, color: Color(0xFFD4AF37), size: 28),
              const SizedBox(width: 12),
              const Text(
                'White Label Brands',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _createBrand,
                icon: const Icon(Icons.add, size: 18),
                label: Text(t('create_new_brand')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _statCard('Brands', '$_totalBrands', Icons.label, Colors.purple),
              _statCard('Clients', '$_totalClients', Icons.people, Colors.blue),
              _statCard('Units', '$_totalUnits', Icons.apartment, Colors.green),
            ],
          ),
          const SizedBox(height: 24),

          // Brands grid
          _isLoadingBrands
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
              : _brands.isEmpty
                  ? _emptyState('No white label brands yet', Icons.label_off)
                  : Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: _brands.map((b) => _brandCard(b)).toList(),
                    ),
        ],
      ),
    );
  }

  Widget _brandCard(Brand brand) {
    final color =
        Color(int.parse(brand.primaryColor.replaceFirst('#', '0xFF')));

    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    brand.name[0].toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brand.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      brand.domain,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stats
          Row(
            children: [
              _miniStat(Icons.people, '${brand.clientCount}', 'Clients'),
              const SizedBox(width: 16),
              _miniStat(Icons.apartment, '${brand.totalUnits}', 'Units'),
              const SizedBox(width: 16),
              _miniStat(
                  Icons.calendar_month, '${brand.totalBookings}', 'Bookings'),
            ],
          ),
          const SizedBox(height: 12),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  _loadClientsForBrand(brand);
                  _subTabController.animateTo(1);
                },
                icon: const Icon(Icons.people, size: 16),
                label: const Text('Clients'),
                style: TextButton.styleFrom(foregroundColor: color),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                color: Colors.grey,
                onPressed: () => _editBrand(brand),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18),
                color: Colors.red,
                onPressed: () => _deleteBrand(brand),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildClientsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand selector
          if (_selectedBrand == null) ...[
            _emptyState(
              'Select a brand from the Brands tab to view clients',
              Icons.arrow_back,
            ),
          ] else ...[
            // Header
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(int.parse(_selectedBrand!.primaryColor
                            .replaceFirst('#', '0xFF')))
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _selectedBrand!.name,
                        style: TextStyle(
                          color: Color(int.parse(_selectedBrand!.primaryColor
                              .replaceFirst('#', '0xFF'))),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_selectedBrand!.domain})',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _createClient,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Client'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Clients list
            _isLoadingClients
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                : _clients.isEmpty
                    ? _emptyState(
                        'No clients for this brand yet', Icons.people_outline)
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _clients.length,
                        itemBuilder: (ctx, i) => _clientCard(_clients[i]),
                      ),
          ],
        ],
      ),
    );
  }

  Widget _clientCard(Map<String, dynamic> client) {
    final status = client['status'] ?? 'pending';
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
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withValues(alpha: 0.2),
            child: Text(
              (client['displayName'] ?? 'U')[0].toUpperCase(),
              style: TextStyle(color: statusColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      client['displayName'] ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
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
                Text(
                  client['email'] ?? '',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _infoChip(Icons.apartment, '${client['unitCount']} units'),
                    const SizedBox(width: 8),
                    _infoChip(Icons.calendar_month,
                        '${client['bookingCount']} bookings'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'White Label Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Overall stats
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _bigStatCard(
                  'Total Brands', '$_totalBrands', Icons.label, Colors.purple),
              _bigStatCard(
                  'Total Clients', '$_totalClients', Icons.people, Colors.blue),
              _bigStatCard(
                  'Total Units', '$_totalUnits', Icons.apartment, Colors.green),
            ],
          ),
          const SizedBox(height: 32),

          // Per-brand breakdown
          const Text(
            'Per Brand Breakdown',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          ..._brands.map((brand) => _brandStatsRow(brand)),
        ],
      ),
    );
  }

  Widget _brandStatsRow(Brand brand) {
    final color =
        Color(int.parse(brand.primaryColor.replaceFirst('#', '0xFF')));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                brand.name[0],
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(brand.domain,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          _statColumn('Clients', '${brand.clientCount}'),
          _statColumn('Units', '${brand.totalUnits}'),
          _statColumn('Bookings', '${brand.totalBookings}'),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
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

  Widget _bigStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _emptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
