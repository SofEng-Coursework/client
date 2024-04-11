import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:virtual_queue/controllers/AccountController.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';

class AdminAccountController extends AccountController {
  late FirebaseProvider _firebaseProvider;
  AdminAccountController({required FirebaseProvider firebaseProvider})
    : super(collectionName: 'admins', firebaseProvider: firebaseProvider);


}

