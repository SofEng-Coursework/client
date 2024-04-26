import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_queue/controllers/AdminQueueController.dart';
import 'package:virtual_queue/models/Queue.dart';

class AdminQueueProgress extends StatefulWidget {
  Queue queue;
  AdminQueueProgress({
    Key? key,
    required this.queue,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AdminQueueProgressState();
}

class _AdminQueueProgressState extends State<AdminQueueProgress> {
  Future<List<String>> getPeopleInQueue(
      AdminQueueController adminQueueController, Queue queue) async {
    List<String> users = await adminQueueController.getUsersInQueue(queue);
    return users;
  }

  int waitTime = 15;

  ButtonStyle editStyle = ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Color(0xFFFFFFFF), width: 3))),
      backgroundColor:
          MaterialStateProperty.all<Color>(const Color(0x00000000)));

  bool isEditingQueue = false;
  bool isAddingPersonToQueue = false;

  TextEditingController addToQueue = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final adminQueueController =
        Provider.of<AdminQueueController>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF017A08),
          title: Text(widget.queue.name),
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
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: const Text("Queue", style: TextStyle(fontSize: 28),),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.6,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF017A08), width: 3),
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: ListView.builder(
                        itemCount: queue.users.length,
                        itemBuilder: (context, index) {
                          final user = queue.users[index];
                          return Card(
                            child: ListTile(
                              title: Text(user.name!),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  adminQueueController.removeUserFromQueue(queue, user);      
                                },
                              ),
                            ),
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
                                  controller: addToQueue,
                                  decoration: const InputDecoration(
                                    hintText: "Name",
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {

                                      Navigator.pop(context);
                                    },
                                    child: const Text("Add"),
                                  ),
                                ],
                              );
                            }
                          );
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
