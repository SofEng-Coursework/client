
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBLgynqUFGD-gtz1bZtGIt2n5OnEUIzXic',
    appId: '1:453363243064:web:7936870b21f713920c6ecd',
    messagingSenderId: '453363243064',
    projectId: 'virtual-queue-database',
    authDomain: 'virtual-queue-database.firebaseapp.com',
    databaseURL: 'https://virtual-queue-database-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'virtual-queue-database.appspot.com',
    measurementId: 'G-EEPC8HW9Y7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCreqU6cibzahaOxeXvJOgTwjUGFLnUJOM',
    appId: '1:453363243064:android:ce70d8db6bbdc69f0c6ecd',
    messagingSenderId: '453363243064',
    projectId: 'virtual-queue-database',
    databaseURL: 'https://virtual-queue-database-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'virtual-queue-database.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCtLQN6aT55-evukkQqRhHTklERgUsQQSw',
    appId: '1:453363243064:ios:d87d6b2d4aa7939b0c6ecd',
    messagingSenderId: '453363243064',
    projectId: 'virtual-queue-database',
    databaseURL: 'https://virtual-queue-database-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'virtual-queue-database.appspot.com',
    iosBundleId: 'com.example.virtualQueue',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCtLQN6aT55-evukkQqRhHTklERgUsQQSw',
    appId: '1:453363243064:ios:277413c2bd1807010c6ecd',
    messagingSenderId: '453363243064',
    projectId: 'virtual-queue-database',
    databaseURL: 'https://virtual-queue-database-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'virtual-queue-database.appspot.com',
    iosBundleId: 'com.example.virtualQueue.RunnerTests',
  );
}
