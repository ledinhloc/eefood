import 'package:flutter/material.dart';

class SubmitSection extends StatelessWidget {
  final bool isAllAnswered;
  final bool isSubmitting;
  final int answeredCount;
  final int totalCount;
  final VoidCallback onSubmit;
  const SubmitSection({
    super.key,
    required this.isAllAnswered,
    required this.isSubmitting,
    required this.answeredCount,
    required this.totalCount,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isAllAnswered && totalCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Còn ${totalCount - answeredCount} câu chưa trả lời',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: (isAllAnswered && !isSubmitting) ? onSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                disabledBackgroundColor: const Color(0xFF2A2A2A),
                foregroundColor: Colors.white,
                disabledForegroundColor: const Color(0xFF555555),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: isAllAnswered ? 4 : 0,
                shadowColor: const Color(0xFFFF6B35).withOpacity(0.4),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Gửi đánh giá',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
