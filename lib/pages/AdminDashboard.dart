import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:virtual_queue/controllers/adminAccountController.dart';
import 'package:virtual_queue/controllers/dataController.dart';
import 'package:virtual_queue/models/Queue.dart';
import 'package:virtual_queue/pages/AdminQueueProgress.dart';
import 'package:virtual_queue/pages/QueueStats.dart';
import 'package:virtual_queue/pages/settings.dart';
import 'package:virtual_queue/controllers/AdminQueueController.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

/// This will build the main screen for the admin to view and access their queues
class _AdminDashboardState extends State<AdminDashboard> {
  TextEditingController name = TextEditingController();
  TextEditingController capacity = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final adminAccountController = Provider.of<AdminAccountController>(context, listen: false);
    final adminQueueController = Provider.of<AdminQueueController>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff017a08),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),

        /// Button to logout and send User back to the menu
        leading: IconButton(
          icon: const Icon(
            Icons.logout,
            color: Color(0xffffffff),
            size: 24,
          ),
          onPressed: () {
            Provider.of<AdminAccountController>(context, listen: false).signOut();
          },
        ),
        actions: [
          /// Button to add a new queue
          IconButton(
            icon: const Icon(Icons.add),
            color: const Color(0xffffffff),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => QueueCreatorDialog(onSubmit: (String name, int? capacity) {
                        adminAccountController.getUserData().then((data) {
                          if (data == null) {
                            print('Error getting user data');
                          }
                          adminQueueController.addQueue(name, capacity, data!['uid']);
                        });
                      }));
            },
          ),

          IconButton(
            icon: Icon(Icons.settings),
            color: Color(0xffffffff),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Scaffold(
                        backgroundColor: Color(0xffffffff),
                        appBar: AppBar(
                          elevation: 0,
                          centerTitle: true,
                          automaticallyImplyLeading: false,
                          backgroundColor: Color(0xff017a08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          title: Text(
                            "Settings",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                              fontSize: 20,
                              color: Color(0xffffffff),
                            ),
                          ),
                          leading: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Color(0xffffffff),
                              size: 24,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        body: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              AccountDetailsEditWidget(
                                accountController: adminAccountController,
                              ),
                              SignOutButton(
                                accountController: adminAccountController,
                              ),
                              DeleteAccountButton(
                                accountController: adminAccountController,
                              ),
                              SizedBox(
                                height: 16,
                                width: 16,
                              ),
                            ],
                          ),
                        ),
                      )));
            },
          ),
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

  /// This is a Widget that lists the queues owned by the User and allows them to be accessed
  /// It utilises a [stream] to fetch real time data on the status of the queues and their occupants
  Widget build(BuildContext context) {
    final adminQueueController = Provider.of<AdminQueueController>(context, listen: false);
    final dataController = Provider.of<DataController>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 20),
      child: StreamBuilder(
        stream: adminQueueController.getQueues(),
        builder: (BuildContext context, AsyncSnapshot<List<Queue>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No queues found'));
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              final queueData = snapshot.data![index];
              return Card(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MultiProvider(providers: [
                              ChangeNotifierProvider.value(value: adminQueueController),
                              ChangeNotifierProvider.value(value: dataController)
                            ], child: AdminQueueProgress(queue: queueData))));
                  },
                  child: ListTile(
                    title: Row(
                      children: [
                        Text(queueData.name),
                        if (queueData.open) const Icon(Icons.check, color: Colors.green),
                        if (!queueData.open) const Icon(Icons.close, color: Colors.red),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Users: ${queueData.users.length}'),
                        Text(queueData.capacity == null ? 'Capacity: Unlimited' : 'Capacity: ${queueData.capacity}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.bar_chart),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => MultiProvider(providers: [
                                        ChangeNotifierProvider.value(value: adminQueueController),
                                        ChangeNotifierProvider.value(value: dataController)
                                      ], child: QueueStats(queue: queueData))));
                            }),
                        IconButton(
                            icon: Icon(queueData.open ? Icons.lock : Icons.lock_open),
                            onPressed: () {
                              // Toggle queue open status
                              adminQueueController.toggleQueueOpenStatus(queueData);
                            }),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // Delete queue
                            adminQueueController.deleteQueue(queueData);
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

  /// This builds the window that is used to set parameters for a new queue
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Queue'),
      content: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: <Widget>[
        TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter Queue Name'),
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
        if (!isUnlimitedCapacity)
          TextField(
            keyboardType: TextInputType.number,
            autofocus: false,
            decoration: const InputDecoration(
              hintText: 'Enter Max Users',
            ),
            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
            controller: capacityController,
          )
      ]),
      actions: [
        TextButton(
            child: const Text("SUBMIT"),
            onPressed: () {
              String name = nameController.text;
              if (name.isEmpty) {
                return;
              }

              int? capacity = isUnlimitedCapacity ? null : int.tryParse(capacityController.text);
              int? newcapacity = (capacity == 0) ? null : capacity;
              widget.onSubmit(name, newcapacity);

              Navigator.of(context).pop();
            }),
      ],
    );
  }
}
