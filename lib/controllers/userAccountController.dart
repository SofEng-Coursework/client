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

  void signUp(BuildContext context, String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      CollectionReference users = _firestore.collection('users');
      DocumentReference ref = await users.add({
        'email': email,
        'uid': credential.user!.uid,
        'firstname': 'John',
        'lastname': 'Doe',
        'phone': '123-456-7890',
      });

    } on FirebaseAuthException catch (e) {
      print(e.message);
      if (e.code == 'email-already-in-use') {
        errBox(context, 'Sign Up Failed', 'Email already in use');
      }
      if (e.code == 'weak-password') {
        errBox(context, 'Sign Up Failed', 'Password too weak');
      }
      errBox(context, 'Sign Up Failed', 'An error occurred: ${e.message}');
    }
  }

  void login(BuildContext context, String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('login success');

      //TODO request server
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        errBox(context, 'Login Failed', 'No user found with that email');
      } else if (e.code == 'invalid-login-credentials') {
        errBox(context, 'Login Failed', 'Incorrect password for that account');
      } else if (e.code == 'too-many-requests') {
        errBox(context, 'Login Failed', 'Too many attempts, you have been locked out');
      } else if (e.code == 'missing-password') {
        errBox(context, 'Login Failed', 'No password entered');
      }
      errBox(context, 'Login Failed', 'An error occurred: ${e.message}');
    }
  }
}

void errBox(BuildContext context, String alert, String errMsg) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(alert),
        content: Text(errMsg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
