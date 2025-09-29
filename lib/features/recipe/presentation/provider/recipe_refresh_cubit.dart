import 'package:flutter_bloc/flutter_bloc.dart';

class RecipeRefreshCubit extends Cubit<int> {
  RecipeRefreshCubit() : super(0);

  void refresh() {
    emit(state + 1);
  }
}