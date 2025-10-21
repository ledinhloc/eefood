import 'package:eefood/core/utils/reaction_helper.dart';
import 'package:eefood/features/post/data/models/comment_reaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CommentReactItem extends StatelessWidget {
  final CommentReactionModel commentReactionModel;
  const CommentReactItem({super.key, required this.commentReactionModel});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: commentReactionModel.avatarUrl != null
                ? NetworkImage(commentReactionModel.avatarUrl!)
                : null,
            child: commentReactionModel.avatarUrl == null ? const Icon(Icons.person) : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: ReactionHelper.color(commentReactionModel.reactionType),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              padding: const EdgeInsets.all(2),
              child: Text(
                ReactionHelper.emoji(commentReactionModel.reactionType),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
      title: Text(commentReactionModel.username ?? 'Người dùng'),
    );;
  }
}