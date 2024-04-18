import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';

class AdminQueueController extends ChangeNotifier {
  late FirebaseProvider _firebaseProvider;
  AdminQueueController({required FirebaseProvider firebaseProvider}) {
    _firebaseProvider = firebaseProvider;
  }

  /// Adds a new queue to the Firestore database
  Future<String?> addQueue(String name, int? capacity, String owner) async {
    CollectionReference collection = _firebaseProvider.FIREBASE_FIRESTORE.collection('queues');
    await collection.doc().set({'id': collection.doc().id, 'name': name, 'open': true, 'capacity': capacity, 'owner': owner, 'users': []});
    return null;
  }

  /// Returns a Stream of all queues owned by the current admin
  Stream<QuerySnapshot> getQueues() {
    final adminUID = _firebaseProvider.FIREBASE_AUTH.currentUser!.uid;

    return _firebaseProvider.FIREBASE_FIRESTORE.collection('queues').where('owner', isEqualTo: adminUID).snapshots();
  }
}
