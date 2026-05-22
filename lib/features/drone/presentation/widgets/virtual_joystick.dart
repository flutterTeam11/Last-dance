import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

class VirtualJoystick extends StatefulWidget {
  final ValueChanged<Offset>? onDirectionChanged;
  final VoidCallback? onDirectionEnd;

  const VirtualJoystick({
    super.key,
    this.onDirectionChanged,
    this.onDirectionEnd,
  });

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset _thumbPosition = Offset.zero;
  final double _outerRadius = 60;

  @override
  Widget build(BuildContext context) {
    final outerSize = (_outerRadius * 2).w;
    final innerSize = 48.w;

    return SizedBox(
      width: outerSize,
      height: outerSize,
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: CustomPaint(
          painter: _JoystickPainter(
            outerRadius: _outerRadius.w,
            thumbPosition: _thumbPosition,
            innerRadius: innerSize / 2,
          ),
          size: Size(outerSize, outerSize),
        ),
      ),
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final center = Offset(_outerRadius.w, _outerRadius.w);
    final maxDist = _outerRadius.w - 24.w;
    var newPos = details.localPosition - center;

    if (newPos.distance > maxDist) {
      newPos = Offset.fromDirection(newPos.direction, maxDist);
    }

    setState(() => _thumbPosition = newPos);
    widget.onDirectionChanged?.call(
      Offset(newPos.dx / maxDist, newPos.dy / maxDist),
    );
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _thumbPosition = Offset.zero);
    widget.onDirectionEnd?.call();
  }
}

class _JoystickPainter extends CustomPainter {
  final double outerRadius;
  final Offset thumbPosition;
  final double innerRadius;

  _JoystickPainter({
    required this.outerRadius,
    required this.thumbPosition,
    required this.innerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Outer circle
    final outerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius, outerPaint);

    // Outer border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, outerRadius, borderPaint);

    // Direction indicators
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

    // Thumb
    final thumbCenter = center + thumbPosition;
    final gradient = RadialGradient(
      colors: [AppTheme.brandCyan, AppTheme.brandBlue],
    );
    final thumbPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: thumbCenter, radius: innerRadius),
      );
    canvas.drawCircle(thumbCenter, innerRadius, thumbPaint);

    // Thumb highlight
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
  bool shouldRepaint(covariant _JoystickPainter oldDelegate) {
    return oldDelegate.thumbPosition != thumbPosition;
  }
}
