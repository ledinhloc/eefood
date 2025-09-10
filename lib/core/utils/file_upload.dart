import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
// import '../config.dart'; // chứa class Config

/* Upload file to cloudinary*/
class FileUploader {
  final Dio dio;
  FileUploader({required this.dio});
  Future<String> uploadFile(File file) async {
    const String cloudName = String.fromEnvironment("CLOUD_NAME");
    const String uploadPreset = String.fromEnvironment("UPLOAD_PRESET");
    final url = "https://api.cloudinary.com/v1_1/${cloudName}/upload";

    final formData = FormData.fromMap({
      "upload_preset": uploadPreset,
      "file": await MultipartFile.fromFile(
        file.path,
        filename: basename(file.path),
      ),
    });

    final response = await dio.post(
        url,
        data: formData,
        options: Options(extra: {'requireAuth': false}));

    if (response.statusCode == 200) {
      return response.data["secure_url"];
    } else {
      throw Exception("Upload failed: ${response.statusCode}");
    }
  }
}
