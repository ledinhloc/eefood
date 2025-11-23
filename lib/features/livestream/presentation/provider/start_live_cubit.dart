import 'package:eefood/features/livestream/data/model/live_stream_response.dart';
import 'package:eefood/features/livestream/domain/repository/live_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StartLiveState{
  final bool loading;
  final LiveStreamResponse? stream;
  final String? error;

  StartLiveState({this.loading = false, this.stream, this.error});
}

class StartLiveCubit extends Cubit<StartLiveState>{
  final LiveRepository repository;
  StartLiveCubit(this.repository) : super(StartLiveState());

  Future<void> startLive(String description) async{
    try{
      emit(StartLiveState(loading: true));
      final res = await repository.startLiveStream(description);
      emit(StartLiveState(stream: res));
    }catch(e){
      emit(StartLiveState(error: e.toString()));
    }
  }

  Future<void> endLive(int id) async{
    try{
      await repository.endLiveStream(id);
    }catch(_){}
  }
}