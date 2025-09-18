import 'package:eefood/features/recipe/domain/entities/recipe_step.dart';

class RecipeStepModel {
  final int? id;
  final int stepNumber;
  final String? instruction;
  final String? imageUrl;
  final String? videoUrl;
  final int? stepTime;
  RecipeStepModel({
    this.id,
    required this.stepNumber,
    this.instruction,
    this.imageUrl,
    this.videoUrl,
    this.stepTime
  });

  factory RecipeStepModel.fromJson(Map<String, dynamic> json) {
    return RecipeStepModel(
      id: json['id'],
      stepNumber: json['stepNumber'],
      instruction: json['instruction'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      stepTime: json['stepTime']
    );
  }

   Map<String, dynamic> toJson() => {
        'id': id,
        'stepNumber': stepNumber,
        'instruction': instruction,
        'imageUrl': imageUrl,
        'videoUrl': videoUrl,
        'stepTime': stepTime,
      };

  RecipeStep toEntity() => RecipeStep(
    id: id!, 
    stepNumber: stepNumber, 
    instruction: instruction!,
    imageUrl: imageUrl,
    videoUrl: videoUrl,
    stepTime: stepTime);
}