/* use case: Login*/
import 'package:eefood/features/auth/data/models/UserModel.dart';
import 'package:eefood/features/auth/data/models/result_model.dart';
import 'package:eefood/features/profile/domain/repositories/profile_repository.dart';

import '../../../auth/domain/entities/user.dart';

class UpdateProfile {
  final ProfileRepository repository;
  UpdateProfile(this.repository);
  Future<Result<User>> call(UserModel user) => repository.updateUser(user);
}

class GetUserById {
  final ProfileRepository repository;
  GetUserById(this.repository);

  Future<User?> call(int id) {
    return repository.getUserById(id);
  }
}