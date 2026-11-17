/// Curated cooking substitutions. These are culinary suggestions, not
/// allergy guarantees; users must verify labels and cross-contamination.
class IngredientSubstitutionService {
  IngredientSubstitutionService._();

  static const Map<String, List<String>> _substitutions = {
    'buttermilk': ['1 cup milk + 1 tbsp lemon juice (rest 5 minutes)', 'plain yogurt thinned with water'],
    'butter': ['olive oil (about 3/4 the amount for sautéing)', 'neutral vegetable oil'],
    'egg': ['1 tbsp ground flaxseed + 3 tbsp water (rest 5 minutes)', '1/4 cup unsweetened applesauce for baking'],
    'milk': ['unsweetened oat milk', 'unsweetened soy milk'],
    'heavy cream': ['evaporated milk', 'coconut cream (adds coconut flavour)'],
    'sour cream': ['plain Greek yogurt', 'plain yogurt'],
    'yogurt': ['plain Greek yogurt', 'dairy-free unsweetened yogurt'],
    'parmesan': ['Pecorino Romano', 'nutritional yeast (different flavour)'],
    'breadcrumbs': ['crushed crackers', 'rolled oats pulsed briefly'],
    'cornstarch': ['twice the amount of all-purpose flour as a thickener'],
    'lemon juice': ['lime juice', 'mild vinegar in a smaller amount'],
    'lime juice': ['lemon juice', 'mild vinegar in a smaller amount'],
    'soy sauce': ['tamari (check gluten label)', 'coconut aminos'],
    'rice': ['quinoa', 'cauliflower rice'],
    'pasta': ['gluten-free pasta', 'zucchini ribbons'],
    'chickpea': ['white beans', 'butter beans'],
    'coriander': ['flat-leaf parsley', 'a smaller amount of fresh basil'],
  };

  static List<String> alternativesFor(String ingredientName) {
    final normalized = ingredientName.trim().toLowerCase();
    for (final entry in _substitutions.entries) {
      if (normalized == entry.key || normalized.contains(entry.key)) {
        return entry.value;
      }
    }
    return const [];
  }
}
