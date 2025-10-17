import '../../data/models/collection_model.dart';

enum CollectionStatus { initial, loading, success, failure }

class CollectionState {
  final CollectionStatus status;
  final List<CollectionModel> collections;
  final CollectionModel? selectedCollection;
  final String? error;

  CollectionState({
    this.status = CollectionStatus.initial,
    this.collections = const [],
    this.selectedCollection,
    this.error,
  });

  CollectionState copyWith({
    CollectionStatus? status,
    List<CollectionModel>? collections,
    CollectionModel? selectedCollection,
    String? error,
  }) {
    return CollectionState(
      status: status ?? this.status,
      collections: collections ?? this.collections,
      selectedCollection: selectedCollection ?? this.selectedCollection,
      error: error ?? this.error,
    );
  }
}
