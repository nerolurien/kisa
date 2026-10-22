import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';

/// Physics-based tactile bouncy button with scale-down spring effect
class BouncyButton extends StatefulWidget {
  final Widget? child;
  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Gradient? gradient;
  final List<BoxShadow>? shadows;
  final Border? border;
  final bool isLoading;
  final double? width;
  final double? height;

  const BouncyButton({
    super.key,
    this.child,
    this.label,
    this.icon,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
    this.borderRadius,
    this.backgroundColor,
    this.gradient,
    this.shadows,
    this.border,
    this.isLoading = false,
    this.width,
    this.height,
  });

  /// Factory for primary warm rose button (#f43f5e)
  factory BouncyButton.primary({
    Key? key,
    required String label,
    IconData? icon,
    VoidCallback? onTap,
    bool isLoading = false,
    double? width,
    double? height,
  }) {
    return BouncyButton(
      key: key,
      label: label,
      icon: icon,
      onTap: onTap,
      isLoading: isLoading,
      width: width,
      height: height,
      gradient: KisaColors.primaryGradient,
      shadows: KisaShadows.primaryGlow,
      borderRadius: BorderRadius.circular(28),
    );
  }

  /// Factory for frosted glass button
  factory BouncyButton.glass({
    Key? key,
    Widget? child,
    String? label,
    IconData? icon,
    VoidCallback? onTap,
    double? width,
    double? height,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
  }) {
    return BouncyButton(
      key: key,
      label: label,
      icon: icon,
      onTap: onTap,
      width: width,
      height: height,
      padding: padding,
      backgroundColor: KisaColors.glassFill,
      border: KisaShadows.glassBorder,
      shadows: KisaShadows.subtle,
      borderRadius: BorderRadius.circular(24),
      child: child,
    );
  }

  @override
  State<BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<BouncyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      reverseDuration: const Duration(milliseconds: 170),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null && !widget.isLoading) {
      HapticFeedback.lightImpact();
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null && !widget.isLoading) {
      _controller.reverse();
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(24);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? (widget.gradient == null ? KisaColors.primaryRose : null),
            gradient: widget.gradient,
            borderRadius: effectiveRadius,
            boxShadow: widget.shadows ?? KisaShadows.subtle,
            border: widget.border,
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : widget.child ??
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: 19,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (widget.label != null)
                        Text(
                          widget.label!,
                          style: KisaTypography.buttonText,
                        ),
                    ],
                  ),
        ),
      ),
    );
  }
}
