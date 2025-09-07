import 'package:flutter/material.dart';

class FoodPreferencesPage extends StatelessWidget {
  const FoodPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Food Preferences")),
      body: const Center(child: Text("Food Preferences Page")),
    );
  }
}
