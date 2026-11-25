import '../domain/demo_repository.dart';

class MockRepository implements DemoRepository {
  const MockRepository();

  static const regions = [
    'Kötekli, Menteşe',
    'Muğla',
    'İzmir',
    'İstanbul',
    'Ankara',
    'Antalya',
  ];

  @override
  Future<DemoCatalog> load() async {
    const names = [
      'Deniz',
      'Ekin',
      'Nehir',
      'Baran',
      'Ada',
      'Kuzey',
      'İdil',
      'Toprak',
      'Ilgın',
      'Arda',
      'Defne',
      'Yağmur',
      'Sarp',
      'Ela',
      'Duru',
    ];
    return (
      profiles: List<DemoProfile>.unmodifiable([
        for (var i = 0; i < names.length; i++)
          (
            id: 'profile-$i',
            name: names[i],
            age: 19 + i % 8,
            region: regions[(i ~/ 3) % regions.length],
            intent: UserIntent.values[i % UserIntent.values.length],
          ),
      ]),
      rooms: List<DemoRoom>.unmodifiable([
        for (var i = 0; i < 10; i++)
          (
            id: 'room-$i',
            region: regions[i % regions.length],
            rent: 5000 + i * 650,
            shared: i.isOdd,
          ),
      ]),
    );
  }
}
