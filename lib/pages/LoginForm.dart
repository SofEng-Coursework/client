import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_queue/controllers/userAccountController.dart';
import 'package:virtual_queue/pages/RegisterForm.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}
/// This builds the widget hosted on the [AuthPage] for logging into the user's account
class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  String? errorMesssage;

  String _email = '';
  String _password = '';

  @override
  void initState() {
    _passwordVisible = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Sign In",
            textAlign: TextAlign.start,
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              fontSize: 24,
              color: Color(0xff017a08),
            ),
          ),
        ),
        /// This Form is used to receive inputted data from the user and
        /// check that the data matches in a format that the system expects
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                onSaved: (value) {
                  _email = value!;
                },
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                onSaved: (value) {
                  _password = value!;
                },
                decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    )),
                obscureText: !_passwordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 16,
              ),
              if (errorMesssage != null)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Username or Password is incorrect", style: TextStyle(color: Colors.red)),
                ),
              ElevatedButton(
                  child: const Text('Sign In'),
                  onPressed: () async {
                    /// This will pass the login details to userAccountController
                    /// Which will then use firebase to validate and return either a success or error message
                    final userAccountController = Provider.of<UserAccountController>(context, listen: false);
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final error = await userAccountController.login(_email, _password);
                      setState(() {
                        errorMesssage = error.message;
                      });
                    }
                  }),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
