import 'package:flutter/material.dart';

class PersonalRecipeTab extends StatefulWidget {
  PersonalRecipeTab({super.key});

  @override
  State<PersonalRecipeTab> createState() => _PersonalRecipeTabState();
}

class _PersonalRecipeTabState extends State<PersonalRecipeTab> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 10,
      itemBuilder: (context, index) => ListTile(
        leading: Container(
          width: 50,
          height: 50,
          color: Colors.grey.shade300,
          child: const Icon(Icons.fastfood),
        ),
        title: Text('Recipe ${index + 1}'),
        subtitle: const Text('Description for recipe'),
      ),
    );
  }
}
