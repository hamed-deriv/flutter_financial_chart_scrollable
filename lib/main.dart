import 'package:flutter/material.dart';

import 'package:flutter_financial_chart/candle_stick_chart.dart';
import 'package:flutter_financial_chart/candle_stick_model.dart';
import 'package:flutter_financial_chart/helpers.dart';

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
            child: GestureDetector(
              child:
                  CandleStickChart(data: allData.sublist(startIndex, endIndex)),
              onHorizontalDragUpdate: (DragUpdateDetails details) {
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
              },
            ),
          ),
        ),
      );
}
