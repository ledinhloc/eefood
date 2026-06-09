import 'dart:io';

import 'package:camera/camera.dart';
import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/post/presentation/provider/post_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';

class IngredientSearchPage extends StatefulWidget {
  const IngredientSearchPage({super.key});

  @override
  State<IngredientSearchPage> createState() => _IngredientSearchPageState();
}

class _IngredientSearchPageState extends State<IngredientSearchPage> {
  final ImagePicker _picker = ImagePicker();
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isFlashOn = false;
  File? _previewImage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    } catch (e, stackTrace) {
      debugPrint('[IngredientSearchPage] init camera failed error=$e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      await showCustomSnackBar(
        context,
        'Không thể khởi tạo camera',
        isError: true,
      );
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    _isFlashOn = !_isFlashOn;
    await _cameraController!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _pickFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;

    final file = File(image.path);
    setState(() {
      _previewImage = file;
    });

    await _detectIngredientsAndReturnToFeed(file);
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      final file = File(image.path);

      if (!mounted) return;
      setState(() {
        _previewImage = file;
      });

      await _detectIngredientsAndReturnToFeed(file);
    } catch (e, stackTrace) {
      debugPrint('[IngredientSearchPage] take photo failed error=$e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      await showCustomSnackBar(
        context,
        'Không thể chụp ảnh',
        isError: true,
      );
    }
  }

  Future<void> _detectIngredientsAndReturnToFeed(File file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: SpinKitCircle(color: Colors.orange)),
    );

    final cubit = getIt<PostListCubit>();

    try {
      final labels = await cubit.postRepo.detectIngredientLabels(file);
      final keyword = labels.toSet().join(' ').trim();

      if (keyword.isEmpty) {
        throw Exception('No ingredients detected');
      }

      await cubit.saveKeyword(keyword);
      await cubit.setFilters(keyword: keyword);

      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).popUntil(
        (route) => route.settings.name == AppRoutes.main || route.isFirst,
      );
    } catch (e, stackTrace) {
      debugPrint('[IngredientSearchPage] failed error=$e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      Navigator.of(context).pop();
      setState(() {
        _previewImage = null;
      });
      await showCustomSnackBar(
        context,
        'Không nhận diện được nguyên liệu trong ảnh',
        isError: true,
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm món từ nguyên liệu'),
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isInitialized)
            CameraPreview(_cameraController!)
          else
            const Center(child: CircularProgressIndicator()),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.18),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.35),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              width: 290,
              height: 290,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white70, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(21),
                child: _previewImage != null
                    ? Image.file(_previewImage!, fit: BoxFit.cover)
                    : Container(
                        color: Colors.white.withValues(alpha: 0.06),
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.food_bank_outlined,
                              color: Colors.white,
                              size: 52,
                            ),
                            SizedBox(height: 12),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                'Đưa nguyên liệu vào khung hình',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 130,
            child: Text(
              'Chụp ảnh hoặc chọn từ thư viện, ứng dụng sẽ nhận diện nguyên liệu và tìm kiếm món ăn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: _pickFromGallery,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white70, width: 2),
                      color: Colors.white10,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _previewImage != null
                          ? Image.file(_previewImage!, fit: BoxFit.cover)
                          : const Icon(
                              Icons.photo_library_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 58),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
