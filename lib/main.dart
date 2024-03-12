import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_queue/controllers/AdminAccountController.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';
import 'package:virtual_queue/pages/AuthPage.dart';
import 'package:virtual_queue/pages/LoginForm.dart';
import 'package:virtual_queue/pages/RegisterForm.dart';
import 'package:virtual_queue/controllers/UserAccountController.dart';

import 'firebase_options.dart';
import 'pages/userDashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseProvider firebaseProvider = FirebaseProvider();
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FirebaseProvider>(
      create: (context) => FirebaseProvider(),
      child: MaterialApp(home: FirebaseLoadingWidget()),
    );
  }
}

class FirebaseLoadingWidget extends StatelessWidget {
  const FirebaseLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseProvider = Provider.of<FirebaseProvider>(context, listen: false);
    return FutureBuilder<void>(
      future: firebaseProvider.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<UserAccountController>(
                create: (context) => UserAccountController(firebaseProvider: firebaseProvider),
              ),
              ChangeNotifierProvider(create: (context) => AdminAccountController(firebaseProvider: firebaseProvider))
            ],
            child: Consumer<FirebaseProvider>(builder: (context, firebaseProvider, child) {
              return AnimatedSwitcher(
                  duration: Duration(milliseconds: 400), child: firebaseProvider.getLoggedInUser() != null ? Dashboard() : AuthPage());
            }),
          );
        }
        return LoadingScreen();
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
          Text(
            'Loading',
            style: TextStyle(fontSize: 20),
          ),
        ]),
      ),
    );
  }
}
