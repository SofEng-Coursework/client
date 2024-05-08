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
      QueueLog user1 = QueueLog(
          start: DateTime.utc(2024, 5, 4, 10, 14).millisecondsSinceEpoch,
          end: DateTime.utc(2024, 5, 4, 10, 16).millisecondsSinceEpoch,
          userId: "test1");
      QueueLog user2 = QueueLog(
          start: DateTime.utc(2024, 5, 4, 10, 14).millisecondsSinceEpoch,
          end: DateTime.utc(2024, 5, 4, 10, 18).millisecondsSinceEpoch,
          userId: "test2");
      QueueLog user3 = QueueLog(
          start: DateTime.utc(2024, 5, 4, 10, 16).millisecondsSinceEpoch,
          end: DateTime.utc(2024, 5, 4, 10, 18).millisecondsSinceEpoch,
          userId: "test3");
      QueueLog user4 = QueueLog(
          start: DateTime.utc(2024, 5, 4, 10, 18).millisecondsSinceEpoch,
          end: DateTime.utc(2024, 5, 4, 10, 19).millisecondsSinceEpoch,
          userId: "test5");
      QueueLog user5 = QueueLog(
          start: DateTime.utc(2024, 5, 4, 10, 20).millisecondsSinceEpoch,
          end: DateTime.utc(2024, 5, 4, 10, 21).millisecondsSinceEpoch,
          userId: "test6");
      QueueLog user6 = QueueLog(
          start: DateTime.utc(2024, 5, 4, 10, 20).millisecondsSinceEpoch,
          end: DateTime.utc(2024, 5, 4, 10, 22).millisecondsSinceEpoch,
          userId: "test6");
      testQueue = Queue(
          id: "1",
          name: "test",
          open: true,
          users: [],
          logs: [user1, user2, user3, user4, user5, user6],
          capacity: null);
    });

    test('correctly returns a list of wait times', () {
      List<QueueLog> logs = testQueue.logs;
      List times = [];
      for (int i = 0; i < 6; i++) {
        times.add(Duration(milliseconds: (logs[i].end - logs[i].start)));
      }
      expect(dataController.getWaitTimes(testQueue), times);
    });

    test('correctly returns the median wait time', () {
      List<QueueLog> logs = testQueue.logs;
      List times = [];
      for (int i = 0; i < 6; i++) {
        times.add(logs[i].end - logs[i].start);
      }
      times.sort();
      int median = times[times.length ~/ 2];
      expect(dataController.getMedianWaitTime(testQueue),
          Duration(milliseconds: median));
    });

    test('correctly returns the hourly time logs', () {
      List<QueueLog> logs = testQueue.logs;
      int testHour = 9;

      List logsForHour = logs.where((element) {
        final logDate = DateTime.fromMillisecondsSinceEpoch(element.start);
        return logDate.hour == testHour;
      }).toList();

      expect(dataController.getLogsForHour(logs, testHour), logsForHour);
    });

    test('correctly returns the daily time logs', () {
      List<QueueLog> logs = testQueue.logs;
      DateTime testDate = DateTime.utc(2024, 5, 4);

      List logsForDate = logs.where((element) {
        final logDate = DateTime.fromMillisecondsSinceEpoch(element.start);
        return logDate.year == testDate.year &&
            logDate.month == testDate.month &&
            logDate.day == testDate.day;
      }).toList();

      expect(dataController.getLogsForDate(testQueue, testDate), logsForDate);
    });

    test('correctly returns median wait time for the hour', () {
      List<QueueLog> logs = testQueue.logs;
      int testHour = 14;
      List logsForHour = dataController.getLogsForHour(logs, testHour);
      var median = Duration.zero;
      if (logsForHour.isNotEmpty) {
        logsForHour.sort();
        median = logsForHour[logsForHour.length ~/ 2];
      }
      expect(dataController.getMedianWaitTimeForHour(logs, testHour), median);
    });

    test('correctly returns median wait time for the date', () {
      DateTime testDate = DateTime.utc(2024, 5, 4);
      List logsForDate = dataController.getLogsForDate(testQueue, testDate);
      List times = logsForDate
          .map((e) => Duration(milliseconds: e.end - e.start))
          .toList();
      var median = Duration.zero;
      if (times.isNotEmpty) {
        times.sort();
        median = times[times.length ~/ 2];
      }
      expect(
          dataController.getMedianWaitTimeForDate(testQueue, testDate), median);
    });

    test('correctly returns minimum and maximum wait times for the hour', () {
      List<QueueLog> logs = testQueue.logs;
      DateTime testDate = DateTime.utc(2024, 5, 4, 14);
      int testHour = testDate.hour;
      List<QueueLog> logsForHour =
          dataController.getLogsForHour(logs, testHour);

      // get the min and max from the test data
      int minQueueLength = 0;
      int maxQueueLength = 0;
      int currentQueueLength = 0;

      final List<(EventType, int)> eventTimes = [];
      for (final log in logsForHour) {
        eventTimes.add((EventType.enter, log.start));
        eventTimes.add((EventType.exit, log.end));
      }
      eventTimes.sort((a, b) => a.$2.compareTo(b.$2));

      for (final event in eventTimes) {
        if (event.$1 == EventType.enter) {
          currentQueueLength++;
          if (currentQueueLength > maxQueueLength) {
            maxQueueLength = currentQueueLength;
          }
        } else {
          currentQueueLength--;
          if (currentQueueLength < minQueueLength) {
            minQueueLength = currentQueueLength;
          }
        }
      }

      expect(dataController.getMinMaxQueueLengthForHour(logsForHour, testHour),
          (minQueueLength, maxQueueLength));
    });

    test('correctly returns minimum and maximum wait times for the hour', () {
      DateTime testDate = DateTime.utc(2024, 5, 4, 14);
      List<QueueLog> logsForDay =
          dataController.getLogsForDate(testQueue, testDate);

      // get the min and max from the test data
      int minQueueLength = 0;
    int maxQueueLength = 0;
    int currentQueueLength = 0;

      final List<(EventType, int)> eventTimes = [];
    for (final log in logsForDay) {
      eventTimes.add((EventType.enter, log.start));
      eventTimes.add((EventType.exit, log.end));
    }
    eventTimes.sort((a, b) => a.$2.compareTo(b.$2));

    for (final event in eventTimes) {
      if (event.$1 == EventType.enter) {
        currentQueueLength++;
        if (currentQueueLength > maxQueueLength) {
          maxQueueLength = currentQueueLength;
        }
      } else {
        currentQueueLength--;
        if (currentQueueLength < minQueueLength) {
          minQueueLength = currentQueueLength;
        }
      }
    }

      expect(dataController.getMinMaxQueueLengthForDate(testQueue, testDate),
          (minQueueLength, maxQueueLength));
    });

    test('correctly formats time', () {
      int secondsTestLessThan30 = 20000;
      int secondsTestGreaterThan30 = 40000;
      int minutesTestLessThan30 = 300000;
      int minutesTestGreaterThan30 = 2400000;
      int hoursTest = 7200000;

      int seconds1 = (secondsTestLessThan30 / 1000).round();
      int seconds2 = (secondsTestGreaterThan30 / 60000).round();
      int minutes1 = (minutesTestLessThan30 / 60000).round();
      int minutes2 = (minutesTestGreaterThan30 / 3600000).round();
      int hours = (hoursTest / 3600000).round();

      expect(dataController.formatTime(secondsTestLessThan30), "$seconds1 seconds");
      expect(dataController.formatTime(secondsTestGreaterThan30), "$seconds2 minutes");
      expect(dataController.formatTime(minutesTestLessThan30), "$minutes1 minutes");
      expect(dataController.formatTime(minutesTestGreaterThan30), "$minutes2 hours");
      expect(dataController.formatTime(hoursTest), "$hours hours");
    });
  });
}
