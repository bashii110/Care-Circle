import 'package:care_circle/core/utils/id_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generate() produces non-empty, unique ids', () {
    final Set<String> ids = <String>{
      for (int i = 0; i < 100; i++) IdGenerator.generate(),
    };

    expect(ids, hasLength(100));
    expect(ids.every((String id) => id.isNotEmpty), isTrue);
  });
}
