// GENERATED FILE. DO NOT EDIT.
// This is a basic firebase_options.dart for SafeHer Flutter app for web and Android/iOS.
// Replace these values with your project's actual Firebase config if needed.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

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
          'DefaultFirebaseOptions are not supported for this platform',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBuvd8CtR5InN6r01NKqxoqXBmzUIq2v-Q',
    authDomain: 'safeher-cb626.firebaseapp.com',
    projectId: 'safeher-cb626',
    storageBucket: 'safeher-cb626.appspot.com',
    messagingSenderId: '174168027843',
    appId: '1:174168027843:web:1d9dec2a3cea7df4dce876',
    measurementId: 'G-XXXXXXXXXX', // Optional
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDmzOg4Vmb14yUKQFR1UxLX0zMhlTAocFc',
    appId: '1:174168027843:android:c7c611c138ee91efdce876',
    messagingSenderId: '174168027843',
    projectId: 'safeher-cb626',
    storageBucket: 'safeher-cb626.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBuvd8CtR5InN6r01NKqxoqXBmzUIq2v-Q',
    appId: '1:174168027843:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '174168027843',
    projectId: 'safeher-cb626',
    storageBucket: 'safeher-cb626.appspot.com',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'YOUR_IOS_BUNDLE_ID',
  );
}
