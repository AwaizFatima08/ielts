import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ielts_simulator/content/models/papers.dart';
import 'package:ielts_simulator/ui/theme.dart';

const _seriesColors = [
  Color(0xFF1B3557),
  Color(0xFFC8102E),
  Color(0xFF2E8B57),
  Color(0xFFE08A00),
  Color(0xFF7B4FA0),
  Color(0xFF3A8FB7),
];

/// Academic Writing Task 1 visual, drawn from a [ChartSpec].
class TaskChart extends StatelessWidget {
  const TaskChart({required this.spec, super.key});

  final ChartSpec spec;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: DefaultTextStyle(
          style: textTheme.bodySmall!.copyWith(color: Colors.black87),
          child: Column(
            children: [
              Text(
                spec.title,
                textAlign: TextAlign.center,
                style: textTheme.titleSmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (spec.kind == ChartKind.table)
                _DataTable(spec: spec)
              else ...[
                AspectRatio(
                  aspectRatio: spec.kind == ChartKind.pie ? 1.4 : 1.5,
                  child: CustomPaint(painter: _ChartPainter(spec)),
                ),
                const SizedBox(height: AppSpacing.sm),
                _Legend(spec: spec),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.spec});

  final ChartSpec spec;

  @override
  Widget build(BuildContext context) {
    final names = spec.kind == ChartKind.pie
        ? spec.xLabels
        : [for (final series in spec.series) series.name];
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      alignment: WrapAlignment.center,
      children: [
        for (final (index, name) in names.indexed)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 12, height: 12, color: _seriesColors[index % _seriesColors.length]),
              const SizedBox(width: AppSpacing.xs),
              Text(name),
            ],
          ),
      ],
    );
  }
}

class _DataTable extends StatelessWidget {
  const _DataTable({required this.spec});

  final ChartSpec spec;

  String _format(double value) =>
      '${value == value.roundToDouble() ? value.toInt() : value}${spec.unit ?? ''}';

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Table(
      border: TableBorder.all(color: Colors.black45),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        TableRow(
          children: [
            const SizedBox.shrink(),
            for (final label in spec.xLabels) _Cell(label, bold: true),
          ],
        ),
        for (final series in spec.series)
          TableRow(
            children: [
              _Cell(series.name, bold: true),
              for (final value in series.values) _Cell(_format(value)),
            ],
          ),
      ],
    ),
  );
}

class _Cell extends StatelessWidget {
  const _Cell(this.text, {this.bold = false});

  final String text;
  final bool bold;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.all(6),
    child: Text(text, style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
  );
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.spec);

  final ChartSpec spec;
  static const _left = 44.0;
  static const _bottom = 28.0;

  @override
  void paint(Canvas canvas, Size size) => switch (spec.kind) {
    ChartKind.pie => _paintPie(canvas, size),
    ChartKind.bar || ChartKind.line => _paintAxes(canvas, size),
    ChartKind.table => null,
  };

  double get _maxValue {
    final top = spec.series.expand((series) => series.values).fold<double>(0, math.max);
    final step = _niceStep(top);
    return (top / step).ceil() * step;
  }

  double _niceStep(double top) {
    if (top <= 0) return 1;
    final rough = top / 5;
    final magnitude = math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
    return [
      1,
      2,
      2.5,
      5,
      10,
    ].map((factor) => factor * magnitude).firstWhere((step) => step >= rough);
  }

  void _label(Canvas canvas, String text, Offset at, {bool centred = true, double fontSize = 10}) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.black87, fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      centred ? at - Offset(painter.width / 2, 0) : at - Offset(painter.width, painter.height / 2),
    );
  }

  void _paintAxes(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(_left, 8, size.width - 8, size.height - _bottom);
    final axis = Paint()..color = Colors.black54;
    final grid = Paint()..color = Colors.black12;
    final top = _maxValue;
    final step = _niceStep(top);
    for (var value = 0.0; value <= top + 0.001; value += step) {
      final y = plot.bottom - value / top * plot.height;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
      _label(
        canvas,
        '${value == value.roundToDouble() ? value.toInt() : value}${spec.unit ?? ''}',
        Offset(plot.left - 4, y),
        centred: false,
      );
    }
    canvas
      ..drawLine(plot.bottomLeft, plot.bottomRight, axis)
      ..drawLine(plot.bottomLeft, plot.topLeft, axis);
    final slot = plot.width / spec.xLabels.length;
    for (final (index, label) in spec.xLabels.indexed) {
      _label(canvas, label, Offset(plot.left + slot * (index + 0.5), plot.bottom + 6));
    }
    if (spec.kind == ChartKind.bar) {
      _paintBars(canvas, plot, slot, top);
    } else {
      _paintLines(canvas, plot, slot, top);
    }
  }

  void _paintBars(Canvas canvas, Rect plot, double slot, double top) {
    final barWidth = slot * 0.8 / spec.series.length;
    for (final (seriesIndex, series) in spec.series.indexed) {
      final paint = Paint()..color = _seriesColors[seriesIndex % _seriesColors.length];
      for (final (index, value) in series.values.indexed) {
        final left = plot.left + slot * index + slot * 0.1 + barWidth * seriesIndex;
        canvas.drawRect(
          Rect.fromLTRB(
            left,
            plot.bottom - value / top * plot.height,
            left + barWidth,
            plot.bottom,
          ),
          paint,
        );
      }
    }
  }

  void _paintLines(Canvas canvas, Rect plot, double slot, double top) {
    for (final (seriesIndex, series) in spec.series.indexed) {
      final color = _seriesColors[seriesIndex % _seriesColors.length];
      final stroke = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      final points = [
        for (final (index, value) in series.values.indexed)
          Offset(plot.left + slot * (index + 0.5), plot.bottom - value / top * plot.height),
      ];
      canvas.drawPath(Path()..addPolygon(points, false), stroke);
      for (final point in points) {
        canvas.drawCircle(point, 3, Paint()..color = color);
      }
    }
  }

  void _paintPie(Canvas canvas, Size size) {
    final values = spec.series.first.values;
    final total = values.fold<double>(0, (sum, value) => sum + value);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final centre = size.center(Offset.zero);
    var angle = -math.pi / 2;
    for (final (index, value) in values.indexed) {
      final sweep = value / total * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: radius),
        angle,
        sweep,
        true,
        Paint()..color = _seriesColors[index % _seriesColors.length],
      );
      final middle = angle + sweep / 2;
      final at = centre + Offset(math.cos(middle), math.sin(middle)) * radius * 0.65;
      final text = '${value == value.roundToDouble() ? value.toInt() : value}${spec.unit ?? ''}';
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
      angle += sweep;
    }
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) => oldDelegate.spec != spec;
}
