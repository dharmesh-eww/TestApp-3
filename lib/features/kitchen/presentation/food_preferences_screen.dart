import 'package:flutter/material.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/localization/app_localizations.dart';

class FoodPreferencesScreen extends StatefulWidget {
  const FoodPreferencesScreen({super.key});
  @override
  State<FoodPreferencesScreen> createState() => _FoodPreferencesScreenState();
}

class _FoodPreferencesScreenState extends State<FoodPreferencesScreen> {
  static const _cuisines = <String,String>{
    'indian':'Indian','north_indian':'North Indian','south_indian':'South Indian','gujarati':'Gujarati',
    'chinese':'Chinese','japanese':'Japanese','italian':'Italian','korean':'Korean','mexican':'Mexican',
    'american':'American','african':'African','british':'British','spanish':'Spanish','thai':'Thai',
    'mediterranean':'Mediterranean','vietnamese':'Vietnamese','greek':'Greek','french':'French',
    'middle_eastern':'Middle Eastern','turkish':'Turkish',
  };
  static const _foodTypes = <String,String>{
    'vegetarian':'Vegetarian','vegan':'Vegan','eggetarian':'Eggetarian',
    'nonVegetarian':'Non-vegetarian','pescatarian':'Pescatarian',
  };
  static const _allergens = <String,String>{
    'peanuts':'Peanuts','tree nuts':'Tree nuts','milk':'Milk','eggs':'Eggs','wheat':'Wheat',
    'gluten':'Gluten','soy':'Soy','fish':'Fish','shellfish':'Shellfish','sesame':'Sesame',
    'mustard':'Mustard','celery':'Celery','lupin':'Lupin','sulphites':'Sulphites',
  };
  static const _dietary = <String,String>{
    'plant_based':'Plant based','gluten_free':'Gluten free','dairy_free':'Dairy free','high_protein':'High protein',
  };
  static const _meals = <String,String>{
    'breakfast':'Breakfast','lunch':'Lunch','dinner':'Dinner','snacks':'Snacks',
  };

