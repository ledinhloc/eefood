import 'package:eefood/core/constants/app_constants.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:flutter/material.dart';

class AboutTab extends StatefulWidget {
  final User user;
  const AboutTab({super.key, required this.user});

  @override
  State<AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends State<AboutTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle(
                  'Thông tin cá nhân',
                  Icons.person_outline,
                  theme,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.cake_outlined,
                  'Ngày sinh',
                  _formatDate(widget.user.dob),
                  theme,
                ),
                _buildDivider(),
                _buildInfoRow(
                  Icons.wc_outlined,
                  'Giới tính',
                  widget.user.gender ?? 'Khác',
                  theme,
                ),
                _buildDivider(),
                _buildInfoRow(
                  Icons.email_outlined,
                  'Email',
                  widget.user.email,
                  theme,
                ),
                _buildDivider(),
                _buildInfoRow(
                  Icons.location_on_outlined,
                  'Địa chỉ',
                  _formatAddress(widget.user.address),
                  theme,
                  maxLines: 2,
                ),

                const SizedBox(height: 32),
                if (widget.user.allergies?.isNotEmpty ?? false) ...[
                  _buildSectionTitle(
                    'Dị ứng',
                    Icons.warning_amber_rounded,
                    theme,
                  ),
                  const SizedBox(height: 16),
                  _buildTagList(
                    widget.user.allergies!,
                    Colors.red.shade50,
                    Colors.red,
                    'allergies',
                  ),
                  const SizedBox(height: 32),
                ],
                if (widget.user.eatingPreferences?.isNotEmpty ?? false) ...[
                  _buildSectionTitle(
                    'Danh sách yêu thích',
                    Icons.restaurant_menu,
                    theme,
                  ),
                  const SizedBox(height: 16),
                  _buildTagList(
                    widget.user.eatingPreferences!,
                    const Color(0xFFFFE5D3),
                    const Color(0xFFE67E22),
                    'cuisines',
                  ),
                  const SizedBox(height: 32),
                ],
                if (widget.user.dietaryPreferences?.isNotEmpty ?? false) ...[
                  _buildSectionTitle(
                    'Chế độ ăn yêu thích',
                    Icons.eco_outlined,
                    theme,
                  ),
                  const SizedBox(height: 16),
                  _buildTagList(
                    widget.user.dietaryPreferences!,
                    Colors.green.shade50,
                    Colors.green,
                    'diets',
                  ),
                  const SizedBox(height: 32),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xFFE67E22)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurface),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.shade200, height: 1, thickness: 1);
  }

  Widget _buildTagList(
    List<String> items,
    Color bgColor,
    Color textColor,
    String label,
  ) {
    final allIcons = [
      ...AppConstants.allergies,
      ...AppConstants.diets,
      ...AppConstants.cuisines,
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        // Tìm icon tương ứng
        final matched = allIcons.firstWhere(
          (e) =>
              item.toLowerCase().contains(e['name'].toString().toLowerCase()),
          orElse: () => {},
        );

        final icon =
            (matched['icon'] != null && matched['icon'].toString().isNotEmpty)
            ? matched['icon'].toString()
            : _getFallbackIcon(label);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: textColor.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                item,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'Not specified';
    try {
      final parsedDate = DateTime.parse(date);
      return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }

  String _formatAddress(dynamic address) {
    if (address == null) return 'Không có';
    final parts = <String>[];
    if (address.street != null) parts.add(address.street);
    if (address.city != null) parts.add(address.city);
    return parts.isEmpty ? 'Không có' : parts.join(', ');
  }

  String _getFallbackIcon(String label) {
    switch (label) {
      case 'allergies':
        return '☢️';
      case 'cuisines':
        return '🍱';
      case 'diets':
        return '🥗';
      default:
        return '🍽️';
    }
  }
}
