import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/core/constants/app_constants.dart';
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

  @override
  void initState() {
    super.initState();
    final random = Random();
    backgroundImage = AppConstants.backgroundImages[random.nextInt(AppConstants.backgroundImages.length)];
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
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.black87),
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
            CachedNetworkImage(
              imageUrl: backgroundImage,
              fit: BoxFit.cover,
            ),
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
