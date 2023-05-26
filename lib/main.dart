import 'package:flutter/material.dart';

import 'package:flutter_financial_chart/candle_stick_chart.dart';
import 'package:flutter_financial_chart/candle_stick_model.dart';
import 'package:flutter_financial_chart/grid_painter.dart';
import 'package:flutter_financial_chart/helpers.dart';
import 'package:flutter_financial_chart/horizontal_axis_painter.dart';
import 'package:flutter_financial_chart/vertical_axis_painter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Candlestick Chart Example',
        theme: ThemeData(
          primarySwatch: Colors.pink,
        ),
        home: CandlestickChartExample(),
      );
}

class CandlestickChartExample extends StatefulWidget {
  @override
  State<CandlestickChartExample> createState() =>
      _CandlestickChartExampleState();
}

class _CandlestickChartExampleState extends State<CandlestickChartExample> {
  List<CandleStickModel> allData = <CandleStickModel>[];

  int startIndex = 0;
  int endIndex = 100;
  double dragVelocity = 0;

  @override
  void initState() {
    super.initState();

    allData = generateRandomCandlestickData(count: 1000);

    startIndex = allData.length - 20;
    endIndex = allData.length;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Candlestick Chart Example')),
        body: Center(
          child: Container(
            padding: const EdgeInsets.only(left: 8, right: 48),
            child: Stack(
              children: <Widget>[
                HorizontalAxisPainter(
                  data: allData.sublist(startIndex, endIndex),
                ),
                VerticalAxisPainter(
                  data: allData.sublist(startIndex, endIndex),
                ),
                GridPainter(
                  data: allData.sublist(startIndex, endIndex),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: CandleStickChart(
                    data: allData.sublist(startIndex, endIndex),
                  ),
                  onHorizontalDragUpdate: (DragUpdateDetails details) {
                    final double dx = details.delta.dx;
                    final double dragDistance = dx.abs();

                    if (dragDistance > 5) {
                      final int direction = dx > 0 ? -1 : 1;
                      final int dragIndex = (dragDistance ~/ 3) * direction;

                      final int newStartIndex = startIndex + dragIndex;
                      final int newEndIndex = endIndex + dragIndex;

                      if (newStartIndex >= 0 && newEndIndex <= allData.length) {
                        startIndex = newStartIndex;
                        endIndex = newEndIndex;

                        setState(() {});
                      }
                    } else {
                      if (details.delta.dx > 0) {
                        if (startIndex == 0) {
                          return;
                        }

                        startIndex = startIndex - 1;
                        endIndex = endIndex - 1;
                      } else {
                        if (endIndex == allData.length) {
                          return;
                        }

                        startIndex = startIndex + 1;
                        endIndex = endIndex + 1;
                      }

                      setState(() {});
                    }
                  },
                  onHorizontalDragEnd: (DragEndDetails details) {
                    dragVelocity = details.primaryVelocity ?? 0.0;
                    if (dragVelocity.abs() > 500) {
                      smoothScroll();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );

  void smoothScroll() {
    if (dragVelocity > 0) {
      // Scrolling to the right
      endIndex -= 1;
      startIndex -= 1;
    } else {
      // Scrolling to the left
      endIndex += 1;
      startIndex += 1;
    }

    if (startIndex >= 0 && endIndex <= allData.length) {
      setState(() {});

      dragVelocity *= 0.9; // Applying damping factor for smoothness

      if (dragVelocity.abs() > 10) {
        // Continue scrolling
        Future<void>.delayed(const Duration(milliseconds: 16), smoothScroll);
      } else {
        // Snap to nearest index
        snapToNearestIndex();
      }
    } else {
      // Snap to nearest index
      snapToNearestIndex();
    }
  }

  void snapToNearestIndex() {
    // Snap to the nearest index
    final int nearestIndex = (dragVelocity > 0) ? endIndex + 1 : endIndex - 1;
    startIndex = nearestIndex - 20;
    endIndex = nearestIndex;

    setState(() {});
  }
}
