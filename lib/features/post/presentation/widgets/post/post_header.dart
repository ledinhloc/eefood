import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/convert_time.dart';
import 'package:eefood/core/utils/share_utils.dart';
import 'package:eefood/features/post/presentation/provider/post_list_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/share/share_bottom_sheet.dart';
import 'package:eefood/features/report/presentation/widgets/report_bottom_sheet.dart';
import 'package:flutter/material.dart';

import '../../../../../core/widgets/custom_bottom_sheet.dart';
import '../../../../../core/widgets/user_avatar.dart';
import '../../../../auth/domain/entities/user.dart';
import '../../../../profile/domain/usecases/profile_usecase.dart';
import '../../../data/models/post_model.dart';
import '../collection/add_to_collection_sheet.dart';

class PostHeader extends StatelessWidget {
  final int userId;
  final PostModel post;
  const PostHeader({super.key, required this.userId, required this.post});

  void _openShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareBottomSheet(
        post: post,
        imageUrl: post.imageUrl,
        contentPreview: post.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      horizontalTitleGap: 6,
      leading: UserAvatar(
        username: post.username,
        isLocal: false,
        url: post.avatarUrl,
      ),
      title: GestureDetector(
        onTap: () async {
          User? userStory = await getIt<GetUserById>().call(userId);
          await Navigator.pushNamed(
            context,
            AppRoutes.personalUser,
            arguments: {'user': userStory},
          );

          if (context.mounted) {
            getIt<PostListCubit>().resetFilters();
          }
        },
        child: Text(
          post.username,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
      subtitle: Text(
        TimeParser.formatCommentTime(post.createdAt),
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz, color: Colors.grey),
        onPressed: () async {
          await showCustomBottomSheet(context, [
            BottomSheetOption(
              icon: const Icon(Icons.bookmark_add, color: Colors.blue),
              title: 'Lưu vào bộ sưu tập',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (_) => AddToCollectionSheet(postId: post.id),
                );
              },
            ),
            BottomSheetOption(
              icon: const Icon(Icons.flag_outlined, color: Colors.red),
              title: 'Báo cáo bài viết',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => ReportBottomSheet(
                    targerId: post.id,
                    targetTitle: post.title,
                    type: 'POST',
                  ),
                );
              },
            ),
            BottomSheetOption(
              icon: const Icon(Icons.link, color: Colors.blue),
              title: 'Sao chép liên kết món ăn',
              onTap: () async {
                await ShareUtils.shareToPlatform(
                  platform: 'copy',
                  recipeId: post.recipeId,
                  title: post.title,
                  imageUrl: post.imageUrl,
                  desc: 'Xem thêm ở đây',
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã sao chép thành công')),
                );
              },
            ),
            BottomSheetOption(
              icon: const Icon(Icons.share_outlined, color: Colors.green),
              title: 'Chia sẻ bài viết',
              onTap: () {
                _openShareSheet(context);
              },
            ),
          ]);
        },
      ),
    );
  }
}
