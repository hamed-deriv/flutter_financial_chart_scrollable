import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:flutter_financial_chart/candle_stick_model.dart';

class CandleStickChart extends StatefulWidget {
  const CandleStickChart({required this.data});

  final List<CandleStickModel> data;

  @override
  _CandleStickChartState createState() => _CandleStickChartState();
}

class _CandleStickChartState extends State<CandleStickChart> {
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
          painter: _CandlestickChartPainter(
            data: widget.data,
            tapPosition: tapPosition,
          ),
        ),
      );
}

class _CandlestickChartPainter extends CustomPainter {
  _CandlestickChartPainter({required this.data, this.tapPosition});

  final List<CandleStickModel> data;
  final Offset? tapPosition;

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

    final Paint positiveCandlePaint = Paint()..color = Colors.green;
    final Paint negativeCandlePaint = Paint()..color = Colors.red;
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

    for (int i = 0; i < data.length; i++) {
      final double candleX = i * candleWidth + candleWidth / 2;
      final CandleStickModel candle = data[i];
      final double candleYHigh =
          height - (candle.high - minPrice) * pricePerPixel - chartPadding;
      final double candleYLow =
          height - (candle.low - minPrice) * pricePerPixel - chartPadding;
      final double candleYOpen =
          height - (candle.open - minPrice) * pricePerPixel - chartPadding;
      final double candleYClose =
          height - (candle.close - minPrice) * pricePerPixel - chartPadding;

      canvas.drawLine(
          Offset(candleX, candleYHigh), Offset(candleX, candleYLow), linePaint);

      final double candleTop =
          candleYOpen < candleYClose ? candleYOpen : candleYClose;
      final double candleBottom =
          candleYOpen < candleYClose ? candleYClose : candleYOpen;

      final double candleHeight = candleBottom - candleTop;

      final Rect candleRect = Rect.fromLTRB(
        candleX - candleWidth / 4,
        candleTop,
        candleX + candleWidth / 4,
        candleTop + candleHeight,
      );

      final Paint candlePaint = candle.close > candle.open
          ? positiveCandlePaint
          : negativeCandlePaint;
      canvas.drawRect(candleRect, candlePaint);

      if (tapPosition != null && candleRect.contains(tapPosition!)) {
        const double tooltipWidth = 80;
        const double tooltipHeight = 30;

        final double tooltipX = candleX - tooltipWidth / 2;
        final double tooltipY = candleTop - tooltipHeight - 5;
        final Rect tooltipRect =
            Rect.fromLTWH(tooltipX, tooltipY, tooltipWidth, tooltipHeight);

        final Paint tooltipPaint = Paint()
          ..color = Colors.black.withOpacity(0.8);
        canvas.drawRect(tooltipRect, tooltipPaint);

        final ui.ParagraphBuilder tooltipBuilder = ui.ParagraphBuilder(
          ui.ParagraphStyle(
            textAlign: TextAlign.center,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        )
          ..pushStyle(ui.TextStyle(color: Colors.white))
          ..addText(
            'Open: ${candle.open.toStringAsFixed(2)}\nClose: ${candle.close.toStringAsFixed(2)}',
          );

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

  @override
  bool shouldRepaint(_CandlestickChartPainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.tapPosition != tapPosition;
}
