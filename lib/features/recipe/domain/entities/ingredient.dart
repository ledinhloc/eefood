class Ingredient {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int? quantity;
  final String? unit;

  const Ingredient({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.quantity,
    this.unit,
  });
}
