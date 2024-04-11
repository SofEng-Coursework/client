import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

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

  List<double> averageDay = [1, 2, 3, 4, 5, 6, 7];

  late List<BarChartGroupData> todayData;

  bool isEditingQueue = false;
  bool isAddingPersonToQueue = false;

  TextEditingController addToQueue = TextEditingController();

  List peopleInQueue = getPeopleInQueue();

  int touchedGroupIndex = -1;

  List<double> data = [
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    7,
    9,
    13,
    20,
    25,
    37,
    35,
    34,
    27,
    24,
    19,
    14,
    9,
    0,
    0,
    0,
    0
  ];

  @override
  void initState() {
    super.initState();
    final averageToday = [];
    for (int i = 0; i < 24; i++) {
      averageToday.add(makeBar(i, data[i]));
    }

    todayData = averageToday.cast<BarChartGroupData>();
  }

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
                                          ElevatedButton(
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
                                          ElevatedButton(
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
                                          ElevatedButton(
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
          /*right side*/ Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /*average daily*/ Container(
                  width: screenWidth * 0.1,
                  height: screenHeight * 0.2,
                  padding: const EdgeInsets.fromLTRB(0, 10, 5, 5),
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
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: getTitles,
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        makeBar(0, averageDay[0]),
                        makeBar(1, averageDay[1]),
                        makeBar(2, averageDay[2]),
                        makeBar(3, averageDay[3]),
                        makeBar(4, averageDay[4]),
                        makeBar(5, averageDay[5]),
                        makeBar(6, averageDay[6]),
                      ],
                      gridData: const FlGridData(
                          drawVerticalLine: false, drawHorizontalLine: true),
                      alignment: BarChartAlignment.spaceAround,
                      maxY: averageDay.reduce(max))),
                ),
                /*average today*/ Container(
                    width: screenWidth * 0.3,
                    height: screenHeight * 0.25,
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
                              getTitlesWidget: bottomTitles,
                              reservedSize: 42,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: 1,
                              getTitlesWidget: leftTitles,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        barGroups: todayData,
                        gridData: FlGridData(
                          show: true,
                          /*checkToShowHorizontalLine: (value) {
                        if (value % (data.reduce(max) % 10) == 0 || value == data.reduce(max)){
                          if (value > data.reduce(max) - (data.reduce(max) % 10) && value != data.reduce(max)){
                            return false;
                          }else{
                            return true;
                          }
                        }else{
                          return false;
                        }
                      },*/
                          getDrawingHorizontalLine: (value) => const FlLine(
                            color: Color(0xFF979797),
                            strokeWidth: 1,
                          ),
                          drawVerticalLine: false,
                        ),
                        alignment: BarChartAlignment.spaceAround,
                        maxY: data.reduce(max)))),
              ])
        ]));
  }

  Widget getTitles(double value, TitleMeta meta) {
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
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF017A08),
          width: 7,
        ),
      ],
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    if (value % (data.reduce(max) % 10) == 0 || value == data.reduce(max)) {
      if (value > data.reduce(max) - (data.reduce(max) % 10) &&
          value != data.reduce(max)) {
        text = "";
      } else {
        text = value.toString();
      }
    } else {
      return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(text, style: style),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
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
