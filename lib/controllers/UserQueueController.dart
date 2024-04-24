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

  Future<String?> joinQueue(Queue queue) async {
    String? userUID = _firebaseProvider.FIREBASE_AUTH.currentUser?.uid;
    if (userUID == null) {
      return ("An error occurred: User not logged in");
    }
    if (queue.isFull()) {
      return ("An error occurred: Queue full");
    }
    if (!queue.open) {
      return ("An error occurred: Queue not opened");
    }
    if (queue.users.indexWhere((element) => element.userId == userUID) != -1) {
      return ("An error occurred: User already in queue");
    }

    final name = await _firebaseProvider.FIREBASE_FIRESTORE.collection('users').doc(userUID).get().then((value) => value.data()?['name']);

    final queueReference = _firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc(queue.id);
    queue.users.add(QueueUserEntry(
      userId: userUID, 
      name: name,
      timestamp: DateTime.now().millisecondsSinceEpoch
    ));

    await queueReference.update({'users': queue.users.map((e) => e.toJson()).toList()});

    return null;
  }

  Future<String?> leaveQueue(Queue queue) async {
    String? userUID = _firebaseProvider.FIREBASE_AUTH.currentUser?.uid;
    if (userUID == null) {
      return ("An error occurred: User not logged in");
    }
    if (queue.users.indexWhere((element) => element.userId == userUID) == -1) {
      return ("An error occurred: User not in queue");
    }

    final queueReference = _firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc(queue.id);
    queue.users.removeWhere((element) => element.userId == userUID);

    await queueReference.update({'users': queue.users.map((e) => e.toJson()).toList()});

    return null;
  }

  Stream<List<Queue>> getQueues() {
    return _firebaseProvider.FIREBASE_FIRESTORE
        .collection('queues')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Queue.fromJson(doc.data())).toList());
  }


  Stream<Queue?> getCurrentQueue() {
    final userUID = _firebaseProvider.FIREBASE_AUTH.currentUser?.uid;
    if (userUID == null) {
      return Stream.value(null);
    }

    return _firebaseProvider.FIREBASE_FIRESTORE.collection('queues').snapshots().map((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        Queue queue = Queue.fromJson(doc.data() as Map<String, dynamic>);
        int position = queue.users.indexWhere((element) => element.userId == userUID);
        if (position != -1) {
          return queue; // Return the Queue object if the user is found in the queue
        }
      }
      return null; // Return null if the user is not found in any queue
    });
  }

  Future<Queue?> getCurrentQueueFuture() async {
    final userUID = _firebaseProvider.FIREBASE_AUTH.currentUser?.uid;
    if (userUID == null) {
      return null;
    }

    final snapshot = await _firebaseProvider.FIREBASE_FIRESTORE.collection('queues').get();
    for (DocumentSnapshot doc in snapshot.docs) {
      Queue queue = Queue.fromJson(doc.data() as Map<String, dynamic>);
      int position = queue.users.indexWhere((element) => element.userId == userUID);
      if (position != -1) {
        return queue; // Return the Queue object if the user is found in the queue
      }
    }
    return null; // Return null if the user is not found in any queue
  }

  Stream<int> getCurrentQueuePosition() {
    final userUID = _firebaseProvider.FIREBASE_AUTH.currentUser?.uid;
    if (userUID == null) {
      return Stream.value(-1);
    }

    return getCurrentQueue().map((queue) {
      if (queue == null) {
        return -1;
      }
      int position = queue.users.indexWhere((element) => element.userId == userUID);
      return position == -1 ? -1 : position + 1;
    });
  }
}
