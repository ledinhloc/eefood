import 'package:eefood/core/database/isar_schema.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  static Isar? _isar;

  Future<Isar> init() async {
    if (_isar != null) return _isar!;

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(isarSchemas, directory: dir.path, inspector: true);

    return _isar!;
  }

  Isar get db {
    if (_isar == null) {
      throw Exception("Isar chưa được khởi tạo!");
    }
    return _isar!;
  }

  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
