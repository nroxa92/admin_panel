// FILE: lib/repositories/base_repository.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 3.0.0 - Phase 3 Repository Pattern

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Base Repository Interface
///
/// Provides standard CRUD operations and query methods.
/// All repositories should extend this base class.
abstract class BaseRepository<T> {
  final FirebaseFirestore firestore;
  final String collectionPath;

  BaseRepository({
    FirebaseFirestore? firestore,
    required this.collectionPath,
  }) : firestore = firestore ?? FirebaseFirestore.instance;

  /// Get collection reference
  CollectionReference<Map<String, dynamic>> get collection =>
      firestore.collection(collectionPath);

  /// Convert Firestore document to model
  T fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc);

  /// Convert model to Firestore map
  Map<String, dynamic> toFirestore(T model);

  // =====================================================
  // CRUD OPERATIONS
  // =====================================================

  /// Get document by ID
  Future<T?> getById(String id) async {
    try {
      final doc = await collection.doc(id).get();
      if (!doc.exists) return null;
      return fromFirestore(doc);
    } catch (e) {
      debugPrint('❌ Repository.getById error: $e');
      rethrow;
    }
  }

  /// Get all documents
  Future<List<T>> getAll() async {
    try {
      final snapshot = await collection.get();
      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('❌ Repository.getAll error: $e');
      rethrow;
    }
  }

  /// Create new document
  Future<String> create(T model, {String? id}) async {
    try {
      final data = toFirestore(model);
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      if (id != null) {
        await collection.doc(id).set(data);
        return id;
      } else {
        final docRef = await collection.add(data);
        return docRef.id;
      }
    } catch (e) {
      debugPrint('❌ Repository.create error: $e');
      rethrow;
    }
  }

  /// Update existing document
  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await collection.doc(id).update(data);
    } catch (e) {
      debugPrint('❌ Repository.update error: $e');
      rethrow;
    }
  }

  /// Delete document
  Future<void> delete(String id) async {
    try {
      await collection.doc(id).delete();
    } catch (e) {
      debugPrint('❌ Repository.delete error: $e');
      rethrow;
    }
  }

  /// Check if document exists
  Future<bool> exists(String id) async {
    try {
      final doc = await collection.doc(id).get();
      return doc.exists;
    } catch (e) {
      debugPrint('❌ Repository.exists error: $e');
      return false;
    }
  }

  // =====================================================
  // QUERY OPERATIONS
  // =====================================================

  /// Query documents with filters
  Future<List<T>> query({
    List<QueryFilter>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = collection;

      // Apply filters
      if (filters != null) {
        for (final filter in filters) {
          query = _applyFilter(query, filter);
        }
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      debugPrint('❌ Repository.query error: $e');
      rethrow;
    }
  }

  Query<Map<String, dynamic>> _applyFilter(
    Query<Map<String, dynamic>> query,
    QueryFilter filter,
  ) {
    switch (filter.operator) {
      case FilterOperator.equals:
        return query.where(filter.field, isEqualTo: filter.value);
      case FilterOperator.notEquals:
        return query.where(filter.field, isNotEqualTo: filter.value);
      case FilterOperator.greaterThan:
        return query.where(filter.field, isGreaterThan: filter.value);
      case FilterOperator.greaterOrEqual:
        return query.where(filter.field, isGreaterThanOrEqualTo: filter.value);
      case FilterOperator.lessThan:
        return query.where(filter.field, isLessThan: filter.value);
      case FilterOperator.lessOrEqual:
        return query.where(filter.field, isLessThanOrEqualTo: filter.value);
      case FilterOperator.arrayContains:
        return query.where(filter.field, arrayContains: filter.value);
      case FilterOperator.whereIn:
        return query.where(filter.field, whereIn: filter.value as List);
    }
  }

  // =====================================================
  // STREAM OPERATIONS
  // =====================================================

  /// Stream single document
  Stream<T?> streamById(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return fromFirestore(doc);
    });
  }

  /// Stream all documents
  Stream<List<T>> streamAll() {
    return collection.snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => fromFirestore(doc)).toList());
  }

  /// Stream with query
  Stream<List<T>> streamQuery({
    List<QueryFilter>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = collection;

    if (filters != null) {
      for (final filter in filters) {
        query = _applyFilter(query, filter);
      }
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) =>
            fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList());
  }

  // =====================================================
  // BATCH OPERATIONS
  // =====================================================

  /// Batch create multiple documents
  Future<void> batchCreate(List<T> models) async {
    try {
      final batch = firestore.batch();

      for (final model in models) {
        final data = toFirestore(model);
        data['createdAt'] = FieldValue.serverTimestamp();
        data['updatedAt'] = FieldValue.serverTimestamp();
        batch.set(collection.doc(), data);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('❌ Repository.batchCreate error: $e');
      rethrow;
    }
  }

  /// Batch delete multiple documents
  Future<void> batchDelete(List<String> ids) async {
    try {
      final batch = firestore.batch();

      for (final id in ids) {
        batch.delete(collection.doc(id));
      }

      await batch.commit();
    } catch (e) {
      debugPrint('❌ Repository.batchDelete error: $e');
      rethrow;
    }
  }
}

// =====================================================
// QUERY FILTER
// =====================================================

class QueryFilter {
  final String field;
  final FilterOperator operator;
  final dynamic value;

  QueryFilter({
    required this.field,
    required this.operator,
    required this.value,
  });

  factory QueryFilter.equals(String field, dynamic value) =>
      QueryFilter(field: field, operator: FilterOperator.equals, value: value);

  factory QueryFilter.greaterThan(String field, dynamic value) => QueryFilter(
      field: field, operator: FilterOperator.greaterThan, value: value);

  factory QueryFilter.lessThan(String field, dynamic value) => QueryFilter(
      field: field, operator: FilterOperator.lessThan, value: value);
}

enum FilterOperator {
  equals,
  notEquals,
  greaterThan,
  greaterOrEqual,
  lessThan,
  lessOrEqual,
  arrayContains,
  whereIn,
}

// =====================================================
// RESULT WRAPPER
// =====================================================

class RepositoryResult<T> {
  final T? data;
  final String? error;
  final bool success;

  RepositoryResult._({this.data, this.error, required this.success});

  factory RepositoryResult.success(T data) =>
      RepositoryResult._(data: data, success: true);

  factory RepositoryResult.failure(String error) =>
      RepositoryResult._(error: error, success: false);
}
