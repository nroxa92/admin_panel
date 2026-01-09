// FILE: lib/services/calendar_service.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 4.0.0 - Phase 4 Calendar Integrations

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../repositories/booking_repository.dart';

/// Calendar Service for iCal Export and Integrations
class CalendarService {
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();

  // =====================================================
  // ICAL EXPORT
  // =====================================================

  /// Generate iCal string for a list of bookings
  String generateICal({
    required List<Booking> bookings,
    required String calendarName,
    String? ownerName,
  }) {
    final buffer = StringBuffer();

    // iCal header
    buffer.writeln('BEGIN:VCALENDAR');
    buffer.writeln('VERSION:2.0');
    buffer.writeln('PRODID:-//VLS Admin Panel//Bookings Calendar//EN');
    buffer.writeln('CALSCALE:GREGORIAN');
    buffer.writeln('METHOD:PUBLISH');
    buffer.writeln('X-WR-CALNAME:$calendarName');
    if (ownerName != null) {
      buffer.writeln('X-WR-CALDESC:Bookings for $ownerName');
    }
    buffer.writeln('X-WR-TIMEZONE:Europe/Zagreb');

    // Timezone definition
    buffer.writeln(_getTimezoneComponent());

    // Add events for each booking
    for (final booking in bookings) {
      buffer.writeln(_generateEvent(booking));
    }

    // iCal footer
    buffer.writeln('END:VCALENDAR');

    return buffer.toString();
  }

  /// Generate single iCal event
  String _generateEvent(Booking booking) {
    final buffer = StringBuffer();
    final now = DateTime.now().toUtc();
    final uid = '${booking.id}@vls-admin.web.app';

    buffer.writeln('BEGIN:VEVENT');
    buffer.writeln('UID:$uid');
    buffer.writeln('DTSTAMP:${_formatDateTime(now)}');
    buffer.writeln('DTSTART;VALUE=DATE:${_formatDate(booking.checkIn)}');
    buffer.writeln(
        'DTEND;VALUE=DATE:${_formatDate(booking.checkOut.add(const Duration(days: 1)))}');
    buffer.writeln(
        'SUMMARY:${_escapeText(booking.guestName)} - ${_escapeText(booking.unitName)}');

    // Description with booking details
    final description = _buildDescription(booking);
    buffer.writeln('DESCRIPTION:${_escapeText(description)}');

    // Location
    buffer.writeln('LOCATION:${_escapeText(booking.unitName)}');

    // Status
    final status = _mapStatus(booking.status);
    buffer.writeln('STATUS:$status');

    // Categories
    buffer.writeln('CATEGORIES:Booking,${booking.unitName}');

    // Transparency (busy)
    buffer.writeln('TRANSP:OPAQUE');

    buffer.writeln('END:VEVENT');

    return buffer.toString();
  }

  String _buildDescription(Booking booking) {
    final parts = <String>[
      'Guest: ${booking.guestName}',
      'Unit: ${booking.unitName}',
      'Guests: ${booking.guestCount}',
      'Check-in: ${_formatDisplayDate(booking.checkIn)}',
      'Check-out: ${_formatDisplayDate(booking.checkOut)}',
      'Nights: ${booking.stayLength}',
      'Status: ${booking.status}',
    ];

    if (booking.guestEmail != null) {
      parts.add('Email: ${booking.guestEmail}');
    }
    if (booking.guestPhone != null) {
      parts.add('Phone: ${booking.guestPhone}');
    }
    if (booking.notes != null && booking.notes!.isNotEmpty) {
      parts.add('Notes: ${booking.notes}');
    }

    return parts.join('\\n');
  }

