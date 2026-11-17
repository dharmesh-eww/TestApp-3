import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'app_locale.dart';

class AppLocalizations {
  AppLocalizations(Locale locale) : locale = AppLocale.normalize(locale);
  final Locale locale;
  bool get isArabic => locale.languageCode == 'ar';
  bool get isHindi => locale.languageCode == 'hi';
  bool get isGujarati => locale.languageCode == 'gu';
  bool get isJapanese => locale.languageCode == 'ja';
  bool get isPortuguese => locale.languageCode == 'pt';
  bool get isIndonesian => locale.languageCode == 'id';
  bool get isSpanish => locale.languageCode == 'es';
  bool get isChinese => locale.languageCode == 'zh';
  bool get isRtl => isArabic;
  String get languageName => switch (locale.languageCode) {
    'ar' => 'العربية', 'hi' => 'हिन्दी', 'gu' => 'ગુજરાતી',
    'ja' => '日本語', 'pt' => 'Português', 'id' => 'Bahasa Indonesia',
    'es' => 'Español', 'zh' => '简体中文', _ => 'English'
  };
  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  static const LocalizationsDelegate<AppLocalizations> delegate = _Delegate();

  String label(String english, String arabic) {
    if (isArabic) return arabic;
    if (isHindi) {
      return const <String, String>{
        'Today': 'आज', 'Recipes': 'व्यंजन', 'Favourites': 'पसंदीदा',
        'Plan': 'योजना', 'Groceries': 'किराने का सामान', 'Kitchen': 'रसोई',
        'Change language': 'भाषा बदलें', 'Language': 'भाषा',
        'Settings': 'सेटिंग्स', 'CHOOSE YOUR LANGUAGE': 'अपनी भाषा चुनें',
        'YOUR LITTLE COOKBOOK': 'आपकी छोटी रेसिपी किताब',
        'Your kitchen,\nyour rhythm.': 'आपकी रसोई,\\nआपकी लय।',
        'Collections': 'संग्रह', 'Cooking history': 'पकाने का इतिहास',
        'Recently viewed': 'हाल ही में देखे गए', 'Your saved recipes': 'आपकी सहेजी गई रेसिपी',
        'Saved recipes': 'सहेजी गई रेसिपी', 'Meals planned': 'नियोजित भोजन',
        'Recipe library': 'रेसिपी लाइब्रेरी', 'Check for curated recipe updates. Your meal plans, pantry and saved recipes stay on this device.': 'चुनी हुई रेसिपी के अपडेट देखें। आपकी भोजन योजनाएँ, पेंट्री और सहेजी गई रेसिपी इसी डिवाइस पर रहती हैं।',
        'MEASUREMENTS': 'माप की इकाइयाँ', 'Measurement system': 'माप प्रणाली',
        'Metric (g, kg, ml, L)': 'मीट्रिक (g, kg, ml, L)',
        'US customary (oz, lb, cups)': 'अमेरिकी (oz, lb, cups)',
        'WEEKLY PLANNER': 'साप्ताहिक योजनाकार', 'First day of week': 'सप्ताह का पहला दिन',
        'Monday': 'सोमवार', 'Sunday': 'रविवार', 'APPEARANCE': 'दिखावट',
        'Theme': 'थीम', 'Use device setting': 'डिवाइस सेटिंग का उपयोग करें',
        'Light': 'लाइट', 'Dark': 'डार्क', 'Reduce motion': 'गतिशीलता कम करें',
        'PERSONAL DISCOVERY': 'व्यक्तिगत खोज',
        'LOCAL DATA': 'स्थानीय डेटा', 'Reset personal data': 'व्यक्तिगत डेटा रीसेट करें',
        'Cancel': 'रद्द करें', 'Save': 'सहेजें', 'Create': 'बनाएँ',
        'Delete': 'हटाएँ', 'Rename': 'नाम बदलें', 'Add recipes': 'रेसिपी जोड़ें',
        'Breakfast': 'नाश्ता', 'Lunch': 'दोपहर का भोजन', 'Dinner': 'रात का भोजन', 'Snack': 'हल्का नाश्ता',
        'Plant based': 'पौधों पर आधारित', 'Gluten free': 'ग्लूटेन मुक्त',
        'Dairy free': 'डेयरी मुक्त', 'High protein': 'उच्च प्रोटीन',
      }[english] ?? english;
    }
    if (isGujarati) {
      return const <String, String>{
        'Today': 'આજે', 'Recipes': 'વાનગીઓ', 'Favourites': 'મનપસંદ',
        'Plan': 'આયોજન', 'Groceries': 'કરિયાણું', 'Kitchen': 'રસોડું',
        'Change language': 'ભાષા બદલો', 'Language': 'ભાષા',
        'Settings': 'સેટિંગ્સ', 'CHOOSE YOUR LANGUAGE': 'તમારી ભાષા પસંદ કરો',
        'YOUR LITTLE COOKBOOK': 'તમારી નાની રસોઈપોથી',
        'Your kitchen,\nyour rhythm.': 'તમારું રસોડું,\\nતમારી લય.',
        'Collections': 'સંગ્રહો', 'Cooking history': 'રસોઈનો ઇતિહાસ',
        'Recently viewed': 'તાજેતરમાં જોયેલી', 'Your saved recipes': 'તમારી સાચવેલી વાનગીઓ',
        'Saved recipes': 'સાચવેલી વાનગીઓ', 'Meals planned': 'આયોજિત ભોજન',
        'Recipe library': 'વાનગીઓની લાઇબ્રેરી', 'Check for curated recipe updates. Your meal plans, pantry and saved recipes stay on this device.': 'પસંદ કરેલી વાનગીઓના અપડેટ તપાસો. તમારી ભોજન યોજનાઓ, પેન્ટ્રી અને સાચવેલી વાનગીઓ આ ઉપકરણમાં જ રહે છે.',
        'MEASUREMENTS': 'માપ', 'Measurement system': 'માપ પદ્ધતિ',
        'Metric (g, kg, ml, L)': 'મેટ્રિક (g, kg, ml, L)',
        'US customary (oz, lb, cups)': 'અમેરિકન (oz, lb, cups)',
        'WEEKLY PLANNER': 'સાપ્તાહિક આયોજન', 'First day of week': 'અઠવાડિયાનો પહેલો દિવસ',
        'Monday': 'સોમવાર', 'Sunday': 'રવિવાર', 'APPEARANCE': 'દેખાવ',
        'Theme': 'થીમ', 'Use device setting': 'ઉપકરણની સેટિંગ વાપરો',
        'Light': 'લાઇટ', 'Dark': 'ડાર્ક', 'Reduce motion': 'એનિમેશન ઘટાડો',
        'PERSONAL DISCOVERY': 'વ્યક્તિગત શોધ',
        'LOCAL DATA': 'સ્થાનિક ડેટા', 'Reset personal data': 'વ્યક્તિગત ડેટા રીસેટ કરો',
        'Cancel': 'રદ કરો', 'Save': 'સાચવો', 'Create': 'બનાવો',
        'Delete': 'કાઢી નાખો', 'Rename': 'નામ બદલો', 'Add recipes': 'વાનગીઓ ઉમેરો',
        'Breakfast': 'નાસ્તો', 'Lunch': 'બપોરનું ભોજન', 'Dinner': 'રાત્રિભોજન', 'Snack': 'હળવો નાસ્તો',
        'Plant based': 'વનસ્પતિ આધારિત', 'Gluten free': 'ગ્લૂટેન મુક્ત',
        'Dairy free': 'ડેરી મુક્ત', 'High protein': 'વધુ પ્રોટીન',
      }[english] ?? english;
    }
    final extra = <String, Map<String, String>>{
      'ja': {
        "Today": "今日",
        "Recipes": "レシピ",
        "Favourites": "お気に入り",
        "Plan": "プラン",
        "Groceries": "買い物リスト",
        "Kitchen": "キッチン",
        "Change language": "言語を変更",
        "Language": "言語",
        "Settings": "設定",
        "CHOOSE YOUR LANGUAGE": "言語を選択",
        "YOUR LITTLE COOKBOOK": "あなたの小さなレシピブック",
        "Collections": "コレクション",
        "Cooking history": "調理履歴",
        "Recently viewed": "最近見たレシピ",
        "Your saved recipes": "保存したレシピ",
        "Saved recipes": "保存済みレシピ",
        "Meals planned": "予定した食事",
        "Recipe library": "レシピライブラリ",
        "Measurement system": "単位系",
        "First day of week": "週の開始曜日",
        "Monday": "月曜日",
        "Sunday": "日曜日",
        "Theme": "テーマ",
        "Use device setting": "端末の設定を使用",
        "Light": "ライト",
        "Dark": "ダーク",
        "Reduce motion": "アニメーションを減らす",
        "Cancel": "キャンセル",
        "Save": "保存",
        "Create": "作成",
        "Delete": "削除",
        "Rename": "名前を変更",
        "Add recipes": "レシピを追加",
        "Breakfast": "朝食",
        "Lunch": "昼食",
        "Dinner": "夕食",
        "Snack": "軽食",
        "Ingredients": "材料",
        "Plan this recipe": "このレシピを予定する",
        "Add ingredients to grocery list": "材料を買い物リストに追加",
        "Start cooking": "調理を始める",
        "Recipe filters": "レシピの絞り込み",
        "Cuisine": "料理の種類",
        "Food type": "食事の種類",
        "Difficulty": "難易度",
        "Total cooking time": "合計調理時間",
        "Clear filters": "条件をクリア",
        "Show recipes": "レシピを表示",
        "See all": "すべて見る",
        "Explore": "探す",
        "Open plan": "プランを開く",
        "Today’s inspiration": "今日のおすすめ",
        "Made for your week": "今週のおすすめ",
        "A few good ideas": "おすすめレシピ",
        "Search recipes or ingredients": "レシピや材料を検索",
        "Find your next\nfavourite.": "次のお気に入りを\\n見つけましょう。",
        "Nothing on this shelf": "レシピがありません",
        "Your meal\nplanner.": "あなたの\\n献立プランナー。",
        "Ingredients added to your grocery list": "材料を買い物リストに追加しました",
        "Recipe copied to clipboard.": "レシピをコピーしました。",
        "View recipe": "レシピを見る",
        "I have": "持っています",
        "Exclude": "除外",
        "Recipe matches": "一致するレシピ",
        "Select at least one ingredient to see match percentages.": "一致率を見るには材料を1つ以上選択してください。",
        "Personal data cleared from this device.": "この端末の個人データを消去しました。",
      },
      'pt': {
        "Today": "Hoje",
        "Recipes": "Receitas",
        "Favourites": "Favoritos",
        "Plan": "Planejar",
        "Groceries": "Compras",
        "Kitchen": "Cozinha",
        "Change language": "Alterar idioma",
        "Language": "Idioma",
        "Settings": "Configurações",
        "CHOOSE YOUR LANGUAGE": "ESCOLHA SEU IDIOMA",
        "YOUR LITTLE COOKBOOK": "SEU PEQUENO LIVRO DE RECEITAS",
        "Collections": "Coleções",
        "Cooking history": "Histórico de preparo",
        "Recently viewed": "Vistos recentemente",
        "Your saved recipes": "Suas receitas salvas",
        "Saved recipes": "Receitas salvas",
        "Meals planned": "Refeições planejadas",
        "Recipe library": "Biblioteca de receitas",
        "Measurement system": "Sistema de medidas",
        "First day of week": "Primeiro dia da semana",
        "Monday": "Segunda-feira",
        "Sunday": "Domingo",
        "Theme": "Tema",
        "Use device setting": "Usar configuração do dispositivo",
        "Light": "Claro",
        "Dark": "Escuro",
        "Reduce motion": "Reduzir animações",
        "Cancel": "Cancelar",
        "Save": "Salvar",
        "Create": "Criar",
        "Delete": "Excluir",
        "Rename": "Renomear",
        "Add recipes": "Adicionar receitas",
        "Breakfast": "Café da manhã",
        "Lunch": "Almoço",
        "Dinner": "Jantar",
        "Snack": "Lanche",
        "Ingredients": "Ingredientes",
        "Plan this recipe": "Planejar esta receita",
        "Add ingredients to grocery list": "Adicionar ingredientes à lista de compras",
        "Start cooking": "Começar a cozinhar",
        "Recipe filters": "Filtros de receitas",
        "Cuisine": "Culinária",
        "Food type": "Tipo de alimentação",
        "Difficulty": "Dificuldade",
        "Total cooking time": "Tempo total de preparo",
        "Clear filters": "Limpar filtros",
        "Show recipes": "Mostrar receitas",
        "See all": "Ver tudo",
        "Explore": "Explorar",
        "Open plan": "Abrir planejamento",
        "Today’s inspiration": "Inspiração de hoje",
        "Made for your week": "Feito para sua semana",
        "A few good ideas": "Algumas boas ideias",
        "Search recipes or ingredients": "Buscar receitas ou ingredientes",
        "Nothing on this shelf": "Nenhuma receita aqui",
        "Ingredients added to your grocery list": "Ingredientes adicionados à lista de compras",
        "Recipe copied to clipboard.": "Receita copiada.",
        "View recipe": "Ver receita",
        "I have": "Tenho",
        "Exclude": "Excluir",
        "Recipe matches": "Receitas correspondentes",
        "Personal data cleared from this device.": "Dados pessoais removidos deste dispositivo.",
      },
      'id': {
        "Today": "Hari ini",
        "Recipes": "Resep",
        "Favourites": "Favorit",
        "Plan": "Rencana",
        "Groceries": "Belanja",
        "Kitchen": "Dapur",
        "Change language": "Ubah bahasa",
        "Language": "Bahasa",
        "Settings": "Pengaturan",
        "CHOOSE YOUR LANGUAGE": "PILIH BAHASA",
        "YOUR LITTLE COOKBOOK": "BUKU RESEP KECIL ANDA",
        "Collections": "Koleksi",
        "Cooking history": "Riwayat memasak",
        "Recently viewed": "Baru dilihat",
        "Your saved recipes": "Resep tersimpan",
        "Saved recipes": "Resep tersimpan",
        "Meals planned": "Jadwal makanan",
        "Recipe library": "Perpustakaan resep",
        "Measurement system": "Sistem ukuran",
        "First day of week": "Hari pertama dalam minggu",
        "Monday": "Senin",
        "Sunday": "Minggu",
        "Theme": "Tema",
        "Use device setting": "Gunakan pengaturan perangkat",
        "Light": "Terang",
        "Dark": "Gelap",
        "Reduce motion": "Kurangi animasi",
        "Cancel": "Batal",
        "Save": "Simpan",
        "Create": "Buat",
        "Delete": "Hapus",
        "Rename": "Ubah nama",
        "Add recipes": "Tambah resep",
        "Breakfast": "Sarapan",
        "Lunch": "Makan siang",
        "Dinner": "Makan malam",
        "Snack": "Camilan",
        "Ingredients": "Bahan-bahan",
        "Plan this recipe": "Jadwalkan resep ini",
        "Add ingredients to grocery list": "Tambahkan bahan ke daftar belanja",
        "Start cooking": "Mulai memasak",
        "Recipe filters": "Filter resep",
        "Cuisine": "Masakan",
        "Food type": "Jenis makanan",
        "Difficulty": "Tingkat kesulitan",
        "Total cooking time": "Total waktu memasak",
        "Clear filters": "Hapus filter",
        "Show recipes": "Tampilkan resep",
        "See all": "Lihat semua",
        "Explore": "Jelajahi",
        "Open plan": "Buka rencana",
        "Today’s inspiration": "Inspirasi hari ini",
        "Made for your week": "Untuk minggu Anda",
        "A few good ideas": "Beberapa ide menarik",
        "Search recipes or ingredients": "Cari resep atau bahan",
        "Nothing on this shelf": "Belum ada resep",
        "Ingredients added to your grocery list": "Bahan ditambahkan ke daftar belanja",
        "Recipe copied to clipboard.": "Resep disalin.",
        "View recipe": "Lihat resep",
        "I have": "Saya punya",
        "Exclude": "Kecualikan",
        "Recipe matches": "Resep yang cocok",
        "Personal data cleared from this device.": "Data pribadi dihapus dari perangkat ini.",
      },
      'es': {
        "Today": "Hoy",
        "Recipes": "Recetas",
        "Favourites": "Favoritos",
        "Plan": "Plan",
        "Groceries": "Compras",
        "Kitchen": "Cocina",
        "Change language": "Cambiar idioma",
        "Language": "Idioma",
        "Settings": "Ajustes",
        "CHOOSE YOUR LANGUAGE": "ELIGE TU IDIOMA",
        "YOUR LITTLE COOKBOOK": "TU PEQUEÑO LIBRO DE RECETAS",
        "Collections": "Colecciones",
        "Cooking history": "Historial de cocina",
        "Recently viewed": "Vistos recientemente",
        "Your saved recipes": "Tus recetas guardadas",
        "Saved recipes": "Recetas guardadas",
        "Meals planned": "Comidas planificadas",
        "Recipe library": "Biblioteca de recetas",
        "Measurement system": "Sistema de medidas",
        "First day of week": "Primer día de la semana",
        "Monday": "Lunes",
        "Sunday": "Domingo",
        "Theme": "Tema",
        "Use device setting": "Usar configuración del dispositivo",
        "Light": "Claro",
        "Dark": "Oscuro",
        "Reduce motion": "Reducir movimiento",
        "Cancel": "Cancelar",
        "Save": "Guardar",
        "Create": "Crear",
        "Delete": "Eliminar",
        "Rename": "Cambiar nombre",
        "Add recipes": "Añadir recetas",
        "Breakfast": "Desayuno",
        "Lunch": "Almuerzo",
        "Dinner": "Cena",
        "Snack": "Tentempié",
        "Ingredients": "Ingredientes",
        "Plan this recipe": "Planificar esta receta",
        "Add ingredients to grocery list": "Añadir ingredientes a la lista de compras",
        "Start cooking": "Empezar a cocinar",
        "Recipe filters": "Filtros de recetas",
        "Cuisine": "Tipo de cocina",
        "Food type": "Tipo de comida",
        "Difficulty": "Dificultad",
        "Total cooking time": "Tiempo total de cocción",
        "Clear filters": "Borrar filtros",
        "Show recipes": "Mostrar recetas",
        "See all": "Ver todo",
        "Explore": "Explorar",
        "Open plan": "Abrir plan",
        "Today’s inspiration": "Inspiración de hoy",
        "Made for your week": "Para tu semana",
        "A few good ideas": "Algunas buenas ideas",
        "Search recipes or ingredients": "Buscar recetas o ingredientes",
        "Nothing on this shelf": "No hay recetas aquí",
        "Ingredients added to your grocery list": "Ingredientes añadidos a tu lista de compras",
        "Recipe copied to clipboard.": "Receta copiada.",
        "View recipe": "Ver receta",
        "I have": "Tengo",
        "Exclude": "Excluir",
        "Recipe matches": "Recetas coincidentes",
        "Personal data cleared from this device.": "Datos personales borrados de este dispositivo.",
      },
      'zh': {
        "Today": "今天",
        "Recipes": "食谱",
        "Favourites": "收藏",
        "Plan": "计划",
        "Groceries": "购物清单",
        "Kitchen": "厨房",
        "Change language": "更改语言",
        "Language": "语言",
        "Settings": "设置",
        "CHOOSE YOUR LANGUAGE": "选择语言",
        "YOUR LITTLE COOKBOOK": "你的专属食谱集",
        "Collections": "合集",
        "Cooking history": "烹饪记录",
        "Recently viewed": "最近浏览",
        "Your saved recipes": "已保存的食谱",
        "Saved recipes": "已保存食谱",
        "Meals planned": "已计划的餐食",
        "Recipe library": "食谱库",
        "Measurement system": "计量单位",
        "First day of week": "每周开始日",
        "Monday": "星期一",
        "Sunday": "星期日",
        "Theme": "主题",
        "Use device setting": "跟随设备设置",
        "Light": "浅色",
        "Dark": "深色",
        "Reduce motion": "减少动画",
        "Cancel": "取消",
        "Save": "保存",
        "Create": "创建",
        "Delete": "删除",
        "Rename": "重命名",
        "Add recipes": "添加食谱",
        "Breakfast": "早餐",
        "Lunch": "午餐",
        "Dinner": "晚餐",
        "Snack": "加餐",
        "Ingredients": "食材",
        "Plan this recipe": "安排这道食谱",
        "Add ingredients to grocery list": "将食材加入购物清单",
        "Start cooking": "开始烹饪",
        "Recipe filters": "食谱筛选",
        "Cuisine": "菜系",
        "Food type": "食物类型",
        "Difficulty": "难度",
        "Total cooking time": "总烹饪时间",
        "Clear filters": "清除筛选",
        "Show recipes": "显示食谱",
        "See all": "查看全部",
        "Explore": "探索",
        "Open plan": "打开计划",
        "Today’s inspiration": "今日灵感",
        "Made for your week": "为你的一周准备",
        "A few good ideas": "一些好点子",
        "Search recipes or ingredients": "搜索食谱或食材",
        "Nothing on this shelf": "这里还没有食谱",
        "Ingredients added to your grocery list": "食材已添加到购物清单",
        "Recipe copied to clipboard.": "食谱已复制。",
        "View recipe": "查看食谱",
        "I have": "我有",
        "Exclude": "排除",
        "Recipe matches": "匹配的食谱",
        "Personal data cleared from this device.": "此设备上的个人数据已清除。",
      },
    }[locale.languageCode];
    return extra?[english] ?? english;
  }

