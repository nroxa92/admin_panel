// =====================================================
// VLS Cloud Functions - PHASE 4 COMPLETE (20 FUNCTIONS)
// Version: 6.0 - Email Notifications + Calendar + Revenue
// Date: 2026-01-09
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
// HELPER: CHECK SUPER ADMIN (Firestore-based)
// =====================================================
async function isSuperAdmin(email) {
  if (!email) return false;
  
  const normalizedEmail = email.toLowerCase();
  
  const superAdminDoc = await admin.firestore()
    .collection('super_admins')
    .doc(normalizedEmail)
    .get();
  
  if (superAdminDoc.exists && superAdminDoc.data().active === true) {
    return true;
  }
  
  if (normalizedEmail === 'vestaluminasystem@gmail.com') {
    return true;
  }
  
  return false;
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
// FUNKCIJA 1: Kreiranje Vlasnika (Super Admin)
// =====================================================
exports.createOwner = onCall(
  {region: 'europe-west3'},
  async (request) => {
    const adminEmail = request.auth?.token?.email;
    
    if (!request.auth || !(await isSuperAdmin(adminEmail))) {
      throw new Error('Unauthorized - Super Admin only');
    }

    const {email, password, tenantId, displayName} = request.data;

    if (!email || !password || !tenantId) {
      throw new Error('Missing required fields: email, password, tenantId');
    }

    if (!/^[A-Z0-9]{6,12}$/.test(tenantId)) {
      throw new Error('Invalid tenant ID format (use 6-12 uppercase letters/numbers)');
    }

    try {
      const existingTenant = await admin.firestore()
        .collection('tenant_links')
        .doc(tenantId)
        .get();

      if (existingTenant.exists) {
        throw new Error(`Tenant ID "${tenantId}" already exists`);
      }

      const userRecord = await admin.auth().createUser({
        email: email,
        password: password,
        emailVerified: true,
      });

      await admin.firestore().collection('tenant_links').doc(tenantId).set({
        tenantId: tenantId,
        firebaseUid: userRecord.uid,
        email: email,
        displayName: displayName || email.split('@')[0],
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: adminEmail,
        linkedAt: null,
        status: 'pending',
      });

      await admin.firestore().collection('settings').doc(tenantId).set({
        ownerId: tenantId,
        cleanerPin: '0000',
        hardResetPin: '1234',
        themeColor: 'gold',
        themeMode: 'dark1',
        appLanguage: 'en',
        houseRulesTranslations: {'en': 'No smoking.'},
        welcomeMessageTranslations: {'en': 'Welcome to our Villa!'},
        cleanerChecklist: ['Check bedsheets', 'Clean bathroom'],
        aiConcierge: '',
        aiHousekeeper: '',
        aiTech: '',
        aiGuide: '',
        checkInTime: '15:00',
        checkOutTime: '10:00',
        emailNotifications: true,
      });

      await logAdminAction(adminEmail, 'CREATE_OWNER', {
        tenantId: tenantId,
        ownerEmail: email,
      });

      return {
        success: true,
        tenantId: String(tenantId),
        firebaseUid: String(userRecord.uid),
        email: String(email),
        message: 'Owner created. They must login and enter tenant ID to activate.',
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
// =====================================================
exports.listOwners = onCall(
  {region: 'europe-west3'},
  async (request) => {
    const adminEmail = request.auth?.token?.email;
    
    if (!request.auth || !(await isSuperAdmin(adminEmail))) {
      throw new Error('Unauthorized - Super Admin only');
    }

    try {
      const snapshot = await admin.firestore().collection('tenant_links').get();

      const owners = snapshot.docs.map((doc) => {
        const data = doc.data();
        return {
          tenantId: String(doc.id),
          email: String(data.email || ''),
          displayName: String(data.displayName || ''),
          firebaseUid: String(data.firebaseUid || ''),
          status: String(data.status || 'pending'),
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
    
    if (!request.auth || !(await isSuperAdmin(adminEmail))) {
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

      const firebaseUid = tenantDoc.data().firebaseUid;
      const ownerEmail = tenantDoc.data().email;

      if (firebaseUid) {
        await admin.auth().deleteUser(firebaseUid);
      }

      await admin.firestore().collection('tenant_links').doc(tenantId).delete();
      await admin.firestore().collection('settings').doc(tenantId).delete();

      await logAdminAction(adminEmail, 'DELETE_OWNER', {
        tenantId: tenantId,
        ownerEmail: ownerEmail,
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
// =====================================================
exports.resetOwnerPassword = onCall(
  {region: 'europe-west3'},
  async (request) => {
    const adminEmail = request.auth?.token?.email;
    
    if (!request.auth || !(await isSuperAdmin(adminEmail))) {
      throw new Error('Unauthorized - Super Admin only');
    }

    const {tenantId, newPassword} = request.data;

    if (!tenantId || !newPassword || newPassword.length < 6) {
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

      const firebaseUid = tenantDoc.data().firebaseUid;

      await admin.auth().updateUser(firebaseUid, {password: newPassword});

      await logAdminAction(adminEmail, 'RESET_PASSWORD', {
        tenantId: tenantId,
      });

      return {
        success: true,
        message: 'Password reset successfully',
        tenantId: String(tenantId),
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
    
    if (!request.auth || !(await isSuperAdmin(adminEmail))) {
      throw new Error('Unauthorized - Super Admin only');
    }

    const {tenantId, status} = request.data;

    if (!tenantId || !['active', 'suspended'].includes(status)) {
      throw new Error('Invalid parameters');
    }

    try {
      await admin.firestore().collection('tenant_links').doc(tenantId).update({status});

      const tenantDoc = await admin.firestore()
        .collection('tenant_links')
        .doc(tenantId)
        .get();

      const firebaseUid = tenantDoc.data().firebaseUid;

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
        pendingUpdate: false,
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
          if (updateStatus === 'installed') updateData.pendingUpdate = false;
          if (updateStatus === 'failed' && updateError) updateData.updateError = updateError;
        }
        
        await tabletRef.update(updateData);

        return {
          success: true,
          pendingUpdate: tabletData.pendingUpdate || false,
          pendingVersion: tabletData.pendingVersion || '',
          pendingApkUrl: tabletData.pendingApkUrl || '',
          forceUpdate: tabletData.forceUpdate || false,
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
    
    if (!request.auth || !(await isSuperAdmin(adminEmail))) {
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
// FUNKCIJA 11: ADD SUPER ADMIN
// =====================================================
exports.addSuperAdmin = onCall(
  {region: 'europe-west3'},
  async (request) => {
    const adminEmail = request.auth?.token?.email;
    
    if (!adminEmail || adminEmail.toLowerCase() !== 'vestaluminasystem@gmail.com') {
      throw new Error('Unauthorized - Primary Admin only');
    }

    const {email, displayName} = request.data;

    if (!email) {
      throw new Error('Email is required');
    }

    const normalizedEmail = email.toLowerCase();

    try {
      await admin.firestore().collection('super_admins').doc(normalizedEmail).set({
        email: normalizedEmail,
        displayName: displayName || email.split('@')[0],
        active: true,
        addedAt: admin.firestore.FieldValue.serverTimestamp(),
        addedBy: adminEmail,
      });

      await logAdminAction(adminEmail, 'ADD_SUPER_ADMIN', {
        newAdminEmail: normalizedEmail,
      });

      return {
        success: true,
        message: `Super Admin ${normalizedEmail} added successfully`,
      };
    } catch (error) {
      console.error('❌ Error adding super admin:', error);
      throw new Error(error.message || 'Failed to add super admin');
    }
  }
);

// =====================================================
// FUNKCIJA 12: REMOVE SUPER ADMIN
// =====================================================
exports.removeSuperAdmin = onCall(
  {region: 'europe-west3'},
  async (request) => {
    const adminEmail = request.auth?.token?.email;
    
    if (!adminEmail || adminEmail.toLowerCase() !== 'vestaluminasystem@gmail.com') {
      throw new Error('Unauthorized - Primary Admin only');
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
    
    if (!request.auth || !(await isSuperAdmin(adminEmail))) {
      throw new Error('Unauthorized - Super Admin only');
    }

    try {
      const snapshot = await admin.firestore().collection('super_admins').get();

      const admins = snapshot.docs.map((doc) => {
        const data = doc.data();
        return {
          email: String(doc.id),
          displayName: String(data.displayName || ''),
          active: Boolean(data.active),
          addedAt: data.addedAt?.toDate?.().toISOString() || null,
          addedBy: data.addedBy || null,
        };
      });

      const hasPrimary = admins.some(a => a.email === 'vestaluminasystem@gmail.com');
      if (!hasPrimary) {
        admins.unshift({
          email: 'vestaluminasystem@gmail.com',
          displayName: 'Primary Admin',
          active: true,
          addedAt: null,
          addedBy: 'system',
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
    
    if (!request.auth || !(await isSuperAdmin(adminEmail))) {
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
    
    if (!request.auth || !(await isSuperAdmin(adminEmail))) {
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
// FUNKCIJA 17: SEND EMAIL NOTIFICATION (Phase 4)
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
            <p>Your booking has been confirmed. Here are the details:</p>
            
            <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0;">
              <p><strong>Property:</strong> ${booking.unitName}</p>
              <p><strong>Check-in:</strong> ${checkIn.toLocaleDateString('en-GB')} at ${ownerSettings.checkInTime || '15:00'}</p>
              <p><strong>Check-out:</strong> ${checkOut.toLocaleDateString('en-GB')} at ${ownerSettings.checkOutTime || '10:00'}</p>
              <p><strong>Guests:</strong> ${booking.guestCount}</p>
              <p><strong>Booking ID:</strong> ${bookingId}</p>
            </div>
            
            <p>If you have any questions, please contact us.</p>
            <p>Best regards,<br>${ownerSettings.ownerName || 'The Host'}</p>
          </div>
          <div style="padding: 15px; background: #333; color: #999; text-align: center; font-size: 12px;">
            Powered by VLS Admin Panel
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
      
      // Log email sent
      await admin.firestore().collection('email_logs').add({
        bookingId: bookingId,
        to: booking.guestEmail,
        type: 'booking_confirmation',
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        status: 'sent',
      });

    } catch (error) {
      console.error('❌ Failed to send confirmation email:', error);
      
      await admin.firestore().collection('email_logs').add({
        bookingId: bookingId,
        to: booking.guestEmail,
        type: 'booking_confirmation',
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        status: 'failed',
        error: error.message,
      });
    }
  }
);

// =====================================================
// FUNKCIJA 19: CHECK-IN REMINDER EMAIL (Scheduled)
// =====================================================
exports.sendCheckInReminders = onSchedule(
  {
    schedule: '0 9 * * *', // Every day at 9 AM
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

      console.log(`Found ${bookingsSnapshot.size} bookings for tomorrow`);

      let sentCount = 0;
      
      for (const doc of bookingsSnapshot.docs) {
        const booking = doc.data();
        
        if (!booking.guestEmail) continue;

        try {
          const ownerSettings = await getOwnerEmailSettings(booking.ownerId);
          
          if (!ownerSettings || !ownerSettings.emailNotifications) continue;

          const checkIn = booking.checkIn.toDate();
          
          const html = `
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
              <div style="background: linear-gradient(135deg, #4CAF50, #2E7D32); padding: 20px; text-align: center;">
                <h1 style="color: white; margin: 0;">Check-in Tomorrow!</h1>
              </div>
              <div style="padding: 30px; background: #f9f9f9;">
                <p>Dear ${booking.guestName},</p>
                <p>This is a friendly reminder that your check-in at <strong>${booking.unitName}</strong> is tomorrow!</p>
                
                <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0;">
                  <p><strong>Check-in Date:</strong> ${checkIn.toLocaleDateString('en-GB')}</p>
                  <p><strong>Check-in Time:</strong> ${ownerSettings.checkInTime || '15:00'}</p>
                  <p><strong>Property:</strong> ${booking.unitName}</p>
                </div>
                
                <p>We look forward to welcoming you!</p>
                <p>Best regards,<br>${ownerSettings.ownerName || 'The Host'}</p>
              </div>
            </div>
          `;

          const transporter = createTransporter();
          
          await transporter.sendMail({
            from: `"${ownerSettings.companyName || ownerSettings.ownerName}" <${smtpUser.value()}>`,
            to: booking.guestEmail,
            subject: `Check-in Reminder - ${booking.unitName}`,
            html: html,
          });

          sentCount++;
          
          await admin.firestore().collection('email_logs').add({
            bookingId: doc.id,
            to: booking.guestEmail,
            type: 'checkin_reminder',
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            status: 'sent',
          });

        } catch (error) {
          console.error(`Failed to send reminder for booking ${doc.id}:`, error);
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