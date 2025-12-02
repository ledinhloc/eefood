class SimpleTokenResponse {
  final String accessToken;
  final String refreshToken;

  SimpleTokenResponse({required this.accessToken, required this.refreshToken});

  factory SimpleTokenResponse.fromJson(Map<String, dynamic> json){
    return SimpleTokenResponse(
        accessToken: json['accessToken'],
        refreshToken: json['refreshToken']);
  }

  Map<String, dynamic> toJson(){
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken
    };
  }
}