  String weekday(String day) {
    if (isHindi) return const {'Monday':'सोमवार','Tuesday':'मंगलवार','Wednesday':'बुधवार','Thursday':'गुरुवार','Friday':'शुक्रवार','Saturday':'शनिवार','Sunday':'रविवार'}[day] ?? day;
    if (isGujarati) return const {'Monday':'સોમવાર','Tuesday':'મંગળવાર','Wednesday':'બુધવાર','Thursday':'ગુરુવાર','Friday':'શુક્રવાર','Saturday':'શનિવાર','Sunday':'રવિવાર'}[day] ?? day;
    if (isJapanese) return const {'Monday':'月曜日','Tuesday':'火曜日','Wednesday':'水曜日','Thursday':'木曜日','Friday':'金曜日','Saturday':'土曜日','Sunday':'日曜日'}[day] ?? day;
    if (isPortuguese) return const {'Monday':'segunda-feira','Tuesday':'terça-feira','Wednesday':'quarta-feira','Thursday':'quinta-feira','Friday':'sexta-feira','Saturday':'sábado','Sunday':'domingo'}[day] ?? day;
    if (isIndonesian) return const {'Monday':'Senin','Tuesday':'Selasa','Wednesday':'Rabu','Thursday':'Kamis','Friday':'Jumat','Saturday':'Sabtu','Sunday':'Minggu'}[day] ?? day;
    if (isSpanish) return const {'Monday':'lunes','Tuesday':'martes','Wednesday':'miércoles','Thursday':'jueves','Friday':'viernes','Saturday':'sábado','Sunday':'domingo'}[day] ?? day;
    if (isChinese) return const {'Monday':'星期一','Tuesday':'星期二','Wednesday':'星期三','Thursday':'星期四','Friday':'星期五','Saturday':'星期六','Sunday':'星期日'}[day] ?? day;
    if (!isArabic) return day;
    return switch (day) {
      'Monday' => 'الإثنين',
      'Tuesday' => 'الثلاثاء',
      'Wednesday' => 'الأربعاء',
      'Thursday' => 'الخميس',
      'Friday' => 'الجمعة',
      'Saturday' => 'السبت',
      'Sunday' => 'الأحد',
      _ => day,
    };
  }

