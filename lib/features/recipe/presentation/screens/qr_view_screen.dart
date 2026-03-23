import 'dart:io';
import 'dart:ui' as ui;

import 'package:eefood/core/utils/save_file_media.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/recipe/presentation/widgets/qr_code/action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class QRViewScreen extends StatefulWidget {
  final int recipeId;
  final String recipeUrl;
  final String recipeTitle;

  const QRViewScreen({
    super.key,
    required this.recipeId,
    required this.recipeUrl,
    required this.recipeTitle
  });

  @override
  State<QRViewScreen> createState() => _QRViewScreenState();
}

class _QRViewScreenState extends State<QRViewScreen>
    with TickerProviderStateMixin {
  final GlobalKey _qrKey = GlobalKey();
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isSaving = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      lowerBound: 0.85,
      upperBound: 1.0,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  Future<Uint8List?> _captureQRImage() async {
    try {
      final RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Lỗi chụp QR: $e');
      return null;
    }
  }

  // Tải QR code về bộ nhớ máy
   Future<void> _downloadQR() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final bytes = await _captureQRImage();
      if (bytes == null) throw Exception('Không thể tạo ảnh QR');

      // Ghi tạm ra file rồi nhờ SaveFileMedia lưu vào gallery
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/qr_${widget.recipeId}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await tempFile.writeAsBytes(bytes);

      final savedPath = await SaveFileMedia.saveFileToGallery(tempFile);

      if (mounted) {
        if (savedPath != null) {
          showCustomSnackBar(context, 'Đã lưu QR vào thư viện ảnh');
        } else {
          showCustomSnackBar(context, 'Lưu thất bại', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, 'Lỗi khi lưu: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Chia sẻ QR code
  Future<void> _shareQR() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final bytes = await _captureQRImage();
      if (bytes == null) throw Exception('Không thể tạo ảnh QR');

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/qr_${widget.recipeId}.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Xem công thức "${widget.recipeTitle}" tại:\n${widget.recipeUrl}',
        subject: 'Chia sẻ công thức: ${widget.recipeTitle}',
      );
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, 'Lỗi khi chia sẻ: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: const Color(0xFF3D2C1E),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'QR Code Công Thức',
          style: TextStyle(
            color: Color(0xFF3D2C1E),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              ScaleTransition(scale: _scaleAnimation, child: _buildQRCard()),
              const SizedBox(height: 28),

              // URL hiển thị 
              _buildUrlChip(),
              const SizedBox(height: 36),

              // Các nút hành động
              _buildActionButtons(),
              const SizedBox(height: 24),

              // Hướng dẫn
              _buildHint(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3D2C1E).withOpacity(0.10),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.06),
            blurRadius: 60,
            spreadRadius: 10,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          RepaintBoundary(
            key: _qrKey,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: QrImageView(
                data: widget.recipeUrl,
                version: QrVersions.auto,
                size: 220,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF3D2C1E),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF3D2C1E),
                ),
                embeddedImage: null,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, const Color(0xFFEADDD5)],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.qr_code_2_rounded,
                  color: const Color(0xFFFF6B35).withOpacity(0.6),
                  size: 20,
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFFEADDD5), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUrlChip() {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: widget.recipeUrl));
        showCustomSnackBar(context, '📋 Đã sao chép liên kết!');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B35).withOpacity(0.08),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link_rounded, size: 16, color: Color(0xFFFF6B35)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.recipeUrl,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFFF6B35),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.copy_rounded, size: 14, color: Color(0xFFFF6B35)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Nút Chia sẻ
        Expanded(
          child: ActionButton(
            label: 'Chia sẻ',
            icon: Icons.share_rounded,
            isLoading: _isSharing,
            isPrimary: true,
            onTap: _shareQR,
          ),
        ),
        const SizedBox(width: 14),

        // Nút Tải về
        Expanded(
          child: ActionButton(
            label: 'Tải về',
            icon: Icons.download_rounded,
            isLoading: _isSaving,
            isPrimary: false,
            onTap: _downloadQR,
          ),
        ),
      ],
    );
  }

  Widget _buildHint() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EDE6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Color(0xFF8D7B6A),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Mở camera điện thoại và hướng vào mã QR để truy cập công thức ngay lập tức. Bấm vào liên kết để sao chép URL.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF8D7B6A),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
