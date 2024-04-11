


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:virtual_queue/controllers/adminAccountController.dart';
import 'package:virtual_queue/pages/Settings.dart';
import 'package:virtual_queue/controllers/AdminQueueController.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({
    super.key
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  TextEditingController name = new TextEditingController();
  TextEditingController capacity = new TextEditingController();

  bool ischecked = true;

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
            icon: Icon(Icons.add),
            color: Color(0xffffffff),
            onPressed: () {
              newQueue(context);
            },
          ),
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
                  "This will be where the queue cards live!!!",
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
  Future newQueue(BuildContext context) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Create New Queue'),
      content: StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                autofocus: true,
                decoration: InputDecoration(hintText: 'Enter Queue Name'),
                controller: name,
              ),
              CheckboxListTile(
                  title: const Text('Unlimited Capacity'),
                  value: ischecked,
                  onChanged: (bool? value) {
                    setState(() {
                      ischecked = value!;
                    });

                  },
              ),

              if (!ischecked) TextField(
                keyboardType: TextInputType.number,

                autofocus: false,
                decoration: const InputDecoration(hintText: 'Enter Max Users',),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                controller: capacity,

              )
            ]

        );
      }
      ),


      actions: [
        TextButton(
            child: Text("SUBMIT"),
            onPressed: () {
              uploadNewQueue(name,capacity,"The admin UID, need to create admin version of getData");
              Navigator.of(context).pop();
            }
        ),
      ],
    ),
  );

  void uploadNewQueue(name,capacity,owner) {
    final adminQueueController = Provider.of<QueueController>(context, listen: false);
    adminQueueController.addQueue(name,capacity,owner);
  }
}
