import 'package:eefood/app_routes.dart';
import 'package:eefood/core/utils/speech_helper.dart';
import 'package:eefood/features/post/presentation/widgets/post/toggle_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../provider/post_list_cubit.dart';

class SearchPopup extends StatefulWidget {
  const SearchPopup({super.key});

  @override
  State<SearchPopup> createState() => _SearchPopupState();
}

class _SearchPopupState extends State<SearchPopup> {
  final TextEditingController _keywordCtl = TextEditingController();

  final List<String> _regions = [
    'Hà Nội',
    'TP.HCM',
    'Đà Nẵng',
    'Việt Nam',
    'Nhật',
    'Châu Âu',
  ];
  final Map<String, String> _difficultyMap = {
    'Dễ': 'EASY',
    'Trung bình': 'MEDIUM',
    'Khó': 'HARD',
  };
  final List<String> _categories = [
    'Món tết',
    'Món chính',
    'Món ăn sáng',
    'Món đường phố',
    'Các loại bánh',
    'Món ngon hàng ngày',
  ];

  // Các giá trị đã chọn (nullable - null = chưa chọn)
  String? _selectedRegion;
  String? _selectedDifficulty;
  String? _selectedCategory;
  int? _selectedMaxCookTime; // tính bằng phút

  // Cooking time options với giá trị số
  final Map<String, int> _cookTimeMap = {
    'Dưới 15 phút': 15,
    'Dưới 30 phút': 30,
    'Dưới 1 giờ': 60,
    'Trên 1 giờ': 9999999,
  };

  @override
  void initState() {
    super.initState();
    final currentState = context.read<PostListCubit>().state;
    _keywordCtl.text = currentState.keyword ?? '';
    _selectedRegion = currentState.region;
    _selectedDifficulty = currentState.difficulty == null
        ? null
        : _difficultyMap.entries
              .firstWhere((e) => e.value == currentState.difficulty)
              .key;
    _selectedCategory = currentState.category;
    _selectedMaxCookTime = currentState.maxCookTime;
  }

  @override
  void dispose() {
    _keywordCtl.dispose();
    super.dispose();
  }

