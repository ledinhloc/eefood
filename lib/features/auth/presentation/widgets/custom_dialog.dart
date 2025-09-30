import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DialogButton {
  final String text;
  final VoidCallback onPressed;
  final Color? textColor;
  final Color? backgroundColor;

  DialogButton({
    required this.text,
    required this.onPressed,
    this.textColor,
    this.backgroundColor,
  });
}

class CustomDialog extends StatelessWidget {
  final String? title;
  final String? description;
  final String? imageAsset;
  final String? imageLottie;
  final List<DialogButton> buttons; // Danh sách nút

  const CustomDialog({
    super.key,
    this.title,
    this.description,
    this.imageAsset,
    this.imageLottie,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hiển thị hình ảnh hoặc Lottie nếu có
            if (imageAsset != null)
              Image.asset(
                imageAsset!,
                height: 120,
              )
            else if (imageLottie != null)
              Lottie.asset(
                imageLottie!,
                height: 120,
              ),
            
            const SizedBox(height: 20),

            // Title
            if (title != null)
              Text(
                title!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),

            if (title != null) const SizedBox(height: 10),

            // Description
            if (description != null)
              Text(
                description!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),

            if (description != null) const SizedBox(height: 20),

            // Buttons
            Column(
              children: buttons.map((btn) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: btn.onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btn.backgroundColor ?? Colors.blue,
                      ),
                      child: Text(
                        btn.text,
                        style: TextStyle(
                          color: btn.textColor ?? Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
