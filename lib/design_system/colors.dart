import 'package:flutter/material.dart';

/// 앱의 색상 시스템
/// Material 3 디자인 시스템 기반
/// 라이트/다크 테마 모두 지원
class AppColors {
  AppColors._();

  // ====================
  // Primary Colors
  // ====================
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF5E92F3);
  static const Color primaryDark = Color(0xFF003C8F);
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFD1E4FF);
  static const Color onPrimaryContainer = Color(0xFF001D36);

  // ====================
  // Secondary Colors
  // ====================
  static const Color secondary = Color(0xFF00BCD4);
  static const Color secondaryLight = Color(0xFF62EFF7);
  static const Color secondaryDark = Color(0xFF008BA3);
  static const Color onSecondary = Colors.white;
  static const Color secondaryContainer = Color(0xFFB4EBF7);
  static const Color onSecondaryContainer = Color(0xFF002023);

  // ====================
  // Tertiary Colors (Accent)
  // ====================
  static const Color tertiary = Color(0xFF7C4DFF);
  static const Color onTertiary = Colors.white;
  static const Color tertiaryContainer = Color(0xFFE8DDFF);
  static const Color onTertiaryContainer = Color(0xFF21005D);

  // ====================
  // Semantic Colors
  // ====================
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  static const Color onSuccess = Colors.white;

  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFCC80);
  static const Color warningDark = Color(0xFFF57C00);
  static const Color onWarning = Colors.white;

  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFC62828);
  static const Color onError = Colors.white;
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);
  static const Color onInfo = Colors.white;

  // ====================
  // Neutral Colors (Light Theme)
  // ====================
  static const Color background = Color(0xFFF5F5F5);
  static const Color onBackground = Color(0xFF1A1C1E);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF1A1C1E);
  static const Color onSurfaceVariant = Color(0xFF757575);
  static const Color surfaceVariant = Color(0xFFDEE3EB);
  static const Color outline = Color(0xFFBDBDBD);
  static const Color outlineVariant = Color(0xFFC4C7C5);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);

  // ====================
  // Neutral Colors (Dark Theme)
  // ====================
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkOnBackground = Colors.white;
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkOnSurface = Colors.white;
  static const Color darkOnSurfaceVariant = Color(0xFFB0B0B0);
  static const Color darkOutline = Color(0xFF616161);
  static const Color darkOutlineVariant = Color(0xFF424242);
  static const Color darkDivider = Color(0xFF424242);

  // ====================
  // Surface Container Colors (Material 3)
  // ====================
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF7F7F7);
  static const Color surfaceContainer = Color(0xFFEFEFEF);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color surfaceContainerHighest = Color(0xFFE0E0E0);

  static const Color darkSurfaceContainerLowest = Color(0xFF0D0D0D);
  static const Color darkSurfaceContainerLow = Color(0xFF1A1A1A);
  static const Color darkSurfaceContainer = Color(0xFF1E1E1E);
  static const Color darkSurfaceContainerHigh = Color(0xFF252525);
  static const Color darkSurfaceContainerHighest = Color(0xFF2C2C2C);

  // ====================
  // Elevation Colors (Light)
  // ====================
  static const Color elevation1 = Color(0x1F000000);
  static const Color elevation2 = Color(0x29000000);
  static const Color elevation3 = Color(0x33000000);
  static const Color elevation4 = Color(0x42000000);
  static const Color elevation5 = Color(0x52000000);

  // ====================
  // Elevation Colors (Dark)
  // ====================
  static const Color darkElevation1 = Color(0x1FFFFFFF);
  static const Color darkElevation2 = Color(0x29FFFFFF);
  static const Color darkElevation3 = Color(0x33FFFFFF);
  static const Color darkElevation4 = Color(0x42FFFFFF);
  static const Color darkElevation5 = Color(0x52FFFFFF);

  // ====================
  // Gradient Colors
  // ====================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, successLight],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error, errorLight],
  );

  static const LinearGradient darkSurfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkSurface, darkBackground],
  );

  // ====================
  // Helper Methods
  // ====================

  /// 현재 테마에 맞는 색상 반환
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : surface;
  }

  static Color getOnSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkOnSurface
        : onSurface;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : background;
  }

  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkDivider
        : divider;
  }

  /// 투명도가 적용된 색상 생성
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}

/// Material 3 Color Scheme Extensions
extension ColorSchemeExtension on ColorScheme {
  Color get success => AppColors.success;
  Color get onSuccess => AppColors.onSuccess;
  Color get warning => AppColors.warning;
  Color get onWarning => AppColors.onWarning;
  Color get info => AppColors.info;
  Color get onInfo => AppColors.onInfo;
}
