import 'package:flutter_test/flutter_test.dart';
import 'package:algoroom/features/demo/data/mock_repository.dart';
import 'package:algoroom/features/demo/domain/demo_repository.dart';

void main() {
  test(
    'Demo catalog has distinct fictional records for every intent',
    () async {
      final data = await const MockRepository().load();

      expect(data.profiles.map((row) => row.id).toSet(), hasLength(15));
      expect(data.rooms.map((row) => row.id).toSet(), hasLength(10));
      expect(
        data.profiles.map((row) => row.intent).toSet(),
        UserIntent.values.toSet(),
      );
      expect(data.rooms.every((room) => room.rent > 0), isTrue);
    },
  );
}
