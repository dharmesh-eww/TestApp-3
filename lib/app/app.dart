import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/theme/app_theme.dart';
import '../features/recipes/domain/recipe.dart';
import '../features/recipes/domain/recipe_catalog.dart';
import '../features/recipes/data/recipe_catalog_loader.dart';
import '../features/recipes/data/static_recipe_content_updater.dart';
import '../data/local/planner_repository.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/today/presentation/today_screen.dart';
import '../features/recipes/presentation/discover_screen.dart';
import '../features/planning/presentation/plan_screen.dart';
import '../features/groceries/presentation/grocery_screen.dart';
import '../features/kitchen/presentation/kitchen_home_screen.dart';
import '../localization/app_localizations.dart';
import 'app_dependencies.dart';
import 'planner_scope.dart';
import 'recipe_catalog_scope.dart';
import 'app_tab_navigation.dart';

class RecipePlannerApp extends StatefulWidget {
  const RecipePlannerApp({super.key, this.repository, this.showOnboarding = false});
  final PlannerRepository? repository;
  final bool showOnboarding;

  @override
  State<RecipePlannerApp> createState() => _RecipePlannerAppState();
}

class _RecipePlannerAppState extends State<RecipePlannerApp> {
  final AppDependencies dependencies = AppDependencies();
  Timer? _cookingPersistTimer;
  Locale _locale = const Locale('en');
  List<Recipe> _catalogRecipes = recipes;
  String _contentVersion = 'bundled';
  String? _catalogPayload;
  StaticRecipeContentUpdater? _contentUpdater;

  @override
  void initState() {
    super.initState();
    dependencies.cookingSession.addListener(_onCookingChanged);
    unawaited(_initializeLocalData());
  }

  Future<void> _initializeLocalData() async {
    try {
      final restored = await widget.repository?.loadPlannerState();
      if (restored != null && mounted) {
        dependencies.plannerState.restoreFromJson(restored.toJson());
        setState(() => _locale = Locale(dependencies.plannerState.localeCode));
      }

      final cached = await widget.repository?.loadCatalog();
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
      final cookingSnapshot = await widget.repository?.loadCookingSession();
      if (cookingSnapshot != null && mounted) {
        dependencies.cookingSession.restoreFromJson(cookingSnapshot);
      }
    } on CatalogLoadException {
      // Keep the in-code catalog active if the bundled document is invalid.
    } catch (_) {
      // Database or asset failures must not block the in-memory starter experience.
    }
  }

  void _onPlannerChanged() {
    setState(() {});
    final store = widget.repository;
    if (store != null) unawaited(store.savePlannerState(dependencies.plannerState).catchError((_) {}));
  }

  void _onCookingChanged() {
    if (_cookingPersistTimer != null) return;
    _cookingPersistTimer = Timer(const Duration(seconds: 1), () {
      _cookingPersistTimer = null;
      final store = widget.repository;
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
      await widget.repository?.activateCatalog(contentVersion: update.contentVersion, payload: update.payload);
      if (!mounted) return false;
      setState(() {
        _catalogPayload = update.payload;
        _catalogRecipes = update.document.recipes;
        _contentVersion = update.contentVersion;
      });
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
    dependencies.cookingSession.removeListener(_onCookingChanged);
    final store = widget.repository;
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
          supportedLocales: const [Locale('en'), Locale('hi'), Locale('gu'), Locale('ar'), Locale('ja'), Locale('pt'), Locale('id'), Locale('es'), Locale('zh')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: (!widget.showOnboarding || dependencies.plannerState.onboardingComplete)
              ? AppShell(
            onLocaleChanged: (locale) {
            dependencies.plannerState.localeCode = locale.languageCode;
            setState(() {
              _locale = locale;
              final payload = _catalogPayload;
              if (payload != null) {
                _catalogRecipes = RecipeCatalogLoader.decode(
                  payload,
                  localeCode: locale.languageCode,
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

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.onLocaleChanged});
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selected = 0;
  List<Widget> get pages => [
    const TodayScreen(),
    const DiscoverScreen(),
    const PlanScreen(),
    const GroceryScreen(),
    KitchenScreen(onLocaleChanged: widget.onLocaleChanged),
  ];

  void selectTab(int index) {
    if (index < 0 || index >= pages.length || index == selected) return;
    setState(() => selected = index);
  }

  @override
  Widget build(BuildContext context) {
    return AppTabNavigation(onSelect: selectTab, child: Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: PlannerScope.of(context).reduceMotion ? Duration.zero : AppMotion.page,
                switchInCurve: AppMotion.enter,
                switchOutCurve: AppMotion.exit,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, .018),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(selected),
                  child: pages[selected],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (value) => setState(() => selected = value),
        destinations: [
          NavigationDestination(icon: Icon(Icons.wb_sunny_outlined), selectedIcon: Icon(Icons.wb_sunny), label: appStrings(context).today),
          NavigationDestination(icon: Icon(Icons.search), label: appStrings(context).recipes),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: appStrings(context).plan),
          NavigationDestination(icon: Icon(Icons.shopping_basket_outlined), label: appStrings(context).groceries),
          NavigationDestination(icon: Icon(Icons.shelves), label: appStrings(context).kitchen),
        ],
      ),
    ));
  }
}
