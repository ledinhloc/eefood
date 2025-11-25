import 'package:eefood/features/livestream/data/model/live_stream_response.dart';
import 'package:eefood/features/livestream/domain/repository/live_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserLiveStatusState {
  final bool loading;
  final LiveStreamResponse? stream;
  final String? error;

  UserLiveStatusState({this.loading = false, this.stream, this.error});
}

class UserLiveStatusCubit extends Cubit<UserLiveStatusState> {
  final LiveRepository repository;

  UserLiveStatusCubit(this.repository) : super(UserLiveStatusState());

  Future<void> checkUserLiveStatus(int userId) async {
    try {
      emit(UserLiveStatusState(loading: true));
      final res = await repository.checkUserStream(userId);
      print('----------- ${res.toString()}');

      // Chỉ emit nếu status là LIVE
      if (res.status == LiveStreamStatus.LIVE) {
        emit(UserLiveStatusState(stream: res));
      } else {
        emit(UserLiveStatusState());
      }
    } catch (e) {
      // Không có stream hoặc lỗi khác -> không hiển thị gì
      emit(UserLiveStatusState());
    }
  }
}