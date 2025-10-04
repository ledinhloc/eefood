class ShoppingIngredientModel {
  final int? id;
  final int? ingredientId;
  final String? ingredientName;
  final String? image;
  final int? quantity;
  final String? unit;
  final bool purchased;
  final List<int>? shoppingIngredientIds;

  ShoppingIngredientModel({
    this.id,
    this.ingredientId,
    this.ingredientName,
    this.image,
    this.quantity,
    this.unit,
    this.purchased = false,
    this.shoppingIngredientIds,
  });

  factory ShoppingIngredientModel.fromJson(Map<String, dynamic> json) {
    return ShoppingIngredientModel(
      id: json['id'] == null ? null : (json['id'] as num).toInt(),
      ingredientId: json['ingredientId'] == null
          ? null
          : (json['ingredientId'] as num).toInt(),
      ingredientName: json['ingredientName'] as String?,
      image: json['image'] as String?,
      quantity: json['quantity'] == null
          ? null
          : (json['quantity'] as num).toInt(),
      unit: json['unit'] as String?,
      purchased: json['purchased'] as bool? ?? false,
      shoppingIngredientIds: (json['shoppingIngredientIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ingredientId': ingredientId,
    'ingredientName': ingredientName,
    'image': image,
    'quantity': quantity,
    'unit': unit,
    'purchased': purchased,
    'shoppingIngredientIds': shoppingIngredientIds,
  };

  ShoppingIngredientModel copyWith({
    int? id,
    int? ingredientId,
    String? ingredientName,
    String? image,
    int? quantity,
    String? unit,
    bool? purchased,
    List<int>? shoppingIngredientIds,
  }) {
    return ShoppingIngredientModel(
      id: id ?? this.id,
      ingredientId: ingredientId ?? this.ingredientId,
      ingredientName: ingredientName ?? this.ingredientName,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      purchased: purchased ?? this.purchased,
      shoppingIngredientIds:
          shoppingIngredientIds ?? this.shoppingIngredientIds,
    );
  }
}
