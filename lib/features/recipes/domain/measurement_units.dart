/// Converts only within a physical dimension. Mass is never converted to volume.
class MeasurementUnits {
  const MeasurementUnits._();

  static const _massToGrams = <String, double>{
    'g': 1, 'gram': 1, 'grams': 1,
    'kg': 1000, 'kilogram': 1000, 'kilograms': 1000,
    'oz': 28.349523125, 'ounce': 28.349523125, 'ounces': 28.349523125,
    'lb': 453.59237, 'lbs': 453.59237, 'pound': 453.59237, 'pounds': 453.59237,
  };
  static const _volumeToMl = <String, double>{
    'ml': 1, 'milliliter': 1, 'milliliters': 1, 'millilitre': 1, 'millilitres': 1,
    'l': 1000, 'liter': 1000, 'liters': 1000, 'litre': 1000, 'litres': 1000,
    'tsp': 4.92892159375, 'teaspoon': 4.92892159375, 'teaspoons': 4.92892159375,
    'tbsp': 14.78676478125, 'tablespoon': 14.78676478125, 'tablespoons': 14.78676478125,
    'cup': 236.5882365, 'cups': 236.5882365,
    'fl oz': 29.5735295625, 'fluid ounce': 29.5735295625, 'fluid ounces': 29.5735295625,
  };

  /// Returns null for unknown or cross-dimension conversions.
  static ({double amount, String unit})? convert(
    double amount,
    String sourceUnit,
    String system,
  ) {
    final unit = sourceUnit.trim().toLowerCase();
    if (system == 'metric') {
      final mass = _massToGrams[unit];
      if (mass != null) {
        final grams = amount * mass;
        return grams.abs() >= 1000
            ? (amount: grams / 1000, unit: 'kg')
            : (amount: grams, unit: 'g');
      }
      final volume = _volumeToMl[unit];
      if (volume != null) {
        final ml = amount * volume;
        return ml.abs() >= 1000
            ? (amount: ml / 1000, unit: 'L')
            : (amount: ml, unit: 'ml');
      }
      return null;
    }
    if (system == 'us') {
      final mass = _massToGrams[unit];
      if (mass != null) {
        final ounces = amount * mass / _massToGrams['oz']!;
        return ounces.abs() >= 16
            ? (amount: ounces / 16, unit: 'lb')
            : (amount: ounces, unit: 'oz');
      }
      final volume = _volumeToMl[unit];
      if (volume != null) {
        final cups = amount * volume / _volumeToMl['cup']!;
        return cups.abs() >= 0.25
            ? (amount: cups, unit: 'cup')
            : (amount: amount * volume / _volumeToMl['tsp']!, unit: 'tsp');
      }
    }
    return null;
  }

  static String format(double amount) =>
      amount == amount.roundToDouble()
          ? amount.toInt().toString()
          : amount.toStringAsFixed(1);
}
