import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    final FirebaseOptions options;
    if (kIsWeb) {
      options = web;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      options = android;
    } else {
      throw UnsupportedError('Este projeto suporta Android e Web.');
    }
    if (options.apiKey.isEmpty ||
        options.appId.isEmpty ||
        options.projectId.isEmpty ||
        options.messagingSenderId.isEmpty) {
      throw StateError(
        'Informe firebase.local.json com --dart-define-from-file.',
      );
    }
    return options;
  }

  static const web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_WEB_APP_ID'),
    projectId: String.fromEnvironment('FIREBASE_WEB_PROJECT_ID'),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_WEB_MESSAGING_SENDER_ID',
    ),
    authDomain: String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN'),
    storageBucket: String.fromEnvironment('FIREBASE_WEB_STORAGE_BUCKET'),
  );

  static const android = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
    projectId: String.fromEnvironment('FIREBASE_ANDROID_PROJECT_ID'),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_ANDROID_MESSAGING_SENDER_ID',
    ),
    storageBucket: String.fromEnvironment('FIREBASE_ANDROID_STORAGE_BUCKET'),
  );
}
