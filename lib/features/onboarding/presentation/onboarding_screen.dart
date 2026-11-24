import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../localization/app_localizations.dart';
import '../../../app/gather_visuals.dart';

/// A short first-run introduction. It stores no account or personal data.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.onComplete});
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final strings = appStrings(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 22, 26, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(color: AppTheme.terracotta.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.spa_rounded, color: AppTheme.terracotta),
                      ),
                      const SizedBox(width: 10),
                      Text('GATHER', style: TextStyle(color: AppTheme.ink, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2.4)),
                      const Spacer(),
                      GatherVisuals.foodMotion(size: 62),
                    ],
                  ).animate().fadeIn(duration: 420.ms).slideY(begin: -.06, end: 0),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 206,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF1E6D6), Color(0xFFE6D7C4)]),
                          ),
                        ),
                        GatherVisuals.heroIllustration(width: 300, height: 208),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(.96, .96), curve: Curves.easeOutCubic),
                  const SizedBox(height: 28),
                  Text(
                    strings.label('A gentler way to gather.', 'طريقة ألطف لتنظيم وصفاتك.'),
                    style: Theme.of(context).textTheme.headlineLarge,
                  ).animate().fadeIn(delay: 120.ms).slideY(begin: .08, end: 0),
                  const SizedBox(height: 13),
                  Text(
                    strings.label(
                      'Keep recipes you love, plan a week of meals, and turn ingredients into a thoughtful shopping list.',
                      'احتفظ بوصفاتك المفضلة، وخطط وجبات أسبوع كامل، وحوّل المكونات إلى قائمة تسوق منظمة.',
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.muted),
                  ),
                  const SizedBox(height: 26),
                  const _Feature(Icons.menu_book_rounded, 'Discover recipes', 'Find something lovely to cook.'),
                  const _Feature(Icons.calendar_month_rounded, 'Plan your week', 'Move meals around as plans change.'),
                  const _Feature(Icons.shopping_basket_rounded, 'Shop with a list', 'Keep your pantry and groceries together.'),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const Key('onboarding-get-started'),
                      onPressed: onComplete,
                      child: Text(strings.label('Get started', 'ابدأ الآن')),
                    ),
                  ),
                  const SizedBox(height: 13),
                  Center(
                    child: Text(
                      strings.label('Your planner stays on this device.', 'يبقى مخططك على هذا الجهاز.'),
                      style: TextStyle(color: AppTheme.muted, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature(this.icon, this.title, this.description);
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: AppTheme.olive.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: AppTheme.olive, size: 20),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 2),
              Text(description, style: TextStyle(color: AppTheme.muted, fontSize: 12)),
            ],
          ),
        ),
      ],
    ),
  ).animate().fadeIn(delay: 160.ms).slideX(begin: .035, end: 0);
}
