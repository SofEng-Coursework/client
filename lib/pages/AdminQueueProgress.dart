import 'package:flutter/material.dart';
import 'package:virtual_queue/controllers/AdminQueueController.dart';

List<String> getPeopleInQueue() {
  return ["Harry", "Elliott", "Andrew", "Ilyas", "Tommy", "Antoine", "idk"];
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Directionality(
      textDirection: TextDirection.rtl, child: MaterialApp(home: AdminPage())));
}

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  double screenWidth =
      WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width;
  double screenHeight = WidgetsBinding
      .instance.platformDispatcher.views.first.physicalSize.height;
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

  List peopleInQueue = getPeopleInQueue();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF017A08),
          title: const Text("*app name*"),
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
        body: Row(mainAxisSize: MainAxisSize.min, children: [
          /*left side*/ Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Queue",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
              /*queue*/ Container(
                width: screenWidth * 0.2,
                height: screenHeight * 0.3,
                padding: const EdgeInsets.all(3),
                margin: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: const Color(0xFF017A08),
                  border: Border.all(
                    color: const Color(0xFF042433),
                    width: 3,
                  ),
                ),
                child: ListView.builder(
                    itemCount: peopleInQueue.length,
                    itemBuilder: (BuildContext context, int i) {
                      return Container(
                          padding: const EdgeInsets.all(1),
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            border: Border.all(
                              color: const Color(0xFFFFFFFF),
                              width: 3,
                            ),
                          ),
                          child: ListTile(
                              title: Text(peopleInQueue[i],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                              trailing: isEditingQueue
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                          ElevatedButton(//move person up
                                            onPressed: () {
                                              if (i > 0) {
                                                setState(() {
                                                  var temp = peopleInQueue[i];
                                                  peopleInQueue[i] =
                                                      peopleInQueue[i - 1];
                                                  peopleInQueue[i - 1] = temp;
                                                });
                                              }
                                            },
                                            style: editStyle,
                                            child: const Text("\u25b2",
                                                style: TextStyle(
                                                    color: Color(0xFFFFFFFF),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10)),
                                          ),
                                          ElevatedButton(//move person down
                                            onPressed: () {
                                              if (i < peopleInQueue.length) {
                                                setState(() {
                                                  var temp = peopleInQueue[i];
                                                  peopleInQueue[i] =
                                                      peopleInQueue[i + 1];
                                                  peopleInQueue[i + 1] = temp;
                                                });
                                              }
                                            },
                                            style: editStyle,
                                            child: const Text("\u25bc",
                                                style: TextStyle(
                                                    color: Color(0xFFFFFFFF),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10)),
                                          ),
                                          ElevatedButton(//remove person
                                            onPressed: () {
                                              setState(() {
                                                peopleInQueue.removeAt(i);
                                              });
                                            },
                                            style: editStyle,
                                            child: const Text("Remove",
                                                style: TextStyle(
                                                    color: Color(0xFFFFFFFF),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15)),
                                          ),
                                        ])
                                  : null));
                    }),
              ),
              /*edit button*/ ElevatedButton(
                onPressed: () {
                  setState(() {
                    isEditingQueue = !isEditingQueue;
                    isAddingPersonToQueue = false;
                    addToQueue.clear();
                  });
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(
                                color: Color(0xFF600000), width: 3))),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFFFF0101))),
                child: const Text("Edit",
                    style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
              ),
              if (isEditingQueue)
                /*add person button*/ Container(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isAddingPersonToQueue = !isAddingPersonToQueue;
                            addToQueue.clear();
                          });
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(
                                        color: Color(0xFF01CA08), width: 3))),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFF017A08))),
                        child: const Text("Add person +",
                            style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 15,
                                fontWeight: FontWeight.bold)))),
              if (isAddingPersonToQueue)
                /*add to new person to queue*/ Container(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                            width: screenWidth * 0.1,
                            height: screenHeight * 0.05,
                            child: TextField(
                              controller: addToQueue,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Enter name"),
                            ),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                          title: const Text("Confirm"),
                                          content: Text(
                                              "Would you like to add ${addToQueue.text} to the queue?"),
                                          actions: [
                                            ElevatedButton(
                                              child: const Text("Cancel"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            ElevatedButton(
                                              child: const Text("Confirm"),
                                              onPressed: () {
                                                setState(() {
                                                  if (addToQueue.text != "") {
                                                    peopleInQueue
                                                        .add(addToQueue.text);
                                                    addToQueue.clear();
                                                  }
                                                  Navigator.of(context).pop();
                                                });
                                              },
                                            ),
                                          ]);
                                    });
                              },
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          side: const BorderSide(
                                              color: Color(0xFF600000),
                                              width: 3))),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          const Color(0xFFFF0101))),
                              child: const Text("Confirm",
                                  style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)))
                        ]))
            ],
          ),
          /*wait time*/ Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: screenWidth * 0.15,
                    //height: screenWidth * 0.05,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color(0xFF017A08),
                      border: Border.all(
                        color: const Color(0xFF042433),
                        width: 3,
                      ),
                    ),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Current Wait Time:",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20, color: Color(0xFFFFFFFF))),
                          Text("$waitTime minutes",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFFFFF)))
                        ]))
              ]),
        ]));
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
