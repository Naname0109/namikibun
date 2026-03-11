import 'dart:math';

import 'package:flutter/material.dart';

import 'package:namikibun/constants/app_constants.dart';

/// 波キャラクター「なみちゃん」アイコン
/// 波の形が体で、その上にかわいい顔がある。
/// 波の高さ・勢い・形で気分を直感的に表現する。
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
    // ソフトシャドウ
    if (showShadow) {
      final shadowPaint = Paint()
        ..color = color.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      _drawWaveBody(canvas, size, shadowPaint, dy: 2);
    }

    // 波の体を描画
    final bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    _drawWaveBody(canvas, size, bodyPaint);

    // 顔を描画
    _drawFace(canvas, size);
  }

  void _drawWaveBody(Canvas canvas, Size size, Paint paint, {double dy = 0}) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    // 波の高さをレベルに応じて変える
    // L1: 低い, L5: 高い
    final waveTop = switch (level) {
      5 => h * 0.15, // 大きく跳ね上がる
      4 => h * 0.25, // ゆるやかに高い
      3 => h * 0.38, // 平坦
      2 => h * 0.45, // 低い
      _ => h * 0.52, // しぼんだ
    };

    final baseY = h * 0.85 + dy;

    switch (level) {
      case 5:
        // 大きく跳ね上がる元気な波
        path.moveTo(0, baseY);
        path.quadraticBezierTo(w * 0.15, baseY, w * 0.25, h * 0.55 + dy);
        path.quadraticBezierTo(w * 0.38, waveTop + dy - h * 0.05, w * 0.5, waveTop + dy);
        path.quadraticBezierTo(w * 0.62, waveTop + dy + h * 0.05, w * 0.75, h * 0.45 + dy);
        path.quadraticBezierTo(w * 0.88, h * 0.6 + dy, w, baseY);
        path.lineTo(w, h + dy);
        path.lineTo(0, h + dy);
        path.close();

      case 4:
        // ゆるやかに高い波
        path.moveTo(0, baseY);
        path.quadraticBezierTo(w * 0.2, h * 0.5 + dy, w * 0.35, h * 0.35 + dy);
        path.quadraticBezierTo(w * 0.5, waveTop + dy, w * 0.65, h * 0.35 + dy);
        path.quadraticBezierTo(w * 0.8, h * 0.5 + dy, w, baseY);
        path.lineTo(w, h + dy);
        path.lineTo(0, h + dy);
        path.close();

      case 3:
        // 平坦で穏やかな波
        path.moveTo(0, baseY);
        path.quadraticBezierTo(w * 0.2, h * 0.5 + dy, w * 0.35, waveTop + dy);
        path.quadraticBezierTo(w * 0.5, waveTop - h * 0.02 + dy, w * 0.65, waveTop + dy);
        path.quadraticBezierTo(w * 0.8, h * 0.5 + dy, w, baseY);
        path.lineTo(w, h + dy);
        path.lineTo(0, h + dy);
        path.close();

      case 2:
        // 低くうねった波
        path.moveTo(0, baseY);
        path.quadraticBezierTo(w * 0.15, h * 0.6 + dy, w * 0.3, waveTop + dy);
        path.quadraticBezierTo(w * 0.45, h * 0.55 + dy, w * 0.55, h * 0.5 + dy);
        path.quadraticBezierTo(w * 0.7, waveTop + dy + h * 0.05, w * 0.85, h * 0.55 + dy);
        path.quadraticBezierTo(w * 0.92, h * 0.65 + dy, w, baseY);
        path.lineTo(w, h + dy);
        path.lineTo(0, h + dy);
        path.close();

      default: // 1
        // しぼんだ小さな波
        path.moveTo(0, baseY);
        path.quadraticBezierTo(w * 0.25, h * 0.6 + dy, w * 0.4, waveTop + dy);
        path.quadraticBezierTo(w * 0.5, waveTop - h * 0.02 + dy, w * 0.6, waveTop + dy);
        path.quadraticBezierTo(w * 0.75, h * 0.6 + dy, w, baseY);
        path.lineTo(w, h + dy);
        path.lineTo(0, h + dy);
        path.close();
    }

    canvas.drawPath(path, paint);

    // L5: しぶきエフェクト
    if (level == 5 && paint.style == PaintingStyle.fill && paint.maskFilter == null) {
      final splashPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(w * 0.38, waveTop + dy - h * 0.04), w * 0.03, splashPaint);
      canvas.drawCircle(Offset(w * 0.55, waveTop + dy - h * 0.06), w * 0.02, splashPaint);
      canvas.drawCircle(Offset(w * 0.62, waveTop + dy - h * 0.02), w * 0.025, splashPaint);
    }
  }

  void _drawFace(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 顔の位置（波の頂上付近）
    final faceY = switch (level) {
      5 => h * 0.28,
      4 => h * 0.35,
      3 => h * 0.45,
      2 => h * 0.52,
      _ => h * 0.58,
    };
    final faceCx = w * 0.5;
    final eyeSpacing = w * 0.12;
    final eyeSize = w * 0.04;

    final facePaint = Paint()..style = PaintingStyle.fill;

    switch (level) {
      case 5:
        // キラキラした目（星型ハイライト）
        _drawStarEye(canvas, Offset(faceCx - eyeSpacing, faceY), eyeSize * 1.3);
        _drawStarEye(canvas, Offset(faceCx + eyeSpacing, faceY), eyeSize * 1.3);
        // 大きなにっこり口
        _drawSmile(canvas, Offset(faceCx, faceY + w * 0.08), w * 0.1, big: true);

      case 4:
        // ニコニコ半月目
        _drawHalfMoonEye(canvas, Offset(faceCx - eyeSpacing, faceY), eyeSize * 1.2);
        _drawHalfMoonEye(canvas, Offset(faceCx + eyeSpacing, faceY), eyeSize * 1.2);
        // やさしい微笑み
        _drawSmile(canvas, Offset(faceCx, faceY + w * 0.07), w * 0.08);

      case 3:
        // まん丸の目
        facePaint.color = Colors.white;
        canvas.drawCircle(Offset(faceCx - eyeSpacing, faceY), eyeSize, facePaint);
        canvas.drawCircle(Offset(faceCx + eyeSpacing, faceY), eyeSize, facePaint);
        facePaint.color = const Color(0xFF4A4A4A);
        canvas.drawCircle(Offset(faceCx - eyeSpacing, faceY), eyeSize * 0.6, facePaint);
        canvas.drawCircle(Offset(faceCx + eyeSpacing, faceY), eyeSize * 0.6, facePaint);
        // 横一文字の口
        final mouthPaint = Paint()
          ..color = const Color(0xFF4A4A4A)
          ..strokeWidth = w * 0.02
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(faceCx - w * 0.05, faceY + w * 0.08),
          Offset(faceCx + w * 0.05, faceY + w * 0.08),
          mouthPaint,
        );

      case 2:
        // 下がり気味の目
        _drawSadEye(canvas, Offset(faceCx - eyeSpacing, faceY), eyeSize, isLeft: true);
        _drawSadEye(canvas, Offset(faceCx + eyeSpacing, faceY), eyeSize, isLeft: false);
        // への字口
        _drawFrown(canvas, Offset(faceCx, faceY + w * 0.08), w * 0.08);

      default: // 1
        // 涙が一滴垂れる目
        _drawCryingEye(canvas, Offset(faceCx - eyeSpacing, faceY), eyeSize, withTear: true);
        _drawCryingEye(canvas, Offset(faceCx + eyeSpacing, faceY), eyeSize, withTear: false);
        // 大きく下がった口
        _drawFrown(canvas, Offset(faceCx, faceY + w * 0.08), w * 0.1, deep: true);
    }
  }

  void _drawStarEye(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

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

  void _drawHalfMoonEye(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 半月目（下半分の弧）
    final rect = Rect.fromCenter(center: center, width: size * 2.2, height: size * 1.8);
    canvas.drawArc(rect, 0, -pi, true, paint);
  }

  void _drawSmile(Canvas canvas, Offset center, double width, {bool big = false}) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = width * 0.2
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

  void _drawSadEye(Canvas canvas, Offset center, double size, {required bool isLeft}) {
    // 白目
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size, whitePaint);

    // 黒目（少し下に）
    final pupilPaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx, center.dy + size * 0.2), size * 0.55, pupilPaint);

    // 下がった眉
    final browPaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..strokeWidth = size * 0.35
      ..strokeCap = StrokeCap.round;
    final browStart = isLeft
        ? Offset(center.dx - size * 1.2, center.dy - size * 0.8)
        : Offset(center.dx - size * 0.6, center.dy - size * 1.2);
    final browEnd = isLeft
        ? Offset(center.dx + size * 0.6, center.dy - size * 1.2)
        : Offset(center.dx + size * 1.2, center.dy - size * 0.8);
    canvas.drawLine(browStart, browEnd, browPaint);
  }

  void _drawCryingEye(Canvas canvas, Offset center, double size, {required bool withTear}) {
    // 閉じた目（横線、少し下がった弧）
    final eyePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = size * 0.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + size * 0.3),
      width: size * 2.5,
      height: size * 1.5,
    );
    canvas.drawArc(rect, -pi * 0.8, pi * 0.6, false, eyePaint);

    // 涙
    if (withTear) {
      final tearPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;
      final tearPath = Path();
      final tearTop = Offset(center.dx + size * 0.3, center.dy + size * 0.8);
      tearPath.moveTo(tearTop.dx, tearTop.dy);
      tearPath.quadraticBezierTo(
        tearTop.dx + size * 0.5, tearTop.dy + size * 1.5,
        tearTop.dx, tearTop.dy + size * 2.0,
      );
      tearPath.quadraticBezierTo(
        tearTop.dx - size * 0.5, tearTop.dy + size * 1.5,
        tearTop.dx, tearTop.dy,
      );
      canvas.drawPath(tearPath, tearPaint);
    }
  }

  void _drawFrown(Canvas canvas, Offset center, double width, {bool deep = false}) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = width * 0.2
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

/// グラフ軸用の簡略版（波シルエットのみ）
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

    final waveTop = switch (level) {
      5 => h * 0.1,
      4 => h * 0.2,
      3 => h * 0.35,
      2 => h * 0.45,
      _ => h * 0.55,
    };

    final path = Path();
    path.moveTo(0, h);
    path.quadraticBezierTo(w * 0.25, h * 0.7, w * 0.4, waveTop);
    path.quadraticBezierTo(w * 0.5, waveTop - h * 0.05, w * 0.6, waveTop);
    path.quadraticBezierTo(w * 0.75, h * 0.7, w, h);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MoodWaveMiniPainter oldDelegate) =>
      level != oldDelegate.level || color != oldDelegate.color;
}
