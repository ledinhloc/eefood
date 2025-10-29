import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_keys.dart';

class SearchRepository {
  /// Lấy danh sách từ khóa gần đây
  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(AppKeys.recentKey) ?? [];
  }

  /// Lưu một từ khóa mới
  Future<void> saveSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList(AppKeys.recentKey) ?? [];

    // loại trùng & đưa keyword lên đầu
    recent.remove(keyword);
    recent.insert(0, keyword);
    if (recent.length > 10) recent.removeLast();

    await prefs.setStringList(AppKeys.recentKey, recent);
  }

  /// Xóa một từ khóa
  Future<void> deleteSearch(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList(AppKeys.recentKey) ?? [];
    recent.remove(keyword);
    await prefs.setStringList(AppKeys.recentKey, recent);
  }

  /// Xóa toàn bộ
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppKeys.recentKey);
  }
}
