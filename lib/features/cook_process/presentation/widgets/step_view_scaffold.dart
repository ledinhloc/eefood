import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/cook_process/presentation/provider/cooking_session_cubit.dart';
import 'package:eefood/features/cook_process/presentation/provider/cooking_session_state.dart';
import 'package:eefood/features/cook_process/presentation/widgets/cooking_app_bar.dart';
import 'package:eefood/features/cook_process/presentation/widgets/exit_confirm_dialog.dart';
import 'package:eefood/features/cook_process/presentation/widgets/navigation_bar.dart';
import 'package:eefood/features/cook_process/presentation/widgets/progress_bar.dart';
import 'package:eefood/features/cook_process/presentation/widgets/step_info/step_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepViewScaffold extends StatefulWidget {
  final String recipeTitle;
  final CookingSessionState state;
  final bool timerEnabled;
  final VoidCallback onChangMode;

  const StepViewScaffold({
    super.key,
    required this.recipeTitle,
    required this.state,
    required this.timerEnabled,
    required this.onChangMode,
  });

  @override
  State<StepViewScaffold> createState() => _StepViewScaffoldState();
}

class _StepViewScaffoldState extends State<StepViewScaffold> {
  bool _isTimerRunning = false;
  bool _isDialogShowing = false;
  SharedPreferences prefs = getIt<SharedPreferences>();

  @override
  void didUpdateWidget(StepViewScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.currentStepIndex != widget.state.currentStepIndex) {
      _isTimerRunning = false;
    }
  }

  void _handleTimerRunningChanged(bool running) {
    setState(() => _isTimerRunning = running);
  }

  Future<void> _handleBack(BuildContext context) async {
    if (_isDialogShowing) return;

    final cubit = context.read<CookingSessionCubit>();

    _isDialogShowing = true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const ExitConfirmDialog(),
    );
    _isDialogShowing = false;

    if (confirmed == true) {
      await prefs.setBool(AppKeys.cooking, false);
      await cubit.saveProgress();
      if (context.mounted) {
        Future.microtask(() {
          Navigator.pop(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final currentStep = state.currentStep;
    final total = state.steps.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8F0),
        body: SafeArea(
          child: Column(
            children: [
              CookingAppBar(
                recipeTitle: widget.recipeTitle,
                currentIndex: state.currentStepIndex,
                total: total,
                onBack: () => _handleBack(context),
                onChangeMode: widget.onChangMode,
              ),
              ProgressBar(current: state.currentStepIndex + 1, total: total),
              Expanded(
                child: currentStep == null
                    ? const Center(child: Text('Không có bước nào'))
                    : StepContent(
                        key: ValueKey(state.currentStepIndex),
                        step: currentStep,
                        timerEnabled: widget.timerEnabled,
                        onTimerRunningChanged: _handleTimerRunningChanged,
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBarCooking(
          state: state,
          isTimerRunning: _isTimerRunning,
        ),
      ),
    );
  }
}
