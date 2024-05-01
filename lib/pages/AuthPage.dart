import 'package:flutter/material.dart';
import 'package:virtual_queue/pages/LoginForm.dart';
import 'package:virtual_queue/pages/RegisterForm.dart';

enum AuthPageType { SignIn, SignUp }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}
/// This is the page that allows the user to decide whether to login or signup and will then open the appropriate widget
class _AuthPageState extends State<AuthPage> {
  AuthPageType _authPageType = AuthPageType.SignIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _authPageType == AuthPageType.SignIn ? LoginForm() : RegisterForm(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_authPageType == AuthPageType.SignIn ? "Don't have an account?" : "Already have an account?"),
                TextButton(
                    onPressed: () {
                      setState(() {
                        _authPageType = _authPageType == AuthPageType.SignIn ? AuthPageType.SignUp : AuthPageType.SignIn;
                      });
                    },
                    child: Text(_authPageType == AuthPageType.SignIn ? "Sign Up" : "Sign In"))
              ],
            ),
          )
        ],
      )),
    );
  }
}
