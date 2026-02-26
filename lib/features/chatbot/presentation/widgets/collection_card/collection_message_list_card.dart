import 'package:eefood/features/chatbot/presentation/widgets/collection_card/collection_message_card.dart';
import 'package:eefood/features/post/data/models/collection_model.dart';
import 'package:flutter/material.dart';

class CollectionMessageListCard extends StatefulWidget {
  final List<CollectionModel> listCollection;
  const CollectionMessageListCard({super.key, required this.listCollection});

  @override
  State<CollectionMessageListCard> createState() =>
      _CollectionMessageListCardState();
}

class _CollectionMessageListCardState extends State<CollectionMessageListCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.collections_bookmark_outlined,
                  size: 20,
                  color: Colors.deepOrange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bộ sưu tập',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.listCollection.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final collection = widget.listCollection[index];
              return CollectionMessageCard(collectionModel: collection);
            },
          ),
        ],
      ),
    );
  }
}