  String weekdayShort(String day) {
    if (isHindi) return const {'Monday':'सो','Tuesday':'मं','Wednesday':'बु','Thursday':'गु','Friday':'शु','Saturday':'श','Sunday':'र'}[day] ?? day.substring(0, 1);
    if (isGujarati) return const {'Monday':'સો','Tuesday':'મં','Wednesday':'બુ','Thursday':'ગુ','Friday':'શુ','Saturday':'શ','Sunday':'ર'}[day] ?? day.substring(0, 1);
    if (isJapanese) return const {'Monday':'月','Tuesday':'火','Wednesday':'水','Thursday':'木','Friday':'金','Saturday':'土','Sunday':'日'}[day] ?? day.substring(0, 1);
    if (isPortuguese || isIndonesian || isSpanish) return weekday(day).substring(0, 2);
    if (isChinese) return weekday(day).substring(2);
    if (!isArabic) return day.substring(0, 1);
    return switch (day) {
      'Monday' => 'ن',
      'Tuesday' => 'ث',
      'Wednesday' => 'ر',
      'Thursday' => 'خ',
      'Friday' => 'ج',
      'Saturday' => 'س',
      'Sunday' => 'ح',
      _ => day,
    };
  }

  String mealSlot(String slot) {
    if (isJapanese || isPortuguese || isIndonesian || isSpanish || isChinese) {
      final values = <String, Map<String, String>>{
        'ja': {'breakfast':'朝食','lunch':'昼食','dinner':'夕食','snack':'軽食'},
        'pt': {'breakfast':'Café da manhã','lunch':'Almoço','dinner':'Jantar','snack':'Lanche'},
        'id': {'breakfast':'Sarapan','lunch':'Makan siang','dinner':'Makan malam','snack':'Camilan'},
        'es': {'breakfast':'Desayuno','lunch':'Almuerzo','dinner':'Cena','snack':'Tentempié'},
        'zh': {'breakfast':'早餐','lunch':'午餐','dinner':'晚餐','snack':'加餐'},
      };
      return values[locale.languageCode]?[slot] ?? slot;
    }
    if (isHindi) {
      return const {'breakfast': 'नाश्ता', 'lunch': 'दोपहर का भोजन', 'dinner': 'रात का भोजन', 'snack': 'हल्का नाश्ता'}[slot] ?? slot;
    }
    if (isGujarati) {
      return const {'breakfast': 'નાસ્તો', 'lunch': 'બપોરનું ભોજન', 'dinner': 'રાત્રિભોજન', 'snack': 'હળવો નાસ્તો'}[slot] ?? slot;
    }
    if (!isArabic) {
      return switch (slot) {
        'breakfast' => 'Breakfast',
        'lunch' => 'Lunch',
        'dinner' => 'Dinner',
        'snack' => 'Snack',
        _ => slot,
      };
    }
    return switch (slot) {
      'breakfast' => 'الإفطار',
      'lunch' => 'الغداء',
      'dinner' => 'العشاء',
      'snack' => 'وجبة خفيفة',
      _ => slot,
    };
  }

