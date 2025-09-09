abstract class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordSuccess extends ForgotPasswordState {
  final bool result;
  ForgotPasswordSuccess(this.result);
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String error;
  ForgotPasswordFailure(this.error);
}