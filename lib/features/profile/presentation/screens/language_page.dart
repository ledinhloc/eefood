import 'package:eefood/features/profile/presentation/provider/settings_cubit.dart';
import 'package:eefood/features/profile/presentation/provider/settings_state.dart';
import 'package:eefood/features/profile/presentation/widgets/language_widget/language_title.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              // ── App Bar đẹp ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    l10n.language,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      letterSpacing: -0.5,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // decorative gradient
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                theme.colorScheme.primary.withOpacity(0.12),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: theme.colorScheme.onSurface,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // ── Subtitle ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  child: Text(
                    'Chọn ngôn ngữ hiển thị trong ứng dụng',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── Language Options ─────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    LanguageTitle(
                      language: AppLanguage.vi,
                      label: l10n.languageVietnamese,
                      nativeLabel: 'Tiếng Việt',
                      flag: '🇻🇳',
                      isSelected: state.language == AppLanguage.vi,
                      onTap: () => context.read<SettingsCubit>().changeLanguage(
                        AppLanguage.vi,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LanguageTitle(
                      language: AppLanguage.en,
                      label: l10n.languageEnglish,
                      nativeLabel: 'English',
                      flag: '🇬🇧',
                      isSelected: state.language == AppLanguage.en,
                      onTap: () => context.read<SettingsCubit>().changeLanguage(
                        AppLanguage.en,
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
