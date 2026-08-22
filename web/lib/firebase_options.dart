import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB46nLtbd5Hu4UGhXBtCVZwHbOyJQFlyMI',
    appId: '1:761563886340:android:a0db0324f9c87bcb77d651',
    messagingSenderId: '761563886340',
    projectId: 'mgpl-d9aa9',
    storageBucket: 'mgpl-d9aa9.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDVIga9r6d1osbCsfAY5KctOlvHXQaRajY',
    appId: '1:761563886340:ios:f25142215951297477d651',
    messagingSenderId: '761563886340',
    projectId: 'mgpl-d9aa9',
    storageBucket: 'mgpl-d9aa9.appspot.com',
    androidClientId: '761563886340-j9svi3di4bts7q1dm1fejnqfqkups3hs.apps.googleusercontent.com',
    iosClientId: '761563886340-m2rm99cd8dgnsveu5q765jh8sl0vr22k.apps.googleusercontent.com',
    iosBundleId: 'com.devarch.immozen',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCb1nIigaBjAWMX704IcHt4VbtDCN0EZM8',
    appId: '1:761563886340:web:e733cbd34f9aa2b777d651',
    messagingSenderId: '761563886340',
    projectId: 'mgpl-d9aa9',
    authDomain: 'mgpl-d9aa9.firebaseapp.com',
    storageBucket: 'mgpl-d9aa9.appspot.com',
    measurementId: 'G-CZSL9W0CLH',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDVIga9r6d1osbCsfAY5KctOlvHXQaRajY',
    appId: '1:761563886340:ios:f25142215951297477d651',
    messagingSenderId: '761563886340',
    projectId: 'mgpl-d9aa9',
    storageBucket: 'mgpl-d9aa9.appspot.com',
    androidClientId: '761563886340-j9svi3di4bts7q1dm1fejnqfqkups3hs.apps.googleusercontent.com',
    iosClientId: '761563886340-m2rm99cd8dgnsveu5q765jh8sl0vr22k.apps.googleusercontent.com',
    iosBundleId: 'com.devarch.immozen',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCb1nIigaBjAWMX704IcHt4VbtDCN0EZM8',
    appId: '1:761563886340:web:2381b90b261db0d277d651',
    messagingSenderId: '761563886340',
    projectId: 'mgpl-d9aa9',
    authDomain: 'mgpl-d9aa9.firebaseapp.com',
    storageBucket: 'mgpl-d9aa9.appspot.com',
    measurementId: 'G-FKT89LYYRZ',
  );

}