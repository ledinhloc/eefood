
import 'package:json_annotation/json_annotation.dart';
part 'block_user_response.g.dart';
@JsonSerializable()
class BlockUserResponse{
  final int blockedUserId;
  final String createdAt;
  final String? username;
  final String? avatarUrl;
  final String? email;
  BlockUserResponse({
    required this.blockedUserId,
    required this.createdAt,
    this.username,
    this.avatarUrl,
    this.email
});
  factory BlockUserResponse.fromJson(Map<String, dynamic> json)
    => _$BlockUserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BlockUserResponseToJson(this);
}