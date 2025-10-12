import 'package:eefood/core/widgets/loading_overlay.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eefood/features/noti/presentation/provider/notification_settings_cubit.dart';
import 'package:eefood/features/noti/presentation/provider/notification_settings_state.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final Map<String, bool> _localSettings = {};

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationSettingsCubit(),
      child: BlocConsumer<NotificationSettingsCubit, NotificationSettingsState>(
        listener: (context, state) {
          if (state.isLoading) {
            LoadingOverlay().show();
          } else {
            LoadingOverlay().hide();
          }
          if (!state.isLoading && state.settings.isNotEmpty) {
            _localSettings.clear();
            for (final s in state.settings) {
              _localSettings[s.type!] = s.enabled!;
            }
          }
        },
        builder: (context, state) {
          final cubit = context.read<NotificationSettingsCubit>();

          if (state.isLoading && state.settings.isEmpty) {
            return const Scaffold(
              body: Center(child: SpinKitCircle(color: Colors.orange)),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Notification Settings'),
              backgroundColor: Colors.transparent,
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(Icons.people_alt, "Social Notifications"),
                  _buildSettingRow('COMMENT', 'Comment on your post'),
                  _buildSettingRow('REACTION', 'Reaction to your post'),
                  _buildSettingRow('FOLLOW', 'When someone follows you'),
                  const SizedBox(height: 16),

                  _buildSectionTitle(
                    Icons.restaurant_menu,
                    "Recipe Notifications",
                  ),
                  _buildSettingRow(
                    'SAVE_RECIPE',
                    'Recipe saved to shopping list',
                  ),
                  _buildSettingRow('SHARE_RECIPE', 'When recipe is shared'),
                  const SizedBox(height: 16),

                  _buildSectionTitle(Icons.settings, "System Notifications"),
                  _buildSettingRow('SYSTEM', 'System updates'),
                  _buildSettingRow('WELCOME', 'Welcome and onboarding tips'),
                  _buildSettingRow('RECOMMEND_RECIPE', 'Recommended recipes'),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: state.isLoading
                          ? null
                          : () async {
                              await cubit.updateSettings(_localSettings);
                              if (context.mounted) {
                                showCustomSnackBar(
                                  context,
                                  'Cập nhật thành công',
                                );
                              }
                            },
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save change'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: Colors.orange.shade600),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );

  Widget _buildSettingRow(String type, String description) {
    final isEnabled = _localSettings[type] ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(description, style: const TextStyle(fontSize: 15)),
          ),
          Switch(
            value: isEnabled,
            activeColor: Colors.orange.shade600,
            onChanged: (value) {
              setState(() {
                _localSettings[type] = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
