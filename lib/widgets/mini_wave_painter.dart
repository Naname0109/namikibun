import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/models/mood_record.dart';

/// カレンダーセル内に描画するミニ波形（CustomPainter）
class MiniWavePainter extends CustomPainter {
  MiniWavePainter({required this.records});

  final List<MoodRecord> records;

  @override
  void paint(Canvas canvas, Size size) {
    if (records.isEmpty) {
      _drawDashedLine(canvas, size);
      return;
    }

    // スロットのorder_indexでソートされている前提（DBのorderBy）
    final points = <Offset>[];
    for (int i = 0; i < records.length; i++) {
      final x = records.length == 1
          ? size.width / 2
          : i * size.width / (records.length - 1);
      // Y軸: moodLevel 1(下)→5(上)
      final y = size.height -
          ((records[i].moodLevel - 1) / 4) * size.height * 0.8 -
          size.height * 0.1;
      points.add(Offset(x, y));
    }

    final paint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // グラデーション色
    final colors = records
        .map((r) => AppConstants.moodColors[r.moodLevel]!)
        .toList();

    if (records.length == 1) {
      // 1点: ドットのみ
      final dotPaint = Paint()
        ..color = colors.first
        ..style = PaintingStyle.fill;
      canvas.drawCircle(points.first, 3, dotPaint);
      return;
    }

    // 2点以上: 線を描画
    if (colors.length >= 2) {
      paint.shader = ui.Gradient.linear(
        points.first,
        points.last,
        colors,
      );
    } else {
      paint.color = colors.first;
    }

    if (records.length == 2) {
      // 2点: 直線
      canvas.drawLine(points[0], points[1], paint);
    } else {
      // 3点以上: Catmull-Rom スプライン曲線
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = i > 0 ? points[i - 1] : points[i];
        final p1 = points[i];
        final p2 = points[i + 1];
        final p3 = i + 2 < points.length ? points[i + 2] : points[i + 1];

        const tension = 1.0;
        final cp1x = p1.dx + (p2.dx - p0.dx) / 6 * tension;
        final cp1y = p1.dy + (p2.dy - p0.dy) / 6 * tension;
        final cp2x = p2.dx - (p3.dx - p1.dx) / 6 * tension;
        final cp2y = p2.dy - (p3.dy - p1.dy) / 6 * tension;

        path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
      }

      canvas.drawPath(path, paint);
    }

    // ドットを描画
    for (int i = 0; i < points.length; i++) {
      final dotPaint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;
      canvas.drawCircle(points[i], 2, dotPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final y = size.height / 2;
    const dashWidth = 3.0;
    const dashSpace = 3.0;
    double x = 0;

    while (x < size.width) {
      canvas.drawLine(
        Offset(x, y),
        Offset((x + dashWidth).clamp(0, size.width), y),
        paint,
      );
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(MiniWavePainter oldDelegate) {
    return oldDelegate.records != records;
  }
}

/// ミニ波形を表示するウィジェット
class MiniWaveWidget extends StatelessWidget {
  const MiniWaveWidget({
    super.key,
    required this.records,
    this.width = 40,
    this.height = 24,
  });

  final List<MoodRecord> records;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: MiniWavePainter(records: records),
    );
  }
}
