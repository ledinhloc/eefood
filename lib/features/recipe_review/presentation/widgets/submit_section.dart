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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.4))),
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
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
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
                disabledBackgroundColor: Colors.grey.withOpacity(0.4),
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
                        color: Colors.orange,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Gửi đánh giá',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
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
