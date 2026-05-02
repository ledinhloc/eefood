import 'dart:typed_data';

import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/recipe/application/services/recipe_pdf_service.dart';
import 'package:eefood/features/recipe/data/models/recipe_detail_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class RecipePdfPreviewPage extends StatefulWidget {
  final RecipeDetailModel recipe;

  const RecipePdfPreviewPage({super.key, required this.recipe});

  @override
  State<RecipePdfPreviewPage> createState() => _RecipePdfPreviewPageState();
}

class _RecipePdfPreviewPageState extends State<RecipePdfPreviewPage> {
  final RecipePdfService _pdfService = RecipePdfService();
  late final Future<Uint8List> _pdfBytesFuture;
  late final String _fileName;
  bool _isSharing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fileName = '${_safeFileName(widget.recipe.title)}.pdf';
    _pdfBytesFuture = _pdfService.generateRecipePdf(widget.recipe);
  }

  String _safeFileName(String value) {
    final sanitized = value
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]+'), '')
        .replaceAll(RegExp(r'\s+'), '_');

    return sanitized.isEmpty ? 'recipe' : sanitized;
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
      body: PdfPreview(
        build: (_) => _pdfBytesFuture,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: _fileName,
        allowPrinting: false,
        allowSharing: false,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        loadingWidget: const Center(child: CircularProgressIndicator()),
        onError: (context, error) {
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
        },
      ),
    );
  }
}
