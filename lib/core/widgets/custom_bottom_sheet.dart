import 'package:flutter/material.dart';

/// Hàm helper mở CustomBottomSheet
void showCustomBottomSheet(
  BuildContext context,
  List<BottomSheetOption> options,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => CustomBottomSheet(options: options),
  );
}

/// Model đại diện cho một lựa chọn trong BottomSheet
class BottomSheetOption {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  BottomSheetOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

/// Widget bottom sheet có thể tái sử dụng
class CustomBottomSheet extends StatelessWidget {
  final List<BottomSheetOption> options;
  const CustomBottomSheet({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ...options.map(
              (opt) => ListTile(
                leading: Icon(opt.icon, color: Colors.black),
                title: Text(opt.title, style: const TextStyle(fontSize: 16, color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  opt.onTap();
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
