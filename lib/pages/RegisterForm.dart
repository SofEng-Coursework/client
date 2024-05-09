import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_queue/controllers/adminAccountController.dart';
import 'package:virtual_queue/controllers/userAccountController.dart';
import 'package:virtual_queue/modules/InputVerifications.dart';

enum AccountType { User, Admin }

/// This builds the widget hosted on the [AuthPage] for registering a new user
class RegisterForm extends StatefulWidget {
  const RegisterForm({
    super.key,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  AccountType _accountType = AccountType.User;

  String? errorMesssage;

  String _email = '';
  String _password = '';
  String _name = '';
  String _phone = '';

  @override
  void initState() {
    _passwordVisible = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Sign Up",
          textAlign: TextAlign.start,
          overflow: TextOverflow.clip,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 24,
            color: Color(0xff017a08),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                  label: Text("User"),
                  selected: _accountType == AccountType.User,
                  onSelected: (selected) {
                    setState(() {
                      _accountType = AccountType.User;
                    });
                  }),
              SizedBox(
                width: 16,
              ),
              ChoiceChip(
                  label: Text("Admin"),
                  selected: _accountType == AccountType.Admin,
                  onSelected: (selected) {
                    setState(() {
                      _accountType = AccountType.Admin;
                    });
                  }),
            ],
          ),
        ),

        /// This is the area where all inputs are gathered and validated before being submitted to firebase
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              /// This section will take a string and confirm it is a valid email
              TextFormField(
                onSaved: (value) {
                  _email = value!;
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!validEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 16,
              ),

              /// This section will take a password and confirm it has at least 6 characters
              TextFormField(
                onSaved: (value) {
                  _password = value!;
                },
                decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
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
                  if (!validPassword(value)) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 16,
              ),

              /// This will take the user or company name
              TextFormField(
                onSaved: (value) {
                  _name = value!;
                },
                decoration: InputDecoration(
                  labelText: _accountType == AccountType.Admin ? "Business Name" : 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your ${_accountType == AccountType.Admin ? "business " : ""}name';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 16,
              ),

              /// This section will take a phone number and ensure it is valid
              TextFormField(
                onSaved: (value) {
                  _phone = value!;
                },
                decoration: InputDecoration(labelText: 'Phone', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!validPhone(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 16,
              ),

              /// This section will check that there are no errors within the data before uploading the data to firebase
              if (errorMesssage != null)
                Padding(padding: EdgeInsets.all(8), child: Text(errorMesssage!, style: TextStyle(color: Colors.red))),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    if (_accountType == AccountType.User) {
                      final errStatus = await Provider.of<UserAccountController>(context, listen: false).signUp(
                        _email,
                        _password,
                        _name,
                        _phone,
                      );
                      if (mounted) {
                        setState(() {
                          errorMesssage = errStatus.message;
                        });
                      }
                    } else {
                      final errStatus =
                          await Provider.of<AdminAccountController>(context, listen: false).signUp(_email, _password, _name, _phone);
                      if (mounted) {
                        setState(() {
                          errorMesssage = errStatus.message;
                        });
                      }
                    }
                  }
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
