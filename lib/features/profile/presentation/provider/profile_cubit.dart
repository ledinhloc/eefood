import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user.dart';

class ProfileCubit extends Cubit<User?> {
  final GetCurrentUser getCurrentUser;
  ProfileCubit(this.getCurrentUser) : super(null);

  Future<void> loadProfile() async {
    final user = await getCurrentUser();
    emit(user);
  }
}
