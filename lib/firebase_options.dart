// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB9PHy1naG7PAi_3Rr5FrxOlzVagG9q6Ik',
    appId: '1:574666074849:web:f6737107ff7d8ae36f65a0',
    messagingSenderId: '574666074849',
    projectId: 'madhw4-de104',
    authDomain: 'madhw4-de104.firebaseapp.com',
    storageBucket: 'madhw4-de104.firebasestorage.app',
    measurementId: 'G-D8G38T2TY5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBVmsm_qbAmaNZVhASi_d1MnbZ8-uwR9TA',
    appId: '1:574666074849:android:ff0a8ae500176beb6f65a0',
    messagingSenderId: '574666074849',
    projectId: 'madhw4-de104',
    storageBucket: 'madhw4-de104.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD-v1p7qIZcEtWmQVHX-P67IFL4_LMNZbg',
    appId: '1:574666074849:ios:f64d9d22b3e6814c6f65a0',
    messagingSenderId: '574666074849',
    projectId: 'madhw4-de104',
    storageBucket: 'madhw4-de104.firebasestorage.app',
    iosBundleId: 'com.example.hw4',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD-v1p7qIZcEtWmQVHX-P67IFL4_LMNZbg',
    appId: '1:574666074849:ios:f64d9d22b3e6814c6f65a0',
    messagingSenderId: '574666074849',
    projectId: 'madhw4-de104',
    storageBucket: 'madhw4-de104.firebasestorage.app',
    iosBundleId: 'com.example.hw4',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB9PHy1naG7PAi_3Rr5FrxOlzVagG9q6Ik',
    appId: '1:574666074849:web:337163bb59f99b406f65a0',
    messagingSenderId: '574666074849',
    projectId: 'madhw4-de104',
    authDomain: 'madhw4-de104.firebaseapp.com',
    storageBucket: 'madhw4-de104.firebasestorage.app',
    measurementId: 'G-HRHFT4NR9V',
  );
}
