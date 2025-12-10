import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eefood/core/constants/app_keys.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'dart:developer';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

class ShareUtils {
  static const String baseUrl = AppKeys.webDeloyUrl;

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.bytes,
      followRedirects: true,
    ),
  );

  /// Chia sẻ bài viết với OG preview + auto deep link redirect
  static Future<void> shareToPlatform({
    required String platform,
    required int recipeId,
    required String title,
    required String desc,
    required String imageUrl,
  }) async {
    try {
      // Tạo URL cho web preview - dùng Uri để build an toàn
      final shareUri = Uri(
        scheme: 'https',
        host: AppKeys.hostDeloy,
        path: '/posts/$recipeId',
        queryParameters: {'title': title, 'desc': desc, 'img': imageUrl},
      );
      final shareUrl = shareUri.toString(); // Không cần encodeFull nữa

      switch (platform.toLowerCase()) {
        case 'facebook':
          await _launch(
            "https://www.facebook.com/sharer/sharer.php?u=$shareUrl",
          );
          break;

        case 'twitter':
          await _launch(
            "https://twitter.com/intent/tweet?url=$shareUrl&text=${Uri.encodeComponent(title)}",
          );
          break;

        case 'other':
        case 'instagram':
        case 'tiktok':
          final file = await _downloadImage(imageUrl);
          final shareText = "$title\n\n$shareUrl";
          if (file != null && await file.exists()) {
            await Share.shareXFiles([XFile(file.path)], text: shareText);
          } else {
            await Share.share(shareText);
          }
          break;

        case 'copy':
          await Clipboard.setData(ClipboardData(text: shareUrl));
          log("Link copied: $shareUrl");
          break;

        default:
          await Share.share("$title\n\n$shareUrl");
          break;
      }

      log("Shared to $platform: $shareUrl");
    } catch (e) {
      log("Error sharing to $platform: $e");
      // Fallback: share thông thường
      await Share.share("$title\n\n$baseUrl/posts/$recipeId");
    }
  }

  static Future<void> _launch(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        log("Cannot launch $url");
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      log("Error launching URL: $e");
    }
  }

  static Future<File?> _downloadImage(String imageUrl) async {
    try {
      final response = await _dio.get(imageUrl);
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final filePath =
            "${tempDir.path}/share_image_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final file = File(filePath);
        await file.writeAsBytes(response.data);
        return file;
      }
    } catch (e) {
      log("Error downloading image: $e");
    }
    return null;
  }
}
