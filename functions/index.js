// =====================================================
// VLS Cloud Functions - PHASE 5 (24 FUNCTIONS)
// Version: 7.0 - Multi-tier Admin + Brand Support
// Date: 2026-01-10
// =====================================================

const {onCall, onRequest} = require('firebase-functions/v2/https');
const {onSchedule} = require('firebase-functions/v2/scheduler');
const {onDocumentCreated, onDocumentUpdated} = require('firebase-functions/v2/firestore');
const {defineSecret} = require('firebase-functions/params');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

const geminiApiKey = defineSecret('GEMINI_API_KEY');
const smtpHost = defineSecret('SMTP_HOST');
const smtpUser = defineSecret('SMTP_USER');
const smtpPass = defineSecret('SMTP_PASS');

admin.initializeApp();

// =====================================================
// HELPER: CHECK SUPER ADMIN (Multi-level)
// Returns: { isAdmin, level, brandId }
// Level 2 = Brand Admin, Level 3 = Master Master
// =====================================================
async function isSuperAdmin(email) {
  if (!email) return { isAdmin: false, level: 0, brandId: null };
  
  const normalizedEmail = email.toLowerCase();
  
  // Master Master always has full access
  if (normalizedEmail === 'vestaluminasystem@gmail.com') {
    return { isAdmin: true, level: 3, brandId: null };
  }
  
  const superAdminDoc = await admin.firestore()
    .collection('super_admins')
    .doc(normalizedEmail)
    .get();
  
  if (superAdminDoc.exists && superAdminDoc.data().active === true) {
    const data = superAdminDoc.data();
    return {
      isAdmin: true,
      level: data.level || 2,
      brandId: data.brandId || null,
    };
  }
  
  return { isAdmin: false, level: 0, brandId: null };
}

// Helper: Check if admin can access specific brand
function canAccessBrand(adminInfo, brandId) {
  if (!adminInfo.isAdmin) return false;
  if (adminInfo.level >= 3) return true; // Master can access all
  return adminInfo.brandId === brandId;
}

// Helper: Check if Master Master
function isMasterMaster(adminInfo) {
  return adminInfo.isAdmin && adminInfo.level >= 3;
}

