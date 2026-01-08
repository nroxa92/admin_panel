// =====================================================
// VillaOS Cloud Functions - JAVASCRIPT (NO TYPESCRIPT)
// =====================================================

const {onCall} = require('firebase-functions/v2/https');
const {defineSecret} = require('firebase-functions/params');
const admin = require('firebase-admin');

// Secret za Gemini API
const geminiApiKey = defineSecret('GEMINI_API_KEY');

// Inicijalizacija Firebase Admin SDK
admin.initializeApp();

// =====================================================
// FUNKCIJA 1: Kreiranje Vlasnika (Super Admin poziva)
// =====================================================
exports.createOwner = onCall(
  {region: 'europe-west3'},
  async (request) => {
  // SIGURNOST: Samo Super Admin
  if (!request.auth || request.auth.token.email !== 'nevenroksa@gmail.com') {
    throw new Error('Unauthorized - Super Admin only');
  }

  const {email, password, tenantId, displayName} = request.data;

  // Validacija
  if (!email || !password || !tenantId) {
    throw new Error('Missing required fields: email, password, tenantId');
  }

  // Provjeri format tenant ID (6-12 znakova, A-Z i 0-9)
  if (!/^[A-Z0-9]{6,12}$/.test(tenantId)) {
    throw new Error('Invalid tenant ID format (use 6-12 uppercase letters/numbers)');
  }

  try {
    // 1. Provjeri da tenant ID nije zauzet
    const existingTenant = await admin.firestore()
      .collection('tenant_links')
      .doc(tenantId)
      .get();

    if (existingTenant.exists) {
      throw new Error(`Tenant ID "${tenantId}" already exists`);
    }

    // 2. Kreiraj Firebase Auth user (BEZ claims - čeka linking!)
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      emailVerified: true, // Automatski verified (admin kreirao)
    });

    // 3. Kreiraj tenant_links dokument
    await admin.firestore().collection('tenant_links').doc(tenantId).set({
      tenantId: tenantId,
      firebaseUid: userRecord.uid,
      email: email,
      displayName: displayName || email.split('@')[0],
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      linkedAt: null,
      status: 'pending',
    });

    // 4. Kreiraj settings dokument sa default postavkama
    await admin.firestore().collection('settings').doc(tenantId).set({
      ownerId: tenantId,
      cleanerPin: '0000',
      hardResetPin: '1234',
      themeColor: 'gold',
      themeMode: 'dark1',
      appLanguage: 'en',
      houseRulesTranslations: {'en': 'No smoking.'},
      cleanerChecklist: ['Check bedsheets', 'Clean bathroom'],
      aiConcierge: '',
      aiHousekeeper: '',
      aiTech: '',
      aiGuide: '',
      welcomeMessage: 'Welcome to our Villa!',
      checkInTime: '15:00',
      checkOutTime: '10:00',
      wifiSsid: '',
      wifiPass: '',
    });

    // ✅ Vrati samo primitive types
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
});

