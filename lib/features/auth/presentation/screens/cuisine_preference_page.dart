import 'package:flutter/material.dart';

class CuisinePreferencePage extends StatefulWidget {
  const CuisinePreferencePage({super.key});

  @override
  State<CuisinePreferencePage> createState() => _CuisinePreferencePageState();
}

class _CuisinePreferencePageState extends State<CuisinePreferencePage> {
  // Danh sách các món ăn
  final List<Map<String, dynamic>> cuisines = [
    {"name": "Salad", "icon": "🥗"},
    {"name": "Egg", "icon": "🍳"},
    {"name": "Soup", "icon": "🍲"},
    {"name": "Meat", "icon": "🍖"},
    {"name": "Chicken", "icon": "🍗"},
    {"name": "Seafood", "icon": "🦐"},
    {"name": "Burger", "icon": "🍔"},
    {"name": "Pizza", "icon": "🍕"},
    {"name": "Sushi", "icon": "🍣"},
  ];

  // Lưu trạng thái chọn
  Set<String> selectedItems = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nút back
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.maybePop(context),
              ),

              SizedBox(height: 10),

              // Tiêu đề
              Text(
                "Select your cuisines preferences",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Select your cuisines preferences for better recommendations, or you can skip it.",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 20),

              // Grid các món ăn
              Expanded(
                child: GridView.builder(
                  itemCount: cuisines.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final cuisine = cuisines[index];
                    final isSelected = selectedItems.contains(cuisine["name"]);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedItems.remove(cuisine["name"]);
                          } else {
                            selectedItems.add(cuisine["name"]);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.red : Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              cuisine["icon"],
                              style: TextStyle(fontSize: 30),
                            ),
                            SizedBox(height: 8),
                            Text(
                              cuisine["name"],
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Nút Skip và Continue
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Bỏ qua
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text("Skip", style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Tiếp tục
                        print("Selected: $selectedItems");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Continue",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