  String dietaryTag(String tag) {
    final extra = <String, Map<String, String>>{
      'ja': {'plant_based':'植物性','gluten_free':'グルテンフリー','dairy_free':'乳製品不使用','high_protein':'高タンパク'},
      'pt': {'plant_based':'À base de plantas','gluten_free':'Sem glúten','dairy_free':'Sem laticínios','high_protein':'Rico em proteínas'},
      'id': {'plant_based':'Berbasis nabati','gluten_free':'Bebas gluten','dairy_free':'Bebas susu','high_protein':'Tinggi protein'},
      'es': {'plant_based':'A base de plantas','gluten_free':'Sin gluten','dairy_free':'Sin lácteos','high_protein':'Alto en proteínas'},
      'zh': {'plant_based':'植物性','gluten_free':'无麸质','dairy_free':'无乳制品','high_protein':'高蛋白'},
    }[locale.languageCode];
    if (extra != null) return extra[tag] ?? tag;
    if (!isArabic) {
      return switch (tag) {
        'plant_based' => 'Plant based',
        'gluten_free' => 'Gluten free',
        'dairy_free' => 'Dairy free',
        'high_protein' => 'High protein',
        _ => tag,
      };
    }
    return switch (tag) {
      'plant_based' => 'نباتي بالكامل',
      'gluten_free' => 'خالٍ من الغلوتين',
      'dairy_free' => 'خالٍ من الألبان',
      'high_protein' => 'غني بالبروتين',
      _ => tag,
    };
  }

