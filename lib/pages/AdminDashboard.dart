


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_queue/controllers/adminAccountController.dart';
import 'package:virtual_queue/pages/Settings.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    final adminAccountController = Provider.of<AdminAccountController>(context, listen: false);
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff017a08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.logout,
            color: Color(0xffffffff),
            size: 24,
          ),
          onPressed: () {
            Provider.of<AdminAccountController>(context, listen: false).signOut();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            color: Color(0xffffffff),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      ChangeNotifierProvider<AdminAccountController>(create: (context) => adminAccountController, child: Settings())));
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 20),
                child: Text(
                  "This will be graphs and pie charts and other forms of data visualisation!!!",
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontSize: 56,
                    color: Color(0xff272727),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
