import 'package:eefood/features/recipe/domain/entities/ingredient.dart';

class IngredientModel {
    final int? id;
    final String name;
    final String? description;
    final String? image;
    final int? quantity;
    final String? unit;

    IngredientModel({
        this.id, 
        required this.name, 
        this.description, 
        this.image, 
        this.quantity, 
        this.unit});

    factory IngredientModel.fromJson(Map<String, dynamic> json) {
        return IngredientModel(
            id: json['id'] as int, 
            name: json['name'],
            description: json['description'],
            image: json['image']);
    }

    Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'image': image,
    };

    Ingredient toEntity() => Ingredient(
        id: id!, 
        name: name,
        description: description,
        imageUrl: image,
        quantity: quantity,
        unit: unit);
}