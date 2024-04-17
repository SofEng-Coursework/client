import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';
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
      DocumentReference queues = _firebaseProvider.FIREBASE_FIRESTORE
          .collection('queues')
          .doc(queueId);
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
      await FirebaseFirestore.instance
          .collection("queues")
          .doc(queueId)
          .update({"users": users});
      return null;
    }
  }

  Future<String?> leaveQueue(String queueId) async {
    final userUID = _firebaseProvider.FIREBASE_AUTH.currentUser!.uid;
    Map<String, String> users = {};
    try {
      DocumentReference queues = _firebaseProvider.FIREBASE_FIRESTORE
          .collection('queues')
          .doc(userUID);
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

    await FirebaseFirestore.instance
        .collection("queues")
        .doc(queueId)
        .update({"users": users});

    return null;
  }

  Future<int> viewProgress(String uid, String queueId) async {
    Map<String, String> users = {};
    try {
      DocumentReference queues =
          _firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc(uid);
      final timeSnapshot = await queues.get();
      if (timeSnapshot.exists) {
        final user = timeSnapshot['users'] as Map<String, String>;
        users = user;
      } else {
        print("Queue not found");
        return -1;
      }
    } catch (e) {
      print(e.toString());
      return -1;
    }
    List<MapEntry<String, String>> sortedUsers = users.entries.toList()
      ..sort((a, b) {
        DateTime bTime = DateTime.parse(b.value);
        return bTime.compareTo(DateTime.now());
      });

    int userPosition = sortedUsers.indexWhere((entry) => entry.key == uid);
    return userPosition + 1;
  }

  Stream<QuerySnapshot> getQueues() {
    return _firebaseProvider.FIREBASE_FIRESTORE
        .collection('queues')
        .snapshots();
  }

  Stream<int> getProgressStream() {
    final userUID = _firebaseProvider.FIREBASE_AUTH.currentUser!.uid;
    try {
      // Reference to the queue document
      DocumentReference queueRef = _firebaseProvider.FIREBASE_FIRESTORE
          .collection('queues')
          .doc(userUID);

      // Return a stream of QuerySnapshot
      return queueRef.snapshots().map((snapshot) {
        if (snapshot.exists) {
          // Get the users map from the snapshot data
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          Map<String, String> users = data['users'] as Map<String, String>;

          // Sort the users map by timestamp
          List<MapEntry<String, String>> sortedUsers = users.entries.toList()
            ..sort((a, b) {
              DateTime bTime = DateTime.parse(b.value);
              return bTime.compareTo(DateTime.now());
            });

          // Find the user position in the sorted list
          int userPosition =
              sortedUsers.indexWhere((entry) => entry.key == userUID);

          // Return the user's position in the queue
          return userPosition + 1;
        } else {
          // Return -1 if the queue document doesn't exist
          return -1;
        }
      });
    } catch (e) {
      // Print and return -1 if an error occurs
      print(e.toString());
      return Stream.value(-1);
    }
  }
}
