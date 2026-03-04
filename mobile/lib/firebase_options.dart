// File generated from google-services.json for project agriai-b0313.
// For full multi-platform support, run `flutterfire configure`.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'run flutterfire configure to add web support.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS - '
          'run flutterfire configure to add iOS support.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
          'run flutterfire configure to add macOS support.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows - '
          'run flutterfire configure to add Windows support.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux - '
          'run flutterfire configure to add Linux support.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAARjYJS4Vr31MBJXKIC3iKpp1n3DOE4qw',
    appId: '1:401878442946:android:e65e557c10d66a551f6c5b',
    messagingSenderId: '401878442946',
    projectId: 'agriai-b0313',
    storageBucket: 'agriai-b0313.firebasestorage.app',
  );
}
