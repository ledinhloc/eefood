import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/core/constants/app_constants.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/file_upload.dart';
import 'package:eefood/core/utils/media_picker.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/data/models/UserModel.dart';
import 'package:eefood/features/profile/domain/usecases/profile_usecase.dart';
import 'package:flutter/material.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:eefood/features/profile/presentation/widgets/personal_header/personal_user_info.dart';

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
  late final String backgroundImage;
  final UpdateProfile _updateProfile = getIt<UpdateProfile>();
  final _fileUploader = getIt<FileUploader>();
  late String? urlImage;

  @override
  void initState() {
    super.initState();
    final random = Random();
    backgroundImage = AppConstants
        .backgroundImages[random.nextInt(AppConstants.backgroundImages.length)];
  }

  Future<void> _handleChangeBackground() async {
    final File? image = await MediaPicker.pickImage();
    if (image != null) {
      final url = await _fileUploader.uploadFile(image);

      final result = await _updateProfile(
        UserModel(
          id: widget.user.id,
          backgroundUrl: urlImage,
          username: widget.user.username,
          email: widget.user.email,
          role: widget.user.role,
          provider: widget.user.provider,
        ),
      );
      if (url.isNotEmpty) {
        setState(() {
          urlImage = url;
        });
      }
      if (result.isSuccess) {
        showCustomSnackBar(context, 'Đã lưu thông tin thành công');
        Navigator.pop(context, true);
      } else {
        showCustomSnackBar(context, 'Lưu thất bại!', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      stretch: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.orangeAccent),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.image_outlined, color: Colors.orangeAccent),
          onPressed: _handleChangeBackground,
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.orangeAccent),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(imageUrl: backgroundImage, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.white.withOpacity(0.9)],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: PersonalUserInfo(user: widget.user),
            ),
          ],
        ),
      ),
    );
  }
}
