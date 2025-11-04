import 'package:flutter/material.dart';

class VerticalDivider extends StatelessWidget {
  const VerticalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 1,
      color: Colors.grey[300],
    );
  }
}
