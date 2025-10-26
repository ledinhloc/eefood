import 'package:flutter/material.dart';

class SearchPopup extends StatefulWidget {
  const SearchPopup({super.key});

  @override
  State<SearchPopup> createState() => _SearchPopupState();
}

class _SearchPopupState extends State<SearchPopup> {
  final TextEditingController _keywordCtrl = TextEditingController();
  String? _region;
  String? _difficulty;
  String? _sortBy = 'createdAt';
  bool showAdvanced = false;

  final List<String> regions = ['Bắc', 'Trung', 'Nam'];
  final List<String> difficulties = ['Dễ', 'Trung bình', 'Khó'];
  final List<Map<String, String>> sortOptions = [
    {'key': 'createdAt', 'label': 'Ngày đăng'},
    {'key': 'popularity', 'label': 'Độ phổ biến'},
    {'key': 'favorites', 'label': 'Độ yêu thích'},
  ];

  void _search() {
    Navigator.pop(context, {
      'keyword': _keywordCtrl.text,
      'region': _region,
      'difficulty': _difficulty,
      'sortBy': _sortBy,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh tìm kiếm chính
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _keywordCtrl,
                      decoration: InputDecoration(
                        hintText: 'Tìm bài viết, công thức...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      showAdvanced
                          ? Icons.expand_less_rounded
                          : Icons.tune_rounded,
                    ),
                    onPressed: () => setState(() => showAdvanced = !showAdvanced),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (showAdvanced) ...[
                // Region
                DropdownButtonFormField<String>(
                  value: _region,
                  hint: const Text('Chọn vùng miền'),
                  items: regions
                      .map((r) =>
                      DropdownMenuItem(value: r, child: Text('Miền $r')))
                      .toList(),
                  onChanged: (val) => setState(() => _region = val),
                ),
                const SizedBox(height: 8),
                // Difficulty
                DropdownButtonFormField<String>(
                  value: _difficulty,
                  hint: const Text('Chọn độ khó'),
                  items: difficulties
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (val) => setState(() => _difficulty = val),
                ),
                const SizedBox(height: 8),
                // Sort by
                DropdownButtonFormField<String>(
                  value: _sortBy,
                  hint: const Text('Sắp xếp theo'),
                  items: sortOptions
                      .map((s) => DropdownMenuItem(
                      value: s['key'], child: Text(s['label']!)))
                      .toList(),
                  onChanged: (val) => setState(() => _sortBy = val),
                ),
                const SizedBox(height: 16),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _search,
                  icon: const Icon(Icons.search),
                  label: const Text('Tìm kiếm'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
