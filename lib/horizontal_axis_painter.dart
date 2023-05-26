import 'package:flutter/material.dart';

import 'package:flutter_financial_chart/candle_stick_model.dart';

class HorizontalAxisPainter extends StatelessWidget {
  const HorizontalAxisPainter({required this.data});

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

    const double chartPadding = 10;

    final Paint linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Draw horizontal axis line
    canvas.drawLine(
      Offset(0, height - chartPadding),
      Offset(width + candleWidth / 2, height - chartPadding),
      linePaint,
    );

    // Draw X-axis labels
    final double labelY = height - chartPadding + 5;
    for (int i = 0; i < data.length; i++) {
      final double candleX = i * candleWidth + candleWidth / 2;

      final TextSpan span = TextSpan(
        text: data[i].label,
        style: const TextStyle(fontSize: 10, color: Colors.black),
      );

      textPainter
        ..text = span
        ..layout();

      canvas
        ..save()
        ..translate(candleX, labelY)
        ..rotate(90 * 3.14159 / 180);

      textPainter.paint(
        canvas,
        Offset(-textPainter.height / 2 + 8, -textPainter.height / 2),
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CandlestickChartPainter oldDelegate) =>
      oldDelegate.data != data;
}
