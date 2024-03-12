import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:virtual_queue/controllers/FirebaseProvider.dart';

class UserAccountController extends ChangeNotifier {
  late FirebaseProvider _firebaseProvider;
  UserAccountController({required FirebaseProvider firebaseProvider}) {
    _firebaseProvider = firebaseProvider;
  }

  Future<String?> signUp(String email, String password, String name, String phone) async {
    try {
      UserCredential credential = await _firebaseProvider.FIREBASE_AUTH.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      CollectionReference users = _firebaseProvider.FIREBASE_FIRESTORE.collection('users');
      await users.doc(uid).set({
        'name': name,
        'phone': phone,
        'email': email,
        'uid': uid,
      });
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Email already in use';
      }
      if (e.code == 'weak-password') {
        return 'Password too weak';
      }
      return 'An error occurred: ${e.message}';
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      UserCredential credential = await _firebaseProvider.FIREBASE_AUTH.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('login success');
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return 'Invalid email';
      } else if (e.code == 'invalid-login-credentials') {
        return 'Incorrect email or password credentials';
      } else if (e.code == 'too-many-requests') {
        return 'Too many requests';
      } else if (e.code == 'missing-password') {
        return 'Missing password';
      }
      return 'An error occurred: ${e.message}';
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final user = _firebaseProvider.FIREBASE_AUTH.currentUser;
    if (user != null) {
      final response = await _firebaseProvider.FIREBASE_FIRESTORE.collection('users').doc(user.uid).get();
      return response.data();
    }
    return null;
  }

  Future<void> signOut() async {
    await _firebaseProvider.FIREBASE_AUTH.signOut();
  }
}
