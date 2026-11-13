import 'package:flutter/material.dart';

import '../../../app/planner_scope.dart';
import '../../../core/theme/app_theme.dart';
import '../../recipes/domain/recipe.dart';
import '../domain/cooking_session.dart';

class CookingModeScreen extends StatefulWidget {
  const CookingModeScreen({super.key, required this.recipe});
  final Recipe recipe;

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  int textScale = 0;

  @override
  Widget build(BuildContext context) {
    final session = PlannerScope.cookingOf(context);
    final total = widget.recipe.steps.length;

    return AnimatedBuilder(
      animation: session,
      builder: (context, _) {
        final servings = session.servingsFor(widget.recipe.id, widget.recipe.servings);
        final currentStep = session.stepFor(widget.recipe.id).clamp(
          0, total == 0 ? 0 : total - 1,
        ).toInt();
        return Scaffold(
          backgroundColor: AppTheme.paper,
          appBar: AppBar(
            title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.recipe.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              Text(total == 0 ? 'No instructions' : 'STEP ${currentStep + 1} OF $total',
                style: const TextStyle(fontSize: 10, color: AppTheme.muted, letterSpacing: 1.2)),
            ]),
            actions: [
              IconButton(
                tooltip: 'Text size',
                onPressed: () => setState(() => textScale = (textScale + 1) % 3),
                icon: const Icon(Icons.text_fields),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                if (total > 0) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (currentStep + 1) / total,
                      minHeight: 7,
                      backgroundColor: AppTheme.line,
                      color: AppTheme.terracotta,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('A MOMENT IN THE MAKING',
                    style: const TextStyle(color: AppTheme.terracotta, fontSize: 10,
                      fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                  const SizedBox(height: 14),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: AppMotion.quick,
                      child: SingleChildScrollView(
                        key: ValueKey(currentStep),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${(currentStep + 1).toString().padLeft(2, '0')}',
                            style: const TextStyle(fontFamily: 'Georgia', fontSize: 58,
                              height: 1, color: AppTheme.terracotta, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          Semantics(
                            liveRegion: true,
                            label: 'Step ${currentStep + 1} of $total. ${widget.recipe.steps[currentStep]}',
                            child: Text(widget.recipe.steps[currentStep],
                            style: TextStyle(
                              color: AppTheme.ink,
                              fontSize: [22.0, 26.0, 30.0][textScale],
                              height: 1.42,
                              fontWeight: FontWeight.w600,
                            )),
                          ),
                          const SizedBox(height: 28),
                          _ingredientPanel(widget.recipe, servings),
                        ]),
                      ),
                    ),
                  ),
                  _timerSection(session),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: currentStep == 0
                            ? null
                            : () => session.setStep(widget.recipe.id, currentStep - 1, total),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 54)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          if (currentStep == total - 1) {
                            showDialog<void>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Ready to serve?'),
                                content: const Text('You have reached the final step. Finish this cooking session?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Keep cooking')),
                                  FilledButton(onPressed: () {
                                    PlannerScope.of(context).recordCooked(widget.recipe);
                                    PlannerScope.refresh(context);
                                    Navigator.pop(dialogContext);
                                    Navigator.pop(context);
                                  }, child: const Text('Finish')),
                                ],
                              ),
                            );
                          } else {
                            session.setStep(widget.recipe.id, currentStep + 1, total);
                          }
                        },
                        icon: Icon(currentStep == total - 1 ? Icons.check : Icons.arrow_forward),
                        label: Text(currentStep == total - 1 ? 'Finish' : 'Next step'),
                        style: FilledButton.styleFrom(minimumSize: const Size(0, 54),
                          backgroundColor: AppTheme.terracotta),
                      ),
                    ),
                  ]),
                ] else ...[
                  const Expanded(child: Center(child: Text('This recipe has no instructions yet.'))),
                ],
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _ingredientPanel(Recipe recipe, int servings) {
    final session = PlannerScope.cookingOf(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('INGREDIENTS AT A GLANCE',
            style: TextStyle(fontSize: 10, letterSpacing: 1.1, color: AppTheme.olive, fontWeight: FontWeight.w800))),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: servings > 1 ? () => session.setServings(recipe.id, servings - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text('$servings', style: const TextStyle(fontWeight: FontWeight.w800)),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => session.setServings(recipe.id, servings + 1),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ]),
        const SizedBox(height: 4),
        for (final ingredient in recipe.ingredients)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              Expanded(child: Text(ingredient.name, style: const TextStyle(color: AppTheme.ink))),
              Text(ingredient.display(servings, recipe.servings, measurementSystem: PlannerScope.of(context).measurementSystem),
                style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w700)),
            ]),
          ),
      ]),
    );
  }

  Widget _timerSection(CookingSession session) {
    final timers = session.timers;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(child: Text('Kitchen timers', style: TextStyle(
          color: AppTheme.ink, fontWeight: FontWeight.w800, fontSize: 16))),
        TextButton.icon(
          onPressed: _addTimer,
          icon: const Icon(Icons.add_alarm, size: 18),
          label: const Text('Add timer'),
        ),
      ]),
      if (timers.isEmpty)
        const Text('Set a timer for simmering, resting or baking.',
          style: TextStyle(color: AppTheme.muted, fontSize: 12))
      else
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: timers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final timer = timers[index];
              return Container(
                width: 205,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.card,
                  borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.line)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(timer.label, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                    if (timer.isComplete) const Icon(Icons.check_circle, color: AppTheme.olive, size: 16),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 26, height: 26),
                      onPressed: () => session.removeTimer(timer.id),
                      icon: const Icon(Icons.close, size: 16),
                    ),
                  ]),
                  Row(children: [
                    Text(formatCookingDuration(timer.remainingNow),
                      style: const TextStyle(fontFeatures: [], fontSize: 23,
                        fontWeight: FontWeight.w800, color: AppTheme.ink)),
                    const Spacer(),
                    IconButton.filledTonal(
                      visualDensity: VisualDensity.compact,
                      onPressed: timer.isComplete ? () => session.resetTimer(timer.id)
                        : timer.isRunning ? () => session.pauseTimer(timer.id)
                        : () => session.startTimer(timer.id),
                      icon: Icon(timer.isComplete ? Icons.replay : timer.isRunning ? Icons.pause : Icons.play_arrow),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => session.resetTimer(timer.id),
                      icon: const Icon(Icons.refresh, size: 19),
                    ),
                  ]),
                ]),
              );
            },
          ),
        ),
    ]);
  }

  Future<void> _addTimer() async {
    final labelController = TextEditingController();
    final minutesController = TextEditingController(text: '5');
    final result = await showDialog<(String, int)>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add a kitchen timer'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: labelController, decoration: const InputDecoration(labelText: 'Timer label')),
          const SizedBox(height: 10),
          TextField(controller: minutesController, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Minutes')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final minutes = int.tryParse(minutesController.text.trim());
              if (minutes == null || minutes < 1 || minutes > 1440) return;
              Navigator.pop(dialogContext, (labelController.text, minutes));
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
    labelController.dispose();
    minutesController.dispose();
    if (!mounted || result == null) return;
    PlannerScope.cookingOf(context).addTimer(
      result.$1,
      Duration(minutes: result.$2),
    );
  }
}
