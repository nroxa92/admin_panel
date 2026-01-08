// FILE: lib/screens/dashboard_screen.dart
// STATUS: PRODUCTION READY - All strings translated
// SADRŽAJ:
//   - DashboardScreen (main screen with sidebar navigation)
//   - LiveMonitorView (today/tomorrow panels + unit list)

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../services/units_service.dart';
import '../services/booking_service.dart';
import '../providers/app_provider.dart';
import '../models/unit_model.dart';
import '../models/booking_model.dart';

import '../widgets/unit_widgets.dart';
import 'booking_screen.dart' as screens;
import 'settings_screen.dart';

// =====================================================
// DASHBOARD SCREEN (Main Navigation)
// =====================================================
class DashboardScreen extends StatefulWidget {
  final String initialRoute;

  const DashboardScreen({super.key, this.initialRoute = 'reception'});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int get _selectedIndex {
    switch (widget.initialRoute) {
      case 'reception':
        return 0;
      case 'calendar':
        return 1;
      case 'settings':
        return 2;
      default:
        return 0;
    }
  }

  final List<Widget> _screens = const [
    LiveMonitorView(),
    screens.BookingScreen(),
    SettingsScreen(),
  ];

  String _getTitle(BuildContext context, int index) {
    final t = context.read<AppProvider>().translate;
    switch (index) {
      case 0:
        return t('nav_reception');
      case 1:
        return t('nav_calendar');
      case 2:
        return t('nav_settings');
      default:
        return "";
    }
  }

