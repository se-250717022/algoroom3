import 'package:flutter_test/flutter_test.dart';
import 'package:algoroom/core/domain/user_intent.dart';
import 'package:algoroom/features/matching/domain/compatibility.dart';

Candidate candidate({
  UserIntent intent = UserIntent.findTogether,
  Budget budget = (minimum: 5000, maximum: 8000),
  int cleanliness = 3,
  Smoking smoking = Smoking.never,
  SmokingPreference smokingPreference = SmokingPreference.none,
  Pets pets = Pets.acceptsPets,
  Set<Criterion> strict = const {},
  int? listingCost,
}) => (
  intent: intent,
  lifestyle: (
    budget: budget,
    cleanliness: cleanliness,
    sleep: Sleep.regular,
    smoking: smoking,
    smokingPreference: smokingPreference,
    guests: 2,
    noise: 3,
    pets: pets,
  ),
  strict: strict,
  listingCost: listingCost,
  active: true,
);

Compatibility? score(Candidate a, Candidate b, {bool blocked = false}) =>
    calculateCompatibility(a, b, blocked: blocked, requiredFiltersMatch: true);

void main() {
  test('Scores identical valid point budgets at 100', () {
    final a = candidate(budget: (minimum: 6000, maximum: 6000));
    expect(score(a, a)?.score, 100);
  });

  test(
    'Uses actual listing cost for seeker budget and respects strict limits',
    () {
      final host = candidate(intent: UserIntent.hasRoom, listingCost: 9000);
      final seeker = candidate(intent: UserIntent.needsRoom);
      expect(
        score(host, seeker)?.criteria[Criterion.budget],
        closeTo(8 / 9, .00001),
      );
      expect(score(seeker, host)?.score, score(host, seeker)?.score);
      expect(
        score(
          host,
          candidate(intent: UserIntent.needsRoom, strict: {Criterion.budget}),
        ),
        isNull,
      );
      expect(score(candidate(intent: UserIntent.hasRoom), seeker), isNull);
    },
  );

  test(
    'Checks both smoking preferences and directional strict requirements',
    () {
      final nonSmoker = candidate(strict: {Criterion.smoking});
      final smoker = candidate(smoking: Smoking.outdoors);
      expect(score(nonSmoker, smoker), isNull);
      expect(score(candidate(), smoker)?.criteria[Criterion.smoking], .5);
      expect(
        score(
          candidate(smokingPreference: SmokingPreference.outdoors),
          smoker,
        )?.criteria[Criterion.smoking],
        1,
      );
    },
  );

  test('Filters pet conflicts, blocks and incompatible intent', () {
    expect(
      score(
        candidate(pets: Pets.noPets, strict: {Criterion.pets}),
        candidate(pets: Pets.hasPet),
      ),
      isNull,
    );
    expect(score(candidate(), candidate(), blocked: true), isNull);
    expect(score(candidate(), candidate(intent: UserIntent.needsRoom)), isNull);
  });

  test('Applies the weighted cleanliness difference', () {
    final result = score(candidate(cleanliness: 1), candidate(cleanliness: 5));
    expect(result?.criteria[Criterion.cleanliness], 0);
    expect(result?.score, 80);
  });
}
