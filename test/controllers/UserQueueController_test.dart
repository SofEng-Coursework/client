import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
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
    });

    setUp(() {
      firebaseProvider.FIREBASE_AUTH.signOut();
    });

    test('is initialized', () {
      expect(userQueueController, isA<UserQueueController>());
    });

    test('join and leave queue', () async {
      // Creating a mock queue
      final fakeQueue = Queue(id: '1', name: 'test', open: true, users: []);
      await firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc('1').set(fakeQueue.toJson());

      // Joining the queue
      final joinResult = await userQueueController.joinQueue(fakeQueue);
      expect(joinResult, isNull);

      // Getting current queue
      final currentQueue = await userQueueController.getCurrentQueue().first;
      expect(currentQueue, isNotNull);
      expect(currentQueue!.id, '1');

      // Getting current queue position
      final currentPosition = await userQueueController.getCurrentQueuePosition().first;
      expect(currentPosition, 1);

      // Leaving the queue
      final leaveResult = await userQueueController.leaveQueue(currentQueue);
      expect(leaveResult, isNull);
    });

    test('get queues', () async {
      // Creating some mock queues
      final fakeQueue1 = Queue(id: '1', name: 'test1', open: true, users: []);
      final fakeQueue2 = Queue(id: '2', name: 'test2', open: true, users: []);
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
}