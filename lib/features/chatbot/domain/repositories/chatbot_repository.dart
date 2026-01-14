import 'package:eefood/features/chatbot/data/models/weather_info.dart';

abstract class ChatbotRepository {
  Future<WeatherInfo> getCurrentWeather();
}