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
              title: const Text('Cài đặt thông báo'),
              backgroundColor: Colors.transparent,
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(Icons.people_alt, "Thông báo xã hội"),
                  _buildSettingRow('COMMENT', 'Bình luận về bài viết của bạn'),
                  _buildSettingRow('REACTION', 'Người khác thả cảm xúc vào bài viết của bạn'),
                  _buildSettingRow('FOLLOW', 'Khi có người theo dõi bạn'),
                  const SizedBox(height: 16),

                  _buildSectionTitle(
                    Icons.restaurant_menu,
                    "Thông báo công thức nấu ăn",
                  ),
                  _buildSettingRow(
                    'SAVE_RECIPE',
                    'Khi công thức được lưu vào danh sách mua sắm',
                  ),
                  _buildSettingRow('SHARE_RECIPE', 'Khi công thức được chia sẻ'),
                  const SizedBox(height: 16),

                  _buildSectionTitle(Icons.settings, "Thông báo hệ thống"),
                  _buildSettingRow('SYSTEM', 'Cập nhật hệ thống'),
                  _buildSettingRow('WELCOME', 'Chào mừng và hướng dẫn sử dụng'),
                  _buildSettingRow('RECOMMEND_RECIPE', 'Công thức được đề xuất'),

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
                      label: const Text('Lưu thay đổi'),
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