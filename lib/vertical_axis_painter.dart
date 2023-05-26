import 'package:flutter/material.dart';

import 'package:flutter_financial_chart/candle_stick_model.dart';

class VerticalAxisPainter extends StatelessWidget {
  const VerticalAxisPainter({required this.data});

  final List<CandleStickModel> data;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(double.infinity, 200),
        painter: _CandlestickChartPainter(data: data),
      );
}

class _CandlestickChartPainter extends CustomPainter {
  _CandlestickChartPainter({required this.data});

  final List<CandleStickModel> data;

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double candleWidth = width / data.length;

    final double maxPrice = data
        .map((CandleStickModel candle) => candle.high)
        .reduce((double a, double b) => a > b ? a : b);
    final double minPrice = data
        .map((CandleStickModel candle) => candle.low)
        .reduce((double a, double b) => a < b ? a : b);
    final double priceRange = maxPrice - minPrice;

    const double chartPadding = 10;
    final double chartHeight = height - chartPadding * 2;
    final double pricePerPixel = chartHeight / priceRange;

    final Paint linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Draw vertical axis lines and labels
    final double axisX = width + candleWidth / 2;
    canvas.drawLine(
        Offset(axisX, 0), Offset(axisX, height - chartPadding), linePaint);
    for (int i = 0; i < 5; i++) {
      final double price = minPrice + (i / 4) * priceRange;
      final double labelY =
          height - (price - minPrice) * pricePerPixel - chartPadding;
      final TextSpan span = TextSpan(
        text: price.toStringAsFixed(2),
        style: const TextStyle(fontSize: 10, color: Colors.black),
      );

      textPainter
        ..text = span
        ..layout()
        ..paint(canvas, Offset(axisX + 5, labelY - textPainter.height / 2));

      canvas.drawLine(
          Offset(axisX - 3, labelY), Offset(axisX + 3, labelY), linePaint);
    }
  }

  @override
  bool shouldRepaint(_CandlestickChartPainter oldDelegate) =>
      oldDelegate.data != data;
}
