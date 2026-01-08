// FILE: lib/widgets/booking_calendar.dart
// OPIS: Calendar widget za booking_screen.dart
// FIXES:
//   - Paralelogram checkout bug (uvijek pola ćelije na checkout danu)
//   - Drag & Drop overlap filter (uzima u obzir vrijeme, ne samo dan)
//   - Turnover gap (3px razmak između checkout/checkin)

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import '../models/unit_model.dart';
import '../models/booking_model.dart';

// =====================================================
// DRAG DATA MODEL
// =====================================================
class DragData {
  final Booking booking;
  final String type;
  DragData(this.booking, this.type);
}

// =====================================================
// CUSTOM SCROLL BEHAVIOR (Mouse + Touch + Trackpad)
// =====================================================
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

// =====================================================
// PARALELOGRAM PAINTER
// =====================================================
class ParallelogramPainter extends CustomPainter {
  final Color color;
  final double skewOffset;
  final bool isVertical;

  ParallelogramPainter({
    required this.color,
    this.skewOffset = 8.0,
    this.isVertical = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const double sharpRadius = 6.0;
    const double wideRadius = 4.0;

    final path = Path();

    if (!isVertical) {
      path.moveTo(skewOffset + wideRadius, 0);
      path.lineTo(size.width - sharpRadius, 0);
      path.arcToPoint(
        Offset(size.width, sharpRadius),
        radius: const Radius.circular(sharpRadius),
        clockwise: true,
      );
      path.lineTo(size.width - skewOffset, size.height - wideRadius);
      path.arcToPoint(
        Offset(size.width - skewOffset - wideRadius, size.height),
        radius: const Radius.circular(wideRadius),
        clockwise: true,
      );
      path.lineTo(sharpRadius, size.height);
      path.arcToPoint(
        Offset(0, size.height - sharpRadius),
        radius: const Radius.circular(sharpRadius),
        clockwise: true,
      );
      path.lineTo(skewOffset, wideRadius);
      path.arcToPoint(
        Offset(skewOffset + wideRadius, 0),
        radius: const Radius.circular(wideRadius),
        clockwise: true,
      );
    } else {
      // 🆕 Vertikalni: ista logika kao horizontalni ali rotirano 90°
      // Top-left ima skew, bottom-right ima skew
      path.moveTo(0, skewOffset + wideRadius);
      path.arcToPoint(
        Offset(wideRadius, skewOffset),
        radius: const Radius.circular(wideRadius),
        clockwise: true,
      );
      path.lineTo(size.width - sharpRadius, 0);
      path.arcToPoint(
        Offset(size.width, sharpRadius),
        radius: const Radius.circular(sharpRadius),
        clockwise: true,
      );
      path.lineTo(size.width, size.height - skewOffset - wideRadius);
      path.arcToPoint(
        Offset(size.width - wideRadius, size.height - skewOffset),
        radius: const Radius.circular(wideRadius),
        clockwise: true,
      );
      path.lineTo(sharpRadius, size.height);
      path.arcToPoint(
        Offset(0, size.height - sharpRadius),
        radius: const Radius.circular(sharpRadius),
        clockwise: true,
      );
      path.close();
    }

    path.close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.3), 3.0, false);
    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =====================================================
// DIAGONAL LINE PAINTER (Corner cell)
// =====================================================
class DiagonalLinePainter extends CustomPainter {
  final Color color;

  DiagonalLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      const Offset(0, 0),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =====================================================
// DIAGONAL TURNOVER LINE PAINTER
// =====================================================
class DiagonalTurnoverLinePainter extends CustomPainter {
  final Color color;
  final bool isVertical;

