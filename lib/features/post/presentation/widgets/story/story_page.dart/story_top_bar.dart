import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/core/utils/convert_time.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:eefood/features/post/data/models/story_model.dart';
import 'package:eefood/features/post/data/models/user_story_model.dart';
import 'package:flutter/material.dart';

import '../../../../../../app_routes.dart';
import '../../../../../../core/di/injection.dart';
import '../../../../../profile/domain/repositories/profile_repository.dart';

class StoryTopBar extends StatelessWidget {
  final UserStoryModel user;
  final StoryModel story;
  final VoidCallback onMorePressed;

  const StoryTopBar({
    super.key,
    required this.user,
    required this.story,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = story.createdAt != null
        ? TimeParser.formatCommentTime(story.createdAt)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: CachedNetworkImageProvider(user.avatarUrl ?? ""),
          ),
          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  User? userStory = await getIt<ProfileRepository>().getUserById(user.userId);
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.personalUser,
                    arguments: {'user': userStory},
                  );
                },
                child: Text(
                  user.username ?? "",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 0),
                        blurRadius: 3,
                        color: Colors.black.withOpacity(
                          0.8,
                        ), // Viền mờ giúp nổi bật
                      ),
                    ],
                  ),
                ),
              ),
              if (createdAt != null)
                Text(
                  createdAt,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 0),
                        blurRadius: 3,
                        color: Colors.black.withOpacity(
                          0.8,
                        ), // Viền mờ giúp nổi bật
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const Spacer(),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.more_horiz_rounded,
                  shadows: [
                    Shadow(blurRadius: 4, color: Colors.black.withOpacity(0.7)),
                  ],
                ),
                onPressed: onMorePressed,
                color: Colors.white,
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  shadows: [
                    Shadow(blurRadius: 4, color: Colors.black.withOpacity(0.7)),
                  ],
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
