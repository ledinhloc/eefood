import 'package:eefood/features/livestream/data/model/live_stream_response.dart';
import 'package:eefood/features/livestream/domain/repository/live_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WatchLiveState{
  final bool loading;
  final LiveStreamResponse? stream;
  final String? error;
  WatchLiveState({this.loading = false, this.stream, this.error});
}

class WatchLiveCubit extends Cubit<WatchLiveState>{
  final LiveRepository repository;
  WatchLiveCubit(this.repository):super(WatchLiveState());

  Future<void> loadLive(int id) async{
    try{
      emit(WatchLiveState(loading: true));
      final res = await repository.getLiveStream(id);
      emit(WatchLiveState(stream: res));
    }catch(e){
      emit(WatchLiveState(error: e.toString()));
    }
  }
}