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
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade300, Colors.orange.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.fastfood,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),

            // Recipe info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bún bò Huế',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE67E22),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tô bún bò cay nồng chuẩn vị miền Trung',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.favorite_border,
                        color: const Color(0xFFE67E22),
                      ),
                      const SizedBox(width: 16),
                      _buildActionButton(
                        icon: Icons.chat_bubble_outline,
                        color: Colors.grey[600]!,
                      ),
                      const SizedBox(width: 16),
                      _buildActionButton(
                        icon: Icons.share_outlined,
                        color: Colors.grey[600]!,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
