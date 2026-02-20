import 'package:flutter/material.dart';

/// 앱의 타이포그래피 시스템
/// Material 3 Type Scale 기반
/// Pretendard 폰트 사용 권장
class AppTypography {
  AppTypography._();

  // ====================
  // Font Families
  // ====================
  static const String fontFamily = 'Pretendard';
  static const String fallbackFontFamily = 'Noto Sans KR';

  // ====================
  // Font Weights
  // ====================
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // ====================
  // Letter Spacing
  // ====================
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0;
  static const double letterSpacingWide = 0.5;
  static const double letterSpacingWider = 1.0;

  // ====================
  // Line Heights
  // ====================
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  // ====================
  // Display Styles
  // ====================
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: [fallbackFontFamily],
    fontSize: 57,
    fontWeight: regular,
    letterSpacing: letterSpacingTight,
    height: lineHeightTight,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: [fallbackFontFamily],
    fontSize: 45,
    fontWeight: regular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightTight,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: [fallbackFontFamily],
    fontSize: 36,
    fontWeight: regular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightTight,
  );

  // ====================
  // Headline Styles
  // ====================
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: [fallbackFontFamily],
    fontSize: 32,
    fontWeight: semiBold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightTight,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: [fallbackFontFamily],
    fontSize: 28,
    fontWeight: semiBold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightTight,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: [fallbackFontFamily],
    fontSize: 24,
    fontWeight: semiBold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightTight,
  );

  // ====================
  // Title Styles
  // ====================
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: [fallbackFontFamily],
    fontSize: 22,
    fontWeight: semiBold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: [fallbackFontFamily],
    fontSize: 16,
    fontWeight: medium,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: [fallbackFontFamily],
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  // ====================
  // Body Styles
  // ====================
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: [fallbackFontFamily],
    fontSize: 16,
    fontWeight: regular,
    letterSpacing: letterSpacingWide,
    height: lineHeightRelaxed,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: [fallbackFontFamily],
    fontSize: 14,
    fontWeight: regular,
    letterSpacing: letterSpacingWide,
    height: lineHeightRelaxed,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: [fallbackFontFamily],
    fontSize: 12,
    fontWeight: regular,
    letterSpacing: letterSpacingWide,
    height: lineHeightRelaxed,
  );

  // ====================
  // Label Styles
  // ====================
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: [fallbackFontFamily],
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: [fallbackFontFamily],
    fontSize: 12,
    fontWeight: medium,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: [fallbackFontFamily],
    fontSize: 11,
    fontWeight: medium,
    letterSpacing: letterSpacingWider,
    height: lineHeightNormal,
  );

  // ====================
  // Custom Styles (App Specific)
  // ====================
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: [fallbackFontFamily],
    fontSize: 16,
    fontWeight: semiBold,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: [fallbackFontFamily],
    fontSize: 14,
    fontWeight: semiBold,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: [fallbackFontFamily],
    fontSize: 12,
    fontWeight: regular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: [fallbackFontFamily],
    fontSize: 11,
    fontWeight: medium,
    letterSpacing: letterSpacingWider,
    height: lineHeightNormal,
  );

  // ====================
  // Helper Methods
  // ====================

  /// 색상이 적용된 TextStyle 생성
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// 폰트 웨이트가 적용된 TextStyle 생성
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// 폰트 사이즈가 적용된 TextStyle 생성
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// 텍스트 테마 생성
  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
  }
}

/// TextStyle Extensions
extension TextStyleExtension on TextStyle {
  /// 색상 적용
  TextStyle colored(Color color) => copyWith(color: color);

  /// 폰트 웨이트 적용
  TextStyle weighted(FontWeight weight) => copyWith(fontWeight: weight);

  /// 폰트 사이즈 적용
  TextStyle sized(double size) => copyWith(fontSize: size);

  /// 라인 높이 적용
  TextStyle withLineHeight(double height) => copyWith(height: height);

  /// 레터 스페이싱 적용
  TextStyle withLetterSpacing(double spacing) => copyWith(letterSpacing: spacing);
}
