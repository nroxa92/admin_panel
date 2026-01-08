// FILE: lib/screens/booking_screen.dart
// STATUS: REFACTORED - Calendar logic moved to booking_calendar.dart
// CHANGES:
//   - Removed painters, scroll behavior, DragData (now in booking_calendar.dart)
//   - Removed _buildHorizontalLayout, _buildVerticalLayout (now in BookingCalendarWidget)
//   - Removed _buildBookingBlock, _buildTurnoverLines (now in BookingCalendarWidget)
//   - Added BookingCalendarWidget usage
//   - Added Booking History PDF option (#6)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/unit_model.dart';
import '../models/booking_model.dart';
import '../services/units_service.dart';
import '../services/booking_service.dart';
import '../services/pdf_service.dart';
import '../providers/app_provider.dart';
import '../widgets/booking_calendar.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final UnitsService _unitsService = UnitsService();
  final BookingService _bookingService = BookingService();

  bool _isVerticalLayout = false;
  String _selectedPeriod = '30';
  int _daysToShow = 30;
  String _sortBy = 'name';
  String _categorySortBy = 'name'; // Sortiranje kategorija
  final Set<String> _hiddenCategories =
      {}; // Skrivene kategorije (prazan string = "Bez zone")

  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    _startDate = _stripTime(DateTime.now().subtract(const Duration(days: 1)));
  }

  DateTime _stripTime(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  // Toggle visibility kategorije
  void _toggleCategoryVisibility(String category) {
    setState(() {
      if (_hiddenCategories.contains(category)) {
        _hiddenCategories.remove(category);
      } else {
        _hiddenCategories.add(category);
      }
    });
  }

  void _onPeriodChanged(String? val, List<Booking> bookings) {
    if (val == null) return;

    final yesterday =
        _stripTime(DateTime.now().subtract(const Duration(days: 1)));

    setState(() {
      _selectedPeriod = val;
      _startDate = yesterday;

      if (val == 'ALL') {
        if (bookings.isEmpty) {
          _daysToShow = 30;
        } else {
          DateTime minDate = _stripTime(bookings.first.startDate);
          DateTime maxDate = _stripTime(bookings.first.endDate);

          for (var b in bookings) {
            final bStart = _stripTime(b.startDate);
            final bEnd = _stripTime(b.endDate);

            if (bStart.isBefore(minDate)) minDate = bStart;
            if (bEnd.isAfter(maxDate)) maxDate = bEnd;
          }

          final finalEnd = maxDate.add(const Duration(days: 1));
          _daysToShow = finalEnd.difference(minDate).inDays;
          _startDate = minDate;
        }
      } else {
        _daysToShow = int.parse(val);
      }
    });
  }

  List<Unit> _sortUnits(List<Unit> units, List<Booking> bookings) {
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
    // KORAK 2: Sortiraj kategorije
    // =========================================
    final categoryKeys = categoryGroups.keys.toList();

    // "Bez kategorije" (prazan string) uvijek PRVA
    categoryKeys.sort((a, b) {
      if (a.isEmpty) return -1; // "Bez kategorije" prva
      if (b.isEmpty) return 1;

      switch (_categorySortBy) {
        case 'name':
          return a.compareTo(b);
        case 'created':
          // Sortiraj po najstarijem unitu u kategoriji
          final aOldest = _getOldestUnitDate(categoryGroups[a]!);
          final bOldest = _getOldestUnitDate(categoryGroups[b]!);
          return aOldest.compareTo(bOldest);
        default:
          return a.compareTo(b);
      }
    });

    // =========================================
    // KORAK 3: Sortiraj jedinice unutar svake kategorije
    // =========================================
    for (var catKey in categoryKeys) {
      final catUnits = categoryGroups[catKey]!;

      switch (_sortBy) {
        case 'name':
          catUnits.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'occupancy':
          final counts = <String, int>{};
          for (var unit in catUnits) {
            counts[unit.id] = bookings.where((b) => b.unitId == unit.id).length;
          }
          catUnits
              .sort((a, b) => (counts[b.id] ?? 0).compareTo(counts[a.id] ?? 0));
          break;
        case 'created':
          catUnits.sort((a, b) => (a.createdAt ?? DateTime(2000))
              .compareTo(b.createdAt ?? DateTime(2000)));
          break;
      }
    }

    // =========================================
    // KORAK 4: Spoji sve u jednu listu
    // =========================================
    final List<Unit> sortedUnits = [];
    for (var catKey in categoryKeys) {
      sortedUnits.addAll(categoryGroups[catKey]!);
    }

    return sortedUnits;
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

  // =====================================================
  // HANDLE DROP - Called from BookingCalendarWidget
  // =====================================================
  Future<void> _handleDrop(
      Booking booking, Unit unit, DateTime droppedDate) async {
    final duration = booking.endDate.difference(booking.startDate);
    final baseDate = _stripTime(droppedDate);

    final newStart = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      booking.startDate.hour,
      booking.startDate.minute,
    );
    final newEnd = newStart.add(duration);

    try {
      final updatedBooking = Booking(
        id: booking.id,
        ownerId: booking.ownerId,
        unitId: unit.id,
        guestName: booking.guestName,
        startDate: newStart,
        endDate: newEnd,
        status: booking.status,
        note: booking.note,
        isScanned: booking.isScanned,
        guestCount: booking.guestCount,
        checkInTime: booking.checkInTime,
        checkOutTime: booking.checkOutTime,
      );

      await _bookingService.updateBooking(updatedBooking);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Booking moved successfully!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  // =====================================================
  // BUILD
  // =====================================================
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.backgroundColor.computeLuminance() < 0.5;
    final textColor = isDark ? Colors.white : Colors.black87;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: provider.backgroundColor,
          body: StreamBuilder<List<Booking>>(
            stream: _bookingService.getBookingsStream(),
            builder: (context, bookingSnap) {
              final bookings = bookingSnap.data ?? [];
              return StreamBuilder<List<Unit>>(
                stream: _unitsService.getUnitsStream(),
                builder: (context, unitSnap) {
                  final units = _sortUnits(unitSnap.data ?? [], bookings);
                  if (!unitSnap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final isMobile = constraints.maxWidth < 600;

                  return Column(
                    children: [
                      // Title (desktop only)
                      if (!isMobile)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Raspored rezervacija",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),

                      // Toolbar
                      _buildToolbar(provider, isDark, textColor, bookings,
                          units, isMobile),

                      // Calendar Widget
                      Expanded(
                        child: BookingCalendarWidget(
                          // Filtriraj jedinice iz skrivenih kategorija
                          units: units
                              .where((u) =>
                                  !_hiddenCategories.contains(u.category ?? ''))
                              .toList(),
                          bookings: bookings,
                          isVerticalLayout: _isVerticalLayout,
                          startDate: _startDate,
                          daysToShow: _daysToShow,
                          onBookingDoubleTap: _showBookingDetails,
                          onDrop: _handleDrop,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // =====================================================
  // TOOLBAR
  // =====================================================
  Widget _buildToolbar(AppProvider provider, bool isDark, Color textColor,
      List<Booking> bookings, List<Unit> units, bool isMobile) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(
            bottom:
                BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
      ),
      child: Row(
        children: [
          // Rotate button
          IconButton(
            icon: Icon(_isVerticalLayout ? Icons.more_horiz : Icons.more_vert),
            tooltip: "Rotate View",
            color: textColor,
            onPressed: () {
              setState(() => _isVerticalLayout = !_isVerticalLayout);
            },
          ),

          const SizedBox(width: 15),

          // Period selector - isti stil kao Sort
          PopupMenuButton<String>(
            tooltip: "Select Period",
            color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            offset: const Offset(0, 45),
            onSelected: (val) => _onPeriodChanged(val, bookings),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: '30',
                height: 40,
                child: Row(
                  children: [
                    Icon(
                      _selectedPeriod == '30' ? Icons.check : null,
                      color: provider.primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text("30 Days", style: TextStyle(color: textColor)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: '60',
                height: 40,
                child: Row(
                  children: [
                    Icon(
                      _selectedPeriod == '60' ? Icons.check : null,
                      color: provider.primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text("60 Days", style: TextStyle(color: textColor)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: '90',
                height: 40,
                child: Row(
                  children: [
                    Icon(
                      _selectedPeriod == '90' ? Icons.check : null,
                      color: provider.primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text("90 Days", style: TextStyle(color: textColor)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'ALL',
                height: 40,
                child: Row(
                  children: [
                    Icon(
                      _selectedPeriod == 'ALL' ? Icons.check : null,
                      color: provider.primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text("All Season", style: TextStyle(color: textColor)),
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
              child: Icon(Icons.calendar_month,
                  color: provider.primaryColor, size: 20),
            ),
          ),

          const SizedBox(width: 10),

          // Combined Sort PopupMenu (Units + Categories)
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
                    value == 'unit_occupancy' ||
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
                    color: provider.primaryColor,
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
                      color: provider.primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text("Name", style: TextStyle(color: textColor)),
                  ],
                ),
              ),
              // Unit: Occupancy
              PopupMenuItem<String>(
                value: 'unit_occupancy',
                height: 40,
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'occupancy' ? Icons.check : null,
                      color: provider.primaryColor,
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
                      color: provider.primaryColor,
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
                    color: provider.primaryColor,
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
                      color: provider.primaryColor,
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
                      color: provider.primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text("Created", style: TextStyle(color: textColor)),
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
              child: Icon(Icons.sort, color: provider.primaryColor, size: 20),
            ),
          ),

          const SizedBox(width: 10),

          // Zone visibility toggle (oko)
          PopupMenuButton<String>(
            tooltip: "Toggle Zone Visibility",
            color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            offset: const Offset(0, 45),
            onSelected: (category) => _toggleCategoryVisibility(category),
            itemBuilder: (context) {
              // Dohvati sve kategorije iz units
              final categories = <String>{};
              for (var unit in units) {
                categories.add(unit.category ?? '');
              }
              final sortedCategories = categories.toList()
                ..sort((a, b) {
                  if (a.isEmpty) return -1;
                  if (b.isEmpty) return 1;
                  return a.compareTo(b);
                });

              return sortedCategories.map((cat) {
                final isHidden = _hiddenCategories.contains(cat);
                final displayName = cat.isEmpty ? "Bez zone" : cat;
                return PopupMenuItem<String>(
                  value: cat,
                  height: 40,
                  child: Row(
                    children: [
                      Icon(
                        isHidden ? Icons.visibility_off : Icons.visibility,
                        color: isHidden ? Colors.grey : provider.primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(displayName, style: TextStyle(color: textColor)),
                    ],
                  ),
                );
              }).toList();
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
                color: _hiddenCategories.isEmpty
                    ? provider.primaryColor
                    : Colors.grey,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Print button
          IconButton(
            icon: const Icon(Icons.print),
            color: textColor,
            tooltip: "Print Menu",
            onPressed: () => _showPrintMenu(context, bookings, units),
          ),

          const SizedBox(width: 15),

          // NEW button - Responsive
          isMobile
              ? ElevatedButton(
                  onPressed: () => _showBookingDialog(null, null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider.primaryColor,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: const Icon(Icons.add, size: 20),
                )
              : ElevatedButton.icon(
                  onPressed: () => _showBookingDialog(null, null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider.primaryColor,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    "NEW",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),

          const Spacer(),
        ],
      ),
    );
  }

  // =====================================================
  // BOOKING DETAILS DIALOG
  // =====================================================
  void _showBookingDetails(Booking b) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF0F0F0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.black, width: 2)),
        contentPadding: const EdgeInsets.all(0),
        content: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(b.guestName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: b.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(b.status.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // Details
              _detailRow("Unit:", b.unitId),
              _detailRow("Check-in:",
                  "${DateFormat('dd.MM.yyyy').format(b.startDate)} ${b.checkInTime}"),
              _detailRow("Check-out:",
                  "${DateFormat('dd.MM.yyyy').format(b.endDate)} ${b.checkOutTime}"),
              _detailRow("Pax:", "${b.guestCount} persons"),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _circleBtn(Icons.edit, Colors.blue, "Edit", () {
                    Navigator.pop(ctx);
                    _showBookingDialog(b, null);
                  }),
                  _circleBtn(Icons.delete, Colors.red, "Delete", () async {
                    final confirm = await _confirmDelete(ctx);
                    if (confirm) {
                      await _bookingService.deleteBooking(b.id);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                    }
                  }),
                  if (b.status != 'confirmed')
                    _circleBtn(Icons.check, Colors.green, "Confirm", () async {
                      final updated = Booking(
                          id: b.id,
                          ownerId: b.ownerId,
                          unitId: b.unitId,
                          guestName: b.guestName,
                          startDate: b.startDate,
                          endDate: b.endDate,
                          status: 'confirmed',
                          note: b.note,
                          isScanned: b.isScanned,
                          guestCount: b.guestCount,
                          checkInTime: b.checkInTime,
                          checkOutTime: b.checkOutTime);
                      await _bookingService.updateBooking(updated);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                    }),
                  _circleBtn(Icons.close, Colors.grey, "Close",
                      () => Navigator.pop(ctx)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _circleBtn(
      IconData icon, Color color, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            color: Colors.white,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text("Delete Booking?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: const Text("No")),
              TextButton(
                  onPressed: () => Navigator.pop(c, true),
                  child:
                      const Text("Yes", style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;
  }

  // =====================================================
  // BOOKING CRUD DIALOG
  // =====================================================
  void _showBookingDialog(Booking? booking, Unit? preselectedUnit) async {
    List<Unit> units = [];
    if (booking != null || preselectedUnit == null) {
      units = await _unitsService.getUnitsStream().first;
    }

    if (!mounted) return;

    final isEdit = booking != null;
    final formKey = GlobalKey<FormState>();

    String? selectedUnitId =
        booking?.unitId ?? (units.isNotEmpty ? units.first.id : null);
    DateTime start = booking != null
        ? _stripTime(booking.startDate)
        : _stripTime(DateTime.now());
    DateTime end = booking != null
        ? _stripTime(booking.endDate)
        : _stripTime(DateTime.now().add(const Duration(days: 1)));
    final nameCtrl = TextEditingController(text: booking?.guestName ?? '');
    int pax = booking?.guestCount ?? 2;
    String status = booking?.status ?? 'confirmed';
    String checkInTime = booking?.checkInTime ?? '15:00';
    String checkOutTime = booking?.checkOutTime ?? '10:00';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(isEdit ? "Edit Reservation" : "New Reservation"),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Unit dropdown
                  InputDecorator(
                    decoration: const InputDecoration(labelText: "Unit"),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedUnitId,
                        isExpanded: true,
                        isDense: true,
                        items: units
                            .map((u) => DropdownMenuItem(
                                value: u.id, child: Text(u.name)))
                            .toList(),
                        onChanged: (v) => setState(() => selectedUnitId = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Date range picker
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                                initialDateRange:
                                    DateTimeRange(start: start, end: end));
                            if (picked != null) {
                              setState(() {
                                start = picked.start;
                                end = picked.end;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration:
                                const InputDecoration(labelText: "Dates"),
                            child: Text(
                                "${DateFormat('dd.MM.').format(start)} - ${DateFormat('dd.MM.').format(end)}"),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Time pickers
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final timeParts = checkInTime.split(':');
                            final initialTime = TimeOfDay(
                              hour: int.parse(timeParts[0]),
                              minute: int.parse(timeParts[1]),
                            );
                            final picked = await showTimePicker(
                                context: context, initialTime: initialTime);
                            if (picked != null) {
                              setState(() {
                                checkInTime =
                                    "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                                labelText: "Check-in Time"),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 18),
                                const SizedBox(width: 8),
                                Text(checkInTime),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final timeParts = checkOutTime.split(':');
                            final initialTime = TimeOfDay(
                              hour: int.parse(timeParts[0]),
                              minute: int.parse(timeParts[1]),
                            );
                            final picked = await showTimePicker(
                                context: context, initialTime: initialTime);
                            if (picked != null) {
                              setState(() {
                                checkOutTime =
                                    "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                                labelText: "Check-out Time"),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 18),
                                const SizedBox(width: 8),
                                Text(checkOutTime),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Guest name
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Guest Name"),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 10),

                  // Pax + Status
                  Row(
                    children: [
                      Expanded(
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: "Pax"),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: pax,
                              isExpanded: true,
                              isDense: true,
                              items: List.generate(15, (i) => i + 1)
                                  .map((i) => DropdownMenuItem(
                                      value: i, child: Text("$i")))
                                  .toList(),
                              onChanged: (v) => setState(() => pax = v!),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InputDecorator(
                          decoration:
                              const InputDecoration(labelText: "Status"),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: status,
                              isExpanded: true,
                              isDense: true,
                              items: [
                                DropdownMenuItem(
                                    value: 'confirmed',
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 14,
                                          height: 14,
                                          decoration: const BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text("Confirmed",
                                            style:
                                                TextStyle(color: Colors.green)),
                                      ],
                                    )),
                                DropdownMenuItem(
                                    value: 'booking',
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 14,
                                          height: 14,
                                          decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text("Booking",
                                            style:
                                                TextStyle(color: Colors.blue)),
                                      ],
                                    )),
                                DropdownMenuItem(
                                    value: 'airbnb',
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 14,
                                          height: 14,
                                          decoration: const BoxDecoration(
                                            color: Colors.orange,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text("Airbnb",
                                            style: TextStyle(
                                                color: Colors.orange)),
                                      ],
                                    )),
                                DropdownMenuItem(
                                    value: 'private',
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: Colors.yellow.shade700,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text("Private",
                                            style: TextStyle(
                                                color: Colors.yellow.shade700)),
                                      ],
                                    )),
                                DropdownMenuItem(
                                    value: 'blocked',
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 14,
                                          height: 14,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text("Closed",
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    )),
                                DropdownMenuItem(
                                    value: 'other',
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 14,
                                          height: 14,
                                          decoration: const BoxDecoration(
                                            color: Colors.purple,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text("Other",
                                            style: TextStyle(
                                                color: Colors.purple)),
                                      ],
                                    )),
                              ],
                              onChanged: (v) => setState(() => status = v!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel")),
            ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final newBooking = Booking(
                        id: booking?.id ?? '',
                        ownerId: booking?.ownerId ?? '',
                        unitId: selectedUnitId!,
                        guestName: nameCtrl.text,
                        startDate: start,
                        endDate: end,
                        status: status,
                        guestCount: pax,
                        checkInTime: checkInTime,
                        checkOutTime: checkOutTime);

                    try {
                      if (isEdit) {
                        await _bookingService.updateBooking(newBooking);
                      } else {
                        await _bookingService.addBooking(newBooking);
                      }
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(isEdit
                              ? "Reservation updated!"
                              : "Reservation created!"),
                          backgroundColor: Colors.green));
                    } catch (e) {
                      if (!mounted) return;
                      // Prikaži detaljniju grešku
                      final errorMsg =
                          e.toString().replaceAll('Exception: ', '');
                      debugPrint('❌ Booking error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Error: $errorMsg"),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 5)));
                    }
                  }
                },
                child: const Text("Save")),
          ],
        );
      }),
    );
  }

  // =====================================================
  // PRINT MENU (6 opcija + History)
  // =====================================================
  void _showPrintMenu(
      BuildContext context, List<Booking> bookings, List<Unit> units) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Print Options",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),

            // 1. Textual List (Full)
            _printOption(Icons.list, "1. Textual List (Full)", () {
              Navigator.pop(ctx);
              PdfService.printBookingSchedule(
                  bookings: bookings,
                  units: units,
                  startDate: _startDate,
                  daysToShow: _daysToShow,
                  mode: 'text_full');
            }),

            // 2. Textual List (Anonymous)
            _printOption(Icons.person_off, "2. Textual List (Anonymous)", () {
              Navigator.pop(ctx);
              PdfService.printBookingSchedule(
                  bookings: bookings,
                  units: units,
                  startDate: _startDate,
                  daysToShow: _daysToShow,
                  mode: 'text_anon');
            }),

            // 3. Cleaning Schedule
            _printOption(Icons.cleaning_services, "3. Cleaning Schedule", () {
              Navigator.pop(ctx);
              PdfService.printBookingSchedule(
                  bookings: bookings,
                  units: units,
                  startDate: _startDate,
                  daysToShow: _daysToShow,
                  mode: 'cleaning');
            }),

            // 4. Graphic View (Full)
            _printOption(Icons.grid_on, "4. Graphic View (Full)", () {
              Navigator.pop(ctx);
              PdfService.printBookingSchedule(
                  bookings: bookings,
                  units: units,
                  startDate: _startDate,
                  daysToShow: _daysToShow,
                  mode: 'graphic');
            }),

            // 5. Graphic View (Anonymous)
            _printOption(Icons.grid_off, "5. Graphic View (Anonymous)", () {
              Navigator.pop(ctx);
              PdfService.printBookingSchedule(
                  bookings: bookings,
                  units: units,
                  startDate: _startDate,
                  daysToShow: _daysToShow,
                  mode: 'graphic_anon');
            }),

            const Divider(),

            // 6. Booking History (NEW!)
            _printOption(Icons.history, "6. Booking History (Full Archive)",
                () {
              Navigator.pop(ctx);
              _showBookingHistoryDialog(context, bookings, units);
            }),
          ],
        ),
      ),
    );
  }

  Widget _printOption(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }

  // =====================================================
  // BOOKING HISTORY DIALOG (NEW!)
  // =====================================================
  void _showBookingHistoryDialog(
      BuildContext context, List<Booking> bookings, List<Unit> units) {
    String selectedUnitId = 'all';
    DateTime? startFilter;
    DateTime? endFilter;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text("📊 Booking History"),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Filter options:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Unit filter
                InputDecorator(
                  decoration: const InputDecoration(
                      labelText: "Unit", border: OutlineInputBorder()),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedUnitId,
                      isExpanded: true,
                      isDense: true,
                      items: [
                        const DropdownMenuItem(
                            value: 'all', child: Text("All Units")),
                        ...units.map((u) =>
                            DropdownMenuItem(value: u.id, child: Text(u.name))),
                      ],
                      onChanged: (v) => setState(() => selectedUnitId = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Date range
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            initialDateRange: startFilter != null &&
                                    endFilter != null
                                ? DateTimeRange(
                                    start: startFilter!, end: endFilter!)
                                : DateTimeRange(
                                    start: DateTime.now()
                                        .subtract(const Duration(days: 365)),
                                    end: DateTime.now()),
                          );
                          if (picked != null) {
                            setState(() {
                              startFilter = picked.start;
                              endFilter = picked.end;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                              labelText: "Date Range",
                              border: OutlineInputBorder()),
                          child: Text(
                            startFilter != null && endFilter != null
                                ? "${DateFormat('dd.MM.yyyy').format(startFilter!)} - ${DateFormat('dd.MM.yyyy').format(endFilter!)}"
                                : "All time (tap to filter)",
                            style: TextStyle(
                              color: startFilter != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Summary
                Builder(builder: (context) {
                  var filteredBookings = bookings;

                  if (selectedUnitId != 'all') {
                    filteredBookings = filteredBookings
                        .where((b) => b.unitId == selectedUnitId)
                        .toList();
                  }

                  if (startFilter != null && endFilter != null) {
                    filteredBookings = filteredBookings.where((b) {
                      return b.startDate.isAfter(startFilter!) ||
                          b.startDate.isAtSameMomentAs(startFilter!) &&
                              b.endDate.isBefore(
                                  endFilter!.add(const Duration(days: 1)));
                    }).toList();
                  }

                  final totalNights = filteredBookings.fold<int>(0, (sum, b) {
                    return sum + b.endDate.difference(b.startDate).inDays;
                  });

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📌 ${filteredBookings.length} bookings",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text("🌙 $totalNights total nights"),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel")),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);

                // Filter bookings
                var filteredBookings = List<Booking>.from(bookings);

                if (selectedUnitId != 'all') {
                  filteredBookings = filteredBookings
                      .where((b) => b.unitId == selectedUnitId)
                      .toList();
                }

                if (startFilter != null && endFilter != null) {
                  filteredBookings = filteredBookings.where((b) {
                    return (b.startDate.isAfter(startFilter!) ||
                            b.startDate.isAtSameMomentAs(startFilter!)) &&
                        b.endDate
                            .isBefore(endFilter!.add(const Duration(days: 1)));
                  }).toList();
                }

                // Sort by date
                filteredBookings
                    .sort((a, b) => b.startDate.compareTo(a.startDate));

                // Generate PDF
                PdfService.printBookingSchedule(
                  bookings: filteredBookings,
                  units: units,
                  startDate: startFilter ?? DateTime(2020),
                  daysToShow: endFilter != null
                      ? endFilter!
                          .difference(startFilter ?? DateTime(2020))
                          .inDays
                      : 365,
                  mode: 'text_full',
                );
              },
              icon: const Icon(Icons.print),
              label: const Text("Print PDF"),
            ),
          ],
        );
      }),
    );
  }
}
