import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'bouncy_button.dart';

/// Clean custom top bar replacing default Material AppBar
class CustomHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTrailingTap;
  final IconData? trailingIcon;
  final bool showBackButton;
  final VoidCallback? onBackTap;

  const CustomHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTrailingTap,
    this.trailingIcon,
    this.showBackButton = false,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBackButton) ...[
            BouncyButton.glass(
              onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
              padding: const EdgeInsets.all(10),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: KisaColors.textPrimary,
              ),
            ),
            const SizedBox(width: 14),
          ] else if (leading != null) ...[
            leading!,
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtitle != null) ...[
                  Text(
                    subtitle!.toUpperCase(),
                    style: KisaTypography.caption.copyWith(
                      color: KisaColors.primaryRose,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  title,
                  style: KisaTypography.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (trailingIcon != null)
            BouncyButton.glass(
              onTap: onTrailingTap,
              padding: const EdgeInsets.all(10),
              child: Icon(
                trailingIcon,
                size: 20,
                color: KisaColors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }
}
