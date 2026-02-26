
import 'package:eefood/features/livestream/data/model/block_user_response.dart';

abstract class LiveBlockRepository{
  Future<List<BlockUserResponse>> getBlockedUsers();
  Future<BlockUserResponse> blockUser(int blockedUserId);
  Future<void> unblockUser(int blockedUserId);
}