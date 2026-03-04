import 'package:eefood/core/database/isar_service.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:isar/isar.dart';

abstract class BaseLocalDataSource {
  final IsarService _isarService = getIt<IsarService>();

  Isar get isar => _isarService.db;
}
