import 'dart:math';

import 'package:flutter/material.dart';

import 'package:namikibun/constants/app_constants.dart';

/// 波キャラクター「なみちゃん」アイコン
/// ぷっくり丸い雫型ボディ、大きな目にハイライト2点、ほっぺ付き。
class MoodWaveIcon extends StatelessWidget {
  const MoodWaveIcon({
    super.key,
    required this.level,
    this.size = 48.0,
    this.showShadow = true,
  });

  final int level;
  final double size;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _MoodWavePainter(
        level: level.clamp(1, 5),
        color: AppConstants.moodColors[level.clamp(1, 5)]!,
        showShadow: showShadow,
      ),
    );
  }
}

/// グラフ軸用の簡略版アイコン（波シルエット+色のみ）
class MoodWaveIconMini extends StatelessWidget {
  const MoodWaveIconMini({
    super.key,
    required this.level,
    this.size = 16.0,
  });

  final int level;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _MoodWaveMiniPainter(
        level: level.clamp(1, 5),
        color: AppConstants.moodColors[level.clamp(1, 5)]!,
      ),
    );
  }
}

class _MoodWavePainter extends CustomPainter {
  _MoodWavePainter({
    required this.level,
    required this.color,
    required this.showShadow,
  });

  final int level;
  final Color color;
  final bool showShadow;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ソフトシャドウ
    if (showShadow) {
      final shadowPaint = Paint()
        ..color = color.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      _drawDropletBody(canvas, w, h, shadowPaint, dy: 2);
    }

    // ボディグラデーション（上が明るく、下が暗い）
    final bodyRect = Rect.fromLTWH(0, 0, w, h);
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(color, Colors.white, 0.25)!,
          color,
          Color.lerp(color, Colors.black, 0.1)!,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(bodyRect)
      ..style = PaintingStyle.fill;
    _drawDropletBody(canvas, w, h, bodyPaint);

