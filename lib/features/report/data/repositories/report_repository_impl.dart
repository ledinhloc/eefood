import 'package:dio/dio.dart';
import 'package:eefood/features/report/domain/repositories/report_repository.dart';
import 'package:flutter/widgets.dart';

class ReportRepositoryImpl extends ReportRepository {
  final Dio dio;
  ReportRepositoryImpl({required this.dio});

  @override
  Future<void> createReport(
    int reporterId,
    String targetType,
    String reason,
    int targetId,
    String imageUrl,
  ) async {
    debugPrint('Hinh anh: ${imageUrl}');
    final response = await dio.post(
      '/v1/reports',
      data: {
        'reporterId': reporterId,
        'targetType': targetType,
        'reason': reason,
        'targetId': targetId,
        'imageUrl': imageUrl
      },
    );

    if (response.statusCode != 200) {
      debugPrint('Failed to create report');
      throw new Exception('Failed to create report');
    }
  }
}
