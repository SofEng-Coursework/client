import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_queue/controllers/AdminQueueController.dart';
import 'package:virtual_queue/models/Queue.dart';

class AdminQueueProgress extends StatefulWidget {
  final Queue queue;
  const AdminQueueProgress({
    Key? key,
    required this.queue,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AdminQueueProgressState();
}

class _AdminQueueProgressState extends State<AdminQueueProgress> {
  int waitTime = 15;

  ButtonStyle editStyle = ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Color(0xFFFFFFFF), width: 3))),
      backgroundColor:
          MaterialStateProperty.all<Color>(const Color(0x00000000)));

  TextEditingController addToQueueName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final adminQueueController =
        Provider.of<AdminQueueController>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF017A08),
          title: Text(widget.queue.name,
              style: const TextStyle(color: Color(0xFFFFFFFF))),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            )
          ],
        ),
        drawer: const Drawer(),
        body: StreamBuilder<Object>(
            stream: adminQueueController.getQueue(widget.queue.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("Error");
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // This is the live queue data
              Queue queue = snapshot.data as Queue;

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Queue",
                        style: TextStyle(fontSize: 28),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child:
                          Text("Being served", style: TextStyle(fontSize: 18)),
                    ),
                    //Being served
                    Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.height * 0.1,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFF017A08), width: 3),
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(
                          child: SingleChildScrollView(
                            child: queue.users.isNotEmpty
                                ? Text(queue.users[0].name as String,
                                    style: const TextStyle(fontSize: 20))
                                : const Text("Queue empty",
                                    style: TextStyle(fontSize: 20)),
                          ),
                        )),
                    //Advance button
                    Padding(
                        padding: const EdgeInsets.all(12),
                        child: ElevatedButton(
                          child: const Text("Advance"),
                          onPressed: () {
                            if (queue.users.isNotEmpty) {
                              adminQueueController.removeUserFromQueue(
                                  queue, queue.users[0]);
                            }
                          },
                        )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 15, 0),
                      child: Text("Wait Time: $waitTime minutes",
                          style: const TextStyle(fontSize: 18)),
                    ),
                    //Main queue
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.height * 0.4,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFF017A08), width: 3),
                          borderRadius: BorderRadius.circular(12)),
                      child: ListView.builder(
                          itemCount: queue.users.length,
                          itemBuilder: (context, index) {
                            final user = queue.users[index];
                            return Card(
                              child: ListTile(
                                  title: Text(user.name!),
                                  trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.arrow_drop_up),
                                          onPressed: () {
                                            adminQueueController
                                                .moveUserUp(queue, user)
                                                .then((status) {
                                              if (status.success) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          status.message!)));
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon:
                                              const Icon(Icons.arrow_drop_down),
                                          onPressed: () {
                                            adminQueueController
                                                .moveUserDown(queue, user)
                                                .then((status) {
                                              if (status.success) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          status.message!)));
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            adminQueueController
                                                .removeUserFromQueue(
                                                    queue, user)
                                                .then((status) {
                                              if (status.success) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          status.message!)));
                                            });
                                          },
                                        )
                                      ])),
                            );
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Add Person to Queue"),
                                  content: TextField(
                                    controller: addToQueueName,
                                    decoration: const InputDecoration(
                                      hintText: "Name",
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        addToQueueName.clear();
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        final user = addToQueueName.text;
                                        adminQueueController
                                            .addUserToQueue(queue, user)
                                            .then((status) {
                                          if (status.success) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content:
                                                      Text(status.message!)));
                                        });
                                        addToQueueName.clear();
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Add"),
                                    ),
                                  ],
                                );
                              });
                        },
                        child: Text("Add New Person"),
                      ),
                    ),
                  ],
                ),
              );
            }));
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF017A08),
        title: const Text("Settings"),
      ),
    );
  }
}
