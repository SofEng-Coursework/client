import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_queue/controllers/AdminQueueController.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';
import 'package:virtual_queue/controllers/UserQueueController.dart';
import 'package:virtual_queue/pages/RegisterForm.dart';
import 'package:virtual_queue/models/Queue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group("UserQueueController", () {
    late UserQueueController userQueueController;
    late FirebaseProvider firebaseProvider;

    setUpAll(() {
      firebaseProvider = FirebaseProvider();
      firebaseProvider.initializeMock();
      userQueueController = UserQueueController(firebaseProvider: firebaseProvider);
      firebaseProvider.FIREBASE_AUTH.signInWithEmailAndPassword(email: 'test', password:'test');
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
    late FirebaseProvider firebaseProvider;

    setUpAll(() {
      firebaseProvider = FirebaseProvider();
      firebaseProvider.initializeMock();
      userQueueController = UserQueueController(firebaseProvider: firebaseProvider);
      adminQueueController = AdminQueueController(firebaseProvider: firebaseProvider);
    });

    setUp(() {
      firebaseProvider.FIREBASE_AUTH.signOut();
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
      expect(queues, isA<List<Queue>>());
      expect(queues.length, 1);
      expect(queues[0].name, 'test');

      // Deleting the queue
      final deleteResult = await adminQueueController.deleteQueue(queues[0]);
      expect(deleteResult.success, true);
      expect(queues.length, 0);
    });
  });
}