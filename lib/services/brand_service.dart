// FILE: lib/services/brand_service.dart
// VERSION: 1.0 - Brand Management & Detection
// DATE: 2026-01-10

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Brand model representing a white-label or retail brand
class Brand {
  final String id;
  final String name;
  final String domain;
  final String type; // 'retail' or 'white_label'
  final bool isLocked;

  // Visual Identity
  final String logoUrl;
  final String logoLightUrl;
  final String faviconUrl;
  final String splashImageUrl;

  // Colors
  final String primaryColor;
  final String secondaryColor;
  final String accentColor;

  // Text
  final String appName;
  final String tagline;
  final String supportEmail;
  final String websiteUrl;

  // Stats
  final int clientCount;
  final int totalUnits;
  final int totalBookings;

  // Meta
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Brand({
    required this.id,
    required this.name,
    required this.domain,
    required this.type,
    this.isLocked = false,
    this.logoUrl = '',
    this.logoLightUrl = '',
    this.faviconUrl = '',
    this.splashImageUrl = '',
    this.primaryColor = '#D4AF37',
    this.secondaryColor = '#1E1E1E',
    this.accentColor = '#FFFFFF',
    this.appName = '',
    this.tagline = '',
    this.supportEmail = '',
    this.websiteUrl = '',
    this.clientCount = 0,
    this.totalUnits = 0,
    this.totalBookings = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Brand.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Brand(
      id: doc.id,
      name: data['name'] ?? '',
      domain: data['domain'] ?? '',
      type: data['type'] ?? 'retail',
      isLocked: data['isLocked'] ?? false,
      logoUrl: data['logoUrl'] ?? '',
      logoLightUrl: data['logoLightUrl'] ?? '',
      faviconUrl: data['faviconUrl'] ?? '',
      splashImageUrl: data['splashImageUrl'] ?? '',
      primaryColor: data['primaryColor'] ?? '#D4AF37',
      secondaryColor: data['secondaryColor'] ?? '#1E1E1E',
      accentColor: data['accentColor'] ?? '#FFFFFF',
      appName: data['appName'] ?? data['name'] ?? '',
      tagline: data['tagline'] ?? '',
      supportEmail: data['supportEmail'] ?? '',
      websiteUrl: data['websiteUrl'] ?? '',
      clientCount: data['clientCount'] ?? 0,
      totalUnits: data['totalUnits'] ?? 0,
      totalBookings: data['totalBookings'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'domain': domain,
      'type': type,
      'isLocked': isLocked,
      'logoUrl': logoUrl,
      'logoLightUrl': logoLightUrl,
      'faviconUrl': faviconUrl,
      'splashImageUrl': splashImageUrl,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'accentColor': accentColor,
      'appName': appName,
      'tagline': tagline,
      'supportEmail': supportEmail,
      'websiteUrl': websiteUrl,
      'clientCount': clientCount,
      'totalUnits': totalUnits,
      'totalBookings': totalBookings,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Brand copyWith({
    String? name,
    String? domain,
    String? type,
    bool? isLocked,
    String? logoUrl,
    String? logoLightUrl,
    String? faviconUrl,
    String? splashImageUrl,
    String? primaryColor,
    String? secondaryColor,
    String? accentColor,
    String? appName,
    String? tagline,
    String? supportEmail,
    String? websiteUrl,
    int? clientCount,
    int? totalUnits,
    int? totalBookings,
  }) {
    return Brand(
      id: id,
      name: name ?? this.name,
      domain: domain ?? this.domain,
      type: type ?? this.type,
      isLocked: isLocked ?? this.isLocked,
      logoUrl: logoUrl ?? this.logoUrl,
      logoLightUrl: logoLightUrl ?? this.logoLightUrl,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      splashImageUrl: splashImageUrl ?? this.splashImageUrl,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
      appName: appName ?? this.appName,
      tagline: tagline ?? this.tagline,
      supportEmail: supportEmail ?? this.supportEmail,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      clientCount: clientCount ?? this.clientCount,
      totalUnits: totalUnits ?? this.totalUnits,
      totalBookings: totalBookings ?? this.totalBookings,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Get default Vesta Lumina brand
  static Brand get defaultBrand => Brand(
        id: 'vesta-lumina',
        name: 'Vesta Lumina',
        domain: 'vestalumina.com',
        type: 'retail',
        isLocked: true,
        primaryColor: '#D4AF37',
        secondaryColor: '#1E1E1E',
        accentColor: '#FFFFFF',
        appName: 'Vesta Lumina',
        tagline: 'Smart Property Management',
        supportEmail: 'support@vestalumina.com',
        websiteUrl: 'https://vestalumina.com',
      );
}

/// Service for brand management and detection
class BrandService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton pattern
  static final BrandService _instance = BrandService._internal();
  factory BrandService() => _instance;
  BrandService._internal();

  // Cache
  Brand? _cachedBrand;
  String? _cachedOwnerId;

  // ═══════════════════════════════════════════════════════════════════
  // BRAND DETECTION
  // ═══════════════════════════════════════════════════════════════════

  /// Get brand by email domain
  Future<Brand?> getBrandByDomain(String email) async {
    try {
      final domain = email.split('@').last.toLowerCase();

      final snapshot = await _firestore
          .collection('brands')
          .where('domain', isEqualTo: domain)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Brand.fromFirestore(snapshot.docs.first);
      }

      // Fallback to default brand
      return await getDefaultBrand();
    } catch (e) {
      debugPrint('❌ Error getting brand by domain: $e');
      return Brand.defaultBrand;
    }
  }

  /// Get brand by owner ID (from tenant_links)
  Future<Brand?> getBrandByOwnerId(String ownerId) async {
    // Return cached if same owner
    if (_cachedOwnerId == ownerId && _cachedBrand != null) {
      return _cachedBrand;
    }

    try {
      final tenantDoc =
          await _firestore.collection('tenant_links').doc(ownerId).get();

      if (!tenantDoc.exists) {
        return await getDefaultBrand();
      }

      final brandId = tenantDoc.data()?['brandId'] ?? 'vesta-lumina';

      final brandDoc = await _firestore.collection('brands').doc(brandId).get();

      if (brandDoc.exists) {
        _cachedBrand = Brand.fromFirestore(brandDoc);
        _cachedOwnerId = ownerId;
        return _cachedBrand;
      }

      return await getDefaultBrand();
    } catch (e) {
      debugPrint('❌ Error getting brand by ownerId: $e');
      return Brand.defaultBrand;
    }
  }

  /// Get default Vesta Lumina brand from Firestore
  Future<Brand> getDefaultBrand() async {
    try {
      final doc =
          await _firestore.collection('brands').doc('vesta-lumina').get();

      if (doc.exists) {
        return Brand.fromFirestore(doc);
      }

      // Create default if doesn't exist
      await createDefaultBrand();
      return Brand.defaultBrand;
    } catch (e) {
      debugPrint('❌ Error getting default brand: $e');
      return Brand.defaultBrand;
    }
  }

  /// Create default Vesta Lumina brand (run once)
  Future<void> createDefaultBrand() async {
    try {
      final docRef = _firestore.collection('brands').doc('vesta-lumina');
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({
          ...Brand.defaultBrand.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        debugPrint('✅ Created default Vesta Lumina brand');
      }
    } catch (e) {
      debugPrint('❌ Error creating default brand: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // BRAND CRUD
  // ═══════════════════════════════════════════════════════════════════

  /// Get all brands
  Future<List<Brand>> getAllBrands() async {
    try {
      final snapshot = await _firestore
          .collection('brands')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Brand.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('❌ Error getting all brands: $e');
      return [];
    }
  }

  /// Get brands by type
  Future<List<Brand>> getBrandsByType(String type) async {
    try {
      final snapshot = await _firestore
          .collection('brands')
          .where('type', isEqualTo: type)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Brand.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('❌ Error getting brands by type: $e');
      return [];
    }
  }

  /// Get single brand by ID
  Future<Brand?> getBrandById(String brandId) async {
    try {
      final doc = await _firestore.collection('brands').doc(brandId).get();

      if (doc.exists) {
        return Brand.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting brand by id: $e');
      return null;
    }
  }

  /// Create new brand
  Future<String?> createBrand({
    required String name,
    required String domain,
    required String type,
    String? primaryColor,
    String? secondaryColor,
    String? tagline,
    String? supportEmail,
    String? websiteUrl,
  }) async {
    try {
      // Generate ID from domain
      final brandId =
          domain.replaceAll('.', '-').replaceAll('_', '-').toLowerCase();

      // Check if domain already exists
      final existing = await _firestore
          .collection('brands')
          .where('domain', isEqualTo: domain.toLowerCase())
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('Brand with this domain already exists');
      }

      final brand = Brand(
        id: brandId,
        name: name,
        domain: domain.toLowerCase(),
        type: type,
        isLocked: false,
        primaryColor: primaryColor ?? '#D4AF37',
        secondaryColor: secondaryColor ?? '#1E1E1E',
        accentColor: '#FFFFFF',
        appName: name,
        tagline: tagline ?? '',
        supportEmail: supportEmail ?? 'support@$domain',
        websiteUrl: websiteUrl ?? 'https://$domain',
      );

      await _firestore.collection('brands').doc(brandId).set({
        ...brand.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Created brand: $brandId');
      return brandId;
    } catch (e) {
      debugPrint('❌ Error creating brand: $e');
      rethrow;
    }
  }

  /// Update brand
  Future<void> updateBrand(String brandId, Map<String, dynamic> data) async {
    try {
      // Don't allow changing domain or id
      data.remove('id');
      data.remove('domain');
      data.remove('createdAt');

      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('brands').doc(brandId).update(data);

      // Clear cache if updated
      if (_cachedBrand?.id == brandId) {
        _cachedBrand = null;
        _cachedOwnerId = null;
      }

      debugPrint('✅ Updated brand: $brandId');
    } catch (e) {
      debugPrint('❌ Error updating brand: $e');
      rethrow;
    }
  }

  /// Delete brand (only if no clients)
  Future<void> deleteBrand(String brandId) async {
    try {
      // Check if brand is locked
      final brandDoc = await _firestore.collection('brands').doc(brandId).get();
      if (brandDoc.data()?['isLocked'] == true) {
        throw Exception('Cannot delete locked brand');
      }

      // Check if brand has clients
      final clients = await _firestore
          .collection('tenant_links')
          .where('brandId', isEqualTo: brandId)
          .limit(1)
          .get();

      if (clients.docs.isNotEmpty) {
        throw Exception('Cannot delete brand with existing clients');
      }

      await _firestore.collection('brands').doc(brandId).delete();

      debugPrint('✅ Deleted brand: $brandId');
    } catch (e) {
      debugPrint('❌ Error deleting brand: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // BRAND STATS
  // ═══════════════════════════════════════════════════════════════════

  /// Update brand statistics
  Future<void> updateBrandStats(String brandId) async {
    try {
      // Count clients
      final clientsSnap = await _firestore
          .collection('tenant_links')
          .where('brandId', isEqualTo: brandId)
          .get();

      final clientIds = clientsSnap.docs.map((d) => d.id).toList();

      int totalUnits = 0;
      int totalBookings = 0;

      for (final clientId in clientIds) {
        final unitsSnap = await _firestore
            .collection('units')
            .where('ownerId', isEqualTo: clientId)
            .get();
        totalUnits += unitsSnap.size;

        final bookingsSnap = await _firestore
            .collection('bookings')
            .where('ownerId', isEqualTo: clientId)
            .get();
        totalBookings += bookingsSnap.size;
      }

      await _firestore.collection('brands').doc(brandId).update({
        'clientCount': clientIds.length,
        'totalUnits': totalUnits,
        'totalBookings': totalBookings,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Updated stats for brand: $brandId');
    } catch (e) {
      debugPrint('❌ Error updating brand stats: $e');
    }
  }

  /// Update all brand statistics
  Future<void> updateAllBrandStats() async {
    try {
      final brands = await getAllBrands();
      for (final brand in brands) {
        await updateBrandStats(brand.id);
      }
      debugPrint('✅ Updated all brand stats');
    } catch (e) {
      debugPrint('❌ Error updating all brand stats: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════

  /// Clear cache
  void clearCache() {
    _cachedBrand = null;
    _cachedOwnerId = null;
  }

  /// Stream brand changes
  Stream<Brand?> streamBrand(String brandId) {
    return _firestore
        .collection('brands')
        .doc(brandId)
        .snapshots()
        .map((doc) => doc.exists ? Brand.fromFirestore(doc) : null);
  }

  /// Get clients for brand
  Future<List<Map<String, dynamic>>> getBrandClients(String brandId) async {
    try {
      final snapshot = await _firestore
          .collection('tenant_links')
          .where('brandId', isEqualTo: brandId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['tenantId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting brand clients: $e');
      return [];
    }
  }
}
