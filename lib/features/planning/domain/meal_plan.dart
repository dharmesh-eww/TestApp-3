enum MealSlot { breakfast, lunch, dinner, snack }
extension MealSlotLabel on MealSlot {
  String get label => switch (this) { MealSlot.breakfast => 'Breakfast', MealSlot.lunch => 'Lunch', MealSlot.dinner => 'Dinner', MealSlot.snack => 'Snack' };
}
class PlannedMeal {
  const PlannedMeal({required this.day, required this.slot, required this.recipeId, required this.servings});
  final String day; final MealSlot slot; final String recipeId; final int servings;
}
class PantryItem {
  const PantryItem({required this.id, required this.name, required this.amount, required this.unit});
  final String id; final String name; final double amount; final String unit;
}
class GroceryItem {
  const GroceryItem({required this.key, required this.name, required this.unit, required this.amount, required this.ownedAmount, required this.toBuyAmount, required this.isQuantified, required this.isChecked});
  final String key; final String name; final String unit; final double amount; final double ownedAmount; final double toBuyAmount; final bool isQuantified; final bool isChecked;
}

class GroceryEdit {
  const GroceryEdit({required this.name, required this.amount});
  final String name;
  final double amount;
}
