import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:virtual_queue/controllers/AccountController.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';

class UserAccountController extends AccountController {
  late Map<String, dynamic> _notificationSettings;

  UserAccountController({required FirebaseProvider firebaseProvider}) : super(collectionName: 'users', firebaseProvider: firebaseProvider) {
    // Initialize notification settings when the controller is created
    _notificationSettings = {'push_enabled': true, 'chat_enabled': true, 'email_enabled': false};
    _initializeNotificationSettings();
  }

  bool get pushNotificationEnabled => _notificationSettings['push_enabled'] ?? true;
  bool get chatNotificationEnabled => _notificationSettings['chat_enabled'] ?? true;
  bool get emailNotificationEnabled => _notificationSettings['email_enabled'] ?? false;

  void togglePushNotification(bool value) {
    _notificationSettings['push_enabled'] = value;
    _updateNotificationSettings();
    notifyListeners();
  }

  void toggleChatNotification(bool value) {
    _notificationSettings['chat_enabled'] = value;
    _updateNotificationSettings();
    notifyListeners();
  }

  void toggleEmailNotification(bool value) {
    _notificationSettings['email_enabled'] = value;
    _updateNotificationSettings();
    notifyListeners();
  }

  void _initializeNotificationSettings() async {
    final user = firebaseProvider.FIREBASE_AUTH.currentUser;
    if (user != null) {
      final docSnapshot = await firebaseProvider.FIREBASE_FIRESTORE.collection('users').doc(user.uid).get();
      _notificationSettings = Map<String, dynamic>.from(docSnapshot.data()?['notification_settings'] ?? {});
      notifyListeners();
    }
  }

  void _updateNotificationSettings() async {
    final user = firebaseProvider.FIREBASE_AUTH.currentUser;
    if (user != null) {
      await firebaseProvider.FIREBASE_FIRESTORE.collection('users').doc(user.uid).update({'notification_settings': _notificationSettings});
    }
  }
}
