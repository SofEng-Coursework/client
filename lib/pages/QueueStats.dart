import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:virtual_queue/controllers/AdminQueueController.dart';
import 'package:virtual_queue/controllers/dataController.dart';
import 'package:virtual_queue/models/FeedbackEntry.dart';
import 'package:virtual_queue/models/Queue.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


/// This is the page that will display statistics and feedback about the queues to the admin
class QueueStats extends StatefulWidget {
  final Queue queue;
  const QueueStats({
    Key? key,
    required this.queue,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QueueStatsState();
}

class WaitTimeChartData {
  final DateTime x;
  final Duration y;
  WaitTimeChartData(this.x, this.y);
}

class QueueLengthChartData {
  final DateTime x;
  final (int, int) y;
  QueueLengthChartData(this.x, this.y);
}

class _QueueStatsState extends State<QueueStats> {
  int viewType = 0; /// 0 for today, 1 for this week
  int dataType = 0; /// 0 for wait time, 1 for queue length

  /// This is the main widget that builds the graph to display user activity
  @override
  Widget build(BuildContext context) {
    final adminQueueController = Provider.of<AdminQueueController>(context, listen: false);
    final dataController = Provider.of<DataController>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF017A08),
          title: Text(widget.queue.name, style: const TextStyle(color: Color(0xFFFFFFFF))),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
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

              /// This is the live queue data
              Queue queue = snapshot.data as Queue;

              /// Daily data

              final todayLogs = dataController.getLogsForDate(queue, DateTime.now());
              final hourlyLogs = List.generate(24, (i) => dataController.getLogsForHour(todayLogs, i));
              final hourlyWaitTimes = List.generate(24, (i) => dataController.getMedianWaitTimeForHour(todayLogs, i));

              final hourlyQueueLengths = List.generate(24, (i) => dataController.getMinMaxQueueLengthForHour(todayLogs, i));

              /// Weekly data

              final dailyWaitTimes = List.generate(7,
                  (i) => dataController.getMedianWaitTimeForDate(queue, DateTime.now().subtract(const Duration(days: 6)).add(Duration(days: i))));

              final dailyQueueLengths = List.generate(7, (i) {
                final (min, max) =
                    dataController.getMinMaxQueueLengthForDate(queue, DateTime.now().subtract(const Duration(days: 6)).add(Duration(days: i)));
                return (min, max);
              });

              /// Chart data

              final List<WaitTimeChartData> waitTimeChartData = viewType == 0
                  ? List.generate(24, (i) {
                      return WaitTimeChartData(
                          DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, i), hourlyWaitTimes[i]);
                    })
                  : List.generate(7, (i) {
                      return WaitTimeChartData(
                          DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(Duration(days: 6 - i)),
                          dailyWaitTimes[i]);
                    });

              final List<QueueLengthChartData> queueLengthChartData = viewType == 0
                  ? List.generate(24, (i) {
                      return QueueLengthChartData(
                          DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, i), hourlyQueueLengths[i]);
                    })
                  : List.generate(7, (i) {
                      return QueueLengthChartData(
                          DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(Duration(days: 6 - i)),
                          dailyQueueLengths[i]);
                    });

