import 'dart:math';

import 'package:flutter/material.dart';

/// 保存完了時のパーティクルアニメーションをオーバーレイとして表示
void showParticleEffect(BuildContext context, GlobalKey buttonKey) {
  final overlay = Overlay.of(context);
  final renderBox = buttonKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) return;

  final position = renderBox.localToGlobal(
    Offset(renderBox.size.width / 2, renderBox.size.height / 2),
  );

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _ParticleOverlay(
      origin: position,
      onComplete: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

class _ParticleOverlay extends StatefulWidget {
  const _ParticleOverlay({
    required this.origin,
    required this.onComplete,
  });

  final Offset origin;
  final VoidCallback onComplete;

  @override
  State<_ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<_ParticleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    final random = Random();
    _particles = List.generate(12, (_) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 60.0 + random.nextDouble() * 80.0;
      final size = 4.0 + random.nextDouble() * 6.0;
      final isStar = random.nextBool();
      final color = [
        const Color(0xFF4ECDC4),
        const Color(0xFF95D5B2),
        const Color(0xFFFFD93D),
        const Color(0xFF4A90D9),
        const Color(0xFFFF8C42),
      ][random.nextInt(5)];

      return _Particle(
        angle: angle,
        speed: speed,
        size: size,
        isStar: isStar,
        color: color,
      );
    });

    _controller.forward().then((_) => widget.onComplete());
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _ParticlePainter(
        origin: widget.origin,
        progress: _controller.value,
        particles: _particles,
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final bool isStar;
  final Color color;

  const _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.isStar,
    required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final Offset origin;
  final double progress;
  final List<_Particle> particles;

  _ParticlePainter({
    required this.origin,
    required this.progress,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final distance = p.speed * progress;
      final dx = origin.dx + cos(p.angle) * distance;
      final dy = origin.dy + sin(p.angle) * distance - 20 * progress;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final currentSize = p.size * (1.0 - progress * 0.5);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      if (p.isStar) {
        _drawStar(canvas, Offset(dx, dy), currentSize, paint);
      } else {
        canvas.drawCircle(Offset(dx, dy), currentSize, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
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

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) =>
      progress != oldDelegate.progress;
}
