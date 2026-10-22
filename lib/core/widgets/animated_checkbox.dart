import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Custom animated checkbox with continuous squircle border,
/// progressive stroke checkmark draw, and spring scale bounce
class KisaAnimatedCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;
  final Color activeColor;
  final Color checkColor;

  const KisaAnimatedCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 26.0,
    this.activeColor = KisaColors.primaryRose,
    this.checkColor = Colors.white,
  });

  @override
  State<KisaAnimatedCheckbox> createState() => _KisaAnimatedCheckboxState();
}

class _KisaAnimatedCheckboxState extends State<KisaAnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _checkAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _checkAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeInOutCubic),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.82)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.82, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_controller);

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant KisaAnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.value ? _scaleAnimation.value : 1.0,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _CheckboxPainter(
                progress: _checkAnimation.value,
                activeColor: widget.activeColor,
                checkColor: widget.checkColor,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CheckboxPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color checkColor;

  _CheckboxPainter({
    required this.progress,
    required this.activeColor,
    required this.checkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(9.0));

    // Background fill lerp
    final fillPaint = Paint()
      ..color = Color.lerp(
        KisaColors.surface.withValues(alpha: 0.90),
        activeColor,
        progress,
      )!
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, fillPaint);

    // Border line
    final borderPaint = Paint()
      ..color = Color.lerp(
        KisaColors.borderSubtle,
        activeColor,
        progress,
      )!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRRect(rrect, borderPaint);

    // Progressive checkmark stroke
    if (progress > 0.05) {
      final checkPath = Path();
      final startPoint = Offset(size.width * 0.28, size.height * 0.52);
      final midPoint = Offset(size.width * 0.44, size.height * 0.70);
      final endPoint = Offset(size.width * 0.74, size.height * 0.32);

      checkPath.moveTo(startPoint.dx, startPoint.dy);
      checkPath.lineTo(midPoint.dx, midPoint.dy);
      checkPath.lineTo(endPoint.dx, endPoint.dy);

      final pathMetrics = checkPath.computeMetrics().toList();
      if (pathMetrics.isNotEmpty) {
        final metric = pathMetrics.first;
        final animatedPath = metric.extractPath(0.0, metric.length * progress);

        final strokePaint = Paint()
          ..color = checkColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 2.4;

        canvas.drawPath(animatedPath, strokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CheckboxPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.checkColor != checkColor;
  }
}
