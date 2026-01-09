// FILE: functions/api_versioning.js
// PROJECT: VillaOS - Phase 5 Enterprise Hardening
// FEATURE: API Versioning for Cloud Functions
// STATUS: PRODUCTION READY

const functions = require("firebase-functions");

/**
 * API Version Configuration
 */
const API_CONFIG = {
  currentVersion: "v2",
  supportedVersions: ["v1", "v2"],
  deprecatedVersions: ["v1"],
  sunsetDate: {
    v1: "2025-06-01",
  },
};

/**
 * Version middleware - validates and extracts API version
 * @param {Object} req - Request object
 * @param {Object} res - Response object
 * @param {Function} next - Next middleware
 */
function versionMiddleware(req, res, next) {
  // Extract version from header, query param, or path
  let version = 
    req.headers["x-api-version"] ||
    req.query.version ||
    extractVersionFromPath(req.path) ||
    API_CONFIG.currentVersion;

  // Normalize version format
  version = version.toLowerCase();
  if (!version.startsWith("v")) {
    version = `v${version}`;
  }

  // Validate version
  if (!API_CONFIG.supportedVersions.includes(version)) {
    return res.status(400).json({
      error: "Unsupported API version",
      supportedVersions: API_CONFIG.supportedVersions,
      currentVersion: API_CONFIG.currentVersion,
    });
  }

  // Add deprecation warning header
  if (API_CONFIG.deprecatedVersions.includes(version)) {
    res.set("X-API-Deprecated", "true");
    res.set("X-API-Sunset-Date", API_CONFIG.sunsetDate[version] || "TBD");
    res.set(
      "Warning",
      `299 - "API version ${version} is deprecated. Please upgrade to ${API_CONFIG.currentVersion}"`
    );
  }

  // Attach version to request
  req.apiVersion = version;
  req.isLatestVersion = version === API_CONFIG.currentVersion;

  next();
}

/**
 * Extract version from URL path (e.g., /v1/users or /api/v2/bookings)
 */
function extractVersionFromPath(path) {
  const match = path.match(/\/(v\d+)\//i);
  return match ? match[1] : null;
}

/**
 * Create versioned endpoint handler
 * @param {Object} handlers - Version-specific handlers { v1: fn, v2: fn }
 */
function versionedHandler(handlers) {
  return async (req, res) => {
    const version = req.apiVersion || API_CONFIG.currentVersion;
    const handler = handlers[version] || handlers[API_CONFIG.currentVersion];

    if (!handler) {
      return res.status(501).json({
        error: `No handler for version ${version}`,
        availableVersions: Object.keys(handlers),
      });
    }

    try {
      await handler(req, res);
    } catch (error) {
      console.error(`API ${version} error:`, error);
      res.status(500).json({
        error: "Internal server error",
        version: version,
        requestId: req.headers["x-request-id"] || "unknown",
      });
    }
  };
}

/**
 * Standard API response wrapper
 */
function apiResponse(res, data, options = {}) {
  const {
    status = 200,
    version = API_CONFIG.currentVersion,
    meta = {},
  } = options;

  return res.status(status).json({
    success: status >= 200 && status < 300,
    version: version,
    timestamp: new Date().toISOString(),
    data: data,
    meta: {
      ...meta,
      apiVersion: version,
      latestVersion: API_CONFIG.currentVersion,
    },
  });
}

/**
 * Standard error response wrapper
 */
function apiError(res, error, options = {}) {
  const {
    status = 500,
    version = API_CONFIG.currentVersion,
    code = "INTERNAL_ERROR",
  } = options;

  return res.status(status).json({
    success: false,
    version: version,
    timestamp: new Date().toISOString(),
    error: {
      code: code,
      message: error.message || error,
      ...(process.env.NODE_ENV !== "production" && { stack: error.stack }),
    },
  });
}

// =====================================================
// EXAMPLE VERSIONED ENDPOINTS
// =====================================================

/**
 * Example: Versioned booking endpoint
 */
const bookingHandlers = {
  // V1: Original format (deprecated)
  v1: async (req, res) => {
    // Legacy response format
    return apiResponse(res, {
      booking_id: req.params.id,
      guest: req.body.guest_name, // old field name
      unit: req.body.unit_id,
    }, { version: "v1" });
  },

  // V2: Current format
  v2: async (req, res) => {
    // New response format with more details
    return apiResponse(res, {
      id: req.params.id,
      guestName: req.body.guestName, // new field name
      unitId: req.body.unitId,
      checkIn: req.body.checkIn,
      checkOut: req.body.checkOut,
      status: req.body.status || "confirmed",
      createdAt: new Date().toISOString(),
    }, { version: "v2" });
  },
};

// =====================================================
// MIGRATION HELPERS
// =====================================================

/**
 * Transform V1 request to V2 format
 */
function migrateV1ToV2Request(body) {
  return {
    guestName: body.guest_name || body.guestName,
    unitId: body.unit_id || body.unitId,
    checkIn: body.check_in || body.checkIn,
    checkOut: body.check_out || body.checkOut,
    guestCount: body.guest_count || body.guestCount || 1,
    notes: body.notes || "",
  };
}

/**
 * Transform V2 response to V1 format (for backwards compatibility)
 */
function migrateV2ToV1Response(data) {
  return {
    booking_id: data.id,
    guest_name: data.guestName,
    unit_id: data.unitId,
    check_in: data.checkIn,
    check_out: data.checkOut,
  };
}

// =====================================================
// EXPORTS
// =====================================================

module.exports = {
  API_CONFIG,
  versionMiddleware,
  versionedHandler,
  apiResponse,
  apiError,
  bookingHandlers,
  migrateV1ToV2Request,
  migrateV2ToV1Response,
};

// =====================================================
// USAGE EXAMPLE IN index.js
// =====================================================
/*
const { versionMiddleware, versionedHandler, bookingHandlers } = require('./api_versioning');
const express = require('express');
const app = express();

// Apply version middleware to all routes
app.use(versionMiddleware);

// Versioned endpoint
app.post('/api/:version?/bookings', versionedHandler(bookingHandlers));

// Export as Cloud Function
exports.api = functions.https.onRequest(app);
*/