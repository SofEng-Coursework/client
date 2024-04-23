import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(home: QueueStats())));
}

class QueueStats extends StatefulWidget {
  const QueueStats({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QueueStatsState();
}

class _QueueStatsState extends State<QueueStats> {
  late List<BarChartGroupData> todayData;
  double screenWidth =
      WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width;
  double screenHeight = WidgetsBinding
      .instance.platformDispatcher.views.first.physicalSize.height;
  List<double> dayData = [
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

  int touchedGroupIndex = -1;

  List<double> averageDay = [1, 2, 3, 4, 5, 6, 7];
  @override
  void initState() {
    super.initState();
    final averageToday = [];
    for (int i = 0; i < 24; i++) {
      averageToday.add(makeBar(i, dayData[i]));
    }

    todayData = averageToday.cast<BarChartGroupData>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF017A08),
          title: const Text("*app name*"),
        ),
        body: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                        sideTitles: SideTitles(showTitles: true,),
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
                      maxY: dayData.reduce(max)))),
            ])));
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
    if (value % (dayData.reduce(max) % 10) == 0 || value == dayData.reduce(max)) {
      if (value > dayData.reduce(max) - (dayData.reduce(max) % 10) &&
          value != dayData.reduce(max)) {
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
