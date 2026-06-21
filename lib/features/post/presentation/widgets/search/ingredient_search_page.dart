import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/meal_plan/domain/repository/meal_plan_repository.dart';
import 'package:eefood/features/meal_plan/presentation/provider/meal_plan_cubit.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/update_item/meal_plan_item_upsert_sheet.dart';
import 'package:eefood/features/post/data/models/ingredient_detection_result.dart';
import 'package:eefood/features/post/presentation/provider/post_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isPickingImage = false;
  File? _previewImage;
  IngredientDetectionResult? _detectionResult;

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
    if (_isPickingImage) return;

    _isPickingImage = true;
    final XFile? image;
    try {
      image = await _picker.pickImage(source: ImageSource.gallery);
    } on PlatformException catch (e) {
      debugPrint('[IngredientSearchPage] pick image failed error=$e');
      if (e.code == 'already_active') {
        return;
      }
      rethrow;
    } finally {
      _isPickingImage = false;
    }

    if (image == null || !mounted) return;

    final file = File(image.path);
    setState(() {
      _previewImage = file;
      _detectionResult = null;
    });

    await _detectIngredients(file);
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
        _detectionResult = null;
      });

      await _detectIngredients(file);
    } catch (e, stackTrace) {
      debugPrint('[IngredientSearchPage] take photo failed error=$e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      await showCustomSnackBar(context, 'Không thể chụp ảnh', isError: true);
    }
  }

  Future<void> _detectIngredients(File file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: SpinKitCircle(color: Colors.orange)),
    );

    final cubit = getIt<PostListCubit>();

    try {
      final result = await cubit.postRepo.detectIngredientsWithAnnotatedImage(
        file,
      );
      final keyword = result.labels.toSet().join(' ').trim();

      if (keyword.isEmpty) {
        throw Exception('No ingredients detected');
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      setState(() {
        _detectionResult = result;
      });
    } catch (e, stackTrace) {
      debugPrint('[IngredientSearchPage] failed error=$e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      Navigator.of(context).pop();
      setState(() {
        _previewImage = null;
        _detectionResult = null;
      });
      await showCustomSnackBar(
        context,
        'Không nhận diện được nguyên liệu trong ảnh',
        isError: true,
      );
    }
  }

  Future<void> _searchDetectedIngredients() async {
    final labels = _detectionResult?.labels ?? const [];
    final keyword = labels.toSet().join(' ').trim();

    if (keyword.isEmpty) {
      await showCustomSnackBar(
        context,
        'Không có nguyên liệu để tìm kiếm',
        isError: true,
      );
      return;
    }

    final cubit = getIt<PostListCubit>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: SpinKitCircle(color: Colors.orange)),
    );

    try {
      await cubit.saveKeyword(keyword);
      await cubit.setFilters(keyword: keyword);

      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).popUntil(
        (route) => route.settings.name == AppRoutes.main || route.isFirst,
      );
    } catch (e, stackTrace) {
      debugPrint('[IngredientSearchPage] search failed error=$e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      Navigator.of(context).pop();
      await showCustomSnackBar(
        context,
        'Không thể tìm món với nguyên liệu này',
        isError: true,
      );
    }
  }

  Future<void> _addDetectedIngredientsToMealPlan() async {
    final labels = (_detectionResult?.labels ?? const <String>[])
        .map((label) => label.trim())
        .where((label) => label.isNotEmpty)
        .toSet()
        .toList();

    if (labels.isEmpty) {
      await showCustomSnackBar(
        context,
        'Không có nguyên liệu để thêm vào kế hoạch',
        isError: true,
      );
      return;
    }

    final mealPlanCubit = MealPlanCubit(
      repository: getIt<MealPlanRepository>(),
    );
    final now = DateTime.now();
    final detectedMealName =
        '${labels.join(', ')} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';

    try {
      await showMealPlanItemUpsertSheet(
        context: context,
        cubit: mealPlanCubit,
        selectedDate: DateTime.now(),
        initialCustomMealName: detectedMealName,
        initialIngredientNames: labels,
      );
    } finally {
      await mealPlanCubit.close();
    }
  }

  Uint8List? _annotatedImageBytes() {
    final base64Image = _detectionResult?.annotatedImageBase64;
    if (base64Image == null || base64Image.isEmpty) return null;

    final normalized = base64Image.contains(',')
        ? base64Image.split(',').last
        : base64Image;

    try {
      return base64Decode(normalized);
    } catch (e) {
      debugPrint('[IngredientSearchPage] decode annotated image failed=$e');
      return null;
    }
  }

  void _clearDetection() {
    setState(() {
      _previewImage = null;
      _detectionResult = null;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final annotatedImageBytes = _annotatedImageBytes();
    final labels = _detectionResult?.labels ?? const [];
    final hasDetection = _detectionResult != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.28),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
        title: const Text(
          'Quét nguyên liệu',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.28),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                ),
                onPressed: _toggleFlash,
              ),
            ),
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
                child: annotatedImageBytes != null
                    ? Image.memory(annotatedImageBytes, fit: BoxFit.cover)
                    : _previewImage != null
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
            bottom: hasDetection ? 186 : 130,
            child: hasDetection
                ? ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 92),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: labels
                            .map(
                              (label) => Chip(
                                label: Text(label),
                                backgroundColor: Colors.white,
                                side: BorderSide.none,
                                labelStyle: const TextStyle(
                                  color: Color(0xFFE67E22),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  )
                : Text(
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
            child: hasDetection
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _addDetectedIngredientsToMealPlan,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white70),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Thêm vào kế hoạch'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _clearDetection,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white70),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text('Chụp lại'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _searchDetectedIngredients,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE67E22),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text('Tìm món'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Row(
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
