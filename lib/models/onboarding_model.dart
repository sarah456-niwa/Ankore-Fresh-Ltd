// models/onboarding_model.dart
class OnboardingItem {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;
  final IconData icon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
    required this.icon,
  });
}