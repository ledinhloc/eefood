
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
  //
}