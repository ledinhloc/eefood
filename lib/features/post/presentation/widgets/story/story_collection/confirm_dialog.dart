import 'package:flutter/material.dart';

class CollectionDialogs {
  static Future<bool?> _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? subtitle,
    required String confirmText,
    required Color confirmColor,
    String cancelText = 'Hủy',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: subtitle != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(content),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              )
            : Text(content),
        actions: [
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelText),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  confirmText,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<bool?> showDeleteDialog(
    BuildContext context,
    String collectionName,
  ) {
    return _showConfirmDialog(
      context: context,
      title: 'Xác nhận xóa danh mục',
      content: 'Bạn có chắc chắn muốn xóa danh mục "$collectionName"?',
      subtitle: 'Tất cả story trong danh mục này sẽ bị xóa khỏi danh mục.',
      confirmText: 'Xóa danh mục',
      confirmColor: Colors.red,
    );
  }

  static Future<bool?> showAddStoryDialog(
    BuildContext context,
    String collectionName,
  ) {
    return _showConfirmDialog(
      context: context,
      title: 'Xác nhận thêm',
      content: 'Bạn có muốn thêm story này vào "$collectionName"?',
      confirmText: 'Thêm',
      confirmColor: Colors.blue,
    );
  }

  static Future<bool?> showRemoveStoryDialog(
    BuildContext context,
    String collectionName,
  ) {
    return _showConfirmDialog(
      context: context,
      title: 'Xác nhận xóa',
      content: 'Bạn có muốn xóa story này khỏi "$collectionName"?',
      confirmText: 'Xóa',
      confirmColor: Colors.red,
    );
  }
}
