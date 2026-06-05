import 'package:flutter/material.dart';

import '../constants/app_constants.dart' show AppStyle;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

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
        border: Border.all(
          color: AppColors.greyBorder,
          width: AppStyle.borderWidth,
        ),
        boxShadow: isOutterShadow ? _CoreSurfaceShadow.soft : null,
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
          boxShadow: isOutterShadow ? _CoreSurfaceShadow.soft : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? AppColors.white, size: 20),
              const SizedBox(width: AppStyle.paddingSmall),
            ],
            Text(
              text,
              style: AppTextStyles.buttonPrimary.copyWith(
                color: textColor ?? AppColors.white,
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
          border: Border.all(
            color: AppColors.greyBorder,
            width: AppStyle.borderWidth,
          ),
          boxShadow: _CoreSurfaceShadow.soft,
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
                    color: accentColor ?? AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(
                        AppStyle.borderRadius - AppStyle.borderWidth,
                      ),
                      bottomLeft: Radius.circular(
                        AppStyle.borderRadius - AppStyle.borderWidth,
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(
                left: accentColor != null
                    ? AppStyle.paddingMedium + 8
                    : AppStyle.paddingMedium,
                right: AppStyle.paddingMedium,
                top: AppStyle.paddingMedium,
                bottom: AppStyle.paddingMedium,
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _CoreSurfaceShadow {
  static const soft = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 18,
      offset: AppStyle.shadowOffset,
    ),
  ];
}
