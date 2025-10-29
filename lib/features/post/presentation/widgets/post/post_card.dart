import 'package:flutter/material.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/reaction_type.dart';
import 'post_header.dart';
import 'post_content.dart';
import 'post_footer.dart';

// 🎨 App color palette
const kPrimaryColor = Color(0xFFFF6B35);
const kPrimaryLight = Color(0xFFF7931E);
const kSecondaryColor = Color(0xFF4CAF50);
const kAccentColor = Color(0xFFFFC107);
const kNeutralLight = Color(0xFFF5F5F5);
const kNeutralGray = Color(0xFFE0E0E0);

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final void Function(Offset offset, Function(ReactionType) onSelect)? onShowReactions;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onShowReactions,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = post.imageUrl != null && post.imageUrl.trim().isNotEmpty;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: kPrimaryColor.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostHeader(post: post),
          GestureDetector(
            onTap: onTap,
            child: Hero(
              tag: 'post_${post.id}',
              child: hasImage
                  ? Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 220,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 220,
                    color: kNeutralLight,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
              )
                  : _buildImagePlaceholder(),
            ),
          ),
          PostContent(post: post),
          const Divider(height: 1, color: kNeutralGray),
          PostFooter(post: post, onShowReactions: onShowReactions),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 220,
      width: double.infinity,
      color: kNeutralLight,
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }
}
