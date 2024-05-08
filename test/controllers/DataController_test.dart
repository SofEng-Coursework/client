import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';
import 'package:virtual_queue/controllers/AccountController.dart';
import 'package:virtual_queue/pages/RegisterForm.dart';
import 'package:virtual_queue/controllers/dataController.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:virtual_queue/models/Queue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group("DataController Get Wait Times", () {
    late DataController dataController;
    late Queue testQueue;

    setUpAll(() {
      // Initialize controller
      dataController = DataController();

      // Create test queue 
      QueueLog user1 = QueueLog(start: 0, end: 100, userId: "test1");
      QueueLog user2 = QueueLog(start: 50, end: 200, userId: "test2");
      QueueLog user3 = QueueLog(start: 60, end: 300, userId: "test3");
      QueueLog user4 = QueueLog(start: 120, end: 330, userId: "test4");
      QueueLog user5 = QueueLog(start: 160, end: 340, userId: "test5");
      QueueLog user6 = QueueLog(start: 200, end: 350, userId: "test6");
      testQueue = Queue(id: "1", name: "test", open: true, users: [], logs: [user1, user2, user3, user4, user5, user6], capacity: null);
    });

    test('correctly returns a list of wait times', () {
      List<QueueLog> logs = testQueue.logs;
      List times = [];
      for (int i = 0; i < 6; i++){
        times.add(Duration(milliseconds : (logs[i].end - logs[i].start)));
      }
      expect(dataController.getWaitTimes(testQueue), times);
    });

  });
}