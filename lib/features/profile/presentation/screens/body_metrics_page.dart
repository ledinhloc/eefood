import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/profile/data/models/user_height_response.dart';
import 'package:eefood/features/profile/data/models/user_weight_response.dart';
import 'package:eefood/features/profile/domain/repositories/body_metrics_repository.dart';
import 'package:eefood/features/profile/presentation/provider/body_metrics_cubit.dart';
import 'package:eefood/features/profile/presentation/provider/body_metrics_state.dart';
import 'package:eefood/features/profile/presentation/widgets/metrics_page/body_metric_chart_card.dart';
import 'package:eefood/features/profile/presentation/widgets/metrics_page/body_metric_form_sheet.dart';
import 'package:eefood/features/profile/presentation/widgets/metrics_page/body_metrics_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BodyMetricsPage extends StatelessWidget {
  const BodyMetricsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          BodyMetricsCubit(repository: getIt<BodyMetricsRepository>())
            ..loadAll(),
      child: const _BodyMetricsView(),
    );
  }
}

class _BodyMetricsView extends StatefulWidget {
  const _BodyMetricsView();

  @override
  State<_BodyMetricsView> createState() => _BodyMetricsViewState();
}

class _BodyMetricsViewState extends State<_BodyMetricsView> {
  String _formatMetric(double? value, String unit) {
    if (value == null) return '--';
    final formatted = value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
    return unit.isEmpty ? formatted : '$formatted $unit';
  }

  String _bmiStatus(double? bmi) {
    if (bmi == null) return 'Chưa đủ dữ liệu';
    if (bmi < 18.5) return 'Thiếu cân';
    if (bmi < 25) return 'Bình thường';
    if (bmi < 30) return 'Thừa cân';
    return 'Béo phì';
  }

  Future<void> _refresh() => context.read<BodyMetricsCubit>().loadAll();

  Future<void> _openHeightSheet([UserHeightResponse? item]) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<BodyMetricsCubit>(),
        child: BodyMetricFormSheet.height(item: item),
      ),
    );
  }

  Future<void> _openWeightSheet([UserWeightResponse? item]) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<BodyMetricsCubit>(),
        child: BodyMetricFormSheet.weight(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final pageBackground = isDark
        ? colorScheme.surface
        : const Color(0xFFFFF8F3);
    final actionColor = isDark
        ? const Color(0xFFFFAB6B)
        : const Color(0xFFFF6B35);

    return BlocListener<BodyMetricsCubit, BodyMetricsState>(
      listenWhen: (previous, current) =>
          previous.error != current.error && current.error != null,
      listener: (context, state) {
        showCustomSnackBar(context, state.error!, isError: true);
      },
      child: BlocBuilder<BodyMetricsCubit, BodyMetricsState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: pageBackground,
            appBar: AppBar(
              backgroundColor: pageBackground,
              surfaceTintColor: Colors.transparent,
              title: const Text('Chỉ số cơ thể'),
            ),
            body: Stack(
              children: [
                RefreshIndicator(
                  color: actionColor,
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      if (state.isLoading &&
                          state.heights.isEmpty &&
                          state.weights.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 80),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else ...[
                        BodyMetricsHeader(
                          accentColor: actionColor,
                          weightText: _formatMetric(
                            state.latestWeight?.weightKg,
                            'kg',
                          ),
                          heightText: _formatMetric(
                            state.latestHeight?.heightCm,
                            'cm',
                          ),
                          bmiText: _formatMetric(state.bmi, ''),
                          bmiStatus: _bmiStatus(state.bmi),
                        ),
                        const SizedBox(height: 14),
                        BmiMetricChartCard(
                          accentColor: actionColor,
                          isDark: isDark,
                          heights: state.heights,
                          weights: state.weights,
                          onPointTap: (item) => _openWeightSheet(item),
                        ),
                        const SizedBox(height: 14),
                        WeightMetricChartCard(
                          accentColor: actionColor,
                          weights: state.weights,
                          onAdd: _openWeightSheet,
                          onPointTap: (item) => _openWeightSheet(item),
                        ),
                        const SizedBox(height: 14),
                        HeightMetricChartCard(
                          accentColor: isDark
                              ? const Color(0xFF95D5B2)
                              : const Color(0xFF4CAF50),
                          heights: state.heights,
                          onAdd: _openHeightSheet,
                          onPointTap: (item) => _openHeightSheet(item),
                        ),
                      ],
                    ],
                  ),
                ),
                if (state.isSubmitting)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.12),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
