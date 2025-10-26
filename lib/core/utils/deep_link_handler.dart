import 'package:eefood/core/constants/app_keys.dart';
import 'package:flutter/material.dart';
import 'package:eefood/app_routes.dart';
import 'package:eefood/main.dart';

class DeepLinkHandler {
  /// Hàm điều hướng an toàn với timeout
  static void _navigateSafely(String route, {Object? arguments}) {
    Future.delayed(const Duration(milliseconds: 100), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final navState = navigatorKey.currentState;
        if (navState == null || navState.mounted == false) return;

        // Kiểm tra route hiện tại để tránh push trùng
        final currentRoute = ModalRoute.of(navState.context)?.settings.name;
        if (currentRoute == route) return;

        // Sử dụng pushReplacementNamed để tránh stack quá nhiều
        navState.pushNamed(route, arguments: arguments);
      });
    });
  }

  /// Deep link dạng nội bộ (eefood://posts/123)
  static void handleDeepLink(String url) {
    try {
      final uri = Uri.parse(url);
      
      // Log để debug
      debugPrint('[DeepLinkHandler] Handling deep link: $url');
      debugPrint('[DeepLinkHandler] Path segments: ${uri.pathSegments}');

      if (uri.pathSegments.isEmpty) {
        _navigateSafely(AppRoutes.splashPage);
        return;
      }

      final first = uri.pathSegments.first;
      final id = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;

      if (id == null) {
        _navigateSafely(AppRoutes.splashPage);
        return;
      }

      switch (first) {
        case 'posts':
        case 'recipes':
          final recipeId = int.tryParse(id);
          if (recipeId != null) {
            _navigateSafely(
              AppRoutes.recipeDetail,
              arguments: {'recipeId': recipeId},
            );
          } else {
            _navigateSafely(AppRoutes.errorPage);
          }
          break;

        default:
          _navigateSafely(AppRoutes.splashPage);
          break;
      }
    } catch (e) {
      debugPrint('Deep link parse error: $e');
      _navigateSafely(AppRoutes.errorPage);
    }
  }

  static void handleWebUrl(String url) {
    try {
      final uri = Uri.parse(url);
      debugPrint('[DeepLinkHandler] Handling web URL: $url');

      if ((uri.host == 'eefood-preview-card.vercel.app' || uri.host == AppKeys.hostDeloy) &&
          uri.pathSegments.length >= 2 &&
          uri.pathSegments.first == 'posts') {
        final recipeId = int.tryParse(uri.pathSegments[1]);
        if (recipeId != null) {
          _navigateSafely(
            AppRoutes.recipeDetail,
            arguments: {'recipeId': recipeId},
          );
          return;
        }
      }

      _navigateSafely(AppRoutes.splashPage);
    } catch (e) {
      debugPrint('Web URL parse error: $e');
      _navigateSafely(AppRoutes.errorPage);
    }
  }
}
