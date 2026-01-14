class WeatherInfo {
  final String province;
  final String description;
  final double temperature;
  final double windSpeed;

  WeatherInfo({
    required this.province,
    required this.description,
    required this.temperature,
    required this.windSpeed,
  });
}

class OpenMeteoWeatherMapper {
  static String description(int code) {
    switch (code) {
      case 0:
        return 'Trời quang';
      case 1:
      case 2:
      case 3:
        return 'Có mây';
      case 45:
      case 48:
        return 'Sương mù';
      case 51:
      case 53:
      case 55:
        return 'Mưa phùn';
      case 61:
      case 63:
      case 65:
        return 'Mưa';
      case 71:
      case 73:
      case 75:
        return 'Tuyết rơi';
      case 80:
      case 81:
      case 82:
        return 'Mưa rào';
      case 95:
        return 'Dông';
      default:
        return 'Thời tiết không xác định';
    }
  }
}
