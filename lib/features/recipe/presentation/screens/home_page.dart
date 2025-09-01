import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Editor\'s Choice', style: TextStyle(color: Colors.orange)),
                const Text('For You', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                Image.asset('assets/images/meatballs.jpg', fit: BoxFit.cover),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.orange[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Today\'s Recipe', style: TextStyle(fontSize: 16)),
                      const Text(
                        'Seb\'s Childhood Swedish Meatballs',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Text('Sebastian Graus', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.favorite_border, color: Colors.grey),
                          const Text('13.8k', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () {},
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'MyRecipes'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Shopping List'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 0, // Default to Home
        onTap: (index) {
          // Handle navigation (to be implemented with state management)
        },
      ),
    );
  }
}