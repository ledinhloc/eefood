import '../entities/user.dart';
import '../repositories/auth_repository.dart';
/*
  Use case auth
*/

/* use case: Login*/
class Login {
  final AuthRepository repository;
  Login(this.repository);
  /* gọi object như mot ham */
  Future<User> call(String email, String password) => repository.login(email, password);
}

class Logout {
  final AuthRepository repository;
  Logout(this.repository);
  Future<void> call() => repository.logout();
}

class GetCurrentUser {
  final AuthRepository repository;
  GetCurrentUser(this.repository);
  Future<User?> call() => repository.getCurrentUser();
}

class RefreshToken {
  final AuthRepository repository;
  RefreshToken(this.repository);
  Future<void> call() => repository.refreshToken();
}

class GetProfile {
  final AuthRepository repository;
  GetProfile(this.repository);
  Future<User> call() => repository.getProfile();
}