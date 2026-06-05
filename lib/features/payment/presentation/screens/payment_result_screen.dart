import 'package:eefood/features/payment/presentation/widgets/info_row.dart';
import 'package:flutter/material.dart';

class PaymentResultScreen extends StatelessWidget {
  final bool isSuccess;
  final String? txnRef;
  final String? amount;
  final String? responseCode;

  const PaymentResultScreen({
    super.key,
    required this.isSuccess,
    this.txnRef,
    this.amount,
    this.responseCode,
  });

  String get _formattedAmount {
    if (amount == null) return '';
    try {
      final raw = int.parse(amount!) ~/ 100;
      // Format kiểu 50,000 VNĐ
      final formatted = raw.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
      return '$formatted VNĐ';
    } catch (_) {
      return '$amount VNĐ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).padding;
    final availableHeight = screenHeight - padding.top - padding.bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBackToRecharge(context);
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: availableHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSuccess
                            ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                            : const Color(0xFFFF5252).withValues(alpha: 0.15),
                      ),
                      child: Icon(
                        isSuccess ? Icons.check_circle : Icons.cancel,
                        size: 60,
                        color: isSuccess
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFFF5252),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Title
                    Text(
                      isSuccess
                          ? 'Thanh toán thành công!'
                          : 'Thanh toán thất bại',
                      style: TextStyle(
                        color: isSuccess
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFFF5252),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      isSuccess
                          ? 'Kim cương đã được cộng vào tài khoản của bạn'
                          : 'Giao dịch không thành công. Vui lòng thử lại.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Transaction info
                    if (isSuccess && amount != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(
                              0xFF7C6AFF,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            InfoRow(label: 'Số tiền', value: _formattedAmount),
                            if (txnRef != null) ...[
                              const Divider(
                                color: Color(0xFF2A2A3E),
                                height: 24,
                              ),
                              InfoRow(
                                label: 'Mã giao dịch',
                                value: txnRef!,
                                isSmall: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                    const SizedBox(height: 40),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _goBackToRecharge(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C6AFF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Quay về trang nạp kim cương',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goBackToRecharge(BuildContext context) {
    // Pop tất cả về RechargeScreen
    Navigator.of(context).popUntil((route) {
      return route.settings.name == '/recharge' || route.isFirst;
    });
  }
}
