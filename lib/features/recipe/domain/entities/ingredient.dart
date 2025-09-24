class Ingredient {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;

  const Ingredient({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });
}
