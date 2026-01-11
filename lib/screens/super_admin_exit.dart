// FILE: lib/screens/super_admin_exit.dart
// VERSION: 1.0 - Exit Valuation & Financial Dashboard
// DATE: 2026-01-10

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════
// EXIT TAB - Financial Dashboard, Pricing & Projections
// ═══════════════════════════════════════════════════════════════════════════

class SuperAdminExitTab extends StatefulWidget {
  const SuperAdminExitTab({super.key});

  @override
  State<SuperAdminExitTab> createState() => _SuperAdminExitTabState();
}

class _SuperAdminExitTabState extends State<SuperAdminExitTab>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TabController _subTabController;

  // Data
  bool _isLoading = true;
  Map<String, dynamic> _config = {};
  Map<String, dynamic> _stats = {};

  // Pricing Controllers
  final _retailBaseController = TextEditingController();
  final _retailPerUnitController = TextEditingController();
  final _retailSetupController = TextEditingController();
  final _whiteLabelBaseController = TextEditingController();
  final _whiteLabelPerUnitController = TextEditingController();
  final _whiteLabelSetupController = TextEditingController();
  final _firebaseCostController = TextEditingController();
  final _maintenanceRateController = TextEditingController();
  final _maintenanceHoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _subTabController.dispose();
    _retailBaseController.dispose();
    _retailPerUnitController.dispose();
    _retailSetupController.dispose();
    _whiteLabelBaseController.dispose();
    _whiteLabelPerUnitController.dispose();
    _whiteLabelSetupController.dispose();
    _firebaseCostController.dispose();
    _maintenanceRateController.dispose();
    _maintenanceHoursController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DATA LOADING
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Load config
      final configDoc =
          await _firestore.collection('exit_config').doc('settings').get();

      if (configDoc.exists) {
        _config = configDoc.data()!;
      } else {
        // Create default config
        _config = _defaultConfig;
        await _firestore.collection('exit_config').doc('settings').set(_config);
      }

      // Load stats
      await _loadStats();

      // Populate controllers
      _populateControllers();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('❌ Error loading exit data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> get _defaultConfig => {
        // Retail Pricing
        'retailMonthlyBase': 29.99,
        'retailPerUnit': 4.99,
        'retailSetupFee': 199.0,

        // White Label Pricing
        'whiteLabelMonthlyBase': 99.99,
        'whiteLabelPerUnit': 2.99,
        'whiteLabelSetupFee': 499.0,

        // Costs
        'firebaseMonthlyCost': 50.0,
        'maintenanceHourlyRate': 50.0,
        'maintenanceHoursMonthly': 10.0,

        // Exit Multipliers
        'multiplierLow': 3.0,
        'multiplierMid': 7.0,
        'multiplierHigh': 12.0,
      };

  void _populateControllers() {
    _retailBaseController.text =
        _config['retailMonthlyBase']?.toString() ?? '29.99';
    _retailPerUnitController.text =
        _config['retailPerUnit']?.toString() ?? '4.99';
    _retailSetupController.text =
        _config['retailSetupFee']?.toString() ?? '199';
    _whiteLabelBaseController.text =
        _config['whiteLabelMonthlyBase']?.toString() ?? '99.99';
    _whiteLabelPerUnitController.text =
        _config['whiteLabelPerUnit']?.toString() ?? '2.99';
    _whiteLabelSetupController.text =
        _config['whiteLabelSetupFee']?.toString() ?? '499';
    _firebaseCostController.text =
        _config['firebaseMonthlyCost']?.toString() ?? '50';
    _maintenanceRateController.text =
        _config['maintenanceHourlyRate']?.toString() ?? '50';
    _maintenanceHoursController.text =
        _config['maintenanceHoursMonthly']?.toString() ?? '10';
  }

  Future<void> _loadStats() async {
    // Count retail clients
    final retailSnap = await _firestore
        .collection('tenant_links')
        .where('brandId', isEqualTo: 'vesta-lumina')
        .get();
    final retailClients = retailSnap.size;

    // Count white label brands & clients
    final brandsSnap = await _firestore
        .collection('brands')
        .where('type', isEqualTo: 'white_label')
        .get();
    final whiteLabelBrands = brandsSnap.size;

    final whiteLabelSnap = await _firestore
        .collection('tenant_links')
        .where('type', isEqualTo: 'white_label')
        .get();
    final whiteLabelClients = whiteLabelSnap.size;

    // Count total units
    final unitsSnap = await _firestore.collection('units').get();
    final totalUnits = unitsSnap.size;

    // Count active bookings (current month)
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final bookingsSnap = await _firestore
        .collection('bookings')
        .where('checkIn',
            isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
        .get();
    final monthlyBookings = bookingsSnap.size;

    _stats = {
      'retailClients': retailClients,
      'whiteLabelBrands': whiteLabelBrands,
      'whiteLabelClients': whiteLabelClients,
      'totalUnits': totalUnits,
      'monthlyBookings': monthlyBookings,
      'totalClients': retailClients + whiteLabelClients,
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CALCULATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  double get _retailMRR {
    final clients = _stats['retailClients'] ?? 0;
    final units = _stats['totalUnits'] ?? 0;
    final base = double.tryParse(_retailBaseController.text) ?? 29.99;
    final perUnit = double.tryParse(_retailPerUnitController.text) ?? 4.99;

    // Estimate retail units (assume 60% of total units are retail)
    final retailUnits = (units * 0.6).round();

    return (clients * base) + (retailUnits * perUnit);
  }

  double get _whiteLabelMRR {
    final clients = _stats['whiteLabelClients'] ?? 0;
    final units = _stats['totalUnits'] ?? 0;
    final base = double.tryParse(_whiteLabelBaseController.text) ?? 99.99;
    final perUnit = double.tryParse(_whiteLabelPerUnitController.text) ?? 2.99;

    // Estimate white label units (assume 40% of total units are white label)
    final wlUnits = (units * 0.4).round();

    return (clients * base) + (wlUnits * perUnit);
  }

  double get _totalMRR => _retailMRR + _whiteLabelMRR;
  double get _totalARR => _totalMRR * 12;

  double get _monthlyCosts {
    final firebase = double.tryParse(_firebaseCostController.text) ?? 50;
    final rate = double.tryParse(_maintenanceRateController.text) ?? 50;
    final hours = double.tryParse(_maintenanceHoursController.text) ?? 10;

    return firebase + (rate * hours);
  }

  double get _monthlyProfit => _totalMRR - _monthlyCosts;
  double get _annualProfit => _monthlyProfit * 12;
  double get _profitMargin =>
      _totalMRR > 0 ? (_monthlyProfit / _totalMRR) * 100 : 0;

  double get _valuationLow => _totalARR * (_config['multiplierLow'] ?? 3);
  double get _valuationMid => _totalARR * (_config['multiplierMid'] ?? 7);
  double get _valuationHigh => _totalARR * (_config['multiplierHigh'] ?? 12);

  // ═══════════════════════════════════════════════════════════════════════════
  // SAVE CONFIG
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _saveConfig() async {
    final t = context.read<AppProvider>().translate;

    try {
      final updatedConfig = {
        'retailMonthlyBase':
            double.tryParse(_retailBaseController.text) ?? 29.99,
        'retailPerUnit': double.tryParse(_retailPerUnitController.text) ?? 4.99,
        'retailSetupFee': double.tryParse(_retailSetupController.text) ?? 199,
        'whiteLabelMonthlyBase':
            double.tryParse(_whiteLabelBaseController.text) ?? 99.99,
        'whiteLabelPerUnit':
            double.tryParse(_whiteLabelPerUnitController.text) ?? 2.99,
        'whiteLabelSetupFee':
            double.tryParse(_whiteLabelSetupController.text) ?? 499,
        'firebaseMonthlyCost':
            double.tryParse(_firebaseCostController.text) ?? 50,
        'maintenanceHourlyRate':
            double.tryParse(_maintenanceRateController.text) ?? 50,
        'maintenanceHoursMonthly':
            double.tryParse(_maintenanceHoursController.text) ?? 10,
        'multiplierLow': _config['multiplierLow'] ?? 3,
        'multiplierMid': _config['multiplierMid'] ?? 7,
        'multiplierHigh': _config['multiplierHigh'] ?? 12,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('exit_config')
          .doc('settings')
          .update(updatedConfig);

      _config = updatedConfig;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('pricing_saved')),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // Refresh calculations
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
    final t = context.read<AppProvider>().translate;

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
              Tab(text: 'Dashboard'),
              Tab(text: 'Pricing Config'),
              Tab(text: 'Projections'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              _buildDashboard(),
              _buildPricingConfig(),
              _buildProjections(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.trending_up, color: Color(0xFFD4AF37), size: 28),
              const SizedBox(width: 12),
              const Text(
                'Exit Dashboard',
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

          // Valuation Cards
          const Text(
            '💰 VALUATION ESTIMATE',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _valuationCard(
                  'Conservative (3x ARR)',
                  _valuationLow,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _valuationCard(
                  'Realistic (7x ARR)',
                  _valuationMid,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _valuationCard(
                  'Optimistic (12x ARR)',
                  _valuationHigh,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Revenue Metrics
          const Text(
            '📊 REVENUE METRICS',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _metricCard('MRR', '€${_totalMRR.toStringAsFixed(2)}',
                  Icons.calendar_today, Colors.green),
              _metricCard('ARR', '€${_totalARR.toStringAsFixed(2)}',
                  Icons.calendar_month, Colors.blue),
              _metricCard('Retail MRR', '€${_retailMRR.toStringAsFixed(2)}',
                  Icons.store, Colors.orange),
              _metricCard(
                  'White Label MRR',
                  '€${_whiteLabelMRR.toStringAsFixed(2)}',
                  Icons.label,
                  Colors.purple),
              _metricCard(
                  'Monthly Costs',
                  '€${_monthlyCosts.toStringAsFixed(2)}',
                  Icons.money_off,
                  Colors.red),
              _metricCard(
                  'Monthly Profit',
                  '€${_monthlyProfit.toStringAsFixed(2)}',
                  Icons.savings,
                  Colors.green),
              _metricCard(
                  'Profit Margin',
                  '${_profitMargin.toStringAsFixed(1)}%',
                  Icons.percent,
                  Colors.cyan),
              _metricCard(
                  'Annual Profit',
                  '€${_annualProfit.toStringAsFixed(2)}',
                  Icons.account_balance,
                  Colors.green),
            ],
          ),
          const SizedBox(height: 32),

          // Business Stats
          const Text(
            '📈 BUSINESS STATS',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _statCard('Total Clients', '${_stats['totalClients'] ?? 0}',
                  Icons.people),
              _statCard('Retail Clients', '${_stats['retailClients'] ?? 0}',
                  Icons.store),
              _statCard('WL Brands', '${_stats['whiteLabelBrands'] ?? 0}',
                  Icons.label),
              _statCard('WL Clients', '${_stats['whiteLabelClients'] ?? 0}',
                  Icons.business),
              _statCard('Total Units', '${_stats['totalUnits'] ?? 0}',
                  Icons.apartment),
              _statCard('Monthly Bookings', '${_stats['monthlyBookings'] ?? 0}',
                  Icons.calendar_month),
            ],
          ),
        ],
      ),
    );
  }

  Widget _valuationCard(String title, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            '€${value.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPricingConfig() {
    final t = context.read<AppProvider>().translate;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings, color: Color(0xFFD4AF37), size: 28),
              const SizedBox(width: 12),
              const Text(
                'Pricing Configuration',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _saveConfig,
                icon: const Icon(Icons.save, size: 18),
                label: Text(t('btn_save')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Retail Pricing
          _sectionTitle('🏪 RETAIL PRICING (Vesta Lumina)', Colors.orange),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child:
                      _configField('Monthly Base (€)', _retailBaseController)),
              const SizedBox(width: 16),
              Expanded(
                  child:
                      _configField('Per Unit (€)', _retailPerUnitController)),
              const SizedBox(width: 16),
              Expanded(
                  child: _configField('Setup Fee (€)', _retailSetupController)),
            ],
          ),
          const SizedBox(height: 32),

          // White Label Pricing
          _sectionTitle('🏷️ WHITE LABEL PRICING', Colors.purple),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _configField(
                      'Monthly Base (€)', _whiteLabelBaseController)),
              const SizedBox(width: 16),
              Expanded(
                  child: _configField(
                      'Per Unit (€)', _whiteLabelPerUnitController)),
              const SizedBox(width: 16),
              Expanded(
                  child: _configField(
                      'Setup Fee (€)', _whiteLabelSetupController)),
            ],
          ),
          const SizedBox(height: 32),

          // Operating Costs
          _sectionTitle('💸 OPERATING COSTS', Colors.red),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _configField(
                      'Firebase Monthly (€)', _firebaseCostController)),
              const SizedBox(width: 16),
              Expanded(
                  child: _configField(
                      'Maintenance €/hour', _maintenanceRateController)),
              const SizedBox(width: 16),
              Expanded(
                  child:
                      _configField('Hours/Month', _maintenanceHoursController)),
            ],
          ),
          const SizedBox(height: 32),

          // Live Calculation Preview
          _sectionTitle('📊 LIVE CALCULATION PREVIEW', Colors.green),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                _calcRow('Retail MRR', '€${_retailMRR.toStringAsFixed(2)}'),
                _calcRow(
                    'White Label MRR', '€${_whiteLabelMRR.toStringAsFixed(2)}'),
                const Divider(color: Colors.grey),
                _calcRow('Total MRR', '€${_totalMRR.toStringAsFixed(2)}',
                    bold: true),
                _calcRow(
                    'Monthly Costs', '-€${_monthlyCosts.toStringAsFixed(2)}',
                    color: Colors.red),
                const Divider(color: Colors.grey),
                _calcRow(
                    'Monthly Profit', '€${_monthlyProfit.toStringAsFixed(2)}',
                    color: Colors.green, bold: true),
                _calcRow(
                    'Annual Profit', '€${_annualProfit.toStringAsFixed(2)}',
                    color: Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _configField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD4AF37)),
        ),
      ),
    );
  }

  Widget _calcRow(String label, String value,
      {Color color = Colors.white, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjections() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_graph, color: Color(0xFFD4AF37), size: 28),
              SizedBox(width: 12),
              Text(
                'Growth Projections',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Current State
          _sectionTitle('📍 CURRENT STATE', Colors.blue),
          const SizedBox(height: 16),
          _projectionCard(
            'Now',
            _stats['totalClients'] ?? 0,
            _stats['totalUnits'] ?? 0,
            _totalMRR,
            _totalARR,
            Colors.blue,
          ),
          const SizedBox(height: 24),

          // 12 Month Projection (20% monthly growth)
          _sectionTitle(
              '📈 12 MONTH PROJECTION (20% Monthly Growth)', Colors.green),
          const SizedBox(height: 16),
          _buildProjectionTable(),
          const SizedBox(height: 24),

          // Milestones
          _sectionTitle('🎯 MILESTONES', Colors.purple),
          const SizedBox(height: 16),
          _milestoneCard(
              '10 Clients', 10, 50, _calculateMRR(10, 50), Colors.orange),
          _milestoneCard(
              '50 Clients', 50, 200, _calculateMRR(50, 200), Colors.green),
          _milestoneCard(
              '100 Clients', 100, 400, _calculateMRR(100, 400), Colors.blue),
          _milestoneCard('500 Clients', 500, 2000, _calculateMRR(500, 2000),
              Colors.purple),
        ],
      ),
    );
  }

  double _calculateMRR(int clients, int units) {
    final base = double.tryParse(_retailBaseController.text) ?? 29.99;
    final perUnit = double.tryParse(_retailPerUnitController.text) ?? 4.99;
    return (clients * base) + (units * perUnit);
  }

  Widget _projectionCard(String period, int clients, int units, double mrr,
      double arr, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _projColumn(period, '', color, isTitle: true),
          _projColumn('Clients', '$clients', color),
          _projColumn('Units', '$units', color),
          _projColumn('MRR', '€${mrr.toStringAsFixed(0)}', color),
          _projColumn('ARR', '€${arr.toStringAsFixed(0)}', color),
          _projColumn('Valuation (7x)', '€${(arr * 7).toStringAsFixed(0)}',
              Colors.green),
        ],
      ),
    );
  }

  Widget _projColumn(String label, String value, Color color,
      {bool isTitle = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTitle ? color : Colors.grey,
            fontSize: isTitle ? 16 : 11,
            fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (!isTitle) ...[
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProjectionTable() {
    final currentClients = _stats['totalClients'] ?? 0;
    final currentUnits = _stats['totalUnits'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(2),
        },
        children: [
          _tableHeader(),
          ...List.generate(12, (i) {
            final month = i + 1;
            final growthFactor = 1.0 + (0.20 * month); // 20% cumulative
            final projClients = (currentClients * growthFactor).round();
            final projUnits = (currentUnits * growthFactor).round();
            final projMRR = _calculateMRR(projClients, projUnits);
            final projARR = projMRR * 12;

            return TableRow(
              children: [
                _tableCell('Month $month'),
                _tableCell('$projClients'),
                _tableCell('$projUnits'),
                _tableCell('€${projMRR.toStringAsFixed(0)}'),
                _tableCell('€${(projARR * 7).toStringAsFixed(0)}',
                    color: Colors.green),
              ],
            );
          }),
        ],
      ),
    );
  }

  TableRow _tableHeader() {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.3))),
      ),
      children: [
        _tableCell('Period', isHeader: true),
        _tableCell('Clients', isHeader: true),
        _tableCell('Units', isHeader: true),
        _tableCell('MRR', isHeader: true),
        _tableCell('Valuation (7x)', isHeader: true),
      ],
    );
  }

  Widget _tableCell(String text, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? (isHeader ? Colors.grey : Colors.white),
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _milestoneCard(
      String title, int clients, int units, double mrr, Color color) {
    final arr = mrr * 12;
    final valuation = arr * 7;

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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.flag, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$clients clients • $units units',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'MRR: €${mrr.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Valuation: €${valuation.toStringAsFixed(0)}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
