import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:virtual_queue/controllers/AccountController.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';

class UserAccountController extends AccountController {
  late FirebaseProvider _firebaseProvider;

  bool _pushNotificationEnabled = true;
  bool _chatNotificationEnabled = true;
  bool _emailNotificationEnabled = false;

  UserAccountController({required FirebaseProvider firebaseProvider})
    : super(collectionName: 'users', firebaseProvider: firebaseProvider);


  bool get pushNotificationEnabled => _pushNotificationEnabled;
  bool get chatNotificationEnabled => _chatNotificationEnabled;
  bool get emailNotificationEnabled => _emailNotificationEnabled;

// Methods to toggle notification settings
  void togglePushNotification(bool value) {
    _pushNotificationEnabled = value;
    // Add logic to update push notification settings in the database
    notifyListeners();
  }

  void toggleChatNotification(bool value) {
    _chatNotificationEnabled = value;
    // Add logic to update chat notification settings in the database
    notifyListeners();
  }

  void toggleEmailNotification(bool value) {
    _emailNotificationEnabled = value;
    // Add logic to update email notification settings in the database
    notifyListeners();
  }
}

