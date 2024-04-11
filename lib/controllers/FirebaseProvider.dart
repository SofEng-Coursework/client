import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseProvider extends ChangeNotifier {
  late FirebaseApp FIREBASE_APP;
  late FirebaseAuth FIREBASE_AUTH;
  late FirebaseFirestore FIREBASE_FIRESTORE;

  FirebaseProvider();

  Future<void> initialize() async {
    FIREBASE_APP = await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FIREBASE_AUTH = FirebaseAuth.instanceFor(app: FIREBASE_APP);
    FIREBASE_FIRESTORE = FirebaseFirestore.instanceFor(app: FIREBASE_APP);

    FIREBASE_AUTH.authStateChanges().listen((User? user) {
      notifyListeners();
    });

    await Future.delayed(Duration(milliseconds: 250));
  }

  Future<void> initializeMock() async {
    FIREBASE_AUTH = MockFirebaseAuth();
    FIREBASE_FIRESTORE = FakeFirebaseFirestore();

    await Future.delayed(Duration(milliseconds: 250));
  }

  User? getLoggedInUser() {
    return FIREBASE_AUTH.currentUser;
  }
}
