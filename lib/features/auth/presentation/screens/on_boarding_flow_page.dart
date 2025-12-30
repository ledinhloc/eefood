import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/auth/presentation/bloc/on_boarding_bloc/on_boarding_cubit.dart';
import 'package:eefood/features/auth/presentation/screens/allergy_page.dart';
import 'package:eefood/features/auth/presentation/screens/cuisine_preference_page.dart';
import 'package:eefood/features/auth/presentation/screens/dietary_preference_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnBoardingFlowPage extends StatefulWidget {
  const OnBoardingFlowPage({super.key});

  @override
  State<OnBoardingFlowPage> createState() => _OnBoardingFlowPageState();
}

class _OnBoardingFlowPageState extends State<OnBoardingFlowPage> {
  Set<String> selectedCuisines = {};
  Set<String> selectedAllergies = {};
  final SetFirstLogin _setFirstLogin = getIt<SetFirstLogin>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnBoardingCubit, int>(
      builder: (context, currentPage) {
        if (currentPage == 1) {
          return CuisinePreferencePage(
            onSelectionComplete: (cuisines) {
              selectedCuisines = cuisines;
              context.read<OnBoardingCubit>().nextPage();
            },
          );
        } else if (currentPage == 2) {
          return AllergyPage(
            selectedCuisines: selectedCuisines,
            onSelectionComplete: (allergies) {
              selectedAllergies = allergies;
              context.read<OnBoardingCubit>().nextPage();
            },
          );
        } else if (currentPage == 3) {
          return DietaryPreferencePage(
            selectedCuisines: selectedCuisines,
            selectedAllergies: selectedAllergies,
            onComplete: () {
              _setFirstLogin(true);
              Navigator.pushReplacementNamed(context, AppRoutes.main);
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
