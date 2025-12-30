import 'package:eefood/core/constants/app_constants.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/profile/domain/usecases/profile_usecase.dart';
import 'package:eefood/features/profile/presentation/widgets/preferences/preference_tab_view.dart';
import 'package:flutter/material.dart';

import '../../../auth/data/models/user_model.dart';

class FoodPreferencesPage extends StatefulWidget {
  const FoodPreferencesPage({super.key});

  @override
  State<FoodPreferencesPage> createState() => _FoodPreferencesPageState();
}

class _FoodPreferencesPageState extends State<FoodPreferencesPage>
    with SingleTickerProviderStateMixin {
  final UpdateProfile _updateProfile = getIt<UpdateProfile>();
  final GetCurrentUser _getCurrentUser = getIt<GetCurrentUser>();

  late TabController _tabController;
  Set<String> selectedCuisines = {};
  Set<String> selectedAllergies = {};
  Set<String> selectedDiets = {};
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserPreferences();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPreferences() async {
    setState(() => isLoading = true);
    try {
      final User? user = await _getCurrentUser();
      if (user != null) {
        setState(() {
          selectedCuisines = user.eatingPreferences?.toSet() ?? {};
          selectedAllergies = user.allergies?.toSet() ?? {};
          selectedDiets = user.dietaryPreferences?.toSet() ?? {};
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        showCustomSnackBar(context, 'Không thể tải thông tin', isError: true);
      }
    }
  }

  Future<void> _savePreferences() async {
    if (isSaving) return;

    setState(() => isSaving = true);
    try {
      final User? user = await _getCurrentUser();
      if (user == null) {
        throw Exception('User not found');
      }

      final request = UserModel(
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
        provider: user.provider,
        eatingPreferences: selectedCuisines.toList(),
        allergies: selectedAllergies.toList(),
        dietaryPreferences: selectedDiets.toList(),
      );

      final result = await _updateProfile(request);
      if (mounted) {
        if (result.isSuccess) {
          showCustomSnackBar(context, 'Đã lưu thành công! ✨');
          Navigator.pop(context, true);
        } else {
          showCustomSnackBar(context, 'Lưu thất bại!', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, 'Có lỗi xảy ra!', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  void _onCuisineToggle(String item) {
    setState(() {
      if (selectedCuisines.contains(item)) {
        selectedCuisines.remove(item);
      } else {
        selectedCuisines.add(item);
      }
    });
  }

  void _onAllergyToggle(String item) {
    setState(() {
      if (selectedAllergies.contains(item)) {
        selectedAllergies.remove(item);
      } else {
        selectedAllergies.add(item);
      }
    });
  }

  void _onDietToggle(String item) {
    setState(() {
      if (selectedDiets.contains(item)) {
        selectedDiets.remove(item);
      } else {
        selectedDiets.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Sở thích món ăn',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: const Color(0xFF1A1A1A),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFFF6B35),
              unselectedLabelColor: const Color(0xFF8E8E93),
              indicatorColor: const Color(0xFFFF6B35),
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              tabs: const [
                Tab(text: 'Món ăn'),
                Tab(text: 'Dị ứng'),
                Tab(text: 'Chế độ'),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      PreferenceTabView(
                        title: 'Món ăn yêu thích',
                        subtitle: 'Chọn món ăn bạn thích để nhận gợi ý phù hợp',
                        icon: '🍽️',
                        items: AppConstants.cuisines,
                        selectedItems: selectedCuisines,
                        onToggle: _onCuisineToggle,
                        accentColor: const Color(0xFFFF6B35),
                      ),
                      PreferenceTabView(
                        title: 'Dị ứng thực phẩm',
                        subtitle: 'Những thực phẩm bạn cần tránh',
                        icon: '⚠️',
                        items: AppConstants.allergies,
                        selectedItems: selectedAllergies,
                        onToggle: _onAllergyToggle,
                        accentColor: const Color(0xFFFF3B30),
                      ),
                      PreferenceTabView(
                        title: 'Chế độ ăn',
                        subtitle: 'Chế độ ăn phù hợp với lối sống',
                        icon: '🥗',
                        items: AppConstants.diets,
                        selectedItems: selectedDiets,
                        onToggle: _onDietToggle,
                        accentColor: const Color(0xFF34C759),
                      ),
                    ],
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildBottomBar() {
    final totalSelected =
        selectedCuisines.length +
        selectedAllergies.length +
        selectedDiets.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Đã chọn',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$totalSelected mục',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isSaving ? null : _savePreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: const Color(0xFFE5E5EA),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_rounded, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Lưu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
