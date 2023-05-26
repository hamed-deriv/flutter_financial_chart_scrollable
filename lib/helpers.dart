import 'dart:math';

import 'package:intl/intl.dart';

import 'package:flutter_financial_chart/candle_stick_model.dart';

List<CandleStickModel> generateRandomCandlestickData({
  int count = 10,
  double minValue = 50,
  double maxValue = 200,
  double minRange = 5,
  double maxRange = 20,
}) {
  final List<CandleStickModel> data = <CandleStickModel>[];

  final Random random = Random();
  double previousClose = (minValue + maxValue) / 2;
  final DateFormat formatter = DateFormat('yyyy-MMM-dd');

  for (int i = 0; i < count; i++) {
    final double range = random.nextDouble() * (maxRange - minRange) + minRange;
    final double high = previousClose + range;
    final double low = previousClose - range;

    final double open = random.nextDouble() * (high - low) + low;
    final double close = random.nextDouble() * (high - low) + low;

    data.add(
      CandleStickModel(
        open: open,
        close: close,
        high: high,
        low: low,
        label: formatter.format(DateTime.now().add(Duration(days: i))),
      ),
    );
    previousClose = close;
  }

  return data;
}
