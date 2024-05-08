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

  group("User functionality", () {
    late UserQueueController userQueueController;
    late UserAccountController userAccountController;
    late FirebaseProvider firebaseProvider;

    setUpAll(() async {
      // Initialize Firebase mock
      firebaseProvider = FirebaseProvider();
      await firebaseProvider.initializeMock();

      // Initialize controller
      userQueueController = UserQueueController(firebaseProvider: firebaseProvider);
      userAccountController = UserAccountController(firebaseProvider: firebaseProvider);
    });

    setUp(() async {
      // Sign in before each test
      await userAccountController.signUp('email@email.com', 'password', 'name', '07123456789');
    });

    tearDown(() async {
      // Sign out after each test
      await firebaseProvider.FIREBASE_AUTH.currentUser?.delete();
    });

    test('is initialized', () {
      expect(userQueueController, isA<UserQueueController>());
    });

    test('join and leave queue', () async {
      // Creating a mock queue
      final fakeQueue = Queue(id: '1', name: 'test', open: true, users: [], logs: []);
      firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc('1').set(fakeQueue.toJson());

      // Joining the queue
      final joinResult = await userQueueController.joinQueue(fakeQueue);
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

    test('cant join a full queue', () async {
      // Creating a mock queue
      final fakeQueue = Queue(id: '1', name: 'test', open: true, users: [], logs: [], capacity: 0);
      firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc('1').set(fakeQueue.toJson());

      // Joining the queue
      final status = await userQueueController.joinQueue(fakeQueue);
      expect(status.success, false);
      expect(status.message, contains('Queue is full'));
    });

    test('cant join a closed queue', () async {
      // Creating a mock queue
      final fakeQueue = Queue(id: '1', name: 'test', open: false, users: [], logs: []);
      firebaseProvider.FIREBASE_FIRESTORE.collection('queues').doc('1').set(fakeQueue.toJson());

      // Joining the queue
      final status = await userQueueController.joinQueue(fakeQueue);
      expect(status.success, false);
      expect(status.message, contains('Queue is closed'));
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

  group("Admin functionality", () {
    late UserQueueController userQueueController;
    late AdminQueueController adminQueueController;
    late AdminAccountController adminAccountController;
    late FirebaseProvider firebaseProvider;

    late String uid;

    setUpAll(() async {
      firebaseProvider = FirebaseProvider();
      firebaseProvider.initializeMock();
      userQueueController = UserQueueController(firebaseProvider: firebaseProvider);
      adminQueueController = AdminQueueController(firebaseProvider: firebaseProvider);

      // Must be signed in
      adminAccountController = AdminAccountController(firebaseProvider: firebaseProvider);
    });

    setUp(() async {
      // Sign in before each test
      await adminAccountController.signUp('email@email.com', 'password', 'name', '07123456789');
      uid = (await adminAccountController.getUserData())!['uid'];
    });

    tearDown(() async {
      // Sign out after each test
      await firebaseProvider.FIREBASE_AUTH.currentUser?.delete();
    });

    test('is initialized', () {
      expect(adminQueueController, isA<AdminQueueController>());
    });

    test('add and delete queue', () async {
      // Adding a queue
      final addResult = await adminQueueController.addQueue('test', 10, uid);
      expect(addResult.success, true);

      // Getting queues
      final queuesStream = adminQueueController.getQueues();
      final queues = await queuesStream.first;
      expect(queues.length, 1);
      expect(queues[0].name, 'test');

      // Deleting the queue
      final deleteResult = await adminQueueController.deleteQueue(queues[0]);
      expect(deleteResult.success, true);

      // Getting queues after deletion
      final queuesStreamAfterDeletion = adminQueueController.getQueues();
      final queuesAfterDeletion = await queuesStreamAfterDeletion.first;
      expect(queuesAfterDeletion.length, 0);
    });

    test('toggle queue open', () async {
      // Adding a queue
      final addResult = await adminQueueController.addQueue('test', 10, uid);
      expect(addResult.success, true);

      // Getting queues
      final queuesStream = adminQueueController.getQueues();
      final queues = await queuesStream.first;
      expect(queues.length, 1);
      expect(queues[0].open, true);

      // Toggling the queue open status
      final toggleResult = await adminQueueController.toggleQueueOpenStatus(queues[0]);
      expect(toggleResult.success, true);

      // Getting queues after toggling
      final queuesStreamAfterToggle = adminQueueController.getQueues();
      final queuesAfterToggle = await queuesStreamAfterToggle.first;
      expect(queuesAfterToggle.length, 1);
      expect(queuesAfterToggle[0].open, false);

      // Delete the queue
      await adminQueueController.deleteQueue(queues[0]);
    });

    test('add user to queue', () async {
      // Adding a queue
      final addResult = await adminQueueController.addQueue('test', 10, uid);
      expect(addResult.success, true);

      // Getting queues
      final queuesStream = adminQueueController.getQueues();
      final queues = await queuesStream.first;
      expect(queues.length, 1);

      // Adding a user to the queue
      final status = await adminQueueController.addUserToQueue(queues[0], 'Steve');
      expect(status.success, true);

      // Getting users in the queue
      final newQueues = await queuesStream.first;
      final newQueue = newQueues.first;
      final users = newQueue.users;
      expect(users.length, 1);
      expect(users[0].name, 'Steve');

      // Delete the queue
      await adminQueueController.deleteQueue(queues[0]);
    });

    test('move user up and down', () async {
      // Adding a queue
      final addResult = await adminQueueController.addQueue('test', 10, uid);
      expect(addResult.success, true);

      // Getting queues
      final queuesStream = adminQueueController.getQueues();
      final queues = await queuesStream.first;
      expect(queues.length, 1);

      final queue = queues[0];

      // Adding users to the queue
      await adminQueueController.addUserToQueue(queue, 'Steve');
      await adminQueueController.addUserToQueue(queue, 'John');
      await adminQueueController.addUserToQueue(queue, 'Alice');

      // Moving user up
      final statusUp = await adminQueueController.moveUserUp(queue, queue.users[1]);
      expect(statusUp.success, true);

      // Getting users in the queue
      final queuesAferUp = await queuesStream.first;
      final newQueue = queuesAferUp.first;
      final usersAfterUp = newQueue.users;
      expect(usersAfterUp.length, 3);
      expect(usersAfterUp[0].name, 'John');
      expect(usersAfterUp[1].name, 'Steve');
      expect(usersAfterUp[2].name, 'Alice');

      // Delete the queue
      await adminQueueController.deleteQueue(queues[0]);
    });

    test('cant move up first', () async {
      // Adding a queue
      final addResult = await adminQueueController.addQueue('test', 10, uid);
      expect(addResult.success, true);

      // Getting queues
      final queuesStream = adminQueueController.getQueues();
      final queues = await queuesStream.first;
      expect(queues.length, 1);

      final queue = queues[0];

      // Adding users to the queue
      await adminQueueController.addUserToQueue(queue, 'Steve');
      await adminQueueController.addUserToQueue(queue, 'John');
      await adminQueueController.addUserToQueue(queue, 'Alice');

      // Moving user up
      final statusUp = await adminQueueController.moveUserUp(queue, queue.users[0]);
      expect(statusUp.success, false);
      expect(statusUp.message, 'User is already at the top of the queue');

      // Delete the queue
      await adminQueueController.deleteQueue(queues[0]);
    });
  });
}
