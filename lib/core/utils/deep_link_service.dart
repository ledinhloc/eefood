import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:eefood/core/constants/app_keys.dart';
import 'package:flutter/material.dart';
import 'package:eefood/core/utils/deep_link_handler.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  Uri? _pendingLink;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // Lấy initial link trước
      _pendingLink = await _appLinks.getInitialLink();
      debugPrint('[DeepLinkService] Initial link: $_pendingLink');

      // Sau đó lắng nghe stream
      _subscription = _appLinks.uriLinkStream.listen((uri) {
        debugPrint('[DeepLinkService] Received deep link: $uri');
        _handleIncomingLink(uri);
      }, onError: (error) {
        debugPrint('[DeepLinkService] Error in link stream: $error');
      });

    } catch (e) {
      debugPrint('[DeepLinkService] Initialization error: $e');
    }
  }

  void handlePendingLinkIfAny() {
    if (_pendingLink != null) {
      debugPrint('[DeepLinkService] Handling pending link: $_pendingLink');
      _handleIncomingLink(_pendingLink!);
      _pendingLink = null;
    }
  }

  void _handleIncomingLink(Uri uri) {
    final url = uri.toString();
    debugPrint('[DeepLinkService] Processing: $url');

    // Thêm delay để đảm bảo Navigator đã sẵn sàng
    Future.delayed(const Duration(milliseconds: 500), () {
      if (uri.host == 'eefoods.netlify.app' || uri.host == AppKeys.hostDeloy) {
        DeepLinkHandler.handleWebUrl(url);
      } else if (uri.scheme == 'eefood') {
        DeepLinkHandler.handleDeepLink(url);
      } else {
        debugPrint('[DeepLinkService] Unknown link scheme: ${uri.scheme}');
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    _initialized = false;
  }
}