import 'package:eefood/app_routes.dart';
import 'package:eefood/features/noti/presentation/provider/notification_cubit.dart';
import 'package:eefood/features/noti/presentation/screens/notification_screen.dart';
import 'package:eefood/features/profile/presentation/provider/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/auth_usecases.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});
  final _logout = getIt<Logout>();

  Future<void> _handlerLogout(BuildContext context, User user) async {
    if (!context.mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận đăng xuất"),
        content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _logout(provider: user.provider, userId: user.id);
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.welcome,
        (route) => true,
      );
    }
  }

  Future<void> _handlerEditProfile(BuildContext context, User user) async {
    final isReload = await Navigator.pushNamed(
      context,
      AppRoutes.editProfile,
      arguments: user,
    );
    if (isReload == true && context.mounted) {
      context.read<ProfileCubit>().loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(getIt<GetCurrentUser>())..loadProfile(),
      child: BlocBuilder<ProfileCubit, User?>(
        builder: (context, user) {
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              title: const Text(
                'Profile',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // --- Phần đầu hồ sơ ---
                Row(
                  children: [
                    UserAvatar(
                      url: user.avatarUrl,
                      isLocal: false,
                      username: user.username,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.personalUser,
                              arguments: {'user': user},
                            ),
                            child: Text(
                              user.username,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Thành viên",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                _handlerEditProfile(context, user);
                              },
                              child: const Text(
                                "Chỉnh sửa",
                                style: TextStyle(fontSize: 12),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async =>
                          await _handlerLogout(context, user),
                      icon: const Icon(
                        Icons.exit_to_app_outlined,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // --- Phần tài khoản ---
                const Text(
                  "Tài khoản",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const ListTile(
                  title: Text("Gói hiện tại"),
                  trailing: Text("Miễn phí"),
                ),

                Card(
                  color: Colors.red[50],
                  child: ListTile(
                    leading: const Icon(Icons.star, color: Colors.red),
                    title: const Text(
                      "Trải nghiệm tất cả tính năng Plus miễn phí trong 7 ngày!",
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.commingSoonPage,
                        arguments: {'featureName': "Tính năng Plus"},
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade200,
                      ),
                      child: const Text("Dùng thử miễn phí"),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  "Quản lý tài khoản",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: const Text("Sở thích món ăn"),
                  subtitle: const Text("Áp dụng cho tab Gợi ý cho bạn"),
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.foodPreference),
                ),

                // const ListTile(
                //   leading: Icon(Icons.restore),
                //   title: Text("Khôi phục giao dịch mua"),
                // ),
                const SizedBox(height: 16),
                const Text(
                  "Hệ thống",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text("Ngôn ngữ"),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.language),
                ),
                ListTile(
                  leading: Icon(Icons.notifications_none),
                  title: Text("Thông báo"),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.notificationSettingScreen,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.brightness_6_outlined),
                  title: Text("Hiển thị"),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.commingSoonPage,
                    arguments: {'featureName': "Hiển thị"},
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  "Hỗ trợ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  leading: Icon(Icons.chat_bubble_outline),
                  title: Text("Góp ý"),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.commingSoonPage,
                    arguments: {'featureName': "Góp ý"},
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.bug_report_outlined),
                  title: Text("Báo lỗi"),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.commingSoonPage,
                    arguments: {'featureName': "Báo lỗi"},
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  "Giới thiệu",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  leading: Icon(Icons.thumb_up_outlined),
                  title: Text("Điều khoản sử dụng"),
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.termOfServicePage),
                ),
                ListTile(
                  leading: Icon(Icons.star_border),
                  title: Text("Đánh giá ứng dụng"),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.commingSoonPage,
                    arguments: {'featureName': "Đánh giá ứng dụng"},
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: 'fab_profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: getIt<NotificationCubit>(),
                      child: const NotificationScreen(),
                    ),
                  ),
                );
              },
              backgroundColor: Colors.orange,
              child: const Icon(Icons.notifications),
            ),
          );
        },
      ),
    );
  }
}
