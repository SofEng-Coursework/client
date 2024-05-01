import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_queue/controllers/AdminQueueController.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';
import 'package:virtual_queue/controllers/UserQueueController.dart';
import 'package:virtual_queue/controllers/adminAccountController.dart';
import 'package:virtual_queue/controllers/userAccountController.dart';
import 'package:virtual_queue/pages/RegisterForm.dart';
import 'package:virtual_queue/models/Queue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group("UserQueueController", () {
    late UserQueueController userQueueController;
    late UserAccountController userAccountController;
    late FirebaseProvider firebaseProvider;

    setUpAll(() async {
      firebaseProvider = FirebaseProvider();
      firebaseProvider.initializeMock();
      userQueueController = UserQueueController(firebaseProvider: firebaseProvider);

      // Must be signed in to join a queue
      userAccountController = UserAccountController(firebaseProvider: firebaseProvider);
      await userAccountController.signUp('email', 'password', 'name', 'phone');
    });

    test('is initialized', () {
      expect(userQueueController, isA<UserQueueController>());
    });

    test('join and leave queue', () async {
      // Creating a mock queue
      final fakeQueue = Queue(id: '1', name: 'test', open: true, users: [], logs: []);
      await firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc('1').set(fakeQueue.toJson());

      // Joining the queue
      final joinResult = await userQueueController.joinQueue(fakeQueue);
      print(joinResult.message);
      expect(joinResult.success, true);

      // Getting current queue
      final currentQueue = await userQueueController.getCurrentQueue().first;
      expect(currentQueue, isNotNull);
      expect(currentQueue!.id, '1');

      // Getting current queue position
      final currentPosition = await userQueueController.getCurrentQueuePosition().first;
      expect(currentPosition, 1);

      // Leaving the queue
      final leaveResult = await userQueueController.leaveQueue(currentQueue);
      expect(leaveResult.success, true);
    });

    test('get queues', () async {
      // Creating some mock queues
      final fakeQueue1 = Queue(id: '1', name: 'test1', open: true, users: [], logs: []);
      final fakeQueue2 = Queue(id: '2', name: 'test2', open: true, users: [], logs: []);
      await firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc('1').set(fakeQueue1.toJson());
      await firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc('2').set(fakeQueue2.toJson());

      // Getting queues
      final queuesStream = userQueueController.getQueues();
      final queues = await queuesStream.first;
      
      expect(queues.length, 2);
      expect(queues[0].id, '1');
      expect(queues[1].id, '2');
    });
  });

  group("AdminQueueController", () {
    late UserQueueController userQueueController;
    late AdminQueueController adminQueueController;
    late AdminAccountController adminAccountController;
    late FirebaseProvider firebaseProvider;

    setUpAll(() async {
      firebaseProvider = FirebaseProvider();
      firebaseProvider.initializeMock();
      userQueueController = UserQueueController(firebaseProvider: firebaseProvider);
      adminQueueController = AdminQueueController(firebaseProvider: firebaseProvider);
      
      // Must be signed in
      adminAccountController = AdminAccountController(firebaseProvider: firebaseProvider);
      await adminAccountController.signUp('email', 'password', 'name', 'phone');
    });

    test('is initialized', () {
      expect(adminQueueController, isA<AdminQueueController>());
    });

    test('add and delete queue', () async {
      // Adding a queue
      final addResult = await adminQueueController.addQueue('test', 10, '1');
      expect(addResult.success, true);

      // Getting queues
      final queuesStream = adminQueueController.getQueues();
      final queues = await queuesStream.first;
      print(firebaseProvider.FIREBASE_AUTH.currentUser);
      print(queues);
    });
  });
}