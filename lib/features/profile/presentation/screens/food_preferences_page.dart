import 'package:eefood/core/constants/app_constants.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/profile/domain/usecases/profile_usecase.dart';
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

  bool get hasChanges {
    // Check if there are any changes to save
    return selectedCuisines.isNotEmpty ||
        selectedAllergies.isNotEmpty ||
        selectedDiets.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Sở thích món ăn',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.orange,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Món ăn'),
                Tab(text: 'Dị ứng'),
                Tab(text: 'Chế độ ăn'),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCuisineTab(),
                      _buildAllergyTab(),
                      _buildDietTab(),
                    ],
                  ),
                ),
                _buildBottomActionBar(),
              ],
            ),
    );
  }

  Widget _buildCuisineTab() {
    return _buildPreferenceList(
      title: 'Chọn món ăn yêu thích',
      description: 'Chọn các món ăn mà bạn thích để nhận gợi ý phù hợp hơn',
      icon: Icons.restaurant_menu,
      items: AppConstants.cuisines,
      selectedItems: selectedCuisines,
      onChanged: (item) {
        setState(() {
          if (selectedCuisines.contains(item)) {
            selectedCuisines.remove(item);
          } else {
            selectedCuisines.add(item);
          }
        });
      },
      emptyMessage: 'Chưa chọn món ăn nào',
    );
  }

  Widget _buildAllergyTab() {
    return _buildPreferenceList(
      title: 'Dị ứng & Hạn chế',
      description: 'Cho chúng tôi biết những thực phẩm bạn cần tránh',
      icon: Icons.warning_amber_rounded,
      items: AppConstants.allergies,
      selectedItems: selectedAllergies,
      onChanged: (item) {
        setState(() {
          if (selectedAllergies.contains(item)) {
            selectedAllergies.remove(item);
          } else {
            selectedAllergies.add(item);
          }
        });
      },
      emptyMessage: 'Không có dị ứng nào',
      color: Colors.red,
    );
  }

  Widget _buildDietTab() {
    return _buildPreferenceList(
      title: 'Chế độ ăn uống',
      description: 'Chọn chế độ ăn uống phù hợp với lối sống của bạn',
      icon: Icons.eco,
      items: AppConstants.diets,
      selectedItems: selectedDiets,
      onChanged: (item) {
        setState(() {
          if (selectedDiets.contains(item)) {
            selectedDiets.remove(item);
          } else {
            selectedDiets.add(item);
          }
        });
      },
      emptyMessage: 'Chưa chọn chế độ ăn nào',
      color: Colors.green,
    );
  }

  Widget _buildPreferenceList({
    required String title,
    required String description,
    required IconData icon,
    required List<Map<String, String>> items,
    required Set<String> selectedItems,
    required Function(String) onChanged,
    required String emptyMessage,
    Color color = Colors.orange,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header Card
        Card(
          elevation: 0,
          color: color.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Selected Count
        if (selectedItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${selectedItems.length} đã chọn',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Items Grid
        ...items.map((item) {
          final itemName = item['name'] ?? '';
          final itemEmoji = item['emoji'] ?? '';
          final isSelected = selectedItems.contains(itemName);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onChanged(itemName),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.15) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : Colors.grey.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? color : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      if (itemEmoji.isNotEmpty) ...[
                        Text(itemEmoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          itemName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.grey[800]
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Summary
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tổng đã chọn',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${selectedCuisines.length + selectedAllergies.length + selectedDiets.length} mục',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Save Button
            SizedBox(
              width: 140,
              height: 50,
              child: ElevatedButton(
                onPressed: isSaving ? null : _savePreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Lưu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
