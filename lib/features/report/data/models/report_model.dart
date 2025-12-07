class ReportModel {
  final int? id;
  final int reporterId;
  final String targetType;
  final String reason;
  final String status;
  final int targetId;
  final DateTime? createdAt;

  ReportModel({
    this.id,
    required this.reporterId,
    required this.targetType,
    required this.reason,
    required this.status,
    required this.targetId,
    this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, String> json) {
    return ReportModel(
      reporterId: json['reporterId'] as int,
      targetType: json['targetType'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String,
      targetId: json['targetId'] as int,
    );
  }
}
