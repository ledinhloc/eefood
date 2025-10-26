import 'package:eefood/features/post/data/models/share_model.dart';

abstract class ShareRepository {
  Future<ShareModel?> sharePost(ShareModel share);
  Future<int> countShareByPost(int postId);
}