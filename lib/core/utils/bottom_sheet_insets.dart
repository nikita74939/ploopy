import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class BottomSheetInsets {
  const BottomSheetInsets._();

  static double bottom(BuildContext context, {double spacing = 20}) {
    final mediaQuery = MediaQuery.of(context);
    return math.max(
          mediaQuery.viewInsets.bottom,
          mediaQuery.viewPadding.bottom,
        ) +
        spacing;
  }
}
