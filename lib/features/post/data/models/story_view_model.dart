class StoryViewModel {
  final int? id;

  final int? userId;
  final String? username;
  final String? email;
  final String? avatarUrl;

  StoryViewModel({
    this.id,
    this.userId,
    this.username,
    this.email,
    this.avatarUrl,
  });

  factory StoryViewModel.fromJson(Map<String, dynamic> json) => StoryViewModel(
    id: json['id'],
    userId: json['userId'],
    username: json['username'],
    email: json['email'],
    avatarUrl: json['avatarUrl'],
  );
}

class StoryViewPage {
  final int totalElements;
  final int numberOfElements;
  final List<StoryViewModel> viewers;

  StoryViewPage({
    required this.totalElements,
    required this.numberOfElements,
    required this.viewers,
  });

  factory StoryViewPage.fromJson(Map<String, dynamic> json) {
    return StoryViewPage(
      numberOfElements: json['numberOfElements'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      viewers: (json['content'] as List<dynamic>? ?? [])
          .map((e) => StoryViewModel.fromJson(e))
          .toList(),
    );
  }
}
