import 'package:flutter/foundation.dart';
import 'package:eefood/features/recipe/domain/entities/category.dart';
import 'package:json_annotation/json_annotation.dart';
part 'category_model.g.dart';
@JsonSerializable()
class CategoryModel {
  final int? id;
  final String? description;
  final String? iconUrl;
  CategoryModel({this.id, this.description,this.iconUrl});

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
}