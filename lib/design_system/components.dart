import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import 'spacing.dart';

/// 앱의 재사용 가능한 컴포넌트 라이브러리
/// Material 3 디자인 기반

// ====================
// AppButton
// ====================

enum AppButtonVariant {
  primary,
  secondary,
  outlined,
  ghost,
  danger,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
  }) : variant = AppButtonVariant.ghost;

  const AppButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
  }) : variant = AppButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Size configurations
    final (height, padding, textStyle) = switch (size) {
      AppButtonSize.small => (
          36.0,
          AppSpacing.buttonSmallPadding,
          AppTypography.buttonMedium,
        ),
      AppButtonSize.medium => (
          48.0,
          AppSpacing.buttonPadding,
          AppTypography.buttonMedium,
        ),
      AppButtonSize.large => (
          56.0,
          AppSpacing.buttonPadding,
          AppTypography.buttonLarge,
        ),
    };

    // Style configurations
    final (backgroundColor, foregroundColor, borderColor) = switch (variant) {
      AppButtonVariant.primary => (
          AppColors.primary,
          AppColors.onPrimary,
          null,
        ),
      AppButtonVariant.secondary => (
          AppColors.secondary,
          AppColors.onSecondary,
          null,
        ),
      AppButtonVariant.outlined => (
          Colors.transparent,
          AppColors.primary,
          AppColors.primary,
        ),
      AppButtonVariant.ghost => (
          Colors.transparent,
          isDark ? AppColors.darkOnSurface : AppColors.onSurface,
          null,
        ),
      AppButtonVariant.danger => (
          AppColors.error,
          AppColors.onError,
          null,
        ),
    };

    Widget buttonChild = isLoading
        ? SizedBox(
            height: textStyle.fontSize,
            width: textStyle.fontSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: textStyle.fontSize),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(label, style: textStyle),
            ],
          );

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: backgroundColor.withOpacity(0.38),
      disabledForegroundColor: foregroundColor.withOpacity(0.38),
      elevation: variant == AppButtonVariant.primary ? 2 : 0,
      shadowColor: variant == AppButtonVariant.primary
          ? AppColors.primary.withOpacity(0.3)
          : null,
      padding: padding,
      minimumSize: Size(width ?? (isFullWidth ? double.infinity : 0), height),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMD,
        side: borderColor != null
            ? BorderSide(color: borderColor, width: 1.5)
            : BorderSide.none,
      ),
    );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: buttonChild,
    );
  }
}

// ====================
// AppCard
// ====================

enum AppCardVariant {
  elevated,
  flat,
  outlined,
}

class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.padding = AppSpacing.cardPadding,
    this.onTap,
    this.borderRadius,
  });

  const AppCard.elevated({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.onTap,
    this.borderRadius,
  }) : variant = AppCardVariant.elevated;

  const AppCard.flat({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.onTap,
    this.borderRadius,
  }) : variant = AppCardVariant.flat;

  const AppCard.outlined({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.onTap,
    this.borderRadius,
  }) : variant = AppCardVariant.outlined;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = borderRadius ?? AppSpacing.borderRadiusLG;

    final (backgroundColor, elevation, borderSide) = switch (variant) {
      AppCardVariant.elevated => (
          isDark ? AppColors.darkSurface : AppColors.surface,
          2.0,
          null,
        ),
      AppCardVariant.flat => (
          isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
          0.0,
          null,
        ),
      AppCardVariant.outlined => (
          isDark ? AppColors.darkSurface : AppColors.surface,
          0.0,
          BorderSide(
            color: isDark ? AppColors.darkOutline : AppColors.outline,
            width: 1,
          ),
        ),
    };

    Widget card = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius,
        border: borderSide != null ? Border.fromBorderSide(borderSide) : null,
        boxShadow: variant == AppCardVariant.elevated
            ? [
                BoxShadow(
                  color: isDark
                      ? AppColors.darkElevation1
                      : AppColors.elevation1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: card,
        ),
      );
    }

    return card;
  }
}

// ====================
// AppTextField
// ====================

enum AppTextFieldVariant {
  filled,
  outlined,
}

class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefix;
  final Widget? suffix;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final AppTextFieldVariant variant;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.onChanged,
    this.onTap,
    this.variant = AppTextFieldVariant.filled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fillColor = isDark
        ? AppColors.darkSurfaceContainer
        : AppColors.surfaceContainerLow;

    InputDecoration decoration = InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helperText,
      errorText: errorText,
      filled: variant == AppTextFieldVariant.filled,
      fillColor: fillColor,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : prefix,
      suffixIcon: suffixIcon != null
          ? IconButton(
              icon: Icon(suffixIcon),
              onPressed: onSuffixTap,
            )
          : suffix,
      contentPadding: AppSpacing.inputPadding,
      border: variant == AppTextFieldVariant.filled
          ? OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMD,
              borderSide: BorderSide.none,
            )
          : OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMD,
              borderSide: BorderSide(
                color: isDark ? AppColors.darkOutline : AppColors.outline,
              ),
            ),
      enabledBorder: variant == AppTextFieldVariant.filled
          ? OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMD,
              borderSide: BorderSide.none,
            )
          : OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMD,
              borderSide: BorderSide(
                color: isDark ? AppColors.darkOutline : AppColors.outline,
              ),
            ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusMD,
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusMD,
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusMD,
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
    );

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onTap: onTap,
      style: AppTypography.bodyMedium.copyWith(
        color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
      ),
      decoration: decoration,
    );
  }
}

// ====================
// AppIcon
// ====================

enum AppIconSize {
  xs,
  sm,
  md,
  lg,
  xl,
  xxl,
}

class AppIcon extends StatelessWidget {
  final IconData icon;
  final AppIconSize size;
  final Color? color;
  final double? customSize;

  const AppIcon({
    super.key,
    required this.icon,
    this.size = AppIconSize.md,
    this.color,
    this.customSize,
  });

  double get _size {
    if (customSize != null) return customSize!;
    return switch (size) {
      AppIconSize.xs => AppSpacing.iconXS,
      AppIconSize.sm => AppSpacing.iconSM,
      AppIconSize.md => AppSpacing.iconMD,
      AppIconSize.lg => AppSpacing.iconLG,
      AppIconSize.xl => AppSpacing.iconXL,
      AppIconSize.xxl => AppSpacing.iconXXL,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Icon(
      icon,
      size: _size,
      color: color ?? (isDark ? AppColors.darkOnSurface : AppColors.onSurface),
    );
  }
}

// ====================
// AppBadge
// ====================

class AppBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark
                ? AppColors.primaryContainer
                : AppColors.primary.withOpacity(0.1)),
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: foregroundColor ??
              (isDark ? AppColors.onPrimaryContainer : AppColors.primary),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ====================
// AppDivider
// ====================

class AppDivider extends StatelessWidget {
  final double indent;
  final double endIndent;
  final double thickness;

  const AppDivider({
    super.key,
    this.indent = 0,
    this.endIndent = 0,
    this.thickness = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Divider(
      color: isDark ? AppColors.darkDivider : AppColors.divider,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      height: thickness,
    );
  }
}

// ====================
// AppListTile
// ====================

class AppListTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const AppListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding = AppSpacing.listItemPadding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      contentPadding: padding,
      leading: leading,
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkOnSurfaceVariant
                    : AppColors.onSurfaceVariant,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMD,
      ),
    );
  }
}
