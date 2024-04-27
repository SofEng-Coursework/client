import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';
import 'package:virtual_queue/models/ErrorStatus.dart';
import 'package:virtual_queue/models/Queue.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

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

  Future<ErrorStatus> addUserToQueue(Queue queue, String user) async {
    if (user.isEmpty) {
      return ErrorStatus(success: false, message: 'Name cannot be empty');
    }
    final queueReference = _firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc(queue.id);
    final queueData = await queueReference.get();
    final capacity = queueData.data()!['capacity'];
    final currentQueueLength = queue.users.length;

    if (capacity == null || currentQueueLength < capacity) {
      final uid = uuid.v1();
      queue.users.add(QueueUserEntry(userId: uid, name: user, timestamp: DateTime.now().millisecondsSinceEpoch));
      await queueReference.update({'users': queue.users.map((e) => e.toJson()).toList()});
      return ErrorStatus(success: true);
    }
    return ErrorStatus(success: false, message: 'Queue is full');
  }

  Future<void> moveUserUp(Queue queue, QueueUserEntry user) async{
    final queueReference = _firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc(queue.id);
    final queueData = await queueReference.get();
    final users = queueData.data()!['users'];
    int indexOfUser = 0;
    
    for (int i = 0; i < users.length; i++) {
      if (users[i]["userId"] == user.userId){
        indexOfUser = i;
        break;
      }
    }

    if (indexOfUser > 0) {
      var aboveUser = users[indexOfUser - 1];
      users[indexOfUser] = aboveUser;
      users[indexOfUser - 1] = {"name": user.name, "timestamp": user.timestamp, "userId": user.userId};
      await queueReference.update({'users': users});
    }
    
  }

  Future<void> moveUserDown(Queue queue, QueueUserEntry user) async{
    final queueReference = _firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc(queue.id);
    final queueData = await queueReference.get();
    final users = queueData.data()!['users'];
    int indexOfUser = 0;
    
    for (int i = 0; i < users.length; i++) {
      if (users[i]["userId"] == user.userId){
        indexOfUser = i;
        break;
      }
    }

    if (indexOfUser < users.length - 1) {
      var aboveUser = users[indexOfUser + 1];
      users[indexOfUser] = aboveUser;
      users[indexOfUser + 1] = {"name": user.name, "timestamp": user.timestamp, "userId": user.userId};
      await queueReference.update({'users': users});
    }
    
  }
}
