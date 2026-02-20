import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/ble_device.dart';
import '../models/elevator_info.dart';
import '../services/ble_service.dart';
import '../design_system/colors.dart';
import '../design_system/typography.dart';
import '../design_system/spacing.dart';
import '../design_system/components.dart';
import '../animations/feedback_animations.dart';
import '../animations/loading_animations.dart';
import '../animations/animation_utils.dart';
import '../accessibility/semantic_labels.dart';
import '../accessibility/dark_mode.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with SingleTickerProviderStateMixin {
  CallStatus _status = CallStatus.idle;
  int _estimatedTime = 0;
  Timer? _timer;
  String? _errorMessage;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.slow,
      vsync: this,
    );
    _callElevator();
  }

  Future<void> _callElevator() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final targetFloor = args?['targetFloor'] as int? ?? 1;

    setState(() {
      _status = CallStatus.calling;
      _estimatedTime = 15;
    });

    final bleService = context.read<BleService>();

    try {
      // Send call command via BLE
      await bleService.sendCommand('CALL:$targetFloor');

      setState(() {
        _status = CallStatus.moving;
      });

      // Haptic feedback for status change
      HapticFeedback.mediumImpact();

      // Start countdown timer
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_estimatedTime > 0) {
          setState(() {
            _estimatedTime--;
          });
        } else {
          setState(() {
            _status = CallStatus.arrived;
          });
          _timer?.cancel();
          HapticFeedback.heavyImpact();
        }
      });

      // Poll for status updates
      _pollStatus();
    } catch (e) {
      setState(() {
        _status = CallStatus.error;
        _errorMessage = e.toString();
      });
      HapticFeedback.vibrate();
    }
  }

  Future<void> _pollStatus() async {
    final bleService = context.read<BleService>();

    Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_status == CallStatus.arrived || _status == CallStatus.error) {
        timer.cancel();
        return;
      }

      try {
        final status = await bleService.readStatus();
        if (status != null && status.contains('arrived')) {
          setState(() {
            _status = CallStatus.arrived;
          });
          timer.cancel();
          HapticFeedback.heavyImpact();
        }
      } catch (e) {
        // Ignore polling errors
      }
    });
  }

  void _onComplete() {
    HapticFeedback.lightImpact();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _onRetry() {
    HapticFeedback.lightImpact();
    setState(() {
      _status = CallStatus.idle;
      _errorMessage = null;
    });
    _callElevator();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final device = args?['device'] as BleDevice?;
    final elevatorInfo = args?['elevatorInfo'] as ElevatorInfo?;
    final targetFloor = args?['targetFloor'] as int? ?? 1;
    final isDark = context.isDarkMode;

    return WillPopScope(
      onWillPop: () async => _status != CallStatus.calling,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('엘리베이터 호출'),
          automaticallyImplyLeading: _status != CallStatus.calling,
        ),
        body: Center(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Progress Steps
                _buildProgressSteps(),
                const SizedBox(height: AppSpacing.xxl),
                // Status Icon
                _buildStatusIcon(),
                const SizedBox(height: AppSpacing.xl),
                // Status Text
                Semantics(
                  label: '${SemanticLabels.callStatus}: ${_getStatusText()}',
                  liveRegion: true,
                  child: Text(
                    _getStatusText(),
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Floor Info
                if (elevatorInfo != null)
                  Container(
                    padding: AppSpacing.paddingMD,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceContainer
                          : AppColors.surfaceContainerLow,
                      borderRadius: AppSpacing.borderRadiusMD,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.elevator,
                          color: isDark
                              ? AppColors.darkOnSurfaceVariant
                              : AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '${elevatorInfo.elevatorId} → ${targetFloor}층',
                          style: AppTypography.bodyLarge.copyWith(
                            color: isDark
                                ? AppColors.darkOnSurface
                                : AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),
                // Estimated Time or Error
                if (_status == CallStatus.moving)
                  _buildTimerDisplay(),
                if (_status == CallStatus.error && _errorMessage != null)
                  _buildErrorDisplay(),
                const SizedBox(height: AppSpacing.xxl),
                // Action Button
                if (_status == CallStatus.arrived || _status == CallStatus.error)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _status == CallStatus.arrived ? _onComplete : _onRetry,
                      icon: Icon(
                        _status == CallStatus.arrived ? Icons.check : Icons.refresh,
                        size: 24,
                      ),
                      label: Text(
                        _status == CallStatus.arrived ? '완료' : '다시 시도',
                        style: AppTypography.buttonLarge,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _status == CallStatus.arrived
                            ? AppColors.success
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: (_status == CallStatus.arrived
                                ? AppColors.success
                                : AppColors.primary)
                            .withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.borderRadiusLG,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSteps() {
    final steps = [
      CallStatus.calling,
      CallStatus.moving,
      CallStatus.arrived,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isActive = _getStepIndex(_status) >= index;
        final isCurrent = _getStepIndex(_status) == index;

        return Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.surfaceContainer,
                shape: BoxShape.circle,
                border: isCurrent
                    ? Border.all(
                        color: AppColors.primary,
                        width: 3,
                      )
                    : null,
              ),
              child: Center(
                child: isActive && index < _getStepIndex(_status)
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : Text(
                        '${index + 1}',
                        style: AppTypography.titleMedium.copyWith(
                          color: isActive ? Colors.white : AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            if (index < steps.length - 1)
              Container(
                width: 40,
                height: 2,
                color: isActive ? AppColors.primary : AppColors.surfaceContainer,
              ),
          ],
        );
      }).toList(),
    );
  }

  int _getStepIndex(CallStatus status) {
    return switch (status) {
      CallStatus.idle => -1,
      CallStatus.calling => 0,
      CallStatus.moving => 1,
      CallStatus.arrived => 2,
      CallStatus.error => -1,
    };
  }

  Widget _buildStatusIcon() {
    switch (_status) {
      case CallStatus.idle:
        return Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.elevator,
            size: 72,
            color: AppColors.primary,
          ),
        );
      case CallStatus.calling:
        return SizedBox(
          width: 140,
          height: 140,
          child: AnimatedSpinner(
            size: 140,
            color: AppColors.primary,
          ),
        );
      case CallStatus.moving:
        return PulseAnimation(
          minScale: 1.0,
          maxScale: 1.1,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_upward,
              size: 64,
              color: Colors.white,
            ),
          ),
        );
      case CallStatus.arrived:
        return SuccessCheck(
          size: 140,
          onComplete: () {},
        );
      case CallStatus.error:
        return ErrorShake(
          trigger: true,
          child: Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close,
              size: 72,
              color: Colors.white,
            ),
          ),
        );
    }
  }

  Widget _buildTimerDisplay() {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppSpacing.borderRadiusXL,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '예상 도착 시간',
            style: AppTypography.labelLarge.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedSwitcher(
            duration: AppDurations.fast,
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: Text(
              '$_estimatedTime초',
              key: ValueKey(_estimatedTime),
              style: AppTypography.displayMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusLG,
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              _errorMessage!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (_status) {
      case CallStatus.idle:
        return '호출 준비중';
      case CallStatus.calling:
        return '엘리베이터 호출중...';
      case CallStatus.moving:
        return '엘리베이터가 이동중입니다';
      case CallStatus.arrived:
        return '엘리베이터가 도착했습니다!';
      case CallStatus.error:
        return '호출에 실패했습니다';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}

enum CallStatus {
  idle,
  calling,
  moving,
  arrived,
  error,
}
