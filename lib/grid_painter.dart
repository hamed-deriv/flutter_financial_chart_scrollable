import 'package:flutter/material.dart';

import 'package:flutter_financial_chart/candle_stick_model.dart';

class GridPainter extends StatelessWidget {
  const GridPainter({required this.data});

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

    const double chartPadding = 10;
    final double chartWidth = width - chartPadding * 2;
    final double chartHeight = height - chartPadding * 2;

    final Paint gridLinePaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw horizontal grid lines.
    final double gridLineSpacing = chartHeight / 4;
    for (int i = 0; i <= 4; i++) {
      final double y = chartPadding + i * gridLineSpacing;

      canvas.drawLine(
        Offset(0, y),
        Offset(width + chartPadding, y),
        gridLinePaint,
      );
    }

    // Draw vertical grid lines.
    final double candleSpacing = chartWidth / (data.length - 1);
    for (int i = 0; i < data.length; i += 4) {
      final double x = chartPadding + i * candleSpacing;

      canvas.drawLine(
        Offset(x, 0),
        Offset(x, height - chartPadding),
        gridLinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CandlestickChartPainter oldDelegate) =>
      oldDelegate.data != data;
}
