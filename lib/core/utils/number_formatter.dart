/// Hàm rút gọn hiển thị số lượng kiểu Facebook (1.2k, 2.3M, 1B, ...)
String formatCompactNumber(num number) {
  if (number >= 1000000000) {
    final value = number / 1000000000;
    return value % 1 == 0 ? "${value.toInt()}B" : "${value.toStringAsFixed(1)}B";
  } else if (number >= 1000000) {
    final value = number / 1000000;
    return value % 1 == 0 ? "${value.toInt()}M" : "${value.toStringAsFixed(1)}M";
  } else if (number >= 1000) {
    final value = number / 1000;
    return value % 1 == 0 ? "${value.toInt()}k" : "${value.toStringAsFixed(1)}k";
  } else {
    return number.toStringAsFixed(0);
  }
}
