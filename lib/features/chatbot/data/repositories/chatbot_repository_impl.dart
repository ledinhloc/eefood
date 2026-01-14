import 'package:dio/dio.dart';
import 'package:eefood/core/utils/locations_utils.dart';
import 'package:eefood/core/utils/logger.dart';
import 'package:eefood/features/chatbot/data/models/weather_info.dart';
import 'package:eefood/features/chatbot/domain/repositories/chatbot_repository.dart';

class ChatbotRepositoryImpl extends ChatbotRepository {
  final Dio dio;
  ChatbotRepositoryImpl({required this.dio});

  @override
  Future<WeatherInfo> getCurrentWeather() async {
    final location = await LocationUtils.getCurrentLocationInfo();

    final response = await dio.get(
      'https://api.open-meteo.com/v1/forecast',
      queryParameters: {
        'latitude': location.latitude,
        'longitude': location.longitude,
        'current_weather': true,
        'timezone': 'Asia/Ho_Chi_Minh',
      },
    );

    final current = response.data['current_weather'];

    final weatherCode = current['weathercode'];

    logger.i("Weather code: $weatherCode");

    return WeatherInfo(
      province: location.province,
      description: OpenMeteoWeatherMapper.description(weatherCode),
      temperature: current['temperature'].toDouble(),
      windSpeed: current['windspeed'].toDouble(),
    );
  }
}
