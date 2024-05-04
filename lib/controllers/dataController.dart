import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';
import 'package:virtual_queue/models/ErrorStatus.dart';
import 'package:virtual_queue/models/Queue.dart';

class DataController extends ChangeNotifier {
  late FirebaseProvider _firebaseProvider;
  AdminQueueController({required FirebaseProvider firebaseProvider}) {
    _firebaseProvider = firebaseProvider;
  }

  List<int> getWaitTimes(Queue queue) {
    final logs = queue.logs;
    return logs.map((e) => e.end - e.start).toList();
  }

  int getMedianWaitTime(Queue queue) {
    final waitTimes = getWaitTimes(queue);
    if (waitTimes.isEmpty) {
      return 0;
    }
    waitTimes.sort();
    return waitTimes[waitTimes.length ~/ 2];
  }

  List<double> getDayData(Queue queue) {
    final logs = queue.logs;
    List<int> times = logs.map((e) => e.start).toList();
    int dayNow = DateTime.now().day;

    Map<int, double> listOfTimes = {for (var hour in List<int>.generate(24, (i) => i)) hour: 0};

    for (int time in times) {
      int hour = DateTime.fromMillisecondsSinceEpoch(time).hour;
      int day = DateTime.fromMillisecondsSinceEpoch(time).day;
      if (dayNow == day) {
        listOfTimes.update(hour, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    return listOfTimes.values.toList();
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
}