// FILE: lib/config/firestore_fields.dart
// VERSION: 1.0
// DATE: 2026-01-11
// PURPOSE: Centralized Firestore field names to ensure consistency
//          between Admin Panel and Tablet Terminal
//
// USAGE:
//   import '../config/firestore_fields.dart';
//   .where(FF.unitId, isEqualTo: unitId)
//   data[FF.guestName]

/// Firestore Field Names - SYNC WITH TABLET!
/// Use these constants instead of hardcoded strings.
class FF {
  // =====================================================
  // BOOKINGS COLLECTION
  // =====================================================
  static const String ownerId = 'ownerId';
  static const String unitId = 'unitId';
  static const String guestName = 'guestName';
  static const String startDate = 'startDate';
  static const String endDate = 'endDate';
  static const String status = 'status';
  static const String source = 'source';
  static const String note = 'note';
  static const String isScanned = 'isScanned';
  static const String guestCount = 'guestCount';
  static const String scannedGuestCount = 'scannedGuestCount';
  static const String checkInTime = 'checkInTime';
  static const String checkOutTime = 'checkOutTime';
  static const String guests = 'guests';
  static const String scannedAt = 'scannedAt';
  static const String updatedAt = 'updatedAt';
  static const String createdAt = 'createdAt';

  // =====================================================
  // UNITS COLLECTION
  // =====================================================
  static const String name = 'name';
  static const String address = 'address';
  static const String category = 'category';
  static const String zone = 'zone'; // Alias for category
  static const String wifiSsid = 'wifiSsid';
  static const String wifiPass = 'wifiPass';
  static const String cleanerPin = 'cleanerPin';
  static const String reviewLink = 'reviewLink';
  static const String contactOptions = 'contactOptions';

  // =====================================================
  // SETTINGS COLLECTION
  // =====================================================
  static const String ownerFirstName = 'ownerFirstName';
  static const String ownerLastName = 'ownerLastName';
  static const String ownerEmail = 'ownerEmail';
  static const String brandName = 'brandName';
  static const String brandLogoUrl = 'brandLogoUrl';
  static const String themeColor = 'themeColor';
  static const String themeMode = 'themeMode';
  static const String appLanguage = 'appLanguage';
  static const String cleanerChecklist = 'cleanerChecklist';
  static const String hardResetPin = 'hardResetPin';
  static const String kioskExitPin = 'kioskExitPin';
  static const String houseRulesTranslations = 'houseRulesTranslations';
  static const String welcomeMessageTranslations = 'welcomeMessageTranslations';
  static const String welcomeMessageDuration = 'welcomeMessageDuration';
  static const String houseRulesDuration = 'houseRulesDuration';
  static const String categories = 'categories';

  // AI Context fields
  static const String aiConcierge = 'aiConcierge';
  static const String aiHousekeeper = 'aiHousekeeper';
  static const String aiTech = 'aiTech';
  static const String aiGuide = 'aiGuide';
  static const String aiLocation = 'aiLocation';
  static const String aiProperty = 'aiProperty';
  static const String aiServices = 'aiServices';
  static const String aiPersonality = 'aiPersonality';

  // Emergency Contact fields
  static const String emergencyCall = 'emergencyCall';
  static const String emergencySms = 'emergencySms';
  static const String emergencyWhatsapp = 'emergencyWhatsapp';
  static const String emergencyViber = 'emergencyViber';
  static const String emergencyEmail = 'emergencyEmail';

  // =====================================================
  // GUESTS (Array elements in bookings)
  // =====================================================
  static const String firstName = 'firstName';
  static const String lastName = 'lastName';
  static const String dateOfBirth = 'dateOfBirth';
  static const String placeOfBirth = 'placeOfBirth';
  static const String countryOfBirth = 'countryOfBirth';
  static const String nationality = 'nationality';
  static const String sex = 'sex';
  static const String documentType = 'documentType';
  static const String documentNumber = 'documentNumber';
  static const String issuingCountry = 'issuingCountry';
  static const String expiryDate = 'expiryDate';
  static const String residenceCountry = 'residenceCountry';
  static const String residenceCity = 'residenceCity';
  static const String residenceAddress = 'residenceAddress';

  // =====================================================
  // SIGNATURES COLLECTION
  // =====================================================
  static const String bookingId = 'bookingId';
  static const String signatureUrl = 'signatureUrl';
  static const String signedAt = 'signedAt';

  // =====================================================
  // CLEANING LOGS COLLECTION
  // =====================================================
  static const String timestamp = 'timestamp';
  static const String cleanedBy = 'cleanedBy';
  static const String completedTasks = 'completedTasks';
  static const String duration = 'duration';
  static const String photoUrls = 'photoUrls';

  // =====================================================
  // FEEDBACK COLLECTION
  // =====================================================
  static const String rating = 'rating';
  static const String comment = 'comment';
  static const String feedbackType = 'feedbackType';

  // =====================================================
  // AI LOGS COLLECTION
  // =====================================================
  static const String query = 'query';
  static const String response = 'response';
  static const String model = 'model';
  static const String tokensUsed = 'tokensUsed';

  // =====================================================
  // TABLETS COLLECTION
  // =====================================================
  static const String tabletId = 'tabletId';
  static const String deviceName = 'deviceName';
  static const String lastSeen = 'lastSeen';
  static const String appVersion = 'appVersion';
  static const String isOnline = 'isOnline';

  // =====================================================
  // STATUS VALUES (for type safety)
  // =====================================================
  static const String statusConfirmed = 'confirmed';
  static const String statusPending = 'pending';
  static const String statusCancelled = 'cancelled';
  static const String statusCheckedIn = 'checked_in';
  static const String statusCheckedOut = 'checked_out';
  static const String statusBlocked = 'blocked';

  // =====================================================
  // SOURCE VALUES (booking origin platforms)
  // =====================================================
  static const String sourceAirbnb = 'airbnb';
  static const String sourceBooking = 'booking';
  static const String sourceVrbo = 'vrbo';
  static const String sourceExpedia = 'expedia';
  static const String sourceManual = 'manual';
  static const String sourcePrivate = 'private';
  static const String sourceOther = 'other';

  // =====================================================
  // DOCUMENT TYPES (for MRZ scanning)
  // =====================================================
  static const String docTypePassport = 'PASSPORT';
  static const String docTypeIdCard = 'ID_CARD';
  static const String docTypeDriverLicense = 'DRIVER_LICENSE';
  static const String docTypeResidencePermit = 'RESIDENCE_PERMIT';
}
