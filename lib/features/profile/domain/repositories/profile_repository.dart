import 'package:eefood/features/auth/data/models/UserModel.dart';

import '../../../auth/data/models/result_model.dart';
import '../../../auth/domain/entities/user.dart';

abstract class ProfileRepository{
  Future<Result<User>> updateUser(UserModel userModel);

}