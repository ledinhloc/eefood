import 'package:eefood/features/post/data/models/story_setting_model.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_settings/story_mode_helper.dart';
import 'package:flutter/material.dart';

class StorySettingOptionTile extends StatefulWidget {
  final StoryMode mode;
  final bool isSelected;
  final int? selectedCount;
  final bool needsUserSelection;
  final VoidCallback onTap;
  final VoidCallback? onSelectUsers;

  const StorySettingOptionTile({
    super.key,
    required this.mode,
    required this.isSelected,
    required this.selectedCount,
    required this.needsUserSelection,
    required this.onTap,
    this.onSelectUsers,
  });

  @override
  State<StorySettingOptionTile> createState() => _StorySettingOptionTileState();
}

class _StorySettingOptionTileState extends State<StorySettingOptionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  bool _wasSelected = false;

  @override
  void initState() {
    super.initState();
    _wasSelected = widget.isSelected;

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );

    // Set initial state
    if (widget.isSelected && widget.needsUserSelection) {
      _expandController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(StorySettingOptionTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only animate if selection actually changed
    if (oldWidget.isSelected != widget.isSelected) {
      _wasSelected = widget.isSelected;

      if (widget.isSelected && widget.needsUserSelection) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.isSelected ? Colors.blue : Colors.grey[300]!,
          width: widget.isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: widget.isSelected ? Colors.blue.withOpacity(0.05) : Colors.white,
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Radio<StoryMode>(
                    value: widget.mode,
                    groupValue: widget.isSelected ? widget.mode : null,
                    onChanged: (_) => widget.onTap(),
                    activeColor: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          StoryModeHelpers.getTitle(widget.mode),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          StoryModeHelpers.getDescription(widget.mode),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.needsUserSelection && widget.isSelected)
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),

              if (widget.needsUserSelection)
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  axisAlignment: -1.0,
                  child: widget.isSelected
                      ? _buildUserSelectorSection()
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserSelectorSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: InkWell(
        onTap: widget.onSelectUsers,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.selectedCount != null && widget.selectedCount! > 0
                    ? 'Đã chọn ${widget.selectedCount} người'
                    : 'Chọn người dùng',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(Icons.person_add, color: Colors.blue, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
