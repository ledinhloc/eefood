class TimeParser {
  /// Chuyển chuỗi cook time thành số phút
  static int fromString(String value) {
    int minutes = 0;

    if (value == '2+ hours') return 120;

    if (value.contains('hour')) {
      final parts = value.split(' ');
      for (int i = 0; i < parts.length; i++) {
        if (parts[i] == 'hour' || parts[i] == 'hours') {
          minutes += int.tryParse(parts[i - 1]) ?? 0 * 60;
        } else if (parts[i] == 'min') {
          minutes += int.tryParse(parts[i - 1]) ?? 0;
        }
      }
    } else {
      minutes = int.tryParse(value.replaceAll(' min', '')) ?? 0;
    }

    return minutes;
  }

  /// Chuyển số phút thành chuỗi cook time
  static String toTimeString(int minutes) {
    if (minutes >= 120) return '2+ hours';

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0 && mins > 0) {
      return '$hours hour${hours > 1 ? 's' : ''} $mins min';
    } else if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''}';
    } else {
      return '$mins min';
    }
  }

  static String formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    // Hàm nhỏ để format giờ phút thủ công
    String formatHourMinute(DateTime dt) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      return '${twoDigits(dt.hour)}:${twoDigits(dt.minute)}';
    }

    if (diff.inDays == 0) {
      return 'Today • ${formatHourMinute(dateTime)}';
    } else if (diff.inDays == 1) {
      return 'Yesterday • ${formatHourMinute(dateTime)}';
    } else {
      return '${diff.inDays} days ago • ${formatHourMinute(dateTime)}';
    }
  }
}
