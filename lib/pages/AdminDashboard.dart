import 'package:cloud_firestore/cloud_firestore.dart';
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

  TextEditingController name = TextEditingController();
  TextEditingController capacity = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final adminAccountController = Provider.of<AdminAccountController>(context, listen: false);
    final adminQueueController = Provider.of<AdminQueueController>(context, listen: false);
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
          // Button to add a new queue
          IconButton(
            icon: Icon(Icons.add),
            color: Color(0xffffffff),
            onPressed: () {
              showDialog(
                context: context, 
                builder: (context) => QueueCreatorDialog(
                  onSubmit: (String name, int? capacity) {
                    adminAccountController.getUserData().then((data) {
                      if (data == null) {
                        print('Error getting user data');
                      }
                      adminQueueController.addQueue(name, capacity, data!['uid']);                   
                    });
                  }
                )
              );
            },
          ),

          // Button to navigate to the admin account settings page
          // IconButton(
          //   icon: Icon(Icons.settings),
          //   color: Color(0xffffffff),
          //   onPressed: () {
          //     Navigator.of(context).push(MaterialPageRoute(
          //         builder: (context) =>
          //             ChangeNotifierProvider<AdminAccountController>(create: (context) => adminAccountController, child: Settings())));
          //   },
          // ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              AdminQueueList(),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminQueueList extends StatelessWidget {
  const AdminQueueList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 16, 0, 20),
      child: StreamBuilder(
        stream: Provider.of<AdminQueueController>(context, listen: false).getQueues(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No queues found'));
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              final queueData = snapshot.data!.docs[index];
              return Card(
                child: InkWell(
                  onTap: () {
                    // TODO: Navigate to queue progress page
                  },
                  child: ListTile(
                    title: Row(
                      children: [
                        Text(queueData['name']),
                        if (queueData['open']) Icon(Icons.check, color: Colors.green),
                        if (!queueData['open']) Icon(Icons.close, color: Colors.red),
                      ],
                    ),
                    subtitle: Text(queueData['capacity'] == null ? 'Unlimited' : 'Capacity: ${queueData['capacity']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(queueData['open'] ? Icons.lock : Icons.lock_open),
                          onPressed: () {
                            queueData.reference.update({'open': !queueData['open']});
                          }
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            queueData.reference.delete();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// A dialog that allows the user to create a new queue
/// Takes an [onSubmit] callback that is called when the user submits the form
/// The callback takes a String [name] and an optional int [capacity]
class QueueCreatorDialog extends StatefulWidget {
  final Function(String name, int? capacity) onSubmit;

  const QueueCreatorDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<QueueCreatorDialog> createState() => _QueueCreatorDialogState();
}

class _QueueCreatorDialogState extends State<QueueCreatorDialog> {
  final nameController = TextEditingController();
  final capacityController = TextEditingController();

  bool isUnlimitedCapacity = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create New Queue'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'Enter Queue Name'),
            controller: nameController,
          ),
          CheckboxListTile(
              title: const Text('Unlimited Capacity'),
              value: isUnlimitedCapacity,
              onChanged: (bool? value) {
                setState(() {
                  isUnlimitedCapacity = value!;
                });
              },
          ),
    
          if (!isUnlimitedCapacity) TextField(
            keyboardType: TextInputType.number,
            autofocus: false,
            decoration: const InputDecoration(hintText: 'Enter Max Users',),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            controller: capacityController,   
          )
        ]
      ),

      actions: [
        TextButton(
            child: Text("SUBMIT"),
            onPressed: () {
              String name = nameController.text;
              if (name.isEmpty) {
                return;
              }

              int? capacity = isUnlimitedCapacity ? null : int.tryParse(capacityController.text);

              widget.onSubmit(name, capacity);

              Navigator.of(context).pop();
            }
        ),
      ],
    );
  }
}
