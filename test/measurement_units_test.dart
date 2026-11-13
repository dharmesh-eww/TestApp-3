import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/features/recipes/domain/measurement_units.dart';

void main() {
  test('converts compatible mass units', () {
    final result = MeasurementUnits.convert(1, 'kg', 'us');
    expect(result!.unit, 'lb');
    expect(result.amount, closeTo(2.2046, .001));
  });

  test('converts compatible volume units', () {
    final result = MeasurementUnits.convert(240, 'ml', 'us');
    expect(result!.unit, 'cup');
    expect(result.amount, closeTo(1.0144, .01));
  });

  test('never converts mass to volume', () {
    expect(MeasurementUnits.convert(100, 'g', 'us'), isNotNull);
    expect(MeasurementUnits.convert(100, 'g', 'us')!.unit, 'oz');
    expect(MeasurementUnits.convert(100, 'g', 'metric')!.unit, 'g');
    expect(MeasurementUnits.convert(100, 'unknown', 'us'), isNull);
  });
}
