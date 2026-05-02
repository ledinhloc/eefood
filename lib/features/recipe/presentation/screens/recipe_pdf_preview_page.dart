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
  late final String _fileName;
  late final Future<Uint8List> _pdfBytesFuture;
  final List<Uint8List> _previewPages = [];
  Object? _previewError;
  bool _isPreviewLoading = true;
  bool _isSharing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _disablePdfDebug();
    _fileName = _pdfService.recipePdfFileName(widget.recipe);
    _pdfBytesFuture = _generatePdfBytes();
    _generatePreviewPages();
  }

  Future<Uint8List> _generatePdfBytes() {
    _disablePdfDebug();
    return _pdfService.generateRecipePdf(widget.recipe);
  }

  Future<void> _generatePreviewPages() async {
    try {
      RecipePdfService.disablePdfDebug();
      final bytes = await _pdfBytesFuture;

      await for (final page in Printing.raster(bytes, dpi: _previewDpi)) {
        RecipePdfService.disablePdfDebug();
        final png = await page.toPng();
        if (!mounted) return;

        setState(() {
          _previewPages.add(png);
        });
      }

      if (!mounted) return;
      setState(() => _isPreviewLoading = false);
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

  void _disablePdfDebug() {
    RecipePdfService.disablePdfDebug();
  }

  @override
  void dispose() {
    _disablePdfDebug();
    super.dispose();
  }

  Future<void> _sharePdf() async {
    if (_isSharing) return;

    setState(() => _isSharing = true);
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
    _disablePdfDebug();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem trước PDF'),
        actions: [
          IconButton(
            tooltip: 'Chia sẻ',
            onPressed: _isSharing ? null : _sharePdf,
            icon: _isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.ios_share_rounded),
          ),
          IconButton(
            tooltip: 'Tải PDF',
            onPressed: _isSaving ? null : _savePdf,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_rounded),
          ),
        ],
      ),
      body: _buildPreviewBody(context),
    );
  }

  Widget _buildPreviewBody(BuildContext context) {
    if (_previewPages.isEmpty && _isPreviewLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_previewPages.isEmpty && _previewError != null) {
      return _buildPreviewError(context);
    }

    return Column(
      children: [
        if (_isPreviewLoading) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _previewPages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _buildPreviewPage(index),
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
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Image.memory(
        _previewPages[index],
        fit: BoxFit.fitWidth,
        filterQuality: FilterQuality.high,
      ),
    );
  }

  Widget _buildPreviewError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Không thể xem trước PDF. Vui lòng thử lại',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
