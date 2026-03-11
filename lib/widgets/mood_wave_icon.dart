import 'dart:math';

import 'package:flutter/material.dart';

import 'package:namikibun/constants/app_constants.dart';

/// 波キャラクター「なみちゃん」アイコン
/// 上部が波の形（波頭がカール）、下部はぷっくり丸い。
/// 表情・ほっぺ・ハイライトで可愛さを表現。
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

    // 泡・しぶき（レベルに応じて量が変わる）
    _drawFoam(canvas, w, h);

    // ボディハイライト（白い楕円、さりげなく）
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    canvas.save();
    canvas.translate(w * 0.3, h * 0.45);
    canvas.rotate(-0.3);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: w * 0.1, height: w * 0.15),
      highlightPaint,
    );
    canvas.restore();

    // 顔を描画
    _drawFace(canvas, w, h);
  }

  /// 雫型ボディ: 上部が尖り、下部がぷっくり丸い
  void _drawDropletBody(Canvas canvas, double w, double h, Paint paint, {double dy = 0}) {
    final path = Path();

    // レベルに応じた頂点の高さ
    final tipY = switch (level) {
      5 => h * 0.05,
      4 => h * 0.12,
      3 => h * 0.20,
      2 => h * 0.28,
      _ => h * 0.35,
    };

    final bottomY = h * 0.92 + dy;
    final cx = w * 0.5;
    final bodyWidth = w * 0.38;

    // 雫の頂点から開始
    path.moveTo(cx, tipY + dy);

    // 右側カーブ（頂点→右ふくらみ→底）
    path.cubicTo(
      cx + bodyWidth * 0.3, tipY + h * 0.15 + dy,
      cx + bodyWidth, h * 0.45 + dy,
      cx + bodyWidth, h * 0.65 + dy,
    );

    // 右下の丸み
    path.cubicTo(
      cx + bodyWidth, h * 0.82 + dy,
      cx + bodyWidth * 0.7, bottomY,
      cx, bottomY,
    );

    // 左下の丸み
    path.cubicTo(
      cx - bodyWidth * 0.7, bottomY,
      cx - bodyWidth, h * 0.82 + dy,
      cx - bodyWidth, h * 0.65 + dy,
    );

    // 左側カーブ（底→左ふくらみ→頂点）
    path.cubicTo(
      cx - bodyWidth, h * 0.45 + dy,
      cx - bodyWidth * 0.3, tipY + h * 0.15 + dy,
      cx, tipY + dy,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  /// 白い泡・しぶき（レベルが高いほど多い）
  void _drawFoam(Canvas canvas, double w, double h) {
    if (level <= 1) return; // L1は泡なし

    final foamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final foamPaintLight = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final tipY = switch (level) {
      5 => h * 0.05,
      4 => h * 0.12,
      3 => h * 0.20,
      2 => h * 0.28,
      _ => h * 0.35,
    };

    if (level >= 2) {
      // 小さな泡1つ
      canvas.drawCircle(Offset(w * 0.55, tipY + h * 0.02), w * 0.03, foamPaintLight);
    }
    if (level >= 3) {
      // 泡2つ追加
      canvas.drawCircle(Offset(w * 0.42, tipY - h * 0.01), w * 0.035, foamPaint);
      canvas.drawCircle(Offset(w * 0.6, tipY + h * 0.05), w * 0.025, foamPaintLight);
    }
    if (level >= 4) {
      // さらに追加
      canvas.drawCircle(Offset(w * 0.35, tipY + h * 0.03), w * 0.03, foamPaint);
      canvas.drawCircle(Offset(w * 0.65, tipY - h * 0.01), w * 0.028, foamPaintLight);
    }
    if (level == 5) {
      // L5: たっぷり泡
      canvas.drawCircle(Offset(w * 0.48, tipY - h * 0.04), w * 0.04, foamPaint);
      canvas.drawCircle(Offset(w * 0.3, tipY + h * 0.06), w * 0.025, foamPaintLight);
      canvas.drawCircle(Offset(w * 0.7, tipY + h * 0.02), w * 0.03, foamPaint);
    }
  }

  void _drawFace(Canvas canvas, double w, double h) {
    // 顔の位置（雫型ボディの中央～やや下）
    final faceY = h * 0.65;
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
        _drawBigEye(canvas, Offset(faceCx - eyeSpacing, faceY), eyeSize * 1.3,
            sparkle: true);
        _drawBigEye(canvas, Offset(faceCx + eyeSpacing, faceY), eyeSize * 1.3,
            sparkle: true);
        _drawSmile(canvas, Offset(faceCx, faceY + w * 0.1), w * 0.1, big: true);

      case 4:
        _drawHappyEye(canvas, Offset(faceCx - eyeSpacing, faceY), eyeSize * 1.2);
        _drawHappyEye(canvas, Offset(faceCx + eyeSpacing, faceY), eyeSize * 1.2);
        _drawSmile(canvas, Offset(faceCx, faceY + w * 0.09), w * 0.08);

      case 3:
        _drawBigEye(canvas, Offset(faceCx - eyeSpacing, faceY), eyeSize);
        _drawBigEye(canvas, Offset(faceCx + eyeSpacing, faceY), eyeSize);
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
        _drawBigEye(canvas, Offset(faceCx - eyeSpacing, faceY), eyeSize,
            droopy: true, isLeft: true);
        _drawBigEye(canvas, Offset(faceCx + eyeSpacing, faceY), eyeSize,
            droopy: true, isLeft: false);
        _drawFrown(canvas, Offset(faceCx, faceY + w * 0.1), w * 0.08);

      default: // 1
        _drawBigEye(canvas, Offset(faceCx - eyeSpacing, faceY), eyeSize,
            teary: true);
        _drawBigEye(canvas, Offset(faceCx + eyeSpacing, faceY), eyeSize,
            teary: true);
        _drawFrown(canvas, Offset(faceCx, faceY + w * 0.1), w * 0.1, deep: true);
    }
  }

  void _drawBigEye(Canvas canvas, Offset center, double size, {
    bool sparkle = false,
    bool droopy = false,
    bool teary = false,
    bool isLeft = true,
  }) {
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size * 1.3, whitePaint);

    final pupilPaint = Paint()
      ..color = const Color(0xFF3A3A3A)
      ..style = PaintingStyle.fill;
    final pupilOffset = droopy
        ? Offset(center.dx, center.dy + size * 0.2)
        : center;
    canvas.drawCircle(pupilOffset, size * 0.85, pupilPaint);

    final hlPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(pupilOffset.dx + size * 0.3, pupilOffset.dy - size * 0.3),
      size * 0.35,
      hlPaint,
    );
    canvas.drawCircle(
      Offset(pupilOffset.dx - size * 0.2, pupilOffset.dy + size * 0.2),
      size * 0.18,
      hlPaint,
    );

    if (sparkle) {
      final sparklePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;
      _drawTinyStar(canvas, Offset(
        pupilOffset.dx + size * 0.5,
        pupilOffset.dy - size * 0.5,
      ), size * 0.2, sparklePaint);
    }

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

    if (droopy) {
      final browPaint = Paint()
        ..color = const Color(0xFF5A5A5A)
        ..strokeWidth = size * 0.25
        ..strokeCap = StrokeCap.round;
      if (isLeft) {
        canvas.drawLine(
          Offset(center.dx - size * 0.8, center.dy - size * 1.5),
          Offset(center.dx + size * 0.8, center.dy - size * 1.8),
          browPaint,
        );
      } else {
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

/// グラフ軸用の簡略版（波型シルエット）
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

    // 雫型シルエット（レベルに応じた頂点の高さ）
    final tipY = switch (level) {
      5 => h * 0.05,
      4 => h * 0.15,
      3 => h * 0.25,
      2 => h * 0.35,
      _ => h * 0.42,
    };

    final bottomY = h * 0.95;
    final cx = w * 0.5;
    final bodyWidth = w * 0.4;

    final path = Path();
    path.moveTo(cx, tipY);

    // 右カーブ
    path.cubicTo(
      cx + bodyWidth * 0.3, tipY + h * 0.15,
      cx + bodyWidth, h * 0.45,
      cx + bodyWidth, h * 0.65,
    );
    path.cubicTo(
      cx + bodyWidth, h * 0.82,
      cx + bodyWidth * 0.7, bottomY,
      cx, bottomY,
    );

    // 左カーブ
    path.cubicTo(
      cx - bodyWidth * 0.7, bottomY,
      cx - bodyWidth, h * 0.82,
      cx - bodyWidth, h * 0.65,
    );
    path.cubicTo(
      cx - bodyWidth, h * 0.45,
      cx - bodyWidth * 0.3, tipY + h * 0.15,
      cx, tipY,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MoodWaveMiniPainter oldDelegate) =>
      level != oldDelegate.level || color != oldDelegate.color;
}
