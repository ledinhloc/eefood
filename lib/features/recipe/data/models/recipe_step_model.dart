import 'package:eefood/features/recipe/domain/entities/recipe_step.dart';

class RecipeStepModel {
  final int? id;
  final int stepNumber;
  final String? instruction;
  final List<String>? imageUrls;
  final List<String>? videoUrls;
  final int? stepTime;

  RecipeStepModel({
    this.id,
    required this.stepNumber,
    this.instruction,
    this.imageUrls,
    this.videoUrls,
    this.stepTime,
  });

  factory RecipeStepModel.fromJson(Map<String, dynamic> json) {
    return RecipeStepModel(
      id: json['id'],
      stepNumber: json['stepNumber'] ?? 0,
      instruction: json['instruction'],
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : [],
      videoUrls: json['videoUrls'] != null
          ? List<String>.from(json['videoUrls'])
          : [],
      stepTime: json['stepTime'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'stepNumber': stepNumber,
    'instruction': instruction,
    'imageUrls': imageUrls,
    'videoUrls': videoUrls,
    'stepTime': stepTime,
  };

  RecipeStepModel copyWith({
    int? id,
    int? stepNumber,
    String? instruction,
    List<String>? imageUrls,
    List<String>? videoUrls,
    int? stepTime,
  }) {
    return RecipeStepModel(
      id: id ?? this.id,
      stepNumber: stepNumber ?? this.stepNumber,
      instruction: instruction ?? this.instruction,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrls: videoUrls ?? this.videoUrls,
      stepTime: stepTime ?? this.stepTime,
    );
  }
}
