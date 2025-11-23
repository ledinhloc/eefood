import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/convert_time.dart';
import 'package:eefood/core/utils/share_utils.dart';
import 'package:eefood/features/post/presentation/provider/post_list_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/share/share_bottom_sheet.dart';
import 'package:eefood/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter/material.dart';
import '../../../../../core/widgets/user_avatar.dart';
import '../../../data/models/post_model.dart';
import '../../../../../core/widgets/custom_bottom_sheet.dart';
import '../collection/add_to_collection_sheet.dart';

class PostHeader extends StatefulWidget {
  final int userId;
  final PostModel post;

  const PostHeader({super.key, required this.userId, required this.post});

  @override
  State<PostHeader> createState() => _PostHeaderState();
}

class _PostHeaderState extends State<PostHeader> {
  final ProfileRepository repository = getIt<ProfileRepository>();
  Future<dynamic>? _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = repository.getUserById(widget.userId);
  }

  void _openShareSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareBottomSheet(
        postId: widget.post.recipeId!,
        imageUrl: widget.post.imageUrl,
        contentPreview: widget.post.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey,
            ),
            title: Container(height: 12, width: 80, color: Colors.grey[300]),
            subtitle: Container(height: 10, width: 40, color: Colors.grey[200]),
          );
        }

        if (snapshot.hasError) {
          return ListTile(
            title: const Text('Lỗi tải người dùng'),
            subtitle: Text(snapshot.error.toString()),
          );
        }

        final user = snapshot.data;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          horizontalTitleGap: 6,
          leading: UserAvatar(
            username: widget.post.username,
            isLocal: false,
            url: widget.post.avatarUrl,
          ),
          title: GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.personalUser,
                arguments: {'user': user},
              );

              if (context.mounted) {
                getIt<PostListCubit>().resetFilters();
              }
            },
            child: Text(
              widget.post.username,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          subtitle: Text(
            TimeParser.formatCommentTime(widget.post.createdAt),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.grey),
            onPressed: () async {
              await showCustomBottomSheet(context, [
                BottomSheetOption(
                  icon: const Icon(
                    Icons.visibility_off_outlined,
                    color: Colors.grey,
                  ),
                  title: 'Ẩn bài viết này',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã ẩn bài viết này')),
                    );
                  },
                ),
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
                      builder: (_) =>
                          AddToCollectionSheet(postId: widget.post.id),
                    );
                  },
                ),
                BottomSheetOption(
                  icon: const Icon(Icons.flag_outlined, color: Colors.red),
                  title: 'Báo cáo bài viết',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Báo cáo bài viết')),
                    );
                  },
                ),
                BottomSheetOption(
                  icon: const Icon(Icons.link, color: Colors.blue),
                  title: 'Sao chép liên kết món ăn',
                  onTap: () async {
                    await ShareUtils.shareToPlatform(
                      platform: 'copy',
                      postId: widget.post.id,
                      title: widget.post.title,
                      imageUrl: widget.post.imageUrl,
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
                    _openShareSheet();
                  },
                ),
              ]);
            },
          ),
        );
      },
    );
  }
}
