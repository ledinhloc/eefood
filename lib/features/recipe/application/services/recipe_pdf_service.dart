import 'dart:io';

import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/nutrition/data/models/nutrition_analysis_model.dart';
import 'package:eefood/features/nutrition/domain/repositories/nutrition_repository.dart';
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

    //load font
    try {
      debugPrint(
        '[RecipePdf] Start generate PDF. recipeId=${recipe.id}, title=${recipe.title}',
      );
      final regularFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
      );
      final boldFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
      );
      final italicFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSans-Italic.ttf'),
      );

      //tao theme
      final theme = pw.ThemeData.withFont(
        base: regularFont,
        bold: boldFont,
        italic: italicFont,
      );

      final steps = recipe.steps ?? const <RecipeStepModel>[];

      final document = pw.Document(theme: theme);
      final coverImageFuture = _loadNetworkImage(recipe.imageUrl);
      final stepImagesFuture = _loadStepImages(steps);
      final nutritionFuture = _loadNutrition(recipe.id);
      final coverImage = await coverImageFuture;
      final stepImages = await stepImagesFuture;
      final nutrition = await nutritionFuture;
      debugPrint(
        '[RecipePdf] Assets loaded. cover=${coverImage != null}, steps=${steps.length}, stepImages=${stepImages.values.fold<int>(0, (total, images) => total + images.length)}, nutrition=${nutrition != null}',
      );
      final recipeUrl = _buildRecipeUrl(recipe.id);

      document.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.fromLTRB(24, 34, 24, 30),
            theme: theme,
          ),
          footer: (context) => pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Trang ${context.pageNumber}/${context.pagesCount}',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
            ),
          ),
          build: (_) => [
            if (coverImage != null) ...[
              _buildCoverImage(coverImage),
              pw.SizedBox(height: 12),
            ],
            _buildTitle(recipe),
            pw.SizedBox(height: 12),
            _buildSummary(recipe),
            if ((recipe.description ?? '').trim().isNotEmpty) ...[
              pw.SizedBox(height: 12),
              _sectionTitle('Mô tả'),
              pw.Text(
                recipe.description!.trim(),
                style: pw.TextStyle(
                  fontSize: 11,
                  lineSpacing: 3,
                  color: PdfColors.grey800,
                ),
              ),
            ],
            if (recipe.categories?.isNotEmpty ?? false) ...[
              pw.SizedBox(height: 12),
              _sectionTitle('Danh mục'),
              pw.Text(
                recipe.categories!
                    .map((category) => category.description?.trim() ?? '')
                    .where((name) => name.isNotEmpty)
                    .join(', '),
                style: pw.TextStyle(
                  fontSize: 11,
                  lineSpacing: 3,
                  color: PdfColors.grey800,
                ),
              ),
            ],
            pw.SizedBox(height: 14),
            _buildIngredientsAndNutrition(recipe, nutrition),
            pw.SizedBox(height: 14),
            _sectionTitle('Các bước thực hiện'),
            _buildSteps(steps, stepImages),
            if ((recipe.videoUrl ?? '').trim().isNotEmpty) ...[
              pw.SizedBox(height: 12),
              _sectionTitle('Video hướng dẫn'),
              pw.Text(
                recipe.videoUrl!.trim(),
                style: pw.TextStyle(fontSize: 11, color: PdfColors.blue700),
              ),
            ],
            if (recipeUrl != null) ...[
              pw.SizedBox(height: 14),
              _sectionTitle('QR công thức'),
              _buildRecipeQr(recipeUrl),
            ],
          ],
        ),
      );

      final bytes = await document.save();
      debugPrint('[RecipePdf] PDF saved. bytes=${bytes.length}');
      return bytes;
    } catch (error, stackTrace) {
      debugPrint('[RecipePdf] Generate PDF failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    } finally {
      disablePdfDebug();
    }
  }

  Future<pw.ImageProvider?> _loadNetworkImage(String? imageUrl) async {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      debugPrint('[RecipePdf] Skip image: invalid url=$url');
      return null;
    }

    try {
      if (uri.scheme == 'http' || uri.scheme == 'https') {
        return printing.networkImage(url, cache: true);
      }
    } catch (error, stackTrace) {
      debugPrint('[RecipePdf] Load network image failed: $url');
      debugPrint('[RecipePdf] Error: $error');
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
    for (var index = 0; index < urls.length; index++) {
      final url = urls[index];
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

  Future<NutritionAnalysisModel?> _loadNutrition(int? recipeId) async {
    if (recipeId == null) return null;

    try {
      return await getIt<NutritionRepository>().getNutritionByRecipeId(
        recipeId,
      );
    } catch (error, stackTrace) {
      debugPrint('[RecipePdf] Load nutrition failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  String? _buildRecipeUrl(int? recipeId) {
    if (recipeId == null) return null;
    return '${AppKeys.webDeloyUrl}/recipes/$recipeId';
  }

  pw.Widget _buildCoverImage(pw.ImageProvider image) {
    return pw.Container(
      height: 136,
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.orange100),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Image(image, fit: pw.BoxFit.cover),
    );
  }

  pw.Widget _buildRecipeQr(String recipeUrl) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.orange50,
        border: pw.Border.all(color: PdfColors.orange100),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: recipeUrl,
            width: 88,
            height: 88,
            color: PdfColors.deepOrange700,
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
          'EEFOOD RECIPE',
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.deepOrange500,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          recipe.title,
          style: pw.TextStyle(
            fontSize: 23,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey900,
          ),
        ),
        pw.SizedBox(height: 4),
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
    final region = recipe.region?.trim();

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.orange50,
        border: pw.Border.all(color: PdfColors.orange100),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: _summaryItem('Chuẩn bị', '${recipe.prepTime ?? 0} phút'),
          ),
          _summaryDivider(),
          pw.Expanded(
            child: _summaryItem('Nấu', '${recipe.cookTime ?? 0} phút'),
          ),
          _summaryDivider(),
          pw.Expanded(child: _summaryItem('Tổng', '$totalTime phút')),
          _summaryDivider(),
          pw.Expanded(child: _summaryItem('Độ khó', difficulty)),
          if (region != null && region.isNotEmpty) ...[
            _summaryDivider(),
            pw.Expanded(child: _summaryItem('Vùng', region)),
          ],
        ],
      ),
    );
  }

  pw.Widget _summaryDivider() {
    return pw.Container(
      width: 1,
      height: 30,
      margin: const pw.EdgeInsets.symmetric(horizontal: 8),
      color: PdfColors.orange100,
    );
  }

  pw.Widget _summaryItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          maxLines: 1,
          style: pw.TextStyle(
            fontSize: 8,
            color: PdfColors.deepOrange600,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          value,
          maxLines: 2,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey900,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildIngredientsAndNutrition(
    RecipeDetailModel recipe,
    NutritionAnalysisModel? nutrition,
  ) {
    final showNutrition = nutrition != null && _hasNutritionData(nutrition);

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: showNutrition ? 3 : 1,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [_sectionTitle('Nguyên liệu'), _buildIngredients(recipe)],
          ),
        ),
        if (showNutrition) ...[
          pw.SizedBox(width: 12),
          pw.Expanded(flex: 2, child: _buildNutritionCard(nutrition)),
        ],
      ],
    );
  }

  bool _hasNutritionData(NutritionAnalysisModel nutrition) {
    return [
      nutrition.totalCalories,
      nutrition.totalProtein,
      nutrition.totalFat,
      nutrition.totalCarb,
      nutrition.totalFiber,
      nutrition.totalSugar,
      nutrition.totalCalcium,
      nutrition.totalSodium,
      nutrition.healthScore,
    ].any((value) => value != null);
  }

  pw.Widget _buildNutritionCard(NutritionAnalysisModel nutrition) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(9),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        border: pw.Border.all(color: PdfColors.green100),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Dinh dưỡng',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green800,
            ),
          ),
          pw.SizedBox(height: 7),
          if (nutrition.totalCalories != null)
            _nutritionHighlight(
              _formatNutritionValue(nutrition.totalCalories),
              'kcal',
            ),
          if (nutrition.totalCalories != null) pw.SizedBox(height: 7),
          pw.Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              if (nutrition.totalProtein != null)
                _nutritionChip('Chất đạm', nutrition.totalProtein, 'g'),
              if (nutrition.totalFat != null)
                _nutritionChip('Chất béo', nutrition.totalFat, 'g'),
              if (nutrition.totalCarb != null)
                _nutritionChip('Tinh bột', nutrition.totalCarb, 'g'),
              if (nutrition.totalFiber != null)
                _nutritionChip('Chất xơ', nutrition.totalFiber, 'g'),
              if (nutrition.totalSugar != null)
                _nutritionChip('Đường', nutrition.totalSugar, 'g'),
              if (nutrition.totalCalcium != null)
                _nutritionChip('Canxi', nutrition.totalCalcium, 'g'),
              if (nutrition.totalSodium != null)
                _nutritionChip('Natri', nutrition.totalSodium, 'g'),
            ],
          ),
          if (nutrition.healthScore != null) ...[
            pw.SizedBox(height: 7),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              decoration: pw.BoxDecoration(
                color: PdfColors.green100,
                border: pw.Border.all(color: PdfColors.green100),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Điểm sức khỏe',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.green900,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    _formatNutritionValue(nutrition.healthScore),
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: PdfColors.green900,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _nutritionHighlight(String value, String unit) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: pw.BoxDecoration(
        color: PdfColors.deepOrange600,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(width: 4),
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Text(
              unit,
              style: pw.TextStyle(fontSize: 9, color: PdfColors.orange50),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _nutritionChip(String label, double? value, String unit) {
    return pw.Container(
      width: 68,
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.grey200),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            maxLines: 1,
            style: pw.TextStyle(fontSize: 7, color: PdfColors.green800),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            '${_formatNutritionValue(value)} $unit',
            maxLines: 1,
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey900,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNutritionValue(double? value) {
    if (value == null) return '-';
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
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
          padding: const pw.EdgeInsets.only(bottom: 3),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '• ',
                style: pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.deepOrange500,
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  amount.isEmpty ? name : '$name - $amount',
                  style: pw.TextStyle(fontSize: 11, color: PdfColors.grey900),
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
        final stepTime = step.stepTime == null
            ? ''
            : ' (${step.stepTime} phút)';
        final images =
            stepImages[step.stepNumber] ?? const <pw.ImageProvider>[];

        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 7),
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.orange50,
            border: pw.Border.all(color: PdfColors.orange100),
            borderRadius: pw.BorderRadius.circular(4),
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
              pw.SizedBox(height: 4),
              pw.Text(
                (step.instruction ?? '').trim().isEmpty
                    ? 'Không có mô tả.'
                    : step.instruction!.trim(),
                style: pw.TextStyle(
                  fontSize: 11,
                  lineSpacing: 3,
                  color: PdfColors.grey900,
                ),
              ),
              if (images.isNotEmpty) ...[
                pw.SizedBox(height: 8),
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
              height: 96,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.orange100),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Image(image, fit: pw.BoxFit.cover),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Row(
        children: [
          pw.Container(
            width: 3,
            height: 13,
            decoration: pw.BoxDecoration(
              color: PdfColors.deepOrange500,
              borderRadius: pw.BorderRadius.circular(2),
            ),
          ),
          pw.SizedBox(width: 6),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey900,
            ),
          ),
        ],
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
