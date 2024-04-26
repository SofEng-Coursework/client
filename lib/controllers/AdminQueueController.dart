import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';
import 'package:virtual_queue/models/Queue.dart';

class AdminQueueController extends ChangeNotifier {
  late FirebaseProvider _firebaseProvider;
  AdminQueueController({required FirebaseProvider firebaseProvider}) {
    _firebaseProvider = firebaseProvider;
  }

  /// Adds a new queue to the Firestore database
  Future<String?> addQueue(String name, int? capacity, String owner) async {
    CollectionReference collection = _firebaseProvider.FIREBASE_FIRESTORE.collection('queues');
    final id = collection.doc().id;
    await collection.doc(id).set({'id': id, 'name': name, 'open': true, 'capacity': capacity, 'owner': owner, 'users': []});
    return null;
  }

  /// Returns a Stream of all queues owned by the current admin
  Stream<List<Queue>> getQueues() {
    final adminUID = _firebaseProvider.FIREBASE_AUTH.currentUser!.uid;

    return _firebaseProvider.FIREBASE_FIRESTORE
        .collection('queues')
        .where('owner', isEqualTo: adminUID)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Queue.fromJson(doc.data())).toList());
  }

  /// Toggle the open status of a queue
  Future<String?> toggleQueueOpenStatus(Queue queue) async {
    final queueReference = _firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc(queue.id);
    await queueReference.update({
      'open': !queue.open,
    });

    // If the queue is being closed, remove all users from the queue
    if (queue.open) {
      await queueReference.update({
        'users': [],
      });
    }
    return null;
  }

  /// Deletes a queue from the Firestore database
  Future<String?> deleteQueue(Queue queue) async {
    final queueReference = _firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc(queue.id);
    await queueReference.delete();
    return null;
  }

  /// Get list of people in a queue
  Future<List<String>> getUsersInQueue(Queue queue) async {
    final queueReference = _firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc(queue.id);
    final queueData = await queueReference.get();
    final users = queueData.data()!['users'] as List<dynamic>;
    return users.map((e) => e['name'] as String).toList();
  }

  Stream<Queue> getQueue(String queueID) {
    return _firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc(queueID).snapshots().map((doc) => Queue.fromJson(doc.data()!));
  }

  Future<void> removeUserFromQueue(Queue queue, QueueUserEntry user) async {
    final queueReference = _firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc(queue.id);
    final queueData = await queueReference.get();
    final users = queueData.data()!['users'] as List<dynamic>;
    users.removeWhere((element) => element['userId'] == user.userId);
    await queueReference.update({
      'users': users,
    });
  }
}
