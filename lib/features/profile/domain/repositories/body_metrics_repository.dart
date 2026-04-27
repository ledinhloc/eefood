import 'package:eefood/features/profile/data/models/user_height_request.dart';
import 'package:eefood/features/profile/data/models/user_height_response.dart';
import 'package:eefood/features/profile/data/models/user_weight_request.dart';
import 'package:eefood/features/profile/data/models/user_weight_response.dart';

abstract class BodyMetricsRepository {
  Future<List<UserHeightResponse>> getMyHeights();

  Future<UserHeightResponse> createMyHeight(UserHeightRequest request);

  Future<UserHeightResponse> updateMyHeight(
    int heightId,
    UserHeightRequest request,
  );

  Future<void> deleteMyHeight(int heightId);

  Future<List<UserWeightResponse>> getMyWeights();

  Future<UserWeightResponse> createMyWeight(UserWeightRequest request);

  Future<UserWeightResponse> updateMyWeight(
    int weightId,
    UserWeightRequest request,
  );

  Future<void> deleteMyWeight(int weightId);
}
