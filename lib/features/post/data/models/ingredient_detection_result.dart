class IngredientDetectionResult {
  final List<String> labels;
  final String annotatedImageBase64;

  const IngredientDetectionResult({
    required this.labels,
    required this.annotatedImageBase64,
  });

  factory IngredientDetectionResult.fromJson(Map<String, dynamic> json) {
    final labels = json['labels'] as List<dynamic>? ?? const [];

    return IngredientDetectionResult(
      labels: labels.map((label) => label.toString()).toList(),
      annotatedImageBase64: json['annotatedImageBase64'] as String? ?? '',
    );
  }
}
