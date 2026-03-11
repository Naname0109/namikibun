import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 寝ているなみちゃん
            CustomPaint(
              size: const Size(80, 56),
              painter: _SleepingWavePainter(
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 18),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 寝ているなみちゃん（丸い体、三日月目、ほっぺ、Zzz、毛布風の広がり）
class _SleepingWavePainter extends CustomPainter {
  _SleepingWavePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 毛布風の広がり（体の下半分、薄い色）
    final blanketPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    final blanketPath = Path();
    blanketPath.moveTo(w * 0.15, h * 0.55);
    blanketPath.quadraticBezierTo(w * 0.3, h * 0.5, w * 0.5, h * 0.52);
    blanketPath.quadraticBezierTo(w * 0.7, h * 0.55, w * 0.85, h * 0.55);
    blanketPath.quadraticBezierTo(w * 0.9, h * 0.7, w * 0.8, h * 0.85);
    blanketPath.quadraticBezierTo(w * 0.5, h * 0.95, w * 0.2, h * 0.85);
    blanketPath.quadraticBezierTo(w * 0.1, h * 0.7, w * 0.15, h * 0.55);
    blanketPath.close();
    canvas.drawPath(blanketPath, blanketPaint);

    // 丸い体（横に寝ている雫型を楕円風に）
    final bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final cx = w * 0.45;
    final cy = h * 0.45;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: w * 0.45, height: h * 0.45),
      bodyPaint,
    );

    // ボディハイライト
    final hlPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - w * 0.05, cy - h * 0.06),
        width: w * 0.12,
        height: h * 0.15,
      ),
      hlPaint,
    );

    // 三日月型の閉じた目（穏やかな笑顔で寝ている）
    final eyePaint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 左目
    final leftEyeRect = Rect.fromCenter(
      center: Offset(cx - w * 0.06, cy),
      width: w * 0.06,
      height: h * 0.06,
    );
    canvas.drawArc(leftEyeRect, 0, 3.14159, false, eyePaint);

    // 右目
    final rightEyeRect = Rect.fromCenter(
      center: Offset(cx + w * 0.06, cy),
      width: w * 0.06,
      height: h * 0.06,
    );
    canvas.drawArc(rightEyeRect, 0, 3.14159, false, eyePaint);

    // ほっぺ
    final cheekPaint = Paint()
      ..color = const Color(0xFFFF9999).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - w * 0.11, cy + h * 0.04),
        width: w * 0.05,
        height: h * 0.04,
      ),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + w * 0.11, cy + h * 0.04),
        width: w * 0.05,
        height: h * 0.04,
      ),
      cheekPaint,
    );

    // Zzzマーク
    final zPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawZ(canvas, Offset(w * 0.72, h * 0.22), 9, zPaint);

    final zPaintSmall = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    _drawZ(canvas, Offset(w * 0.8, h * 0.08), 7, zPaintSmall);

    final zPaintTiny = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    _drawZ(canvas, Offset(w * 0.86, h * 0.0), 5, zPaintTiny);
  }

  void _drawZ(Canvas canvas, Offset pos, double size, Paint paint) {
    final path = Path();
    path.moveTo(pos.dx, pos.dy);
    path.lineTo(pos.dx + size, pos.dy);
    path.lineTo(pos.dx, pos.dy + size);
    path.lineTo(pos.dx + size, pos.dy + size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SleepingWavePainter oldDelegate) =>
      color != oldDelegate.color;
}
