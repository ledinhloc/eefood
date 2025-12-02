import 'package:eefood/features/auth/data/models/user_model.dart';

import '../../../auth/data/models/result_model.dart';
import '../../../auth/domain/entities/user.dart';

abstract class ProfileRepository{
  Future<Result<User>> updateUser(UserModel userModel);
  Future<User?> getUserById(int userId);
}