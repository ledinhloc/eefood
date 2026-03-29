import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_daily_summary_response.dart';
import 'package:eefood/features/meal_plan/domain/repository/meal_plan_repository.dart';
import 'package:eefood/features/meal_plan/presentation/provider/meal_plan_cubit.dart';
import 'package:eefood/features/meal_plan/presentation/provider/meal_plan_state.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/daily_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class MealPlanPage extends StatelessWidget {
  const MealPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MealPlanCubit(repository: getIt<MealPlanRepository>())..loadOverview(),
      child: const _MealPlanView(),
    );
  }
}

class _MealPlanView extends StatelessWidget {
  const _MealPlanView();

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatChipDate(DateTime? date) {
    if (date == null) return '--';
    return DateFormat('dd/MM').format(date);
  }

  String _weekdayLabel(DateTime? date) {
    if (date == null) return '';
    return DateFormat('EEE', 'en').format(date);
  }

  String _value(num? value, {String suffix = ''}) {
    if (value == null) return '--';
    final formatted = value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    return '$formatted$suffix';
  }

  bool _sameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryWarm = const Color(0xFFE85D04);
    final accentWarm = const Color(0xFFFFBA08);
    final softCream = const Color(0xFFFFF4E6);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Ke hoach bua an',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: BlocListener<MealPlanCubit, MealPlanState>(
        listenWhen: (previous, current) =>
            previous.error != current.error && current.error != null,
        listener: (context, state) {
          showCustomSnackBar(context, state.error!, isError: true);
        },
        child: BlocBuilder<MealPlanCubit, MealPlanState>(
          builder: (context, state) {
            if (state.isLoading && state.plan == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final plan = state.plan;
            if (plan == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu_outlined,
                        size: 56,
                        color: Colors.orange.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chua co ke hoach an uong hien tai.',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: primaryWarm,
              onRefresh: () => context.read<MealPlanCubit>().loadOverview(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryWarm, accentWarm],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: primaryWarm.withValues(alpha: 0.22),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Ke hoach hien tai',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          plan.goal?.trim().isNotEmpty == true
                              ? plan.goal!.trim()
                              : 'Duy tri bua an can bang moi ngay',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${_formatDate(plan.startDate)} - ${_formatDate(plan.endDate)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (plan.note?.trim().isNotEmpty == true) ...[
                          const SizedBox(height: 14),
                          Text(
                            plan.note!.trim(),
                            style: const TextStyle(
                              color: Colors.white,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: softCream,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF4D7B8)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.today_outlined, color: primaryWarm),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ngay dang chon',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.brown.shade600,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(state.selectedDate),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Tong quan tung ngay',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (state.dailySummaries.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFF2E6D9)),
                      ),
                      child: Text(
                        'Chua co tong hop dinh duong theo ngay cho meal plan hien tai.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  else
                    ...state.dailySummaries.map(
                      (summary) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DailySummaryCard(
                          summary: summary,
                          isSelected:
                              _sameDay(summary.planDate, state.selectedDate),
                          onTap: () {
                            final date = summary.planDate;
                            if (date != null) {
                              context.read<MealPlanCubit>().selectDate(date);
                            }
                          },
                          chipDate: _formatChipDate(summary.planDate),
                          weekday: _weekdayLabel(summary.planDate),
                          caloriesText:
                              _value(summary.calories, suffix: ' kcal'),
                          proteinText: _value(summary.protein, suffix: ' g'),
                          carbsText: _value(summary.carbs, suffix: ' g'),
                          fatText: _value(summary.fat, suffix: ' g'),
                          fiberText: _value(summary.fiber, suffix: ' g'),
                          primaryWarm: primaryWarm,
                          accentWarm: accentWarm,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
