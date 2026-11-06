import 'package:flutter/widgets.dart';

class Breakpoints {
  Breakpoints._();

  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1250;
  static const double maxContentWidth = 1240;
}

bool isMobileWidth(double width) => width <= Breakpoints.mobile;

int postGridColumns(double width) {
  if (width <= Breakpoints.mobile) return 1;
  if (width < Breakpoints.tablet) return 2;
  if (width < Breakpoints.desktop) return 3;
  return 4;
}

double pageHorizontalPadding(double width) {
  if (width <= Breakpoints.mobile) return 16;
  if (width < Breakpoints.tablet) return 24;
  return 32;
}

/// Side padding that keeps content centered and capped at [maxWidth].
double centeredSidePadding(
  double width, {
  double maxWidth = Breakpoints.maxContentWidth,
}) {
  final remaining = (width - maxWidth) / 2;
  return remaining > 16 ? remaining : pageHorizontalPadding(width);
}

double gridCardHeight(BuildContext context) {
  final scale = MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.35);
  return 390 * scale;
}
