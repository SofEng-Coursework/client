import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';
import 'package:virtual_queue/pages/RegisterForm.dart';

class UserQueueController {
  late FirebaseProvider _firebaseProvider;
  UserQueueController({required FirebaseProvider firebaseProvider}) {
    _firebaseProvider = firebaseProvider;
  }

  Future<void> joinQueue(String uid, String queueId) async {
    bool opened = false;
    double capacity = 0;
    Map<String, String> users = {};
    try {
      DocumentReference queues =
          _firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc(uid);
      final timeSnapshot = await queues.get();
      if (timeSnapshot.exists) {
        final open = timeSnapshot['open'] as bool;
        final cap = timeSnapshot['capacity'] as double;
        final user = timeSnapshot['users'] as Map<String, String>;
        opened = open;
        capacity = cap;
        users = user;
      } else {
        print("Queue not found");
        return;
      }
    } catch (e) {
      print(e.toString());
      return;
    }
    if (opened == false) {
      print("Queue not opened");
      return;
    } else if (users.length >= capacity) {
      print("Queue full");
      return;
    } else {
      users[uid] = (DateTime.now().toString());
      await FirebaseFirestore.instance
          .collection("queues")
          .doc(queueId)
          .update({"users": users});
    }
  }

  Future<void> leaveQueue(String uid, String queueId) async {
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
        return;
      }
    } catch (e) {
      print(e.toString());
    }

    users.remove(uid);

    await FirebaseFirestore.instance
        .collection("queues")
        .doc(queueId)
        .update({"users": users});
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
}
