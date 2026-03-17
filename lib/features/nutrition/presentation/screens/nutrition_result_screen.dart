import 'dart:io';
import 'dart:math';

import 'package:eefood/features/nutrition/data/models/nutrition_analysis_model.dart';
import 'package:eefood/features/nutrition/presentation/provider/nutrition_cubit.dart';
import 'package:eefood/features/nutrition/presentation/provider/nutrition_state.dart';
import 'package:eefood/features/nutrition/presentation/widgets/display_nutrition/orbital_loading_painter.dart';
import 'package:eefood/features/nutrition/presentation/widgets/nutrition_sections.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NutritionResultScreen extends StatefulWidget {
  final File imageFile;

  const NutritionResultScreen({super.key, required this.imageFile});

  @override
  State<NutritionResultScreen> createState() => _NutritionResultScreenState();
}

class _NutritionResultScreenState extends State<NutritionResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _loadingController;
  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );

    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onSuccess() {
    if (!_contentController.isCompleted) _contentController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF8F8F8);

    return Scaffold(
      backgroundColor: bgColor,
      body: BlocConsumer<NutritionCubit, NutritionState>(
        listener: (_, state) {
          if (state.status == NutritionStatus.success) _onSuccess();
        },
        builder: (_, state) => CustomScrollView(
          physics: state.isLoading
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          slivers: [
            _NutritionSliverAppBar(
              imageFile: widget.imageFile,
              state: state,
              isDark: isDark,
            ),
            if (state.isLoading)
              SliverFillRemaining(
                child: _LoadingView(
                  controller: _loadingController,
                  state: state,
                  isDark: isDark,
                ),
              )
            else if (state.status == NutritionStatus.error)
              SliverFillRemaining(
                child: _ErrorView(error: state.error, isDark: isDark),
              )
            else if (state.status == NutritionStatus.success &&
                state.result != null)
              _ResultSliver(
                data: state.result!,
                isDark: isDark,
                fadeAnimation: _contentFade,
                slideAnimation: _contentSlide,
              )
            else
              const SliverToBoxAdapter(child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

class _NutritionSliverAppBar extends StatelessWidget {
  final File imageFile;
  final NutritionState state;
  final bool isDark;

  const _NutritionSliverAppBar({
    required this.imageFile,
    required this.state,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black38,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(imageFile, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                  stops: [0.4, 1.0],
                ),
              ),
            ),
            if (state.result != null)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Text(
                  state.result!.recipeTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black54)],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  final AnimationController controller;
  final NutritionState state;
  final bool isDark;

  const _LoadingView({
    required this.controller,
    required this.state,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white54 : Colors.black45;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: AnimatedBuilder(
              animation: controller,
              builder: (_, __) => CustomPaint(
                painter: OrbitalLoadingPainter(
                  progress: controller.value,
                  isDark: isDark,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            state.statusMessage ?? l10n.processingNutrition,
            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            state.status == NutritionStatus.uploading
                ? l10n.loadingNutrition
                : l10n.loadingDetectNutrition,
            style: TextStyle(color: subtitleColor, fontSize: 14),
          ),
          const SizedBox(height: 20),
          _BouncingDots(controller: controller),
        ],
      ),
    );
  }
}

class _BouncingDots extends StatelessWidget {
  final AnimationController controller;

  const _BouncingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final t = (controller.value - i * 0.33).clamp(0.0, 1.0);
          final scale = sin(t * pi).clamp(0.0, 1.0);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8 + 4 * scale,
            height: 8 + 4 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF6B00).withOpacity(0.4 + 0.6 * scale),
            ),
          );
        }),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String? error;
  final bool isDark;

  const _ErrorView({this.error, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.failAnalysis,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              error ?? l10n.retryAnalyzeImage,
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 14),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                l10n.retryCapture,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultSliver extends StatelessWidget {
  final NutritionAnalysisModel data;
  final bool isDark;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const _ResultSliver({
    required this.data,
    required this.isDark,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: Column(
            children: [
              const SizedBox(height: 20),
              HealthScoreBanner(data: data, isDark: isDark),
              const SizedBox(height: 20),
              NutritionPieChartSection(data: data, isDark: isDark),
              const SizedBox(height: 20),
              NutrientGridSection(data: data, isDark: isDark),
              const SizedBox(height: 20),
              NutritionSummarySection(data: data, isDark: isDark),
              const SizedBox(height: 20),
              IngredientListSection(data: data, isDark: isDark),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
