import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';
import 'package:virtual_queue/models/Queue.dart';
import 'package:virtual_queue/pages/RegisterForm.dart';
import 'dart:async';

class UserQueueController extends ChangeNotifier {
  late FirebaseProvider _firebaseProvider;
  UserQueueController({required FirebaseProvider firebaseProvider}) {
    _firebaseProvider = firebaseProvider;
  }

  Future<String?> joinQueue(String queueId) async {
    final userUID = _firebaseProvider.FIREBASE_AUTH.currentUser!.uid;
    bool opened = false;
    double capacity = 0;
    dynamic users = {};
    try {
      DocumentReference queues = _firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc(queueId);
      final timeSnapshot = await queues.get();
      if (timeSnapshot.exists) {
        opened = timeSnapshot['open'] as bool;
        capacity = (timeSnapshot['capacity'] ?? double.infinity) as double;
        users = timeSnapshot['users'];
      } else {
        return ("An error occurred: Queue not found");
      }
    } catch (e) {
      return "An error occurred: ${e.toString()}";
    }
    if (opened == false) {
      return ("An error occurred: Queue not opened");
    } else if (users.length >= capacity) {
      return ("An error occurred: Queue full");
    } else {
      users[userUID] = (DateTime.now().millisecondsSinceEpoch);
      await FirebaseFirestore.instance.collection("queues").doc(queueId).update({"users": users});
      return null;
    }
  }

  Future<String?> leaveQueue(String queueId) async {
    final userUID = _firebaseProvider.FIREBASE_AUTH.currentUser!.uid;
    Map<String, String> users = {};
    try {
      DocumentReference queues = _firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc(userUID);
      final timeSnapshot = await queues.get();
      if (timeSnapshot.exists) {
        final user = timeSnapshot['users'] as Map<String, String>;
        users = user;
      } else {
        return ("An error occurred: Queue not found");
      }
    } catch (e) {
      return "An error occurred: ${e.toString()}";
    }

    users.remove(userUID);

    await FirebaseFirestore.instance.collection("queues").doc(queueId).update({"users": users});

    return null;
  }

  Stream<List<Queue>> getQueues() {
    return _firebaseProvider.FIREBASE_FIRESTORE
        .collection('queues')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Queue.fromJson(doc.data())).toList());
  }

  Stream<int> getProgressStream() {
    final userUID = _firebaseProvider.FIREBASE_AUTH.currentUser?.uid;
    if (userUID == null) {
      // Return -1 if the user is not logged in
      return Stream.value(-1);
    }

    return _firebaseProvider.FIREBASE_FIRESTORE.collection('queues').snapshots().map((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        Queue queue = Queue.fromJson(doc.data() as Map<String, dynamic>);
        int position = queue.users.indexWhere((element) => element.userId == userUID);
        if (position != -1) {
          print("User found in queue: $position");
          return position; // Return the position if the user is found in the queue
        }
      }
      return -1; // Return -1 if the user is not found in any queue
    });
  }
}
