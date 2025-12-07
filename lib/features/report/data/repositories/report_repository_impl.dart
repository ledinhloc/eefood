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
  ) async {
    final response = await dio.post(
      '/v1/reports',
      data: {
        'reporterId': reporterId,
        'targetType': targetType,
        'reason': reason,
        'targetId': targetId,
      },
    );

    if (response.statusCode != 200) {
      debugPrint('Failed to create report');
      throw new Exception('Failed to create report');
    }
  }
}
