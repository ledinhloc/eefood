import 'dart:io';

import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class SaveFileMedia {
  static Future<String?> saveFileToGallery(
    File file, {
    bool isImage = true,
  }) async {
    try {
      final fileName = _generateFileName(isImage);
      final result = await ImageGallerySaverPlus.saveFile(
        file.path,
        isReturnPathOfIOS: true,
        name: fileName,
      );

      if (result == null) return null;

      // result có dạng: {filePath: "..."}
      if (result is Map && result["filePath"] != null) {
        return result["filePath"];
      }

      return result.toString();
    } catch (err) {
      throw Exception('Failed to save file to gallery: $err');
    }
  }

  static String _generateFileName(bool isImage) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return isImage ? "IMG_$timestamp" : "VID_$timestamp";
  }
}
