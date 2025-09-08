import 'package:eefood/features/auth/presentation/widgets/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;
  final String? imageAsset;
  final String? imageLottie;
  CustomDialog({
    super.key, 
    required this.title, 
    required this.description,
    required this.buttonText,
    required this.onPressed,
    this.imageAsset,
    this.imageLottie
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
            if(imageAsset != null)
              Image.asset(
                imageAsset!,
                height: 120,
              )
            else if (imageLottie != null)
              Lottie.asset(
                imageLottie!,
                height: 120
              ),
            const SizedBox(height: 20),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: AuthButton(
                text: buttonText,
                onPressed: () {
                  onPressed();
                },
                textColor: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}