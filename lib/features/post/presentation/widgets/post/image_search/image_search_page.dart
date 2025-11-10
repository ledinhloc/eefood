import 'dart:io';
import 'package:camera/camera.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/post/presentation/provider/post_list_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/post/image_search/image_search_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';

class ImageSearchScreen extends StatefulWidget {
  const ImageSearchScreen({super.key});

  @override
  State<ImageSearchScreen> createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends State<ImageSearchScreen> {
  CameraController? _cameraController;
  bool _isFlashOn = false;
  XFile? _lastImage;
  bool _isInitialized = false;
  File? _recentPhotoFile;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadRecentPhoto();
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
    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  Future<void> _loadRecentPhoto() async {
    try {
      // Yêu cầu quyền truy cập thư viện
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) {
        return;
      }

      // Lấy album gần nhất
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      if (albums.isEmpty) return;

      // Lấy ảnh gần nhất từ album đầu tiên
      final List<AssetEntity> recentAssets = await albums.first
          .getAssetListRange(start: 0, end: 1);

      if (recentAssets.isNotEmpty) {
        final file = await recentAssets.first.file;
        if (file != null && mounted) {
          setState(() {
            _recentPhotoFile = file;
          });
        }
      }
    } catch (e) {
      print('Error loading recent photo: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    _isFlashOn = !_isFlashOn;
    await _cameraController!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
    setState(() {});
  }

  Future<void> _handleImageSearch(File file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: SpinKitCircle(color: Colors.orange)),
    );

    final cubit = getIt<PostListCubit>();
    await cubit.fetchPosts(loadMore: false, imageFile: file);

    if (!mounted) return;
    Navigator.pop(context);

    _showSearchResultsBottomSheet(cubit, file, cubit.state.keyword);
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    try {
      final image = await _cameraController!.takePicture();
      final file = File(image.path);

      // Lưu ảnh vào gallery
      final Uint8List bytes = await file.readAsBytes();
      await ImageGallerySaverPlus.saveImage(
        bytes,
        name: "eefood_${DateTime.now().millisecondsSinceEpoch}",
        quality: 90,
      );

      setState(() => _recentPhotoFile = file);

      // Thực hiện tìm kiếm
      await _handleImageSearch(file);
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final file = File(image.path);
    setState(() => _recentPhotoFile = file);
    await _handleImageSearch(file);
  }

  void _showSearchResultsBottomSheet(
    PostListCubit cubit,
    File imageFile,
    String? keyword,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: ImageSearchResultsSheet(imageFile: imageFile, keyword: keyword),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm bằng hình ảnh'),
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isInitialized)
            CameraPreview(_cameraController!)
          else
            const Center(child: CircularProgressIndicator()),

          // --- Overlay hình vuông bo góc ---
          if (_isInitialized)
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white54, width: 3),
                ),
              ),
            ),

          // --- Thanh dưới: thư viện + chụp ---
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Ảnh thư viện - hiển thị ảnh gần nhất
                GestureDetector(
                  onTap: _pickFromGallery,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white54, width: 2),
                      color: Colors.white10,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: _recentPhotoFile != null
                          ? Image.file(_recentPhotoFile!, fit: BoxFit.cover)
                          : const Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: 28,
                            ),
                    ),
                  ),
                ),

                // Nút chụp
                GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 70), // chừa khoảng cân đối
              ],
            ),
          ),
        ],
      ),
    );
  }
}
