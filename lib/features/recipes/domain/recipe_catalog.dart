import 'recipe.dart';

enum RecipeSort { recommended, quickest, title }

const recipeCategories = <RecipeCategory>[
  RecipeCategory(id: 'all', name: 'All recipes'),
  RecipeCategory(id: 'breakfast', name: 'Breakfast'),
  RecipeCategory(id: 'lunch', name: 'Lunch'),
  RecipeCategory(id: 'dinner', name: 'Dinner'),
  RecipeCategory(id: 'snacks', name: 'Snacks'),
];

/// Curated local catalog shared by home, discovery, planning and favourites.
const recipes = <Recipe>[
  Recipe(
    id: 'lemon-pasta', slug: 'lemon-ricotta-pasta',
    title: 'Lemon ricotta pasta',
    subtitle: 'Silky, bright and ready in twenty minutes',
    image: 'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=1000',
    minutes: 20, prepMinutes: 5, cookMinutes: 15,
    difficulty: 'Easy', category: 'Dinner', categoryIds: ['dinner'],
    cuisineIds: ['italian'], foodType: FoodType.vegetarian,
    calories: 480, servings: 2, tags: ['pasta', 'weeknight', 'quick'],
    ingredients: [
      Ingredient('Pasta', 200, 'g', id: 'pasta'),
      Ingredient('Ricotta', 120, 'g', id: 'ricotta'),
      Ingredient('Lemon', 1, 'whole', id: 'lemon'),
      Ingredient('Parmesan', 30, 'g', id: 'parmesan'),
      Ingredient('Olive oil', 1, 'tbsp', id: 'olive_oil'),
      Ingredient('Fresh basil', 8, 'leaves', id: 'basil'),
    ],
    steps: [
      'Bring a large pot of salted water to a boil. Cook the pasta until just al dente.',
      'Whisk ricotta, lemon zest, lemon juice, olive oil and a splash of pasta water until creamy.',
      'Add the drained pasta and toss gently. Loosen with more pasta water as needed.',
      'Finish with parmesan, torn basil, black pepper and a little olive oil.',
    ],
  ),
  Recipe(
    id: 'roasted-bowl', slug: 'roasted-harvest-bowl',
    title: 'Roasted harvest bowl',
    subtitle: 'Crisp vegetables, grains and green tahini',
    image: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=1000',
    minutes: 35, prepMinutes: 10, cookMinutes: 25,
    difficulty: 'Easy', category: 'Lunch', categoryIds: ['lunch'],
    cuisineIds: ['global'], foodType: FoodType.vegan,
    dietaryTags: ['plant_based'], calories: 420, servings: 2,
    tags: ['chickpeas', 'quinoa', 'vegetables'],
    ingredients: [
      Ingredient('Sweet potato', 1, 'large', id: 'sweet_potato'),
      Ingredient('Chickpeas', 240, 'g', id: 'chickpeas'),
      Ingredient('Quinoa', 120, 'g', id: 'quinoa'),
      Ingredient('Tahini', 2, 'tbsp', id: 'tahini'),
      Ingredient('Cucumber', 1, 'whole', id: 'cucumber'),
      Ingredient('Parsley', 10, 'g', id: 'parsley'),
    ],
    steps: [
      'Heat the oven to 220°C. Dice the sweet potato and season with olive oil, salt and pepper.',
      'Roast the sweet potato and chickpeas for 25–30 minutes until golden.',
      'Cook quinoa according to the packet instructions and fluff with a fork.',
      'Stir tahini with lemon juice and water. Build bowls with quinoa, vegetables and sauce.',
    ],
  ),
  Recipe(
    id: 'berry-oats', slug: 'overnight-berry-oats',
    title: 'Overnight berry oats',
    subtitle: 'A make-ahead breakfast with a little crunch',
    image: 'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?w=1000',
    minutes: 10, prepMinutes: 10,
    difficulty: 'Easy', category: 'Breakfast', categoryIds: ['breakfast'],
    cuisineIds: ['global'], foodType: FoodType.vegetarian,
    calories: 310, servings: 1, tags: ['oats', 'make ahead', 'berries'],
    ingredients: [
      Ingredient('Rolled oats', 50, 'g', id: 'oats'),
      Ingredient('Milk', 120, 'ml', id: 'milk'),
      Ingredient('Greek yogurt', 60, 'g', id: 'greek_yogurt'),
      Ingredient('Mixed berries', 80, 'g', id: 'berries'),
      Ingredient('Maple syrup', 1, 'tsp', id: 'maple_syrup'),
      Ingredient('Chia seeds', 1, 'tsp', id: 'chia'),
    ],
    steps: [
      'Combine oats, milk, yogurt, chia seeds and maple syrup in a jar.',
      'Stir well, cover and refrigerate overnight or for at least four hours.',
      'Top with berries and a spoonful of yogurt before serving.',
    ],
  ),
  Recipe(
    id: 'tomato-soup', slug: 'slow-sunday-tomato-soup',
    title: 'Slow Sunday tomato soup',
    subtitle: 'A comforting bowl with toasted sourdough',
    image: 'https://images.unsplash.com/photo-1547592180-85f173990554?w=1000',
    minutes: 40, prepMinutes: 10, cookMinutes: 30,
    difficulty: 'Easy', category: 'Lunch', categoryIds: ['lunch'],
    cuisineIds: ['global'], foodType: FoodType.vegetarian,
    calories: 360, servings: 4, tags: ['tomato', 'comfort food'],
    ingredients: [
      Ingredient('Ripe tomatoes', 800, 'g', id: 'tomatoes'),
      Ingredient('Onion', 1, 'whole', id: 'onion'),
      Ingredient('Garlic', 3, 'cloves', id: 'garlic'),
      Ingredient('Vegetable stock', 500, 'ml', id: 'vegetable_stock'),
      Ingredient('Cream', 60, 'ml', id: 'cream'),
      Ingredient('Sourdough', 4, 'slices', id: 'sourdough'),
    ],
    steps: [
      'Soften the onion in olive oil, then add garlic and cook until fragrant.',
      'Add tomatoes and stock. Simmer gently for 25 minutes.',
      'Blend until smooth, stir in cream and season to taste.',
      'Serve hot with toasted sourdough and fresh herbs.',
    ],
  ),
  Recipe(
    id: 'gujarati-dhokla', slug: 'gujarati-dhokla',
    title: 'Gujarati dhokla',
    subtitle: 'Soft, savory steamed dhokla with a light tempering',
    image: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=1000',
    minutes: 35, prepMinutes: 15, cookMinutes: 20,
    difficulty: 'Easy', category: 'Breakfast', categoryIds: ['breakfast', 'snacks'],
    cuisineIds: ['gujarati', 'indian'], foodType: FoodType.vegetarian,
    calories: 210, servings: 4, tags: ['steamed', 'besan', 'snack'],
    ingredients: [
      Ingredient('Gram flour', 1, 'cup', id: 'besan'),
      Ingredient('Curd', .5, 'cup', id: 'curd'),
      Ingredient('Ginger', 1, 'tsp', id: 'ginger'),
      Ingredient('Mustard seeds', 1, 'tsp', id: 'mustard_seeds'),
    ],
    steps: [
      'Mix gram flour, curd and water into a smooth batter.',
      'Fold in ginger and seasoning, then rest the batter briefly.',
      'Steam until cooked through and finish with a light tempering.',
    ],
  ),

  Recipe(
    id: 'masala-dosa', slug: 'south-indian-masala-dosa',
    title: 'South Indian masala dosa', subtitle: 'Crisp rice crepe with warmly spiced potato masala',
    image: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=1000',
    minutes: 45, prepMinutes: 20, cookMinutes: 25, difficulty: 'Medium',
    category: 'Breakfast', categoryIds: ['breakfast'], cuisineIds: ['indian','south_indian'],
    foodType: FoodType.vegan, calories: 390, servings: 2, tags: ['dosa','potato','south indian'],
    ingredients: [Ingredient('Dosa batter', 2, 'cups'), Ingredient('Potatoes', 2, 'medium'), Ingredient('Onion', 1, 'whole'), Ingredient('Mustard seeds', 1, 'tsp'), Ingredient('Curry leaves', 8, 'leaves'), Ingredient('Turmeric', .5, 'tsp')],
    steps: ['Boil and roughly mash the potatoes.','Sauté mustard seeds, onion, curry leaves and turmeric; fold in the potatoes with salt.','Spread a ladle of dosa batter thinly on a hot greased skillet.','Cook until crisp, add potato masala, fold and serve with chutney.'],
  ),
  Recipe(
    id: 'paneer-tikka-bowl', slug: 'north-indian-paneer-tikka-bowl',
    title: 'Paneer tikka rice bowl', subtitle: 'Smoky spiced paneer, peppers and fluffy basmati rice',
    image: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=1000',
    minutes: 40, prepMinutes: 15, cookMinutes: 25, difficulty: 'Medium',
    category: 'Dinner', categoryIds: ['dinner','lunch'], cuisineIds: ['indian','north_indian'],
    foodType: FoodType.vegetarian, calories: 560, servings: 2, tags: ['paneer','rice','tikka'],
    ingredients: [Ingredient('Paneer', 250, 'g'), Ingredient('Basmati rice', 150, 'g'), Ingredient('Bell pepper', 1, 'whole'), Ingredient('Yogurt', 80, 'g'), Ingredient('Tikka masala', 2, 'tbsp'), Ingredient('Lemon', 1, 'whole')],
    steps: ['Rinse and cook the basmati rice until fluffy.','Mix yogurt, tikka masala and lemon juice; coat paneer and pepper pieces.','Pan-sear or grill the paneer and peppers until lightly charred.','Serve over rice with lemon and fresh coriander.'],
  ),
  Recipe(
    id: 'chicken-biryani', slug: 'easy-chicken-biryani',
    title: 'Weeknight chicken biryani', subtitle: 'Fragrant basmati rice layered with spiced chicken',
    image: 'https://images.unsplash.com/photo-1563379091339-03246963d96c?w=1000',
    minutes: 60, prepMinutes: 20, cookMinutes: 40, difficulty: 'Medium',
    category: 'Dinner', categoryIds: ['dinner'], cuisineIds: ['indian','north_indian'],
    foodType: FoodType.nonVegetarian, calories: 650, servings: 4, tags: ['chicken','biryani','rice'],
    ingredients: [Ingredient('Chicken', 500, 'g'), Ingredient('Basmati rice', 300, 'g'), Ingredient('Onion', 2, 'whole'), Ingredient('Yogurt', 120, 'g'), Ingredient('Biryani masala', 2, 'tbsp'), Ingredient('Mint', 10, 'g')],
    steps: ['Rinse and soak the rice for 20 minutes.','Brown sliced onions; reserve some for garnish.','Marinate chicken with yogurt, biryani masala, salt and mint, then cook until nearly tender.','Parboil rice, layer over chicken, cover tightly and steam on low until rice is cooked.','Rest for 10 minutes, fluff gently and top with fried onions.'],
  ),
  Recipe(
    id: 'chinese-veg-fried-rice', slug: 'chinese-vegetable-fried-rice',
    title: 'Chinese vegetable fried rice', subtitle: 'A quick wok-fried rice with crisp vegetables',
    image: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=1000',
    minutes: 25, prepMinutes: 10, cookMinutes: 15, difficulty: 'Easy',
    category: 'Lunch', categoryIds: ['lunch','dinner'], cuisineIds: ['chinese'],
    foodType: FoodType.vegan, calories: 430, servings: 2, tags: ['rice','wok','quick'],
    ingredients: [Ingredient('Cooked rice', 3, 'cups'), Ingredient('Carrot', 1, 'whole'), Ingredient('Peas', 80, 'g'), Ingredient('Spring onions', 3, 'stalks'), Ingredient('Soy sauce', 1, 'tbsp'), Ingredient('Sesame oil', 1, 'tsp')],
    steps: ['Use cold, cooked rice and separate any clumps.','Stir-fry diced carrot and peas in a hot wok until just tender.','Add rice, soy sauce and sesame oil; toss over high heat.','Fold through spring onions and serve immediately.'],
  ),
  Recipe(
    id: 'japanese-teriyaki-salmon', slug: 'japanese-teriyaki-salmon',
    title: 'Japanese teriyaki salmon', subtitle: 'Glossy soy-ginger salmon with steamed rice',
    image: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=1000',
    minutes: 30, prepMinutes: 10, cookMinutes: 20, difficulty: 'Easy',
    category: 'Dinner', categoryIds: ['dinner'], cuisineIds: ['japanese'],
    foodType: FoodType.pescatarian, calories: 520, servings: 2, tags: ['salmon','teriyaki','rice'],
    ingredients: [Ingredient('Salmon fillets', 2, 'pieces'), Ingredient('Soy sauce', 3, 'tbsp'), Ingredient('Honey', 1, 'tbsp'), Ingredient('Fresh ginger', 1, 'tsp'), Ingredient('Rice', 150, 'g'), Ingredient('Sesame seeds', 1, 'tsp')],
    steps: ['Cook rice according to the packet instructions.','Simmer soy sauce, honey and grated ginger until slightly syrupy.','Pan-sear salmon until nearly cooked, then brush with teriyaki glaze.','Finish cooking until the salmon flakes easily and serve with rice and sesame.'],
  ),
  Recipe(
    id: 'korean-bibimbap', slug: 'korean-vegetable-bibimbap',
    title: 'Korean vegetable bibimbap', subtitle: 'Colourful rice bowl with vegetables and gochujang sauce',
    image: 'https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=1000',
    minutes: 35, prepMinutes: 15, cookMinutes: 20, difficulty: 'Medium',
    category: 'Lunch', categoryIds: ['lunch','dinner'], cuisineIds: ['korean'],
    foodType: FoodType.vegetarian, calories: 510, servings: 2, tags: ['bibimbap','rice bowl','gochujang'],
    ingredients: [Ingredient('Cooked rice', 2, 'cups'), Ingredient('Spinach', 100, 'g'), Ingredient('Carrot', 1, 'whole'), Ingredient('Mushrooms', 100, 'g'), Ingredient('Eggs', 2, 'whole'), Ingredient('Gochujang', 1, 'tbsp')],
    steps: ['Warm the rice and prepare the vegetables in separate piles.','Quickly sauté spinach, carrot and mushrooms separately.','Fry the eggs to your liking.','Arrange rice and vegetables in bowls, top with egg and serve with gochujang.'],
  ),
  Recipe(
    id: 'mexican-bean-tacos', slug: 'mexican-black-bean-tacos',
    title: 'Mexican black bean tacos', subtitle: 'Smoky beans, avocado and fresh lime in warm tortillas',
    image: 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=1000',
    minutes: 25, prepMinutes: 10, cookMinutes: 15, difficulty: 'Easy',
    category: 'Dinner', categoryIds: ['dinner','lunch'], cuisineIds: ['mexican'],
    foodType: FoodType.vegan, calories: 440, servings: 2, tags: ['tacos','black beans','avocado'],
    ingredients: [Ingredient('Black beans', 240, 'g'), Ingredient('Corn tortillas', 6, 'pieces'), Ingredient('Avocado', 1, 'whole'), Ingredient('Tomato', 1, 'whole'), Ingredient('Cumin', .5, 'tsp'), Ingredient('Lime', 1, 'whole')],
    steps: ['Warm black beans with cumin, smoked paprika and a splash of water.','Dice tomato and avocado; season with lime and salt.','Warm tortillas in a dry skillet.','Fill tortillas with beans and fresh toppings.'],
  ),
  Recipe(
    id: 'american-pancakes', slug: 'fluffy-american-pancakes',
    title: 'Fluffy American pancakes', subtitle: 'Golden breakfast pancakes with berries and maple syrup',
    image: 'https://images.unsplash.com/photo-1528207776546-365bb710ee93?w=1000',
    minutes: 20, prepMinutes: 8, cookMinutes: 12, difficulty: 'Easy',
    category: 'Breakfast', categoryIds: ['breakfast'], cuisineIds: ['american'],
    foodType: FoodType.vegetarian, calories: 390, servings: 3, tags: ['pancakes','breakfast','berries'],
    ingredients: [Ingredient('All-purpose flour', 150, 'g'), Ingredient('Milk', 180, 'ml'), Ingredient('Egg', 1, 'whole'), Ingredient('Baking powder', 2, 'tsp'), Ingredient('Maple syrup', 2, 'tbsp'), Ingredient('Mixed berries', 80, 'g')],
    steps: ['Whisk flour and baking powder in a bowl.','Whisk milk and egg, then stir into the dry ingredients until just combined.','Cook small portions on a lightly greased skillet until bubbles appear; flip and cook through.','Serve with berries and maple syrup.'],
  ),
  Recipe(
    id: 'thai-green-curry', slug: 'thai-green-vegetable-curry',
    title: 'Thai green vegetable curry', subtitle: 'Creamy coconut curry with vegetables and fragrant basil',
    image: 'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=1000',
    minutes: 35, prepMinutes: 10, cookMinutes: 25, difficulty: 'Medium',
    category: 'Dinner', categoryIds: ['dinner'], cuisineIds: ['thai'],
    foodType: FoodType.vegan, calories: 470, servings: 3, tags: ['curry','coconut','thai basil'],
    ingredients: [Ingredient('Green curry paste', 2, 'tbsp'), Ingredient('Coconut milk', 400, 'ml'), Ingredient('Broccoli', 150, 'g'), Ingredient('Bell pepper', 1, 'whole'), Ingredient('Baby corn', 100, 'g'), Ingredient('Thai basil', 10, 'g')],
    steps: ['Warm a little coconut milk in a saucepan and stir in the curry paste.','Add remaining coconut milk and bring to a gentle simmer.','Add vegetables and cook until tender but still bright.','Finish with Thai basil and serve with steamed rice.'],
  ),
  Recipe(
    id: 'greek-chickpea-salad', slug: 'greek-chickpea-salad',
    title: 'Greek chickpea salad', subtitle: 'Fresh cucumber, tomato, olives and feta with lemon dressing',
    image: 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=1000',
    minutes: 15, prepMinutes: 15, cookMinutes: 0, difficulty: 'Easy',
    category: 'Lunch', categoryIds: ['lunch'], cuisineIds: ['greek','mediterranean'],
    foodType: FoodType.vegetarian, calories: 360, servings: 2, tags: ['salad','chickpeas','no-cook'],
    ingredients: [Ingredient('Chickpeas', 240, 'g'), Ingredient('Cucumber', 1, 'whole'), Ingredient('Tomatoes', 2, 'whole'), Ingredient('Feta', 60, 'g'), Ingredient('Kalamata olives', 40, 'g'), Ingredient('Lemon', 1, 'whole')],
    steps: ['Drain and rinse the chickpeas.','Chop cucumber and tomatoes; halve the olives.','Whisk lemon juice with olive oil, salt and pepper.','Toss everything together and crumble feta over the top.'],
  ),
  Recipe(
    id: 'falafel-wrap', slug: 'middle-eastern-falafel-wrap',
    title: 'Middle Eastern falafel wrap', subtitle: 'Herby chickpea falafel with crunchy salad and tahini',
    image: 'https://images.unsplash.com/photo-1531058020387-3be344556be6?w=1000',
    minutes: 40, prepMinutes: 15, cookMinutes: 25, difficulty: 'Medium',
    category: 'Lunch', categoryIds: ['lunch'], cuisineIds: ['middle_eastern'],
    foodType: FoodType.vegan, calories: 490, servings: 3, tags: ['falafel','wrap','chickpea'],
    ingredients: [Ingredient('Cooked chickpeas', 400, 'g'), Ingredient('Parsley', 15, 'g'), Ingredient('Garlic', 2, 'cloves'), Ingredient('Ground cumin', 1, 'tsp'), Ingredient('Tahini', 2, 'tbsp'), Ingredient('Flatbreads', 3, 'pieces')],
    steps: ['Pulse chickpeas, parsley, garlic and cumin into a coarse mixture.','Shape into small patties and chill briefly so they hold together.','Pan-fry with a little oil until golden on both sides.','Serve in flatbreads with salad and thinned tahini.'],
  ),
  Recipe(
    id: 'french-ratatouille', slug: 'french-ratatouille',
    title: 'French vegetable ratatouille', subtitle: 'Slow-simmered Provençal vegetables with herbs',
    image: 'https://images.unsplash.com/photo-1572453800999-e8d2d1589b7c?w=1000',
    minutes: 55, prepMinutes: 15, cookMinutes: 40, difficulty: 'Medium',
    category: 'Dinner', categoryIds: ['dinner','lunch'], cuisineIds: ['french','mediterranean'],
    foodType: FoodType.vegan, calories: 260, servings: 4, tags: ['vegetables','provençal','one pot'],
    ingredients: [Ingredient('Eggplant', 1, 'whole'), Ingredient('Zucchini', 2, 'whole'), Ingredient('Bell pepper', 1, 'whole'), Ingredient('Tomatoes', 400, 'g'), Ingredient('Onion', 1, 'whole'), Ingredient('Thyme', 2, 'sprigs')],
    steps: ['Dice the vegetables into even pieces.','Soften onion and pepper in olive oil.','Add eggplant and zucchini; cook until lightly golden.','Add tomatoes and thyme, then simmer until tender and rich.'],
  ),
  Recipe(
    id: 'vietnamese-summer-rolls', slug: 'vietnamese-fresh-summer-rolls',
    title: 'Vietnamese fresh summer rolls', subtitle: 'Rice-paper rolls packed with herbs, noodles and crisp vegetables',
    image: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=1000',
    minutes: 30, prepMinutes: 30, cookMinutes: 0, difficulty: 'Medium',
    category: 'Snacks', categoryIds: ['snacks','lunch'], cuisineIds: ['vietnamese'],
    foodType: FoodType.vegan, calories: 280, servings: 3, tags: ['rice paper','fresh','herbs'],
    ingredients: [Ingredient('Rice paper wrappers', 8, 'sheets'), Ingredient('Rice vermicelli', 100, 'g'), Ingredient('Carrot', 1, 'whole'), Ingredient('Cucumber', 1, 'whole'), Ingredient('Lettuce', 6, 'leaves'), Ingredient('Mint', 10, 'g')],
    steps: ['Cook vermicelli according to the packet and cool.','Slice carrot and cucumber into thin matchsticks.','Dip one rice-paper wrapper in warm water until pliable.','Add noodles, vegetables and herbs; fold in the sides and roll tightly.','Serve with a dipping sauce of choice.'],
  ),
  Recipe(
    id: 'korean-veg-pancakes', slug: 'korean-vegetable-pancakes',
    title: 'Korean vegetable pancakes', subtitle: 'Crispy savoury scallion pancakes with a soy dipping sauce',
    image: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=1000',
    minutes: 25, prepMinutes: 10, cookMinutes: 15, difficulty: 'Easy',
    category: 'Snacks', categoryIds: ['snacks','breakfast'], cuisineIds: ['korean'],
    foodType: FoodType.vegan, calories: 320, servings: 2, tags: ['pancake','scallion','crispy'],
    ingredients: [Ingredient('All-purpose flour', 120, 'g'), Ingredient('Water', 150, 'ml'), Ingredient('Spring onions', 4, 'stalks'), Ingredient('Carrot', .5, 'whole'), Ingredient('Soy sauce', 2, 'tbsp'), Ingredient('Rice vinegar', 1, 'tbsp')],
    steps: ['Whisk flour, cold water and a pinch of salt into a thin batter.','Fold in sliced spring onions and carrot.','Pan-fry thin pancakes in a lightly oiled skillet until crisp on both sides.','Mix soy sauce and rice vinegar for dipping.'],
  ),
  Recipe(
    id: 'mexican-guacamole', slug: 'mexican-fresh-guacamole',
    title: 'Fresh Mexican guacamole', subtitle: 'Creamy avocado dip with lime, tomato and coriander',
    image: 'https://images.unsplash.com/photo-1601050690117-94f5f6fa8bd7?w=1000',
    minutes: 10, prepMinutes: 10, cookMinutes: 0, difficulty: 'Easy',
    category: 'Snacks', categoryIds: ['snacks'], cuisineIds: ['mexican'],
    foodType: FoodType.vegan, calories: 190, servings: 4, tags: ['avocado','dip','no-cook'],
    ingredients: [Ingredient('Avocados', 2, 'whole'), Ingredient('Tomato', 1, 'whole'), Ingredient('Red onion', .25, 'whole'), Ingredient('Lime', 1, 'whole'), Ingredient('Coriander', 10, 'g'), Ingredient('Salt', null, '', amountType: IngredientAmountType.toTaste)],
    steps: ['Mash the avocado in a bowl, leaving a little texture.','Fold in finely diced tomato and red onion.','Add lime juice, chopped coriander and salt to taste.','Serve straight away with tortilla chips or vegetable sticks.'],
  ),
  Recipe(
    id: 'american-bbq-chicken', slug: 'american-bbq-chicken',
    title: 'American BBQ chicken', subtitle: 'Sticky oven-baked chicken with a smoky barbecue glaze',
    image: 'https://images.unsplash.com/photo-1527477396000-e27163b481c2?w=1000',
    minutes: 50, prepMinutes: 10, cookMinutes: 40, difficulty: 'Easy',
    category: 'Dinner', categoryIds: ['dinner'], cuisineIds: ['american'],
    foodType: FoodType.nonVegetarian, calories: 570, servings: 4, tags: ['chicken','barbecue','oven'],
    ingredients: [Ingredient('Chicken thighs', 700, 'g'), Ingredient('BBQ sauce', 120, 'ml'), Ingredient('Smoked paprika', 1, 'tsp'), Ingredient('Garlic powder', .5, 'tsp'), Ingredient('Potatoes', 500, 'g'), Ingredient('Olive oil', 1, 'tbsp')],
    steps: ['Heat oven to 200°C and line a baking tray.','Season chicken with paprika, garlic powder, salt and pepper.','Brush with BBQ sauce and bake until cooked through, basting once.','Roast potato wedges alongside and serve with extra sauce.'],
  ),
  Recipe(
    id: 'italian-bruschetta', slug: 'italian-tomato-bruschetta',
    title: 'Italian tomato bruschetta', subtitle: 'Toasted bread topped with ripe tomatoes, basil and olive oil',
    image: 'https://images.unsplash.com/photo-1572695157366-5e585ab2b69f?w=1000',
    minutes: 15, prepMinutes: 10, cookMinutes: 5, difficulty: 'Easy',
    category: 'Snacks', categoryIds: ['snacks'], cuisineIds: ['italian'],
    foodType: FoodType.vegan, calories: 220, servings: 4, tags: ['tomato','bread','appetizer'],
    ingredients: [Ingredient('Baguette', 1, 'loaf'), Ingredient('Tomatoes', 3, 'whole'), Ingredient('Fresh basil', 8, 'leaves'), Ingredient('Garlic', 1, 'clove'), Ingredient('Olive oil', 2, 'tbsp'), Ingredient('Balsamic vinegar', 1, 'tsp')],
    steps: ['Dice tomatoes and mix with chopped basil, olive oil and balsamic.','Slice and toast the baguette until golden.','Rub warm toast lightly with the cut garlic clove.','Spoon tomato mixture over the toast and serve.'],
  ),
  Recipe(
    id: 'south-indian-idli', slug: 'south-indian-idli-sambar',
    title: 'Idli with quick sambar', subtitle: 'Soft steamed idlis served with a comforting lentil stew',
    image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=1000',
    minutes: 35, prepMinutes: 10, cookMinutes: 25, difficulty: 'Easy',
    category: 'Breakfast', categoryIds: ['breakfast'], cuisineIds: ['indian','south_indian'],
    foodType: FoodType.vegan, calories: 330, servings: 2, tags: ['idli','sambar','lentils'],
    ingredients: [Ingredient('Idli batter', 2, 'cups'), Ingredient('Toor dal', 80, 'g'), Ingredient('Mixed vegetables', 150, 'g'), Ingredient('Sambar powder', 1, 'tbsp'), Ingredient('Tamarind paste', 1, 'tsp'), Ingredient('Mustard seeds', .5, 'tsp')],
    steps: ['Pressure-cook toor dal until soft and mash lightly.','Simmer vegetables with water, sambar powder and tamarind until tender.','Stir in dal and finish with a mustard-seed tempering.','Steam idli batter in greased moulds and serve hot with sambar.'],
  ),

];

