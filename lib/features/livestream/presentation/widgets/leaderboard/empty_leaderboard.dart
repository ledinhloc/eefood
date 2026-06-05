import 'package:flutter/material.dart';

class EmptyLeaderboard extends StatelessWidget {
  const EmptyLeaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('💎', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text(
            'Chưa có ai ủng hộ streamer này',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'Hãy là người đầu tiên! 🎁',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
