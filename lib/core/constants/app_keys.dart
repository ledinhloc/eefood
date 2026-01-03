
/*
  Chứa các key cần dùng trong app
 */
import 'package:eefood/core/utils/helpers.dart';

class AppKeys{
  //SharedPreferences
  static const isLoginedIn = 'isLoggedIn';
  static const saveEmail = 'saveEmail';
  static const savePass = 'savePass';
  static const accessToken = 'accessToken';
  static const refreshToken = 'refreshToken';
  static const fcmToken = 'fcmToken';
  static const user = 'user';
  static const baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://192.168.1.16:8222');
  static final livekitUrl = getLiveKitWsUrl(baseUrl, wsPort: 7880);
  static const webDeloyUrl = "https://eefoodpreviewapp.vercel.app";
  static const hostDeloy = "eefoodpreviewapp.vercel.app";
  static const recentKey = 'recent_search_keywords';
  static const webClientId = String.fromEnvironment('WEB_CLIENT_ID');
  //
}