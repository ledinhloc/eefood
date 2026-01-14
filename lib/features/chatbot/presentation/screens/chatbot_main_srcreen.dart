import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/chatbot/data/models/weather_info.dart';
import 'package:eefood/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:flutter/material.dart';

class ChatbotMainSrcreen extends StatefulWidget {
  const ChatbotMainSrcreen({super.key});

  @override
  State<ChatbotMainSrcreen> createState() => _ChatbotMainSrcreenState();
}

class _ChatbotMainSrcreenState extends State<ChatbotMainSrcreen> {
  final ChatbotRepository repository = getIt<ChatbotRepository>();
  WeatherInfo? _currentWeather;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _getCurrentWeather();
  }

  void _getCurrentWeather() async {
    try {
      final weather = await repository.getCurrentWeather();

      setState(() {
        _currentWeather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_currentWeather == null) {
      return const Scaffold(
        body: Center(child: Text('Không lấy được thời tiết')),
      );
    }
    String s =
        'Hiện tại ở ${_currentWeather!.province}, ${_currentWeather!.description.toLowerCase()}, '
        'nhiệt độ khoảng ${_currentWeather!.temperature.round()}°C.';

    return Scaffold(
      appBar: AppBar(
        title: Text('eeBot'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Container(child: Text(s)),
    );
  }
}
