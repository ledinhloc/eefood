import 'package:eefood/features/auth/data/models/register_response_model.dart';


abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final RegisterResponseModel result;
  RegisterSuccess(this.result);
}

class RegisterFailure extends RegisterState {
  final String error;
  RegisterFailure(this.error);
}
