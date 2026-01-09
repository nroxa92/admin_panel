// FILE: lib/repositories/units_repository.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 3.0.0 - Phase 3 Repository Pattern

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'base_repository.dart';

/// Units Repository
///
/// Handles all unit (villa/apartment) related database operations.
class UnitsRepository extends BaseRepository<Unit> {
  final String ownerId;

  UnitsRepository({
    required this.ownerId,
    super.firestore,
  }) : super(collectionPath: 'units');

  @override
  Unit fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Unit.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(Unit model) {
    return model.toMap();
  }

  // =====================================================
  // OWNER-SCOPED QUERIES
  // =====================================================

  /// Get all units for owner
  Future<List<Unit>> getOwnerUnits() async {
    return query(
      filters: [QueryFilter.equals('ownerId', ownerId)],
      orderBy: 'name',
    );
  }

  /// Stream owner's units
  Stream<List<Unit>> streamOwnerUnits() {
    return streamQuery(
      filters: [QueryFilter.equals('ownerId', ownerId)],
      orderBy: 'name',
    );
  }

  /// Get unit count
  Future<int> getUnitCount() async {
    try {
      final snapshot =
          await collection.where('ownerId', isEqualTo: ownerId).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('❌ UnitsRepository.getUnitCount error: $e');
      final units = await getOwnerUnits();
      return units.length;
    }
  }

  /// Get active units
  Future<List<Unit>> getActiveUnits() async {
    return query(
      filters: [
        QueryFilter.equals('ownerId', ownerId),
        QueryFilter.equals('isActive', true),
      ],
    );
  }

  /// Get unit by name
  Future<Unit?> getByName(String name) async {
    final units = await query(
      filters: [
        QueryFilter.equals('ownerId', ownerId),
        QueryFilter.equals('name', name),
      ],
      limit: 1,
    );
    return units.isNotEmpty ? units.first : null;
  }

  // =====================================================
  // ANALYTICS
  // =====================================================

  /// Get unit statistics
  Future<UnitStats> getStats() async {
    try {
      final units = await getOwnerUnits();

      int totalUnits = units.length;
      int activeUnits = units.where((u) => u.isActive).length;
      int totalCapacity = units.fold(0, (acc, u) => acc + u.maxGuests);

      return UnitStats(
        totalUnits: totalUnits,
        activeUnits: activeUnits,
        inactiveUnits: totalUnits - activeUnits,
        totalCapacity: totalCapacity,
      );
    } catch (e) {
      debugPrint('❌ UnitsRepository.getStats error: $e');
      rethrow;
    }
  }
}

// =====================================================
// UNIT MODEL
// =====================================================

class Unit {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final String? address;
  final int maxGuests;
  final int bedrooms;
  final int bathrooms;
  final bool isActive;
  final String? imageUrl;
  final Map<String, dynamic>? amenities;
  final DateTime? createdAt;

  Unit({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.address,
    required this.maxGuests,
    required this.bedrooms,
    required this.bathrooms,
    this.isActive = true,
    this.imageUrl,
    this.amenities,
    this.createdAt,
  });

  factory Unit.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Unit(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      address: data['address'],
      maxGuests: data['maxGuests'] ?? 1,
      bedrooms: data['bedrooms'] ?? 1,
      bathrooms: data['bathrooms'] ?? 1,
      isActive: data['isActive'] ?? true,
      imageUrl: data['imageUrl'],
      amenities: data['amenities'] as Map<String, dynamic>?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'address': address,
      'maxGuests': maxGuests,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'amenities': amenities,
    };
  }
}

// =====================================================
// UNIT STATS MODEL
// =====================================================

class UnitStats {
  final int totalUnits;
  final int activeUnits;
  final int inactiveUnits;
  final int totalCapacity;

  UnitStats({
    required this.totalUnits,
    required this.activeUnits,
    required this.inactiveUnits,
    required this.totalCapacity,
  });
}
