import 'package:eefood/features/post/data/models/user_story_model.dart';
import 'package:eefood/features/post/presentation/provider/story_list_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'create_story_card.dart';
import 'story_card.dart';

class StorySection extends StatefulWidget {
  final VoidCallback onCreateStory;
  final List<UserStoryModel> userStories;
  final int currentUserId;

  const StorySection({
    super.key,
    required this.onCreateStory,
    required this.userStories,
    required this.currentUserId,
  });

  @override
  State<StorySection> createState() => _StorySectionState();
}

class _StorySectionState extends State<StorySection> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: widget.userStories.length + 1,
            itemBuilder: (context, index) {
              // Ô tạo story
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CreateStoryCard(onTap: widget.onCreateStory),
                );
              }

              final userStory = widget.userStories[index - 1];

              // story đầu tiên sẽ lấy làm thumbnail card
              final previewStory = userStory.stories.first;

              bool hasUnViewed = userStory.stories.any(
                (s) => s.isViewed == false,
              );

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context
                              .read<StoryCubit>(), // truyền cubit hiện tại
                          child: StoryViewerPage(
                            allUsers: widget.userStories,
                            userIndex: index - 1,
                            initialStoryIndex: 0,
                          ),
                        ),
                      ),
                    );
                  },
                  child: StoryCard(
                    userName: userStory.userId == widget.currentUserId
                        ? "Tin của bạn"
                        : userStory.username ?? "Người dùng",
                    imageUrl: previewStory.contentUrl ?? "",
                    avatarUrl: userStory.avatarUrl,
                    hasStory: hasUnViewed,
                  ),
                ),
              );
            },
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Divider(height: 1, thickness: 1, color: Colors.black12),
        ),
      ],
    );
  }
}
