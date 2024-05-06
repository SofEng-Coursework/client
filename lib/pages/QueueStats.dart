import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:virtual_queue/controllers/AdminQueueController.dart';
import 'package:virtual_queue/controllers/dataController.dart';
import 'package:virtual_queue/models/FeedbackEntry.dart';
import 'package:virtual_queue/models/Queue.dart';

class QueueStats extends StatefulWidget {
  final Queue queue;
  const QueueStats({
    Key? key,
    required this.queue,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QueueStatsState();
}

class _QueueStatsState extends State<QueueStats> {
  late List<BarChartGroupData> todayData;
  int touchedGroupIndex = -1;

  List<double> averageDay = [1, 2, 3, 4, 5, 6, 7];

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

              // This is the live queue data
              Queue queue = snapshot.data as Queue;

              return Scrollbar(
                  child: Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                    // /*average daily*/ Container(
                    //   width: 300,
                    //   height: 200,
                    //   padding: const EdgeInsets.fromLTRB(0, 10, 5, 5),
                    //   child: BarChart(BarChartData(
                    //       barTouchData: BarTouchData(
                    //         enabled: false,
                    //         touchTooltipData: BarTouchTooltipData(
                    //           tooltipBgColor: Colors.transparent,
                    //           tooltipPadding: EdgeInsets.zero,
                    //           tooltipMargin: 8,
                    //           getTooltipItem: (
                    //             BarChartGroupData group,
                    //             int groupIndex,
                    //             BarChartRodData rod,
                    //             int rodIndex,
                    //           ) {
                    //             return BarTooltipItem(
                    //               rod.toY.round().toString(),
                    //               const TextStyle(
                    //                 color: Color(0xFF0065B7),
                    //                 fontWeight: FontWeight.bold,
                    //               ),
                    //             );
                    //           },
                    //         ),
                    //       ),
                    //       titlesData: FlTitlesData(
                    //         show: true,
                    //         bottomTitles: AxisTitles(
                    //           sideTitles: SideTitles(
                    //             showTitles: true,
                    //             reservedSize: 30,
                    //             getTitlesWidget: bottomTitlesWeek,
                    //           ),
                    //         ),
                    //         leftTitles: const AxisTitles(
                    //           sideTitles: SideTitles(showTitles: false),
                    //         ),
                    //         topTitles: const AxisTitles(
                    //           sideTitles: SideTitles(
                    //             showTitles: false,
                    //           ),
                    //         ),
                    //         rightTitles: const AxisTitles(
                    //           sideTitles: SideTitles(showTitles: false),
                    //         ),
                    //       ),
                    //       borderData: FlBorderData(show: false),
                    //       barGroups: [
                    //         makeBar(0, averageDay[0]),
                    //         makeBar(1, averageDay[1]),
                    //         makeBar(2, averageDay[2]),
                    //         makeBar(3, averageDay[3]),
                    //         makeBar(4, averageDay[4]),
                    //         makeBar(5, averageDay[5]),
                    //         makeBar(6, averageDay[6]),
                    //       ],
                    //       gridData: const FlGridData(drawVerticalLine: false, drawHorizontalLine: false),
                    //       alignment: BarChartAlignment.spaceAround,
                    //       maxY: averageDay.reduce(max))),
                    // ),
                    /*average today*/
                    Container(
                        width: MediaQuery.of(context).size.width - 100,
                        height: MediaQuery.of(context).size.height * 0.5,
                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                        child: BarChart(BarChartData(
                            barTouchData: BarTouchData(
                              enabled: false,
                              touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: Colors.transparent,
                                tooltipPadding: EdgeInsets.zero,
                                tooltipMargin: 8,
                                getTooltipItem: (
                                  BarChartGroupData group,
                                  int groupIndex,
                                  BarChartRodData rod,
                                  int rodIndex,
                                ) {
                                  return BarTooltipItem(
                                    rod.toY.round().toString(),
                                    const TextStyle(
                                      color: Color(0xFF0065B7),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: bottomTitlesToday,
                                  reservedSize: 42,
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(24, (i) => makeBar(i, dataController.getDayData(queue)[i])),
                            gridData: const FlGridData(
                              show: false,
                            ),
                            alignment: BarChartAlignment.spaceAround,
                            maxY: dataController.getDayData(queue).reduce(max)))),
                    StreamBuilder(
                        stream: adminQueueController.getFeedback(queue.id),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text("Error");
                          }
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          // This is the live queue data
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
                                              style: TextStyle(fontWeight: FontWeight.bold),
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
                        })
                  ])));
            }));
  }

  Widget bottomTitlesWeek(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Mn';
        break;
      case 1:
        text = 'Te';
        break;
      case 2:
        text = 'Wd';
        break;
      case 3:
        text = 'Tu';
        break;
      case 4:
        text = 'Fr';
        break;
      case 5:
        text = 'St';
        break;
      case 6:
        text = 'Sn';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text,
          style: const TextStyle(
            color: Color(0xFF464646),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          )),
    );
  }

  BarChartGroupData makeBar(int x, double y) {
    return BarChartGroupData(barsSpace: 4, x: x, barRods: [
      BarChartRodData(
        toY: y,
        color: const Color(0xFF017A08),
        width: 7,
      ),
    ], showingTooltipIndicators: [
      0
    ]);
  }

  Widget bottomTitlesToday(double value, TitleMeta meta) {
    List<String> titles = [
      "00:00",
      "01:00",
      "02:00",
      "03:00",
      "04:00",
      "05:00",
      "06:00",
      "07:00",
      "08:00",
      "09:00",
      "10:00",
      "11:00",
      "12:00",
      "13:00",
      "14:00",
      "15:00",
      "16:00",
      "17:00",
      "18:00",
      "19:00",
      "20:00",
      "21:00",
      "22:00",
      "23:00"
    ];

    Widget text = Text(
      titles[value.toInt()],
      style: const TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 1, //margin top
      child: RotatedBox(quarterTurns: -1, child: text),
    );
  }
}
