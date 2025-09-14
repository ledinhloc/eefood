class RecipeStep {
  final int id;
  final int stepNumber;
  final String instruction;
  final String? imageUrl;
  final String? videoUrl;
  final int? stepTime;

  const RecipeStep({
    required this.id,
    required this.stepNumber,
    required this.instruction,
    this.imageUrl,
    this.videoUrl,
    this.stepTime,
  });
}
