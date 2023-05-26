import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_financial_chart/candle_stick_model.dart';

class LineChart extends StatefulWidget {
  const LineChart({required this.data});

  final List<CandleStickModel> data;

  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  Offset? tapPosition;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (TapDownDetails details) {
          setState(() {
            tapPosition = details.localPosition;
          });
        },
        onTapUp: (_) {
          setState(() {
            tapPosition = null;
          });
        },
        child: CustomPaint(
          size: const Size(double.infinity, 200),
          painter: _LineChartPainter(
            data: widget.data,
            tapPosition: tapPosition,
          ),
        ),
      );
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.data, this.tapPosition});

  final List<CandleStickModel> data;
  final Offset? tapPosition;

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double pointSpacing = width / (data.length - 1);

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

    final List<Offset> points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final double pointX = i * pointSpacing;
      final double pointY =
          height - (data[i].close - minPrice) * pricePerPixel - chartPadding;

      points.add(Offset(pointX, pointY));
    }

    canvas.drawPoints(PointMode.polygon, points, linePaint);

    if (tapPosition != null) {
      final ui.Offset? nearestPoint = findNearestPoint(tapPosition!, points);
      if (nearestPoint != null) {
        final double tooltipX = nearestPoint.dx;
        final double tooltipY = nearestPoint.dy - 20;
        const double tooltipWidth = 80;
        const double tooltipHeight = 30;

        final Rect tooltipRect =
            Rect.fromLTWH(tooltipX, tooltipY, tooltipWidth, tooltipHeight);

        final Paint tooltipPaint = Paint()
          ..color = Colors.black.withOpacity(0.8);
        canvas.drawRect(tooltipRect, tooltipPaint);

        final CandleStickModel nearestData = data[points.indexOf(nearestPoint)];

        final ui.ParagraphBuilder tooltipBuilder = ui.ParagraphBuilder(
          ui.ParagraphStyle(
            textAlign: TextAlign.center,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        )
          ..pushStyle(ui.TextStyle(color: Colors.white))
          ..addText('Close: ${nearestData.close.toStringAsFixed(2)}');

        final ui.Paragraph tooltipParagraph = tooltipBuilder.build()
          ..layout(const ui.ParagraphConstraints(width: tooltipWidth));

        canvas.drawParagraph(
          tooltipParagraph,
          Offset(tooltipX + (tooltipWidth - tooltipParagraph.width) / 2,
              tooltipY + (tooltipHeight - tooltipParagraph.height) / 2),
        );
      }
    }
  }

  Offset? findNearestPoint(Offset tapPosition, List<Offset> points) {
    Offset? nearestPoint;
    double minDistance = double.infinity;

    for (final ui.Offset point in points) {
      final double distance = (tapPosition - point).distanceSquared;
      if (distance < minDistance) {
        minDistance = distance;
        nearestPoint = point;
      }
    }

    return nearestPoint;
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.tapPosition != tapPosition;
}
