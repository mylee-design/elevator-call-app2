import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../design_system/colors.dart';

/// 다크 모드 유틸리티
/// 테마 모드 관리 및 시스템 설정 연동

class DarkModeUtils {
  DarkModeUtils._();

  static const String _themeModeKey = 'theme_mode';

  /// 시스템 다크 모드 감지
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// 테마 모드 저장
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  /// 테마 모드 로드
  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName = prefs.getString(_themeModeKey);

    return switch (modeName) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  /// 테마 모드 토글
  static ThemeMode toggleThemeMode(ThemeMode current) {
    return switch (current) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
  }

  /// 다크 모드 여부 확인 (시스템 설정 포함)
  static bool isEffectiveDarkMode(BuildContext context, ThemeMode mode) {
    final platformBrightness = MediaQuery.platformBrightnessOf(context);

    return switch (mode) {
      ThemeMode.light => false,
      ThemeMode.dark => true,
      ThemeMode.system => platformBrightness == Brightness.dark,
    };
  }
}

/// 테마 모드 관리 Provider
class ThemeModeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  ThemeModeNotifier() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    _mode = await DarkModeUtils.loadThemeMode();
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    await DarkModeUtils.saveThemeMode(mode);
    notifyListeners();
  }

  Future<void> toggle() async {
    final newMode = DarkModeUtils.toggleThemeMode(_mode);
    await setMode(newMode);
  }

  bool isDarkMode(BuildContext context) {
    return DarkModeUtils.isEffectiveDarkMode(context, _mode);
  }
}

/// 다크 모드-aware 이미지 위젯
class ThemedImage extends StatelessWidget {
  final String lightImage;
  final String? darkImage;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? semanticLabel;

  const ThemedImage({
    super.key,
    required this.lightImage,
    this.darkImage,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DarkModeUtils.isDarkMode(context);
    final imagePath = isDark && darkImage != null ? darkImage! : lightImage;

    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
    );
  }
}

/// 다크 모드-aware 아이콘 위젯
class ThemedIcon extends StatelessWidget {
  final IconData icon;
  final Color? lightColor;
  final Color? darkColor;
  final double? size;

  const ThemedIcon({
    super.key,
    required this.icon,
    this.lightColor,
    this.darkColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DarkModeUtils.isDarkMode(context);
    final color = isDark
        ? (darkColor ?? AppColors.darkOnSurface)
        : (lightColor ?? AppColors.onSurface);

    return Icon(
      icon,
      color: color,
      size: size,
    );
  }
}

/// 다크 모드-aware 컨테이너 위젯
class ThemedContainer extends StatelessWidget {
  final Widget child;
  final Color? lightColor;
  final Color? darkColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? shadows;

  const ThemedContainer({
    super.key,
    required this.child,
    this.lightColor,
    this.darkColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.border,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DarkModeUtils.isDarkMode(context);
    final color = isDark
        ? (darkColor ?? AppColors.darkSurface)
        : (lightColor ?? AppColors.surface);

    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: border,
        boxShadow: shadows,
      ),
      child: child,
    );
  }
}

/// 다크 모드-aware 텍스트 위젯
class ThemedText extends StatelessWidget {
  final String data;
  final TextStyle? lightStyle;
  final TextStyle? darkStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ThemedText({
    super.key,
    required this.data,
    this.lightStyle,
    this.darkStyle,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DarkModeUtils.isDarkMode(context);
    final style = isDark ? darkStyle : lightStyle;

    return Text(
      data,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// 테마 전환 애니메이션 위젯
class ThemeTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const ThemeTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      data: Theme.of(context),
      duration: duration,
      child: child,
    );
  }
}

/// 테마 모드 선택 다이얼로그
class ThemeModeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onModeChanged;

  const ThemeModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('테마 선택'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<ThemeMode>(
            title: const Row(
              children: [
                Icon(Icons.wb_sunny),
                SizedBox(width: 8),
                Text('라이트 모드'),
              ],
            ),
            value: ThemeMode.light,
            groupValue: currentMode,
            onChanged: (value) {
              if (value != null) {
                onModeChanged(value);
                Navigator.of(context).pop();
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Row(
              children: [
                Icon(Icons.nights_stay),
                SizedBox(width: 8),
                Text('다크 모드'),
              ],
            ),
            value: ThemeMode.dark,
            groupValue: currentMode,
            onChanged: (value) {
              if (value != null) {
                onModeChanged(value);
                Navigator.of(context).pop();
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Row(
              children: [
                Icon(Icons.settings_suggest),
                SizedBox(width: 8),
                Text('시스템 설정'),
              ],
            ),
            value: ThemeMode.system,
            groupValue: currentMode,
            onChanged: (value) {
              if (value != null) {
                onModeChanged(value);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

/// 빌드 컨텍스트 확장
extension DarkModeContextExtension on BuildContext {
  /// 현재 다크 모드 여부
  bool get isDarkMode => DarkModeUtils.isDarkMode(this);

  /// 현재 테마의 색상
  Color get adaptiveSurfaceColor =>
      isDarkMode ? AppColors.darkSurface : AppColors.surface;

  Color get adaptiveOnSurfaceColor =>
      isDarkMode ? AppColors.darkOnSurface : AppColors.onSurface;

  Color get adaptiveBackgroundColor =>
      isDarkMode ? AppColors.darkBackground : AppColors.background;

  Color get adaptiveDividerColor =>
      isDarkMode ? AppColors.darkDivider : AppColors.divider;
}