// Helper: Generate tenant ID (8 chars)
function generateTenantId() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let result = '';
  for (let i = 0; i < 8; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

// Helper: Generate temporary password (12 chars)
function generateTempPassword() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789!@#$';
  let result = '';
  for (let i = 0; i < 12; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

// =====================================================
// HELPER: LOG ADMIN ACTION
// =====================================================
async function logAdminAction(adminEmail, action, details = {}) {
  try {
    await admin.firestore().collection('admin_logs').add({
      adminEmail: adminEmail,
      action: action,
      details: details,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      ip: details.ip || null,
    });
  } catch (error) {
    console.error('Failed to log admin action:', error);
  }
}

// =====================================================
// HELPER: CREATE EMAIL TRANSPORTER
// =====================================================
function createTransporter() {
  return nodemailer.createTransport({
    host: smtpHost.value(),
    port: 587,
    secure: false,
    auth: {
      user: smtpUser.value(),
      pass: smtpPass.value(),
    },
  });
}

// =====================================================
// HELPER: GET OWNER EMAIL SETTINGS
// =====================================================
async function getOwnerEmailSettings(ownerId) {
  const settingsDoc = await admin.firestore()
    .collection('settings')
    .doc(ownerId)
    .get();
  
  if (!settingsDoc.exists) return null;
  
  const data = settingsDoc.data();
  return {
    contactEmail: data.contactEmail,
    ownerName: `${data.ownerFirstName || ''} ${data.ownerLastName || ''}`.trim(),
    companyName: data.companyName || '',
    emailNotifications: data.emailNotifications !== false,
  };
}

// =====================================================
// HELPER: UPDATE BRAND STATISTICS
// =====================================================
async function updateBrandStats(brandId) {
  try {
    const clientsSnap = await admin.firestore()
      .collection('tenant_links')
      .where('brandId', '==', brandId)
      .get();
    
    const clientIds = clientsSnap.docs.map(d => d.id);
    let totalUnits = 0;
    let totalBookings = 0;

    for (const clientId of clientIds) {
      const unitsSnap = await admin.firestore()
        .collection('units')
        .where('ownerId', '==', clientId)
        .get();
      totalUnits += unitsSnap.size;

      const bookingsSnap = await admin.firestore()
        .collection('bookings')
        .where('ownerId', '==', clientId)
        .get();
      totalBookings += bookingsSnap.size;
    }

    await admin.firestore().collection('brands').doc(brandId).update({
      clientCount: clientIds.length,
      totalUnits: totalUnits,
      totalBookings: totalBookings,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`✅ Updated stats for brand: ${brandId}`);
  } catch (error) {
    console.error(`❌ Error updating brand stats: ${error}`);
  }
}

// =====================================================
// HELPER: ENSURE DEFAULT DOCUMENTS EXIST
// Auto-creates brands/vesta-lumina and exit_config/settings
// =====================================================
async function ensureDefaultDocuments() {
  const db = admin.firestore();
  
  // 1. Ensure default brand exists
  const brandDoc = await db.collection('brands').doc('vesta-lumina').get();
  if (!brandDoc.exists) {
    await db.collection('brands').doc('vesta-lumina').set({
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
      logoUrl: '',
      logoLightUrl: '',
      faviconUrl: '',
      splashImageUrl: '',
      clientCount: 0,
      totalUnits: 0,
      totalBookings: 0,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log('✅ Created default brand: vesta-lumina');
  }
  
  // 2. Ensure exit_config exists
  const exitDoc = await db.collection('exit_config').doc('settings').get();
  if (!exitDoc.exists) {
    await db.collection('exit_config').doc('settings').set({
      retailMonthlyBase: 29.99,
      retailPerUnit: 4.99,
      retailSetupFee: 199,
      whiteLabelMonthlyBase: 99.99,
      whiteLabelPerUnit: 2.99,
      whiteLabelSetupFee: 499,
      firebaseMonthlyCost: 50,
      maintenanceHourlyRate: 50,
      maintenanceHoursMonthly: 10,
      multiplierLow: 3,
      multiplierMid: 7,
      multiplierHigh: 12,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log('✅ Created exit_config/settings');
  }
  
  // 3. Ensure master admin exists
  const masterDoc = await db.collection('super_admins').doc('vestaluminasystem@gmail.com').get();
  if (!masterDoc.exists) {
    await db.collection('super_admins').doc('vestaluminasystem@gmail.com').set({
      email: 'vestaluminasystem@gmail.com',
      level: 3,
      brandId: null,
      active: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      createdBy: 'system',
    });
    console.log('✅ Created master admin document');
  } else if (!masterDoc.data().level) {
    // Update existing doc with level if missing
    await db.collection('super_admins').doc('vestaluminasystem@gmail.com').update({
      level: 3,
      brandId: null,
    });
    console.log('✅ Updated master admin with level');
  }
}

// =====================================================
// FUNKCIJA 1: Kreiranje Vlasnika (Super Admin)
// UPDATED: Brand support + Auto-generate tenant ID & password
// =====================================================
exports.createOwner = onCall(
  {region: 'europe-west3'},
  async (request) => {
    const adminEmail = request.auth?.token?.email;
    const adminInfo = await isSuperAdmin(adminEmail);
    
    if (!request.auth || !adminInfo.isAdmin) {
      throw new Error('Unauthorized - Super Admin only');
    }

    // Ensure default documents exist
    await ensureDefaultDocuments();

    const {email, displayName, brandId, type} = request.data;

    if (!email || !displayName) {
      throw new Error('Missing required fields: email, displayName');
    }

    // Determine brand - Level 2 can only create for their brand
    const targetBrandId = brandId || adminInfo.brandId || 'vesta-lumina';
    const targetType = type || 'retail';

    // Check brand access for Level 2 admins
    if (adminInfo.level < 3 && adminInfo.brandId && adminInfo.brandId !== targetBrandId) {
      throw new Error('You can only create owners for your assigned brand');
    }

    // Auto-generate tenant ID and password
    let tenantId = generateTenantId();
    const tempPassword = generateTempPassword();

    try {
      // Verify tenant ID is unique (very unlikely to collide)
      let existingTenant = await admin.firestore()
        .collection('tenant_links')
        .doc(tenantId)
        .get();

      if (existingTenant.exists) {
        // Try once more with new ID
        tenantId = generateTenantId();
        existingTenant = await admin.firestore()
          .collection('tenant_links')
          .doc(tenantId)
          .get();
        if (existingTenant.exists) {
          throw new Error('Failed to generate unique tenant ID, please try again');
        }
      }

      // Create Firebase Auth user
      const userRecord = await admin.auth().createUser({
        email: email,
        password: tempPassword,
        emailVerified: true,
      });

      // Create tenant_links document with brand info
      await admin.firestore().collection('tenant_links').doc(tenantId).set({
        tenantId: tenantId,
        firebaseUid: userRecord.uid,
        email: email,
        displayName: displayName,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: adminEmail,
        linkedAt: null,
        status: 'pending',
        brandId: targetBrandId,
        type: targetType,
      });

      // Create settings document
      await admin.firestore().collection('settings').doc(tenantId).set({
        ownerId: tenantId,
        cleanerPin: '0000',
        hardResetPin: '1234',
        themeColor: 'gold',
        themeMode: 'dark1',
        appLanguage: 'en',
        houseRulesTranslations: {'en': 'No smoking.'},
        welcomeMessageTranslations: {'en': 'Welcome!'},
        cleanerChecklist: ['Check bedsheets', 'Clean bathroom'],
        aiConcierge: '',
        aiHousekeeper: '',
        aiTech: '',
        aiGuide: '',
        checkInTime: '15:00',
        checkOutTime: '10:00',
        emailNotifications: true,
      });

      // Update brand stats
      await updateBrandStats(targetBrandId);

      // Log action
      await logAdminAction(adminEmail, 'CREATE_OWNER', {
        tenantId: tenantId,
        ownerEmail: email,
        brandId: targetBrandId,
        type: targetType,
      });

      return {
        success: true,
        tenantId: String(tenantId),
        firebaseUid: String(userRecord.uid),
        email: String(email),
        tempPassword: String(tempPassword),
        brandId: String(targetBrandId),
        message: 'Owner created successfully.',
      };
    } catch (error) {
      console.error('❌ Error creating owner:', error);
      throw new Error(error.message || 'Failed to create owner');
    }
  }
);

// =====================================================
// FUNKCIJA 2: Linkanje Tenant ID
// =====================================================
exports.linkTenantId = onCall(
  {region: 'europe-west3'},
  async (request) => {
    if (!request.auth) {
      throw new Error('Unauthorized - must be logged in');
    }

    const {tenantId} = request.data;
    const firebaseUid = request.auth.uid;
    const userEmail = request.auth.token.email;

    if (!tenantId || !userEmail) {
      throw new Error('Missing tenantId or email');
    }

    try {
      const tenantDoc = await admin.firestore()
        .collection('tenant_links')
        .doc(tenantId)
        .get();

      if (!tenantDoc.exists) {
        throw new Error(`Tenant ID "${tenantId}" not found. Contact admin.`);
      }

      const tenantData = tenantDoc.data();

      if (tenantData.email.toLowerCase() !== userEmail.toLowerCase()) {
        throw new Error('Tenant ID does not match your email');
      }

      if (tenantData.status === 'suspended') {
        throw new Error('Your account has been suspended. Contact admin.');
      }

      await admin.auth().setCustomUserClaims(firebaseUid, {
        ownerId: tenantId,
        role: 'owner',
      });

      await admin.firestore()
        .collection('tenant_links')
        .doc(tenantId)
        .update({
          linkedAt: admin.firestore.FieldValue.serverTimestamp(),
          status: 'active',
        });

      return {
        success: true,
        tenantId: String(tenantId),
        message: 'Account activated successfully!',
      };
    } catch (error) {
      console.error('❌ Error during linking:', error);
      throw new Error(error.message || 'Failed to link tenant ID');
    }
  }
);

// =====================================================
// FUNKCIJA 3: Lista Vlasnika (Super Admin)
// UPDATED: Filter by brand for Level 2
// =====================================================
exports.listOwners = onCall(
  {region: 'europe-west3'},
  async (request) => {
    const adminEmail = request.auth?.token?.email;
    const adminInfo = await isSuperAdmin(adminEmail);
    
    if (!request.auth || !adminInfo.isAdmin) {
      throw new Error('Unauthorized - Super Admin only');
    }

    try {
      let query = admin.firestore().collection('tenant_links');
      
      // Level 2 admins only see their brand's owners
      if (adminInfo.level < 3 && adminInfo.brandId) {
        query = query.where('brandId', '==', adminInfo.brandId);
      }

      const snapshot = await query.get();

      const owners = snapshot.docs.map((doc) => {
        const data = doc.data();
        return {
          tenantId: String(doc.id),
          email: String(data.email || ''),
          displayName: String(data.displayName || ''),
          firebaseUid: String(data.firebaseUid || ''),
          status: String(data.status || 'pending'),
          brandId: String(data.brandId || 'vesta-lumina'),
          type: String(data.type || 'retail'),
          createdAt: data.createdAt?.toDate?.().toISOString() || null,
          createdBy: data.createdBy || null,
          linkedAt: data.linkedAt?.toDate?.().toISOString() || null,
        };
      });

      return {success: true, owners: owners};
    } catch (error) {
      console.error('❌ Error listing owners:', error);
      throw new Error(error.message || 'Failed to list owners');
    }
  }
);

// =====================================================
// FUNKCIJA 4: Brisanje Vlasnika
// =====================================================
exports.deleteOwner = onCall(
  {region: 'europe-west3'},
  async (request) => {
    const adminEmail = request.auth?.token?.email;
    const adminInfo = await isSuperAdmin(adminEmail);
    
    if (!request.auth || !adminInfo.isAdmin) {
      throw new Error('Unauthorized - Super Admin only');
    }

    const {tenantId} = request.data;

    if (!tenantId) {
      throw new Error('Missing tenantId');
    }

    try {
      const tenantDoc = await admin.firestore()
        .collection('tenant_links')
        .doc(tenantId)
        .get();

      if (!tenantDoc.exists) {
        throw new Error('Tenant not found');
      }

      const tenantData = tenantDoc.data();
      
      // Level 2 can only delete owners from their brand
      if (adminInfo.level < 3 && adminInfo.brandId !== tenantData.brandId) {
        throw new Error('You can only delete owners from your assigned brand');
      }

      const firebaseUid = tenantData.firebaseUid;
      const ownerEmail = tenantData.email;
      const brandId = tenantData.brandId || 'vesta-lumina';

      if (firebaseUid) {
        await admin.auth().deleteUser(firebaseUid);
      }

      await admin.firestore().collection('tenant_links').doc(tenantId).delete();
      await admin.firestore().collection('settings').doc(tenantId).delete();

      // Update brand stats
      await updateBrandStats(brandId);

      await logAdminAction(adminEmail, 'DELETE_OWNER', {
        tenantId: tenantId,
        ownerEmail: ownerEmail,
        brandId: brandId,
      });

      return {
        success: true,
        message: 'Owner deleted successfully',
        tenantId: String(tenantId),
      };
    } catch (error) {
      console.error('❌ Error deleting owner:', error);
      throw new Error(error.message || 'Failed to delete owner');
    }
  }
);

// =====================================================
// FUNKCIJA 5: Reset Lozinke
// UPDATED: Returns generated password
// =====================================================
exports.resetOwnerPassword = onCall(
  {region: 'europe-west3'},
  async (request) => {
    const adminEmail = request.auth?.token?.email;
    const adminInfo = await isSuperAdmin(adminEmail);
    
    if (!request.auth || !adminInfo.isAdmin) {
      throw new Error('Unauthorized - Super Admin only');
    }

    const {tenantId} = request.data;

    if (!tenantId) {
      throw new Error('Tenant ID is required');
    }

    try {
      const tenantDoc = await admin.firestore()
        .collection('tenant_links')
        .doc(tenantId)
        .get();

      if (!tenantDoc.exists) {
        throw new Error('Tenant not found');
      }

      const tenantData = tenantDoc.data();
      
      // Level 2 can only reset for their brand
      if (adminInfo.level < 3 && adminInfo.brandId !== tenantData.brandId) {
        throw new Error('You can only reset passwords for owners in your brand');
      }

      const firebaseUid = tenantData.firebaseUid;
      const newPassword = generateTempPassword();

      await admin.auth().updateUser(firebaseUid, {password: newPassword});

      await logAdminAction(adminEmail, 'RESET_PASSWORD', {
        tenantId: tenantId,
      });

      return {
        success: true,
        message: 'Password reset successfully',
        tenantId: String(tenantId),
        newPassword: String(newPassword),
      };
    } catch (error) {
      console.error('❌ Error resetting password:', error);
      throw new Error(error.message || 'Failed to reset password');
    }
  }
);

// =====================================================
// FUNKCIJA 6: Suspend/Unsuspend Vlasnika
// =====================================================
exports.toggleOwnerStatus = onCall(
  {region: 'europe-west3'},
  async (request) => {
    const adminEmail = request.auth?.token?.email;
    const adminInfo = await isSuperAdmin(adminEmail);
    
    if (!request.auth || !adminInfo.isAdmin) {
      throw new Error('Unauthorized - Super Admin only');
    }

    const {tenantId, newStatus} = request.data;
    const status = newStatus || request.data.status;

    if (!tenantId || !['active', 'suspended'].includes(status)) {
      throw new Error('Invalid parameters');
    }

    try {
      const tenantDoc = await admin.firestore()
        .collection('tenant_links')
        .doc(tenantId)
        .get();

      if (!tenantDoc.exists) {
        throw new Error('Tenant not found');
      }

      const tenantData = tenantDoc.data();
      
      // Level 2 can only toggle for their brand
      if (adminInfo.level < 3 && adminInfo.brandId !== tenantData.brandId) {
        throw new Error('You can only manage owners in your brand');
      }

      await admin.firestore().collection('tenant_links').doc(tenantId).update({status});

      const firebaseUid = tenantData.firebaseUid;

      if (firebaseUid) {
        await admin.auth().updateUser(firebaseUid, {
          disabled: status === 'suspended',
        });
      }

      await logAdminAction(adminEmail, 'TOGGLE_STATUS', {
        tenantId: tenantId,
        newStatus: status,
      });

      return {
        success: true,
        message: `Owner ${status === 'active' ? 'activated' : 'suspended'}`,
        tenantId: String(tenantId),
        status: String(status),
      };
    } catch (error) {
      console.error('❌ Error toggling status:', error);
      throw new Error(error.message || 'Failed to toggle status');
    }
  }
);

// =====================================================
// FUNKCIJA 7: AI PRIJEVOD - House Rules
// =====================================================
exports.translateHouseRules = onCall(
  {
    region: 'europe-west3',
    secrets: [geminiApiKey],
  },
  async (request) => {
    if (!request.auth) {
      throw new Error('Unauthorized - must be logged in');
    }

    const {text, sourceLang, targetLangs} = request.data;

    if (!text || !sourceLang || !targetLangs || !Array.isArray(targetLangs)) {
      throw new Error('Invalid parameters');
    }

    try {
      const {GoogleGenerativeAI} = require('@google/generative-ai');
      const genAI = new GoogleGenerativeAI(geminiApiKey.value());
      const model = genAI.getGenerativeModel({model: 'gemini-2.0-flash'});

      const translations = {};

      for (const targetLang of targetLangs) {
        const prompt = `Translate from ${sourceLang} to ${targetLang}. Preserve formatting. Output only the translation:\n\n${text}`;

        const result = await model.generateContent(prompt);
        translations[targetLang] = result.response.text().trim();
      }

      return {success: true, translations};
    } catch (error) {
      console.error('❌ Translation error:', error);
      throw new Error(error.message || 'Translation failed');
    }
  }
);

// =====================================================
// FUNKCIJA 8: Registracija Tableta
// =====================================================
exports.registerTablet = onCall(
  {region: 'europe-west3'},
  async (request) => {
    const {tenantId, unitId} = request.data;

    if (!tenantId || !unitId) {
      throw new Error('Missing required fields: tenantId, unitId');
    }

    try {
      const unitDoc = await admin.firestore().collection('units').doc(unitId).get();

      if (!unitDoc.exists || unitDoc.data().ownerId !== tenantId) {
        throw new Error('Unit not found or does not belong to tenant');
      }

      const tenantDoc = await admin.firestore()
        .collection('tenant_links')
        .doc(tenantId)
        .get();

      if (!tenantDoc.exists || tenantDoc.data().status === 'suspended') {
        throw new Error('Tenant not found or suspended');
      }

      const existingTablets = await admin.firestore()
        .collection('tablets')
        .where('unitId', '==', unitId)
        .where('status', '==', 'active')
        .get();

      if (!existingTablets.empty) {
        const batch = admin.firestore().batch();
        existingTablets.docs.forEach(doc => {
          batch.update(doc.ref, {status: 'replaced', replacedAt: admin.firestore.FieldValue.serverTimestamp()});
        });
        await batch.commit();
      }

      const userRecord = await admin.auth().createUser({
        displayName: `Tablet_${unitId}_${Date.now()}`,
      });

      await admin.auth().setCustomUserClaims(userRecord.uid, {
        ownerId: tenantId,
        unitId: unitId,
        role: 'tablet',
      });

      const tabletRef = admin.firestore().collection('tablets').doc();
      
      await tabletRef.set({
        tabletId: tabletRef.id,
        firebaseUid: userRecord.uid,
        ownerId: tenantId,
        unitId: unitId,
        unitName: unitDoc.data().name || 'Unknown',
        ownerName: tenantDoc.data().displayName || tenantId,
        status: 'active',
        registeredAt: admin.firestore.FieldValue.serverTimestamp(),
        lastActiveAt: admin.firestore.FieldValue.serverTimestamp(),
        appVersion: '1.0.0',
        pendingUpdate: null,
      });

      const customToken = await admin.auth().createCustomToken(userRecord.uid, {
        ownerId: tenantId,
        unitId: unitId,
        role: 'tablet',
      });

      return {
        success: true,
        tabletId: tabletRef.id,
        firebaseUid: userRecord.uid,
        customToken: customToken,
        message: 'Tablet registered successfully!',
      };
    } catch (error) {
      console.error('❌ Error registering tablet:', error);
      throw new Error(error.message || 'Failed to register tablet');
    }
  }
);

// =====================================================
// FUNKCIJA 9: Heartbeat Tableta
// =====================================================
exports.tabletHeartbeat = onCall(
  {region: 'europe-west3'},
  async (request) => {
    if (!request.auth || request.auth.token.role !== 'tablet') {
      throw new Error('Unauthorized');
    }

    const {unitId} = request.auth.token;
    const {appVersion, batteryLevel, isCharging, updateStatus, updateError} = request.data;

    try {
      const tabletsSnapshot = await admin.firestore()
        .collection('tablets')
        .where('unitId', '==', unitId)
        .where('status', '==', 'active')
        .limit(1)
        .get();

      if (!tabletsSnapshot.empty) {
        const tabletRef = tabletsSnapshot.docs[0].ref;
        const tabletData = tabletsSnapshot.docs[0].data();
        
        const updateData = {
          lastActiveAt: admin.firestore.FieldValue.serverTimestamp(),
        };
        
        if (appVersion) updateData.appVersion = appVersion;
        if (batteryLevel !== undefined) updateData.batteryLevel = batteryLevel;
        if (isCharging !== undefined) updateData.isCharging = isCharging;
        if (updateStatus) {
          updateData.updateStatus = updateStatus;
          if (updateStatus === 'installed') updateData.pendingUpdate = null;
          if (updateStatus === 'failed' && updateError) updateData.updateError = updateError;
        }
        
        await tabletRef.update(updateData);

        const pending = tabletData.pendingUpdate;
        return {
          success: true,
          pendingUpdate: pending ? true : false,
          pendingVersion: pending?.version || '',
          pendingApkUrl: pending?.downloadUrl || '',
          forceUpdate: pending?.forceUpdate || false,
        };
      }

      return {success: true};
    } catch (error) {
      return {success: false, error: error.message};
    }
  }
);

// =====================================================
// FUNKCIJA 10: Translate Notification
// =====================================================
exports.translateNotification = onCall(
  {
    region: 'europe-west3',
    secrets: [geminiApiKey],
  },
  async (request) => {
    const adminEmail = request.auth?.token?.email;
    const adminInfo = await isSuperAdmin(adminEmail);
    
    if (!request.auth || !adminInfo.isAdmin) {
      throw new Error('Unauthorized - Super Admin only');
    }

    const {text, sourceLanguage, targetLanguages} = request.data;

    if (!text || !sourceLanguage || !targetLanguages) {
      throw new Error('Missing required fields');
    }

    const translations = {};
    translations[sourceLanguage] = text;

    try {
      const {GoogleGenerativeAI} = require('@google/generative-ai');
      const genAI = new GoogleGenerativeAI(geminiApiKey.value());
      const model = genAI.getGenerativeModel({model: 'gemini-2.0-flash'});

      for (const targetLang of targetLanguages) {
        const prompt = `Translate to ${targetLang}. Return only translation:\n"${text}"`;
        const result = await model.generateContent(prompt);
        translations[targetLang] = result.response.text().trim().replace(/^["']|["']$/g, '');
        await new Promise((resolve) => setTimeout(resolve, 200));
      }

      return {translations};
    } catch (error) {
      console.error('Translation error:', error);
      throw new Error('Translation failed');
    }
  }
);

// =====================================================
// FUNKCIJA 11: ADD SUPER ADMIN (Master Only)
// UPDATED: Multi-level support
// =====================================================
exports.addSuperAdmin = onCall(
  {region: 'europe-west3'},
  async (request) => {
    const adminEmail = request.auth?.token?.email;
    const adminInfo = await isSuperAdmin(adminEmail);

    // Only Master Master can add super admins
    if (!request.auth || !isMasterMaster(adminInfo)) {
      throw new Error('Unauthorized - Master Admin only');
    }

    // Ensure default documents exist
    await ensureDefaultDocuments();

    const {email, level, brandId, displayName} = request.data;

    if (!email) {
      throw new Error('Email is required');
    }

    const normalizedEmail = email.toLowerCase().trim();
    const adminLevel = level || 2;

    // Level 2 requires brandId
    if (adminLevel === 2 && !brandId) {
      throw new Error('Brand ID is required for Level 2 admin');
    }

    // Verify brand exists for Level 2
    if (adminLevel === 2 && brandId) {
      const brandDoc = await admin.firestore()
        .collection('brands')
        .doc(brandId)
        .get();
      
      if (!brandDoc.exists) {
        throw new Error(`Brand "${brandId}" does not exist`);
      }
    }

    try {
      // Check if already exists
      const existingDoc = await admin.firestore()
        .collection('super_admins')
        .doc(normalizedEmail)
        .get();

      if (existingDoc.exists) {
        throw new Error('This email is already a super admin');
      }

      // Create super admin document
      await admin.firestore().collection('super_admins').doc(normalizedEmail).set({
        email: normalizedEmail,
        displayName: displayName || email.split('@')[0],
        level: adminLevel,
        brandId: adminLevel === 2 ? brandId : null,
        active: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: adminEmail,
      });

      await logAdminAction(adminEmail, 'ADD_SUPER_ADMIN', {
        newAdminEmail: normalizedEmail,
        level: adminLevel,
        brandId: brandId || null,
      });

      return {
        success: true,
        email: normalizedEmail,
        level: adminLevel,
        brandId: brandId || null,
        message: `Super Admin (Level ${adminLevel}) added successfully`,
      };
    } catch (error) {
      console.error('❌ Error adding super admin:', error);
      throw new Error(error.message || 'Failed to add super admin');
    }
  }
);

// =====================================================
// FUNKCIJA 12: REMOVE SUPER ADMIN (Master Only)
// =====================================================
exports.removeSuperAdmin = onCall(
  {region: 'europe-west3'},
  async (request) => {
    const adminEmail = request.auth?.token?.email;
    const adminInfo = await isSuperAdmin(adminEmail);

    if (!request.auth || !isMasterMaster(adminInfo)) {
      throw new Error('Unauthorized - Master Admin only');
    }

    const {email} = request.data;

    if (!email) {
      throw new Error('Email is required');
    }

    const normalizedEmail = email.toLowerCase();

    if (normalizedEmail === 'vestaluminasystem@gmail.com') {
      throw new Error('Cannot remove primary admin');
    }

    try {
      await admin.firestore().collection('super_admins').doc(normalizedEmail).delete();

      await logAdminAction(adminEmail, 'REMOVE_SUPER_ADMIN', {
        removedAdminEmail: normalizedEmail,
      });

      return {
        success: true,
        message: `Super Admin ${normalizedEmail} removed successfully`,
      };
    } catch (error) {
      console.error('❌ Error removing super admin:', error);
      throw new Error(error.message || 'Failed to remove super admin');
    }
  }
);

// =====================================================
// FUNKCIJA 13: LIST SUPER ADMINS
// =====================================================
exports.listSuperAdmins = onCall(
  {region: 'europe-west3'},
  async (request) => {
    const adminEmail = request.auth?.token?.email;
    const adminInfo = await isSuperAdmin(adminEmail);
    
    if (!request.auth || !adminInfo.isAdmin) {
      throw new Error('Unauthorized - Super Admin only');
    }

    try {
      const snapshot = await admin.firestore().collection('super_admins').get();

      const admins = snapshot.docs.map((doc) => {
        const data = doc.data();
        return {
          email: String(doc.id),
          displayName: String(data.displayName || ''),
          level: data.level || 2,
          brandId: data.brandId || null,
          active: Boolean(data.active),
          createdAt: data.createdAt?.toDate?.().toISOString() || data.addedAt?.toDate?.().toISOString() || null,
          createdBy: data.createdBy || data.addedBy || null,
        };
      });

      // Ensure primary admin is in list
      const hasPrimary = admins.some(a => a.email === 'vestaluminasystem@gmail.com');
      if (!hasPrimary) {
        admins.unshift({
          email: 'vestaluminasystem@gmail.com',
          displayName: 'Master Admin',
          level: 3,
          brandId: null,
          active: true,
          createdAt: null,
          createdBy: 'system',
        });
      }

      return {success: true, admins: admins};
    } catch (error) {
      console.error('❌ Error listing super admins:', error);
      throw new Error(error.message || 'Failed to list super admins');
    }
  }
);

// =====================================================
// FUNKCIJA 14: SCHEDULED BACKUP
// =====================================================
exports.scheduledBackup = onSchedule(
  {
    schedule: '0 3 * * *',
    region: 'europe-west3',
    timeZone: 'Europe/Zagreb',
  },
  async (event) => {
    console.log('🔵 Starting scheduled backup...');
    
    const timestamp = new Date().toISOString().split('T')[0];
    const backupId = `backup_${timestamp}`;
    
    try {
      const collections = [
        'tenant_links',
        'settings',
        'units',
        'bookings',
        'tablets',
        'super_admins',
        'brands',
        'exit_config',
      ];

      const backupData = {};
      let totalDocs = 0;

      for (const collectionName of collections) {
        const snapshot = await admin.firestore().collection(collectionName).get();
        backupData[collectionName] = {};
        
        snapshot.docs.forEach(doc => {
          backupData[collectionName][doc.id] = doc.data();
          totalDocs++;
        });
        
        console.log(`✅ Backed up ${snapshot.size} docs from ${collectionName}`);
      }

      await admin.firestore().collection('backups').doc(backupId).set({
        backupId: backupId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        collections: collections,
        totalDocuments: totalDocs,
        status: 'completed',
        sizeEstimate: JSON.stringify(backupData).length,
      });

      if (JSON.stringify(backupData).length < 1000000) {
        await admin.firestore().collection('backups').doc(backupId).update({
          data: backupData,
        });
      }

      console.log(`✅ Backup completed: ${backupId}, ${totalDocs} documents`);
      
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
      
      const oldBackups = await admin.firestore()
        .collection('backups')
        .where('timestamp', '<', thirtyDaysAgo)
        .get();
      
      if (!oldBackups.empty) {
        const batch = admin.firestore().batch();
        oldBackups.docs.forEach(doc => batch.delete(doc.ref));
        await batch.commit();
        console.log(`🧹 Cleaned up ${oldBackups.size} old backups`);
      }

      return null;
    } catch (error) {
      console.error('❌ Backup failed:', error);
      
      await admin.firestore().collection('backups').doc(backupId).set({
        backupId: backupId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        status: 'failed',
        error: error.message,
      });

      return null;
    }
  }
);

// =====================================================
// FUNKCIJA 15: MANUAL BACKUP
// =====================================================
exports.manualBackup = onCall(
  {region: 'europe-west3'},
  async (request) => {
    const adminEmail = request.auth?.token?.email;
    const adminInfo = await isSuperAdmin(adminEmail);
    
    if (!request.auth || !adminInfo.isAdmin) {
      throw new Error('Unauthorized - Super Admin only');
    }

    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const backupId = `manual_${timestamp}`;
    
    try {
      const collections = [
        'tenant_links',
        'settings',
        'units',
        'bookings',
        'tablets',
        'super_admins',
        'brands',
        'exit_config',
      ];

      const backupData = {};
      let totalDocs = 0;

      for (const collectionName of collections) {
        const snapshot = await admin.firestore().collection(collectionName).get();
        backupData[collectionName] = {};
        
        snapshot.docs.forEach(doc => {
          backupData[collectionName][doc.id] = doc.data();
          totalDocs++;
        });
      }

      await admin.firestore().collection('backups').doc(backupId).set({
        backupId: backupId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        triggeredBy: adminEmail,
        collections: collections,
        totalDocuments: totalDocs,
        status: 'completed',
        type: 'manual',
      });

      if (JSON.stringify(backupData).length < 1000000) {
        await admin.firestore().collection('backups').doc(backupId).update({
          data: backupData,
        });
      }

      await logAdminAction(adminEmail, 'MANUAL_BACKUP', {
        backupId: backupId,
        totalDocuments: totalDocs,
      });

      return {
        success: true,
        backupId: backupId,
        totalDocuments: totalDocs,
        message: 'Backup completed successfully',
      };
    } catch (error) {
      console.error('❌ Manual backup failed:', error);
      throw new Error(error.message || 'Backup failed');
    }
  }
);

// =====================================================
// FUNKCIJA 16: GET ADMIN LOGS
// =====================================================
exports.getAdminLogs = onCall(
  {region: 'europe-west3'},
  async (request) => {
    const adminEmail = request.auth?.token?.email;
    const adminInfo = await isSuperAdmin(adminEmail);
    
    if (!request.auth || !adminInfo.isAdmin) {
      throw new Error('Unauthorized - Super Admin only');
    }

    const {limit = 100} = request.data;

    try {
      const snapshot = await admin.firestore()
        .collection('admin_logs')
        .orderBy('timestamp', 'desc')
        .limit(limit)
        .get();

      const logs = snapshot.docs.map((doc) => {
        const data = doc.data();
        return {
          id: doc.id,
          adminEmail: data.adminEmail,
          action: data.action,
          details: data.details,
          timestamp: data.timestamp?.toDate?.().toISOString() || null,
        };
      });

      return {success: true, logs: logs};
    } catch (error) {
      console.error('❌ Error getting admin logs:', error);
      throw new Error(error.message || 'Failed to get admin logs');
    }
  }
);

// =====================================================
// FUNKCIJA 17: SEND EMAIL NOTIFICATION
// =====================================================
exports.sendEmailNotification = onCall(
  {
    region: 'europe-west3',
    secrets: [smtpHost, smtpUser, smtpPass],
  },
  async (request) => {
    if (!request.auth) {
      throw new Error('Unauthorized');
    }

    const {to, subject, html, text} = request.data;

    if (!to || !subject || (!html && !text)) {
      throw new Error('Missing required fields: to, subject, and html or text');
    }

    try {
      const transporter = createTransporter();

      const mailOptions = {
        from: `"VLS Admin" <${smtpUser.value()}>`,
        to: to,
        subject: subject,
        text: text,
        html: html,
      };

      await transporter.sendMail(mailOptions);

      return {success: true, message: 'Email sent successfully'};
    } catch (error) {
      console.error('❌ Email send error:', error);
      throw new Error(error.message || 'Failed to send email');
    }
  }
);

// =====================================================
// FUNKCIJA 18: BOOKING CONFIRMATION EMAIL (Trigger)
// =====================================================
exports.onBookingCreated = onDocumentCreated(
  {
    document: 'bookings/{bookingId}',
    region: 'europe-west3',
    secrets: [smtpHost, smtpUser, smtpPass],
  },
  async (event) => {
    const booking = event.data.data();
    const bookingId = event.params.bookingId;

    if (!booking.guestEmail) {
      console.log('No guest email, skipping notification');
      return;
    }

    try {
      const ownerSettings = await getOwnerEmailSettings(booking.ownerId);
      
      if (!ownerSettings || !ownerSettings.emailNotifications) {
        console.log('Email notifications disabled');
        return;
      }

      const checkIn = booking.checkIn.toDate();
      const checkOut = booking.checkOut.toDate();
      
      const html = `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background: linear-gradient(135deg, #D4AF37, #B8860B); padding: 20px; text-align: center;">
            <h1 style="color: white; margin: 0;">Booking Confirmed</h1>
          </div>
          <div style="padding: 30px; background: #f9f9f9;">
            <p>Dear ${booking.guestName},</p>
            <p>Your booking has been confirmed.</p>
            <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0;">
              <p><strong>Property:</strong> ${booking.unitName}</p>
              <p><strong>Check-in:</strong> ${checkIn.toLocaleDateString('en-GB')}</p>
              <p><strong>Check-out:</strong> ${checkOut.toLocaleDateString('en-GB')}</p>
              <p><strong>Guests:</strong> ${booking.guestCount}</p>
            </div>
            <p>Best regards,<br>${ownerSettings.ownerName || 'The Host'}</p>
          </div>
        </div>
      `;

      const transporter = createTransporter();
      
      await transporter.sendMail({
        from: `"${ownerSettings.companyName || ownerSettings.ownerName}" <${smtpUser.value()}>`,
        to: booking.guestEmail,
        subject: `Booking Confirmed - ${booking.unitName}`,
        html: html,
      });

      console.log(`✅ Confirmation email sent for booking ${bookingId}`);
      
      await admin.firestore().collection('email_logs').add({
        bookingId: bookingId,
        to: booking.guestEmail,
        type: 'booking_confirmation',
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        status: 'sent',
      });

    } catch (error) {
      console.error('❌ Failed to send confirmation email:', error);
    }
  }
);

// =====================================================
// FUNKCIJA 19: CHECK-IN REMINDER EMAIL (Scheduled)
// =====================================================
exports.sendCheckInReminders = onSchedule(
  {
    schedule: '0 9 * * *',
    region: 'europe-west3',
    timeZone: 'Europe/Zagreb',
    secrets: [smtpHost, smtpUser, smtpPass],
  },
  async (event) => {
    console.log('🔵 Sending check-in reminders...');

    try {
      const tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate() + 1);
      tomorrow.setHours(0, 0, 0, 0);
      
      const dayAfter = new Date(tomorrow);
      dayAfter.setDate(dayAfter.getDate() + 1);

      const bookingsSnapshot = await admin.firestore()
        .collection('bookings')
        .where('checkIn', '>=', tomorrow)
        .where('checkIn', '<', dayAfter)
        .get();

      let sentCount = 0;
      
      for (const doc of bookingsSnapshot.docs) {
        const booking = doc.data();
        if (!booking.guestEmail) continue;

        try {
          const ownerSettings = await getOwnerEmailSettings(booking.ownerId);
          if (!ownerSettings || !ownerSettings.emailNotifications) continue;

          const transporter = createTransporter();
          
          await transporter.sendMail({
            from: `"${ownerSettings.companyName || 'VLS'}" <${smtpUser.value()}>`,
            to: booking.guestEmail,
            subject: `Check-in Reminder - ${booking.unitName}`,
            html: `<p>Your check-in at ${booking.unitName} is tomorrow!</p>`,
          });

          sentCount++;
        } catch (error) {
          console.error(`Failed to send reminder for ${doc.id}:`, error);
        }
      }

      console.log(`✅ Sent ${sentCount} check-in reminders`);
      return null;
    } catch (error) {
      console.error('❌ Check-in reminders failed:', error);
      return null;
    }
  }
);

// =====================================================
// FUNKCIJA 20: UPDATE EMAIL SETTINGS
// =====================================================
exports.updateEmailSettings = onCall(
  {region: 'europe-west3'},
  async (request) => {
    if (!request.auth) {
      throw new Error('Unauthorized');
    }

    const ownerId = request.auth.token.ownerId;
    
    if (!ownerId) {
      throw new Error('Owner ID not found');
    }

    const {emailNotifications, reminderDaysBefore} = request.data;

    try {
      const updateData = {};
      
      if (typeof emailNotifications === 'boolean') {
        updateData.emailNotifications = emailNotifications;
      }
      
      if (typeof reminderDaysBefore === 'number') {
        updateData.reminderDaysBefore = reminderDaysBefore;
      }

      await admin.firestore()
        .collection('settings')
        .doc(ownerId)
        .update(updateData);

      return {success: true, message: 'Email settings updated'};
    } catch (error) {
      console.error('❌ Error updating email settings:', error);
      throw new Error(error.message || 'Failed to update settings');
    }
  }
);

// =====================================================
// FUNKCIJA 21: DISTRIBUTE APK UPDATE (Master Only)
// =====================================================
exports.distributeApkUpdate = onCall(
  {region: 'europe-west3'},
  async (request) => {
    const adminEmail = request.auth?.token?.email;
    const adminInfo = await isSuperAdmin(adminEmail);

    if (!request.auth || !isMasterMaster(adminInfo)) {
      throw new Error('Unauthorized - Master Admin only');
    }

    const {versionId} = request.data;

    if (!versionId) {
      throw new Error('Version ID is required');
    }

    try {
      const versionDoc = await admin.firestore()
        .collection('apk_versions')
        .doc(versionId)
        .get();

      if (!versionDoc.exists) {
        throw new Error('APK version not found');
      }

      const versionData = versionDoc.data();

      const tabletsSnap = await admin.firestore()
        .collection('tablets')
        .where('status', '==', 'active')
        .get();

      const tabletCount = tabletsSnap.size;

      const batch = admin.firestore().batch();
      
      tabletsSnap.docs.forEach((doc) => {
        batch.update(doc.ref, {
          pendingUpdate: {
            version: versionData.version,
            versionCode: versionData.versionCode,
            downloadUrl: versionData.downloadUrl,
            releaseNotes: versionData.releaseNotes || '',
            notifiedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
        });
      });

      await batch.commit();

      await admin.firestore().collection('apk_versions').doc(versionId).update({
        distributedAt: admin.firestore.FieldValue.serverTimestamp(),
        distributedCount: tabletCount,
      });

      await logAdminAction(adminEmail, 'DISTRIBUTE_APK', {
        version: versionData.version,
        tabletCount: tabletCount,
      });

      return {
        success: true,
        version: versionData.version,
        tabletCount: tabletCount,
        message: `APK distributed to ${tabletCount} tablets`,
      };
    } catch (error) {
      console.error('❌ Error distributing APK:', error);
      throw new Error(error.message || 'Failed to distribute APK');
    }
  }
);

// =====================================================
// FUNKCIJA 22: SEND SYSTEM NOTIFICATION
// =====================================================
exports.sendSystemNotification = onCall(
  {region: 'europe-west3'},
  async (request) => {
    const adminEmail = request.auth?.token?.email;
    const adminInfo = await isSuperAdmin(adminEmail);

    if (!request.auth || !adminInfo.isAdmin) {
      throw new Error('Unauthorized - Super Admin only');
    }

    const {title, message, type, sendToAll, recipients, brandId} = request.data;

    if (!title || !message) {
      throw new Error('Title and message are required');
    }

    try {
      let targetRecipients = [];

      if (sendToAll) {
        let query = admin.firestore().collection('tenant_links');
        
        if (adminInfo.level < 3 && adminInfo.brandId) {
          query = query.where('brandId', '==', adminInfo.brandId);
        } else if (brandId) {
          query = query.where('brandId', '==', brandId);
        }

        const ownersSnap = await query.get();
        targetRecipients = ownersSnap.docs.map(d => d.id);
      } else {
        targetRecipients = recipients || [];
      }

      const notificationRef = await admin.firestore().collection('system_notifications').add({
        title: title,
        message: message,
        type: type || 'info',
        recipientCount: targetRecipients.length,
        recipients: targetRecipients,
        brandId: brandId || adminInfo.brandId || null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: adminEmail,
      });

      await logAdminAction(adminEmail, 'SEND_NOTIFICATION', {
        title: title,
        recipientCount: targetRecipients.length,
      });

      return {
        success: true,
        notificationId: notificationRef.id,
        recipientCount: targetRecipients.length,
        message: `Notification sent to ${targetRecipients.length} recipients`,
      };
    } catch (error) {
      console.error('❌ Error sending notification:', error);
      throw new Error(error.message || 'Failed to send notification');
    }
  }
);

// =====================================================
// FUNKCIJA 23: GET BRAND INFO (For Tablet App)
// =====================================================
exports.getBrandInfo = onCall(
  {region: 'europe-west3'},
  async (request) => {
    const {ownerId} = request.data;

    if (!ownerId) {
      throw new Error('Owner ID is required');
    }

    await ensureDefaultDocuments();

    try {
      const tenantDoc = await admin.firestore()
        .collection('tenant_links')
        .doc(ownerId)
        .get();

      let brandId = 'vesta-lumina';
      
      if (tenantDoc.exists) {
        brandId = tenantDoc.data().brandId || 'vesta-lumina';
      }

      const brandDoc = await admin.firestore()
        .collection('brands')
        .doc(brandId)
        .get();

      if (!brandDoc.exists) {
        return getDefaultBrandResponse();
      }

      const brand = brandDoc.data();

      return {
        success: true,
        brand: {
          id: brand.id || brandId,
          name: brand.name || 'Vesta Lumina',
          appName: brand.appName || brand.name || 'Vesta Lumina',
          logoUrl: brand.logoUrl || '',
          logoLightUrl: brand.logoLightUrl || '',
          splashImageUrl: brand.splashImageUrl || '',
          primaryColor: brand.primaryColor || '#D4AF37',
          secondaryColor: brand.secondaryColor || '#1E1E1E',
          accentColor: brand.accentColor || '#FFFFFF',
          tagline: brand.tagline || 'Smart Property Management',
          supportEmail: brand.supportEmail || 'support@vestalumina.com',
        },
      };
    } catch (error) {
      console.error('❌ Error getting brand info:', error);
      return getDefaultBrandResponse();
    }
  }
);

function getDefaultBrandResponse() {
  return {
    success: true,
    brand: {
      id: 'vesta-lumina',
      name: 'Vesta Lumina',
      appName: 'Vesta Lumina',
      logoUrl: '',
      logoLightUrl: '',
      splashImageUrl: '',
      primaryColor: '#D4AF37',
      secondaryColor: '#1E1E1E',
      accentColor: '#FFFFFF',
      tagline: 'Smart Property Management',
      supportEmail: 'support@vestalumina.com',
    },
  };
}

// =====================================================
// FUNKCIJA 24: INITIALIZE SYSTEM (One-time setup)
// =====================================================
exports.initializeSystem = onCall(
  {region: 'europe-west3'},
  async (request) => {
    const adminEmail = request.auth?.token?.email;
    
    if (!adminEmail || adminEmail.toLowerCase() !== 'vestaluminasystem@gmail.com') {
      throw new Error('Unauthorized - Master Admin only');
    }

    try {
      await ensureDefaultDocuments();

      const tenantsSnap = await admin.firestore().collection('tenant_links').get();
      
      const batch = admin.firestore().batch();
      let updatedCount = 0;
      
      tenantsSnap.docs.forEach(doc => {
        const data = doc.data();
        if (!data.brandId) {
          batch.update(doc.ref, {
            brandId: 'vesta-lumina',
            type: 'retail',
          });
          updatedCount++;
        }
      });
      
      if (updatedCount > 0) {
        await batch.commit();
      }

      await updateBrandStats('vesta-lumina');

      await logAdminAction(adminEmail, 'INITIALIZE_SYSTEM', {
        tenantsUpdated: updatedCount,
      });

      return {
        success: true,
        message: 'System initialized successfully',
        tenantsUpdated: updatedCount,
      };
    } catch (error) {
      console.error('❌ Error initializing system:', error);
      throw new Error(error.message || 'Failed to initialize system');
    }
  }
);