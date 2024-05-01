import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';
import 'package:virtual_queue/models/ErrorStatus.dart';
import 'package:virtual_queue/models/FeedbackEntry.dart';
import 'package:virtual_queue/models/Queue.dart';
import 'package:virtual_queue/pages/RegisterForm.dart';
import 'dart:async';

class UserQueueController extends ChangeNotifier {
  late FirebaseProvider _firebaseProvider;
  UserQueueController({required FirebaseProvider firebaseProvider}) {
    _firebaseProvider = firebaseProvider;
  }

  Future<ErrorStatus> joinQueue(Queue queue) async {
    String? userUID = _firebaseProvider.FIREBASE_AUTH.currentUser?.uid;
    if (userUID == null) {
      return ErrorStatus(success: false, message: "An error occurred: User not logged in");
    }
    if (queue.isFull()) {
      return ErrorStatus(success: false, message: "An error occurred: Queue is full");
    }
    if (!queue.open) {
      return ErrorStatus(success: false, message: "An error occurred: Queue is closed");
    }
    if (queue.users.indexWhere((element) => element.userId == userUID) != -1) {
      return ErrorStatus(success: false, message: "An error occurred: User already in queue");
    }

    final userReference = _firebaseProvider.FIREBASE_FIRESTORE.collection('users').doc(userUID);
    final name = await userReference.get().then((value) => value.data()?['name']);

    userReference.update({
      'feedbackPrompt': FieldValue.arrayUnion([queue.id]), // Add the queue ID to the user's feedback prompt list
    });

    final queueReference = _firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc(queue.id);
    queue.users.add(QueueUserEntry(userId: userUID, name: name, timestamp: DateTime.now().millisecondsSinceEpoch));
    await queueReference.update({'users': queue.users.map((e) => e.toJson()).toList()});

    return ErrorStatus(success: true);
  }

  List<int> getWaitTimes(Queue queue) {
    final logs = queue.logs;
    return logs.map((e) => e.end - e.start).toList();
  }

  int getMedianWaitTime(Queue queue) {
    final waitTimes = getWaitTimes(queue);
    if (waitTimes.isEmpty) {
      return 0;
    }
    waitTimes.sort();
    return waitTimes[waitTimes.length ~/ 2];
  }

  Future<ErrorStatus> leaveQueue(Queue queue) async {
    String? userUID = _firebaseProvider.FIREBASE_AUTH.currentUser?.uid;
    if (userUID == null) {
      return ErrorStatus(success: false, message: "An error occurred: User not logged in");
    }
    if (queue.users.indexWhere((element) => element.userId == userUID) == -1) {
      return ErrorStatus(success: false, message: "An error occurred: User not in queue");
    }

    // Add a log entry for the user leaving the queue
    final startTime = queue.users.firstWhere((element) => element.userId == userUID).timestamp;
    final endTime = DateTime.now().millisecondsSinceEpoch;

    final logs = queue.logs;
    logs.add(QueueLog(userId: userUID, start: startTime, end: endTime));

    final queueReference = _firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc(queue.id);
    queue.users.removeWhere((element) => element.userId == userUID);

    await queueReference.update({
      'users': queue.users.map((e) => e.toJson()).toList(),
      'logs': logs.map((e) => e.toJson()).toList(),
    });

    return ErrorStatus(success: true);
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

  Future<void> removeFeedbackPrompt(String queueId, String userId) {
    final userReference = _firebaseProvider.FIREBASE_FIRESTORE.collection('users').doc(userId);
    return userReference.update({
      'feedbackPrompt': FieldValue.arrayRemove([queueId])
    });
  }

  Future<ErrorStatus> submitFeedback(String queueId, FeedbackEntry entry) async {
    final userUID = _firebaseProvider.FIREBASE_AUTH.currentUser?.uid;
    if (userUID == null) {
      return ErrorStatus(success: false, message: "An error occurred: User not logged in");
    }

    final queueFeedbackRef = _firebaseProvider.FIREBASE_FIRESTORE.collection('feedback').doc(queueId);
    // Create a new document if it doesn't exist, otherwise update the existing document
    await queueFeedbackRef.set({
      'queueId': queueId,
      'ratings': [],
      'entries': [],
    }, SetOptions(merge: true));

    // Update the ratings and comments arrays with the new feedback
    await queueFeedbackRef.update({
      'ratings': FieldValue.arrayUnion([entry.rating]),
      'comments': FieldValue.arrayUnion([entry.toJson()]),
    });

    return ErrorStatus(success: true);
  }
}
