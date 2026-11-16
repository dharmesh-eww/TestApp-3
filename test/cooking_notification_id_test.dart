import 'package:flutter_test/flutter_test.dart';
import 'package:testapp_3/features/cooking/domain/cooking_assist_service.dart';

void main() {
  test('cooking timer notification IDs are stable and non-zero', () {
    final first = CookingAssistService.notificationIdFor('timer-123');
    final second = CookingAssistService.notificationIdFor('timer-123');

    expect(first, isNonZero);
    expect(second, first);
    expect(CookingAssistService.notificationIdFor('timer-456'), isNot(first));
  });
}
