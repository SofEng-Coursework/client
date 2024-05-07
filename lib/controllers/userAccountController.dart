import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:virtual_queue/controllers/AccountController.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';

class UserAccountController extends AccountController {
  UserAccountController({required FirebaseProvider firebaseProvider})
      : super(collectionName: 'users', firebaseProvider: firebaseProvider) {}

  Future<List<Map<String, dynamic>>> getHistory() async {
    final user = firebaseProvider.FIREBASE_AUTH.currentUser;
    if (user == null) return [];
    final userUID = user.uid;
    final snapshot = await firebaseProvider.FIREBASE_FIRESTORE.collection('queues').get();
    List<Map<String, dynamic>> history = [];
    for (DocumentSnapshot doc in snapshot.docs) {
      final queue = doc.data() as Map<String, dynamic>;
      final logs = queue['logs'] as List;
      for (Map<String, dynamic> log in logs) {
        if (log['userId'] == userUID) {
          final int start = log['start'];
          final int end = log['end'];
          // check if less than 30 days ago
          if (DateTime.now().millisecondsSinceEpoch - start > 30 * 24 * 60 * 60 * 1000) continue;
          history.add({
            'queue': queue['name'],
            'start': start,
            'end': end,
          });
        }
      }
    }
    return history;
  }
}
