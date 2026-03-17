import 'package:flutter/material.dart';

class ChoiceCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
  final Color textColor;
  final Color subtitleColor;
  final bool isDark;
  final VoidCallback onTap;
  const ChoiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    required this.textColor,
    required this.subtitleColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<ChoiceCard> createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<ChoiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withOpacity(0.07)
                  : Colors.black.withOpacity(0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(widget.icon, color: widget.accentColor, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: widget.subtitleColor,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: widget.accentColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
