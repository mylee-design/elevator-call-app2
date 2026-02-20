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
import '../animations/loading_animations.dart';
import '../animations/feedback_animations.dart';
import '../accessibility/semantic_labels.dart';
import '../accessibility/dark_mode.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';

class BleDevicesScreen extends StatefulWidget {
  const BleDevicesScreen({super.key});

  @override
  State<BleDevicesScreen> createState() => _BleDevicesScreenState();
}

class _BleDevicesScreenState extends State<BleDevicesScreen> {
  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    final bleService = context.read<BleService>();
    try {
      await bleService.startScan(timeout: const Duration(seconds: 10));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          ErrorSnackBar.create(message: '스캔 오류: $e'),
        );
      }
    }
  }

  Future<void> _connectToDevice(BleDevice device) async {
    final bleService = context.read<BleService>();

    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: AnimatedSpinner(),
      ),
    );

    try {
      await bleService.connect(device);
      if (mounted) {
        Navigator.pop(context);
        final elevatorInfo =
            ModalRoute.of(context)?.settings.arguments as ElevatorInfo?;
        Navigator.pushNamed(
          context,
          '/floor_selection',
          arguments: {
            'device': device,
            'elevatorInfo': elevatorInfo,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          ErrorSnackBar.create(message: '연결 실패: $e'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final elevatorInfo =
        ModalRoute.of(context)?.settings.arguments as ElevatorInfo?;
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE 기기 선택'),
        actions: [
          Consumer<BleService>(
            builder: (context, bleService, child) {
              if (bleService.isScanning) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: SemanticLabels.scanButton,
                onPressed: _startScan,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Elevator Info Card
          if (elevatorInfo != null) _buildElevatorInfoCard(elevatorInfo, isDark),
          // Device List
          Expanded(
            child: Consumer<BleService>(
              builder: (context, bleService, child) {
                if (bleService.isScanning && bleService.devices.isEmpty) {
                  return _buildLoadingState();
                }

                if (bleService.devices.isEmpty) {
                  return EmptyState.noDevices(
                    onAction: _startScan,
                  );
                }

                return Semantics(
                  label: SemanticLabels.deviceList,
                  child: ListView.separated(
                    padding: AppSpacing.paddingMD,
                    itemCount: bleService.devices.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final device = bleService.devices[index];
                      return _buildDeviceCard(device, isDark);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElevatorInfoCard(ElevatorInfo info, bool isDark) {
    return AppCard.flat(
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusMD,
            ),
            child: const Icon(
              Icons.elevator,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '스캔된 엘리베이터',
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${info.elevatorId} (${info.floor}층)',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SkeletonList(
      itemCount: 4,
      itemHeight: 100,
    );
  }

  Widget _buildDeviceCard(BleDevice device, bool isDark) {
    return AppCard.elevated(
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          // Device Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppSpacing.borderRadiusMD,
            ),
            child: const Icon(
              Icons.bluetooth,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Device Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.displayName,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  device.id,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Signal Strength
                Row(
                  children: [
                    _buildSignalIndicator(device.signalBars),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      device.signalStrength,
                      style: AppTypography.labelMedium.copyWith(
                        color: isDark
                            ? AppColors.darkOnSurfaceVariant
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Connect Button
          AppButton(
            label: '연결',
            size: AppButtonSize.small,
            onPressed: () => _connectToDevice(device),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalIndicator(int bars) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return AnimatedContainer(
          duration: AppDurations.fast,
          width: 4,
          height: 8 + (index * 4),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: index < bars
                ? AppColors.success
                : (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurfaceContainer
                    : AppColors.surfaceContainer),
            borderRadius: AppSpacing.borderRadiusXS,
          ),
        );
      }),
    );
  }
}