              List<CartesianSeries> series = [];
              if (dataType == 0) {
                series = [
                  LineSeries<WaitTimeChartData, DateTime>(
                    name: 'Wait Time',
                    animationDuration: 250,
                    dataSource: waitTimeChartData,
                    xValueMapper: (data, _) => data.x,
                    yValueMapper: (data, _) => data.y.inMilliseconds,
                  )
                ];
              } else {
                series = [
                  /// min queue length column
                  ColumnSeries<QueueLengthChartData, DateTime>(
                    enableTooltip: false,
                    name: 'Min Queue Length',
                    animationDuration: 250,
                    dataSource: queueLengthChartData,
                    xValueMapper: (data, _) => data.x,
                    yValueMapper: (data, _) => data.y.$1,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    dataLabelMapper: (datum, index) {
                      final minLength = datum.y.$1;
                      if (minLength == 0) return "";
                      return "Min ${datum.y.$2.toString()}";
                    },
                  ),
                  /// max queue length column
                  ColumnSeries<QueueLengthChartData, DateTime>(
                    enableTooltip: false,
                    name: 'Max Queue Length',
                    animationDuration: 250,
                    dataSource: queueLengthChartData,
                    xValueMapper: (data, _) => data.x,
                    yValueMapper: (data, _) => data.y.$2,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    dataLabelMapper: (datum, index) {
                      final maxLength = datum.y.$2;
                      if (maxLength == 0) return "";
                      return "Max ${datum.y.$2.toString()}";
                    },
                  )
                ];
              }

              return Scrollbar(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      //mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton(
                            value: viewType,
                            items: const [
                              DropdownMenuItem(
                                value: 0,
                                child: Text("Today"),
                              ),
                              DropdownMenuItem(
                                value: 1,
                                child: Text("Last 7 Days"),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                viewType = value as int;
                              });
                            }),
                        const SizedBox(width: 10),
                        DropdownButton(
                            value: dataType,
                            items: const [
                              DropdownMenuItem(
                                value: 0,
                                child: Text("Wait Time"),
                              ),
                              DropdownMenuItem(
                                value: 1,
                                child: Text("Queue Length"),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                dataType = value as int;
                              });
                            })
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 100,
                      height: MediaQuery.of(context).size.height * 0.4,
                      padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                      child: SfCartesianChart(
                          tooltipBehavior: TooltipBehavior(
                            duration: 1000,
                            enable: true,
                            builder: (data, point, series, pointIndex, seriesIndex) {
                              return Container(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  Duration(milliseconds: point.y!.toInt()).toString().split('.').first,
                                  style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                                ),
                              );
                            },
                          ),
                          primaryXAxis: viewType == 0
                              ? DateTimeAxis(
                                  title: const AxisTitle(text: 'Time Of Day'),
                                  minimum: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                                  maximum: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59),
                                )
                              : DateTimeAxis(
                                  title: const AxisTitle(text: 'Day'),
                                  minimum:
                                      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(const Duration(days: 6)),
                                  maximum: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(const Duration(days: 1)),
                                ),
                          primaryYAxis: dataType == 0
                              ? NumericAxis(
                                  title: const AxisTitle(text: 'Wait Time'),
                                  axisLabelFormatter: (axisLabelRenderArgs) {
                                    return ChartAxisLabel(
                                      Duration(milliseconds: axisLabelRenderArgs.value.toInt()).toString().split('.').first,
                                      const TextStyle(),
                                    );
                                  },
                                )
                              : const NumericAxis(
                                  title: AxisTitle(text: 'Queue Length'),
                                ),
                          series: series),
                    ),
                    FeedbackEntryListWidget(adminQueueController: adminQueueController, queue: queue)
                  ]));
            }));
  }
}

class FeedbackEntryListWidget extends StatelessWidget {
  const FeedbackEntryListWidget({
    super.key,
    required this.adminQueueController,
    required this.queue,
  });

  final AdminQueueController adminQueueController;
  final Queue queue;

  /// This is the main widget to display the user ratings
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: adminQueueController.getFeedback(queue.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error");
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          /// This is the live queue data
          List<FeedbackEntry> feedback = snapshot.data as List<FeedbackEntry>;

          if (feedback.isEmpty) {
            return const Text("No feedback");
          } else {
            return Expanded(
              child: ListView.builder(
                itemCount: feedback.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              feedback[index].name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            RatingBar.builder(
                                initialRating: feedback[index].rating.toDouble(),
                                minRating: 1,
                                itemSize: 24,
                                ignoreGestures: true,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                onRatingUpdate: (rating) {})
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            feedback[index].comments,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        });
  }
}
