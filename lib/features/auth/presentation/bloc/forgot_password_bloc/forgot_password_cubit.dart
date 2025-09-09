import 'package:eefood/features/auth/data/models/result_model.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/auth/presentation/bloc/forgot_password_bloc/forgot_password_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPassword forgotPasswordUsecase;

  ForgotPasswordCubit(this.forgotPasswordUsecase) : super(ForgotPasswordInitial());

  Future<void> forgotPassword(String email) async {
    emit(ForgotPasswordLoading());
    try {
      final Result<bool> result = await forgotPasswordUsecase(email);
      if (result.isSuccess) {
        emit(
          ForgotPasswordSuccess(result.data!),
        ); 
      } else {
        emit(ForgotPasswordFailure(result.error ?? 'Failed'));
      }
    } catch (e) {
      emit(ForgotPasswordFailure(e.toString()));
    }
  }
}
