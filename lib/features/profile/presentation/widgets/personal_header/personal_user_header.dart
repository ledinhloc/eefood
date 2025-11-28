import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/file_upload.dart';
import 'package:eefood/core/utils/media_picker.dart';
import 'package:eefood/core/widgets/custom_bottom_sheet.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/data/models/UserModel.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/profile/domain/usecases/profile_usecase.dart';
import 'package:eefood/features/profile/presentation/provider/profile_cubit.dart';
import 'package:eefood/features/profile/presentation/widgets/personal_header/live_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:eefood/features/profile/presentation/widgets/personal_header/personal_user_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../provider/user_live_status_cubit.dart';

class PersonalUserHeader extends StatefulWidget {
  final User user;
  final bool isScrolled;

  const PersonalUserHeader({
    super.key,
    required this.user,
    this.isScrolled = false,
  });

  @override
  State<PersonalUserHeader> createState() => _PersonalUserHeaderState();
}

class _PersonalUserHeaderState extends State<PersonalUserHeader> {
  late final ProfileCubit _cubit;
  late final UserLiveStatusCubit _liveStatusCubit;

  @override
  void initState() {
    super.initState();
    _cubit = ProfileCubit(getIt<GetCurrentUser>())..loadProfile();

    _liveStatusCubit = getIt<UserLiveStatusCubit>()..checkUserLiveStatus(widget.user.id);
  }

  Future<void> _handleChangeBackground(BuildContext context) async {
    final File? image = await MediaPicker.pickImage();
    if (image == null) return;

    final uploader = getIt<FileUploader>();
    final updateProfile = getIt<UpdateProfile>();
    final url = await uploader.uploadFile(image);

    final result = await updateProfile(
      UserModel(
        id: widget.user.id,
        backgroundUrl: url,
        username: widget.user.username,
        email: widget.user.email,
        role: widget.user.role,
        provider: widget.user.provider,
      ),
    );

    if (result.isSuccess) {
      _cubit.loadProfile();
      showCustomSnackBar(context, 'Đã lưu thông tin thành công');
    } else {
      showCustomSnackBar(context, 'Lưu thất bại!', isError: true);
    }
  }

  Future<void> _handleRemoveBackground(BuildContext context) async {
    final updateProfile = getIt<UpdateProfile>();
    final result = await updateProfile(
      UserModel(
        id: widget.user.id,
        backgroundUrl: "",
        username: widget.user.username,
        email: widget.user.email,
        role: widget.user.role,
        provider: widget.user.provider,
      ),
    );

    if (result.isSuccess) {
      _cubit.loadProfile();
      showCustomSnackBar(context, 'Đã xóa thông tin thành công');
    } else {
      showCustomSnackBar(context, 'Xóa thất bại!', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, User?>(
      bloc: _cubit,
      builder: (context, userState) {
        if (userState == null) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final bgUrl = widget.user.backgroundUrl;
        final hasBackground = bgUrl != null && bgUrl.isNotEmpty;

        return SliverAppBar(
          expandedHeight: 350,
          pinned: true,
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.white,
          stretch: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.orangeAccent),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (userState.id == widget.user.id) ...[
              IconButton(
                icon: const Icon(
                  Icons.image_outlined,
                  color: Colors.orangeAccent,
                ),
                onPressed: () async {
                  await showCustomBottomSheet(context, [
                    BottomSheetOption(
                      icon: const Icon(
                        Icons.file_upload_outlined,
                        color: Colors.greenAccent,
                      ),
                      title: 'Thêm ảnh nền',
                      onTap: () => _handleChangeBackground(context),
                    ),
                    BottomSheetOption(
                      icon: const Icon(
                        Icons.delete_outline_outlined,
                        color: Colors.redAccent,
                      ),
                      title: 'Xóa ảnh nền',
                      onTap: () => _handleRemoveBackground(context),
                    ),
                  ]);
                },
              ),
            ],
            IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: Colors.orangeAccent,
              ),
              onPressed: () {},
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.fadeTitle,
            ],
            titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            centerTitle: true,
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (hasBackground)
                  CachedNetworkImage(imageUrl: bgUrl!, fit: BoxFit.cover)
                else
                  Container(color: Colors.grey[100]),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PersonalUserInfo(user: widget.user),
                      // BlocProvider(
                      //   create: (_) => _liveStatusCubit,
                      //   child: BlocBuilder<UserLiveStatusCubit, UserLiveStatusState>(
                      //     builder: (context, state) {
                      //       return LiveStatusBadge(stream: state.stream);
                      //     },
                      //   ),
                      // ),

                      BlocBuilder<UserLiveStatusCubit, UserLiveStatusState>(
                          bloc: _liveStatusCubit,
                          builder: (context, state){
                            return LiveStatusBadge(stream: state.stream,);
                          },
                      ),
                      const SizedBox(height: 3,),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
