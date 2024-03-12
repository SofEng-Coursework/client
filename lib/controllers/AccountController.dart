import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';

abstract class AccountController extends ChangeNotifier {
  late FirebaseProvider _firebaseProvider;
  final String collectionName;

  AccountController({required this.collectionName, required FirebaseProvider firebaseProvider}) {
    _firebaseProvider = firebaseProvider;
  }

  Future<String?> signUp(String email, String password, String name, String phone) async {
    try {
      UserCredential credential = await _firebaseProvider.FIREBASE_AUTH.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      CollectionReference collection = _firebaseProvider.FIREBASE_FIRESTORE.collection(collectionName);
      await collection.doc(uid).set({
        'name': name,
        'phone': phone,
        'email': email,
        'uid': uid,
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return "An error occurred: ${e.message}";
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      UserCredential credential = await _firebaseProvider.FIREBASE_AUTH.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return 'An error occurred: ${e.message}';
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final user = _firebaseProvider.FIREBASE_AUTH.currentUser;
    if (user != null) {
      final response = await _firebaseProvider.FIREBASE_FIRESTORE.collection(collectionName).doc(user.uid).get();
      return response.data();
    }
    return null;
  }

  Future<void> signOut() async {
    await _firebaseProvider.FIREBASE_AUTH.signOut();
  }
}