class RecipeCatalog {
  const RecipeCatalog._();

  static List<Recipe> search(
    Iterable<Recipe> source, {
    String query = '',
    String categoryId = 'all',
    String cuisineId = 'all',
    Set<String> cuisineIds = const {},
    FoodType? foodType,
    String difficulty = 'all',
    int? minMinutes,
    int? maxMinutes,
    String season = 'all',
    bool nutritionOnly = false,
    Set<String> dietaryTags = const {},
    Set<String> preferredCuisines = const {},
    Set<String> preferredFoodTypes = const {},
    int? preferredMaxCookingMinutes,
    Set<String> preferredMealTypes = const {},
    Set<String> allergies = const {},
    RecipeSort sort = RecipeSort.recommended,
  }) {
    final normalized = query.trim().toLowerCase();
    final result = source.where((recipe) {
      final matchesCategory = categoryId == 'all' ||
          recipe.categoryIds.contains(categoryId) ||
          recipe.category.toLowerCase() == categoryId.toLowerCase();
      final matchesCuisine = cuisineIds.isNotEmpty
          ? recipe.cuisineIds.any(cuisineIds.contains)
          : cuisineId == 'all' || recipe.cuisineIds.contains(cuisineId);
      final matchesFoodType = (foodType == null || recipe.foodType == foodType) &&
          (preferredFoodTypes.isEmpty || preferredFoodTypes.contains(recipe.foodType.name));
      final matchesDifficulty = difficulty == 'all' || recipe.difficulty.toLowerCase() == difficulty.toLowerCase();
      final matchesTime = (minMinutes == null || recipe.totalMinutes >= minMinutes) &&
          (maxMinutes == null || recipe.totalMinutes <= maxMinutes) &&
          (preferredMaxCookingMinutes == null || recipe.totalMinutes <= preferredMaxCookingMinutes);
      final matchesSeason = season == 'all' || recipe.seasons.contains(season.toLowerCase());
      final matchesNutrition = !nutritionOnly || recipe.hasNutritionData;
      final matchesDiet = dietaryTags.isEmpty || dietaryTags.every(recipe.dietaryTags.contains);
      final matchesPreferredCuisine = preferredCuisines.isEmpty ||
          recipe.cuisineIds.any(preferredCuisines.contains);
      final matchesMealType = preferredMealTypes.isEmpty ||
          recipe.categoryIds.any(preferredMealTypes.contains);
      final blockedAllergens = allergies.map((value) => value.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ')).toSet();
      final recipeAllergens = recipe.verifiedAllergens.map((value) => value.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ')).toSet();
      // With an active allergy profile, unverified recipes are excluded rather
      // than being presented as safe.
      final matchesAllergies = allergies.isEmpty ||
          (recipe.allergensVerified && !recipeAllergens.any(blockedAllergens.contains));
      return recipe.isPublished && matchesCategory && matchesCuisine && matchesFoodType &&
          matchesDifficulty && matchesTime && matchesSeason && matchesNutrition && matchesDiet &&
          matchesPreferredCuisine && matchesMealType && matchesAllergies && recipe.matches(normalized);
    }).toList();

    switch (sort) {
      case RecipeSort.recommended:
        break;
      case RecipeSort.quickest:
        result.sort((a, b) => a.totalMinutes.compareTo(b.totalMinutes));
        break;
      case RecipeSort.title:
        result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }
    return result;
  }
}
