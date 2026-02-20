import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ble_device.dart';
import '../models/elevator_info.dart';
import '../design_system/colors.dart';
import '../design_system/typography.dart';
import '../design_system/spacing.dart';
import '../design_system/components.dart';
import '../animations/feedback_animations.dart';
import '../animations/animation_utils.dart';
import '../accessibility/semantic_labels.dart';
import '../accessibility/dark_mode.dart';

class FloorSelectionScreen extends StatefulWidget {
  const FloorSelectionScreen({super.key});

  @override
  State<FloorSelectionScreen> createState() => _FloorSelectionScreenState();
}

class _FloorSelectionScreenState extends State<FloorSelectionScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedFloor;
  int _currentFloor = 1;
  late AnimationController _controller;

  final List<int> _floors = [
    -3, -2, -1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.medium,
      vsync: this,
    );

    // Get current floor from arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      final elevatorInfo = args?['elevatorInfo'] as ElevatorInfo?;
      if (elevatorInfo != null) {
        setState(() {
          _currentFloor = int.tryParse(elevatorInfo.floor) ?? 1;
        });
      }
      _controller.forward();
    });
  }

  void _onFloorSelected(int floor) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedFloor = floor;
    });
  }

  void _onConfirm() {
    if (_selectedFloor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('층을 선택해주세요')),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final device = args?['device'] as BleDevice?;
    final elevatorInfo = args?['elevatorInfo'] as ElevatorInfo?;

    Navigator.pushNamed(
      context,
      '/call',
      arguments: {
        'device': device,
        'elevatorInfo': elevatorInfo,
        'targetFloor': _selectedFloor,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final device = args?['device'] as BleDevice?;
    final elevatorInfo = args?['elevatorInfo'] as ElevatorInfo?;
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('층 선택'),
      ),
      body: Column(
        children: [
          // Device Info Card
          _buildDeviceInfoCard(device, elevatorInfo, isDark),
          // Selected Floor Display
          _buildSelectedFloorDisplay(isDark),
          // Floor Grid
          Expanded(
            child: Semantics(
              label: SemanticLabels.floorGrid,
              child: GridView.builder(
                padding: AppSpacing.paddingMD,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _floors.length,
                itemBuilder: (context, index) {
                  final floor = _floors[index];
                  final isSelected = _selectedFloor == floor;
                  final isCurrentFloor = floor == _currentFloor;

                  return FadeTransition(
                    opacity: TweenUtils.staggered(
                      _controller,
                      startInterval: index * 0.02,
                      endInterval: (index + 1) * 0.02,
                    ),
                    child: _buildFloorButton(
                      floor,
                      isSelected,
                      isCurrentFloor,
                      isDark,
                    ),
                  );
                },
              ),
            ),
          ),
          // Confirm Button
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoCard(BleDevice? device, ElevatorInfo? elevatorInfo, bool isDark) {
    return AppCard.flat(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (device != null) ...[
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusSM,
                  ),
                  child: const Icon(
                    Icons.bluetooth_connected,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '연결된 기기',
                        style: AppTypography.labelMedium.copyWith(
                          color: isDark
                              ? AppColors.darkOnSurfaceVariant
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        device.displayName,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (elevatorInfo != null) ...[
            if (device != null) const SizedBox(height: AppSpacing.md),
            Container(
              padding: AppSpacing.paddingSM,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: AppSpacing.borderRadiusMD,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '현재 위치: ${elevatorInfo.floor}층',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedFloorDisplay(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          Text(
            '선택된 층',
            style: AppTypography.labelLarge.copyWith(
              color: isDark
                  ? AppColors.darkOnSurfaceVariant
                  : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedSwitcher(
            duration: AppDurations.normal,
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: Text(
              _selectedFloor != null ? '${_selectedFloor}층' : '-',
              key: ValueKey(_selectedFloor),
              style: AppTypography.displaySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: _selectedFloor != null
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorButton(
    int floor,
    bool isSelected,
    bool isCurrentFloor,
    bool isDark,
  ) {
    return TouchFeedback(
      onTap: () => _onFloorSelected(floor),
      hapticFeedback: HapticFeedbackType.selection,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected
              ? null
              : isCurrentFloor
                  ? AppColors.secondary.withOpacity(0.15)
                  : (isDark
                      ? AppColors.darkSurfaceContainer
                      : AppColors.surface),
          borderRadius: AppSpacing.borderRadiusMD,
          border: isCurrentFloor
              ? Border.all(
                  color: AppColors.secondary,
                  width: 2,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${floor}F',
                style: AppTypography.titleMedium.copyWith(
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColors.darkOnSurface
                          : AppColors.onSurface),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
              if (isCurrentFloor)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.3)
                        : AppColors.secondary.withOpacity(0.2),
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Text(
                    '현재',
                    style: AppTypography.labelSmall.copyWith(
                      color: isSelected ? Colors.white : AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: AppSpacing.paddingMD,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _selectedFloor != null ? _onConfirm : null,
          icon: const Icon(Icons.elevator, size: 24),
          label: Text(
            '엘리베이터 호출',
            style: AppTypography.buttonLarge,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.38),
            elevation: _selectedFloor != null ? 4 : 0,
            shadowColor: AppColors.primary.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusLG,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
