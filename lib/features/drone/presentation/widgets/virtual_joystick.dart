import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'joystick_painter.dart';

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
          painter: JoystickPainter(
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
