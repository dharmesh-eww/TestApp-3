import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// A short first-run introduction. It stores no account or personal data.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.onComplete});
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Padding(padding: const EdgeInsets.all(28), child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.spa_outlined, size: 42, color: AppTheme.terracotta),
          const SizedBox(height: 28),
          Text('A gentler way to gather.', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 16),
          const Text('Keep recipes you love, plan a week of meals, and turn ingredients into a thoughtful shopping list.'),
          const SizedBox(height: 28),
          const _Feature(Icons.menu_book_outlined, 'Discover recipes', 'Find something lovely to cook.'),
          const _Feature(Icons.calendar_month_outlined, 'Plan your week', 'Move meals around as plans change.'),
          const _Feature(Icons.shopping_basket_outlined, 'Shop with a list', 'Keep your pantry and groceries together.'),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity, child: FilledButton(key: const Key('onboarding-get-started'), onPressed: onComplete, child: const Text('Get started'))),
          const SizedBox(height: 12),
          Center(child: Text('Your planner stays on this device.', style: TextStyle(color: AppTheme.muted))),
        ],
      )),
    ))),
  );
}

class _Feature extends StatelessWidget {
  const _Feature(this.icon, this.title, this.description);
  final IconData icon; final String title; final String description;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(children: [
    Icon(icon, color: AppTheme.olive), const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      Text(description, style: TextStyle(color: AppTheme.muted)),
    ])),
  ]));
}
