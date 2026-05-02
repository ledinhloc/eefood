import 'dart:io';

import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/features/recipe/data/models/recipe_detail_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart' as printing;
import 'package:share_plus/share_plus.dart';

class RecipePdfService {
  static void disablePdfDebug() {
    pw.Document.debug = false;
    pw.RichText.debug = false;
  }

  String recipePdfFileName(RecipeDetailModel recipe) {
    final sanitized = recipe.title
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]+'), '')
        .replaceAll(RegExp(r'\s+'), '_');

    final fileName = sanitized.isEmpty ? 'recipe' : sanitized;
    return '$fileName.pdf';
  }

  Future<void> shareRecipePdf(RecipeDetailModel recipe) async {
    final bytes = await generateRecipePdf(recipe);
    final tempDir = await getTemporaryDirectory();
    final fileName = recipePdfFileName(recipe);
    final file = File('${tempDir.path}/$fileName');

    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        text: 'Công thức: ${recipe.title}',
        subject: 'Công thức ${recipe.title}',
        title: recipe.title,
      ),
    );
  }

  Future<Uint8List> generateRecipePdf(RecipeDetailModel recipe) async {
    disablePdfDebug();

    try {
      final regularFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
      );
      final boldFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
      );
      final italicFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSans-Italic.ttf'),
      );

      final theme = pw.ThemeData.withFont(
        base: regularFont,
        bold: boldFont,
        italic: italicFont,
      );

      final steps = [...?recipe.steps]
        ..sort((first, second) => first.stepNumber.compareTo(second.stepNumber));

      final document = pw.Document(theme: theme);
      final coverImage = await _loadNetworkImage(recipe.imageUrl);
      final stepImages = await _loadStepImages(steps);
      final recipeUrl = _buildRecipeUrl(recipe.id);

      document.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.fromLTRB(32, 48, 32, 40),
            theme: theme,
          ),
          footer: (context) => pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Trang ${context.pageNumber}/${context.pagesCount}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ),
          build: (_) => [
            if (coverImage != null) ...[
              _buildCoverImage(coverImage),
              pw.SizedBox(height: 18),
            ],
            _buildTitle(recipe),
            pw.SizedBox(height: 18),
            _buildSummary(recipe),
            if ((recipe.description ?? '').trim().isNotEmpty) ...[
              pw.SizedBox(height: 18),
              _sectionTitle('Mô tả'),
              pw.Text(
                recipe.description!.trim(),
                style: const pw.TextStyle(fontSize: 12, lineSpacing: 4),
              ),
            ],
            if (recipe.categories?.isNotEmpty ?? false) ...[
              pw.SizedBox(height: 18),
              _sectionTitle('Danh mục'),
              pw.Text(
                recipe.categories!
                    .map((category) => category.description?.trim() ?? '')
                    .where((name) => name.isNotEmpty)
                    .join(', '),
                style: const pw.TextStyle(fontSize: 12, lineSpacing: 4),
              ),
            ],
            pw.SizedBox(height: 20),
            _sectionTitle('Nguyên liệu'),
            _buildIngredients(recipe),
            pw.SizedBox(height: 20),
            _sectionTitle('Các bước thực hiện'),
            _buildSteps(steps, stepImages),
            if ((recipe.videoUrl ?? '').trim().isNotEmpty) ...[
              pw.SizedBox(height: 18),
              _sectionTitle('Video hướng dẫn'),
              pw.Text(
                recipe.videoUrl!.trim(),
                style: pw.TextStyle(fontSize: 11, color: PdfColors.blue700),
              ),
            ],
            if (recipeUrl != null) ...[
              pw.SizedBox(height: 20),
              _sectionTitle('QR công thức'),
              _buildRecipeQr(recipeUrl),
            ],
          ],
        ),
      );

      return document.save();
    } finally {
      disablePdfDebug();
    }
  }

  Future<pw.ImageProvider?> _loadNetworkImage(String? imageUrl) async {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) return null;

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return null;

    try {
      if (uri.scheme == 'http' || uri.scheme == 'https') {
        return printing.networkImage(url, cache: true);
      }
    } catch (error, stackTrace) {
      debugPrint('Load recipe PDF image failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    return null;
  }

  Future<List<pw.ImageProvider>> _loadImages(List<String>? imageUrls) async {
    final urls = (imageUrls ?? const <String>[])
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList();

    final images = <pw.ImageProvider>[];
    for (final url in urls) {
      final image = await _loadNetworkImage(url);
      if (image != null) {
        images.add(image);
      }
    }

    return images;
  }

  Future<Map<int, List<pw.ImageProvider>>> _loadStepImages(
    List<RecipeStepModel> steps,
  ) async {
    final stepImages = <int, List<pw.ImageProvider>>{};

    for (final step in steps) {
      stepImages[step.stepNumber] = await _loadImages(step.imageUrls);
    }

    return stepImages;
  }

  String? _buildRecipeUrl(int? recipeId) {
    if (recipeId == null) return null;
    return '${AppKeys.webDeloyUrl}/recipes/$recipeId';
  }

  pw.Widget _buildCoverImage(pw.ImageProvider image) {
    return pw.Container(
      height: 180,
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Image(image, fit: pw.BoxFit.cover),
    );
  }

  pw.Widget _buildRecipeQr(String recipeUrl) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: recipeUrl,
            width: 88,
            height: 88,
            color: PdfColors.brown900,
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Quét mã QR để mở công thức trên điện thoại.',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  recipeUrl,
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.blue700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTitle(RecipeDetailModel recipe) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          recipe.title,
          style: pw.TextStyle(
            fontSize: 26,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.deepOrange700,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'Tác giả: ${recipe.username}',
          style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
        ),
      ],
    );
  }

  pw.Widget _buildSummary(RecipeDetailModel recipe) {
    final totalTime = (recipe.prepTime ?? 0) + (recipe.cookTime ?? 0);
    final difficulty = recipe.difficulty?.name ?? 'N/A';

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.orange50,
        border: pw.Border.all(color: PdfColors.orange100),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _summaryItem('Chuẩn bị', '${recipe.prepTime ?? 0} phút'),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _summaryItem('Nấu', '${recipe.cookTime ?? 0} phút'),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _summaryItem('Tổng thời gian', '$totalTime phút'),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(child: _summaryItem('Độ khó', difficulty)),
            ],
          ),
          if ((recipe.region ?? '').trim().isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: _summaryItem('Vùng miền', recipe.region!.trim()),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(child: pw.SizedBox()),
              ],
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _summaryItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  pw.Widget _buildIngredients(RecipeDetailModel recipe) {
    final ingredients = recipe.ingredients ?? const [];
    if (ingredients.isEmpty) {
      return _emptyText('Chưa có nguyên liệu.');
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: ingredients.map((item) {
        final quantity = item.quantity == null
            ? ''
            : item.quantity! % 1 == 0
                ? item.quantity!.toInt().toString()
                : item.quantity!.toString();
        final unit = item.unit?.trim() ?? '';
        final name = item.ingredient?.name.trim() ?? 'Nguyên liệu';
        final amount = [quantity, unit]
            .where((part) => part.isNotEmpty)
            .join(' ');

        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('- ', style: const pw.TextStyle(fontSize: 12)),
              pw.Expanded(
                child: pw.Text(
                  amount.isEmpty ? name : '$name - $amount',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _buildSteps(
    List<RecipeStepModel> steps,
    Map<int, List<pw.ImageProvider>> stepImages,
  ) {
    if (steps.isEmpty) {
      return _emptyText('Chưa có bước thực hiện.');
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: steps.map((step) {
        final stepTime = step.stepTime == null ? '' : ' (${step.stepTime} phút)';
        final images = stepImages[step.stepNumber] ?? const <pw.ImageProvider>[];

        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 12),
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Bước ${step.stepNumber}$stepTime',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.deepOrange700,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                (step.instruction ?? '').trim().isEmpty
                    ? 'Không có mô tả.'
                    : step.instruction!.trim(),
                style: const pw.TextStyle(fontSize: 12, lineSpacing: 4),
              ),
              if (images.isNotEmpty) ...[
                pw.SizedBox(height: 10),
                _buildStepImages(images),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _buildStepImages(List<pw.ImageProvider> images) {
    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children: images
          .map(
            (image) => pw.Container(
              width: 150,
              height: 110,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Image(image, fit: pw.BoxFit.cover),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.deepOrange700,
        ),
      ),
    );
  }

  pw.Widget _emptyText(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 12,
        color: PdfColors.grey600,
        fontStyle: pw.FontStyle.italic,
      ),
    );
  }
}
