import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';

class QueueController extends ChangeNotifier {
  late FirebaseProvider _firebaseProvider;
  QueueController({required FirebaseProvider firebaseProvider}) {
    _firebaseProvider = firebaseProvider;
  }

  Future<String?> addQueue(String name,int capacity,String owner) async {

    CollectionReference collection = _firebaseProvider.FIREBASE_FIRESTORE.collection('queues');
    await collection.doc().set({
      'name': name,
      'open': true,
      'capacity': capacity,
      'owner': owner
      // other things I've got noted down somewhere
    });
    return null;
  }
}