  String stepOf(int current, int total) => switch (locale.languageCode) {
    'ar' => 'الخطوة $current من $total',
    'ja' => 'ステップ $current / $total',
    'pt' => 'ETAPA $current DE $total',
    'id' => 'LANGKAH $current DARI $total',
    'es' => 'PASO $current DE $total',
    'zh' => '第 $current 步，共 $total 步',
    _ => 'STEP $current OF $total',
  };

  String get today => switch (locale.languageCode) { 'ar' => 'اليوم', 'hi' => 'आज', 'gu' => 'આજે', 'ja' => '今日', 'pt' => 'Hoje', 'id' => 'Hari ini', 'es' => 'Hoy', 'zh' => '今天', _ => 'Today' };
  String get recipes => switch (locale.languageCode) { 'ar' => 'الوصفات', 'hi' => 'व्यंजन', 'gu' => 'વાનગીઓ', 'ja' => 'レシピ', 'pt' => 'Receitas', 'id' => 'Resep', 'es' => 'Recetas', 'zh' => '食谱', _ => 'Recipes' };
  String get favorites => switch (locale.languageCode) { 'ar' => 'المفضلة', 'hi' => 'पसंदीदा', 'gu' => 'મનપસંદ', 'ja' => 'お気に入り', 'pt' => 'Favoritos', 'id' => 'Favorit', 'es' => 'Favoritos', 'zh' => '收藏', _ => 'Favourites' };
  String get plan => switch (locale.languageCode) { 'ar' => 'الخطة', 'hi' => 'योजना', 'gu' => 'આયોજન', 'ja' => 'プラン', 'pt' => 'Planejar', 'id' => 'Rencana', 'es' => 'Plan', 'zh' => '计划', _ => 'Plan' };
  String get groceries => switch (locale.languageCode) { 'ar' => 'المشتريات', 'hi' => 'किराने का सामान', 'gu' => 'કરિયાણું', 'ja' => '買い物リスト', 'pt' => 'Compras', 'id' => 'Belanja', 'es' => 'Compras', 'zh' => '购物清单', _ => 'Groceries' };
  String get kitchen => switch (locale.languageCode) { 'ar' => 'المطبخ', 'hi' => 'रसोई', 'gu' => 'રસોડું', 'ja' => 'キッチン', 'pt' => 'Cozinha', 'id' => 'Dapur', 'es' => 'Cocina', 'zh' => '厨房', _ => 'Kitchen' };
  String get language => switch (locale.languageCode) { 'ar' => 'تغيير اللغة', 'hi' => 'भाषा बदलें', 'gu' => 'ભાષા બદલો', 'ja' => '言語を変更', 'pt' => 'Alterar idioma', 'id' => 'Ubah bahasa', 'es' => 'Cambiar idioma', 'zh' => '更改语言', _ => 'Change language' };
  String get recipeShelf => switch (locale.languageCode) {
    'ar' => 'رف الوصفات', 'ja' => 'レシピ棚', 'pt' => 'A ESTANTE DE RECEITAS',
    'id' => 'RAK RESEP', 'es' => 'EL ESTANTE DE RECETAS', 'zh' => '食谱架',
    _ => 'THE RECIPE SHELF'
  };
  String get findFavourite => switch (locale.languageCode) {
    'ar' => 'اعثر على\nمفضلتك القادمة.', 'ja' => '次のお気に入りを\n見つけましょう。',
    'pt' => 'Encontre sua próxima\nreceita favorita.', 'id' => 'Temukan resep\nfavorit Anda berikutnya.',
    'es' => 'Encuentra tu próxima\nreceta favorita.', 'zh' => '发现你的\n下一道心头好。',
    _ => 'Find your next\nfavourite.'
  };
  String get searchHint => switch (locale.languageCode) {
    'ar' => 'ابحث عن وصفة أو مكوّن', 'ja' => 'レシピや材料を検索',
    'pt' => 'Buscar receitas ou ingredientes', 'id' => 'Cari resep atau bahan',
    'es' => 'Buscar recetas o ingredientes', 'zh' => '搜索食谱或食材',
    _ => 'Search recipes or ingredients'
  };
  String get emptyShelf => switch (locale.languageCode) {
    'ar' => 'لا توجد وصفات هنا', 'ja' => 'レシピがありません', 'pt' => 'Nenhuma receita aqui',
    'id' => 'Belum ada resep', 'es' => 'No hay recetas aquí', 'zh' => '这里还没有食谱',
    _ => 'Nothing on this shelf'
  };
  String get emptyShelfHint => switch (locale.languageCode) {
    'ar' => 'جرّب مكوّناً آخر أو امسح عوامل التصفية.', 'ja' => '別の材料を試すか、フィルターを解除してください。',
    'pt' => 'Tente outro ingrediente ou limpe os filtros.', 'id' => 'Coba bahan lain atau hapus filter.',
    'es' => 'Prueba otro ingrediente o borra los filtros.', 'zh' => '试试其他食材，或清除筛选条件。',
    _ => 'Try another ingredient or clear your filters.'
  };
  String get weekEyebrow => switch (locale.languageCode) {
    'ar' => 'أسبوع بطعم جميل', 'ja' => 'おいしい一週間に', 'pt' => 'UMA SEMANA CHEIA DE SABOR',
    'id' => 'PEKAN YANG LEZAT', 'es' => 'UNA SEMANA LLENA DE SABOR', 'zh' => '开启美味一周',
    _ => 'A WEEK THAT TASTES GOOD'
  };
  String get mealPlanner => switch (locale.languageCode) {
    'ar' => 'مخطط\nوجباتك.', 'ja' => 'あなたの\n献立プランナー。',
    'pt' => 'Seu planejador\nde refeições.', 'id' => 'Perencana\nmenu Anda.',
    'es' => 'Tu planificador\nde comidas.', 'zh' => '你的\n每周膳食计划。',
    _ => 'Your meal\nplanner.'
  };
  String get weekDescription => switch (locale.languageCode) {
    'ar' => 'سبعة أيام وأربع وجبات يومياً. خطط أسبوعك بطريقتك.',
    'ja' => '7日間、毎日4回の食事。自分らしく一週間を計画しましょう。',
    'pt' => 'Sete dias e quatro refeições por dia. Planeje sua semana do seu jeito.',
    'id' => 'Tujuh hari dan empat waktu makan setiap hari. Atur minggu Anda sendiri.',
    'es' => 'Siete días y cuatro comidas al día. Organiza tu semana a tu manera.',
    'zh' => '七天，每天四餐。按照自己的节奏安排一周。',
    _ => 'Seven days, four gentle prompts a day. Make the week your own.'
  };

