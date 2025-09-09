import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/auth/data/models/register_response_model.dart';
import 'package:eefood/features/auth/data/models/result_model.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final Register registerUsecase;

  RegisterCubit(this.registerUsecase) : super(RegisterInitial());

  Future<void> register(String username, String email, String password) async {
    emit(RegisterLoading());
    try {
      final Result<RegisterResponseModel> result = await registerUsecase(
        username,
        email,
        password,
      );
      if (result.isSuccess) {
        emit(
          RegisterSuccess(result.data!),
        ); 
      } else {
        emit(RegisterFailure(result.error ?? 'Register failed'));
      }
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }
}
