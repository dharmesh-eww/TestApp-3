import 'dart:async';

import 'package:flutter/widgets.dart';

/// A single countdown whose remaining time is derived from an absolute deadline.
/// This keeps it accurate when Dart timers are throttled in the background.
class CookingTimerEntry {
  CookingTimerEntry({
    required this.id,
    required this.label,
    required this.duration,
  }) : remaining = duration;

  final String id;
  final String label;
  final Duration duration;
  Duration remaining;
  DateTime? _endsAt;
  bool isRunning = false;
  bool isComplete = false;

  Duration get remainingNow {
    if (!isRunning || _endsAt == null) return remaining;
    final value = _endsAt!.difference(DateTime.now());
    return value.isNegative ? Duration.zero : value;
  }

  double get progress {
    if (duration.inMilliseconds <= 0) return 1;
    return (1 - remainingNow.inMilliseconds / duration.inMilliseconds)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  void start() {
    if (isComplete || isRunning || remaining <= Duration.zero) return;
    _endsAt = DateTime.now().add(remaining);
    isRunning = true;
  }

  void pause() {
    if (!isRunning) return;
    remaining = remainingNow;
    _endsAt = null;
    isRunning = false;
    if (remaining == Duration.zero) isComplete = true;
  }

  void reset() {
    _endsAt = null;
    remaining = duration;
    isRunning = false;
    isComplete = false;
  }

  bool refresh() {
    if (!isRunning) return false;
    final next = remainingNow;
    if (next == Duration.zero) {
      remaining = Duration.zero;
      _endsAt = null;
      isRunning = false;
      isComplete = true;
      return true;
    }
    remaining = next;
    return false;
  }
}

/// App-scoped in-memory cooking state. No external state-management package.
class CookingSession extends ChangeNotifier with WidgetsBindingObserver {
  CookingSession() {
    WidgetsBinding.instance.addObserver(this);
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => refresh());
  }

  final Map<String, int> _steps = {};
  final Map<String, int> _servings = {};
  final List<CookingTimerEntry> _timers = [];
  Timer? _ticker;
  int _nextTimerId = 0;

  List<CookingTimerEntry> get timers => List.unmodifiable(_timers);

  int stepFor(String recipeId) => _steps[recipeId] ?? 0;
  int servingsFor(String recipeId, int fallback) => _servings[recipeId] ?? fallback;

  void setStep(String recipeId, int step, int total) {
    if (total <= 0) return;
    final safeStep = step.clamp(0, total - 1).toInt();
    if (_steps[recipeId] == safeStep) return;
    _steps[recipeId] = safeStep;
    notifyListeners();
  }

  void setServings(String recipeId, int servings) {
    if (servings < 1 || _servings[recipeId] == servings) return;
    _servings[recipeId] = servings;
    notifyListeners();
  }

  CookingTimerEntry addTimer(String label, Duration duration) {
    final timer = CookingTimerEntry(
      id: 'cooking-timer-${_nextTimerId++}',
      label: label.trim().isEmpty ? 'Cooking timer' : label.trim(),
      duration: duration,
    );
    _timers.add(timer);
    notifyListeners();
    return timer;
  }

  void startTimer(String id) => _mutateTimer(id, (timer) => timer.start());
  void pauseTimer(String id) => _mutateTimer(id, (timer) => timer.pause());
  void resetTimer(String id) => _mutateTimer(id, (timer) => timer.reset());

  void removeTimer(String id) {
    _timers.removeWhere((timer) => timer.id == id);
    notifyListeners();
  }

  void refresh() {
    var changed = false;
    for (final timer in _timers) {
      if (timer.refresh()) changed = true;
    }
    if (changed || _timers.any((timer) => timer.isRunning)) notifyListeners();
  }

  void _mutateTimer(String id, void Function(CookingTimerEntry) action) {
    for (final timer in _timers) {
      if (timer.id == id) {
        action(timer);
        notifyListeners();
        return;
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }
}

String formatCookingDuration(Duration duration) {
  final seconds = duration.inSeconds.clamp(0, 599999);
  final minutes = seconds ~/ 60;
  final remainder = seconds % 60;
  final hours = minutes ~/ 60;
  final shownMinutes = minutes % 60;
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${shownMinutes.toString().padLeft(2, '0')}:${remainder.toString().padLeft(2, '0')}';
  }
  return '${shownMinutes.toString().padLeft(2, '0')}:${remainder.toString().padLeft(2, '0')}';
}
