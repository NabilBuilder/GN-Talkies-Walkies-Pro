import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDfjpHLnw6gHcV06QfNYIW_17MgD1ej1Xg',
    appId: '1:1068673376529:web:f65f0653891b5c5d896cb0',
    messagingSenderId: '1068673376529',
    projectId: 'studio-9699067203-220ec',
    storageBucket: 'studio-9699067203-220ec.firebasestorage.app',
    authDomain: 'studio-9699067203-220ec.firebaseapp.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: '1068673376529',
    projectId: 'studio-9699067203-220ec',
    storageBucket: 'studio-9699067203-220ec.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: '1068673376529',
    projectId: 'studio-9699067203-220ec',
    storageBucket: 'studio-9699067203-220ec.firebasestorage.app',
    iosBundleId: 'com.example.gestion_materiel',
  );
}
