import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_queue/controllers/UserQueueController.dart';
import 'package:virtual_queue/controllers/userAccountController.dart';
import 'package:virtual_queue/models/Queue.dart';
import 'package:virtual_queue/pages/Settings.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    final userQueueController = Provider.of<UserQueueController>(context, listen: false);
    final userAccountController = Provider.of<UserAccountController>(context, listen: false);

    return StreamBuilder(
        stream: userQueueController.getCurrentQueue(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
          final queue = snapshot.data;

          return queue == null ? QueuesListView() : QueueProgressView(queue: queue);
        });
  }
}

class QueueProgressView extends StatelessWidget {
  final Queue queue;

  const QueueProgressView({required this.queue, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(),
          Column(
            children: [
              Text("Your position in the queue"),
              SizedBox(
                height: 10,
              ),
              CircleAvatar(
                radius: 50,
                child: StreamBuilder(
                  stream: Provider.of<UserQueueController>(context, listen: false).getCurrentQueuePosition(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    }
                    final position = snapshot.data;
                    return Text(position.toString());
                  },
                ),
              ),
            ],
          ),
          Container(
              height: 250,
              child: Row( children: [
                for (var i in [1,2,3,4,5,6,7,8,9,10])
                  StreamBuilder(
                      stream: Provider.of<UserQueueController>(context, listen: false).getCurrentQueuePosition(),
                      builder: (context, snapshot) {
                        if (i == snapshot.data) {
                          return Container(
                              height: 250,
                              child: Image.asset('assets/images/greenuser.png')
                          );
                        }
                        return Container(
                          height: 150,
                          child: Image.asset('assets/images/user.png')
                        );
                      }
                  )
              ])
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<UserQueueController>(context, listen: false).leaveQueue(queue);
            },
            child: Text("Leave queue"),
          )
        ],
      )),
    );
  }
}

class QueuesListView extends StatelessWidget {
  const QueuesListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final userAccountController = Provider.of<UserAccountController>(context, listen: false);
    final userQueueContorller = Provider.of<UserQueueController>(context, listen: false);

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
            Provider.of<UserAccountController>(context, listen: false).signOut();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            color: Color(0xffffffff),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      ChangeNotifierProvider<UserAccountController>(create: (context) => userAccountController, child: Settings())));
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
                  "Nearby Queues",
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontSize: 24,
                    color: Color(0xff272727),
                  ),
                ),
              ),
              StreamBuilder(
                stream: userQueueContorller.getQueues(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }
                  final queues = snapshot.data!;
                  print(queues);
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.all(0),
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: queues.length,
                    itemBuilder: (context, index) {
                      final queueData = queues[index];
                      final counter =
                          queueData.capacity != null ? '${queueData.users.length}/${queueData.capacity}' : '${queueData.users.length}';
                      String queueDetails = '$counter users in queue';
                      return QueueCard(queueData: queueData);
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class QueueCard extends StatefulWidget {
  final Queue queueData;

  QueueCard({
    required this.queueData,
    Key? key,
  }) : super(key: key);

  @override
  State<QueueCard> createState() => _QueueCardState();
}

class _QueueCardState extends State<QueueCard> {
  String? error;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 16),
      color: Color(0xffffffff),
      shadowColor: Color(0x4d939393),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: BorderSide(color: Color(0x4d9e9e9e), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(0),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xfff2f2f2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.work_outlined,
                color: Color(0xff212435),
                size: 16,
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      widget.queueData.name,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        fontSize: 16,
                        color: Color(0xff000000),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                      child: Text(
                        'Users in queue: ${widget.queueData.users.length}',
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xff6c6c6c),
                        ),
                      ),
                    ),
                    error != null
                        ? Padding(
                            padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                            child: Text(
                              error ?? '',
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Color.fromARGB(255, 255, 0, 0),
                              ),
                            ),
                          )
                        : SizedBox()
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                final status = await Provider.of<UserQueueController>(context, listen: false).joinQueue(widget.queueData);
                if (mounted) {
                  setState(() {
                    error = status;
                  });
                }
              },
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xff017a08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_box,
                  color: Color(0xffffffff),
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


