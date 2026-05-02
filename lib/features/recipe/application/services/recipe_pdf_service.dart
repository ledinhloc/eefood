import 'dart:io';

import 'package:eefood/features/recipe/data/models/recipe_detail_model.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class RecipePdfService {
  String recipePdfFileName(RecipeDetailModel recipe) {
    return '${_safeFileName(recipe.title)}.pdf';
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

    pw.ImageProvider? coverImage;
    final imageUrl = recipe.imageUrl?.trim();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        coverImage = await networkImage(imageUrl);
      } catch (_) {
        coverImage = null;
      }
    }

    final document = pw.Document(theme: theme);

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          theme: theme,
        ),
        header: (_) => pw.Text(
          'EEFood Recipe',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Trang ${context.pageNumber}/${context.pagesCount}',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ),
        build: (_) => [
          _buildTitle(recipe),
          if (coverImage != null) ...[
            pw.SizedBox(height: 16),
            pw.ClipRRect(
              horizontalRadius: 10,
              verticalRadius: 10,
              child: pw.Image(
                coverImage,
                height: 190,
                width: PdfPageFormat.a4.availableWidth,
                fit: pw.BoxFit.cover,
              ),
            ),
          ],
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
            pw.Wrap(
              spacing: 6,
              runSpacing: 6,
              children: recipe.categories!
                  .map((category) => category.description?.trim() ?? '')
                  .where((name) => name.isNotEmpty)
                  .map(_chip)
                  .toList(),
            ),
          ],
          pw.SizedBox(height: 20),
          _sectionTitle('Nguyên liệu'),
          _buildIngredients(recipe),
          pw.SizedBox(height: 20),
          _sectionTitle('Các bước thực hiện'),
          _buildSteps(recipe),
          if ((recipe.videoUrl ?? '').trim().isNotEmpty) ...[
            pw.SizedBox(height: 18),
            _sectionTitle('Video hướng dẫn'),
            pw.Text(
              recipe.videoUrl!.trim(),
              style: pw.TextStyle(fontSize: 11, color: PdfColors.blue700),
            ),
          ],
        ],
      ),
    );

    return document.save();
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
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.orange100),
      ),
      child: pw.Wrap(
        spacing: 18,
        runSpacing: 10,
        children: [
          _summaryItem('Chuẩn bị', '${recipe.prepTime ?? 0} phút'),
          _summaryItem('Nấu', '${recipe.cookTime ?? 0} phút'),
          _summaryItem('Tổng thời gian', '$totalTime phút'),
          _summaryItem('Độ khó', difficulty),
          if ((recipe.region ?? '').trim().isNotEmpty)
            _summaryItem('Vùng miền', recipe.region!.trim()),
        ],
      ),
    );
  }

  pw.Widget _summaryItem(String label, String value) {
    return pw.SizedBox(
      width: 140,
      child: pw.Column(
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
      ),
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
        final amount = [
          quantity,
          unit,
        ].where((part) => part.isNotEmpty).join(' ');

        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('• ', style: const pw.TextStyle(fontSize: 12)),
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

  pw.Widget _buildSteps(RecipeDetailModel recipe) {
    final steps = [...?recipe.steps]
      ..sort((first, second) => first.stepNumber.compareTo(second.stepNumber));

    if (steps.isEmpty) {
      return _emptyText('Chưa có bước thực hiện.');
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: steps.map((step) {
        final stepTime = step.stepTime == null
            ? ''
            : ' (${step.stepTime} phút)';

        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 12),
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
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
            ],
          ),
        );
      }).toList(),
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

  pw.Widget _chip(String label) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(999),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
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

  String _safeFileName(String value) {
    final sanitized = value
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]+'), '')
        .replaceAll(RegExp(r'\s+'), '_');

    return sanitized.isEmpty ? 'recipe' : sanitized;
  }
}
