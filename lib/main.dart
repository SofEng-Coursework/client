import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_queue/login.dart';
import 'package:virtual_queue/register.dart';
import 'package:virtual_queue/controllers/userAccountController.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // We're using the manual installation on non-web platforms since Google sign in plugin doesn't yet support Dart initialization.
  // See related issue: https://github.com/flutter/flutter/issues/96391

  // We store the app and auth to make testing with a named instance easier.
  final app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Starting');
  final auth = FirebaseAuth.instanceFor(app: app);
  runApp(MyApp(auth: auth));
}

class MyApp extends StatelessWidget {
  final FirebaseAuth auth;

  MyApp({required this.auth});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserAccountController(auth: auth),
      child: MaterialApp(
        home: SignUp(),
      ),
    );
  }
}
