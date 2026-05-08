import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class NeoContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final bool isOutterShadow;

  const NeoContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.isOutterShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppStyle.paddingMedium),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppStyle.borderRadius),
        border: Border.all(color: AppColors.border, width: AppStyle.borderWidth),
        boxShadow: isOutterShadow
            ? [
                const BoxShadow(
                  color: AppColors.border,
                  offset: AppStyle.shadowOffset,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class NeoButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isOutterShadow;
  final Color? backgroundColor;
  final Color? textColor;

  const NeoButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isOutterShadow = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppStyle.paddingLarge,
          vertical: AppStyle.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primary,
          borderRadius: BorderRadius.circular(AppStyle.borderRadius),
          border: Border.all(color: AppColors.border, width: AppStyle.borderWidth),
          boxShadow: isOutterShadow
              ? [
                  const BoxShadow(
                    color: AppColors.border,
                    offset: AppStyle.shadowOffset,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? Colors.white),
              const SizedBox(width: AppStyle.paddingSmall),
            ],
            Text(
              text,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NeoCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? accentColor;

  const NeoCard({
    super.key,
    required this.child,
    this.onTap,
    this.width,
    this.height,
    this.backgroundColor,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(AppStyle.borderRadius),
          border: Border.all(color: AppColors.border, width: AppStyle.borderWidth),
          boxShadow: const [
            BoxShadow(color: AppColors.border, offset: AppStyle.shadowOffset),
          ],
        ),
        child: Stack(
          children: [
            if (accentColor != null)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 8,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppStyle.borderRadius - AppStyle.borderWidth),
                      bottomLeft: Radius.circular(AppStyle.borderRadius - AppStyle.borderWidth),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(
                left: accentColor != null ? AppStyle.paddingMedium + 8 : AppStyle.paddingMedium,
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}