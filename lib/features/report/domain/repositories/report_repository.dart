abstract class ReportRepository {
  Future<void> createReport(
    int reporterId,
    String targetType,
    String reason,
    int targetId,
  );
}
