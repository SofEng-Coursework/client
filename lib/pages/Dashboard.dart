import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_queue/controllers/adminAccountController.dart';
import 'package:virtual_queue/controllers/userAccountController.dart';
import 'package:virtual_queue/pages/RegisterForm.dart';
import 'package:virtual_queue/pages/userDashboard.dart';
import 'package:virtual_queue/pages/AdminDashboard.dart';

/// This is the barrier between the login / signup page and the user's dashboard
/// It will use [UserAccountController] and [AdminAccountController] to determine the type of user
/// It then uses this data to pass them to the appropriate dashboard page
class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  Future<Map<String, dynamic>?> getFirstNonNullUserData(
      UserAccountController userAccountController, AdminAccountController adminAccountController) async {
    final user = await userAccountController.getUserData();
    if (user != null) {
      return user;
    }
    final admin = await adminAccountController.getUserData();
    if (admin != null) {
      return admin;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final userAccountController = Provider.of<UserAccountController>(context, listen: false);
    final adminAccountController = Provider.of<AdminAccountController>(context, listen: false);
    return FutureBuilder(
        future: getFirstNonNullUserData(userAccountController, adminAccountController),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            AccountType accountType = snapshot.data!['accountType'];
            if (accountType == AccountType.Admin) {
              return AdminDashboard();
            }
            if (accountType == AccountType.User) {
              return UserDashboard();
            }
          }
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        });
  }
}
