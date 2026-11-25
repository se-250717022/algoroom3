import '../../../core/domain/user_intent.dart';

export '../../../core/domain/user_intent.dart';

typedef DemoProfile = ({
  String id,
  String name,
  int age,
  String region,
  UserIntent intent,
});

typedef DemoRoom = ({String id, String region, int rent, bool shared});

typedef DemoCatalog = ({List<DemoProfile> profiles, List<DemoRoom> rooms});

abstract interface class DemoRepository {
  Future<DemoCatalog> load();
}
