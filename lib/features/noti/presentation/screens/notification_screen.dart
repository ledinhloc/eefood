import 'package:eefood/app_routes.dart';
import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/deep_link_handler.dart';
import 'package:eefood/core/widgets/overlay_menu.dart';
import 'package:eefood/features/noti/presentation/provider/notification_cubit.dart';
import 'package:eefood/features/noti/presentation/provider/notification_state.dart';
import 'package:eefood/features/noti/presentation/widgets/notification_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final SharedPreferences _sharedPreferences = getIt<SharedPreferences>();
  final _scrollController = ScrollController();
  final LayerLink _layerLink = LayerLink();
  late NotificationCubit cubit;
  OverlayEntry? _overlayEntry;
  late bool _showLottieHint;

  @override
  void initState() {
    super.initState();
    cubit = context.read<NotificationCubit>();
    print('NotificationScreen init cubit hash=${cubit.hashCode}');
    cubit.fetchNotifications();
    cubit.fetchUnreadCount();
    _scrollController.addListener(_onScroll);
    _showLottieHint = _sharedPreferences.getBool(AppKeys.isLoginedIn) ?? false;
    if (_showLottieHint) {
      _showLottieHintTemporarily();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      cubit.fetchNotifications(loadMore: true);
    }
  }

  void _showLottieHintTemporarily() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _showLottieHint = true);
    await Future.delayed(const Duration(seconds: 5));
    if (mounted) setState(() => _showLottieHint = false);
  }

  void _toggleOverlayMenu(BuildContext context) {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }

    final overlayWidget = MenuOverlay(
      items: [
        OverlayMenuItem(
          icon: Icons.mark_email_read,
          title: "Đánh dấu tất cả đã đọc",
          color: Colors.blue,
          onTap: () {
            cubit.markAllAsRead();
            _removeOverlay();
          },
        ),
        OverlayMenuItem(
          icon: Icons.delete_forever,
          title: "Xóa tất cả",
          color: Colors.red,
          onTap: () {
            cubit.deleteAllNotifications();
            _removeOverlay();
          },
        ),
      ],
    );

    _overlayEntry = overlayWidget.buildOverlayEntry(
      context: context,
      layerLink: _layerLink,
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _removeOverlay, // nhấn ra ngoài để đóng overlay
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Notifications",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          actions: [
            CompositedTransformTarget(
              link: _layerLink,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _toggleOverlayMenu(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.notificationSettingScreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                if (state.isLoading && state.notifications.isEmpty) {
                  return const Center(
                    child: SpinKitCircle(color: Colors.orange),
                  );
                }

                if (state.notifications.isEmpty) {
                  return const Center(child: Text("Không có thông báo nào"));
                }

                return RefreshIndicator(
                  onRefresh: () async => cubit.fetchNotifications(),
                  child: ListView.separated(
                    controller: _scrollController,
                    itemCount:
                        state.notifications.length + (state.isLoading ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        const Divider(height: 0, thickness: 0.6),
                    itemBuilder: (context, index) {
                      if (index == state.notifications.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: SpinKitCircle(color: Colors.orange),
                          ),
                        );
                      }
                      final noti = state.notifications[index];

                      return Dismissible(
                        key: ValueKey(noti.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          if (noti.id != null) {
                            cubit.deleteNotification(noti.id!);
                          }
                        },
                        child: NotificationItem(
                          notification: noti,
                          onTap: () {
                            if (noti.isRead == false) {
                              if (noti.id != null) {
                                cubit.markAsRead(noti.id!);
                              }
                            }
                            if (noti.path != null) {
                              DeepLinkHandler.handleDeepLink(noti.path!);
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // Hướng dẫn vuốt trái bằng Lottie
            if (_showLottieHint)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _showLottieHint = false),
                  child: Container(
                    color: Colors.white.withOpacity(0.8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/lotties/swipe_left.json',
                          width: 180,
                          repeat: true,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Vuốt sang trái để xóa",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
