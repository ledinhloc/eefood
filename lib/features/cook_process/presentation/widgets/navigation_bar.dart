import 'package:eefood/features/cook_process/presentation/provider/cooking_session_cubit.dart';
import 'package:eefood/features/cook_process/presentation/provider/cooking_session_state.dart';
import 'package:eefood/features/cook_process/presentation/widgets/complete_button.dart';
import 'package:eefood/features/cook_process/presentation/widgets/nav_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationBarCooking extends StatelessWidget {
  final CookingSessionState state;
  final bool isTimerRunning;
  const NavigationBarCooking({
    super.key,
    required this.state,
    this.isTimerRunning = false,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CookingSessionCubit>();
    final isCompleting = state.status == CookingStatus.completing;
    final canGoNext = !isTimerRunning;
    final canComplete = !isTimerRunning;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous
          NavButton(
            icon: Icons.arrow_back_rounded,
            label: 'Trước',
            enabled: !state.isFirstStep,
            outlined: true,
            onTap: cubit.previousStep,
          ),
          const SizedBox(width: 12),

          // Next / Complete
          Expanded(
            child: state.isLastStep
                ? CompleteButton(
                    isLoading: isCompleting,
                    onTap: () => cubit.completeSession(),
                  )
                : NavButton(
                    icon: Icons.arrow_forward_rounded,
                    label: isTimerRunning ? 'Chờ hết giờ' : 'Tiếp theo',
                    enabled: canGoNext,
                    outlined: false,
                    onTap: cubit.nextStep,
                    expanded: true,
                  ),
          ),
        ],
      ),
    );
  }
}
