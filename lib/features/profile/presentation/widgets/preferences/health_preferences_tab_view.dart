import 'package:eefood/core/constants/app_constants.dart';
import 'package:eefood/features/auth/domain/enum/activity_level.dart';
import 'package:flutter/material.dart';

import 'preference_chip_item.dart';

class HealthPreferencesTabView extends StatefulWidget {
  final ActivityLevel? selectedActivityLevel;
  final Set<String> selectedHealthConditions;
  final ValueChanged<ActivityLevel> onActivityLevelSelect;
  final ValueChanged<String> onHealthConditionToggle;
  final ValueChanged<String> onAddCustomHealthCondition;

  const HealthPreferencesTabView({
    super.key,
    required this.selectedActivityLevel,
    required this.selectedHealthConditions,
    required this.onActivityLevelSelect,
    required this.onHealthConditionToggle,
    required this.onAddCustomHealthCondition,
  });

  static const Color accentColor = Color(0xFF4F46E5);

  @override
  State<HealthPreferencesTabView> createState() =>
      _HealthPreferencesTabViewState();
}

class _HealthPreferencesTabViewState extends State<HealthPreferencesTabView> {
  final TextEditingController _customConditionController =
      TextEditingController();

  Set<String> get _suggestedHealthConditionNames => AppConstants
      .healthConditionsSuggestions
      .map((item) => item['name'] ?? '')
      .where((item) => item.isNotEmpty)
      .toSet();

  List<String> get _customSelectedConditions =>
      widget.selectedHealthConditions
          .where((item) => !_suggestedHealthConditionNames.contains(item))
          .toList()
        ..sort();

  void _addCustomCondition() {
    final value = _customConditionController.text.trim();
    if (value.isEmpty) {
      return;
    }

    widget.onAddCustomHealthCondition(value);
    _customConditionController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _customConditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount =
        widget.selectedHealthConditions.length +
        (widget.selectedActivityLevel != null ? 1 : 0);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  HealthPreferencesTabView.accentColor.withValues(alpha: 0.08),
                  HealthPreferencesTabView.accentColor.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: HealthPreferencesTabView.accentColor.withValues(
                          alpha: 0.15,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('💪', style: TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sức khỏe & vận động',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cập nhật mức độ hoạt động và tình trạng sức khỏe để nhận gợi ý phù hợp.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (selectedCount > 0)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: HealthPreferencesTabView.accentColor.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          size: 16,
                          color: HealthPreferencesTabView.accentColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$selectedCount đã chọn',
                          style: const TextStyle(
                            color: HealthPreferencesTabView.accentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mức độ hoạt động',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Chọn 1 mức phù hợp với nhịp sinh hoạt của bạn.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _activityLevelOptions.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.28,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final option = _activityLevelOptions[index];
                    final isSelected =
                        widget.selectedActivityLevel == option.level;

                    return _ActivityLevelCard(
                      option: option,
                      isSelected: isSelected,
                      accentColor: HealthPreferencesTabView.accentColor,
                      onTap: () => widget.onActivityLevelSelect(option.level),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tình trạng sức khỏe',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Chọn nhiều mục nếu cần điều chỉnh gợi ý món ăn.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customConditionController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addCustomCondition(),
                        decoration: InputDecoration(
                          hintText: 'Thêm tình trạng khác',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E5EA),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E5EA),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: HealthPreferencesTabView.accentColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _addCustomCondition,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HealthPreferencesTabView.accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Icon(Icons.add_rounded, size: 22),
                      ),
                    ),
                  ],
                ),
                if (_customSelectedConditions.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Đã thêm',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _customSelectedConditions.map((item) {
                      return SizedBox(
                        width: (MediaQuery.of(context).size.width - 52) / 2,
                        child: PreferenceChipItem(
                          label: item,
                          icon: '✨',
                          isSelected: true,
                          accentColor: HealthPreferencesTabView.accentColor,
                          onTap: () => widget.onHealthConditionToggle(item),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = AppConstants.healthConditionsSuggestions[index];
              final itemName = item['name'] ?? '';
              final itemIcon = item['icon'] ?? '';
              final isSelected = widget.selectedHealthConditions.contains(
                itemName,
              );

              return PreferenceChipItem(
                label: itemName,
                icon: itemIcon,
                isSelected: isSelected,
                accentColor: HealthPreferencesTabView.accentColor,
                onTap: () => widget.onHealthConditionToggle(itemName),
              );
            }, childCount: AppConstants.healthConditionsSuggestions.length),
          ),
        ),
      ],
    );
  }
}

class _ActivityLevelCard extends StatelessWidget {
  final _ActivityLevelOption option;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _ActivityLevelCard({
    required this.option,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? accentColor : const Color(0xFFE5E5EA),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 10 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(option.icon, style: const TextStyle(fontSize: 24)),
                const Spacer(),
                if (isSelected)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              option.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? accentColor : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              option.description,
              style: TextStyle(
                fontSize: 12,
                height: 1.3,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityLevelOption {
  final ActivityLevel level;
  final String title;
  final String description;
  final String icon;

  const _ActivityLevelOption({
    required this.level,
    required this.title,
    required this.description,
    required this.icon,
  });
}

const List<_ActivityLevelOption> _activityLevelOptions = [
  _ActivityLevelOption(
    level: ActivityLevel.SEDENTARY,
    title: 'Ít vận động',
    description: 'Phần lớn thời gian ngồi hoặc làm việc tĩnh.',
    icon: '🪑',
  ),
  _ActivityLevelOption(
    level: ActivityLevel.LIGHT,
    title: 'Nhẹ nhàng',
    description: 'Có đi lại, tập nhẹ hoặc hoạt động ít.',
    icon: '🚶',
  ),
  _ActivityLevelOption(
    level: ActivityLevel.MODERATE,
    title: 'Vừa phải',
    description: 'Vận động đều hoặc tập luyện vài buổi mỗi tuần.',
    icon: '🏃',
  ),
  _ActivityLevelOption(
    level: ActivityLevel.ACTIVE,
    title: 'Năng động',
    description: 'Tập luyện thường xuyên hoặc cường độ cao.',
    icon: '🔥',
  ),
];
