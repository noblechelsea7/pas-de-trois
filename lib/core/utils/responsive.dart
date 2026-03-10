import 'package:flutter/widgets.dart';

/// Responsive breakpoints for Pas de trois.
/// Web: width > 768   Mobile: width ≤ 768
abstract final class AppBreakpoints {
  static const double webWidth = 768;
  static const double maxContentWidth = 1200;

  static bool isWeb(BuildContext context) =>
      MediaQuery.sizeOf(context).width > webWidth;
}
