import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../provider/collection_cubit.dart';
import '../../../../../core/widgets/custom_bottom_sheet.dart';
import '../../../data/models/collection_model.dart';

class CollectionMoreButton extends StatelessWidget {
  final CollectionModel collection;
  final Color iconColor;

  const CollectionMoreButton({
    super.key,
    required this.collection,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CollectionCubit>();

    return IconButton(
      icon: Icon(Icons.more_vert, color: iconColor),
      onPressed: () {
        showCustomBottomSheet(context, [
          BottomSheetOption(
            icon: const Icon(Icons.edit, color: Colors.blue),
            title: 'Đổi tên bộ sưu tập',
            onTap: () => _showRenameDialog(context, cubit),
          ),
          BottomSheetOption(
            icon: const Icon(Icons.delete, color: Colors.red),
            title: 'Xóa bộ sưu tập',
            onTap: () async {
              Navigator.pop(context);
              await cubit.deleteCollection(collection.id);
            },
          ),
        ]);
      },
    );
  }

  void _showRenameDialog(BuildContext context, CollectionCubit cubit) {
    final controller = TextEditingController(text: collection.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sửa tên bộ sưu tập'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nhập tên mới'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await cubit.updateCollection(collection.id, name: controller.text);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
