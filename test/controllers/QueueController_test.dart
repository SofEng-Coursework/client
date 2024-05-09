import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_queue/controllers/AdminQueueController.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';
import 'package:virtual_queue/controllers/UserQueueController.dart';
import 'package:virtual_queue/controllers/adminAccountController.dart';
import 'package:virtual_queue/controllers/userAccountController.dart';
import 'package:virtual_queue/models/Queue.dart';
import 'package:virtual_queue/models/FeedbackEntry.dart';
import 'package:virtual_queue/models/ErrorStatus.dart';

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

    test('move user up', () async {
      // Adding a queue
      final addResult = await adminQueueController.addQueue('test', 10, uid);
      expect(addResult.success, true);

      // Getting queues
      var queuesStream = adminQueueController.getQueues();
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
      await adminQueueController.deleteQueue(newQueue);
    });

    test('move user down', () async {
      // Adding a queue
      final addResult = await adminQueueController.addQueue('test', 10, uid);
      expect(addResult.success, true);

      // Getting queues
      var queuesStream = adminQueueController.getQueues();
      final queues = await queuesStream.first;
      expect(queues.length, 1);

      final queue = queues[0];

      // Adding users to the queue
      await adminQueueController.addUserToQueue(queue, 'Steve');
      await adminQueueController.addUserToQueue(queue, 'John');
      await adminQueueController.addUserToQueue(queue, 'Alice');

      // Moving user down
      final statusDown = await adminQueueController.moveUserDown(queue, queue.users[0]);
      expect(statusDown.success, true);

      // Getting users in the queue
      final queuesAfterDown = await queuesStream.first;
      final newQueue = queuesAfterDown.first;
      final usersAfterDown = newQueue.users;
      expect(usersAfterDown.length, 3);
      expect(usersAfterDown[0].name, 'John');
      expect(usersAfterDown[1].name, 'Steve');
      expect(usersAfterDown[2].name, 'Alice');

      // Delete the queue
      await adminQueueController.deleteQueue(newQueue);
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

    test('cant move down last', () async {
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

      // Moving user down
      final statusDown = await adminQueueController.moveUserDown(queue, queue.users[2]);
      expect(statusDown.success, false);
      expect(statusDown.message, 'User is already at the bottom of the queue');

      // Delete the queue
      await adminQueueController.deleteQueue(queues[0]);
    });

    test('remove user from queue', () async {
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

      // Remove user from the queue
      var removeUser = await adminQueueController.removeUserFromQueue(queue, queue.users[0]);
      expect(removeUser.success, true, reason: removeUser.message);

      // Check queue length again to see if the user has been removed
      var updatedQueue = await adminQueueController.getQueue(queue.id).first;
      expect(updatedQueue.users.length, 0);
    });

    test('get a specific queue', () async {
      // Adding a queue
      final addResult = await adminQueueController.addQueue('test', 10, uid);
      expect(addResult.success, true);

      // Get the specific queue
      final queuesStream = adminQueueController.getQueues();
      final queues = await queuesStream.first;
      final queueResult = queues[0];
      expect(queueResult.name, 'test');
      expect(queueResult.capacity, 10);

      // Delete the queue
      await adminQueueController.deleteQueue(queueResult);
    });

    test('get feedback', () async {
      // Mock feedback entry
      FeedbackEntry mockFeedback = FeedbackEntry(
        userId: '1',
        name: 'test name',
        comments: 'test comment',
        rating: 5,
      );

      // Adding a queue
      final addResult = await adminQueueController.addQueue('test', 10, uid);
      expect(addResult.success, true);

      // Submitting the mock feedback
      final submitStatus = await userQueueController.submitFeedback(uid, mockFeedback);
      expect(submitStatus.success, true);

      // Getting feedback for the specific queue
      final feedbackStream = adminQueueController.getFeedback(uid);
      final feedbackList = await feedbackStream.first;

      // Validate that retrieved feedback is the same as the mock feedback
      expect(feedbackList.length, equals(1));
      expect(feedbackList[0].userId, equals(mockFeedback.userId));
      expect(feedbackList[0].name, equals(mockFeedback.name));
      expect(feedbackList[0].comments, equals(mockFeedback.comments));
      expect(feedbackList[0].rating, equals(mockFeedback.rating));
    });

    test('get feedback for invalid queue', () async {
      // Getting feedback for an invalid queue
      final feedbackStream = adminQueueController.getFeedback('invalid');
      final feedbackList = await feedbackStream.first;

      // Validate that no feedback is returned
      expect(feedbackList.length, equals(0));
    });
  });
}
