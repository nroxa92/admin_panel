// FILE: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: "AIzaSyAjoZz3-XfmRw7vMGOxkywGB4-ghHKaqRo",
        authDomain: "villa-ai-admin.firebaseapp.com",
        projectId: "villa-ai-admin",
        storageBucket: "villa-ai-admin.firebasestorage.app",
        messagingSenderId: "510976438146",
        appId: "1:510976438146:web:167491469cb0e96ab6a99b",
        measurementId: "G-HEERRXZEF4",
      );
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }
}
