import 'package:flutter/material.dart';
import 'package:testapp_3/app/gather_visuals.dart';
import 'package:testapp_3/app/planner_scope.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/localization/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});
  final VoidCallback onComplete;
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _cuisines = <String, String>{
    'indian':'Indian','north_indian':'North Indian','south_indian':'South Indian','gujarati':'Gujarati',
    'chinese':'Chinese','japanese':'Japanese','italian':'Italian','korean':'Korean','mexican':'Mexican',
    'american':'American','african':'African','british':'British','spanish':'Spanish','thai':'Thai',
    'mediterranean':'Mediterranean','vietnamese':'Vietnamese','greek':'Greek','french':'French',
    'middle_eastern':'Middle Eastern','turkish':'Turkish',
  };
  static const _foodTypes = <String, String>{
    'vegetarian':'Vegetarian','vegan':'Vegan','eggetarian':'Eggetarian',
    'nonVegetarian':'Non-vegetarian','pescatarian':'Pescatarian',
  };
  static const _allergens = <String, String>{
    'peanuts':'Peanuts','tree nuts':'Tree nuts','milk':'Milk','eggs':'Eggs','wheat':'Wheat',
    'gluten':'Gluten','soy':'Soy','fish':'Fish','shellfish':'Shellfish','sesame':'Sesame',
    'mustard':'Mustard','celery':'Celery','lupin':'Lupin','sulphites':'Sulphites',
  };
  static const _dietary = <String, String>{
    'plant_based':'More plant-based meals','gluten_free':'Gluten-free ideas',
    'dairy_free':'Dairy-free ideas','high_protein':'High-protein meals',
  };
  static const _mealTypes = <String, String>{
    'breakfast':'Breakfast','lunch':'Lunch','dinner':'Dinner','snacks':'Snacks',
  };
  int _page = 0;
  static const _pageCount = 6;

  void _toggle(Set<String> values, String value) {
    setState(() { if (!values.add(value)) values.remove(value); });
    PlannerScope.refresh(context);
  }
  void _next() {
    if (_page == _pageCount - 1) { widget.onComplete(); return; }
    setState(() => _page++);
  }

  @override
  Widget build(BuildContext context) {
    final state = PlannerScope.of(context);
    final strings = appStrings(context);
    final title = switch (_page) {
      0 => 'Welcome to Gather',
      1 => 'A kitchen that feels like yours',
      2 => 'What cuisines do you enjoy?',
      3 => 'What do you like to eat?',
      4 => 'Any ingredients to avoid?',
      _ => 'A little more about your cooking',
    };
    final subtitle = switch (_page) {
      0 => 'Good food starts with ideas. Let’s make finding your next favourite recipe feel easy.',
      1 => 'We’ll use a few quick choices to shape recipe ideas around your tastes. You can change everything later.',
      2 => 'Choose as many as you like. We’ll bring recipes from the places and flavours you love.',
      3 => 'Select every style that works for you. You can choose more than one.',
      4 => 'Tell us about any food allergies or ingredients you need to avoid. You can leave this blank.',
      _ => 'Choose the meals you make and how much time you usually have.',
    };
    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(22,14,22,12), child: Row(children: [
            Container(width:40,height:40,decoration:BoxDecoration(color:AppTheme.terracotta.withOpacity(.12),borderRadius:BorderRadius.circular(13)),child:const Icon(Icons.spa_rounded,color:AppTheme.terracotta)),
            const SizedBox(width:10),const Text('GATHER',style:TextStyle(fontWeight:FontWeight.w900,letterSpacing:2.2,color:AppTheme.ink)),
            const Spacer(),Text('${_page+1} / $_pageCount',style:TextStyle(color:AppTheme.muted,fontSize:12,fontWeight:FontWeight.w700)),
          ])),
          Padding(padding:const EdgeInsets.symmetric(horizontal:22),child:ClipRRect(borderRadius:BorderRadius.circular(10),child:LinearProgressIndicator(value:(_page+1)/_pageCount,minHeight:5,backgroundColor:AppTheme.line,color:AppTheme.terracotta))),
          Expanded(child: AnimatedSwitcher(duration:const Duration(milliseconds:240),child:SingleChildScrollView(
            key:ValueKey(_page),padding:const EdgeInsets.fromLTRB(22,24,22,24),
            child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              if(_page<2)...[
                Container(width:double.infinity,height:205,decoration:BoxDecoration(color:_page==0?const Color(0xFFF0E5D7):const Color(0xFFE8EDDF),borderRadius:BorderRadius.circular(26)),
                  child:Stack(alignment:Alignment.center,children:[Icon(_page==0?Icons.ramen_dining_rounded:Icons.auto_awesome_rounded,size:118,color:AppTheme.olive.withOpacity(.15)),GatherVisuals.heroIllustration(width:290,height:198)])),
                const SizedBox(height:24),
              ] else Container(width:54,height:54,decoration:BoxDecoration(color:AppTheme.terracotta.withOpacity(.12),borderRadius:BorderRadius.circular(17)),
                child:Icon(_page==2?Icons.public_rounded:_page==3?Icons.restaurant_menu_rounded:_page==4?Icons.health_and_safety_outlined:Icons.timer_outlined,color:AppTheme.terracotta,size:27)),
              const SizedBox(height:15),
              Text(strings.label(title,title),style:Theme.of(context).textTheme.headlineMedium?.copyWith(fontFamily:'Georgia',fontWeight:FontWeight.bold,color:AppTheme.ink)),
              const SizedBox(height:9),Text(strings.label(subtitle,subtitle),style:TextStyle(color:AppTheme.muted,height:1.5,fontSize:14)),
              const SizedBox(height:24),
              if(_page==0)...[
                const _IntroPoint(icon:Icons.menu_book_rounded,title:'Find recipes you’ll love',detail:'Explore a growing collection of meal ideas.'),
                const _IntroPoint(icon:Icons.calendar_month_rounded,title:'Plan your week',detail:'Turn favourites into a simple meal plan.'),
                const _IntroPoint(icon:Icons.shopping_basket_outlined,title:'Make shopping easier',detail:'Keep ingredients and groceries organised.'),
              ],
              if(_page==1)...[
                const _IntroPoint(icon:Icons.tune_rounded,title:'Your taste comes first',detail:'Choose cuisines, food styles and the meals you enjoy.'),
                const _IntroPoint(icon:Icons.shield_outlined,title:'Keep allergies in mind',detail:'Recipes can be filtered using the allergens you list.'),
                const _IntroPoint(icon:Icons.edit_outlined,title:'Change it whenever you like',detail:'Your preferences are always available in Settings.'),
              ],
              if(_page==2)_OptionWrap(options:_cuisines,selected:state.preferredCuisines,onTap:(v)=>_toggle(state.preferredCuisines,v)),
              if(_page==3)...[
                _OptionWrap(options:_foodTypes,selected:state.preferredFoodTypes,onTap:(v)=>_toggle(state.preferredFoodTypes,v)),
                const SizedBox(height:22),Text('A few recipe preferences',style:Theme.of(context).textTheme.titleMedium),
                const SizedBox(height:10),_OptionWrap(options:_dietary,selected:state.preferredDietaryTags,onTap:(v)=>_toggle(state.preferredDietaryTags,v)),
              ],
              if(_page==4)...[
                Container(decoration:BoxDecoration(color:AppTheme.card,border:Border.all(color:AppTheme.line),borderRadius:BorderRadius.circular(15)),
                  child:CheckboxListTile(value:state.allergies.isEmpty,onChanged:(v){setState(()=>state.allergies.clear());PlannerScope.refresh(context);},
                    title:const Text('No known food allergies'),subtitle:const Text('Choose this if there is nothing you need to avoid.'),controlAffinity:ListTileControlAffinity.leading,activeColor:AppTheme.olive)),
                const SizedBox(height:14),Text('Or select ingredients you are allergic to',style:Theme.of(context).textTheme.titleSmall),
                const SizedBox(height:8),_OptionWrap(options:_allergens,selected:state.allergies,onTap:(v)=>_toggle(state.allergies,v)),
                const SizedBox(height:10),Text('Allergy filters are a guide, not a guarantee. Always check ingredient labels and confirm food safety yourself.',style:TextStyle(color:AppTheme.muted,fontSize:11,height:1.45)),
              ],
              if(_page==5)...[
                Text('Which meals do you usually look for?',style:Theme.of(context).textTheme.titleMedium),
                const SizedBox(height:10),_OptionWrap(options:_mealTypes,selected:state.preferredMealTypes,onTap:(v)=>_toggle(state.preferredMealTypes,v)),
                const SizedBox(height:22),Text('Your usual cooking time',style:Theme.of(context).textTheme.titleMedium),
                const SizedBox(height:5),Text('We’ll prioritise recipes that fit your schedule.',style:TextStyle(color:AppTheme.muted,fontSize:12)),
                const SizedBox(height:10),Wrap(spacing:8,runSpacing:8,children:[
                  for(final minutes in const [15,30,45,60])ChoiceChip(label:Text('Under $minutes min'),selected:state.preferredMaxCookingMinutes==minutes,
                    onSelected:(_){setState(()=>state.preferredMaxCookingMinutes=minutes);PlannerScope.refresh(context);},selectedColor:AppTheme.terracotta.withOpacity(.16)),
                ]),
                TextButton(onPressed:(){setState(()=>state.preferredMaxCookingMinutes=null);PlannerScope.refresh(context);},child:const Text('No time preference')),
              ],
            ]),
          ))),
          Padding(padding:const EdgeInsets.fromLTRB(22,10,22,20),child:Row(children:[
            if(_page>0)TextButton.icon(onPressed:()=>setState(()=>_page--),icon:const Icon(Icons.arrow_back_rounded),label:Text(strings.label('Back','رجوع'))) else const SizedBox(width:78),
            const Spacer(),
            if(_page>=2&&_page<_pageCount-1)TextButton(onPressed:_next,child:Text(strings.label('Skip','تخطي'))),
            const SizedBox(width:8),
            FilledButton(style:FilledButton.styleFrom(backgroundColor:AppTheme.terracotta,padding:const EdgeInsets.symmetric(horizontal:25,vertical:14)),
              onPressed:_next,child:Text(strings.label(_page==_pageCount-1?'Continue':'Next',_page==_pageCount-1?'متابعة':'التالي'))),
          ])),
        ]),
      ))),
    );
  }
}

