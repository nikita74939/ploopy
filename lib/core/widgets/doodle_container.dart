import 'package:flutter/material.dart';

import '../constants/app_constants.dart' show AppStyle;
import '../theme/app_colors.dart';

class DoodleContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const DoodleContainer({
    super.key,
    required this.child,
    this.color,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: color ?? AppColors.surface,
          borderRadius: BorderRadius.circular(AppStyle.borderRadius),
          border: Border.all(
            color: AppColors.greyBorder,
            width: AppStyle.borderWidth,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              offset: AppStyle.shadowOffset,
              blurRadius: 18,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
