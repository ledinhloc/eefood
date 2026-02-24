import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StreamEndedDialog extends StatelessWidget {
  final String? message;
  final VoidCallback onClose;
  const StreamEndedDialog({Key? key, this.message, required this.onClose})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange.shade50, Colors.white, Colors.red.shade50],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //Icon, Animation
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 50,
                color: Colors.deepOrange,
              ),
            ),

            const SizedBox(height: 20,),

            const Text(
              'Buổi phát sóng đã kết thúc',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12,),

            //message
            Text(
              message ?? 'Cảm ơn bạn đã theo dõi!\nHẹn gặp lại trong buổi livestream tiếp theo 🍜',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.5
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24,),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.deepOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Khám phá thêm công thức ngon tại trang chủ!',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      )
                  ),
                  child: const Text(
                      'Về trang chủ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}
