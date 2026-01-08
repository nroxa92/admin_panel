// FILE: lib/screens/dashboard_screen.dart
// STATUS: UPDATED - GoRouter navigation (URL-based, refresh stays on same page)
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
  // ✅ NOVO: Prima route iz GoRouter
  final String initialRoute;

  const DashboardScreen({super.key, this.initialRoute = 'reception'});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ✅ NOVO: Mapiranje route -> index
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

  // Lista ekrana (Tabovi)
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

  // ✅ NOVO: Navigacija putem GoRouter
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
      drawer: isMobile ? Drawer(child: _buildSidebar(context)) : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(context),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final t = provider.translate;
    final primaryColor = provider.primaryColor;
    final isDark = provider.backgroundColor.computeLuminance() < 0.5;
    final textColor = isDark ? Colors.white : Colors.black87;
    final sidebarColor = isDark
        ? Color.alphaBlend(
            Colors.white.withValues(alpha: 0.05), provider.backgroundColor)
        : Color.alphaBlend(
            Colors.black.withValues(alpha: 0.05), provider.backgroundColor);

    return Container(
      width: 250,
      color: sidebarColor,
      child: Column(
        children: [
          Container(
            height: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                  bottom:
                      BorderSide(color: primaryColor.withValues(alpha: 0.2))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield, color: primaryColor, size: 28),
                const SizedBox(width: 10),
                Text("VILLA OS",
                    style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // ✅ NOVO: Koristi _navigateTo umjesto setState
          _menuItem(0, 'reception', t('nav_reception'),
              Icons.dashboard_customize_outlined, primaryColor, textColor),
          _menuItem(1, 'calendar', t('nav_calendar'),
              Icons.calendar_month_outlined, primaryColor, textColor),
          _menuItem(2, 'settings', t('nav_settings'),
              Icons.settings_suggest_outlined, primaryColor, textColor),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: OutlinedButton.icon(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout, size: 18),
              label: Text(t('nav_logout')),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[300],
                side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ✅ UPDATED: Prima route string za navigaciju
  Widget _menuItem(int index, String route, String title, IconData icon,
      Color primary, Color textColor) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? primary : Colors.grey, size: 24),
      title: Text(title,
          style: TextStyle(
              color: isSelected ? textColor : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedTileColor: primary.withValues(alpha: 0.1),
      onTap: () => _navigateTo(context, route), // ✅ GoRouter navigacija
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
  String _sortBy = 'name'; // Unit sort
  String _categorySortBy = 'name'; // Category sort
  final Set<String> _hiddenCategories =
      {}; // Skrivene kategorije (prazan string = "Bez kategorije")

  void _openNewUnitDialog(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final settings = provider.settings;
    final primaryColor = provider.primaryColor;

    // 🔍 DEBUG - provjeri categories
    debugPrint(
        '🔍 _openNewUnitDialog - settings.categories: ${settings.categories}');
    debugPrint(
        '🔍 _openNewUnitDialog - categories length: ${settings.categories.length}');

    // Controllers
    final nameCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    final wifiNameCtrl = TextEditingController();
    final wifiPassCtrl = TextEditingController();
    final reviewLinkCtrl = TextEditingController();
    final newZoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    String? selectedZone;
    String? newZoneName; // Nova zona koja je potvrđena kvačicom
    bool isLoading = false;
    bool isAddingNewZone = false;
    bool isSavingZone = false; // Loading za spremanje zone

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title:
                const Text("New Unit", style: TextStyle(color: Colors.white)),
            content: SizedBox(
              width: 400,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Zona dropdown/input
                      const Text("Zona",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 6),

                      // Ako dodaje novu zonu - prikaži input
                      if (isAddingNewZone)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: primaryColor),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: newZoneCtrl,
                                  autofocus: true,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: "Naziv nove zone...",
                                    hintStyle: TextStyle(color: Colors.white38),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              // Kvačica - spremi novu zonu u Firebase
                              isSavingZone
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.green),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.check,
                                          color: Colors.green, size: 20),
                                      onPressed: () async {
                                        final zoneName =
                                            newZoneCtrl.text.trim();
                                        if (zoneName.isEmpty) return;

                                        setDialogState(
                                            () => isSavingZone = true);

                                        try {
                                          // Spremi novu zonu u Firebase ODMAH
                                          await UnitsService()
                                              .addCategory(zoneName);

                                          // Stream će automatski osvježiti settings

                                          if (context.mounted) {
                                            setDialogState(() {
                                              newZoneName = zoneName;
                                              isAddingNewZone = false;
                                              isSavingZone = false;
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Zona "$zoneName" spremljena!'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            setDialogState(
                                                () => isSavingZone = false);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text('Greška: $e'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                              IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.red, size: 20),
                                onPressed: () {
                                  setDialogState(() {
                                    isAddingNewZone = false;
                                    newZoneName = null;
                                    newZoneCtrl.clear();
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      // Ako je nova zona potvrđena, prikaži je kao chip
                      else if (newZoneName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  size: 18, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Nova zona: $newZoneName",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close,
                                    size: 18, color: Colors.white70),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () =>
                                    setDialogState(() => newZoneName = null),
                              ),
                            ],
                          ),
                        )
                      else
                        // Dropdown za odabir zone
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedZone,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF2C2C2C),
                              hint: const Text("Bez zone",
                                  style: TextStyle(color: Colors.white70)),
                              style: const TextStyle(color: Colors.white),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text("Bez zone",
                                      style: TextStyle(color: Colors.white70)),
                                ),
                                ...settings.categories
                                    .map((zone) => DropdownMenuItem<String>(
                                          value: zone,
                                          child: Text(zone),
                                        )),
                                // Divider
                                if (settings.categories.isNotEmpty)
                                  const DropdownMenuItem<String>(
                                    enabled: false,
                                    value: '__divider__',
                                    child: Divider(color: Colors.grey),
                                  ),
                                // + Dodaj novu zonu
                                const DropdownMenuItem<String>(
                                  value: '__add_new__',
                                  child: Row(
                                    children: [
                                      Icon(Icons.add_circle_outline,
                                          size: 18, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text("+ Dodaj novu zonu",
                                          style:
                                              TextStyle(color: Colors.green)),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                if (val == '__add_new__') {
                                  setDialogState(() {
                                    isAddingNewZone = true;
                                    selectedZone = null;
                                  });
                                } else if (val != '__divider__') {
                                  setDialogState(() => selectedZone = val);
                                }
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameCtrl,
                        style: const TextStyle(color: Colors.white),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? "Required" : null,
                        decoration: InputDecoration(
                          labelText: "Unit Name *",
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: addrCtrl,
                        style: const TextStyle(color: Colors.white),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? "Required" : null,
                        decoration: InputDecoration(
                          labelText: "Address *",
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: wifiNameCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "WiFi SSID",
                                labelStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.black26,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: wifiPassCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "WiFi Pass",
                                labelStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.black26,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: reviewLinkCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Review Link (Optional)",
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;

                        // Provjeri ako je u modu dodavanja nove zone ali nije potvrdio
                        if (isAddingNewZone) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Potvrdite novu zonu ili je otkažite"),
                                backgroundColor: Colors.orange),
                          );
                          return;
                        }

                        setDialogState(() => isLoading = true);

                        try {
                          final service = UnitsService();

                          // Koristi novu zonu ako je potvrđena, inače selectedZone
                          // (zona je već spremljena u Firebase kod kvačice)
                          String? finalZone = newZoneName ?? selectedZone;

                          final unitId = await service.generateUnitId(
                            ownerFirstName: settings.ownerFirstName,
                            ownerLastName: settings.ownerLastName,
                            category: finalZone,
                            unitName: nameCtrl.text.trim(),
                          );

                          final unit = Unit(
                            id: unitId,
                            ownerId: '',
                            ownerEmail: '',
                            name: nameCtrl.text.trim(),
                            address: addrCtrl.text.trim(),
                            wifiSsid: wifiNameCtrl.text.trim(),
                            wifiPass: wifiPassCtrl.text.trim(),
                            cleanerPin: '',
                            reviewLink: reviewLinkCtrl.text.trim(),
                            contactOptions: {},
                            category: finalZone,
                          );

                          await service.saveUnit(unit);

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Unit created: $unitId"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Error: $e"),
                                  backgroundColor: Colors.red),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setDialogState(() => isLoading = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2),
                      )
                    : const Text("CREATE",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper: Toggle visibility kategorije
  void _toggleCategoryVisibility(String category) {
    setState(() {
      if (_hiddenCategories.contains(category)) {
        _hiddenCategories.remove(category);
      } else {
        _hiddenCategories.add(category);
      }
    });
  }

  // Helper: Dohvati datum najstarijeg unita u listi
  DateTime _getOldestUnitDate(List<Unit> units) {
    if (units.isEmpty) return DateTime(2000);
    DateTime oldest = units.first.createdAt ?? DateTime(2000);
    for (var unit in units) {
      final created = unit.createdAt ?? DateTime(2000);
      if (created.isBefore(oldest)) {
        oldest = created;
      }
    }
    return oldest;
  }

  // Vraća mapu: categoryKey -> List<Unit> (sortirano)
  Map<String, List<Unit>> _groupAndSortUnits(
      List<Unit> units, List<Booking> bookings) {
    // =========================================
    // KORAK 1: Grupiraj jedinice po kategorijama
    // =========================================
    final Map<String, List<Unit>> categoryGroups = {};

    for (var unit in units) {
      final catKey = unit.category ?? ''; // Prazan string = "Bez kategorije"
      categoryGroups.putIfAbsent(catKey, () => []);
      categoryGroups[catKey]!.add(unit);
    }

    // =========================================
    // KORAK 2: Sortiraj jedinice unutar svake kategorije
    // =========================================
    for (var catKey in categoryGroups.keys) {
      final catUnits = categoryGroups[catKey]!;

      switch (_sortBy) {
        case 'name':
          catUnits.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'busy':
          catUnits.sort((a, b) {
            int daysA = _countBookedDays(a.id, bookings);
            int daysB = _countBookedDays(b.id, bookings);
            return daysB.compareTo(daysA);
          });
          break;
        case 'created':
          catUnits.sort((a, b) => (a.createdAt ?? DateTime(2000))
              .compareTo(b.createdAt ?? DateTime(2000)));
          break;
      }
    }

    return categoryGroups;
  }

  // Vraća sortiranu listu kategorija
  List<String> _getSortedCategoryKeys(Map<String, List<Unit>> categoryGroups) {
    final categoryKeys = categoryGroups.keys.toList();

    // "Bez kategorije" (prazan string) uvijek PRVA
    categoryKeys.sort((a, b) {
      if (a.isEmpty) return -1;
      if (b.isEmpty) return 1;

      switch (_categorySortBy) {
        case 'name':
          return a.compareTo(b);
        case 'created':
          final aOldest = _getOldestUnitDate(categoryGroups[a]!);
          final bOldest = _getOldestUnitDate(categoryGroups[b]!);
          return aOldest.compareTo(bOldest);
        default:
          return a.compareTo(b);
      }
    });

    return categoryKeys;
  }

  // Stara metoda - zadržana za kompatibilnost
  List<Unit> _sortUnits(List<Unit> units, List<Booking> bookings) {
    final groups = _groupAndSortUnits(units, bookings);
    final sortedKeys = _getSortedCategoryKeys(groups);

    final List<Unit> result = [];
    for (var key in sortedKeys) {
      result.addAll(groups[key]!);
    }
    return result;
  }

  int _countBookedDays(String unitId, List<Booking> bookings) {
    int count = 0;
    final now = DateTime.now();
    final end = now.add(const Duration(days: 30));
    for (var b in bookings) {
      if (b.unitId == unitId) {
        if (b.startDate.isBefore(end) && b.endDate.isAfter(now)) {
          count += b.endDate.difference(b.startDate).inDays;
        }
      }
    }
    return count;
  }

  DateTime _stripTime(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final unitsService = UnitsService();
    final bookingService = BookingService();
    final provider = context.watch<AppProvider>();
    final t = provider.translate;
    final primaryColor = provider.primaryColor;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;
    final isMobile = screenWidth < 1000;
    final isDark = provider.backgroundColor.computeLuminance() < 0.5;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hide title on mobile (AppBar already shows it)
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

          // Toolbar: Sort + New Unit button
          Wrap(
            spacing: 15,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // COMBINED SORT POPUP MENU (Units + Categories)
              PopupMenuButton<String>(
                tooltip: "Sort Options",
                color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                offset: const Offset(0, 45),
                onSelected: (value) {
                  setState(() {
                    // Unit sort options
                    if (value == 'unit_name' ||
                        value == 'unit_busy' ||
                        value == 'unit_created') {
                      _sortBy = value.replaceFirst('unit_', '');
                    }
                    // Category sort options
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
                      "UNITS",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  // Unit: Name
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
                        Text("Name", style: TextStyle(color: textColor)),
                      ],
                    ),
                  ),
                  // Unit: Occupancy
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
                        Text("Occupancy", style: TextStyle(color: textColor)),
                      ],
                    ),
                  ),
                  // Unit: Created
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
                        Text("Created", style: TextStyle(color: textColor)),
                      ],
                    ),
                  ),
                  // DIVIDER
                  const PopupMenuDivider(),
                  // ZONES HEADER
                  PopupMenuItem<String>(
                    enabled: false,
                    height: 30,
                    child: Text(
                      "ZONES",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  // Cat: Name
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
                        Text("Name", style: TextStyle(color: textColor)),
                      ],
                    ),
                  ),
                  // Cat: Created
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
                        Text("Created", style: TextStyle(color: textColor)),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Sort",
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.sort, color: primaryColor, size: 20),
                    ],
                  ),
                ),
              ),

              // NEW UNIT BUTTON
              ElevatedButton.icon(
                onPressed: () => _openNewUnitDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
          ),

          const SizedBox(height: 30),

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
                            child: Text("Error: ${snapshot.error}",
                                style: const TextStyle(color: Colors.red)));
                      }
                      if (!snapshot.hasData) {
                        return Center(
                            child:
                                CircularProgressIndicator(color: primaryColor));
                      }

                      // SORTIRAJ JEDINICE
                      final units = _sortUnits(snapshot.data!, bookings);

                      if (units.isEmpty) {
                        return Center(
                            child: Text("No units found.",
                                style: TextStyle(color: textColor)));
                      }

                      // Filter today's bookings
                      final today = _stripTime(DateTime.now());
                      final checkInsToday = bookings
                          .where((b) => _isSameDay(b.startDate, today))
                          .toList();
                      final checkOutsToday = bookings
                          .where((b) => _isSameDay(b.endDate, today))
                          .toList();

                      // Turnovers: where checkout and checkin happen same day on same unit
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

                      // TOMORROW INFO
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
                          // RESPONSIVE INFO PANELS (TODAY + TOMORROW)
                          if (isWideScreen)
                            // Desktop: Side by side
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildDailyScheduleWidget(
                                    context,
                                    'DANAS',
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
                                    'SUTRA',
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
                            // Mobile: Stacked
                            Column(
                              children: [
                                _buildDailyScheduleWidget(
                                  context,
                                  'DANAS',
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
                                  'SUTRA',
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

                          // UNITS LIST - Grouped by Categories
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
  // BUILD CATEGORY GROUPED UNITS
  // =====================================================
  List<Widget> _buildCategoryGroupedUnits(
    List<Unit> units,
    List<Booking> bookings,
    bool isDark,
    Color primaryColor,
    Color textColor,
  ) {
    final List<Widget> widgets = [];

    // Grupiraj i sortiraj
    final categoryGroups = _groupAndSortUnits(units, bookings);
    final sortedKeys = _getSortedCategoryKeys(categoryGroups);

    for (var categoryKey in sortedKeys) {
      final categoryUnits = categoryGroups[categoryKey]!;
      final isHidden = _hiddenCategories.contains(categoryKey);
      final displayName = categoryKey.isEmpty ? 'Bez zone' : categoryKey;

      // Category Header
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: Row(
            children: [
              // Category icon
              Icon(
                categoryKey.isEmpty ? Icons.home_outlined : Icons.apartment,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              // Category name
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
              // Visibility toggle (oko)
              IconButton(
                icon: Icon(
                  isHidden ? Icons.visibility_off : Icons.visibility,
                  color: isHidden ? Colors.grey : primaryColor,
                  size: 20,
                ),
                tooltip: isHidden ? 'Show category' : 'Hide category',
                onPressed: () => _toggleCategoryVisibility(categoryKey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      );

      // Units in category (if not hidden)
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
  // DAILY SCHEDULE WIDGET BUILDER
  // =====================================================
  Widget _buildDailyScheduleWidget(
    BuildContext context,
    String label, // "DANAS" or "SUTRA"
    DateTime date,
    List<Booking> checkIns,
    List<Booking> checkOuts,
    List<Map<String, dynamic>> turnovers,
    List<Unit> units,
    bool isDark,
    Color primaryColor,
    Color textColor,
  ) {
    final dateStr = DateFormat('EEEE, dd.MM.yyyy').format(date);

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
            Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),
            const SizedBox(height: 12),

            // CHECK-INS
            _buildSectionRow(
              icon: Icons.arrow_downward,
              iconColor: Colors.blue,
              title: 'CHECK-IN (${checkIns.length})',
              items: checkIns,
              units: units,
              textColor: textColor,
              formatter: (b, unit) =>
                  '${b.checkInTime} - ${b.guestName} @ ${unit.name}',
              emptyMessage: 'Nema check-inova',
            ),

            const SizedBox(height: 12),

            // CHECK-OUTS
            _buildSectionRow(
              icon: Icons.arrow_upward,
              iconColor: Colors.red,
              title: 'CHECK-OUT (${checkOuts.length})',
              items: checkOuts,
              units: units,
              textColor: textColor,
              formatter: (b, unit) =>
                  '${b.checkOutTime} - ${b.guestName} @ ${unit.name}',
              emptyMessage: 'Nema check-outova',
            ),

            if (turnovers.isNotEmpty) ...[
              const SizedBox(height: 12),
              // TURNOVERS
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.sync, color: Colors.orange, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TURNOVER (${turnovers.length})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...turnovers.map((t) {
                          final unit = t['unit'] as Unit;
                          final checkout = t['checkout'] as Booking;
                          final checkin = t['checkin'] as Booking;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              '• ${unit.name}: ${checkout.checkOutTime} out → ${checkin.checkInTime} in',
                              style: TextStyle(
                                fontSize: 11,
                                color: textColor.withValues(alpha: 0.8),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper za section rows u Daily Schedule
  Widget _buildSectionRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Booking> items,
    required List<Unit> units,
    required Color textColor,
    required String Function(Booking, Unit) formatter,
    required String emptyMessage,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 4),
              if (items.isEmpty)
                Text(
                  emptyMessage,
                  style: TextStyle(
                    fontSize: 11,
                    color: textColor.withValues(alpha: 0.5),
                  ),
                )
              else
                ...items.map((b) {
                  final unit = units.firstWhere(
                    (u) => u.id == b.unitId,
                    orElse: () => Unit(
                      id: '',
                      ownerId: '',
                      ownerEmail: '',
                      name: 'Unknown',
                      address: '',
                      wifiSsid: '',
                      wifiPass: '',
                      contactOptions: {},
                    ),
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '• ${formatter(b, unit)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: textColor.withValues(alpha: 0.8),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}
