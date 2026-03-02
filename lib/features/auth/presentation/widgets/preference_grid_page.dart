import 'package:eefood/features/auth/presentation/bloc/on_boarding_bloc/on_boarding_cubit.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PreferenceGridPage extends StatefulWidget {
  final String title;
  final String description;
  final List<Map<String, dynamic>> items;
  final Set<String> initialSelection;
  final Function(Set<String>) onSelectionComplete;
  final Function() onSkip;
  final String? continueButtonText;
  final bool showSkipButton;

  const PreferenceGridPage({
    super.key,
    required this.title,
    required this.description,
    required this.items,
    required this.initialSelection,
    required this.onSelectionComplete,
    required this.onSkip,
    this.continueButtonText,
    this.showSkipButton = true,
  });

  @override
  State<PreferenceGridPage> createState() => _PreferenceGridPageState();
}

class _PreferenceGridPageState extends State<PreferenceGridPage> {
  late Set<String> selectedItems;

  @override
  void initState() {
    super.initState();
    selectedItems = Set<String>.from(widget.initialSelection);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar
              BlocBuilder<OnBoardingCubit, int>(
                builder: (context, currentPage) {
                  final totalPages = context.read<OnBoardingCubit>().totalPages;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: currentPage / totalPages,
                      minHeight: 8,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      color: Colors.red,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(widget.description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 20),

              // Grid
              Expanded(
                child: GridView.builder(
                  itemCount: widget.items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isSelected = selectedItems.contains(item["name"]);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedItems.remove(item["name"]);
                          } else {
                            selectedItems.add(item["name"]);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? Colors.red
                                : theme.colorScheme.outlineVariant,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item["icon"],
                              style: const TextStyle(fontSize: 30),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item["name"],
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Buttons
              Row(
                children: [
                  if (widget.showSkipButton)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onSkip,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: Text(
                          l10n.skip, // key: skip
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  if (widget.showSkipButton) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onSelectionComplete(selectedItems);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        widget.continueButtonText ??
                            l10n.continueButton, // key: continueButton
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
