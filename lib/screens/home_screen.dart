import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/colors.dart';
import '../design_system/typography.dart';
import '../design_system/spacing.dart';
import '../design_system/components.dart';
import '../animations/loading_animations.dart';
import '../animations/animation_utils.dart';
import '../accessibility/semantic_labels.dart';
import '../accessibility/dark_mode.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.slow,
      vsync: this,
    );

    _fadeAnimation = TweenUtils.fade(_controller);
    _slideAnimation = TweenUtils.slideFromBottom(_controller);
    _scaleAnimation = TweenUtils.scale(
      _controller,
      begin: 0.8,
      end: 1.0,
      curve: AppCurves.spring,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScanPressed() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/qr_scan');
  }

  void _onMockModePressed() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/ble_devices');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.darkSurfaceGradient
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.background,
                    Color(0xFFE3F2FD),
                  ],
                ),
        ),
        child: SafeArea(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // App Logo with Pulse Animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: PulseAnimation(
                        minScale: 1.0,
                        maxScale: 1.05,
                        child: _buildLogo(isDark),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Title
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Semantics(
                      header: true,
                      label: '엘리베이터 호출',
                      child: Text(
                        '엘리베이터 호출',
                        style: AppTypography.headlineLarge.copyWith(
                          color: isDark
                              ? AppColors.darkOnSurface
                              : AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Subtitle
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Text(
                      'QR 코드를 스캔하여 엘리베이터를 호출하세요',
                      style: AppTypography.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.darkOnSurfaceVariant
                            : AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const Spacer(),
                // QR Scan Button
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Semantics(
                      button: true,
                      label: SemanticLabels.scanQrButton,
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _onScanPressed,
                          icon: const Icon(Icons.qr_code_scanner, size: 28),
                          label: Text(
                            'QR 코드 스캔',
                            style: AppTypography.buttonLarge,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            elevation: 4,
                            shadowColor: AppColors.primary.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppSpacing.borderRadiusLG,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Mock Mode Button
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Semantics(
                      button: true,
                      label: SemanticLabels.mockModeButton,
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _onMockModePressed,
                          icon: const Icon(Icons.bluetooth, size: 28),
                          label: Text(
                            'Mock 모드로 테스트',
                            style: AppTypography.buttonLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppSpacing.borderRadiusLG,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Info Text
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Bluetooth와 칩라 권한이 필요합니다',
                    style: AppTypography.caption.copyWith(
                      color: isDark
                          ? AppColors.darkOnSurfaceVariant
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.elevator,
        size: 72,
        color: Colors.white,
      ),
    );
  }
}
