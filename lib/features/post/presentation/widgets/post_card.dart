import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
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
  const PostCard({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              child: Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 220,
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  color: kNeutralLight,
                  child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ),
          PostContent(post: post),
          const Divider(height: 1, color: kNeutralGray),
          PostFooter(post: post),
        ],
      ),
    );
  }
}