class _OptionWrap extends StatelessWidget {
  const _OptionWrap({required this.options,required this.selected,required this.onTap});
  final Map<String,String> options; final Set<String> selected; final ValueChanged<String> onTap;
  @override Widget build(BuildContext context)=>Wrap(spacing:9,runSpacing:9,children:[
    for(final entry in options.entries)FilterChip(label:Text(appStrings(context).label(entry.value,entry.value)),selected:selected.contains(entry.key),onSelected:(_)=>onTap(entry.key),
      showCheckmark:true,selectedColor:AppTheme.terracotta.withOpacity(.15),checkmarkColor:AppTheme.terracotta,
      side:BorderSide(color:selected.contains(entry.key)?AppTheme.terracotta:AppTheme.line),
      labelStyle:TextStyle(color:selected.contains(entry.key)?AppTheme.terracotta:AppTheme.ink,fontWeight:FontWeight.w600)),
  ]);
}

class _IntroPoint extends StatelessWidget {
  const _IntroPoint({required this.icon,required this.title,required this.detail});
  final IconData icon; final String title; final String detail;
  @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(bottom:13),child:Row(children:[
    Container(width:42,height:42,decoration:BoxDecoration(color:AppTheme.olive.withOpacity(.12),borderRadius:BorderRadius.circular(13)),child:Icon(icon,color:AppTheme.olive)),
    const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(title,style:const TextStyle(fontWeight:FontWeight.w800,color:AppTheme.ink)),const SizedBox(height:3),
      Text(detail,style:TextStyle(color:AppTheme.muted,fontSize:12)),
    ])),
  ]));
}