  String category(String id, String fallback) {
    if (isHindi) return const {'all':'सभी व्यंजन','breakfast':'नाश्ता','lunch':'दोपहर का भोजन','dinner':'रात का भोजन','snacks':'हल्के नाश्ते'}[id] ?? fallback;
    if (isGujarati) return const {'all':'બધી વાનગીઓ','breakfast':'નાસ્તો','lunch':'બપોરનું ભોજન','dinner':'રાત્રિભોજન','snacks':'હળવો નાસ્તો'}[id] ?? fallback;
    final extra = <String, Map<String, String>>{
      'ja': {'all':'すべて','breakfast':'朝食','lunch':'昼食','dinner':'夕食','snacks':'軽食'},
      'pt': {'all':'Todas','breakfast':'Café da manhã','lunch':'Almoço','dinner':'Jantar','snacks':'Lanches'},
      'id': {'all':'Semua','breakfast':'Sarapan','lunch':'Makan siang','dinner':'Makan malam','snacks':'Camilan'},
      'es': {'all':'Todas','breakfast':'Desayuno','lunch':'Almuerzo','dinner':'Cena','snacks':'Aperitivos'},
      'zh': {'all':'全部','breakfast':'早餐','lunch':'午餐','dinner':'晚餐','snacks':'小吃'},
    }[locale.languageCode];
    if (extra != null) return extra[id] ?? fallback;
    if (!isArabic) return fallback;
    return switch (id) {
      'all' => 'كل الوصفات',
      'breakfast' => 'الإفطار',
      'lunch' => 'الغداء',
      'dinner' => 'العشاء',
      'snacks' => 'وجبات خفيفة',
      _ => fallback,
    };
  }

  String recipeCount(int count) => switch (locale.languageCode) {
    'ar' => '$count وصفة للتجربة', 'hi' => 'आज़माने के लिए $count व्यंजन',
    'gu' => 'આઝમાવવા માટે $count વાનગીઓ', 'ja' => '試せるレシピ $count 件',
    'pt' => '$count receitas para experimentar', 'id' => '$count resep untuk dicoba',
    'es' => '$count recetas para probar', 'zh' => '$count 道待尝试的食谱',
    _ => '$count ${count == 1 ? 'recipe' : 'recipes'} to try'
  };
}
AppLocalizations appStrings(BuildContext context) => AppLocalizations.of(context);

class _Delegate extends LocalizationsDelegate<AppLocalizations> {
  const _Delegate();
  @override
  bool isSupported(Locale locale) => AppLocale.isSupported(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture(AppLocalizations(AppLocale.normalize(locale)));
  @override
  bool shouldReload(_Delegate old) => false;
}
