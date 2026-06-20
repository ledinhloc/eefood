class MealPlanItemsRegenerateRequest {
  final List<int> itemIds;
  final String? reason;

  const MealPlanItemsRegenerateRequest({required this.itemIds, this.reason});

  Map<String, dynamic> toJson() {
    return {'itemIds': itemIds, 'reason': reason};
  }
}
