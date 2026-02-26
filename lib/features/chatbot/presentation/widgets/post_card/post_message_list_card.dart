import 'package:eefood/features/chatbot/presentation/widgets/post_card/post_message_card.dart';
import 'package:eefood/features/post/data/models/post_model.dart';
import 'package:flutter/material.dart';

class PostMessageListCard extends StatelessWidget {
  final List<PostModel> postModel;
  const PostMessageListCard({super.key, required this.postModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 2),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Gợi ý cho bạn',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${postModel.length} món',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.63,
            ),
            itemCount: postModel.length,
            itemBuilder: (context, index) {
              return PostMessageCard(postModel: postModel[index]);
            },
          ),
        ],
      ),
    );
  }
}
