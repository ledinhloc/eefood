import 'package:eefood/features/profile/presentation/provider/settings_cubit.dart';
import 'package:eefood/features/profile/presentation/provider/settings_state.dart';
import 'package:eefood/features/profile/presentation/widgets/display_page_widget/font_review_card.dart';
import 'package:eefood/features/profile/presentation/widgets/display_page_widget/font_size_selector.dart';
import 'package:eefood/features/profile/presentation/widgets/display_page_widget/section_header.dart';
import 'package:eefood/features/profile/presentation/widgets/display_page_widget/theme_selector.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DisplayPage extends StatelessWidget {
  const DisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    l10n.display,
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
                      Positioned(
                        top: -30,
                        right: -30,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                theme.colorScheme.secondary.withOpacity(0.1),
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

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  Section: Theme 
                    SectionHeader(title: l10n.theme),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ThemeSelector(currentTheme: state.themeMode),
                    ),

                    const SizedBox(height: 32),

                    // Section: Font Size 
                    SectionHeader(title: l10n.fontSize),

                    // Preview card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FontReviewCard(state: state),
                    ),

                    const SizedBox(height: 16),

                    // Font size options
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FontSizeSelector(currentSize: state.fontSize),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
