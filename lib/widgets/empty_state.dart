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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 波キャラの寝ている姿
            CustomPaint(
              size: const Size(80, 60),
              painter: _SleepingWavePainter(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 波キャラクターの寝ている姿
class _SleepingWavePainter extends CustomPainter {
  _SleepingWavePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 平坦な波（寝ている体）
    final bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final bodyPath = Path();
    bodyPath.moveTo(w * 0.1, h * 0.7);
    bodyPath.quadraticBezierTo(w * 0.3, h * 0.5, w * 0.5, h * 0.5);
    bodyPath.quadraticBezierTo(w * 0.7, h * 0.5, w * 0.9, h * 0.7);
    bodyPath.lineTo(w * 0.9, h);
    bodyPath.lineTo(w * 0.1, h);
    bodyPath.close();
    canvas.drawPath(bodyPath, bodyPaint);

    // 閉じた目（横線2本）
    final eyePaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.38, h * 0.48),
      Offset(w * 0.45, h * 0.48),
      eyePaint,
    );
    canvas.drawLine(
      Offset(w * 0.55, h * 0.48),
      Offset(w * 0.62, h * 0.48),
      eyePaint,
    );

    // Zzzマーク
    final zPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawZ(canvas, Offset(w * 0.72, h * 0.2), 8, zPaint);
    final zPaintSmall = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    _drawZ(canvas, Offset(w * 0.8, h * 0.1), 6, zPaintSmall);
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
