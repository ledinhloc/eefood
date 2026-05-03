import 'dart:typed_data';

import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/recipe/application/services/recipe_pdf_service.dart';
import 'package:eefood/features/recipe/data/models/recipe_detail_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class RecipePdfPreviewPage extends StatefulWidget {
  final RecipeDetailModel recipe;

  const RecipePdfPreviewPage({super.key, required this.recipe});

  @override
  State<RecipePdfPreviewPage> createState() => _RecipePdfPreviewPageState();
}

class _RecipePdfPreviewPageState extends State<RecipePdfPreviewPage> {
  static const double _previewDpi = 160;

  final RecipePdfService _pdfService = RecipePdfService();
  final List<Uint8List> _previewPages = [];

  late final String _fileName;
  late final Future<Uint8List> _pdfBytesFuture;

  Object? _previewError;
  bool _isPreviewLoading = true;
  bool _isSharing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    RecipePdfService.disablePdfDebug();
    _fileName = _pdfService.recipePdfFileName(widget.recipe);
    _pdfBytesFuture = _pdfService.generateRecipePdf(widget.recipe);
    _generatePreviewPages();
  }

  Future<void> _generatePreviewPages() async {
    try {
      final bytes = await _pdfBytesFuture;

      await for (final page in Printing.raster(bytes, dpi: _previewDpi)) {
        final png = await page.toPng();
        if (!mounted) return;

        setState(() {
          _previewPages.add(png);
        });
      }

      if (!mounted) return;
      setState(() {
        _isPreviewLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Generate recipe PDF preview failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;

      setState(() {
        _previewError = error;
        _isPreviewLoading = false;
      });
    }
  }

  Future<void> _sharePdf() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      final bytes = await _pdfBytesFuture;
      await Printing.sharePdf(
        bytes: bytes,
        filename: _fileName,
        subject: 'Công thức ${widget.recipe.title}',
        body: 'Công thức: ${widget.recipe.title}',
      );
    } catch (error, stackTrace) {
      debugPrint('Share recipe PDF failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        showCustomSnackBar(
          context,
          'Không thể chia sẻ PDF. Vui lòng thử lại',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _savePdf() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    try {
      final bytes = await _pdfBytesFuture;
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Lưu PDF công thức',
        fileName: _fileName,
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        bytes: bytes,
      );

      if (!mounted || savedPath == null) return;

      showCustomSnackBar(context, 'Đã lưu PDF thành công');
    } catch (error, stackTrace) {
      debugPrint('Save recipe PDF failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        showCustomSnackBar(
          context,
          'Không thể lưu PDF. Vui lòng thử lại',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.surface
        : Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surfaceColor,
        foregroundColor: theme.colorScheme.onSurface,
        title: const Text(
              'Xem trước PDF',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
        shape: Border(
          bottom: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
      ),
      body: _buildPreviewBody(),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  label: 'Chia sẻ',
                  icon: Icons.ios_share_rounded,
                  isLoading: _isSharing,
                  isPrimary: false,
                  onPressed: _isSharing ? null : _sharePdf,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  label: 'Tải PDF',
                  icon: Icons.download_rounded,
                  isLoading: _isSaving,
                  isPrimary: true,
                  onPressed: _isSaving ? null : _savePdf,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isLoading,
    required bool isPrimary,
    required VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final foreground = isPrimary ? theme.colorScheme.onPrimary : primary;
    final background = isPrimary
        ? primary
        : primary.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.18 : 0.10,
          );

    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foreground,
                ),
              )
            : Icon(icon, size: 20),
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: background,
          disabledBackgroundColor: background.withValues(alpha: 0.55),
          foregroundColor: foreground,
          disabledForegroundColor: foreground.withValues(alpha: 0.70),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewBody() {
    if (_previewPages.isEmpty && _isPreviewLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_previewPages.isEmpty && _previewError != null) {
      return _buildPreviewError();
    }

    return Column(
      children: [
        if (_isPreviewLoading) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _previewPages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, index) => _buildPreviewPage(index),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewPage(int index) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Image.memory(
        _previewPages[index],
        fit: BoxFit.fitWidth,
        filterQuality: FilterQuality.high,
      ),
    );
  }

  Widget _buildPreviewError() {
    return Builder(
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Không thể xem trước PDF. Vui lòng thử lại',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
