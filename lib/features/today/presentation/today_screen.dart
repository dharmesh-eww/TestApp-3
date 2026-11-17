import 'package:flutter/material.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/localization/app_localizations.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/app/recipe_catalog_scope.dart';
import 'package:testapp_3/app/app_widgets.dart';
import 'package:testapp_3/app/app_tab_navigation.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = RecipeCatalogScope.of(context);
    final featured = catalog.first;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(appStrings(context).label('MONDAY, AT YOUR PACE', 'أسبوعك على إيقاعك'), style: TextStyle(color: AppTheme.terracotta, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            SizedBox(height: 7),
            Text(appStrings(context).label('A little more joy\nin the kitchen.', 'مزيد من البهجة\nفي مطبخك.'), style: TextStyle(fontFamily: 'Georgia', fontSize: 31, height: 1.08, color: AppTheme.ink, fontWeight: FontWeight.bold)),
          ])),
          CircleAvatar(radius: 24, backgroundColor: const Color(0xFFE9E4D8), child: Icon(Icons.spa_outlined, color: AppTheme.olive)),
        ]),
        const SizedBox(height: 24),
        SectionHeading(title: appStrings(context).label('Today’s inspiration', 'إلهام اليوم'), action: appStrings(context).label('See all', 'عرض الكل'), onTap: () => goToAppTab(context, 1)),
        const SizedBox(height: 12),
        FeaturedRecipe(recipe: featured),
        const SizedBox(height: 26),
        SectionHeading(title: appStrings(context).label('Made for your week', 'اختيارات لأسبوعك'), action: appStrings(context).label('Open plan', 'افتح الخطة'), onTap: () => goToAppTab(context, 2)),
        const SizedBox(height: 12),
        const WeekStrip(),
        const SizedBox(height: 26),
        SectionHeading(title: appStrings(context).label('A few good ideas', 'بعض الأفكار الجميلة'), action: appStrings(context).label('Explore', 'استكشف'), onTap: () => goToAppTab(context, 1)),
        const SizedBox(height: 12),
        SizedBox(
          height: 218,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: catalog.length - 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => SizedBox(width: 174, child: RecipeTile(recipe: catalog[index + 1])),
          ),
        ),
      ],
    );
  }
}