  DiagonalTurnoverLinePainter({required this.color, this.isVertical = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    if (!isVertical) {
      canvas.drawLine(
        Offset(0, size.height * 0.8),
        Offset(size.width, size.height * 0.2),
        paint,
      );
    } else {
      canvas.drawLine(
        Offset(size.width * 0.8, 0),
        Offset(size.width * 0.2, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =====================================================
// BOOKING CALENDAR WIDGET
// =====================================================
class BookingCalendarWidget extends StatefulWidget {
  final List<Unit> units;
  final List<Booking> bookings;
  final bool isVerticalLayout;
  final DateTime startDate;
  final int daysToShow;
  final Function(Booking) onBookingDoubleTap;
  final Future<void> Function(Booking, Unit, DateTime) onDrop;

  const BookingCalendarWidget({
    super.key,
    required this.units,
    required this.bookings,
    required this.isVerticalLayout,
    required this.startDate,
    required this.daysToShow,
    required this.onBookingDoubleTap,
    required this.onDrop,
  });

  @override
  State<BookingCalendarWidget> createState() => _BookingCalendarWidgetState();
}

// 🆕 Helper klasa za row items (zone header ili unit)
class _CalendarRowItem {
  final bool isHeader;
  final String? zoneName;
  final dynamic unit; // Unit type

  _CalendarRowItem.header(this.zoneName)
      : isHeader = true,
        unit = null;
  _CalendarRowItem.unit(this.unit)
      : isHeader = false,
        zoneName = null;
}

class _BookingCalendarWidgetState extends State<BookingCalendarWidget> {
  final ScrollController _verticalHeaderCtrl = ScrollController();
  final ScrollController _verticalBodyCtrl = ScrollController();
  final ScrollController _horizontalHeaderCtrl = ScrollController();
  final ScrollController _horizontalBodyCtrl = ScrollController();

  double get _cellHeight => 32.0;
  double get _zoneHeaderHeight => 20.0; // 🆕 Nizak header za zone

  // ✅ FIXED: Fiksna širina ćelije (kao 60 dana prikaz)
  double get _cellWidth => 40.0;

  // 🆕 HELPER: Gradi listu redova (zone headers + units)
  List<_CalendarRowItem> _buildRowItems() {
    final items = <_CalendarRowItem>[];
    String? lastZone;

    for (var unit in widget.units) {
      final zone = unit.category ?? '';
      if (zone != lastZone) {
        // Dodaj zone header
        items.add(_CalendarRowItem.header(zone.isEmpty ? 'Bez zone' : zone));
        lastZone = zone;
      }
      items.add(_CalendarRowItem.unit(unit));
    }

    return items;
  }

  // 🆕 HELPER: Računa ukupnu visinu svih redova
  double _calculateTotalHeight(List<_CalendarRowItem> items) {
    double total = 0;
    for (var item in items) {
      total += item.isHeader ? _zoneHeaderHeight : _cellHeight;
    }
    return total;
  }

  // 🆕 HELPER: Širina zone headera u vertikalnom modu
  double get _zoneHeaderWidth => 16.0;

  // 🆕 HELPER: Računa ukupnu širinu svih kolona (za vertikalni layout)
  double _calculateTotalWidth(List<_CalendarRowItem> items, double cellWidth) {
    double total = 0;
    for (var item in items) {
      total += item.isHeader ? _zoneHeaderWidth : cellWidth;
    }
    return total;
  }

  // 🆕 HELPER: Gradi mapu X offseta za vertikalni layout
  Map<String, double> _buildUnitXOffsets(
      List<_CalendarRowItem> items, double cellWidth) {
    final Map<String, double> offsets = {};
    double currentX = 0;
    for (var item in items) {
      if (item.isHeader) {
        currentX += _zoneHeaderWidth;
      } else {
        offsets[item.unit.id] = currentX;
        currentX += cellWidth;
      }
    }
    return offsets;
  }

  @override
  void initState() {
    super.initState();
    _syncScrolls();
  }

  void _syncScrolls() {
    _verticalHeaderCtrl.addListener(() {
      if (_verticalHeaderCtrl.hasClients && _verticalBodyCtrl.hasClients) {
        if (_verticalBodyCtrl.offset != _verticalHeaderCtrl.offset) {
          _verticalBodyCtrl.jumpTo(_verticalHeaderCtrl.offset);
        }
      }
    });
    _verticalBodyCtrl.addListener(() {
      if (_verticalHeaderCtrl.hasClients && _verticalBodyCtrl.hasClients) {
        if (_verticalHeaderCtrl.offset != _verticalBodyCtrl.offset) {
          _verticalHeaderCtrl.jumpTo(_verticalBodyCtrl.offset);
        }
      }
    });
    _horizontalHeaderCtrl.addListener(() {
      if (_horizontalHeaderCtrl.hasClients && _horizontalBodyCtrl.hasClients) {
        if (_horizontalBodyCtrl.offset != _horizontalHeaderCtrl.offset) {
          _horizontalBodyCtrl.jumpTo(_horizontalHeaderCtrl.offset);
        }
      }
    });
    _horizontalBodyCtrl.addListener(() {
      if (_horizontalHeaderCtrl.hasClients && _horizontalBodyCtrl.hasClients) {
        if (_horizontalHeaderCtrl.offset != _horizontalBodyCtrl.offset) {
          _horizontalHeaderCtrl.jumpTo(_horizontalBodyCtrl.offset);
        }
      }
    });
  }

  @override
  void dispose() {
    _verticalHeaderCtrl.dispose();
    _verticalBodyCtrl.dispose();
    _horizontalHeaderCtrl.dispose();
    _horizontalBodyCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BookingCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isVerticalLayout != widget.isVerticalLayout ||
        oldWidget.daysToShow != widget.daysToShow ||
        oldWidget.startDate != widget.startDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resetScrollPosition();
      });
    }
  }

  void _resetScrollPosition() {
    if (_horizontalBodyCtrl.hasClients) _horizontalBodyCtrl.jumpTo(0);
    if (_horizontalHeaderCtrl.hasClients) _horizontalHeaderCtrl.jumpTo(0);
    if (_verticalBodyCtrl.hasClients) _verticalBodyCtrl.jumpTo(0);
    if (_verticalHeaderCtrl.hasClients) _verticalHeaderCtrl.jumpTo(0);
  }

  // =====================================================
  // HELPER FUNCTIONS
  // =====================================================

  DateTime _stripTime(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _parseTimeHour(String timeString) {
    try {
      final parts = timeString.split(':');
      return int.parse(parts[0]);
    } catch (e) {
      return 0;
    }
  }

  // =====================================================
  // ✅ FIX #2: IMPROVED OVERLAP CHECK (with time awareness)
  // =====================================================
  bool _checkOverlap(
    Booking movingBooking,
    String targetUnitId,
    DateTime newStart,
    DateTime newEnd,
    List<Booking> allBookings,
  ) {
    final otherBookings = allBookings.where((b) => b.id != movingBooking.id);

    final newCheckInHour = _parseTimeHour(movingBooking.checkInTime);
    final newCheckOutHour = _parseTimeHour(movingBooking.checkOutTime);

    for (var existing in otherBookings) {
      if (existing.unitId != targetUnitId) continue;

      final existingStart = _stripTime(existing.startDate);
      final existingEnd = _stripTime(existing.endDate);
      final newStartStripped = _stripTime(newStart);
      final newEndStripped = _stripTime(newEnd);

      final existingCheckInHour = _parseTimeHour(existing.checkInTime);
      final existingCheckOutHour = _parseTimeHour(existing.checkOutTime);

      // Osnovni overlap check na razini dana
      if (newStartStripped.isBefore(existingEnd) &&
          newEndStripped.isAfter(existingStart)) {
        // Potencijalni overlap - provjeri detalje

        // ✅ TURNOVER CHECK #1: novi checkout dan == existing check-in dan
        if (_isSameDay(newEndStripped, existingStart)) {
          // Ako je checkout PRIJE ILI JEDNAKO check-inu, OK je (turnover)
          if (newCheckOutHour <= existingCheckInHour) {
            continue; // NEMA OVERLAPA - turnover OK
          }
        }

        // ✅ TURNOVER CHECK #2: novi check-in dan == existing checkout dan
        if (_isSameDay(newStartStripped, existingEnd)) {
          // Ako je check-in NAKON ILI JEDNAKO checkOutu, OK je (turnover)
          if (newCheckInHour >= existingCheckOutHour) {
            continue; // NEMA OVERLAPA - turnover OK
          }
        }

        // ✅ EDGE CASE: Ako se booking potpuno preklapa samo na turnover danima
        // Npr: postojeći 10-12, novi 12-14 -> samo jedan dan overlap (12.)
        if (_isSameDay(newStartStripped, existingEnd) &&
            _isSameDay(newEndStripped, existingStart)) {
          // Ovo je nemoguće (end prije start), ali za svaki slučaj
          continue;
        }

        return true; // OVERLAP!
      }
    }

    return false;
  }

  // =====================================================
  // HANDLE DROP (Drag & Drop)
  // =====================================================
  Future<void> _handleDrop(
      DragData data, Unit unit, DateTime droppedDate) async {
    if (data.type != 'move') return;

    final Booking b = data.booking;
    if (b.unitId == unit.id && _isSameDay(b.startDate, droppedDate)) return;

    final duration = b.endDate.difference(b.startDate);
    final baseDate = _stripTime(droppedDate);

    final newStart = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      b.startDate.hour,
      b.startDate.minute,
    );
    final newEnd = newStart.add(duration);

    final hasOverlap =
        _checkOverlap(b, unit.id, newStart, newEnd, widget.bookings);

    if (hasOverlap) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("❌ Cannot move booking - Time slot is already occupied!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    await widget.onDrop(b, unit, droppedDate);
  }

  // =====================================================
  // BUILD
  // =====================================================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? Colors.white10 : Colors.black12;

    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior().copyWith(scrollbars: false),
      child: widget.isVerticalLayout
          ? _buildVerticalLayout(borderColor, textColor)
          : _buildHorizontalLayout(borderColor, textColor),
    );
  }

  // =====================================================
  // HORIZONTAL LAYOUT
  // =====================================================
  Widget _buildHorizontalLayout(Color borderColor, Color textColor) {
    final double totalWidth = widget.daysToShow * _cellWidth;

    // 🆕 Gradi row items (zone headers + units)
    final rowItems = _buildRowItems();
    final double totalHeight = _calculateTotalHeight(rowItems);

    // 🆕 Mapa: unit.id -> Y offset (za pozicioniranje bookinga)
    final Map<String, double> unitYOffsets = {};
    double currentY = 0;
    for (var item in rowItems) {
      if (item.isHeader) {
        currentY += _zoneHeaderHeight;
      } else {
        unitYOffsets[item.unit.id] = currentY;
        currentY += _cellHeight;
      }
    }

    return Row(
      children: [
        // Unit labels column
        SizedBox(
          width: 140,
          child: Column(
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: borderColor),
                        right: BorderSide(color: borderColor))),
                child: Stack(
                  children: [
                    CustomPaint(
                      size: const Size(140, 50),
                      painter: DiagonalLinePainter(color: borderColor),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 5,
                      child: Icon(Icons.apartment,
                          size: 16, color: textColor.withValues(alpha: 0.5)),
                    ),
                    Positioned(
                      right: 10,
                      top: 5,
                      child: Icon(Icons.calendar_today,
                          size: 16, color: textColor.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
              // 🆕 ListView sa zone headers + units
              Expanded(
                child: ListView.builder(
                  controller: _verticalHeaderCtrl,
                  physics: const ClampingScrollPhysics(),
                  itemCount: rowItems.length,
                  itemBuilder: (ctx, i) {
                    final item = rowItems[i];

                    if (item.isHeader) {
                      // 🆕 Zone header - nizak, s bojom
                      return Container(
                        height: _zoneHeaderHeight,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.15),
                          border: Border(
                              bottom: BorderSide(color: borderColor),
                              right: BorderSide(color: borderColor)),
                        ),
                        child: Text(
                          item.zoneName ?? '',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    } else {
                      // Unit row
                      final unit = item.unit;
                      return Container(
                        height: _cellHeight,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: borderColor),
                              right: BorderSide(color: borderColor)),
                          color: Theme.of(context).cardTheme.color,
                        ),
                        child: Text(
                          unit.name,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: textColor),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        // Calendar grid
        Expanded(
          child: Column(
            children: [
              // Date header - koristi SingleChildScrollView za sinkronizaciju s body-jem
              SizedBox(
                height: 50,
                child: SingleChildScrollView(
                  controller: _horizontalHeaderCtrl,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Row(
                    children: List.generate(widget.daysToShow, (i) {
                      final d = widget.startDate.add(Duration(days: i));
                      final isToday = _isSameDay(d, DateTime.now());

                      Color? headerBg;
                      if (isToday) {
                        headerBg = Colors.amber.withValues(alpha: 0.1);
                      } else if (d.weekday == DateTime.saturday) {
                        headerBg = Colors.blue.withValues(alpha: 0.25);
                      } else if (d.weekday == DateTime.sunday) {
                        headerBg = Colors.red.withValues(alpha: 0.25);
                      } else {
                        headerBg = borderColor.withValues(alpha: 0.05);
                      }

                      return Container(
                        width: _cellWidth,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: headerBg,
                          border: Border(
                              bottom: BorderSide(
                                  color: isToday ? Colors.amber : borderColor),
                              right: BorderSide(color: borderColor)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(DateFormat('dd').format(d),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: isToday ? Colors.amber : textColor)),
                            Text(DateFormat('E').format(d),
                                style: TextStyle(
                                    fontSize: 9,
                                    color: isToday
                                        ? Colors.amber
                                        : textColor.withValues(alpha: 0.6))),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
              // Grid body
              Expanded(
                child: Listener(
                  onPointerSignal: (event) {
                    if (event is PointerScrollEvent) {
                      final newOffset =
                          _horizontalBodyCtrl.offset + event.scrollDelta.dy;
                      if (_horizontalBodyCtrl.hasClients) {
                        _horizontalBodyCtrl.jumpTo(newOffset.clamp(
                          0.0,
                          _horizontalBodyCtrl.position.maxScrollExtent,
                        ));
                      }
                    }
                  },
                  child: SingleChildScrollView(
                    controller: _verticalBodyCtrl,
                    physics: const ClampingScrollPhysics(),
                    child: SingleChildScrollView(
                      controller: _horizontalBodyCtrl,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        width: totalWidth,
                        height: totalHeight,
                        child: Stack(
                          children: [
                            // 🆕 Grid cells sa zone headers
                            Column(
                              children: rowItems.map((item) {
                                if (item.isHeader) {
                                  // Zone header row - prazan prostor sa bojom
                                  return Container(
                                    height: _zoneHeaderHeight,
                                    width: totalWidth,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.08),
                                      border: Border(
                                        bottom: BorderSide(color: borderColor),
                                      ),
                                    ),
                                  );
                                } else {
                                  // Unit row sa ćelijama
                                  final u = item.unit;
                                  return SizedBox(
                                    height: _cellHeight,
                                    child: Row(
                                      children:
                                          List.generate(widget.daysToShow, (i) {
                                        final d = widget.startDate
                                            .add(Duration(days: i));

                                        Color? cellColor;
                                        if (d.weekday == DateTime.saturday) {
                                          cellColor = Colors.blue
                                              .withValues(alpha: 0.15);
                                        } else if (d.weekday ==
                                            DateTime.sunday) {
                                          cellColor = Colors.red
                                              .withValues(alpha: 0.15);
                                        }

                                        return DragTarget<DragData>(
                                          onAcceptWithDetails: (details) =>
                                              _handleDrop(details.data, u, d),
                                          builder: (context, candidateData,
                                              rejectedData) {
                                            if (candidateData.isNotEmpty) {
                                              cellColor = Colors.blue
                                                  .withValues(alpha: 0.3);
                                            }
                                            return Container(
                                              width: _cellWidth,
                                              decoration: BoxDecoration(
                                                color: cellColor,
                                                border: Border(
                                                    right: BorderSide(
                                                        color: borderColor
                                                            .withValues(
                                                                alpha: 0.5)),
                                                    bottom: BorderSide(
                                                        color: borderColor)),
                                              ),
                                            );
                                          },
                                        );
                                      }),
                                    ),
                                  );
                                }
                              }).toList(),
                            ),
                            // Booking blocks - 🆕 koristi unitYOffsets za pozicioniranje
                            ...widget.bookings.map((b) =>
                                _buildBookingBlockWithOffset(b, unitYOffsets)),
                            // Turnover lines - 🆕 koristi unitYOffsets
                            ..._buildTurnoverLinesWithOffset(unitYOffsets),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🆕 Booking block sa custom Y offset
  Widget _buildBookingBlockWithOffset(
      Booking b, Map<String, double> unitYOffsets) {
    final unitIndex = widget.units.indexWhere((u) => u.id == b.unitId);
    if (unitIndex < 0) return const SizedBox.shrink();

    final unitY = unitYOffsets[b.unitId] ?? 0;

    final bookingStart = _stripTime(b.startDate);
    final bookingEnd = _stripTime(b.endDate);
    final viewStart = _stripTime(widget.startDate);
    final viewEnd = viewStart.add(Duration(days: widget.daysToShow));

    if (bookingEnd.isBefore(viewStart) || bookingStart.isAfter(viewEnd)) {
      return const SizedBox.shrink();
    }

    // Računanje pozicije i veličine
    int startOffset = bookingStart.difference(viewStart).inDays;
    int duration = bookingEnd.difference(bookingStart).inDays;

    final checkOutHour = _parseTimeHour(b.checkOutTime);
    if (checkOutHour > 0) {
      duration += 1;
    }
    if (duration < 1) duration = 1;

    if (startOffset < 0) {
      duration += startOffset;
      startOffset = 0;
    }

    double startOffsetAdjustment = 0.0;
    double durationAdjustment = 0.0;

    final checkInHour = _parseTimeHour(b.checkInTime);
    if (checkInHour >= 12) {
      startOffsetAdjustment = 0.5;
      durationAdjustment -= 0.5;
    }

    if (checkOutHour > 0) {
      durationAdjustment -= 0.5;
    }

    // Check for turnover after this booking
    bool hasTurnoverAfter = false;
    final unitBookings = widget.bookings
        .where((bk) => bk.unitId == b.unitId)
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final currentIndex = unitBookings.indexWhere((bk) => bk.id == b.id);
    if (currentIndex != -1 && currentIndex < unitBookings.length - 1) {
      final nextBooking = unitBookings[currentIndex + 1];
      if (_isSameDay(
          _stripTime(b.endDate), _stripTime(nextBooking.startDate))) {
        hasTurnoverAfter = true;
      }
    }

    const vMargin = 4.0;
    double left = (startOffset + startOffsetAdjustment) * _cellWidth;
    double width = (duration + durationAdjustment) * _cellWidth;
    double height = _cellHeight - vMargin;

    if (hasTurnoverAfter) {
      width -= 3;
    }

    if (width <= 0) return const SizedBox.shrink();

    // 🆕 Koristi ParallelogramPainter kao original
    final Widget bookingCard = ClipRect(
      child: CustomPaint(
        painter: ParallelogramPainter(
          color: b.color,
          skewOffset: 6.0,
          isVertical: false,
        ),
        child: Container(
          alignment: Alignment.center,
          child: (width > 25 && height > 18)
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    b.guestName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          )
                        ]),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                )
              : null,
        ),
      ),
    );

    return Positioned(
      left: left,
      top: unitY + (vMargin / 2),
      width: width,
      height: height,
      child: LongPressDraggable<DragData>(
        data: DragData(b, 'move'),
        feedback: Material(
          color: Colors.transparent,
          child: Opacity(
            opacity: 0.7,
            child: SizedBox(width: width, height: height, child: bookingCard),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.3, child: bookingCard),
        child: GestureDetector(
          onDoubleTap: () => widget.onBookingDoubleTap(b),
          child: Tooltip(
            message:
                "${b.guestName}\n${DateFormat('dd.MM.').format(b.startDate)} ${b.checkInTime} - ${DateFormat('dd.MM.').format(b.endDate)} ${b.checkOutTime}",
            child: bookingCard,
          ),
        ),
      ),
    );
  }

  // 🆕 Turnover lines sa custom Y offset (prazna lista - turnover je u booking bloku)
  List<Widget> _buildTurnoverLinesWithOffset(Map<String, double> unitYOffsets) {
    // Turnover linije su integrirane u ParallelogramPainter
    return [];
  }

  // =====================================================
  // VERTICAL LAYOUT
  // =====================================================
  Widget _buildVerticalLayout(Color borderColor, Color textColor) {
    final double totalHeight = widget.daysToShow * _cellHeight;
    const double headerHeight = 100.0;
    const double vCellWidth = 32.0;

    // 🆕 Gradi column items (zone headers + units)
    final columnItems = _buildRowItems(); // Ista logika kao horizontalni
    final double totalWidth = _calculateTotalWidth(columnItems, vCellWidth);
    final unitXOffsets = _buildUnitXOffsets(columnItems, vCellWidth);

    return Column(
      children: [
        // Header row
        SizedBox(
          height: headerHeight,
          child: Row(
            children: [
              Container(
                width: 60,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: borderColor),
                        right: BorderSide(color: borderColor))),
                child: Stack(
                  children: [
                    CustomPaint(
                      size: const Size(60, 100),
                      painter: DiagonalLinePainter(color: borderColor),
                    ),
                    Positioned(
                      left: 5,
                      bottom: 10,
                      child: Icon(Icons.calendar_today,
                          size: 14, color: textColor.withValues(alpha: 0.5)),
                    ),
                    Positioned(
                      right: 5,
                      top: 10,
                      child: Icon(Icons.apartment,
                          size: 14, color: textColor.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
              // 🆕 ListView sa zone headers + units
              Expanded(
                child: ListView.builder(
                  controller: _horizontalHeaderCtrl,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  itemCount: columnItems.length,
                  itemBuilder: (ctx, i) {
                    final item = columnItems[i];

                    if (item.isHeader) {
                      // 🆕 Zone header - uska kolona
                      return Container(
                        width: _zoneHeaderWidth,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.15),
                          border: Border(
                              bottom: BorderSide(color: borderColor),
                              right: BorderSide(color: borderColor)),
                        ),
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: Text(
                            item.zoneName ?? '',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    } else {
                      // Unit column
                      final unit = item.unit;
                      return Container(
                        width: vCellWidth,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: borderColor),
                              right: BorderSide(color: borderColor)),
                          color: Theme.of(context).cardTheme.color,
                        ),
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: Text(
                            unit.name,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: textColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        // Grid body
        Expanded(
          child: Row(
            children: [
              // Date labels
              SizedBox(
                width: 60,
                child: ListView.builder(
                  controller: _verticalHeaderCtrl,
                  physics: const ClampingScrollPhysics(),
                  itemCount: widget.daysToShow,
                  itemBuilder: (ctx, i) {
                    final d = widget.startDate.add(Duration(days: i));
                    final isToday = _isSameDay(d, DateTime.now());

                    Color? bg;
                    if (isToday) {
                      bg = Colors.amber.withValues(alpha: 0.1);
                    } else if (d.weekday == DateTime.saturday) {
                      bg = Colors.blue.withValues(alpha: 0.25);
                    } else if (d.weekday == DateTime.sunday) {
                      bg = Colors.red.withValues(alpha: 0.25);
                    } else {
                      bg = borderColor.withValues(alpha: 0.05);
                    }

                    return Container(
                      height: _cellHeight,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: bg,
                        border: Border(
                            bottom: BorderSide(
                                color: isToday ? Colors.amber : borderColor),
                            right: BorderSide(color: borderColor)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(DateFormat('dd').format(d),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: isToday ? Colors.amber : textColor)),
                          Text(DateFormat('E').format(d),
                              style: TextStyle(
                                  fontSize: 8,
                                  color: isToday
                                      ? Colors.amber
                                      : textColor.withValues(alpha: 0.6))),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Grid
              Expanded(
                child: Listener(
                  onPointerSignal: (event) {
                    if (event is PointerScrollEvent) {
                      final newOffset =
                          _verticalBodyCtrl.offset + event.scrollDelta.dy;
                      if (_verticalBodyCtrl.hasClients) {
                        _verticalBodyCtrl.jumpTo(newOffset.clamp(
                          0.0,
                          _verticalBodyCtrl.position.maxScrollExtent,
                        ));
                      }
                    }
                  },
                  child: SingleChildScrollView(
                    controller: _verticalBodyCtrl,
                    physics: const ClampingScrollPhysics(),
                    child: SingleChildScrollView(
                      controller: _horizontalBodyCtrl,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        width: totalWidth,
                        height: totalHeight,
                        child: Stack(
                          children: [
                            // 🆕 Grid cells sa zone headers
                            Row(
                              children: columnItems.map((item) {
                                if (item.isHeader) {
                                  // Zone header column - prazan prostor sa bojom
                                  return Container(
                                    width: _zoneHeaderWidth,
                                    height: totalHeight,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.08),
                                      border: Border(
                                        right: BorderSide(color: borderColor),
                                      ),
                                    ),
                                  );
                                } else {
                                  // Unit column sa ćelijama
                                  final u = item.unit;
                                  return Container(
                                    width: vCellWidth,
                                    decoration: BoxDecoration(
                                        border: Border(
                                            right: BorderSide(
                                                color: borderColor))),
                                    child: Column(
                                      children:
                                          List.generate(widget.daysToShow, (i) {
                                        final d = widget.startDate
                                            .add(Duration(days: i));

                                        Color? cellColor;
                                        if (d.weekday == DateTime.saturday) {
                                          cellColor = Colors.blue
                                              .withValues(alpha: 0.15);
                                        } else if (d.weekday ==
                                            DateTime.sunday) {
                                          cellColor = Colors.red
                                              .withValues(alpha: 0.15);
                                        }

                                        return DragTarget<DragData>(
                                          onAcceptWithDetails: (details) =>
                                              _handleDrop(details.data, u, d),
                                          builder: (context, candidateData,
                                              rejectedData) {
                                            if (candidateData.isNotEmpty) {
                                              cellColor = Colors.blue
                                                  .withValues(alpha: 0.3);
                                            }
                                            return Container(
                                              height: _cellHeight,
                                              decoration: BoxDecoration(
                                                color: cellColor,
                                                border: Border(
                                                    bottom: BorderSide(
                                                        color: borderColor
                                                            .withValues(
                                                                alpha: 0.5))),
                                              ),
                                            );
                                          },
                                        );
                                      }),
                                    ),
                                  );
                                }
                              }).toList(),
                            ),
                            // Booking blocks - 🆕 koristi unitXOffsets
                            ...widget.bookings.map((b) =>
                                _buildBookingBlockVertical(
                                    b, vCellWidth, unitXOffsets)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🆕 Booking block za vertikalni layout sa custom X offset
  Widget _buildBookingBlockVertical(
      Booking b, double cellWidth, Map<String, double> unitXOffsets) {
    final unitIndex = widget.units.indexWhere((u) => u.id == b.unitId);
    if (unitIndex < 0) return const SizedBox.shrink();

    final unitX = unitXOffsets[b.unitId] ?? 0;

    final safeStart = _stripTime(b.startDate);
    final safeEnd = _stripTime(b.endDate);
    final viewStart = _stripTime(widget.startDate);

    if (safeEnd.isBefore(viewStart) ||
        safeStart.isAfter(viewStart.add(Duration(days: widget.daysToShow)))) {
      return const SizedBox.shrink();
    }

    int startOffset = safeStart.difference(viewStart).inDays;
    int duration = safeEnd.difference(safeStart).inDays;

    final checkOutHour = _parseTimeHour(b.checkOutTime);
    if (checkOutHour > 0) {
      duration += 1;
    }
    if (duration < 1) duration = 1;

    if (startOffset < 0) {
      duration += startOffset;
      startOffset = 0;
    }

    double startOffsetAdjustment = 0.0;
    double durationAdjustment = 0.0;

    final checkInHour = _parseTimeHour(b.checkInTime);
    if (checkInHour >= 12) {
      startOffsetAdjustment = 0.5;
      durationAdjustment -= 0.5;
    }

    if (checkOutHour > 0) {
      durationAdjustment -= 0.5;
    }

    // Check for turnover
    bool hasTurnoverAfter = false;
    final unitBookings = widget.bookings
        .where((bk) => bk.unitId == b.unitId)
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final currentIndex = unitBookings.indexWhere((bk) => bk.id == b.id);
    if (currentIndex != -1 && currentIndex < unitBookings.length - 1) {
      final nextBooking = unitBookings[currentIndex + 1];
      if (_isSameDay(
          _stripTime(b.endDate), _stripTime(nextBooking.startDate))) {
        hasTurnoverAfter = true;
      }
    }

    const double vMargin = 4.0;
    double left = unitX + (vMargin / 2);
    double top = (startOffset + startOffsetAdjustment) * _cellHeight;
    double width = cellWidth - vMargin;
    double height = (duration + durationAdjustment) * _cellHeight;

    if (hasTurnoverAfter) {
      height -= 3;
    }

    if (height <= 0) return const SizedBox.shrink();

    final bool showText = height > 40 && width > 14;

    final Widget bookingCard = ClipRect(
      child: CustomPaint(
        painter: ParallelogramPainter(
          color: b.color,
          skewOffset: 4.0,
          isVertical: true,
        ),
        child: Container(
          alignment: Alignment.center,
          child: showText
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2.0, vertical: 4.0),
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Text(
                      b.guestName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            )
                          ]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: LongPressDraggable<DragData>(
        data: DragData(b, 'move'),
        feedback: Material(
          color: Colors.transparent,
          child: Opacity(
            opacity: 0.7,
            child: SizedBox(width: width, height: height, child: bookingCard),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.3, child: bookingCard),
        child: GestureDetector(
          onDoubleTap: () => widget.onBookingDoubleTap(b),
          child: Tooltip(
            message:
                "${b.guestName}\n${DateFormat('dd.MM.').format(b.startDate)} ${b.checkInTime} - ${DateFormat('dd.MM.').format(b.endDate)} ${b.checkOutTime}",
            child: bookingCard,
          ),
        ),
      ),
    );
  }
}
