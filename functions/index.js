// =====================================================
// VLS Cloud Functions - COMPLETE (10 FUNCTIONS)
// Version: 4.0 - Vesta Lumina System
// Super Admin: vestaluminasystem@gmail.com
// Date: 2026-01-09
// =====================================================

const {onCall} = require('firebase-functions/v2/https');
const {defineSecret} = require('firebase-functions/params');
const admin = require('firebase-admin');

// Secret za Gemini API
const geminiApiKey = defineSecret('GEMINI_API_KEY');

// Inicijalizacija Firebase Admin SDK
admin.initializeApp();

// =====================================================
// SUPER ADMIN EMAIL - CENTRALIZED
// =====================================================
const SUPER_ADMIN_EMAIL = 'vestaluminasystem@gmail.com';

// =====================================================
// FUNKCIJA 1: Kreiranje Vlasnika (Super Admin poziva)
// =====================================================
exports.createOwner = onCall(
  {region: 'europe-west3'},
  async (request) => {
    if (!request.auth || request.auth.token.email !== SUPER_ADMIN_EMAIL) {
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
    console.log('🔵 linkTenantId called');

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
    if (!request.auth || request.auth.token.email !== SUPER_ADMIN_EMAIL) {
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
    if (!request.auth || request.auth.token.email !== SUPER_ADMIN_EMAIL) {
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

      if (firebaseUid) {
        await admin.auth().deleteUser(firebaseUid);
      }

      await admin.firestore().collection('tenant_links').doc(tenantId).delete();
      await admin.firestore().collection('settings').doc(tenantId).delete();

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
    if (!request.auth || request.auth.token.email !== SUPER_ADMIN_EMAIL) {
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
    if (!request.auth || request.auth.token.email !== SUPER_ADMIN_EMAIL) {
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
// FUNKCIJA 7: AI PRIJEVOD - GEMINI SDK (House Rules)
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

      // Deactivate existing tablets
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

      // Create tablet auth user
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
// FUNKCIJA 10: Translate Notification (Super Admin)
// =====================================================
exports.translateNotification = onCall(
  {
    region: 'europe-west3',
    secrets: [geminiApiKey],
  },
  async (request) => {
    if (!request.auth || request.auth.token.email !== SUPER_ADMIN_EMAIL) {
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