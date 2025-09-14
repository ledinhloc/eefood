enum Difficulty { EASY, MEDIUM, HARD }

class Recipe {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? videoUrl;
  final Difficulty? difficulty;
  final String? region;
  final int? cookTime; // in minutes
  final int? prepTime; // in minutes
  final List<String>? dietaryPreferences;

  const Recipe({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.videoUrl,
    this.difficulty,
    this.region,
    this.cookTime,
    this.prepTime,
    this.dietaryPreferences,
  });
}

