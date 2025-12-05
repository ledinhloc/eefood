import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/file_upload.dart';
import 'package:eefood/core/utils/media_picker.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/post/data/models/story_collection_model.dart';
import 'package:eefood/features/post/presentation/provider/story_collection_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateAndUpdateCollectionDialog extends StatefulWidget {
  final int userId;
  final StoryCollectionModel? collection;

  const CreateAndUpdateCollectionDialog({
    super.key,
    required this.userId,
    this.collection,
  });

  @override
  State<CreateAndUpdateCollectionDialog> createState() =>
      _CreateAndUpdateCollectionDialogState();
}

class _CreateAndUpdateCollectionDialogState
    extends State<CreateAndUpdateCollectionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _fileUpload = getIt<FileUploader>();

  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.collection != null) {
      _nameController.text = widget.collection!.name ?? '';
      _descriptionController.text = widget.collection!.description ?? '';
      _uploadedImageUrl = widget.collection!.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await MediaPicker.pickImage();
      if (image == null) return;

      setState(() => _isUploading = true);

      final url = await _fileUpload.uploadFile(image);

      if (mounted) {
        setState(() {
          _selectedImage = image;
          _uploadedImageUrl = url;
          _isUploading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        showCustomSnackBar(context, 'Lỗi tải ảnh: $e', isError: true);
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _uploadedImageUrl = null;
    });
  }

  void _saveCollection() {
    if (!_formKey.currentState!.validate()) return;

    final collection = StoryCollectionModel(
      userId: widget.userId,
      name: _nameController.text.trim(),
      imageUrl: _uploadedImageUrl ?? '',
      description: _descriptionController.text.trim(),
    );

    final cubit = context.read<StoryCollectionCubit>();
    if (widget.collection != null) {
      cubit.updateCollection(collection, widget.collection!.id!);
    } else {
      cubit.createCollection(collection);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isUpdateMode = widget.collection != null;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(isUpdateMode),
                  const SizedBox(height: 20),
                  _buildImagePicker(),
                  const SizedBox(height: 16),
                  _buildNameField(),
                  const SizedBox(height: 16),
                  _buildDescriptionField(),
                  const SizedBox(height: 20),
                  _buildActionButtons(isUpdateMode),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isUpdateMode) {
    return Row(
      children: [
        Icon(
          isUpdateMode ? Icons.edit : Icons.create_new_folder,
          color: Colors.blue,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          isUpdateMode ? 'Cập nhật danh mục' : 'Tạo danh mục mới',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          if (_uploadedImageUrl != null) _buildImagePreview(),
          _buildPickerButton(),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    imageUrl: _uploadedImageUrl!,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 140,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 140,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.error, size: 32),
                    ),
                  ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _removeImage,
                icon: const Icon(Icons.close, size: 15),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                style: IconButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          ),
          if (_isUploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPickerButton() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: OutlinedButton.icon(
        onPressed: _isUploading ? null : _pickImage,
        icon: _isUploading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.image_outlined, size: 20),
        label: Text(_isUploading ? 'Đang tải lên...' : 'Chọn ảnh'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Tên danh mục *',
        hintText: 'Ví dụ: Món ăn yêu thích',
        prefixIcon: const Icon(Icons.label_outline, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập tên danh mục';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: 'Mô tả',
        hintText: 'Mô tả ngắn về danh mục này',
        prefixIcon: const Icon(Icons.description_outlined, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _buildActionButtons(bool isUpdateMode) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Hủy'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isUploading ? null : _saveCollection,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(isUpdateMode ? 'Cập nhật' : 'Tạo'),
          ),
        ),
      ],
    );
  }
}