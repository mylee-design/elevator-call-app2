import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/typography.dart';
import '../design_system/spacing.dart';
import '../design_system/components.dart';
import '../animations/feedback_animations.dart';

/// 에러 상태 화면 위젯
/// 오류 발생 시 표시되는 일관된 UI
class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final String? retryLabel;
  final VoidCallback? onAction;
  final VoidCallback? onRetry;
  final bool showIcon;
  final bool animate;

  const ErrorState({
    super.key,
    this.title = '오류가 발생했습니다',
    required this.message,
    this.actionLabel,
    this.retryLabel = '다시 시도',
    this.onAction,
    this.onRetry,
    this.showIcon = true,
    this.animate = true,
  });

  /// 일반 오류
  const ErrorState.generic({
    super.key,
    this.title = '오류가 발생했습니다',
    required this.message,
    this.retryLabel = '다시 시도',
    this.onRetry,
  })  : actionLabel = null,
        onAction = null,
        showIcon = true,
        animate = true;

  /// 네트워크 오류
  const ErrorState.network({
    super.key,
    this.title = '네트워크 연결 오류',
    this.message = '인터넷 연결을 확인하고\n다시 시도해주세요',
    this.retryLabel = '다시 연결',
    this.onRetry,
  })  : actionLabel = null,
        onAction = null,
        showIcon = true,
        animate = true;

  /// BLE 오류
  const ErrorState.ble({
    super.key,
    this.title = '블루투스 연결 오류',
    this.message = '블루투스를 켜고\n다시 시도해주세요',
    this.retryLabel = '다시 연결',
    this.onRetry,
  })  : actionLabel = null,
        onAction = null,
        showIcon = true,
        animate = true;

  /// 권한 오류
  const ErrorState.permission({
    super.key,
    this.title = '권한이 필요합니다',
    required this.message,
    this.actionLabel = '설정으로 이동',
    this.onAction,
  })  : retryLabel = null,
        onRetry = null,
        showIcon = true,
        animate = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Center(
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon) ...[
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
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
            const SizedBox(height: AppSpacing.xl),
            if (retryLabel != null && onRetry != null)
              AppButton(
                label: retryLabel!,
                onPressed: onRetry,
              ),
            if (actionLabel != null && onAction != null) ...[
              if (retryLabel != null && onRetry != null)
                const SizedBox(height: AppSpacing.md),
              AppButton.outlined(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );

    if (animate) {
      content = ErrorShake(
        trigger: true,
        child: content,
      );
    }

    return content;
  }
}

/// 스낵바 형태의 에러 메시지
class ErrorSnackBar {
  static SnackBar create({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    return SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.error,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMD,
      ),
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onAction,
            )
          : null,
    );
  }
}

/// 인라인 에러 메시지
class InlineError extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry padding;

  const InlineError({
    super.key,
    required this.message,
    this.padding = const EdgeInsets.symmetric(vertical: AppSpacing.sm),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: 16,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 에러 바운더리 위젯
class ErrorBoundary extends StatelessWidget {
  final Widget child;
  final Widget fallback;

  const ErrorBoundary({
    super.key,
    required this.child,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return _ErrorBoundaryWidget(
      fallback: fallback,
      child: child,
    );
  }
}

class _ErrorBoundaryWidget extends StatefulWidget {
  final Widget child;
  final Widget fallback;

  const _ErrorBoundaryWidget({
    required this.child,
    required this.fallback,
  });

  @override
  State<_ErrorBoundaryWidget> createState() => _ErrorBoundaryWidgetState();
}

class _ErrorBoundaryWidgetState extends State<_ErrorBoundaryWidget> {
  bool _hasError = false;

  @override
  void didUpdateWidget(_ErrorBoundaryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_hasError) {
      setState(() => _hasError = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.fallback;
    }

    return widget.child;
  }
}

/// 재시도 가능한 에러 래퍼
class RetryableError extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback onRetry;
  final String? customMessage;

  const RetryableError({
    super.key,
    required this.error,
    this.stackTrace,
    required this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    String message = customMessage ?? _getErrorMessage(error);

    return ErrorState(
      title: '오류가 발생했습니다',
      message: message,
      retryLabel: '다시 시도',
      onRetry: onRetry,
    );
  }

  String _getErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}
