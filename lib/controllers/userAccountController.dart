import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserAccountController extends ChangeNotifier {
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;

  UserAccountController({required FirebaseAuth auth, required FirebaseFirestore firestore}) {
    _auth = auth;
    _firestore = firestore;
  }

  Future<String?> signUp(String email, String password, String name, String phone) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      CollectionReference users = _firestore.collection('users');
      DocumentReference ref = await users.add({
        'email': email,
        'uid': credential.user!.uid,
        'name': name,
        'phone': phone,
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

  Future<String?> login(BuildContext context, String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
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
}