// =====================================================
// FUNKCIJA 2: Linkanje Tenant ID
// =====================================================
exports.linkTenantId = onCall(
  {region: 'europe-west3'},
  async (request) => {
  console.log('🔵 linkTenantId called');

  // Auth check
  if (!request.auth) {
    console.error('❌ No auth context');
    throw new Error('Unauthorized - must be logged in');
  }

  const {tenantId} = request.data;
  const firebaseUid = request.auth.uid;
  const userEmail = request.auth.token.email;

  console.log(`📧 Email: ${userEmail}, UID: ${firebaseUid}, TenantID: ${tenantId}`);

  // Validacija
  if (!tenantId) {
    console.error('❌ No tenantId provided');
    throw new Error('Missing tenantId');
  }

  if (!userEmail) {
    console.error('❌ No email in auth token');
    throw new Error('Email not found in auth token');
  }

  try {
    // 1. Provjeri tenant_links
    console.log('🔍 Fetching tenant_links document...');
    const tenantDoc = await admin.firestore()
      .collection('tenant_links')
      .doc(tenantId)
      .get();

    if (!tenantDoc.exists) {
      console.error(`❌ Tenant ID "${tenantId}" does not exist`);
      throw new Error(`Tenant ID "${tenantId}" not found. Contact admin.`);
    }

    const tenantData = tenantDoc.data();
    console.log('📄 Tenant data:', tenantData);

    // 2. Email match check
    const tenantEmail = tenantData.email;
    if (!tenantEmail) {
      console.error('❌ No email in tenant document');
      throw new Error('Tenant document missing email');
    }

    if (tenantEmail.toLowerCase() !== userEmail.toLowerCase()) {
      console.error(`❌ Email mismatch: ${userEmail} vs ${tenantEmail}`);
      throw new Error('Tenant ID does not match your email');
    }

    // 3. Provjeri status
    if (tenantData.status === 'suspended') {
      console.error('❌ Account suspended');
      throw new Error('Your account has been suspended. Contact admin.');
    }

    // 4. Set custom claims
    console.log('🔐 Setting custom claims...');
    await admin.auth().setCustomUserClaims(firebaseUid, {
      ownerId: tenantId,  // ✅ FIXED: ownerId umjesto tenantId
      role: 'owner',
    });

    // 5. Update tenant_links
    console.log('💾 Updating tenant_links...');
    await admin.firestore()
      .collection('tenant_links')
      .doc(tenantId)
      .update({
        linkedAt: admin.firestore.FieldValue.serverTimestamp(),
        status: 'active',
      });

    console.log('✅ Linking successful!');

    return {
      success: true,
      tenantId: String(tenantId),
      message: 'Account activated successfully!',
    };
  } catch (error) {
    console.error('❌ Error during linking:', error);
    throw new Error(error.message || 'Failed to link tenant ID');
  }
});

// =====================================================
// FUNKCIJA 3: Lista Vlasnika (Super Admin)
// =====================================================
exports.listOwners = onCall(
  {region: 'europe-west3'},
  async (request) => {
  // Auth check
  if (!request.auth || request.auth.token.email !== 'nevenroksa@gmail.com') {
    throw new Error('Unauthorized - Super Admin only');
  }

  try {
    const snapshot = await admin.firestore().collection('tenant_links').get();

    const owners = snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        tenantId: String(data.tenantId || ''),
        email: String(data.email || ''),
        displayName: String(data.displayName || ''),
        firebaseUid: String(data.firebaseUid || ''),
        status: String(data.status || 'pending'),
        createdAt: data.createdAt && data.createdAt.toDate ? data.createdAt.toDate().toISOString() : null,
        linkedAt: data.linkedAt && data.linkedAt.toDate ? data.linkedAt.toDate().toISOString() : null,
      };
    });

    return {success: true, owners: owners};
  } catch (error) {
    console.error('❌ Error listing owners:', error);
    throw new Error(error.message || 'Failed to list owners');
  }
});

