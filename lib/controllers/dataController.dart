import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';
import 'package:virtual_queue/models/ErrorStatus.dart';
import 'package:virtual_queue/models/Queue.dart';

class DataController extends ChangeNotifier {
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

}