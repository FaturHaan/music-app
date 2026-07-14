import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A reusable frosted glass container with backdrop blur and subtle border.
/// Used throughout the app for glassmorphism UI elements.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final double? width;
  final double? height;
  final double opacity;
  final Color? borderColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.blur = 20,
    this.width,
    this.height,
    this.opacity = 1.0,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppColors.glassGradientDark
                  : AppColors.glassGradientLight,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ??
                    (isDark
                        ? AppColors.glassDarkBorder
                        : AppColors.glassLightBorder),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
