import 'package:eefood/core/constants/app_keys.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: AppKeys.webClientId, // Web Client ID
  );

  /// Đăng nhập Google và trả về ID Token
  static Future<String?> signInWithGoogle() async {
    try {
      print("TOKEN: "+AppKeys.webClientId);

      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print("SignOut skip: $e");
      }

      // Mở Google Login
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // await signOut();
        return null;
      }; // Người dùng bấm cancel

      final GoogleSignInAuthentication auth = await googleUser.authentication;
      if(auth.idToken==null) {
        print("ID TOKEN: ${auth.idToken}");
        throw new Exception('Token không có');
      }

      // Lấy ID Token gửi lên server
      return auth.idToken;
    } catch (e) {
      print("Google Login Error: $e");
      await signOut();
      rethrow;
    }
  }

  /// Đăng xuất Google
  static Future<void> signOut() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      print("Google sign out error: $e");
    }
  }
}
