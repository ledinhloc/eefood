import 'dart:io';

import 'package:camera/camera.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/nutrition/presentation/provider/nutrition_cubit.dart';
import 'package:eefood/features/nutrition/presentation/screens/nutrition_result_screen.dart';
import 'package:eefood/features/nutrition/presentation/widgets/scan_overlay_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

class NutritionCameraScreen extends StatefulWidget {
  const NutritionCameraScreen({super.key});

  @override
  State<NutritionCameraScreen> createState() => _NutritionCameraScreenState();
}

class _NutritionCameraScreenState extends State<NutritionCameraScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isFlashOn = false;
  bool _isInitialized = false;
  File? _recentPhotoFile;
  File? _capturedPhotoOverlay;

  // Pulse animation cho scan overlay
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadRecentPhoto();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );
    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    if (mounted) setState(() => _isInitialized = true);
  }

  Future<void> _loadRecentPhoto() async {
    try {
      final ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) return;
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );
      if (albums.isEmpty) return;
      final assets = await albums.first.getAssetListRange(start: 0, end: 1);
      if (assets.isNotEmpty) {
        final file = await assets.first.file;
        if (file != null && mounted) setState(() => _recentPhotoFile = file);
      }
    } catch (_) {}
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    _isFlashOn = !_isFlashOn;
    await _cameraController!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
    setState(() {});
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    try {
      final image = await _cameraController!.takePicture();
      final file = File(image.path);
      setState(() => _capturedPhotoOverlay = file);

      final bytes = await file.readAsBytes();
      await ImageGallerySaverPlus.saveImage(
        bytes,
        name: "eefood_nutrition_${DateTime.now().millisecondsSinceEpoch}",
        quality: 90,
      );
      setState(() => _recentPhotoFile = file);

      await _startAnalysis(file);
    } catch (_) {}
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final file = File(image.path);
    setState(() {
      _capturedPhotoOverlay = file;
      _recentPhotoFile = file;
    });
    await _startAnalysis(file);
  }

  Future<void> _startAnalysis(File file) async {
    final cubit = getIt<NutritionCubit>();

    // Navigate to result screen immediately - nó sẽ tự xử lý loading
    if (!mounted) return;

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => BlocProvider.value(
          value: cubit,
          child: NutritionResultScreen(imageFile: file),
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ).then((_) {
      // Reset khi quay lại
      setState(() => _capturedPhotoOverlay = null);
      cubit.reset();
    });

    // Kick off analysis sau khi navigation bắt đầu
    cubit.analyzeImage(file);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Phân tích dinh dưỡng',
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
                color: _isFlashOn ? const Color(0xFFFF6B00) : Colors.white70,
              ),
            ),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          if (_isInitialized)
            CameraPreview(_cameraController!)
          else
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
            ),

          // Dimmed overlay ngoài khung quét
          if (_isInitialized) _buildScanOverlay(),

          // Instruction text
          if (_isInitialized)
            Positioned(
              bottom: 160,
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
                    'Đặt món ăn vào khung để phân tích',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

          // Bottom controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery button
                GestureDetector(
                  onTap: _pickFromGallery,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white38, width: 2),
                      color: Colors.white10,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _recentPhotoFile != null
                          ? Image.file(_recentPhotoFile!, fit: BoxFit.cover)
                          : const Icon(
                              Icons.photo_library_rounded,
                              color: Colors.white70,
                              size: 26,
                            ),
                    ),
                  ),
                ),

                // Shutter button
                GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B00).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF6B00), Color(0xFFFF9A3C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 56),
              ],
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
            capturedImage: _capturedPhotoOverlay,
          ),
        );
      },
    );
  }
}
