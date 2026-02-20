import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/typography.dart';
import '../design_system/spacing.dart';
import '../design_system/components.dart';

/// 빈 상태 화면 위젯
/// 데이터가 없을 때 표시되는 일관된 UI
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconSize = 80,
  });

  /// BLE 기기 없음 상태
  const EmptyState.noDevices({
    super.key,
    this.actionLabel = '다시 검색',
    this.onAction,
  })  : icon = Icons.bluetooth_disabled,
        title = '기기를 찾을 수 없습니다',
        message = '주변에 BLE 기기가 없거나\n블루투스가 꺼져있을 수 있습니다',
        iconSize = 80;

  /// QR 스캔 결과 없음 상태
  const EmptyState.noScanResult({
    super.key,
    this.actionLabel = '다시 스캔',
    this.onAction,
  })  : icon = Icons.qr_code_scanner,
        title = 'QR 코드를 인식할 수 없습니다',
        message = 'QR 코드가 프레임 안에 들어오도록\n조정해주세요',
        iconSize = 80;

  /// 연결 실패 상태
  const EmptyState.connectionFailed({
    super.key,
    this.actionLabel = '다시 시도',
    this.onAction,
  })  : icon = Icons.link_off,
        title = '연결에 실패했습니다',
        message = '기기와의 연결이 끊어졌습니다\n다시 시도해주세요',
        iconSize = 80;

  /// 검색 결과 없음 상태
  const EmptyState.noResults({
    super.key,
    this.actionLabel,
    this.onAction,
  })  : icon = Icons.search_off,
        title = '검색 결과가 없습니다',
        message = '다른 검색어로 시도필보세요',
        iconSize = 80;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize + 40,
              height: iconSize + 40,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceContainer
                    : AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: isDark
                    ? AppColors.darkOnSurfaceVariant
                    : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.headlineSmall.copyWith(
                color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkOnSurfaceVariant
                    : AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 일러스트레이션 기반 빈 상태
class EmptyStateIllustration extends StatelessWidget {
  final String illustrationPath;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double illustrationHeight;

  const EmptyStateIllustration({
    super.key,
    required this.illustrationPath,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.illustrationHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              illustrationPath,
              height: illustrationHeight,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.headlineSmall.copyWith(
                color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkOnSurfaceVariant
                    : AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
