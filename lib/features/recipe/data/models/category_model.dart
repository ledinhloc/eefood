import 'package:flutter/foundation.dart';
import 'package:eefood/features/recipe/domain/entities/category.dart';
class CategoryModel {
  final int id;
  final String? description;
  final String? iconUrl;

  CategoryModel({required this.id, this.description,this.iconUrl});
  
  factory CategoryModel.fromJson(Map<String,dynamic> json) {
    return CategoryModel(
      id: json['id'],
      description: json['description'],
      iconUrl: json['iconUrl']
      );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'iconUrl': iconUrl,
    };
  }

  CategoryPreference toEntity() => CategoryPreference(
    id: id,
    description: description,
    iconUrl: iconUrl
  );
}