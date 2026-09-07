import 'package:shared_preferences/shared_preferences.dart';

/// Deliberately NOT run through Either<Failure, T> the way session
/// operations are. This is a simple device preference, not a business
/// operation — if reading it fails, defaulting to "show onboarding" is
/// the correct fallback, not a user-facing error. Not everything needs
/// the same amount of ceremony.
class OnboardingPreference {
  static const _key = 'has_completed_onboarding';

  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}