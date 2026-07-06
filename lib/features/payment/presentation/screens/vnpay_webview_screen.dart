import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:eefood/app_routes.dart';
import 'package:eefood/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
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
  bool _hasHandledResult = false;
  String? _errorMessage;
  late Uri _paymentUri;
  StreamSubscription? _deepLinkSub;

  @override
  void initState() {
    super.initState();
    _paymentUri = Uri.parse(widget.paymentUrl.trim());
    logger.i('VNPay payment URL: $_paymentUri');
    _initWebView();
    _listenDeepLink();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (url.startsWith('eefood://')) {
              _handleDeepLinkUrl(url);
              return;
            }
            _setLoading(true);
          },
          onPageFinished: (_) {
            _setLoading(false);
          },
          onWebResourceError: (error) {
            final url = error.url ?? '';
            logger.e(
              'VNPay WebView error: code=${error.errorCode}, '
              'type=${error.errorType}, mainFrame=${error.isForMainFrame}, '
              'url=$url, description=${error.description}',
            );
            if (url.startsWith('eefood://')) {
              _handleDeepLinkUrl(url);
              return;
            }

            if (error.isForMainFrame ?? true) {
              _showLoadError(
                'Khong the hien thi VNPay trong WebView.\n${error.description}',
              );
            }
          },
          onSslAuthError: _handleSslAuthError,
          onNavigationRequest: (request) {
            final url = request.url;

            if (url.startsWith('eefood://')) {
              _handleDeepLinkUrl(url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )..loadRequest(_paymentUri);
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
    if (!mounted || _hasHandledResult) return;
    _hasHandledResult = true;

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

  void _handleSslAuthError(SslAuthError error) {
    final platformError = error.platform;
    final errorUrl = platformError is AndroidSslAuthError
        ? platformError.url
        : _paymentUri.toString();
    final host = Uri.tryParse(errorUrl)?.host.toLowerCase();
    final allowedInSandbox =
        host == 'sandbox.vnpayment.vn' ||
        (host != null && host.endsWith('.ngrok-free.app'));

    logger.w(
      'VNPay SSL auth error: host=$host, '
      'description=${platformError.description}, allowed=$allowedInSandbox',
    );

    if (allowedInSandbox) {
      error.proceed();
      return;
    }

    error.cancel();
    _showLoadError('SSL khong hop le: ${platformError.description}');
  }

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() {
      _isLoading = value;
      if (value) _errorMessage = null;
    });
  }

  void _showLoadError(String message) {
    if (!mounted || _hasHandledResult) return;
    setState(() {
      _isLoading = false;
      _errorMessage = message;
    });
  }

  Future<void> _openInBrowser() async {
    final opened = await launchUrl(
      _paymentUri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      _showLoadError('Khong the mo trinh duyet ngoai.');
    }
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          onPressed: () => _showCancelDialog(),
        ),
        title: Row(
          children: [
            Icon(Icons.lock, color: Color(0xFF4CAF50), size: 16),
            SizedBox(width: 6),
            Text(
              'Thanh toán VNPay',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_errorMessage != null) _buildErrorView(theme),
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

  Widget _buildErrorView(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_clock, color: Color(0xFFFFB74D), size: 56),
          const SizedBox(height: 16),
          Text(
            'Khong the tai trang thanh toan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _setLoading(true);
                    _controller.loadRequest(_paymentUri);
                  },
                  child: const Text('Thu lai'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _openInBrowser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C6AFF),
                  ),
                  child: const Text(
                    'Mo browser',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
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
