import 'package:eefood/app_routes.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/nutrition/presentation/widgets/scan_overlay_painter.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController(
    lensType: CameraLensType.normal,
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool _isFlashOn = false;
  bool _hasScanned = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _toggleFlash() async {
    await _scannerController.toggleTorch();
    setState(() => _isFlashOn = !_isFlashOn);
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcode = capture.barcodes.firstOrNull;
    final rawValue = barcode?.rawValue;
    if (rawValue == null) return;

    final recipeId = _extractRecipeId(rawValue);
    if (recipeId == null) {
      showCustomSnackBar(
        context,
        "Mã QR không hợp lệ hoặc không phải công thức nấu ăn",
        isError: true,
      );
      return;
    }

    setState(() => _hasScanned = true);
    _scannerController.stop();

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.recipeDetail,
      arguments: {'recipeId': recipeId},
    );
  }

  int? _extractRecipeId(String url) {
    try {
      final uri = Uri.parse(url);

      // Dạng query param: ?recipeId=12
      final queryId = uri.queryParameters['recipeId'];
      if (queryId != null) return int.tryParse(queryId);

      // Dạng path segment: /recipes/12
      final segments = uri.pathSegments;
      final recipeIndex = segments.indexOf('recipes');
      if (recipeIndex != -1 && recipeIndex + 1 < segments.length) {
        return int.tryParse(segments[recipeIndex + 1]);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Quét mã QR',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                key: ValueKey(_isFlashOn),
                color: _isFlashOn ? const Color(0xFFFF6B00) : Colors.white,
              ),
            ),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera scanner
          MobileScanner(controller: _scannerController, onDetect: _onDetect),

          // Dimmed overlay + scan box (tái sử dụng logic từ NutritionCameraScreen)
          _buildScanOverlay(),

          // Instruction text (tái sử dụng style từ NutritionCameraScreen)
          Positioned(
            bottom: 200,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Đưa mã QR vào khung để quét tự động',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Loading overlay khi đang xử lý
          if (_hasScanned)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    const boxSize = 280.0;
    const radius = 20.0;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        final glowOpacity = 0.4 + 0.4 * _pulseAnim.value;
        final scanLineY = _pulseAnim.value;

        return CustomPaint(
          painter: ScanOverlayPainter(
            boxSize: boxSize,
            borderRadius: radius,
            glowOpacity: glowOpacity,
            scanLineY: scanLineY,
            capturedImage: null,
          ),
        );
      },
    );
  }
}
