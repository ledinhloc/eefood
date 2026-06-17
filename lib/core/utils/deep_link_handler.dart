import 'package:eefood/app_routes.dart';
import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/livestream/domain/repository/live_comment_repo.dart';
import 'package:eefood/features/livestream/domain/repository/live_reaction_repo.dart';
import 'package:eefood/features/livestream/domain/repository/live_viewer_repository.dart';
import 'package:eefood/features/livestream/presentation/provider/block_user_cubit.dart';
import 'package:eefood/features/livestream/presentation/provider/live_comment_cubit.dart';
import 'package:eefood/features/livestream/presentation/provider/live_gift_cubit.dart';
import 'package:eefood/features/livestream/presentation/provider/live_leaderboard_cubit.dart';
import 'package:eefood/features/livestream/presentation/provider/live_poll_cubit.dart';
import 'package:eefood/features/livestream/presentation/provider/live_reaction_cubit.dart';
import 'package:eefood/features/livestream/presentation/provider/live_viewer_cubit.dart';
import 'package:eefood/features/livestream/presentation/provider/subtitle_cubit.dart';
import 'package:eefood/features/livestream/presentation/provider/watch_live_cubit.dart';
import 'package:eefood/features/livestream/presentation/screens/live_viewer_screen.dart';
import 'package:eefood/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeepLinkHandler {
  /// Hàm điều hướng an toàn với timeout
  static void _navigateSafely(
    String route, {
    Object? arguments,
    bool replaceCurrent = false,
  }) {
    Future.delayed(const Duration(milliseconds: 100), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final navState = navigatorKey.currentState;
        if (navState == null || navState.mounted == false) return;

        // Kiểm tra route hiện tại để tránh push trùng
        final currentRoute = ModalRoute.of(navState.context)?.settings.name;
        if (currentRoute == route) {
          if (replaceCurrent)
            navState.pushReplacementNamed(route, arguments: arguments);
          return;
        }

        if (replaceCurrent) {
          navState.pushReplacementNamed(route, arguments: arguments);
          return;
        }

        // Sử dụng pushReplacementNamed để tránh stack quá nhiều
        navState.pushNamed(route, arguments: arguments);
      });
    });
  }

  static void _pushSafely(Route<void> route) {
    Future.delayed(const Duration(milliseconds: 100), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final navState = navigatorKey.currentState;
        if (navState == null || navState.mounted == false) return;
        navState.push(route);
      });
    });
  }

  static void _openLiveViewer(int streamId) {
    _pushSafely(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => SubtitleCubit()),
            BlocProvider(create: (_) => getIt<WatchLiveCubit>()),
            BlocProvider(
              create: (_) =>
                  LiveCommentCubit(getIt<LiveCommentRepository>(), streamId),
            ),
            BlocProvider(
              create: (_) =>
                  LiveReactionCubit(getIt<LiveReactionRepository>(), streamId),
            ),
            BlocProvider(
              create: (_) =>
                  LiveViewerCubit(getIt<LiveViewerRepository>(), streamId),
            ),
            BlocProvider(create: (_) => BlockUserCubit()),
            BlocProvider(
              create: (_) => LivePollCubit()
                ..init(
                  liveStreamId: streamId,
                  isHost: false,
                  connectSocket: true,
                ),
            ),
            BlocProvider(create: (_) => getIt<LiveGiftCubit>()..init(streamId)),
            BlocProvider(
              create: (_) => getIt<LiveLeaderboardCubit>()..init(streamId),
            ),
          ],
          child: LiveViewerScreen(streamId: streamId),
        ),
      ),
    );
  }

  /// Deep link dạng nội bộ (eefood://posts/123)
  static void handleDeepLink(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments =
          uri.host.isNotEmpty && uri.scheme != 'http' && uri.scheme != 'https'
          ? [uri.host, ...uri.pathSegments]
          : uri.pathSegments;

      // Log để debug
      debugPrint('[DeepLinkHandler] Handling deep link: $url');
      debugPrint('[DeepLinkHandler] Path segments: $pathSegments');

      if (pathSegments.isEmpty) {
        _navigateSafely(AppRoutes.splashPage);
        return;
      }

      final first = pathSegments.first;
      final id = pathSegments.length > 1 ? pathSegments[1] : null;

      if (first == 'recipe-approve') {
        _handleRecipeApprove(uri);
        return;
      }

      if (first == 'meal-plan') {
        _handleMealPlan(uri);
        return;
      }

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
        case 'livestreams':
          final streamId = int.tryParse(id);
          if (streamId != null) {
            _openLiveViewer(streamId);
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

      if ((uri.host == 'eefood-preview-card.vercel.app' ||
              uri.host == AppKeys.hostDeloy) &&
          uri.pathSegments.length >= 2 &&
          uri.pathSegments.first == 'recipes') {
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

  static void _handleRecipeApprove(Uri uri) {
    final recipeId =
        uri.queryParameters['recipeId'] ??
        (uri.pathSegments.length > 2 ? uri.pathSegments[2] : null);
    final recipeName = uri.queryParameters['recipeName'];
    final message = uri.queryParameters['message'];
    final imageUrl = uri.queryParameters['imageUrl'];
    final approvedAtStr = uri.queryParameters['approvedAt'];

    DateTime? approvedAt;
    if (approvedAtStr != null) {
      try {
        approvedAt = DateTime.parse(approvedAtStr);
      } catch (e) {
        debugPrint('Error parsing approvedAt: $e');
      }
    }

    int? recipeIdInt;
    if (recipeId != null) {
      recipeIdInt = int.tryParse(recipeId);
    }

    _navigateSafely(
      AppRoutes.recipeApprovalDetail,
      arguments: {
        'recipeId': recipeIdInt,
        'recipeName': recipeName,
        'message': message,
        'imageUrl': imageUrl,
        'approvedAt': approvedAt,
      },
    );
    return;
  }

  static void _handleMealPlan(Uri uri) {
    DateTime? date;
    final dateStr = uri.queryParameters['date'];
    if (dateStr != null && dateStr.isNotEmpty) {
      date = DateTime.tryParse(dateStr);
    }

    _navigateSafely(
      AppRoutes.mealPlan,
      arguments: {'date': date},
    );
  }
}