  late Set<String> _cuisine;
  late Set<String> _foodTypes;
  late Set<String> _allergies;
  late Set<String> _dietary;
  late Set<String> _mealsSelected;
  int? _maxMinutes;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final state = PlannerScope.of(context);
    _cuisine = {...state.preferredCuisines};
    _foodTypes = {...state.preferredFoodTypes};
    _allergies = {...state.allergies};
    _dietary = {...state.preferredDietaryTags};
    _mealsSelected = {...state.preferredMealTypes};
    _maxMinutes = state.preferredMaxCookingMinutes;
  }

  void _toggle(Set<String> values,String key) {
    setState(() { if(!values.add(key)) values.remove(key); _dirty=true; });
  }

  void _save() {
    final state = PlannerScope.of(context);
    state.preferredCuisines..clear()..addAll(_cuisine);
    state.preferredFoodTypes..clear()..addAll(_foodTypes);
    state.allergies..clear()..addAll(_allergies);
    state.preferredDietaryTags..clear()..addAll(_dietary);
    state.preferredMealTypes..clear()..addAll(_mealsSelected);
    state.preferredMaxCookingMinutes = _maxMinutes;
    PlannerScope.refresh(context);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(appStrings(context).label('Your recipe preferences have been updated.','تم تحديث تفضيلات الوصفات.'))));
  }

  @override
  Widget build(BuildContext context) {
    final strings = appStrings(context);
    return Scaffold(
      backgroundColor: AppTheme.paper,
      appBar: AppBar(title:Text(strings.label('Recipe preferences','تفضيلات الوصفات')),actions:[
        TextButton(onPressed:(){
          setState((){_cuisine.clear();_foodTypes.clear();_allergies.clear();_dietary.clear();_mealsSelected.clear();_maxMinutes=null;_dirty=true;});
        },child:Text(strings.label('Reset','إعادة ضبط'))),
      ]),
      body: ListView(padding:const EdgeInsets.fromLTRB(18,8,18,24),children:[
        Container(
          padding:const EdgeInsets.all(19),
          decoration:BoxDecoration(
            gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF344B3F),Color(0xFF526A54)]),
            borderRadius:BorderRadius.circular(23),
          ),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Icon(Icons.restaurant_menu_rounded,color:Color(0xFFE6C8A5),size:28),
            const SizedBox(height:12),
            Text(strings.label('Your taste, your recipe feed','ذوقك يحدد وصفاتك'),style:const TextStyle(color:Colors.white,fontFamily:'Georgia',fontSize:23,fontWeight:FontWeight.bold)),
            const SizedBox(height:7),
            Text(strings.label('Adjust these choices whenever your cravings change. Gather uses them to shape Today and Discover.','عدّل اختياراتك متى تغيرت رغباتك. يستخدم Gather هذه التفضيلات لتخصيص اليوم والاكتشاف.'),style:const TextStyle(color:Colors.white70,height:1.45,fontSize:12)),
          ]),
        ),
        const SizedBox(height:18),
        _PreferenceSection(
          number:'01',title:strings.label('Cuisines you love','المطابخ التي تحبها'),
          description:strings.label('Pick as many cuisines as you enjoy.','اختر المطابخ التي تفضلها.'),
          child:_PreferenceChips(options:_cuisines,selected:_cuisine,onTap:(v)=>_toggle(_cuisine,v)),
        ),
        _PreferenceSection(
          number:'02',title:strings.label('Food style','نوع الطعام'),
          description:strings.label('Choose the food types you are happy to eat.','اختر أنواع الطعام التي تناسبك.'),
          child:_PreferenceChips(options:_foodTypes,selected:_foodTypes,onTap:(v)=>_toggle(_foodTypes,v)),
        ),
        _PreferenceSection(
          number:'03',title:strings.label('Dietary preferences','التفضيلات الغذائية'),
          description:strings.label('We’ll favour recipes that match these tags.','سنفضل الوصفات التي تطابق هذه التصنيفات.'),
          child:_PreferenceChips(options:_dietary,selected:_dietary,onTap:(v)=>_toggle(_dietary,v)),
        ),
        _PreferenceSection(
          number:'04',title:strings.label('Allergy exclusions','استبعاد مسببات الحساسية'),
          description:strings.label('Recipes without verified allergen information are hidden when an allergy is selected. Always check food labels.','تُخفى الوصفات التي لا تحتوي على معلومات حساسية موثقة عند تحديد حساسية. تحقق دائمًا من ملصقات الطعام.'),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            OutlinedButton.icon(
              onPressed:(){setState((){_allergies.clear();_dirty=true;});},
              icon:const Icon(Icons.check_circle_outline),
              label:Text(strings.label('No known allergies','لا توجد حساسية معروفة')),
            ),
            const SizedBox(height:8),
            _PreferenceChips(options:_allergens,selected:_allergies,onTap:(v)=>_toggle(_allergies,v)),
          ]),
        ),
        _PreferenceSection(
          number:'05',title:strings.label('What do you cook?','ما الوجبات التي تحضرها؟'),
          description:strings.label('Choose the meals you usually browse for.','اختر الوجبات التي تبحث عنها عادةً.'),
          child:_PreferenceChips(options:_meals,selected:_mealsSelected,onTap:(v)=>_toggle(_mealsSelected,v)),
        ),
        _PreferenceSection(
          number:'06',title:strings.label('Time in the kitchen','الوقت في المطبخ'),
          description:strings.label('Set the longest cooking time you’d prefer.','حدد أطول مدة طهي تفضلها.'),
          child:Wrap(spacing:8,runSpacing:8,children:[
            for(final minutes in const [15,30,45,60])
              ChoiceChip(label:Text('Up to $minutes min'),selected:_maxMinutes==minutes,onSelected:(_){setState(()=>_maxMinutes=minutes);}),
            ChoiceChip(label:Text(strings.label('Any time','أي وقت')),selected:_maxMinutes==null,onSelected:(_){setState(()=>_maxMinutes=null);}),
          ]),
        ),
        const SizedBox(height:16),
        FilledButton.icon(
          key:const Key('save-food-preferences'),
          onPressed:_save,
          style:FilledButton.styleFrom(backgroundColor:AppTheme.terracotta,padding:const EdgeInsets.symmetric(vertical:15)),
          icon:const Icon(Icons.check_rounded),
          label:Text(strings.label('Save preferences','حفظ التفضيلات')),
        ),
      ]),
    );
  }
}

class _PreferenceSection extends StatelessWidget {
  const _PreferenceSection({required this.number,required this.title,required this.description,required this.child});
  final String number,title,description; final Widget child;
  @override Widget build(BuildContext context)=>Container(
    margin:const EdgeInsets.only(bottom:13),padding:const EdgeInsets.all(16),
    decoration:BoxDecoration(color:AppTheme.card,borderRadius:BorderRadius.circular(19),border:Border.all(color:AppTheme.line)),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[
        Container(width:30,height:30,alignment:Alignment.center,decoration:BoxDecoration(color:AppTheme.terracotta.withOpacity(.12),borderRadius:BorderRadius.circular(10)),
          child:Text(number,style:const TextStyle(color:AppTheme.terracotta,fontWeight:FontWeight.w900,fontSize:11))),
        const SizedBox(width:10),Expanded(child:Text(title,style:Theme.of(context).textTheme.titleMedium)),
      ]),
      const SizedBox(height:5),Text(description,style:TextStyle(color:AppTheme.muted,fontSize:11,height:1.4)),
      const SizedBox(height:13),child,
    ]),
  );
}

class _PreferenceChips extends StatelessWidget {
  const _PreferenceChips({required this.options,required this.selected,required this.onTap});
  final Map<String,String> options; final Set<String> selected; final ValueChanged<String> onTap;
  @override Widget build(BuildContext context)=>Wrap(spacing:8,runSpacing:8,children:[
    for(final entry in options.entries)
      FilterChip(label:Text(appStrings(context).label(entry.value,entry.value)),selected:selected.contains(entry.key),onSelected:(_)=>onTap(entry.key),
        showCheckmark:false,selectedColor:AppTheme.olive.withOpacity(.14),
        side:BorderSide(color:selected.contains(entry.key)?AppTheme.olive:AppTheme.line),
        labelStyle:TextStyle(color:selected.contains(entry.key)?AppTheme.olive:AppTheme.ink,fontWeight:FontWeight.w600,fontSize:12)),
  ]);
}
