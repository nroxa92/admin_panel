// FILE: lib/firebase_options.dart
// PROJECT: Vesta Lumina System (VLS)
// FIREBASE: vls-admin

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: "AIzaSyAAcIoY-JcCOeWHAhbQdSF21uBpHO2O_J8",
        authDomain: "vls-admin.firebaseapp.com",
        projectId: "vls-admin",
        storageBucket: "vls-admin.firebasestorage.app",
        messagingSenderId: "408151118868",
        appId: "1:408151118868:web:db68e134285d21e7fbeab9",
        measurementId: "G-N56T0WF88W",
      );
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }
}