  String _getTimezoneComponent() {
    return '''BEGIN:VTIMEZONE
TZID:Europe/Zagreb
BEGIN:DAYLIGHT
TZOFFSETFROM:+0100
TZOFFSETTO:+0200
TZNAME:CEST
DTSTART:19700329T020000
RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU
END:DAYLIGHT
BEGIN:STANDARD
TZOFFSETFROM:+0200
TZOFFSETTO:+0100
TZNAME:CET
DTSTART:19701025T030000
RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU
END:STANDARD
END:VTIMEZONE''';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}${_pad(dt.month)}${_pad(dt.day)}T'
        '${_pad(dt.hour)}${_pad(dt.minute)}${_pad(dt.second)}Z';
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}${_pad(dt.month)}${_pad(dt.day)}';
  }

  String _formatDisplayDate(DateTime dt) {
    return '${dt.day}.${dt.month}.${dt.year}';
  }

  String _pad(int value) => value.toString().padLeft(2, '0');

  String _escapeText(String text) {
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll(',', '\\,')
        .replaceAll(';', '\\;')
        .replaceAll('\n', '\\n');
  }

  String _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'active':
        return 'CONFIRMED';
      case 'cancelled':
        return 'CANCELLED';
      case 'pending':
        return 'TENTATIVE';
      default:
        return 'CONFIRMED';
    }
  }

  // =====================================================
  // EXPORT HELPERS
  // =====================================================

  /// Copy iCal content to clipboard
  Future<void> copyToClipboard(String icalContent) async {
    await Clipboard.setData(ClipboardData(text: icalContent));
  }

  /// Generate download URL for iCal (Web only)
  String generateDownloadUrl(String icalContent, String filename) {
    final bytes = utf8.encode(icalContent);
    final base64Data = base64Encode(bytes);
    return 'data:text/calendar;base64,$base64Data';
  }

  /// Generate iCal for single booking
  String generateSingleBookingICal(Booking booking) {
    return generateICal(
      bookings: [booking],
      calendarName: '${booking.guestName} - ${booking.unitName}',
    );
  }

  /// Generate iCal for unit
  String generateUnitICal({
    required String unitName,
    required List<Booking> bookings,
  }) {
    return generateICal(
      bookings: bookings,
      calendarName: '$unitName Bookings',
    );
  }

  // =====================================================
  // GOOGLE CALENDAR URL
  // =====================================================

  /// Generate Google Calendar add event URL
  String generateGoogleCalendarUrl(Booking booking) {
    final title =
        Uri.encodeComponent('${booking.guestName} - ${booking.unitName}');
    final details =
        Uri.encodeComponent(_buildDescription(booking).replaceAll('\\n', '\n'));
    final location = Uri.encodeComponent(booking.unitName);

    final startDate = _formatDate(booking.checkIn);
    final endDate = _formatDate(booking.checkOut.add(const Duration(days: 1)));

    return 'https://calendar.google.com/calendar/render'
        '?action=TEMPLATE'
        '&text=$title'
        '&dates=$startDate/$endDate'
        '&details=$details'
        '&location=$location';
  }

  /// Generate Google Calendar subscription URL (for iCal feed)
  String generateGoogleCalendarSubscribeUrl(String icalUrl) {
    final encodedUrl = Uri.encodeComponent(icalUrl);
    return 'https://calendar.google.com/calendar/r?cid=$encodedUrl';
  }

  // =====================================================
  // OUTLOOK URL
  // =====================================================

  /// Generate Outlook Web add event URL
  String generateOutlookUrl(Booking booking) {
    final subject =
        Uri.encodeComponent('${booking.guestName} - ${booking.unitName}');
    final body =
        Uri.encodeComponent(_buildDescription(booking).replaceAll('\\n', '\n'));
    final location = Uri.encodeComponent(booking.unitName);

    final startDate = booking.checkIn.toIso8601String();
    final endDate =
        booking.checkOut.add(const Duration(days: 1)).toIso8601String();

    return 'https://outlook.live.com/calendar/0/deeplink/compose'
        '?subject=$subject'
        '&startdt=$startDate'
        '&enddt=$endDate'
        '&body=$body'
        '&location=$location'
        '&allday=true';
  }

  // =====================================================
  // IMPORT PARSING
  // =====================================================

  /// Parse iCal string to extract bookings (basic parsing)
  List<ICalEvent> parseICal(String icalContent) {
    final events = <ICalEvent>[];
    final lines = icalContent.split('\n');

    Map<String, String>? currentEvent;

    for (var line in lines) {
      line = line.trim();

      if (line == 'BEGIN:VEVENT') {
        currentEvent = {};
      } else if (line == 'END:VEVENT' && currentEvent != null) {
        events.add(ICalEvent.fromMap(currentEvent));
        currentEvent = null;
      } else if (currentEvent != null && line.contains(':')) {
        final colonIndex = line.indexOf(':');
        final key = line.substring(0, colonIndex).split(';').first;
        final value = line.substring(colonIndex + 1);
        currentEvent[key] = _unescapeText(value);
      }
    }

    return events;
  }

  String _unescapeText(String text) {
    return text
        .replaceAll('\\n', '\n')
        .replaceAll('\\,', ',')
        .replaceAll('\\;', ';')
        .replaceAll('\\\\', '\\');
  }
}

// =====================================================
// ICAL EVENT MODEL
// =====================================================

class ICalEvent {
  final String? uid;
  final String? summary;
  final String? description;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;

  ICalEvent({
    this.uid,
    this.summary,
    this.description,
    this.location,
    this.startDate,
    this.endDate,
    this.status,
  });

  factory ICalEvent.fromMap(Map<String, String> map) {
    return ICalEvent(
      uid: map['UID'],
      summary: map['SUMMARY'],
      description: map['DESCRIPTION'],
      location: map['LOCATION'],
      startDate: _parseDate(map['DTSTART']),
      endDate: _parseDate(map['DTEND']),
      status: map['STATUS'],
    );
  }

  static DateTime? _parseDate(String? value) {
    if (value == null) return null;

    try {
      // Handle different date formats
      if (value.length == 8) {
        // YYYYMMDD
        return DateTime(
          int.parse(value.substring(0, 4)),
          int.parse(value.substring(4, 6)),
          int.parse(value.substring(6, 8)),
        );
      } else if (value.length >= 15) {
        // YYYYMMDDTHHmmss or YYYYMMDDTHHmmssZ
        return DateTime(
          int.parse(value.substring(0, 4)),
          int.parse(value.substring(4, 6)),
          int.parse(value.substring(6, 8)),
          int.parse(value.substring(9, 11)),
          int.parse(value.substring(11, 13)),
          int.parse(value.substring(13, 15)),
        );
      }
    } catch (e) {
      debugPrint('Error parsing iCal date: $value');
    }

    return null;
  }
}
