import 'dart:io';

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
  File? _previewImage;

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source);
    if (image == null || !mounted) return;

    final file = File(image.path);
    setState(() {
      _previewImage = file;
    });

    await _detectIngredientsAndReturnToFeed(file);
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
      await showCustomSnackBar(
        context,
        'Không nhận diện được nguyên liệu trong ảnh',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tìm món từ nguyên liệu')),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.orange.shade100),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _previewImage != null
                        ? Image.file(_previewImage!, fit: BoxFit.cover)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.food_bank_outlined,
                                size: 72,
                                color: Colors.orange.shade400,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Chụp hoặc chọn ảnh nguyên liệu',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Text(
                                  'Ảnh sẽ được gửi lên để nhận diện nguyên liệu rồi tự động quay về trang món ăn.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Chụp hình'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text('Chọn từ thư viện'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange.shade700,
                    side: BorderSide(color: Colors.orange.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
