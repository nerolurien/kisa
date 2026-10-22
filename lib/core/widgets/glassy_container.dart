import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

/// Frosted spatial glass container with BackdropFilter and continuous squircle curves
class GlassyContainer extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final double? width;
  final double? height;

  const GlassyContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.margin,
    this.borderRadius = 28,
    this.blur = 20,
    this.color,
    this.border,
    this.shadows,
    this.onTap,
    this.onDoubleTap,
    this.width,
    this.height,
  });

  @override
  State<GlassyContainer> createState() => _GlassyContainerState();
}

class _GlassyContainerState extends State<GlassyContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = BorderRadius.circular(widget.borderRadius);
    final hasInteractions = widget.onTap != null || widget.onDoubleTap != null;

    final Widget card = Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.color ?? KisaColors.surfaceGlass.withValues(alpha: 0.88),
        borderRadius: effectiveBorderRadius,
        border: widget.border ?? KisaShadows.glassBorder,
      ),
      child: widget.child,
    );

    final Widget frosted = Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        boxShadow: widget.shadows ?? KisaShadows.card,
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
          child: card,
        ),
      ),
    );

    if (!hasInteractions) {
      return frosted;
    }

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        _animController.forward();
      },
      onTapUp: (_) {
        _animController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _animController.reverse(),
      onDoubleTap: widget.onDoubleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: frosted,
      ),
    );
  }
}
