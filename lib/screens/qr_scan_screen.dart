import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/elevator_info.dart';
import '../design_system/colors.dart';
import '../design_system/typography.dart';
import '../design_system/spacing.dart';
import '../design_system/components.dart';
import '../animations/feedback_animations.dart';
import '../animations/loading_animations.dart';
import '../accessibility/semantic_labels.dart';
import '../accessibility/dark_mode.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen>
    with SingleTickerProviderStateMixin {
  bool _isFlashOn = false;
  bool _isScanning = true;
  double _zoomScale = 1.0;
  MobileScannerController? _controller;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        _showPermissionDeniedDialog();
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('권한 필요'),
        content: const Text('QR 코드 스캔을 위해 칩라 권한이 필요합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isScanning = false;
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Parse QR data
    final elevatorInfo = ElevatorInfo.fromQRData(code);

    // Show result and navigate
    if (mounted) {
      _showScanResult(elevatorInfo);
    }
  }

  void _showScanResult(ElevatorInfo info) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ScanResultBottomSheet(
        info: info,
        onRescan: () {
          Navigator.pop(context);
          setState(() {
            _isScanning = true;
          });
        },
        onContinue: () {
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            '/ble_devices',
            arguments: info,
          );
        },
      ),
    );
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    _controller?.toggleTorch();
    HapticFeedback.lightImpact();
  }

  void _setZoom(double scale) {
    setState(() {
      _zoomScale = scale.clamp(1.0, 5.0);
    });
    _controller?.setZoomScale(_zoomScale);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'QR 코드 스캔',
          style: AppTypography.titleLarge.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            tooltip: SemanticLabels.flashToggle,
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Preview
          MobileScanner(
            controller: _controller ??= MobileScannerController(
              torchEnabled: _isFlashOn,
            ),
            onDetect: _onDetect,
          ),
          // Scan Overlay
          _buildScanOverlay(isDark),
          // Instructions
          _buildInstructions(),
          // Zoom Control
          _buildZoomControl(),
        ],
      ),
    );
  }

  Widget _buildScanOverlay(bool isDark) {
    return Stack(
      children: [
        // Dark overlay with cutout
        CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _ScanOverlayPainter(),
        ),
        // Scan frame with corners
        Center(
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              borderRadius: AppSpacing.borderRadiusLG,
              border: Border.all(
                color: AppColors.accentColor.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                // Corner markers
                _buildCornerMarkers(),
                // Scan line animation
                if (_isScanning)
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Positioned(
                        top: 280 * _animationController.value,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.accentColor,
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentColor.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCornerMarkers() {
    const cornerSize = 30.0;
    const cornerThickness = 4.0;
    const cornerColor = AppColors.accentColor;

    return Stack(
      children: [
        // Top left
        Positioned(
          top: 0,
          left: 0,
          child: _buildCorner(
            cornerSize,
            cornerThickness,
            cornerColor,
            [true, false, false, true],
          ),
        ),
        // Top right
        Positioned(
          top: 0,
          right: 0,
          child: _buildCorner(
            cornerSize,
            cornerThickness,
            cornerColor,
            [false, true, true, false],
          ),
        ),
        // Bottom left
        Positioned(
          bottom: 0,
          left: 0,
          child: _buildCorner(
            cornerSize,
            cornerThickness,
            cornerColor,
            [false, true, true, false],
          ),
        ),
        // Bottom right
        Positioned(
          bottom: 0,
          right: 0,
          child: _buildCorner(
            cornerSize,
            cornerThickness,
            cornerColor,
            [true, false, false, true],
          ),
        ),
      ],
    );
  }

  Widget _buildCorner(
    double size,
    double thickness,
    Color color,
    List<bool> borders,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border(
          top: borders[0]
              ? BorderSide(color: color, width: thickness)
              : BorderSide.none,
          right: borders[1]
              ? BorderSide(color: color, width: thickness)
              : BorderSide.none,
          bottom: borders[2]
              ? BorderSide(color: color, width: thickness)
              : BorderSide.none,
          left: borders[3]
              ? BorderSide(color: color, width: thickness)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      bottom: 150,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: AppSpacing.borderRadiusMD,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '엘리베이터 QR 코드를 스캔하세요',
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '프레임 안에 QR 코드를 맞춰주세요',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoomControl() {
    return Positioned(
      bottom: 50,
      left: 50,
      right: 50,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: AppSpacing.borderRadiusFull,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.zoom_out,
              color: Colors.white,
              size: 20,
            ),
            Expanded(
              child: Slider(
                value: _zoomScale,
                min: 1.0,
                max: 5.0,
                divisions: 8,
                activeColor: AppColors.accentColor,
                inactiveColor: Colors.white30,
                onChanged: _setZoom,
              ),
            ),
            const Icon(
              Icons.zoom_in,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller?.dispose();
    super.dispose();
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final cutoutSize = 280.0;
    final cutoutLeft = (size.width - cutoutSize) / 2;
    final cutoutTop = (size.height - cutoutSize) / 2;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cutoutLeft, cutoutTop, cutoutSize, cutoutSize),
          const Radius.circular(16),
        ),
      );

    canvas.drawPath(path, paint..fillType = PathFillType.evenOdd);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanResultBottomSheet extends StatelessWidget {
  final ElevatorInfo info;
  final VoidCallback onRescan;
  final VoidCallback onContinue;

  const _ScanResultBottomSheet({
    required this.info,
    required this.onRescan,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXL),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkOutline : AppColors.outline,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Success Icon
            SuccessCheck(
              size: 80,
              onComplete: () {},
            ),
            const SizedBox(height: AppSpacing.lg),
            // Title
            Text(
              'QR 코드 인식 완료',
              style: AppTypography.headlineSmall.copyWith(
                color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Info Card
            AppCard.flat(
              padding: AppSpacing.cardPaddingLG,
              child: Column(
                children: [
                  _buildInfoRow('엘리베이터 ID', info.elevatorId),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoRow('현재 층', '${info.floor}층'),
                  if (info.buildingName != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildInfoRow('건물', info.buildingName!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton.outlined(
                    label: '다시 스캔',
                    onPressed: onRescan,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: '계속',
                    onPressed: onContinue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
