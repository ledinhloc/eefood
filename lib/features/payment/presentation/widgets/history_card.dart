import 'package:eefood/features/payment/data/model/wallet_history_response.dart';
import 'package:eefood/features/payment/presentation/widgets/type_badge.dart';
import 'package:flutter/material.dart';

class HistoryCard extends StatelessWidget {
  final WalletHistoryResponse item;
  const HistoryCard({super.key, required this.item});

  static const _cfg = {
    'TOPUP': (
      label: 'Nạp kim cương',
      icon: Icons.add_circle_rounded,
      bg: Color(0xFFE8F5E9),
      iconColor: Color(0xFF2E7D32),
      amountColor: Color(0xFF2E7D32),
      prefix: '+',
    ),
    'SPEND': (
      label: 'Sử dụng kim cương',
      icon: Icons.diamond_rounded,
      bg: Color(0xFFFFF3E0),
      iconColor: Color(0xFFE65100),
      amountColor: Color(0xFFE65100),
      prefix: '-',
    ),
    'REFUND': (
      label: 'Hoàn trả kim cương',
      icon: Icons.refresh_rounded,
      bg: Color(0xFFE3F2FD),
      iconColor: Color(0xFF1565C0),
      amountColor: Color(0xFF1565C0),
      prefix: '+',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final type = item.type ?? 'SPEND';
    final cfg =
        _cfg[type] ??
        (
          label: type,
          icon: Icons.help_outline,
          bg: const Color(0xFFF5F5F5),
          iconColor: Colors.grey,
          amountColor: Colors.grey,
          prefix: '',
        );

    final amount = item.amount ?? 0;
    final balance = item.balanceAfter ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // --- Icon ---
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cfg.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(cfg.icon, color: cfg.iconColor, size: 22),
          ),
          const SizedBox(width: 12),

          // --- Info ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cfg.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.diamond_outlined,
                      size: 11,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Số dư: $balance',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (item.transactionId != null) ...[
                      Text(
                        ' · ',
                        style: TextStyle(color: Colors.grey.shade300),
                      ),
                      Text(
                        '#${item.transactionId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ],
                ),
                if (item.createdAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(item.createdAt!),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ],
            ),
          ),

          // --- Amount ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.diamond_rounded, size: 13, color: cfg.amountColor),
                  const SizedBox(width: 3),
                  Text(
                    '${cfg.prefix}$amount',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cfg.amountColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              TypeBadge(type: type, cfg: cfg),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')} '
        '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}
