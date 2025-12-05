import 'dart:io';
import 'package:flutter/material.dart';
import 'collection_image_preview.dart';

class CollectionFormFields extends StatelessWidget {
  final bool isUpdate;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final bool isUploading;
  final String? uploadedImageUrl;
  final File? selectedImage;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onSave;

  const CollectionFormFields({
    super.key,
    required this.isUpdate,
    required this.nameController,
    required this.descriptionController,
    required this.isUploading,
    required this.uploadedImageUrl,
    required this.selectedImage,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              isUpdate ? Icons.edit : Icons.create_new_folder,
              color: Colors.blue,
            ),
            const SizedBox(width: 12),
            Text(
              isUpdate ? 'Cập nhật danh mục' : 'Tạo danh mục mới',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Name
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Tên danh mục *',
            hintText: 'Ví dụ: Món ăn yêu thích',
            prefixIcon: const Icon(Icons.label_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) => value != null && value.trim().isNotEmpty
              ? null
              : 'Vui lòng nhập tên danh mục',
        ),
        const SizedBox(height: 16),

        // Image
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (uploadedImageUrl != null)
                CollectionImagePreview(
                  selectedImage: selectedImage,
                  uploadedImageUrl: uploadedImageUrl!,
                  isUploading: isUploading,
                  onRemoveImage: onRemoveImage,
                ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: OutlinedButton.icon(
                  onPressed: isUploading ? null : onPickImage,
                  icon: isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.image_outlined),
                  label: Text(isUploading ? 'Đang tải lên...' : 'Chọn ảnh'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Description
        TextFormField(
          controller: descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Mô tả',
            hintText: 'Mô tả ngắn về danh mục này',
            prefixIcon: const Icon(Icons.description_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),

        // Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
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
                onPressed: isUploading ? null : onSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(isUpdate ? 'Cập nhật' : 'Tạo'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