// =====================================================
// FUNKCIJA 4: Brisanje Vlasnika
// =====================================================
exports.deleteOwner = onCall(
  {region: 'europe-west3'},
  async (request) => {
  // Auth check
  if (!request.auth || request.auth.token.email !== 'nevenroksa@gmail.com') {
    throw new Error('Unauthorized - Super Admin only');
  }

  const {tenantId} = request.data;

  if (!tenantId) {
    throw new Error('Missing tenantId');
  }

  try {
    // Get tenant data
    const tenantDoc = await admin.firestore()
      .collection('tenant_links')
      .doc(tenantId)
      .get();

    if (!tenantDoc.exists) {
      throw new Error('Tenant not found');
    }

    const firebaseUid = tenantDoc.data().firebaseUid;

    // Delete Firebase Auth user
    if (firebaseUid) {
      await admin.auth().deleteUser(firebaseUid);
    }

    // Delete tenant_links document
    await admin.firestore().collection('tenant_links').doc(tenantId).delete();

    // Delete settings document
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
});

// =====================================================
// FUNKCIJA 5: Reset Lozinke
// =====================================================
exports.resetOwnerPassword = onCall(
  {region: 'europe-west3'},
  async (request) => {
  // Auth check
  if (!request.auth || request.auth.token.email !== 'nevenroksa@gmail.com') {
    throw new Error('Unauthorized - Super Admin only');
  }

  const {tenantId, newPassword} = request.data;

  // Validation
  if (!tenantId || !newPassword) {
    throw new Error('Missing required fields: tenantId, newPassword');
  }

  if (newPassword.length < 6) {
    throw new Error('Password must be at least 6 characters');
  }

  try {
    // Get tenant data
    const tenantDoc = await admin.firestore()
      .collection('tenant_links')
      .doc(tenantId)
      .get();

    if (!tenantDoc.exists) {
      throw new Error('Tenant not found');
    }

    const firebaseUid = tenantDoc.data().firebaseUid;

    if (!firebaseUid) {
      throw new Error('Firebase UID not found');
    }

    // Update password
    await admin.auth().updateUser(firebaseUid, {
      password: newPassword,
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
});

// =====================================================
// FUNKCIJA 6: Suspend/Unsuspend Vlasnika
// =====================================================
exports.toggleOwnerStatus = onCall(
  {region: 'europe-west3'},
  async (request) => {
  // Auth check
  if (!request.auth || request.auth.token.email !== 'nevenroksa@gmail.com') {
    throw new Error('Unauthorized - Super Admin only');
  }

  const {tenantId, status} = request.data;

  // Validation
  if (!tenantId || !['active', 'suspended'].includes(status)) {
    throw new Error('Invalid parameters');
  }

  try {
    // Update status
    await admin.firestore().collection('tenant_links').doc(tenantId).update({
      status: status,
    });

    // Get tenant data
    const tenantDoc = await admin.firestore()
      .collection('tenant_links')
      .doc(tenantId)
      .get();

    const firebaseUid = tenantDoc.data().firebaseUid;

    // Disable/enable user
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
});

// =====================================================
// FUNKCIJA 7: AI PRIJEVOD - GEMINI SDK
// ✅ FIXED: Model gemini-2.5-flash + Enhanced prompt
// =====================================================
exports.translateHouseRules = onCall(
  {
    region: 'europe-west3',
    secrets: [geminiApiKey],
  },
  async (request) => {
    console.log('🌐 translateHouseRules called');

    // Auth check
    if (!request.auth) {
      throw new Error('Unauthorized - must be logged in');
    }

    const {text, sourceLang, targetLangs} = request.data;

    // Validation
    if (!text || !sourceLang || !targetLangs || !Array.isArray(targetLangs)) {
      throw new Error('Invalid parameters: text, sourceLang, targetLangs required');
    }

    try {
      const {GoogleGenerativeAI} = require('@google/generative-ai');
      const genAI = new GoogleGenerativeAI(geminiApiKey.value());
      // ✅ FIXED: Stable model instead of experimental
      const model = genAI.getGenerativeModel({model: 'gemini-2.5-flash'});

      const translations = {};

      for (const targetLang of targetLangs) {
        // ✅ FIXED: Enhanced prompt with quality checks
        const prompt = `You are a professional translator for a luxury villa rental service.

TASK: Translate the following text from ${sourceLang} to ${targetLang}.

CRITICAL REQUIREMENTS:
1. ACCURACY: Translate meaning precisely, not word-for-word
2. TONE: Maintain the same level of formality and warmth
3. FORMATTING: Preserve ALL formatting (line breaks, lists, bullet points, numbering)
4. NATURAL LANGUAGE: Sound like a native ${targetLang} speaker wrote it
5. NO ADDITIONS: Do not add explanations, notes, or extra text
6. CULTURAL ADAPTATION: Adapt idioms and cultural references appropriately

QUALITY CHECK (perform internally before outputting):
- Double-check grammar and spelling
- Verify all formatting is preserved
- Ensure the tone matches the original
- Confirm no content was added or omitted

Text to translate:
${text}

OUTPUT ONLY THE TRANSLATION IN ${targetLang}:`;

        console.log(`🔄 Translating to ${targetLang}...`);

        const result = await model.generateContent(prompt);
        const translatedText = result.response.text();

        if (!translatedText) {
          throw new Error(`No translation returned for ${targetLang}`);
        }

        translations[targetLang] = translatedText.trim();

        console.log(`✅ ${targetLang}: ${translatedText.substring(0, 50)}...`);
      }

      return {
        success: true,
        translations: translations,
        message: `Translated to ${targetLangs.length} languages`,
      };
    } catch (error) {
      console.error('❌ Translation error:', error);
      throw new Error(error.message || 'Translation failed');
    }
  }
);
// =====================================================
// FUNKCIJA 8: Registracija Tableta (DODAJ NA KRAJ index.js)
// =====================================================
// 
// SVRHA: Tablet poziva ovu funkciju pri SETUP-u.
// Funkcija verificira da Unit pripada Tenantu,
// kreira Anonymous Auth user i postavlja Custom Claims.
//
// FLOW:
// 1. Tablet šalje: tenantId + unitId
// 2. CF verificira da unit.ownerId == tenantId
// 3. CF kreira anonymous user + postavlja claims
// 4. CF vraća customToken za auto-login
// =====================================================

exports.registerTablet = onCall(
  {region: 'europe-west3'},
  async (request) => {
    console.log('📱 registerTablet called');

    const {tenantId, unitId} = request.data;

    // Validacija inputa
    if (!tenantId || !unitId) {
      console.error('❌ Missing required fields');
      throw new Error('Missing required fields: tenantId, unitId');
    }

    console.log(`📋 TenantID: ${tenantId}, UnitID: ${unitId}`);

    try {
      // 1. PROVJERI DA UNIT POSTOJI I PRIPADA TENANTU
      console.log('🔍 Checking unit ownership...');
      
      const unitDoc = await admin.firestore()
        .collection('units')
        .doc(unitId)
        .get();

      if (!unitDoc.exists) {
        console.error(`❌ Unit "${unitId}" not found`);
        throw new Error(`Unit "${unitId}" not found. Check Web Panel.`);
      }

      const unitData = unitDoc.data();
      
      // Provjeri vlasništvo
      if (unitData.ownerId !== tenantId) {
        console.error(`❌ Unit "${unitId}" does not belong to tenant "${tenantId}"`);
        throw new Error('Unit does not belong to this tenant. Check credentials.');
      }

      console.log('✅ Unit ownership verified');

      // 2. PROVJERI DA TENANT POSTOJI I AKTIVAN JE
      console.log('🔍 Checking tenant status...');
      
      const tenantDoc = await admin.firestore()
        .collection('tenant_links')
        .doc(tenantId)
        .get();

      if (!tenantDoc.exists) {
        console.error(`❌ Tenant "${tenantId}" not found`);
        throw new Error(`Tenant "${tenantId}" not found. Contact admin.`);
      }

      const tenantData = tenantDoc.data();
      
      if (tenantData.status === 'suspended') {
        console.error('❌ Tenant account suspended');
        throw new Error('Owner account is suspended. Contact admin.');
      }

      console.log('✅ Tenant verified');

      // 3. PROVJERI DA LI VEĆ POSTOJI TABLET ZA OVAJ UNIT
      // (Opcijski - možemo dozvoliti više tableta po unitu ili ne)
      const existingTablets = await admin.firestore()
        .collection('tablets')
        .where('unitId', '==', unitId)
        .where('status', '==', 'active')
        .get();

      if (!existingTablets.empty) {
        console.log('⚠️ Active tablet already exists for this unit, deactivating old...');
        // Deaktiviraj stare tablete za ovaj unit
        const batch = admin.firestore().batch();
        existingTablets.docs.forEach(doc => {
          batch.update(doc.ref, {status: 'replaced', replacedAt: admin.firestore.FieldValue.serverTimestamp()});
        });
        await batch.commit();
      }

      // 4. KREIRAJ ANONYMOUS AUTH USER ZA TABLET
      console.log('👤 Creating tablet auth user...');
      
      const tabletDisplayName = `Tablet_${unitId}_${Date.now()}`;
      
      const userRecord = await admin.auth().createUser({
        displayName: tabletDisplayName,
        // Anonymous user - nema email/password
      });

      console.log(`✅ Auth user created: ${userRecord.uid}`);

      // 5. POSTAVI CUSTOM CLAIMS
      console.log('🔐 Setting custom claims...');
      
      await admin.auth().setCustomUserClaims(userRecord.uid, {
        ownerId: tenantId,
        unitId: unitId,
        role: 'tablet',
      });

      console.log('✅ Custom claims set');

      // 6. SPREMI TABLET REGISTRACIJU U FIRESTORE
      console.log('💾 Saving tablet registration...');
      
      const tabletDocRef = admin.firestore().collection('tablets').doc();
      
      await tabletDocRef.set({
        id: tabletDocRef.id,
        firebaseUid: userRecord.uid,
        ownerId: tenantId,
        unitId: unitId,
        unitName: unitData.name || 'Unknown',
        status: 'active',
        registeredAt: admin.firestore.FieldValue.serverTimestamp(),
        lastActiveAt: admin.firestore.FieldValue.serverTimestamp(),
        platform: 'Android',
        appVersion: '1.0.0',
      });

      console.log('✅ Tablet registration saved');

      // 7. GENERIRAJ CUSTOM TOKEN ZA AUTO-LOGIN
      console.log('🎫 Generating custom token...');
      
      const customToken = await admin.auth().createCustomToken(userRecord.uid, {
        ownerId: tenantId,
        unitId: unitId,
        role: 'tablet',
      });

      console.log('✅ Custom token generated');

      // 8. VRATI PODATKE TABLETU
      return {
        success: true,
        customToken: customToken,
        firebaseUid: userRecord.uid,
        ownerId: String(tenantId),
        unitId: String(unitId),
        unitName: String(unitData.name || 'Unknown'),
        message: 'Tablet registered successfully!',
      };

    } catch (error) {
      console.error('❌ Error registering tablet:', error);
      throw new Error(error.message || 'Failed to register tablet');
    }
  }
);


// =====================================================
// FUNKCIJA 9: Heartbeat Tableta (opcijski, za tracking)
// =====================================================
// Tablet može periodički zvati ovu funkciju da
// vlasnik vidi da je tablet online.
// =====================================================

exports.tabletHeartbeat = onCall(
  {region: 'europe-west3'},
  async (request) => {
    // Auth check - mora biti tablet
    if (!request.auth) {
      throw new Error('Unauthorized');
    }

    const claims = request.auth.token;
    
    if (claims.role !== 'tablet') {
      throw new Error('Only tablets can send heartbeat');
    }

    const {unitId} = claims;

    try {
      // Update lastActiveAt u tablets collection
      const tabletsSnapshot = await admin.firestore()
        .collection('tablets')
        .where('unitId', '==', unitId)
        .where('status', '==', 'active')
        .limit(1)
        .get();

      if (!tabletsSnapshot.empty) {
        await tabletsSnapshot.docs[0].ref.update({
          lastActiveAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      return {success: true};
    } catch (error) {
      console.error('Heartbeat error:', error);
      return {success: false};
    }
  }
);