  // method để điền keyword vào ô tìm kiếm =====
  void _fillKeywordFromHistory(String keyword) {
    setState(() {
      _keywordCtl.text = keyword;
      _keywordCtl.selection = TextSelection.fromPosition(
        TextPosition(offset: keyword.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: SizedBox(
        width: double.infinity,
        // ===== Giảm chiều cao để không bị overflow =====
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // ===== HEADER (giữ nguyên) =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surface
                    : const Color(0xFFFFF3EB),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bộ lọc tìm kiếm',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                    iconSize: 24,
                  ),
                ],
              ),
            ),

            // ===== BODY =====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== KEYWORD =====
                    _buildSectionTitle('🔍 Từ khóa', theme),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _keywordCtl,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 22,
                          color: theme.colorScheme.onSurface,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Voice search
                            IconButton(
                              icon: const Icon(Icons.mic, size: 22),
                              color: Colors.orange.shade700,
                              onPressed: () async {
                                final helper = SpeechHelper();
                                final keyword = await helper.listenOnceWithUI(
                                  context,
                                );
                                if (keyword != null && context.mounted) {
                                  setState(() => _keywordCtl.text = keyword);
                                }

                                final filters = <String, dynamic>{
                                  'keyword': _keywordCtl.text.trim().isEmpty
                                      ? null
                                      : _keywordCtl.text.trim(),
                                  'region': _selectedRegion,
                                  'difficulty': _selectedDifficulty != null
                                      ? _difficultyMap[_selectedDifficulty]
                                      : null,
                                  'category': _selectedCategory,
                                  'maxCookTime': _selectedMaxCookTime,
                                };
                                Navigator.of(context).pop(filters);
                              },
                            ),
                            // Image search
                            IconButton(
                              icon: const Icon(
                                Icons.camera_alt_rounded,
                                size: 22,
                              ),
                              color: Colors.orange.shade700,
                              onPressed: () async {
                                await Navigator.pushNamed(
                                  context,
                                  AppRoutes.imageChoiceScreen,
                                );
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                        hintText: 'Nhập tên món, nguyên liệu...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: false,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: const Color.fromARGB(255, 25, 15, 15)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.orange.shade400,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ===== RECENT SEARCHES =====
                    BlocBuilder<PostListCubit, PostListState>(
                      builder: (context, state) {
                        final recents = state.recentKeywords;
                        if (recents.isEmpty) return const SizedBox();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSectionTitle(
                                  '🕒 Tìm kiếm gần đây',
                                  theme,
                                ),
                                TextButton(
                                  onPressed: () {
                                    getIt<PostListCubit>().clearAllKeywords();
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Xóa tất cả',
                                    style: TextStyle(
                                      color: Colors.red.shade400,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6, // Giảm từ 8 → 6
                              runSpacing: 6,
                              children: recents.map((keyword) {
                                return GestureDetector(
                                  // Thêm onTap để fill keyword =====
                                  onTap: () => _fillKeywordFromHistory(keyword),
                                  child: Chip(
                                    label: Text(
                                      keyword,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    onDeleted: () => getIt<PostListCubit>()
                                        .deleteKeyword(keyword),
                                    deleteIcon: const Icon(
                                      Icons.close,
                                      size: 14,
                                    ),
                                    deleteIconColor: Colors.red.shade400,
                                    backgroundColor: Colors.blue.shade50,
                                    side: BorderSide(
                                      color: Colors.blue.shade200,
                                    ),
                                    labelStyle: TextStyle(
                                      color: Colors.blue.shade900,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16), // Giảm từ 24 → 16
                          ],
                        );
                      },
                    ),

                    // ===== REGION =====
                    _buildSectionTitle('🌍 Khu vực', theme),
                    const SizedBox(height: 8), // Giảm từ 12 → 8
                    ToggleChips(
                      options: _regions,
                      selected: _selectedRegion,
                      onTap: (v) => setState(() => _selectedRegion = v),
                    ),
                    const SizedBox(height: 16), // Giảm từ 24 → 16
                    // ===== DIFFICULTY =====
                    _buildSectionTitle(' Độ khó', theme),
                    const SizedBox(height: 8),
                    ToggleChips(
                      options: _difficultyMap.keys.toList(),
                      selected: _selectedDifficulty,
                      onTap: (v) => setState(() => _selectedDifficulty = v),
                    ),
                    const SizedBox(height: 16),

                    // ===== CATEGORY =====
                    _buildSectionTitle(' Danh mục', theme),
                    const SizedBox(height: 8),
                    ToggleChips(
                      options: _categories,
                      selected: _selectedCategory,
                      onTap: (v) => setState(() => _selectedCategory = v),
                    ),
                    const SizedBox(height: 16),

                    // ===== COOK TIME =====
                    _buildSectionTitle('⏱️ Thời gian nấu', theme),
                    const SizedBox(height: 8),
                    ToggleChips(
                      options: _cookTimeMap.keys.toList(),
                      selected:
                          _cookTimeMap.entries
                              .firstWhere(
                                (e) => e.value == _selectedMaxCookTime,
                                orElse: () => const MapEntry('', 0),
                              )
                              .key
                              .isNotEmpty
                          ? _cookTimeMap.entries
                                .firstWhere(
                                  (e) => e.value == _selectedMaxCookTime,
                                )
                                .key
                          : null,
                      onTap: (label) {
                        setState(() {
                          _selectedMaxCookTime = label != null
                              ? _cookTimeMap[label]
                              : null;
                        });
                      },
                    ),
                    const SizedBox(height: 8), // Giảm từ 12 → 8
                  ],
                ),
              ),
            ),

            // ===== FOOTER BUTTONS =====
            Container(
              padding: const EdgeInsets.all(12), // Giảm từ 16 → 12
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Reset button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _keywordCtl.clear();
                          _selectedRegion = null;
                          _selectedDifficulty = null;
                          _selectedCategory = null;
                          _selectedMaxCookTime = null;
                        });
                        context.read<PostListCubit>().resetFilters();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Đặt lại'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Apply button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final filters = <String, dynamic>{
                          'keyword': _keywordCtl.text.trim().isEmpty
                              ? null
                              : _keywordCtl.text.trim(),
                          'region': _selectedRegion,
                          'difficulty': _selectedDifficulty != null
                              ? _difficultyMap[_selectedDifficulty]
                              : null,
                          'category': _selectedCategory,
                          'maxCookTime': _selectedMaxCookTime,
                        };
                        Navigator.of(context).pop(filters);
                      },
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Áp dụng'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15, // Giảm từ 16 → 15
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}
