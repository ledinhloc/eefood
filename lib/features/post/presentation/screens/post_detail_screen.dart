import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/post_repository_impl.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  PostModel? post;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    final repo = RepositoryProvider.of<PostRepositoryImpl>(context);
    final result = await repo.getPostById(widget.postId);
    setState(() {
      post = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (post == null) return const Center(child: Text("Không tìm thấy bài viết"));

    return Scaffold(
      appBar: AppBar(title: Text(post!.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(post!.imageUrl, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(post!.content, style: const TextStyle(fontSize: 16)),
            ),
            const Divider(),
            ...post!.comments.map((c) => ListTile(
              title: Text(c.content),
              subtitle: Text("User ${c.userId} • ${c.createdAt}"),
            )),
          ],
        ),
      ),
    );
  }
}
