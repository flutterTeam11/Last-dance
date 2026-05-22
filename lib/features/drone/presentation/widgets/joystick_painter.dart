import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class JoystickPainter extends CustomPainter {
  final double outerRadius;
  final Offset thumbPosition;
  final double innerRadius;

  JoystickPainter({
    required this.outerRadius,
    required this.thumbPosition,
    required this.innerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final outerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius, outerPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, outerRadius, borderPaint);

    final indicatorPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    final indicatorDist = outerRadius * 0.65;
    for (var i = 0; i < 4; i++) {
      final pos =
          center +
          Offset(
            indicatorDist * (i == 1 ? 1 : (i == 3 ? -1 : 0)),
            indicatorDist * (i == 2 ? 1 : (i == 0 ? -1 : 0)),
          );
      canvas.drawCircle(pos, 3, indicatorPaint);
    }

    final thumbCenter = center + thumbPosition;
    final gradient = RadialGradient(
      colors: [AppTheme.brandCyan, AppTheme.brandBlue],
    );
    final thumbPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: thumbCenter, radius: innerRadius),
      );
    canvas.drawCircle(thumbCenter, innerRadius, thumbPaint);

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      thumbCenter + Offset(-innerRadius * 0.2, -innerRadius * 0.2),
      innerRadius * 0.3,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant JoystickPainter oldDelegate) =>
      oldDelegate.thumbPosition != thumbPosition;
}
