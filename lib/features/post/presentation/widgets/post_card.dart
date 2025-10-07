import 'package:eefood/core/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import 'reaction_popup.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  const PostCard({super.key, required this.post, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 1.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(post: post),
          GestureDetector(
            onTap: onTap,
            child: Image.network(
              post.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
              errorBuilder: (_, __, ___) => Container(
                height: 200,
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, size: 50),
              ),
            ),
          ),
          _PostContent(post: post),
          _PostFooter(post: post),
        ],
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  final PostModel post;
  const _PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserAvatar(username: 'loc', isLocal: false, url: 'https://jbagy.me/wp-content/uploads/2025/03/hinh-anh-cute-avatar-vo-tri-3.jpg',),
      title: const Text(
        'Emily Jane',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text('3h ago'),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz),
        onPressed: () {},
      ),
    );
  }
}

class _PostContent extends StatelessWidget {
  final PostModel post;
  const _PostContent({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.title,
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(post.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 6)
        ],
      ),
    );
  }
}

class _PostFooter extends StatefulWidget {
  final PostModel post;
  const _PostFooter({required this.post});

  @override
  State<_PostFooter> createState() => _PostFooterState();
}

class _PostFooterState extends State<_PostFooter> {
  bool _showReactions = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_showReactions)
          ReactionPopup(
            onSelect: (emoji) {
              debugPrint('Selected reaction: $emoji');
              setState(() => _showReactions = false);
            },
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onLongPress: () => setState(() => _showReactions = true),
                onTap: () => debugPrint("Like post ${widget.post.id}"),
                child: const _FooterButton(
                    icon: Icons.thumb_up_alt_outlined, label: 'Like'),
              ),
              const _FooterButton(
                  icon: Icons.comment_outlined, label: 'Comment'),
              const _FooterButton(icon: Icons.share_outlined, label: 'Share'),
            ],
          ),
        ),
      ],
    );
  }
}

class _FooterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FooterButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 20, color: Colors.grey.shade700),
      label: Text(
        label,
        style: TextStyle(color: Colors.grey.shade700),
      ),
    );
  }
}
