import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:virtual_queue/controllers/UserQueueController.dart';
import 'package:virtual_queue/controllers/userAccountController.dart';
import 'package:virtual_queue/models/FeedbackEntry.dart';
import 'package:virtual_queue/models/Queue.dart';
import 'package:virtual_queue/pages/Settings.dart';
import 'package:virtual_queue/controllers/dataController.dart';

/// This builds the main page for users to access a selection of queues
class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    final userQueueController = Provider.of<UserQueueController>(context, listen: false);

    /// This StreamBuilder will check if the user is in a queue and will pass the Queue Progress page if so.
    return StreamBuilder(
        stream: userQueueController.getCurrentQueue(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
          final queue = snapshot.data;

          return queue == null ? const QueuesListView() : QueueProgressView(queue: queue);
        });
  }
}
/// This is where the popup asking for feedback is created and uploaded to Firebase
class FeedbackView extends StatefulWidget {
  final List<dynamic> feedbackPrompts;
  final Map<String, dynamic> userData;
  const FeedbackView({required this.feedbackPrompts, required this.userData, super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  final commentsController = TextEditingController();

  int rating = 0;

  @override
  Widget build(BuildContext context) {
    final userQueueController = Provider.of<UserQueueController>(context, listen: false);
    final queueId = widget.feedbackPrompts[0] as String;
    final userId = widget.userData['uid'] as String;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            userQueueController.removeFeedbackPrompt(queueId, userId);
            Navigator.of(context).pop();
          },
        ),
        title: const Text("Rate Experience"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("How would you rate your experience?", style: TextStyle(fontSize: 24)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RatingBar.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return const Icon(
                        Icons.sentiment_very_dissatisfied,
                        color: Colors.red,
                      );
                    case 1:
                      return const Icon(
                        Icons.sentiment_dissatisfied,
                        color: Colors.redAccent,
                      );
                    case 2:
                      return const Icon(
                        Icons.sentiment_neutral,
                        color: Colors.amber,
                      );
                    case 3:
                      return const Icon(
                        Icons.sentiment_satisfied,
                        color: Colors.lightGreen,
                      );
                    case 4:
                      return const Icon(
                        Icons.sentiment_very_satisfied,
                        color: Colors.green,
                      );
                    default:
                      return Container();
                  }
                },
                onRatingUpdate: (newRating) {
                  setState(() {
                    rating = newRating.toInt();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 120,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Additional comments",
                    border: OutlineInputBorder(),
                  ),
                  expands: true,
                  controller: commentsController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (rating == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a rating")));
                  return;
                }
                // Submit feedback
                final FeedbackEntry entry = FeedbackEntry(
                  userId: userId,
                  comments: commentsController.text,
                  rating: rating,
                );
                userQueueController.removeFeedbackPrompt(queueId, userId);
                userQueueController.submitFeedback(widget.feedbackPrompts[0], entry).then((status) {
                  if (status.success) {
                    Navigator.of(context).pop();
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status.message!)));
                });
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
/// This is the widget that shows the user their position in the queue and the average wait time
class QueueProgressView extends StatelessWidget {
  final Queue queue;

  const QueueProgressView({required this.queue, super.key});

  @override
  Widget build(BuildContext context) {
    final dataController = Provider.of<DataController>(context, listen: false);
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(),
          Column(
            children: [
              Text("Average Wait Time: ${dataController.formatTime(dataController.getMedianWaitTime(queue))}"),
              const Text("Your position in the queue"),
              const SizedBox(
                height: 10,
              ),
              CircleAvatar(
                radius: 50,
                child: StreamBuilder(
                  stream: Provider.of<UserQueueController>(context, listen: false).getCurrentQueuePosition(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
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
              child: StreamBuilder<int>(
                  stream: Provider.of<UserQueueController>(context, listen: false).getCurrentQueuePosition(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final position = snapshot.data!;
                    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      if (position > 2) SizedBox(height: 125, child: Image.asset('assets/images/user.png')),
                      if (position > 1) SizedBox(height: 150, child: Image.asset('assets/images/user.png')),
                      SizedBox(height: 180, child: Image.asset('assets/images/greenuser.png')),
                      SizedBox(height: 150, child: Image.asset('assets/images/user.png')),
                      SizedBox(height: 125, child: Image.asset('assets/images/user.png')),
                    ]);
                  })),
          ElevatedButton(
            onPressed: () {
              Provider.of<UserQueueController>(context, listen: false).leaveQueue(queue).then((status) {
                if (status.success) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status.message!)));
              });
            },
            child: const Text("Leave queue"),
          )
        ],
      )),
    );
  }
}

class QueuesListView extends StatefulWidget {
  const QueuesListView({
    super.key,
  });

  @override
  State<QueuesListView> createState() => _QueuesListViewState();
}

class _QueuesListViewState extends State<QueuesListView> {
  final feedbackViewPushed = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    final userAccountController = Provider.of<UserAccountController>(context, listen: false);
    final userQueueContorller = Provider.of<UserQueueController>(context, listen: false);

    userAccountController.getUserData().then((userData) {
      if (userData == null) {
        return;
      }
      final feedbackPrompts = userData['feedbackPrompt'] as List<dynamic>;
      if (feedbackPrompts.isNotEmpty && !feedbackViewPushed.value) {
        feedbackViewPushed.value = true;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
              value: userQueueContorller, child: FeedbackView(feedbackPrompts: feedbackPrompts, userData: userData)),
        )).then((value) => feedbackViewPushed.value = false);
      }
    });

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
        leading: IconButton(
          icon: const Icon(
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
            icon: const Icon(Icons.settings),
            color: const Color(0xffffffff),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      ChangeNotifierProvider<UserAccountController>(create: (context) => userAccountController, child: Settings())));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Padding(
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
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }
                  final queues = snapshot.data!;

                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.all(0),
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
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

  const QueueCard({
    required this.queueData,
    Key? key,
  }) : super(key: key);

  @override
  State<QueueCard> createState() => _QueueCardState();
}

class _QueueCardState extends State<QueueCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      color: const Color(0xffffffff),
      shadowColor: const Color(0x4d939393),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: const BorderSide(color: Color(0x4d9e9e9e), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(0),
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xfff2f2f2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.work_outlined,
                color: Color(0xff212435),
                size: 16,
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        fontSize: 16,
                        color: Color(0xff000000),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                      child: Text(
                        'Users in queue: ${widget.queueData.users.length}',
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xff6c6c6c),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                Provider.of<UserQueueController>(context, listen: false).joinQueue(widget.queueData).then((status) {
                  if (status.success) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status.message!)));
                });
              },
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(0),
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xff017a08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
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
