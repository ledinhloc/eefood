import 'package:eefood/features/cook_process/presentation/widgets/flame_icon.dart';
import 'package:eefood/features/cook_process/presentation/widgets/mode_card.dart';
import 'package:flutter/material.dart';

class ModePickerScaffold extends StatelessWidget {
  final String recipeTitle;
  final ValueChanged<bool> onSelect;
  const ModePickerScaffold({
    super.key,
    required this.recipeTitle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              const FlameIcon(),
              const SizedBox(height: 24),
              Text(
                recipeTitle,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Chọn chế độ nấu ăn',
                style: TextStyle(fontSize: 16, color: Color(0xFF888888)),
              ),
              const SizedBox(height: 40),
              ModeCard(
                icon: Icons.timer_outlined,
                title: 'Tính thời gian',
                subtitle: 'Đếm ngược theo thời gian từng bước',
                color: const Color(0xFFFF6B35),
                onTap: () => onSelect(true),
              ),
              const SizedBox(height: 16),
              ModeCard(
                icon: Icons.self_improvement_rounded,
                title: 'Tự do',
                subtitle: 'Không tính giờ, làm theo nhịp của bạn',
                color: const Color(0xFF2D9CDB),
                onTap: () => onSelect(false),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
