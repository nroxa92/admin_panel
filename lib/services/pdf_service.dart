// FILE: lib/services/pdf_service.dart
// VERSION: 2.0 - Enhanced eVisitor with MRZ support
// DATE: 2026-01-11
// CHANGES:
//   - Enhanced printEvisitorForm() with professional layout
//   - Handles multiple field name formats (MRZ + legacy)
//   - Added helper methods for robust field extraction

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/unit_model.dart';
import '../models/booking_model.dart';

class PdfService {
  // =============================================
  // GLAVNI ENTRY POINT - Odabir PDF tipa
  // =============================================
  static Future<void> printBookingSchedule({
    required List<Booking> bookings,
    required List<Unit> units,
    required DateTime startDate,
    required int daysToShow,
    required String mode,
  }) async {
    pw.Document pdf;

    switch (mode) {
      case 'text_full':
        pdf = _generateTextList(bookings, units, startDate, daysToShow, false);
        break;
      case 'text_anon':
        pdf = _generateTextList(bookings, units, startDate, daysToShow, true);
        break;
      case 'cleaning':
        pdf = _generateCleaningSchedule(bookings, units, startDate);
        break;
      case 'graphic':
        pdf = _generateGraphicCalendar(
            bookings, units, startDate, daysToShow, false);
        break;
      case 'graphic_anon':
        pdf = _generateGraphicCalendar(
            bookings, units, startDate, daysToShow, true);
        break;
      default:
        pdf = _generateTextList(bookings, units, startDate, daysToShow, false);
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // =============================================
  // PDF #5 & #6: TEXTUAL LIST (Full/Anonymous)
  // =============================================
  static pw.Document _generateTextList(
    List<Booking> bookings,
    List<Unit> units,
    DateTime startDate,
    int daysToShow,
    bool anonymous,
  ) {
    final pdf = pw.Document();
    final endDate = startDate.add(Duration(days: daysToShow));

    final relevantBookings = bookings.where((b) {
      return b.endDate.isAfter(startDate) && b.startDate.isBefore(endDate);
    }).toList();

    final Map<String, List<Booking>> bookingsByUnit = {};
    for (var unit in units) {
      bookingsByUnit[unit.id] = relevantBookings
          .where((b) => b.unitId == unit.id)
          .toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    anonymous ? 'BOOKING LIST (Anonymous)' : 'BOOKING LIST',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Period: ${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            ...units.map((unit) {
              final unitBookings = bookingsByUnit[unit.id] ?? [];

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 16),
                  pw.Text(
                    unit.name,
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  if (unitBookings.isEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 16, bottom: 8),
                      child: pw.Text('No bookings in this period',
                          style: pw.TextStyle(
                              fontSize: 10, fontStyle: pw.FontStyle.italic)),
                    ),
                  ...unitBookings.map((booking) {
                    final startStr =
                        '${DateFormat('dd.MM.yyyy').format(booking.startDate)} ${booking.checkInTime}';
                    final endStr =
                        '${DateFormat('dd.MM.yyyy').format(booking.endDate)} ${booking.checkOutTime}';

                    return pw.Container(
                      margin: const pw.EdgeInsets.only(left: 16, bottom: 12),
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(8)),
                        color: PdfColors.grey100,
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                anonymous ? 'OCCUPIED' : booking.guestName,
                                style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: pw.BoxDecoration(
                                  color: _getStatusColor(booking.status),
                                  borderRadius: const pw.BorderRadius.all(
                                      pw.Radius.circular(4)),
                                ),
                                child: pw.Text(
                                  booking.status.toUpperCase(),
                                  style: const pw.TextStyle(
                                      fontSize: 8, color: PdfColors.white),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text('Check-in:  $startStr',
                              style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Check-out: $endStr',
                              style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Guests: ${booking.guestCount} pax',
                              style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    );
                  }),
                ],
              );
            }),
          ];
        },
      ),
    );

    return pdf;
  }

  // =============================================
  // PDF #7: CLEANING SCHEDULE
  // =============================================
  static pw.Document _generateCleaningSchedule(
    List<Booking> bookings,
    List<Unit> units,
    DateTime startDate,
  ) {
    final pdf = pw.Document();
    final next7Days = startDate.add(const Duration(days: 7));

    final List<Map<String, dynamic>> cleaningEvents = [];

    for (var booking in bookings) {
      if (booking.endDate.isAfter(startDate) &&
          booking.endDate.isBefore(next7Days)) {
        cleaningEvents.add({
          'date': booking.endDate,
          'type': 'CHECK-OUT',
          'unitId': booking.unitId,
          'time': booking.checkOutTime,
        });
      }

      if (booking.startDate.isAfter(startDate) &&
          booking.startDate.isBefore(next7Days)) {
        cleaningEvents.add({
          'date': booking.startDate,
          'type': 'CHECK-IN',
          'unitId': booking.unitId,
          'time': booking.checkInTime,
        });
      }
    }

    cleaningEvents.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    final Map<String, List<Map<String, dynamic>>> eventsByDay = {};
    for (var event in cleaningEvents) {
      final dateKey =
          DateFormat('yyyy-MM-dd').format(event['date'] as DateTime);
      eventsByDay.putIfAbsent(dateKey, () => []);
      eventsByDay[dateKey]!.add(event);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'CLEANING SCHEDULE',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Next 7 days: ${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(next7Days)}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            ...eventsByDay.entries.map((entry) {
              final date = DateTime.parse(entry.key);
              final events = entry.value;

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 16),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.blue50,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Text(
                      DateFormat('EEEE, dd.MM.yyyy').format(date),
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  ...events.map((event) {
                    final unit =
                        units.firstWhere((u) => u.id == event['unitId']);
                    final isCheckOut = event['type'] == 'CHECK-OUT';

                    return pw.Container(
                      margin: const pw.EdgeInsets.only(left: 16, bottom: 8),
                      child: pw.Row(
                        children: [
                          pw.Container(
                            width: 20,
                            height: 20,
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              border: pw.Border.all(
                                  color: isCheckOut
                                      ? PdfColors.red
                                      : PdfColors.green),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                isCheckOut ? '✓' : '○',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  color: isCheckOut
                                      ? PdfColors.red
                                      : PdfColors.green,
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Expanded(
                            child: pw.Text(
                              '${unit.name} - ${event['type']} ${event['time']}',
                              style: const pw.TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            }),
            if (eventsByDay.isEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 32),
                child: pw.Center(
                  child: pw.Text(
                    'No cleaning tasks in the next 7 days',
                    style: pw.TextStyle(
                        fontSize: 12, fontStyle: pw.FontStyle.italic),
                  ),
                ),
              ),
          ];
        },
      ),
    );

    return pdf;
  }

  // =============================================
  // PDF #8 & #9: GRAPHIC CALENDAR (Full/Anonymous)
  // =============================================
  static pw.Document _generateGraphicCalendar(
    List<Booking> bookings,
    List<Unit> units,
    DateTime startDate,
    int daysToShow,
    bool anonymous,
  ) {
    final pdf = pw.Document();

    const double cellWidth = 25.0;
    const double cellHeight = 30.0;
    const double unitLabelWidth = 80.0;
    const double headerHeight = 40.0;

    const int maxDaysPerPage = 21;
    final int totalPages = (daysToShow / maxDaysPerPage).ceil();

    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      final int pageStartDay = pageIndex * maxDaysPerPage;
      final int pageDays = (pageStartDay + maxDaysPerPage > daysToShow)
          ? daysToShow - pageStartDay
          : maxDaysPerPage;

      final DateTime pageStart = startDate.add(Duration(days: pageStartDay));

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(16),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  anonymous ? 'CALENDAR (Anonymous)' : 'BOOKING CALENDAR',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Period: ${DateFormat('dd.MM.yyyy').format(pageStart)} - ${DateFormat('dd.MM.yyyy').format(pageStart.add(Duration(days: pageDays - 1)))}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 12),
                pw.Expanded(
                  child: pw.Stack(
                    children: [
                      _buildCalendarGrid(
                        units,
                        pageStart,
                        pageDays,
                        cellWidth,
                        cellHeight,
                        unitLabelWidth,
                        headerHeight,
                      ),
                      ..._buildBookingBlocks(
                        bookings,
                        units,
                        pageStart,
                        pageDays,
                        cellWidth,
                        cellHeight,
                        unitLabelWidth,
                        headerHeight,
                        anonymous,
                      ),
                      ..._buildOverlapLines(
                        bookings,
                        units,
                        pageStart,
                        pageDays,
                        cellWidth,
                        cellHeight,
                        unitLabelWidth,
                        headerHeight,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Page ${pageIndex + 1} of $totalPages',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
                ),
              ],
            );
          },
        ),
      );
    }

    return pdf;
  }

  static pw.Widget _buildCalendarGrid(
    List<Unit> units,
    DateTime startDate,
    int days,
    double cellWidth,
    double cellHeight,
    double unitLabelWidth,
    double headerHeight,
  ) {
    return pw.Column(
      children: [
        pw.Row(
          children: [
            pw.Container(
              width: unitLabelWidth,
              height: headerHeight,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey),
                  right: pw.BorderSide(color: PdfColors.grey),
                ),
              ),
              child: pw.Center(
                child: pw.Text('UNIT',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
              ),
            ),
            ...List.generate(days, (i) {
              final date = startDate.add(Duration(days: i));
              final isWeekend = date.weekday == DateTime.saturday ||
                  date.weekday == DateTime.sunday;

              return pw.Container(
                width: cellWidth,
                height: headerHeight,
                decoration: pw.BoxDecoration(
                  color: isWeekend
                      ? (date.weekday == DateTime.saturday
                          ? PdfColors.blue50
                          : PdfColors.red50)
                      : null,
                  border: const pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey),
                    right: pw.BorderSide(color: PdfColors.grey),
                  ),
                ),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(DateFormat('dd').format(date),
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text(DateFormat('E').format(date),
                        style: const pw.TextStyle(fontSize: 7)),
                  ],
                ),
              );
            }),
          ],
        ),
        ...units.map((unit) {
          return pw.Row(
            children: [
              pw.Container(
                width: unitLabelWidth,
                height: cellHeight,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey),
                    right: pw.BorderSide(color: PdfColors.grey),
                  ),
                ),
                padding: const pw.EdgeInsets.all(4),
                child:
                    pw.Text(unit.name, style: const pw.TextStyle(fontSize: 8)),
              ),
              ...List.generate(days, (i) {
                final date = startDate.add(Duration(days: i));
                final isWeekend = date.weekday == DateTime.saturday ||
                    date.weekday == DateTime.sunday;

                return pw.Container(
                  width: cellWidth,
                  height: cellHeight,
                  decoration: pw.BoxDecoration(
                    color: isWeekend
                        ? (date.weekday == DateTime.saturday
                            ? PdfColors.blue50
                            : PdfColors.red50)
                        : null,
                    border: const pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.grey),
                      right: pw.BorderSide(color: PdfColors.grey),
                    ),
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  static List<pw.Widget> _buildBookingBlocks(
    List<Booking> bookings,
    List<Unit> units,
    DateTime pageStart,
    int pageDays,
    double cellWidth,
    double cellHeight,
    double unitLabelWidth,
    double headerHeight,
    bool anonymous,
  ) {
    final List<pw.Widget> blocks = [];

    for (var booking in bookings) {
      final unitIndex = units.indexWhere((u) => u.id == booking.unitId);
      if (unitIndex == -1) continue;

      final bookingStart = _stripTime(booking.startDate);
      final bookingEnd = _stripTime(booking.endDate);
      final pageEnd = pageStart.add(Duration(days: pageDays));

      if (bookingEnd.isBefore(pageStart) || bookingStart.isAfter(pageEnd)) {
        continue;
      }

      int startOffset = bookingStart.difference(pageStart).inDays;
      int duration = bookingEnd.difference(bookingStart).inDays;

      if (startOffset < 0) {
        duration += startOffset;
        startOffset = 0;
      }
      if (startOffset + duration > pageDays) {
        duration = pageDays - startOffset;
      }

      if (duration < 1) continue;

      final double x = unitLabelWidth + (startOffset * cellWidth);
      final double y = headerHeight + (unitIndex * cellHeight);
      final double width = duration * cellWidth;
      final double height = cellHeight;

      blocks.add(
        pw.Positioned(
          left: x,
          top: y,
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(2),
            child: pw.Container(
              width: width - 4,
              height: height - 4,
              decoration: pw.BoxDecoration(
                color: _getStatusColor(booking.status),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: pw.Center(
                child: pw.Text(
                  anonymous ? 'OCCUPIED' : booking.guestName,
                  style: const pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.white,
                  ),
                  textAlign: pw.TextAlign.center,
                  overflow: pw.TextOverflow.clip,
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return blocks;
  }

  static List<pw.Widget> _buildOverlapLines(
    List<Booking> bookings,
    List<Unit> units,
    DateTime pageStart,
    int pageDays,
    double cellWidth,
    double cellHeight,
    double unitLabelWidth,
    double headerHeight,
  ) {
    final List<pw.Widget> lines = [];

    for (var unit in units) {
      final unitIndex = units.indexOf(unit);
      final unitBookings = bookings.where((b) => b.unitId == unit.id).toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));

      for (int i = 0; i < unitBookings.length - 1; i++) {
        final currentBooking = unitBookings[i];
        final nextBooking = unitBookings[i + 1];

        final currentEnd = _stripTime(currentBooking.endDate);
        final nextStart = _stripTime(nextBooking.startDate);

        if (_isSameDay(currentEnd, nextStart)) {
          final dayOffset = currentEnd.difference(pageStart).inDays;

          if (dayOffset >= 0 && dayOffset < pageDays) {
            final double x =
                unitLabelWidth + (dayOffset * cellWidth) + (cellWidth / 2);
            final double y = headerHeight + (unitIndex * cellHeight);

            lines.add(
              pw.Positioned(
                left: x - 1,
                top: y + 4,
                child: pw.Container(
                  width: 2,
                  height: cellHeight - 8,
                  color: PdfColors.red700,
                ),
              ),
            );
          }
        }
      }
    }

    return lines;
  }

  // =============================================
  // HELPER FUNKCIJE
  // =============================================

  static DateTime _stripTime(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static PdfColor _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return PdfColors.green;
      case 'booking.com':
      case 'booking':
        return PdfColors.blue;
      case 'private':
        return PdfColors.yellow800;
      case 'airbnb':
        return PdfColors.orange;
      case 'blocked':
      case 'closed':
        return PdfColors.red;
      default:
        return PdfColors.purple;
    }
  }

  // =============================================
  // RECEPCIJA PDF-ovi (#1-4)
  // =============================================

  /// Print eVisitor form with scanned guest data (MRZ)
  /// Handles both legacy fields (name, address, idNumber) and
  /// MRZ standard fields (firstName, lastName, documentNumber, etc.)
  static Future<void> printEvisitorForm(
    String unitName,
    List<Map<String, dynamic>> guestData,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 16),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'eVisitor - Guest Registration',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.Text(
                'Page ${context.pageNumber}/${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 16),
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
              ),
              pw.Text(
                'VillaOS eVisitor System',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
              ),
            ],
          ),
        ),
        build: (context) => [
          // Header info box
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: PdfColors.blue200),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Property: $unitName',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Scan Date: ${DateFormat('dd.MM.yyyy').format(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.blue800,
                    borderRadius:
                        pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Text(
                    '${guestData.length} Guest${guestData.length != 1 ? 's' : ''}',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Guest cards
          ...guestData.asMap().entries.map((entry) {
            final idx = entry.key;
            final guest = entry.value;

            // Extract guest name (handle multiple formats)
            final String guestName = _extractGuestName(guest);

            // Extract all available fields
            final String? dateOfBirth =
                _getField(guest, ['dateOfBirth', 'dob', 'birthDate']);
            final String? nationality =
                _getField(guest, ['nationality', 'nat', 'country']);
            final String? documentType =
                _getField(guest, ['documentType', 'docType', 'type']);
            final String? documentNumber = _getField(guest,
                ['documentNumber', 'idNumber', 'docNumber', 'passportNumber']);
            final String? sex = _getField(guest, ['sex', 'gender']);
            final String? placeOfBirth =
                _getField(guest, ['placeOfBirth', 'birthPlace']);
            final String? countryOfBirth =
                _getField(guest, ['countryOfBirth', 'birthCountry']);
            final String? issuingCountry =
                _getField(guest, ['issuingCountry', 'issuer']);
            final String? expiryDate =
                _getField(guest, ['expiryDate', 'expiry', 'validUntil']);
            final String? address =
                _getField(guest, ['address', 'residence', 'residenceAddress']);
            final String? residenceCity =
                _getField(guest, ['residenceCity', 'city']);
            final String? residenceCountry =
                _getField(guest, ['residenceCountry']);

            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Guest header
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.only(
                        topLeft: pw.Radius.circular(7),
                        topRight: pw.Radius.circular(7),
                      ),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Container(
                          width: 24,
                          height: 24,
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.blue800,
                            shape: pw.BoxShape.circle,
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              '${idx + 1}',
                              style: const pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Expanded(
                          child: pw.Text(
                            guestName,
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        if (nationality != null)
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: const pw.BoxDecoration(
                              color: PdfColors.blue100,
                              borderRadius: pw.BorderRadius.all(
                                  pw.Radius.circular(4)),
                            ),
                            child: pw.Text(
                              nationality,
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue900,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Guest details
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(12),
                    child: pw.Column(
                      children: [
                        // Row 1: Document info
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Expanded(
                              child: _buildPdfInfoField(
                                  'Document Type', documentType ?? '-'),
                            ),
                            pw.SizedBox(width: 16),
                            pw.Expanded(
                              child: _buildPdfInfoField(
                                  'Document Number', documentNumber ?? '-'),
                            ),
                            pw.SizedBox(width: 16),
                            pw.Expanded(
                              child: _buildPdfInfoField(
                                  'Expiry Date', expiryDate ?? '-'),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 10),

                        // Row 2: Personal info
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Expanded(
                              child: _buildPdfInfoField(
                                  'Date of Birth', dateOfBirth ?? '-'),
                            ),
                            pw.SizedBox(width: 16),
                            pw.Expanded(
                              child: _buildPdfInfoField('Sex', sex ?? '-'),
                            ),
                            pw.SizedBox(width: 16),
                            pw.Expanded(
                              child: _buildPdfInfoField('Place of Birth',
                                  placeOfBirth ?? countryOfBirth ?? '-'),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 10),

                        // Row 3: Residence info (if available)
                        if (address != null ||
                            residenceCity != null ||
                            residenceCountry != null)
                          pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Expanded(
                                flex: 2,
                                child: _buildPdfInfoField(
                                  'Residence',
                                  [address, residenceCity, residenceCountry]
                                      .where((e) => e != null && e.isNotEmpty)
                                      .join(', '),
                                ),
                              ),
                              pw.SizedBox(width: 16),
                              pw.Expanded(
                                child: _buildPdfInfoField(
                                    'Issuing Country', issuingCountry ?? '-'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          // Empty state
          if (guestData.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(32),
              child: pw.Center(
                child: pw.Text(
                  'No guest data available',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  /// Helper: Extract guest name from various field formats
  static String _extractGuestName(Map<String, dynamic> guest) {
    // Try firstName + lastName first
    final firstName = guest['firstName']?.toString().trim() ?? '';
    final lastName = guest['lastName']?.toString().trim() ?? '';

    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }

    // Fallback to 'name' field
    final name = guest['name']?.toString().trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    // Fallback to 'fullName' field
    final fullName = guest['fullName']?.toString().trim();
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }

    return 'Unknown Guest';
  }

  /// Helper: Get field value trying multiple possible field names
  static String? _getField(
      Map<String, dynamic> data, List<String> possibleKeys) {
    for (final key in possibleKeys) {
      final value = data[key]?.toString().trim();
      if (value != null && value.isNotEmpty && value != 'null') {
        return value;
      }
    }
    return null;
  }

  /// Helper: Build info field widget for PDF
  static pw.Widget _buildPdfInfoField(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: const pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value.isEmpty ? '-' : value,
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  static Future<void> printHouseRules(
    String unitName,
    String guestName,
    String rulesText,
    Uint8List? signatureImage,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('HOUSE RULES',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Unit: $unitName | Guest: $guestName'),
            pw.Text(
                'Date: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}'),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 16),
            pw.Text(rulesText, style: const pw.TextStyle(fontSize: 11)),
            pw.SizedBox(height: 24),
            pw.Text('I accept these rules:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            if (signatureImage != null)
              pw.Container(
                height: 60,
                width: 200,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                ),
                child: pw.Image(pw.MemoryImage(signatureImage)),
              ),
            pw.SizedBox(height: 8),
            pw.Text(
                'Timestamp: ${DateFormat('dd.MM.yyyy HH:mm:ss').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static Future<void> printCleaningReport(
    String unitName,
    String cleanerName,
    List<Map<String, dynamic>> tasks,
    String notes,
    Uint8List? signatureImage,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('CLEANING LOG',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Unit: $unitName | Cleaner: $cleanerName'),
            pw.Text(
                'Date: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}'),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 16),
            ...tasks.map((task) {
              final isDone = task['checked'] == true;
              return pw.Row(
                children: [
                  pw.Container(
                    width: 16,
                    height: 16,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                      color: isDone ? PdfColors.green : null,
                    ),
                    child: isDone
                        ? pw.Center(
                            child: pw.Text('✓',
                                style: const pw.TextStyle(
                                    fontSize: 12, color: PdfColors.white)))
                        : null,
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(task['name'] ?? ''),
                ],
              );
            }),
            pw.SizedBox(height: 16),
            pw.Text('Notes:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(notes.isEmpty ? 'N/A' : notes),
            pw.SizedBox(height: 24),
            if (signatureImage != null)
              pw.Container(
                height: 60,
                width: 200,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                ),
                child: pw.Image(pw.MemoryImage(signatureImage)),
              ),
            pw.SizedBox(height: 8),
            pw.Text(
                'Completed: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static Future<void> printUnitSchedule(
    Unit unit,
    List<Booking> bookings,
  ) async {
    final pdf = pw.Document();

    final unitBookings = bookings.where((b) => b.unitId == unit.id).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Text('FULL SEASON SCHEDULE',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Unit: ${unit.name}'),
            pw.Text('From: Today → Last Check-out'),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 16),
            if (unitBookings.isEmpty)
              pw.Text('No bookings found',
                  style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
            ...unitBookings.map((booking) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _getStatusColor(booking.status)),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(booking.guestName,
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: pw.BoxDecoration(
                            color: _getStatusColor(booking.status),
                            borderRadius: const pw.BorderRadius.all(
                                pw.Radius.circular(4)),
                          ),
                          child: pw.Text(
                            booking.status.toUpperCase(),
                            style: const pw.TextStyle(
                                fontSize: 8, color: PdfColors.white),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                        '${DateFormat('dd.MM.yyyy').format(booking.startDate)} ${booking.checkInTime} - ${DateFormat('dd.MM.yyyy').format(booking.endDate)} ${booking.checkOutTime}'),
                    pw.Text('${booking.guestCount} pax'),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