  void _navigateTo(BuildContext context, String route) {
    context.go('/$route');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1000;
    final provider = context.watch<AppProvider>();
    final backgroundColor = provider.backgroundColor;
    final primaryColor = provider.primaryColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: isMobile
          ? AppBar(
              title: Text(_getTitle(context, _selectedIndex)),
              backgroundColor: backgroundColor,
              iconTheme: IconThemeData(color: primaryColor),
            )
          : null,
      drawer: isMobile ? _buildDrawer(context, provider) : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(context, provider),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppProvider provider) {
    final t = provider.translate;
    final isDark = provider.backgroundColor.computeLuminance() < 0.5;
    final textColor = isDark ? Colors.white : Colors.black87;
    final primary = provider.primaryColor;

    return Drawer(
      backgroundColor: provider.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _drawerTile(context, Icons.home, t('nav_reception'), 'reception',
                _selectedIndex == 0, primary, textColor),
            _drawerTile(context, Icons.calendar_month, t('nav_calendar'),
                'calendar', _selectedIndex == 1, primary, textColor),
            _drawerTile(context, Icons.settings, t('nav_settings'), 'settings',
                _selectedIndex == 2, primary, textColor),
            const Spacer(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red.shade300),
              title: Text(t('nav_logout'),
                  style: TextStyle(color: Colors.red.shade300)),
              onTap: () => FirebaseAuth.instance.signOut(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(BuildContext context, IconData icon, String title,
      String route, bool isSelected, Color primary, Color textColor) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? primary : Colors.grey, size: 24),
      title: Text(title,
          style: TextStyle(
              color: isSelected ? textColor : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedTileColor: primary.withValues(alpha: 0.1),
      onTap: () {
        Navigator.pop(context);
        _navigateTo(context, route);
      },
    );
  }

  Widget _buildSidebar(BuildContext context, AppProvider provider) {
    final t = provider.translate;
    final isDark = provider.backgroundColor.computeLuminance() < 0.5;
    final textColor = isDark ? Colors.white : Colors.black87;
    final primary = provider.primaryColor;

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
        border: Border(
          right: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Text(
            'VillaOS',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
          const SizedBox(height: 30),
          _sidebarTile(context, Icons.home, t('nav_reception'), 'reception',
              _selectedIndex == 0, primary, textColor),
          _sidebarTile(context, Icons.calendar_month, t('nav_calendar'),
              'calendar', _selectedIndex == 1, primary, textColor),
          _sidebarTile(context, Icons.settings, t('nav_settings'), 'settings',
              _selectedIndex == 2, primary, textColor),
          const Spacer(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade300),
            title: Text(t('nav_logout'),
                style: TextStyle(color: Colors.red.shade300)),
            onTap: () => FirebaseAuth.instance.signOut(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sidebarTile(BuildContext context, IconData icon, String title,
      String route, bool isSelected, Color primary, Color textColor) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? primary : Colors.grey, size: 24),
      title: Text(title,
          style: TextStyle(
              color: isSelected ? textColor : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedTileColor: primary.withValues(alpha: 0.1),
      onTap: () => _navigateTo(context, route),
    );
  }
}

// =====================================================
// LIVE MONITOR VIEW (Today/Tomorrow + Unit List)
// =====================================================
class LiveMonitorView extends StatefulWidget {
  const LiveMonitorView({super.key});

  @override
  State<LiveMonitorView> createState() => _LiveMonitorViewState();
}

class _LiveMonitorViewState extends State<LiveMonitorView> {
  String _sortBy = 'name';
  String _categorySortBy = 'name';
  final Set<String> _hiddenCategories = {};

  void _toggleCategoryVisibility(String category) {
    setState(() {
      if (_hiddenCategories.contains(category)) {
        _hiddenCategories.remove(category);
      } else {
        _hiddenCategories.add(category);
      }
    });
  }

  void _openNewUnitDialog(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final t = provider.translate;
    final primaryColor = provider.primaryColor;
    final unitsService = UnitsService();

    final nameCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    final wifiNameCtrl = TextEditingController();
    final wifiPassCtrl = TextEditingController();
    final reviewLinkCtrl = TextEditingController();
    final newZoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    String? selectedZone;
    String? newZoneValue;

    showDialog(
      context: context,
      builder: (ctx) => StreamBuilder<List<Unit>>(
        // Dohvati sve units da dobijemo postojeće zone
        stream: unitsService.getUnitsStream(),
        builder: (context, unitSnapshot) {
          // Kombiniraj zone iz units + settings
          final Set<String> allZones = {};

          // 1. Dodaj zone iz postojećih units
          if (unitSnapshot.hasData) {
            for (var unit in unitSnapshot.data!) {
              if (unit.category != null && unit.category!.isNotEmpty) {
                allZones.add(unit.category!);
              }
            }
          }

          // 2. Dodaj zone iz settings
          for (var cat in provider.settings.categories) {
            if (cat.isNotEmpty) {
              allZones.add(cat);
            }
          }

          // Sortiraj abecedno
          final sortedZones = allZones.toList()..sort();

          return StatefulBuilder(builder: (context, setDialogState) {
            final isDark = provider.backgroundColor.computeLuminance() < 0.5;
            final textColor = isDark ? Colors.white : Colors.black87;

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              title: Text(t('dialog_new_unit'),
                  style: TextStyle(color: textColor)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: SizedBox(
                    width: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SECTION: Identification
                        Text(t('section_identification'),
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: nameCtrl,
                          decoration: InputDecoration(
                            labelText: "${t('label_name')} *",
                            labelStyle: TextStyle(color: Colors.grey.shade400),
                            border: const OutlineInputBorder(),
                          ),
                          style: TextStyle(color: textColor),
                          validator: (v) =>
                              v == null || v.isEmpty ? t('msg_error') : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: addrCtrl,
                          decoration: InputDecoration(
                            labelText: t('label_address'),
                            labelStyle: TextStyle(color: Colors.grey.shade400),
                            border: const OutlineInputBorder(),
                          ),
                          style: TextStyle(color: textColor),
                        ),
                        const SizedBox(height: 10),

                        // Zone dropdown - DINAMIČKI IZ UNITS + SETTINGS
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: selectedZone,
                                decoration: InputDecoration(
                                  labelText: t('sort_zones'),
                                  labelStyle:
                                      TextStyle(color: Colors.grey.shade400),
                                  border: const OutlineInputBorder(),
                                ),
                                dropdownColor: isDark
                                    ? const Color(0xFF2C2C2C)
                                    : Colors.white,
                                style: TextStyle(color: textColor),
                                items: [
                                  // Opcija "Bez zone"
                                  DropdownMenuItem<String>(
                                    value: null,
                                    child: Text(t('zone_none'),
                                        style: TextStyle(color: textColor)),
                                  ),
                                  // Postojeće zone
                                  ...sortedZones.map((cat) => DropdownMenuItem(
                                      value: cat,
                                      child: Text(cat,
                                          style: TextStyle(color: textColor)))),
                                  // Opcija "Nova zona"
                                  DropdownMenuItem<String>(
                                    value: '__new__',
                                    child: Text("+ ${t('new_zone')}",
                                        style: TextStyle(color: primaryColor)),
                                  ),
                                ],
                                onChanged: (val) {
                                  setDialogState(() {
                                    if (val == '__new__') {
                                      selectedZone = null;
                                      newZoneValue = '';
                                    } else {
                                      selectedZone = val;
                                      newZoneValue = null;
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        // New zone text field
                        if (newZoneValue != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: newZoneCtrl,
                                  decoration: InputDecoration(
                                    labelText: t('new_zone'),
                                    labelStyle:
                                        TextStyle(color: Colors.grey.shade400),
                                    border: const OutlineInputBorder(),
                                  ),
                                  style: TextStyle(color: textColor),
                                  onChanged: (v) =>
                                      setDialogState(() => newZoneValue = v),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                                onPressed: () =>
                                    setDialogState(() => newZoneValue = null),
                              ),
                            ],
                          ),
                          Text(t('msg_confirm_zone'),
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 11)),
                        ],

                        const SizedBox(height: 20),

                        // SECTION: Connectivity
                        Text(t('section_connectivity'),
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: wifiNameCtrl,
                          decoration: InputDecoration(
                            labelText: t('label_wifi_ssid'),
                            labelStyle: TextStyle(color: Colors.grey.shade400),
                            border: const OutlineInputBorder(),
                          ),
                          style: TextStyle(color: textColor),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: wifiPassCtrl,
                          decoration: InputDecoration(
                            labelText: t('label_wifi_pass'),
                            labelStyle: TextStyle(color: Colors.grey.shade400),
                            border: const OutlineInputBorder(),
                          ),
                          style: TextStyle(color: textColor),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: reviewLinkCtrl,
                          decoration: InputDecoration(
                            labelText: t('label_review_link'),
                            labelStyle: TextStyle(color: Colors.grey.shade400),
                            border: const OutlineInputBorder(),
                          ),
                          style: TextStyle(color: textColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(t('btn_cancel')),
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final finalZone = newZoneValue?.trim().isNotEmpty == true
                        ? newZoneValue!.trim()
                        : selectedZone;

                    // Ako je nova zona, spremi je u settings
                    if (newZoneValue?.trim().isNotEmpty == true) {
                      await unitsService.addCategory(newZoneValue!.trim());
                    }

                    // Generate unit ID
                    final settings = provider.settings;
                    final unitId = await unitsService.generateUnitId(
                      ownerFirstName: settings.ownerFirstName,
                      ownerLastName: settings.ownerLastName,
                      category: finalZone,
                      unitName: nameCtrl.text.trim(),
                    );

                    final newUnit = Unit(
                      id: unitId,
                      ownerId: '',
                      ownerEmail: '',
                      name: nameCtrl.text.trim(),
                      address: addrCtrl.text.trim(),
                      category: finalZone,
                      wifiSsid: wifiNameCtrl.text.trim(),
                      wifiPass: wifiPassCtrl.text.trim(),
                      cleanerPin: '',
                      reviewLink: reviewLinkCtrl.text.trim(),
                      contactOptions: {},
                    );

                    await unitsService.saveUnit(newUnit);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(t('btn_save'),
                      style: const TextStyle(color: Colors.white)),
                ),
              ],
            );
          });
        },
      ),
    );
  }

  // Helper functions
  DateTime _stripTime(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // Sort units
  List<Unit> _sortUnits(List<Unit> units, List<Booking> bookings) {
    final List<Unit> unitsCopy = List.from(units);
    final categoryGroups = _groupAndSortUnits(unitsCopy, bookings);
    final sortedKeys = _getSortedCategoryKeys(categoryGroups);

    final List<Unit> result = [];
    for (var key in sortedKeys) {
      result.addAll(categoryGroups[key]!);
    }
    return result;
  }

  Map<String, List<Unit>> _groupAndSortUnits(
      List<Unit> units, List<Booking> bookings) {
    final Map<String, List<Unit>> groups = {};

    for (var unit in units) {
      final key = unit.category ?? '';
      groups.putIfAbsent(key, () => []);
      groups[key]!.add(unit);
    }

    // Sort units within each group
    for (var key in groups.keys) {
      final list = groups[key]!;
      switch (_sortBy) {
        case 'name':
          list.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'busy':
          final counts = <String, int>{};
          for (var u in list) {
            counts[u.id] = bookings.where((b) => b.unitId == u.id).length;
          }
          list.sort((a, b) => (counts[b.id] ?? 0).compareTo(counts[a.id] ?? 0));
          break;
        case 'created':
          list.sort((a, b) => (a.createdAt ?? DateTime(2000))
              .compareTo(b.createdAt ?? DateTime(2000)));
          break;
      }
    }

    return groups;
  }

  List<String> _getSortedCategoryKeys(Map<String, List<Unit>> groups) {
    final keys = groups.keys.toList();

    keys.sort((a, b) {
      if (a.isEmpty) return -1;
      if (b.isEmpty) return 1;

      switch (_categorySortBy) {
        case 'name':
          return a.compareTo(b);
        case 'created':
          final aOldest = _getOldestDate(groups[a]!);
          final bOldest = _getOldestDate(groups[b]!);
          return aOldest.compareTo(bOldest);
        default:
          return a.compareTo(b);
      }
    });

    return keys;
  }

  DateTime _getOldestDate(List<Unit> units) {
    if (units.isEmpty) return DateTime(2000);
    DateTime oldest = units.first.createdAt ?? DateTime(2000);
    for (var u in units) {
      final d = u.createdAt ?? DateTime(2000);
      if (d.isBefore(oldest)) oldest = d;
    }
    return oldest;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final t = provider.translate;
    final primaryColor = provider.primaryColor;
    final textColor = provider.backgroundColor.computeLuminance() < 0.5
        ? Colors.white
        : Colors.black87;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;
    final isMobile = screenWidth < 1000;
    final isDark = provider.backgroundColor.computeLuminance() < 0.5;

    final unitsService = UnitsService();
    final bookingService = BookingService();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hide title on mobile
          if (!isMobile) ...[
            Text(
              t('nav_reception'),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
          ],

          Expanded(
            child: StreamBuilder<List<Booking>>(
                stream: bookingService.getBookingsStream(),
                builder: (context, bookingSnap) {
                  final bookings = bookingSnap.data ?? [];

                  return StreamBuilder<List<Unit>>(
                    stream: unitsService.getUnitsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                            child: Text("${t('msg_error')}: ${snapshot.error}",
                                style: const TextStyle(color: Colors.red)));
                      }
                      if (!snapshot.hasData) {
                        return Center(
                            child:
                                CircularProgressIndicator(color: primaryColor));
                      }

                      final units = _sortUnits(snapshot.data!, bookings);

                      // Collect all categories for visibility dropdown
                      final allCategories = <String>{};
                      for (var unit in units) {
                        allCategories.add(unit.category ?? '');
                      }

                      if (units.isEmpty) {
                        return Center(
                            child: Text(t('msg_no_units'),
                                style: TextStyle(color: textColor)));
                      }

                      // TODAY
                      final today = _stripTime(DateTime.now());
                      final checkInsToday = bookings
                          .where((b) => _isSameDay(b.startDate, today))
                          .toList();
                      final checkOutsToday = bookings
                          .where((b) => _isSameDay(b.endDate, today))
                          .toList();

                      // Turnovers today
                      final turnovers = <Map<String, dynamic>>[];
                      for (var unit in units) {
                        final unitBookings = bookings
                            .where((b) => b.unitId == unit.id)
                            .toList()
                          ..sort((a, b) => a.startDate.compareTo(b.startDate));

                        for (int i = 0; i < unitBookings.length - 1; i++) {
                          if (_isSameDay(
                                  _stripTime(unitBookings[i].endDate), today) &&
                              _isSameDay(
                                  _stripTime(unitBookings[i + 1].startDate),
                                  today)) {
                            turnovers.add({
                              'unit': unit,
                              'checkout': unitBookings[i],
                              'checkin': unitBookings[i + 1],
                            });
                          }
                        }
                      }

                      // TOMORROW
                      final tomorrow = today.add(const Duration(days: 1));
                      final checkInsTomorrow = bookings
                          .where((b) => _isSameDay(b.startDate, tomorrow))
                          .toList();
                      final checkOutsTomorrow = bookings
                          .where((b) => _isSameDay(b.endDate, tomorrow))
                          .toList();

                      // Turnovers Tomorrow
                      final turnoversTomorrow = <Map<String, dynamic>>[];
                      for (var unit in units) {
                        final unitBookings = bookings
                            .where((b) => b.unitId == unit.id)
                            .toList()
                          ..sort((a, b) => a.startDate.compareTo(b.startDate));

                        for (int i = 0; i < unitBookings.length - 1; i++) {
                          if (_isSameDay(_stripTime(unitBookings[i].endDate),
                                  tomorrow) &&
                              _isSameDay(
                                  _stripTime(unitBookings[i + 1].startDate),
                                  tomorrow)) {
                            turnoversTomorrow.add({
                              'unit': unit,
                              'checkout': unitBookings[i],
                              'checkin': unitBookings[i + 1],
                            });
                          }
                        }
                      }

                      return ListView(
                        children: [
                          // TOOLBAR (inside stream for access to units/categories)
                          _buildToolbar(
                            context,
                            isDark,
                            primaryColor,
                            textColor,
                            allCategories,
                          ),
                          const SizedBox(height: 30),

                          // RESPONSIVE INFO PANELS
                          if (isWideScreen)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildDailyScheduleWidget(
                                    context,
                                    t('day_today'),
                                    today,
                                    checkInsToday,
                                    checkOutsToday,
                                    turnovers,
                                    units,
                                    isDark,
                                    primaryColor,
                                    textColor,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildDailyScheduleWidget(
                                    context,
                                    t('day_tomorrow'),
                                    tomorrow,
                                    checkInsTomorrow,
                                    checkOutsTomorrow,
                                    turnoversTomorrow,
                                    units,
                                    isDark,
                                    primaryColor,
                                    textColor,
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildDailyScheduleWidget(
                                  context,
                                  t('day_today'),
                                  today,
                                  checkInsToday,
                                  checkOutsToday,
                                  turnovers,
                                  units,
                                  isDark,
                                  primaryColor,
                                  textColor,
                                ),
                                const SizedBox(height: 20),
                                _buildDailyScheduleWidget(
                                  context,
                                  t('day_tomorrow'),
                                  tomorrow,
                                  checkInsTomorrow,
                                  checkOutsTomorrow,
                                  turnoversTomorrow,
                                  units,
                                  isDark,
                                  primaryColor,
                                  textColor,
                                ),
                              ],
                            ),
                          const SizedBox(height: 30),

                          // UNITS LIST
                          ..._buildCategoryGroupedUnits(
                            units,
                            bookings,
                            isDark,
                            primaryColor,
                            textColor,
                          ),
                        ],
                      );
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // TOOLBAR (extracted for cleaner code)
  // =====================================================
  Widget _buildToolbar(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Set<String> allCategories,
  ) {
    final t = context.read<AppProvider>().translate;

    return Wrap(
      spacing: 15,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // SORT POPUP MENU
        PopupMenuButton<String>(
          tooltip: t('tooltip_sort'),
          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          offset: const Offset(0, 45),
          onSelected: (value) {
            setState(() {
              if (value == 'unit_name' ||
                  value == 'unit_busy' ||
                  value == 'unit_created') {
                _sortBy = value.replaceFirst('unit_', '');
              }
              if (value == 'cat_name' || value == 'cat_created') {
                _categorySortBy = value.replaceFirst('cat_', '');
              }
            });
          },
          itemBuilder: (context) => [
            // UNITS HEADER
            PopupMenuItem<String>(
              enabled: false,
              height: 30,
              child: Text(
                t('sort_units'),
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: 'unit_name',
              height: 40,
              child: Row(
                children: [
                  Icon(
                    _sortBy == 'name' ? Icons.check : null,
                    color: primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(t('sort_by_name'), style: TextStyle(color: textColor)),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'unit_busy',
              height: 40,
              child: Row(
                children: [
                  Icon(
                    _sortBy == 'busy' ? Icons.check : null,
                    color: primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(t('sort_by_occupancy'),
                      style: TextStyle(color: textColor)),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'unit_created',
              height: 40,
              child: Row(
                children: [
                  Icon(
                    _sortBy == 'created' ? Icons.check : null,
                    color: primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(t('sort_by_created'),
                      style: TextStyle(color: textColor)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            // ZONES HEADER
            PopupMenuItem<String>(
              enabled: false,
              height: 30,
              child: Text(
                t('sort_zones'),
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: 'cat_name',
              height: 40,
              child: Row(
                children: [
                  Icon(
                    _categorySortBy == 'name' ? Icons.check : null,
                    color: primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(t('sort_by_name'), style: TextStyle(color: textColor)),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'cat_created',
              height: 40,
              child: Row(
                children: [
                  Icon(
                    _categorySortBy == 'created' ? Icons.check : null,
                    color: primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(t('sort_by_created'),
                      style: TextStyle(color: textColor)),
                ],
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Icon(Icons.sort, color: primaryColor, size: 20),
          ),
        ),

        // ZONE VISIBILITY DROPDOWN
        PopupMenuButton<String>(
          tooltip: t('tooltip_visibility'),
          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          offset: const Offset(0, 45),
          onSelected: (value) {
            if (value == '_show_all') {
              setState(() => _hiddenCategories.clear());
            } else if (value == '_hide_all') {
              setState(() => _hiddenCategories.addAll(allCategories));
            } else {
              _toggleCategoryVisibility(value);
            }
          },
          itemBuilder: (context) {
            final sortedCategories = allCategories.toList()
              ..sort((a, b) {
                if (a.isEmpty) return -1;
                if (b.isEmpty) return 1;
                return a.compareTo(b);
              });

            return [
              // SHOW ALL
              PopupMenuItem<String>(
                value: '_show_all',
                height: 40,
                child: Row(
                  children: [
                    Icon(Icons.visibility, color: primaryColor, size: 18),
                    const SizedBox(width: 8),
                    Text(t('show_all'),
                        style: TextStyle(
                            color: textColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // HIDE ALL
              PopupMenuItem<String>(
                value: '_hide_all',
                height: 40,
                child: Row(
                  children: [
                    const Icon(Icons.visibility_off,
                        color: Colors.grey, size: 18),
                    const SizedBox(width: 8),
                    Text(t('hide_all'),
                        style: TextStyle(
                            color: textColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              // Individual categories
              ...sortedCategories.map((cat) {
                final isHidden = _hiddenCategories.contains(cat);
                final displayName = cat.isEmpty ? t('zone_none') : cat;
                return PopupMenuItem<String>(
                  value: cat,
                  height: 40,
                  child: Row(
                    children: [
                      Icon(
                        isHidden ? Icons.visibility_off : Icons.visibility,
                        color: isHidden ? Colors.grey : primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(displayName, style: TextStyle(color: textColor)),
                    ],
                  ),
                );
              }),
            ];
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Icon(
              _hiddenCategories.isEmpty
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: _hiddenCategories.isEmpty ? primaryColor : Colors.grey,
              size: 20,
            ),
          ),
        ),

        // NEW UNIT BUTTON
        ElevatedButton.icon(
          onPressed: () => _openNewUnitDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: isDark ? Colors.black : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          icon: const Icon(Icons.add, size: 20),
          label: Text(
            t('dialog_new_unit'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // BUILD CATEGORY GROUPED UNITS
  // =====================================================
  List<Widget> _buildCategoryGroupedUnits(
    List<Unit> units,
    List<Booking> bookings,
    bool isDark,
    Color primaryColor,
    Color textColor,
  ) {
    final t = context.read<AppProvider>().translate;
    final List<Widget> widgets = [];

    final categoryGroups = _groupAndSortUnits(units, bookings);
    final sortedKeys = _getSortedCategoryKeys(categoryGroups);

    for (var categoryKey in sortedKeys) {
      final categoryUnits = categoryGroups[categoryKey]!;
      final isHidden = _hiddenCategories.contains(categoryKey);
      final displayName = categoryKey.isEmpty ? t('zone_none') : categoryKey;

      // Category Header
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: Row(
            children: [
              Icon(
                categoryKey.isEmpty ? Icons.home_outlined : Icons.apartment,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$displayName (${categoryUnits.length})',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isHidden ? Icons.visibility_off : Icons.visibility,
                  color: isHidden ? Colors.grey : primaryColor,
                  size: 20,
                ),
                tooltip: isHidden ? t('show_category') : t('hide_category'),
                onPressed: () => _toggleCategoryVisibility(categoryKey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      );

      // Units (if not hidden)
      if (!isHidden) {
        for (var unit in categoryUnits) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 28),
              child: UnitListItem(unit: unit),
            ),
          );
        }
      }
    }

    return widgets;
  }

  // =====================================================
  // DAILY SCHEDULE WIDGET
  // =====================================================
  Widget _buildDailyScheduleWidget(
    BuildContext context,
    String label,
    DateTime date,
    List<Booking> checkIns,
    List<Booking> checkOuts,
    List<Map<String, dynamic>> turnovers,
    List<Unit> units,
    bool isDark,
    Color primaryColor,
    Color textColor,
  ) {
    final t = context.read<AppProvider>().translate;
    final dateStr = DateFormat('EEEE, dd.MM.yyyy').format(date);

    String getUnitName(String unitId) {
      try {
        return units.firstWhere((u) => u.id == unitId).name;
      } catch (_) {
        return unitId;
      }
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            Row(
              children: [
                Icon(Icons.calendar_today, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$label - $dateStr',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: isDark ? Colors.white24 : Colors.black12),
            const SizedBox(height: 8),

            // CHECK-INS
            Row(
              children: [
                const Icon(Icons.login, color: Colors.green, size: 18),
                const SizedBox(width: 6),
                Text(
                  "${t('check_ins')}: ${checkIns.length}",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (checkIns.isEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 4),
                child: Text(t('no_activity'),
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              )
            else
              ...checkIns.map((b) => Padding(
                    padding: const EdgeInsets.only(left: 24, top: 4),
                    child: Text(
                      '${getUnitName(b.unitId)} - ${b.guestName} (${b.checkInTime})',
                      style: TextStyle(color: textColor, fontSize: 13),
                    ),
                  )),
            const SizedBox(height: 12),

            // CHECK-OUTS
            Row(
              children: [
                const Icon(Icons.logout, color: Colors.red, size: 18),
                const SizedBox(width: 6),
                Text(
                  "${t('check_outs')}: ${checkOuts.length}",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (checkOuts.isEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 4),
                child: Text(t('no_activity'),
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              )
            else
              ...checkOuts.map((b) => Padding(
                    padding: const EdgeInsets.only(left: 24, top: 4),
                    child: Text(
                      '${getUnitName(b.unitId)} - ${b.guestName} (${b.checkOutTime})',
                      style: TextStyle(color: textColor, fontSize: 13),
                    ),
                  )),
            const SizedBox(height: 12),

            // TURNOVERS
            Row(
              children: [
                const Icon(Icons.sync, color: Colors.orange, size: 18),
                const SizedBox(width: 6),
                Text(
                  "${t('turnovers')}: ${turnovers.length}",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (turnovers.isEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 4),
                child: Text(t('no_activity'),
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              )
            else
              ...turnovers.map((to) {
                final unit = to['unit'] as Unit;
                final checkout = to['checkout'] as Booking;
                final checkin = to['checkin'] as Booking;
                return Padding(
                  padding: const EdgeInsets.only(left: 24, top: 4),
                  child: Text(
                    '${unit.name}: ${checkout.guestName} → ${checkin.guestName}',
                    style: TextStyle(color: textColor, fontSize: 13),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
