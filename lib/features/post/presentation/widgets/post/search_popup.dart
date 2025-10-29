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

  // sample options - bạn có thể lấy động từ backend
  final List<String> _regions = ['Tất cả', 'Hà Nội', 'TP.HCM', 'Đà Nẵng', 'Việt Nam', 'Nhật'];
  final Map<String, String> _difficultyMap = {
    'Tất cả': '',
    'Dễ': 'EASY',
    'Trung bình': 'MEDIUM',
    'Khó': 'HARD',
  };
  late final List<String> _difficulties;
  final List<String> _mealTypes = ['Tất cả', 'Khai vị', 'Món chính', 'Tráng miệng', 'Đồ uống'];
  final List<String> _times = ['Tất cả', '<15p', '<30p', '<1h', '>1h'];
  final List<String> _diets = ['Tất cả', 'Ăn chay', 'Giảm cân', 'Healthy'];

  String _selectedRegion = 'Tất cả';
  String _selectedDifficulty = 'Tất cả';
  String _selectedMealType = 'Tất cả';
  String _selectedTime = 'Tất cả';
  String _selectedDiet = 'Tất cả';
  String _selectedSort = 'Mới nhất';

  // recent searches sample (có thể bind với local storage)
  final List<String> _recent = ['Cơm chiên', 'Món chay', 'Món nhanh'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _difficulties = _difficultyMap.keys.toList();
  }

  @override
  void dispose() {
    _keywordCtl.dispose();
    super.dispose();
  }

  //toa nhom cac lua chon
  Widget _buildChips(List<String> options, String selected, ValueChanged<String> onTap) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: options.map((opt) {
        final selectedFlag = opt == selected;
        return ChoiceChip(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          label: Text(opt, style: TextStyle(color: selectedFlag ? Colors.white : Colors.black87)),
          selected: selectedFlag,
          onSelected: (_) => onTap(opt),
          selectedColor: Colors.redAccent,
          backgroundColor: Colors.grey.shade100,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // header
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 25, right: 12, bottom: 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Tìm kiếm', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // keyword
                    const Text('Từ khoá', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _keywordCtl,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
                        hintText: 'Nhập tên món / nguyên liệu',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // recent
                    BlocBuilder<PostListCubit, PostListState>(
                      builder: (context, state) {
                        final recents = state.recentKeywords;
                        if (recents.isEmpty) return const SizedBox();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Lịch sử tìm kiếm', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: recents.map((r) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _keywordCtl.text = r;
                                      _keywordCtl.selection = TextSelection.fromPosition(
                                        TextPosition(offset: _keywordCtl.text.length),
                                      );
                                    });
                                  },
                                  child: Chip(
                                    label: Text(r),
                                    onDeleted: () => getIt<PostListCubit>().deleteKeyword(r),
                                    deleteIcon: const Icon(Icons.close, size: 16),
                                    deleteIconColor: Colors.redAccent,
                                    backgroundColor: Colors.grey.shade100,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      },
                    ),
                    // region
                    const Text('Lọc theo khu vực', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _buildChips(_regions, _selectedRegion, (v) => setState(() => _selectedRegion = v)),
                    const SizedBox(height: 12),

                    // difficulty
                    const Text('Lọc theo độ khó', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _buildChips(_difficulties, _selectedDifficulty, (v) => setState(() => _selectedDifficulty = v)),
                    const SizedBox(height: 12),

                    // meal type
                    const Text('Loại bữa ăn', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _buildChips(_mealTypes, _selectedMealType, (v) => setState(() => _selectedMealType = v)),
                    const SizedBox(height: 12),

                    // time
                    const Text('Thời gian nấu', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _buildChips(_times, _selectedTime, (v) => setState(() => _selectedTime = v)),
                    const SizedBox(height: 12),

                    // diet
                    const Text('Chế độ ăn', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _buildChips(_diets, _selectedDiet, (v) => setState(() => _selectedDiet = v)),
                    const SizedBox(height: 12),

                    // sort
                    const Text('Sắp xếp theo', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Mới nhất', 'Phổ biến', 'Đánh giá cao', 'Cũ nhất'].map((s) {
                        final sel = s == _selectedSort;
                        return ChoiceChip(
                          label: Text(s, style: TextStyle(color: sel ? Colors.white : Colors.black87)),
                          selected: sel,
                          onSelected: (_) => setState(() => _selectedSort = s),
                          selectedColor: Colors.redAccent,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // footer buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _keywordCtl.text = '';
                        _selectedRegion = 'Tất cả';
                        _selectedDifficulty = 'Tất cả';
                        _selectedMealType = 'Tất cả';
                        _selectedTime = 'Tất cả';
                        _selectedDiet = 'Tất cả';
                        _selectedSort = 'Mới nhất';
                      });
                    },
                    child: const Text('Xoá bộ lọc'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      final filters = <String, dynamic>{
                        'keyword': _keywordCtl.text.trim().isEmpty ? null : _keywordCtl.text.trim(),
                        'region': _selectedRegion == 'Tất cả' ? null : _selectedRegion,
                        'difficulty': _difficultyMap[_selectedDifficulty]?.isEmpty ?? true
                            ? null
                            : _difficultyMap[_selectedDifficulty],
                        'mealType': _selectedMealType == 'Tất cả' ? null : _selectedMealType,
                        'time': _selectedTime == 'Tất cả' ? null : _selectedTime,
                        'diet': _selectedDiet == 'Tất cả' ? null : _selectedDiet,
                        'sort': _selectedSort,
                      };
                      Navigator.of(context).pop(filters);
                    },
                    child: const Text('Áp dụng'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
