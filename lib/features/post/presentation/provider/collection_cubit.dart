import 'package:eefood/core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/collection_repository.dart';
import 'collection_state.dart';

class CollectionCubit extends Cubit<CollectionState> {
  final CollectionRepository repository = getIt<CollectionRepository>();

  CollectionCubit() : super(CollectionState());

  Future<void> fetchCollectionsByUser() async {
    emit(state.copyWith(status: CollectionStatus.loading));
    try {
      final collections = await repository.getCollectionsByUser();
      emit(state.copyWith(
        status: CollectionStatus.success,
        collections: collections,
      ));
    } catch (e) {
      emit(state.copyWith(status: CollectionStatus.failure, error: e.toString()));
    }
  }

  Future<void> fetchCollectionDetail(int id) async {
    emit(state.copyWith(status: CollectionStatus.loading));
    try {
      final collection = await repository.getCollectionById(id);
      emit(state.copyWith(
        status: CollectionStatus.success,
        selectedCollection: collection,
      ));
    } catch (e) {
      emit(state.copyWith(status: CollectionStatus.failure, error: e.toString()));
    }
  }
}