    // ボディハイライト（白い楕円）
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.save();
    canvas.translate(w * 0.35, h * 0.3);
    canvas.rotate(-0.3);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: w * 0.2, height: w * 0.35),
      highlightPaint,
    );
    canvas.restore();

    // 顔を描画
    _drawFace(canvas, w, h);

    // L5: しぶきエフェクト
    if (level == 5) {
      final splashPaint = Paint()
        ..color = color.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(w * 0.2, h * 0.2), w * 0.03, splashPaint);
      canvas.drawCircle(Offset(w * 0.82, h * 0.15), w * 0.025, splashPaint);
      canvas.drawCircle(Offset(w * 0.78, h * 0.28), w * 0.02, splashPaint);
    }
  }

  /// 雫型のぷっくりボディ
  void _drawDropletBody(Canvas canvas, double w, double h, Paint paint, {double dy = 0}) {
    final path = Path();

    // 波の高さをレベルで変える
    final topY = switch (level) {
      5 => h * 0.12,
      4 => h * 0.18,
      3 => h * 0.25,
      2 => h * 0.30,
      _ => h * 0.35,
    };

    // 雫型: 上部は丸い頭、下部は広がる丸いボディ
    final cx = w * 0.5;
    final bottomY = h * 0.92 + dy;
    final bodyWidth = w * 0.42;

    path.moveTo(cx, topY + dy);
    // 左側カーブ
    path.cubicTo(
      cx - bodyWidth * 0.5, topY + dy,
      cx - bodyWidth, h * 0.45 + dy,
      cx - bodyWidth, h * 0.65 + dy,
    );
    // 左下の丸み
    path.cubicTo(
      cx - bodyWidth, h * 0.82 + dy,
      cx - bodyWidth * 0.6, bottomY,
      cx, bottomY,
    );
    // 右下の丸み
    path.cubicTo(
      cx + bodyWidth * 0.6, bottomY,
      cx + bodyWidth, h * 0.82 + dy,
      cx + bodyWidth, h * 0.65 + dy,
    );
    // 右側カーブ
    path.cubicTo(
      cx + bodyWidth, h * 0.45 + dy,
      cx + bodyWidth * 0.5, topY + dy,
      cx, topY + dy,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawFace(Canvas canvas, double w, double h) {
    // 顔の位置（下寄りに配置）
    final faceY = h * 0.58;
    final faceCx = w * 0.5;
    final eyeSpacing = w * 0.13;
    final eyeSize = w * 0.055;

    // ほっぺ（全レベル共通、薄いピンク）
    final cheekPaint = Paint()
      ..color = const Color(0xFFFF9999).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(faceCx - eyeSpacing - w * 0.04, faceY + w * 0.08),
        width: w * 0.1,
        height: w * 0.06,
      ),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(faceCx + eyeSpacing + w * 0.04, faceY + w * 0.08),
        width: w * 0.1,
        height: w * 0.06,
      ),
      cheekPaint,
    );

    switch (level) {
      case 5:
        // キラキラ目（大きな丸目+ハイライト2点）
        _drawBigEye(canvas, Offset(faceCx - eyeSpacing, faceY), eyeSize * 1.3,
            sparkle: true);
        _drawBigEye(canvas, Offset(faceCx + eyeSpacing, faceY), eyeSize * 1.3,
            sparkle: true);
        // 大きなにっこり
        _drawSmile(canvas, Offset(faceCx, faceY + w * 0.1), w * 0.1, big: true);

      case 4:
        // ニコニコ半月目
        _drawHappyEye(canvas, Offset(faceCx - eyeSpacing, faceY), eyeSize * 1.2);
        _drawHappyEye(canvas, Offset(faceCx + eyeSpacing, faceY), eyeSize * 1.2);
        // 微笑み
        _drawSmile(canvas, Offset(faceCx, faceY + w * 0.09), w * 0.08);

      case 3:
        // まん丸の目+ハイライト
        _drawBigEye(canvas, Offset(faceCx - eyeSpacing, faceY), eyeSize);
        _drawBigEye(canvas, Offset(faceCx + eyeSpacing, faceY), eyeSize);
        // 横一文字の口
        final mouthPaint = Paint()
          ..color = const Color(0xFF5A5A5A)
          ..strokeWidth = w * 0.02
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(faceCx - w * 0.05, faceY + w * 0.1),
          Offset(faceCx + w * 0.05, faceY + w * 0.1),
          mouthPaint,
        );

      case 2:
        // 困り目
        _drawBigEye(canvas, Offset(faceCx - eyeSpacing, faceY), eyeSize,
            droopy: true, isLeft: true);
        _drawBigEye(canvas, Offset(faceCx + eyeSpacing, faceY), eyeSize,
            droopy: true, isLeft: false);
        // への字口
        _drawFrown(canvas, Offset(faceCx, faceY + w * 0.1), w * 0.08);

      default: // 1
        // うるうる目（涙付き）
        _drawBigEye(canvas, Offset(faceCx - eyeSpacing, faceY), eyeSize,
            teary: true);
        _drawBigEye(canvas, Offset(faceCx + eyeSpacing, faceY), eyeSize,
            teary: true);
        // 大きく下がった口
        _drawFrown(canvas, Offset(faceCx, faceY + w * 0.1), w * 0.1, deep: true);
    }
  }

  /// 大きな丸目（ハイライト2点入り）
  void _drawBigEye(Canvas canvas, Offset center, double size, {
    bool sparkle = false,
    bool droopy = false,
    bool teary = false,
    bool isLeft = true,
  }) {
    // 白目
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size * 1.3, whitePaint);

    // 黒目
    final pupilPaint = Paint()
      ..color = const Color(0xFF3A3A3A)
      ..style = PaintingStyle.fill;
    final pupilOffset = droopy
        ? Offset(center.dx, center.dy + size * 0.2)
        : center;
    canvas.drawCircle(pupilOffset, size * 0.85, pupilPaint);

    // ハイライト大（右上）
    final hlPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(pupilOffset.dx + size * 0.3, pupilOffset.dy - size * 0.3),
      size * 0.35,
      hlPaint,
    );
    // ハイライト小（左下）
    canvas.drawCircle(
      Offset(pupilOffset.dx - size * 0.2, pupilOffset.dy + size * 0.2),
      size * 0.18,
      hlPaint,
    );

    // キラキラ追加（L5）
    if (sparkle) {
      final sparklePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;
      // 小さな星型ハイライト
      _drawTinyStar(canvas, Offset(
        pupilOffset.dx + size * 0.5,
        pupilOffset.dy - size * 0.5,
      ), size * 0.2, sparklePaint);
    }

    // 涙（L1）
    if (teary) {
      final tearPaint = Paint()
        ..color = const Color(0xFF88CCFF).withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
      final tearPath = Path();
      final tearStart = Offset(center.dx + size * 0.8, center.dy + size * 0.5);
      tearPath.moveTo(tearStart.dx, tearStart.dy);
      tearPath.quadraticBezierTo(
        tearStart.dx + size * 0.3, tearStart.dy + size * 1.0,
        tearStart.dx, tearStart.dy + size * 1.3,
      );
      tearPath.quadraticBezierTo(
        tearStart.dx - size * 0.3, tearStart.dy + size * 1.0,
        tearStart.dx, tearStart.dy,
      );
      canvas.drawPath(tearPath, tearPaint);
    }

    // 困り眉（L2）- 左右対称にスラント
    if (droopy) {
      final browPaint = Paint()
        ..color = const Color(0xFF5A5A5A)
        ..strokeWidth = size * 0.25
        ..strokeCap = StrokeCap.round;
      if (isLeft) {
        // 左目: 外側が下がる（左下→右上）
        canvas.drawLine(
          Offset(center.dx - size * 0.8, center.dy - size * 1.5),
          Offset(center.dx + size * 0.8, center.dy - size * 1.8),
          browPaint,
        );
      } else {
        // 右目: 外側が下がる（左上→右下）
        canvas.drawLine(
          Offset(center.dx - size * 0.8, center.dy - size * 1.8),
          Offset(center.dx + size * 0.8, center.dy - size * 1.5),
          browPaint,
        );
      }
    }
  }

  void _drawTinyStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    const points = 4;
    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? size : size * 0.4;
      final angle = (i * pi / points) - pi / 2;
      final point = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  /// ニコニコ半月目（L4）
  void _drawHappyEye(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = const Color(0xFF3A3A3A)
      ..strokeWidth = size * 0.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + size * 0.2),
      width: size * 2.0,
      height: size * 1.5,
    );
    canvas.drawArc(rect, pi, pi, false, paint);
  }

  void _drawSmile(Canvas canvas, Offset center, double width, {bool big = false}) {
    final paint = Paint()
      ..color = const Color(0xFF5A5A5A)
      ..strokeWidth = width * 0.18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = big ? 0.8 : 0.6;
    final rect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - width * 0.2),
      width: width * 2,
      height: width * (big ? 1.8 : 1.4),
    );
    canvas.drawArc(rect, pi * (0.5 - sweepAngle / 2), pi * sweepAngle, false, paint);
  }

  void _drawFrown(Canvas canvas, Offset center, double width, {bool deep = false}) {
    final paint = Paint()
      ..color = const Color(0xFF5A5A5A)
      ..strokeWidth = width * 0.18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = deep ? 0.7 : 0.5;
    final rect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + width * (deep ? 0.8 : 0.5)),
      width: width * 2,
      height: width * (deep ? 1.6 : 1.2),
    );
    canvas.drawArc(rect, -pi * (0.5 + sweepAngle / 2), pi * sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_MoodWavePainter oldDelegate) =>
      level != oldDelegate.level || color != oldDelegate.color;
}

/// グラフ軸用の簡略版（雫シルエットのみ）
class _MoodWaveMiniPainter extends CustomPainter {
  _MoodWaveMiniPainter({required this.level, required this.color});

  final int level;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final topY = switch (level) {
      5 => h * 0.05,
      4 => h * 0.15,
      3 => h * 0.25,
      2 => h * 0.35,
      _ => h * 0.45,
    };

    final cx = w * 0.5;
    final bottomY = h * 0.95;
    final bodyW = w * 0.42;

    final path = Path();
    path.moveTo(cx, topY);
    path.cubicTo(cx - bodyW * 0.5, topY, cx - bodyW, h * 0.45, cx - bodyW, h * 0.65);
    path.cubicTo(cx - bodyW, h * 0.82, cx - bodyW * 0.6, bottomY, cx, bottomY);
    path.cubicTo(cx + bodyW * 0.6, bottomY, cx + bodyW, h * 0.82, cx + bodyW, h * 0.65);
    path.cubicTo(cx + bodyW, h * 0.45, cx + bodyW * 0.5, topY, cx, topY);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MoodWaveMiniPainter oldDelegate) =>
      level != oldDelegate.level || color != oldDelegate.color;
}
