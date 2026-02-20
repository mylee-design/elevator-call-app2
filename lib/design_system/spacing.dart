import 'package:flutter/material.dart';

/// 앱의 간격(Spacing) 시스템
/// 4pt 기반 그리드 시스템
/// Material 3 spacing guidelines 기반
class AppSpacing {
  AppSpacing._();

  // ====================
  // Base Unit
  // ====================
  static const double baseUnit = 4;

  // ====================
  // Spacing Scale (4pt grid)
  // ====================
  static const double none = 0;
  static const double xxs = baseUnit;           // 4
  static const double xs = baseUnit * 2;        // 8
  static const double sm = baseUnit * 3;        // 12
  static const double md = baseUnit * 4;        // 16
  static const double lg = baseUnit * 6;        // 24
  static const double xl = baseUnit * 8;        // 32
  static const double xxl = baseUnit * 12;      // 48
  static const double xxxl = baseUnit * 16;     // 64
  static const double xxxxl = baseUnit * 24;    // 96

  // ====================
  // EdgeInsets Presets
  // ====================

  // All sides
  static const EdgeInsets paddingNone = EdgeInsets.zero;
  static const EdgeInsets paddingXXS = EdgeInsets.all(xxs);
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);

  // Horizontal only
  static const EdgeInsets paddingHorizontalXXS = EdgeInsets.symmetric(horizontal: xxs);
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(horizontal: xl);

  // Vertical only
  static const EdgeInsets paddingVerticalXXS = EdgeInsets.symmetric(vertical: xxs);
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(vertical: xl);

  // Symmetric
  static const EdgeInsets paddingSymmetricSM = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xs,
  );
  static const EdgeInsets paddingSymmetricMD = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
  static const EdgeInsets paddingSymmetricLG = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  // ====================
  // Component Spacing
  // ====================

  /// Button internal padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  /// Button small padding
  static const EdgeInsets buttonSmallPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  /// Card padding large
  static const EdgeInsets cardPaddingLG = EdgeInsets.all(lg);

  /// Input field padding
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// App bar padding
  static const EdgeInsets appBarPadding = EdgeInsets.symmetric(horizontal: md);

  /// Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.all(md);

  /// Screen padding horizontal
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: md);

  // ====================
  // Gap Widgets
  // ====================

  static const SizedBox gapXXS = SizedBox(width: xxs, height: xxs);
  static const SizedBox gapXS = SizedBox(width: xs, height: xs);
  static const SizedBox gapSM = SizedBox(width: sm, height: sm);
  static const SizedBox gapMD = SizedBox(width: md, height: md);
  static const SizedBox gapLG = SizedBox(width: lg, height: lg);
  static const SizedBox gapXL = SizedBox(width: xl, height: xl);
  static const SizedBox gapXXL = SizedBox(width: xxl, height: xxl);

  // Horizontal gaps
  static const SizedBox hGapXXS = SizedBox(width: xxs);
  static const SizedBox hGapXS = SizedBox(width: xs);
  static const SizedBox hGapSM = SizedBox(width: sm);
  static const SizedBox hGapMD = SizedBox(width: md);
  static const SizedBox hGapLG = SizedBox(width: lg);
  static const SizedBox hGapXL = SizedBox(width: xl);
  static const SizedBox hGapXXL = SizedBox(width: xxl);

  // Vertical gaps
  static const SizedBox vGapXXS = SizedBox(height: xxs);
  static const SizedBox vGapXS = SizedBox(height: xs);
  static const SizedBox vGapSM = SizedBox(height: sm);
  static const SizedBox vGapMD = SizedBox(height: md);
  static const SizedBox vGapLG = SizedBox(height: lg);
  static const SizedBox vGapXL = SizedBox(height: xl);
  static const SizedBox vGapXXL = SizedBox(height: xxl);
  static const SizedBox vGapXXXL = SizedBox(height: xxxl);

  // ====================
  // Border Radius
  // ====================
  static const double radiusNone = 0;
  static const double radiusXS = 4;
  static const double radiusSM = 8;
  static const double radiusMD = 12;
  static const double radiusLG = 16;
  static const double radiusXL = 24;
  static const double radiusXXL = 32;
  static const double radiusFull = 9999;

  // BorderRadius presets
  static const BorderRadius borderRadiusNone = BorderRadius.zero;
  static const BorderRadius borderRadiusXS = BorderRadius.all(Radius.circular(radiusXS));
  static const BorderRadius borderRadiusSM = BorderRadius.all(Radius.circular(radiusSM));
  static const BorderRadius borderRadiusMD = BorderRadius.all(Radius.circular(radiusMD));
  static const BorderRadius borderRadiusLG = BorderRadius.all(Radius.circular(radiusLG));
  static const BorderRadius borderRadiusXL = BorderRadius.all(Radius.circular(radiusXL));
  static const BorderRadius borderRadiusXXL = BorderRadius.all(Radius.circular(radiusXXL));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(radiusFull));

  // ====================
  // Elevation (Shadow)
  // ====================
  static const List<BoxShadow> shadowSM = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> shadowMD = [
    BoxShadow(
      color: Color(0x29000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowLG = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowXL = [
    BoxShadow(
      color: Color(0x42000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // Dark theme shadows
  static const List<BoxShadow> darkShadowSM = [
    BoxShadow(
      color: Color(0x1FFFFFFF),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> darkShadowMD = [
    BoxShadow(
      color: Color(0x29FFFFFF),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // ====================
  // Icon Sizes
  // ====================
  static const double iconXS = 16;
  static const double iconSM = 20;
  static const double iconMD = 24;
  static const double iconLG = 32;
  static const double iconXL = 48;
  static const double iconXXL = 64;

  // ====================
  // Helper Methods
  // ====================

  /// 커스텀 padding 생성
  static EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) {
      return EdgeInsets.all(all);
    }
    return EdgeInsets.only(
      left: left ?? horizontal ?? 0,
      top: top ?? vertical ?? 0,
      right: right ?? horizontal ?? 0,
      bottom: bottom ?? vertical ?? 0,
    );
  }

  /// 커스텀 border radius 생성
  static BorderRadius customRadius({
    double? all,
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
  }) {
    if (all != null) {
      return BorderRadius.all(Radius.circular(all));
    }
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft ?? 0),
      topRight: Radius.circular(topRight ?? 0),
      bottomLeft: Radius.circular(bottomLeft ?? 0),
      bottomRight: Radius.circular(bottomRight ?? 0),
    );
  }
}

/// EdgeInsets Extension
extension EdgeInsetsExtension on EdgeInsets {
  /// 특정 방향만 값 변경
  EdgeInsets copyWith({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: left ?? this.left,
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
    );
  }
}
