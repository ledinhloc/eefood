import 'package:flutter/material.dart';
import 'package:eefood/app_routes.dart';
import 'package:eefood/main.dart'; // để lấy navigatorKey

class DeepLinkHandler {
  /// Hàm xử lý deep link tổng quát
  static void handleDeepLink(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      if (pathSegments.isEmpty) return;

      final first = pathSegments.first;
      final id = pathSegments.length > 1 ? pathSegments[1] : null;

      switch (first) {
        case 'posts':
          if (id != null) {
            navigatorKey.currentState?.pushNamed(
              AppRoutes.recipeDetail,
              arguments: {'recipeId': int.tryParse(id)},
            );
          }
          break;

        default:
          navigatorKey.currentState?.pushNamed(AppRoutes.errorPage);
      }
    } catch (e) {
      debugPrint('Deep link parse error: $e');
      navigatorKey.currentState?.pushNamed(AppRoutes.errorPage);
    }
  }
}
