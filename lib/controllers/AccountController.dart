import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';
import 'package:virtual_queue/models/ErrorStatus.dart';
import 'package:virtual_queue/pages/RegisterForm.dart';
import 'package:virtual_queue/InputVerifications.dart';

class AccountController extends ChangeNotifier {
  late FirebaseProvider firebaseProvider;
  final String collectionName;

  AccountController({required this.collectionName, required this.firebaseProvider});

  Future<ErrorStatus> signUp(String email, String password, String name, String phone) async {
    if (!validEmail(email) | !validPhone(phone) | !validPassword(password)) {
      return ErrorStatus(success: false);
    }
    try {
      UserCredential credential = await firebaseProvider.FIREBASE_AUTH.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      CollectionReference collection = firebaseProvider.FIREBASE_FIRESTORE.collection(collectionName);
      await collection.doc(uid).set({
        'name': name,
        'phone': phone,
        'email': email,
        'uid': uid,
        'feedbackPrompt': [],
        'notificiation_settings': {
          'chat_enabled': true,
          'email_enabled': true,
          'push_enabled': true,
        }
      });
      return ErrorStatus(success: true);
    } on FirebaseAuthException catch (e) {
      return ErrorStatus(success: false, message: 'An error occurred: ${e.message}');
    }
  }

  Future<ErrorStatus> login(String email, String password) async {
    try {
      UserCredential credential = await firebaseProvider.FIREBASE_AUTH.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return ErrorStatus(success: true);
    } on FirebaseAuthException catch (e) {
      return ErrorStatus(success: false, message: 'An error occurred: ${e.message}');
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final user = firebaseProvider.FIREBASE_AUTH.currentUser;
    if (user != null) {
      final response = await firebaseProvider.FIREBASE_FIRESTORE.collection(collectionName).doc(user.uid).get();
      Map<String, dynamic>? data = response.data();
      if (data == null) {
        return null;
      }
      data['accountType'] = collectionName == 'users' ? AccountType.User : AccountType.Admin;
      return data;
    }
    return null;
  }

  Future<ErrorStatus> signOut() async {
    await firebaseProvider.FIREBASE_AUTH.signOut();
    return ErrorStatus(success: true);
  }

  Future<ErrorStatus> deleteAccount() async {
    final user = firebaseProvider.FIREBASE_AUTH.currentUser;
    if (user == null) return ErrorStatus(success: false, message: 'User not found');
    await firebaseProvider.FIREBASE_FIRESTORE.collection(collectionName).doc(user.uid).delete();
    await user.delete();
    return ErrorStatus(success: true);
  }

  Future<ErrorStatus> updateAccount({String? name, String? phone}) async {
    final user = firebaseProvider.FIREBASE_AUTH.currentUser;
    if (user == null) return ErrorStatus(success: false, message: 'User not found');
    Map<String, dynamic> data = {};
    if (name != null) {
      data['name'] = name;
    }
    if (phone != null) {
      data['phone'] = phone;
    }
    await firebaseProvider.FIREBASE_FIRESTORE.collection(collectionName).doc(user.uid).update(data);
    return ErrorStatus(success: true);
  }
}
