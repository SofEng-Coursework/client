import 'package:flutter/material.dart';
import 'package:virtual_queue/models/Queue.dart';
import 'package:virtual_queue/modules/InputVerifications.dart';

enum EventType { enter, exit }

/// This file contains functions that access the logs and creates stats for the admin stats page to display

class DataController extends ChangeNotifier {
  List<Duration> getWaitTimes(Queue queue) {
    final logs = queue.logs;
    return logs.map((e) => Duration(milliseconds: e.end - e.start)).toList();
  }

  Duration getMedianWaitTime(Queue queue) {
    final waitTimes = getWaitTimes(queue);
    if (waitTimes.isEmpty) {
      return Duration.zero;
    }
    waitTimes.sort();
    return waitTimes[waitTimes.length ~/ 2];
  }

  List<QueueLog> getLogsForHour(List<QueueLog> logsForDay, int hour) {
    if (checkValidHour(hour)) {
      return [];
    } else {
      return logsForDay.where((element) {
        final logDate = DateTime.fromMillisecondsSinceEpoch(element.start);
        return logDate.hour == hour;
      }).toList();
    }
  }

  List<QueueLog> getLogsForDate(Queue queue, DateTime date) {
    final logs = queue.logs;
    return logs.where((element) {
      final logDate = DateTime.fromMillisecondsSinceEpoch(element.start);
      return logDate.year == date.year && logDate.month == date.month && logDate.day == date.day;
    }).toList();
  }

  Duration getMedianWaitTimeForHour(List<QueueLog> logsForDay, int hour) {
    if (checkValidHour(hour)) {
      return Duration.zero;
    } else {
      final logsForHour = getLogsForHour(logsForDay, hour);
      final waitTimes = logsForHour.map((e) => Duration(milliseconds: e.end - e.start)).toList();
      if (waitTimes.isEmpty) {
        return Duration.zero;
      }
      waitTimes.sort();
      return waitTimes[waitTimes.length ~/ 2];
    }
  }

  Duration getMedianWaitTimeForDate(Queue queue, DateTime date) {
    final logsForDay = getLogsForDate(queue, date);
    final waitTimes = logsForDay.map((e) => Duration(milliseconds: e.end - e.start)).toList();
    if (waitTimes.isEmpty) {
      return Duration.zero;
    }
    waitTimes.sort();
    return waitTimes[waitTimes.length ~/ 2];
  }

  (int, int) getMinMaxQueueLengthForHour(List<QueueLog> logsForDay, int hour) {
    if (!validHour(hour)) return (0, 0);

    final logsForHour = getLogsForHour(logsForDay, hour);

    int minQueueLength = 0;
    int maxQueueLength = 0;
    int currentQueueLength = 0;

    /// Timeline sweep algorithm
    /// Create a list of events for the hour
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

    return (minQueueLength, maxQueueLength);
  }

  (int, int) getMinMaxQueueLengthForDate(Queue queue, DateTime date) {
    final logsForDay = getLogsForDate(queue, date);

    int minQueueLength = 0;
    int maxQueueLength = 0;
    int currentQueueLength = 0;

    /// Timeline sweep algorithm
    /// Create a list of events for the day
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

    return (minQueueLength, maxQueueLength);
  }

  String formatTime(int milliseconds) {
    final seconds = (milliseconds / 1000).round();
    final minutes = (seconds / 60).round();
    final hours = (minutes / 60).round();
    if (hours > 0) {
      return "$hours hours";
    }
    if (minutes > 0) {
      return "$minutes minutes";
    }
    return "$seconds seconds";
  }

  bool checkValidHour(int hour) {
    if (hour >= 0 && hour <= 24) {
      return true;
    } else {
      return false;
    }
  }
}
