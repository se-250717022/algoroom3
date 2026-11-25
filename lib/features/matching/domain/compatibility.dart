import 'dart:math' as math;

import '../../../core/domain/user_intent.dart';

enum Criterion { budget, cleanliness, sleep, smoking, guests, noise, pets }

enum Sleep { early, regular, late, variable }

enum Smoking { never, occasional, regular, outdoors }

enum SmokingPreference { any, outdoors, none }

enum Pets { hasPet, acceptsPets, noPets }

typedef Budget = ({int minimum, int maximum});
typedef Lifestyle = ({
  Budget budget,
  int cleanliness,
  Sleep sleep,
  Smoking smoking,
  SmokingPreference smokingPreference,
  int guests,
  int noise,
  Pets pets,
});
typedef Candidate = ({
  UserIntent intent,
  Lifestyle? lifestyle,
  Set<Criterion> strict,
  int? listingCost,
  bool active,
});
typedef Compatibility = ({
  double score,
  Map<Criterion, double> criteria,
  String version,
});

const defaultWeights = {
  Criterion.budget: 25,
  Criterion.cleanliness: 20,
  Criterion.sleep: 15,
  Criterion.smoking: 15,
  Criterion.guests: 10,
  Criterion.noise: 10,
  Criterion.pets: 5,
};

bool compatibleIntents(UserIntent a, UserIntent b) => switch (a) {
  UserIntent.hasRoom => b == UserIntent.needsRoom,
  UserIntent.needsRoom => b == UserIntent.hasRoom,
  UserIntent.findTogether => b == UserIntent.findTogether,
};

double _scale(int a, int b, int range) => 1 - (a - b).abs() / range;

bool _accepts(SmokingPreference preference, Smoking smoking) =>
    smoking == Smoking.never ||
    preference == SmokingPreference.any ||
    (preference == SmokingPreference.outdoors && smoking == Smoking.outdoors);

double _sleep(Sleep a, Sleep b) {
  if (a == b) return 1;
  if (a == Sleep.variable || b == Sleep.variable) return .5;
  return (a.index - b.index).abs() == 1 ? .7 : .3;
}

bool _validBudget(Budget value) =>
    value.minimum >= 0 && value.maximum > 0 && value.minimum <= value.maximum;

bool _valid(Lifestyle value) =>
    _validBudget(value.budget) &&
    value.cleanliness >= 1 &&
    value.cleanliness <= 5 &&
    value.noise >= 1 &&
    value.noise <= 5 &&
    value.guests >= 1 &&
    value.guests <= 4;

double _costScore(int cost, Budget budget) {
  if (cost >= budget.minimum && cost <= budget.maximum) return 1;
  final boundary = cost < budget.minimum ? budget.minimum : budget.maximum;
  return 1 - (cost - boundary).abs() / math.max(cost, boundary);
}

double _overlap(Budget a, Budget b) {
  final start = math.max(a.minimum, b.minimum);
  final end = math.min(a.maximum, b.maximum);
  if (start > end) return 0;
  final shortest = math.min(a.maximum - a.minimum, b.maximum - b.minimum);
  return shortest == 0 ? 1 : (end - start) / shortest;
}

Compatibility? calculateCompatibility(
  Candidate a,
  Candidate b, {
  required bool blocked,
  required bool requiredFiltersMatch,
  Map<Criterion, int> weights = defaultWeights,
  String version = '1.0.0',
}) {
  if (blocked ||
      !requiredFiltersMatch ||
      !a.active ||
      !b.active ||
      !compatibleIntents(a.intent, b.intent)) {
    return null;
  }
  final left = a.lifestyle;
  final right = b.lifestyle;
  if (left == null || right == null || !_valid(left) || !_valid(right)) {
    return null;
  }

  final together = a.intent == UserIntent.findTogether;
  final host = a.intent == UserIntent.hasRoom ? a : b;
  final seeker = a.intent == UserIntent.needsRoom ? left : right;
  final cost = host.listingCost;
  if (!together && (cost == null || cost <= 0)) return null;

  final aAcceptsSmoking = _accepts(left.smokingPreference, right.smoking);
  final bAcceptsSmoking = _accepts(right.smokingPreference, left.smoking);
  final aAcceptsPets = left.pets != Pets.noPets || right.pets != Pets.hasPet;
  final bAcceptsPets = right.pets != Pets.noPets || left.pets != Pets.hasPet;
  final budget = together
      ? _overlap(left.budget, right.budget)
      : _costScore(cost!, seeker.budget);
  final budgetFits = together
      ? math.max(left.budget.minimum, right.budget.minimum) <=
            math.min(left.budget.maximum, right.budget.maximum)
      : budget == 1;
  final criteria = {
    Criterion.budget: budget,
    Criterion.cleanliness: _scale(left.cleanliness, right.cleanliness, 4),
    Criterion.sleep: _sleep(left.sleep, right.sleep),
    Criterion.smoking:
        ((aAcceptsSmoking ? 1 : 0) + (bAcceptsSmoking ? 1 : 0)) / 2,
    Criterion.guests: _scale(left.guests, right.guests, 3),
    Criterion.noise: _scale(left.noise, right.noise, 4),
    Criterion.pets: aAcceptsPets && bAcceptsPets ? 1.0 : 0.0,
  };

  bool satisfies(Candidate candidate, bool acceptsSmoking, bool acceptsPets) =>
      candidate.strict.every(
        (criterion) => switch (criterion) {
          Criterion.budget =>
            !together && candidate.intent == UserIntent.hasRoom || budgetFits,
          Criterion.smoking => acceptsSmoking,
          Criterion.pets => acceptsPets,
          _ => criteria[criterion] == 1,
        },
      );
  if (!satisfies(a, aAcceptsSmoking, aAcceptsPets) ||
      !satisfies(b, bAcceptsSmoking, bAcceptsPets)) {
    return null;
  }

  if (weights.length != Criterion.values.length ||
      weights.values.any((weight) => weight < 0) ||
      weights.values.fold(0, (sum, weight) => sum + weight) != 100 ||
      version.trim().isEmpty) {
    throw ArgumentError(
      'Seven nonnegative weights totaling 100 and a version are required.',
    );
  }
  final score = Criterion.values.fold<double>(
    0,
    (sum, criterion) => sum + criteria[criterion]! * weights[criterion]!,
  );
  return (
    score: score.clamp(0.0, 100.0).toDouble(),
    criteria: Map.unmodifiable(criteria),
    version: version,
  );
}
