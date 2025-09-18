import 'package:flutter_bloc/flutter_bloc.dart';

class OnBoardingCubit extends Cubit<int>{
  final int totalPages;

  OnBoardingCubit({this.totalPages = 3}) : super(1);

  void nextPage() {
    if (state < totalPages) {
      emit(state + 1);
    }
  }

  void previousPage() {
    if (state > 1) {
      emit(state - 1);
    }
  }

  void reset() => emit(1);
}