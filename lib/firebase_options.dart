import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAznT3wkJ5238dAC5KjA7qmcBlrFYfrJjM',
    appId: '1:191983645033:android:a2d3c6bd3207e18e034df8',
    messagingSenderId: '191983645033',
    projectId: 'bulkrep-6d946',
    storageBucket: 'bulkrep-6d946.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAznT3wkJ5238dAC5KjA7qmcBlrFYfrJjM',
    appId: '1:191983645033:ios:a2d3c6bd3207e18e034df8',
    messagingSenderId: '191983645033',
    projectId: 'bulkrep-6d946',
    storageBucket: 'bulkrep-6d946.firebasestorage.app',
    iosBundleId: 'com.levelbot.app',
  );
}
