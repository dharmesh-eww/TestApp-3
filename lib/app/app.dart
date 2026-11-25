import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/theme/app_theme.dart';
import '../features/recipes/domain/recipe.dart';
import '../features/recipes/domain/recipe_catalog.dart';
import '../features/recipes/data/recipe_catalog_loader.dart';
import '../features/recipes/data/static_recipe_content_updater.dart';
import '../core/data/app_repository.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import 'app_shell.dart';
import '../localization/app_localizations.dart';
import 'app_dependencies.dart';
import 'planner_scope.dart';
import 'recipe_catalog_scope.dart';
import '../localization/app_locale.dart';
import '../features/notifications/domain/smart_reminder_service.dart';
import '../features/notifications/domain/reminder_notification_service.dart';
import '../features/widgets/data/gather_home_widget_service.dart';

class RecipePlannerApp extends StatefulWidget {
  const RecipePlannerApp({super.key, this.repository, this.showOnboarding = false});
  final AppRepository? repository;
  final bool showOnboarding;

  @override
  State<RecipePlannerApp> createState() => _RecipePlannerAppState();
}

class _RecipePlannerAppState extends State<RecipePlannerApp> with WidgetsBindingObserver {
  late final AppDependencies dependencies = AppDependencies(repository: widget.repository);
  Timer? _cookingPersistTimer;
  Locale _locale = const Locale('en');
  List<Recipe> _catalogRecipes = recipes;
  String _contentVersion = 'bundled';
  String? _catalogPayload;
  StaticRecipeContentUpdater? _contentUpdater;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    dependencies.cookingSession.addListener(_onCookingChanged);
    unawaited(_initializeLocalData());
  }

  Future<void> _initializeLocalData() async {
    try {
      final restored = await dependencies.repository?.loadPlannerState();
      if (restored != null && mounted) {
        dependencies.plannerState.restoreFromJson(restored.toJson());
        setState(() => _locale = AppLocale.normalize(Locale(dependencies.plannerState.localeCode)));
      }

      final cached = await dependencies.repository?.loadCatalog();
      if (cached != null) {
        _catalogPayload = cached.payload;
        final document = RecipeCatalogLoader.decode(
          cached.payload,
          localeCode: dependencies.plannerState.localeCode,
        );
        if (mounted) setState(() {
          _catalogRecipes = document.recipes;
          _contentVersion = cached.contentVersion;
        });
      } else {
        final payload = await rootBundle.loadString(RecipeCatalogLoader.assetPath);
        _catalogPayload = payload;
        final document = RecipeCatalogLoader.decode(
          payload,
          localeCode: dependencies.plannerState.localeCode,
        );
        if (!mounted) return;
        setState(() => _catalogRecipes = document.recipes);
      }
      final cookingSnapshot = await dependencies.repository?.loadCookingSession();
      if (cookingSnapshot != null && mounted) {
        dependencies.cookingSession.restoreFromJson(cookingSnapshot);
      }
      await _syncPlatformIntegrations();
    } on CatalogLoadException {
      // Keep the in-code catalog active if the bundled document is invalid.
    } catch (_) {
      // Database or asset failures must not block the in-memory starter experience.
    }
  }

  void _onPlannerChanged() {
    setState(() {});
    final store = dependencies.repository;
    if (store != null) unawaited(store.savePlannerState(dependencies.plannerState).catchError((_) {}));
    unawaited(_syncPlatformIntegrations());
  }

  Future<void> _syncPlatformIntegrations() async {
    final state = dependencies.plannerState;
    final catalog = [..._catalogRecipes, ...state.customRecipes.values];
    try {
      await SmartReminderService.sync(state, catalog);
      await ReminderNotificationService.sync(state);
      await GatherHomeWidgetService.sync(state, catalog);
      final store = dependencies.repository;
      if (store != null) await store.savePlannerState(state);
      if (mounted) setState(() {});
    } catch (_) {
      // Native integrations are optional; core planning remains usable.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_syncPlatformIntegrations());
  }

  void _onCookingChanged() {
    if (_cookingPersistTimer != null) return;
    _cookingPersistTimer = Timer(const Duration(seconds: 1), () {
      _cookingPersistTimer = null;
      final store = dependencies.repository;
      if (store != null) {
        unawaited(store.saveCookingSession(dependencies.cookingSession.toJson()).catchError((_) {}));
      }
    });
  }

  Future<bool> _checkForContentUpdates() async {
    final uri = Uri.parse('https://raw.githubusercontent.com/dharmesh-eww/TestApp-3/main/content/manifest.json');
    try {
      final update = await (_contentUpdater ??= StaticRecipeContentUpdater()).checkAndDownload(uri, localeCode: _locale.languageCode);
      if (update.contentVersion == _contentVersion) return false;
      await dependencies.repository?.activateCatalog(contentVersion: update.contentVersion, payload: update.payload);
      if (!mounted) return false;
      setState(() {
        _catalogPayload = update.payload;
        _catalogRecipes = update.document.recipes;
        _contentVersion = update.contentVersion;
      });
      unawaited(_syncPlatformIntegrations());
      return true;
    } on ContentUpdateException {
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _cookingPersistTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    dependencies.cookingSession.removeListener(_onCookingChanged);
    final store = dependencies.repository;
    if (store != null) {
      unawaited(store.saveCookingSession(dependencies.cookingSession.toJson()).catchError((_) {}));
    }
    _contentUpdater?.close();
    dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppTheme.setDarkMode(dependencies.plannerState.themePreference == 'dark' ||
        (dependencies.plannerState.themePreference == 'system' && WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark));
    return PlannerScope(
      state: dependencies.plannerState,
      cookingSession: dependencies.cookingSession,
      onChanged: _onPlannerChanged,
      child: RecipeCatalogScope(
        recipes: [..._catalogRecipes, ...dependencies.plannerState.customRecipes.values],
        contentVersion: _contentVersion,
        onCheckForUpdates: _checkForContentUpdates,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Gather — Recipe Planner',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: switch (dependencies.plannerState.themePreference) {
            'light' => ThemeMode.light,
            'dark' => ThemeMode.dark,
            _ => ThemeMode.system,
          },
          locale: _locale,
          supportedLocales: AppLocale.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: (!widget.showOnboarding || dependencies.plannerState.onboardingComplete)
              ? AppShell(
            onLocaleChanged: (locale) {
            final selectedLocale = AppLocale.normalize(locale);
            dependencies.plannerState.localeCode = selectedLocale.languageCode;
            setState(() {
              _locale = selectedLocale;
              final payload = _catalogPayload;
              if (payload != null) {
                _catalogRecipes = RecipeCatalogLoader.decode(
                  payload,
                  localeCode: selectedLocale.languageCode,
                ).recipes;
              }
            });
            _onPlannerChanged();
          },
          )
              : OnboardingScreen(onComplete: () {
                  dependencies.plannerState.onboardingComplete = true;
                  _onPlannerChanged();
                }),
        ),
      ),
    );
  }
}

