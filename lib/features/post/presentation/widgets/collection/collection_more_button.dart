import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection.dart';
import '../../provider/collection_cubit.dart';
import '../../../../../core/widgets/custom_bottom_sheet.dart';
import '../../../data/models/collection_model.dart';

class CollectionMoreButton extends StatelessWidget {
  final CollectionModel collection;
  final Color iconColor;
  final VoidCallback? onDeleted;

  const CollectionMoreButton({
    super.key,
    required this.collection,
    this.iconColor = Colors.white,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = getIt<CollectionCubit>();

    return IconButton(
      icon: Icon(Icons.more_vert, color: iconColor),
      onPressed: () async {
        await showCustomBottomSheet(context, [
          BottomSheetOption(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8C42).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Color(0xFFFF8C42),
                size: 20,
              ),
            ),
            title: 'Đổi tên bộ sưu tập',
            onTap: () => _showRenameDialog(context, cubit),
          ),
          BottomSheetOption(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE63946).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: Color(0xFFE63946),
                size: 20,
              ),
            ),
            title: 'Xóa bộ sưu tập',
            onTap: () => _handleDelete(context, cubit),
          ),
        ]);
      },
    );
  }

  Future<void> _handleDelete(BuildContext context, CollectionCubit cubit) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon cảnh báo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE63946).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Color(0xFFE63946),
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),

              // Tiêu đề
              const Text(
                'Xác nhận xóa',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 12),

              // Nội dung
              Text.rich(
                TextSpan(
                  text: 'Bạn có chắc muốn xóa bộ sưu tập\n',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: '"${collection.name}"',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE63946),
                      ),
                    ),
                    const TextSpan(text: ' không?'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(
                          color: Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                      ),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE63946),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Xóa',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      await cubit.deleteCollection(collection.id);
      if (context.mounted) {
        onDeleted?.call();
      }
    }
  }

  void _showRenameDialog(BuildContext context, CollectionCubit cubit) {
    final controller = TextEditingController(text: collection.name);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8C42).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Color(0xFFFF8C42),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Đổi tên bộ sưu tập',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // TextField
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2D3142),
                ),
                decoration: InputDecoration(
                  hintText: 'Nhập tên mới',
                  hintStyle: TextStyle(
                    color: const Color(0xFF6B7280).withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFFF8C42),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
                        side: const BorderSide(
                          color: Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                      ),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (controller.text.trim().isEmpty) {
                          showCustomSnackBar(context, "Vui lòng nhập tên bộ sưu tập!");
                          return;
                        }
                        Navigator.pop(context);
                        await cubit.updateCollection(
                          collection.id,
                          name: controller.text.trim(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8C42),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Lưu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
