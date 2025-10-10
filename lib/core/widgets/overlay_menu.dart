import 'package:flutter/material.dart';
class OverlayMenuItem {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const OverlayMenuItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
}

class MenuOverlay extends StatelessWidget {
  final List<OverlayMenuItem> items;

  const MenuOverlay({
    super.key,
    required this.items,
  });

  /// Tạo OverlayEntry với danh sách menu item
  OverlayEntry buildOverlayEntry({
    required BuildContext context,
    required LayerLink layerLink,
    Offset offset = const Offset(-140, 40),
    double width = 180,
  }) {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: kToolbarHeight + MediaQuery.of(context).padding.top,
        right: 10,
        width: width,
        child: CompositedTransformFollower(
          link: layerLink,
          offset: offset,
          showWhenUnlinked: false,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: items
                  .map(
                    (item) => _buildMenuTile(
                      icon: item.icon,
                      title: item.title,
                      color: item.color,
                      onTap: item.onTap,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}