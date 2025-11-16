
/*
  Chứa các key cần dùng trong app
 */
class AppKeys{
  //SharedPreferences
  static const isLoginedIn = 'isLoggedIn';
  static const accessToken = 'accessToken';
  static const refreshToken = 'refreshToken';
  static const user = 'user';
  static const baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://192.168.1.16:8222');
  static const webDeloyUrl = "https://eefood-preview-card.vercel.app";
  static const hostDeloy = "eefood-preview-card.vercel.app";
  static const recentKey = 'recent_search_keywords';
  static const webClientId = String.fromEnvironment('WEB_CLIENT_ID');
  //
}