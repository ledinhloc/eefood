import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/cook_process/presentation/provider/cooking_session_cubit.dart';
import 'package:eefood/features/cook_process/presentation/provider/cooking_session_state.dart';
import 'package:eefood/features/cook_process/presentation/widgets/completion_dialog.dart';
import 'package:eefood/features/cook_process/presentation/widgets/mode_picker_scaffold.dart';
import 'package:eefood/features/cook_process/presentation/widgets/step_view_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CookingSessionView extends StatefulWidget {
  final String recipeTitle;
  const CookingSessionView({super.key, required this.recipeTitle});

  @override
  State<CookingSessionView> createState() => _CookingSessionViewState();
}

class _CookingSessionViewState extends State<CookingSessionView> {
  bool? _timerEnabled;
  final SharedPreferences prefs = getIt<SharedPreferences>();

  @override
  void initState() {
    super.initState();
    _loadTimerPref();
  }

  Future<void> _loadTimerPref() async {
    final saved = prefs.getBool(AppKeys.cooking);
    setState(() => _timerEnabled = saved);
  }

  Future<void> _saveTimerPref(bool value) async {
    await prefs.setBool(AppKeys.cooking, value);
    setState(() => _timerEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CookingSessionCubit, CookingSessionState>(
      listener: (context, state) {
        if (state.status == CookingStatus.done) {
          _showCompletionDialog(context);
        }
      },
      builder: (context, state) {
        if (state.status == CookingStatus.loading) {
          return const _LoadingScaffold();
        }
        if (state.status == CookingStatus.error) {
          return _ErrorScaffold(message: state.error ?? 'Lỗi không xác định');
        }

        if (_timerEnabled == null) {
          return ModePickerScaffold(
            recipeTitle: widget.recipeTitle,
            onSelect: _saveTimerPref,
          );
        }

        return StepViewScaffold(
          recipeTitle: widget.recipeTitle,
          state: state,
          timerEnabled: _timerEnabled!,
          onChangMode: () => setState(() => _timerEnabled = null),
        );
      },
    );
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CompletionDialog(
        onDone: () {
          Navigator.of(context).pop(); // close dialog
          Navigator.of(context).pop(); // back to detail
        },
      ),
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35))),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  final String message;
  const _ErrorScaffold({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Text(
          message,
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
      ),
    );
  }
}
