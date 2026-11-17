import 'package:flutter/material.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/features/recipes/presentation/custom_recipe_editor_screen.dart';
import 'package:testapp_3/features/recipes/presentation/recipe_detail_screen.dart';
import 'package:testapp_3/localization/app_localizations.dart';

class CustomRecipesScreen extends StatelessWidget {
  const CustomRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final custom = PlannerScope.of(context).customRecipes.values.toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return Scaffold(
      appBar: AppBar(title: Text(appStrings(context).label('My recipes', 'وصفاتي'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomRecipeEditorScreen())),
        icon: const Icon(Icons.add),
        label: Text(appStrings(context).label('Create recipe', 'إنشاء وصفة')),
      ),
      body: custom.isEmpty
          ? Center(child: Text(appStrings(context).label('Your personal recipes will appear here.', 'ستظهر وصفاتك الشخصية هنا.')))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: custom.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final recipe = custom[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: AppTheme.card, child: Icon(Icons.menu_book_outlined, color: AppTheme.olive)),
                    title: Text(recipe.title),
                    subtitle: Text('${recipe.totalMinutes} min · ${recipe.ingredients.length} ingredients'),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => CustomRecipeEditorScreen(recipe: recipe)));
                        } else if (value == 'delete') {
                          final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
                            title: Text(appStrings(context).label('Delete recipe?', 'حذف الوصفة؟')),
                            content: Text(appStrings(context).label('This removes the personal recipe from this device.', 'سيؤدي ذلك إلى إزالة الوصفة الشخصية من هذا الجهاز.')),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(appStrings(context).label('Cancel', 'إلغاء'))),
                              FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(appStrings(context).label('Delete', 'حذف'))),
                            ],
                          ));
                          if (confirmed == true && context.mounted) {
                            PlannerScope.of(context).deleteCustomRecipe(recipe.id);
                            PlannerScope.refresh(context);
                          }
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'edit', child: Text(appStrings(context).label('Edit', 'تعديل'))),
                        PopupMenuItem(value: 'delete', child: Text(appStrings(context).label('Delete', 'حذف'))),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
