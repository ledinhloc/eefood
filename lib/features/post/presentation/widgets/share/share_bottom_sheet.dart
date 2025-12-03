import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/share_utils.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/post/data/models/share_model.dart';
import 'package:eefood/features/post/domain/repositories/share_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShareBottomSheet extends StatelessWidget {
  final ShareRepository _repository = getIt<ShareRepository>();
  final GetCurrentUser _getCurrentUser = getIt<GetCurrentUser>();
  final int postId;
  final String? imageUrl;
  final String? contentPreview;

  ShareBottomSheet({
    Key? key,
    required this.postId,
    this.imageUrl,
    this.contentPreview,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'icon': FontAwesomeIcons.facebookF,
        'label': 'Facebook',
        'platform': 'facebook',
        'color': const Color(0xFF1877F2),
      },
      {
        'icon': FontAwesomeIcons.xTwitter,
        'label': 'Twitter',
        'platform': 'twitter',
        'color': Colors.black,
      },
      {
        'icon': FontAwesomeIcons.instagram,
        'label': 'Instagram',
        'platform': 'instagram',
        'color': const Color(0xFFE4405F),
      },
      {
        'icon': FontAwesomeIcons.tiktok,
        'label': 'TikTok',
        'platform': 'tiktok',
        'color': const Color(0xFF010101),
      },
      {
        'icon': Icons.more_horiz_rounded,
        'label': 'Other',
        'platform': 'other',
        'color': const Color(0xFF0068FF),
      },
      {
        'icon': Icons.link,
        'label': 'Copy Link',
        'platform': 'copy',
        'color': Colors.grey,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              "Chia sẻ bài viết",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 12,
              children: items.map((item) {
                return GestureDetector(
                  onTap: () async {
                    final user = await _getCurrentUser();
                    await _repository.sharePost(
                      ShareModel(
                        postId: postId,
                        platform: item['platform'] as String,
                        content: contentPreview,
                        imageUrl: imageUrl,
                        userId: user?.id,
                      ),
                    );
                    await ShareUtils.shareToPlatform(
                      platform: item['platform'] as String,
                      postId: postId,
                      title: contentPreview!,
                      imageUrl: imageUrl!,
                      desc: 'Xem thêm ở đây',
                    );

                    Navigator.pop(context);

                    showCustomSnackBar(
                      context,
                      "Đã chia sẻ lên ${item['label']}",
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: (item['color'] as Color).withOpacity(
                          0.15,
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: item['color'] as Color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['label'] as String,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
