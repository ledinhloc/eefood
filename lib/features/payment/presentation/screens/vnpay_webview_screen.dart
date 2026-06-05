import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:eefood/app_routes.dart';
import 'package:eefood/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VnpayWebviewScreen extends StatefulWidget {
  final String paymentUrl;
  final int transactionId;

  const VnpayWebviewScreen({
    super.key,
    required this.paymentUrl,
    required this.transactionId,
  });

  @override
  State<VnpayWebviewScreen> createState() => _VnpayWebviewScreenState();
}

class _VnpayWebviewScreenState extends State<VnpayWebviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  StreamSubscription? _deepLinkSub;

  @override
  void initState() {
    super.initState();
    _initWebView();
    _listenDeepLink();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0F0F1A))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
          if (url.startsWith('eefood://')) {
            _handleDeepLinkUrl(url);
            return;
          }
          setState(() => _isLoading = true);
        },
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
            final url = error.url ?? '';
            if (url.startsWith('eefood://')) {
              _handleDeepLinkUrl(url);
            }
          },
          onNavigationRequest: (request) {
            final url = request.url;

            if (url.startsWith('eefood://')) {
              _handleDeepLinkUrl(url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _listenDeepLink() {
    final appLinks = AppLinks();

    appLinks.getInitialLink().then((uri) {
      if (uri != null &&
          uri.scheme == 'eefood' &&
          uri.path == '/payment/result') {
        _handleDeepLinkUri(uri);
      }
    });

    _deepLinkSub = appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'eefood' && uri.path == '/payment/result') {
        _handleDeepLinkUri(uri);
      }
    });
  }

  void _handleDeepLinkUrl(String url) {
    try {
      _handleDeepLinkUri(Uri.parse(url));
    } catch (e) {
      debugPrint('Cannot parse deep link: $e');
    }
  }

  void _handleDeepLinkUri(Uri uri) {
  if (!mounted) return;

  debugPrint('=== Deep link received: $uri');
  debugPrint('=== Params: ${uri.queryParameters}');

  final params = uri.queryParameters;

  bool success;
  if (params.containsKey('success')) {
    success = params['success'] == 'true';
  } else {
    // Đọc trực tiếp params VNPay
    final responseCode = params['vnp_ResponseCode'];
    final transactionStatus = params['vnp_TransactionStatus'];
    success = responseCode == '00' && transactionStatus == '00';
  }

  final txnRef = params['txnRef'] ?? params['vnp_TxnRef'];
  final amount = params['amount'] ?? params['vnp_Amount'];
  final responseCode = params['responseCode'] ?? params['vnp_ResponseCode'];

  debugPrint('=== isSuccess: $success');

  Navigator.of(context).pushReplacementNamed(
    AppRoutes.paymentResultScreen,
    arguments: {
      'isSuccess': success,
      'txnRef': txnRef,
      'amount': amount,
      'responseCode': responseCode,
    },
  );
}

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => _showCancelDialog(),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock, color: Color(0xFF4CAF50), size: 16),
            SizedBox(width: 6),
            Text(
              'Thanh toán VNPay',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C6AFF)),
              ),
            ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Huỷ thanh toán?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Giao dịch chưa hoàn thành. Bạn có muốn thoát không?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tiếp tục',
              style: TextStyle(color: Color(0xFF7C6AFF)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // đóng dialog
              Navigator.pop(context); // đóng WebView
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
            ),
            child: const Text('Thoát', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
