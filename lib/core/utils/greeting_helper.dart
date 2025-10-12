class GreetingHelper {
  static String getGreeting({required String userName}) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour >= 5 && hour < 11) {
      greeting = 'Chào buổi sáng';
    } else if (hour >= 11 && hour < 13) {
      greeting = 'Chào buổi trưa';
    } else if (hour >= 13 && hour < 18) {
      greeting = 'Chào buổi chiều';
    } else {
      greeting = 'Chào buổi tối';
    }

    return '$greeting, $userName 👋';
  }
}
