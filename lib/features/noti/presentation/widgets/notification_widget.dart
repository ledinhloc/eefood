import 'package:eefood/core/utils/convert_time.dart';
import 'package:eefood/features/noti/data/models/notification_model.dart';
import 'package:eefood/features/noti/data/models/notification_type.dart';
import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationItem({super.key, required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isSystem = notification.type == "SYSTEM";
    final bool isRead = notification.isRead ?? true;
    final bool hasPostImage = notification.postImageUrl?.isNotEmpty ?? false;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : Colors.blue.shade50,
          border: Border(
            bottom: BorderSide(color: Color(0xFFEAEAEA), width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar / Icon
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: isSystem
                      ? Colors.blue.shade50
                      : Colors.grey.shade200,
                  backgroundImage:
                      !isSystem && (notification.avatarUrl?.isNotEmpty ?? false)
                      ? NetworkImage(notification.avatarUrl!)
                      : null,
                  child: isSystem
                      ? const Icon(
                          Icons.notifications_active,
                          color: Colors.blue,
                        )
                      : (notification.avatarUrl?.isEmpty ?? true)
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: NotificationType.getColor(
                        notification.type,
                        body: notification.body,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      NotificationType.getIcon(
                        notification.type,
                        body: notification.body,
                      ),
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            // Nội dung chính
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề + NEW tag
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Nội dung
                  Text(
                    notification.body ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Thời gian
                  Text(
                    TimeParser.formatTime(
                      notification.createdAt ?? DateTime.now(),
                    ),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Ảnh bài viết (nếu có)
            if (hasPostImage)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    notification.postImageUrl!,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 52,
                      height: 52,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
