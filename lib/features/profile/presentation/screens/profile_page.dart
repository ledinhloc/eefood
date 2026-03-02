import 'package:eefood/app_routes.dart';
import 'package:eefood/features/noti/presentation/provider/notification_cubit.dart';
import 'package:eefood/features/noti/presentation/screens/notification_screen.dart';
import 'package:eefood/features/profile/presentation/provider/profile_cubit.dart';
import 'package:eefood/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.logout),
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
          final l10n = AppLocalizations.of(context)!;
          final theme = Theme.of(context);
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              title: Text(
                l10n.profileTitle,
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
                            l10n.memberLabel,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                _handlerEditProfile(context, user);
                              },
                              child: Text(
                                l10n.editProfile,
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
                Text(
                  l10n.accountTitle,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: Text(l10n.currentPlan),
                  trailing: Text(l10n.freePlan),
                ),

                Card(
                  color: Colors.red[50],
                  child: ListTile(
                    leading: const Icon(Icons.star, color: Colors.red),
                    title: Text(l10n.tryPlusTitle),
                    trailing: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.commingSoonPage,
                        arguments: {'featureName': "Tính năng Plus"},
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade200,
                      ),
                      child: Text(l10n.tryPlusButton),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  l10n.manageAccount,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: Text(l10n.foodPreference),
                  subtitle: Text(l10n.foodPreferenceHint),
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.foodPreference),
                ),

                // const ListTile(
                //   leading: Icon(Icons.restore),
                //   title: Text("Khôi phục giao dịch mua"),
                // ),
                const SizedBox(height: 16),
                Text(
                  l10n.system,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.language),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.language),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_none),
                  title: Text(l10n.notifications),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.notificationSettingScreen,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.brightness_6_outlined),
                  title: Text(l10n.display),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.display),
                ),

                const SizedBox(height: 16),
                Text(
                  l10n.support,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  leading: Icon(Icons.chat_bubble_outline),
                  title: Text(l10n.feedback),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.commingSoonPage,
                    arguments: {'featureName': l10n.feedback},
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.bug_report_outlined),
                  title: Text(l10n.reportBug),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.commingSoonPage,
                    arguments: {'featureName': l10n.reportBug},
                  ),
                ),

                const SizedBox(height: 16),
                Text(l10n.about, style: TextStyle(fontWeight: FontWeight.bold)),
                ListTile(
                  leading: Icon(Icons.thumb_up_outlined),
                  title: Text(l10n.termsOfService),
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.termOfServicePage),
                ),
                ListTile(
                  leading: Icon(Icons.star_border),
                  title: Text(l10n.rateApp),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.commingSoonPage,
                    arguments: {'featureName': l10n.rateApp},
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
