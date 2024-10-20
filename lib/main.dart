import 'package:alfabetizando_tcc/src/models/categories.dart';
import 'package:alfabetizando_tcc/src/models/font.dart';
import 'package:alfabetizando_tcc/src/models/intern.dart';
import 'package:alfabetizando_tcc/src/models/user_preferences.dart';
import 'package:alfabetizando_tcc/src/pages/welcome_screen%20.dart';
import 'package:alfabetizando_tcc/src/providers/font_provider.dart';
import 'package:alfabetizando_tcc/src/providers/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:alfabetizando_tcc/src/models/user.dart' as AppUser;
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  final supabaseUrl = dotenv.get('URL');
  final supabaseAnonKey = dotenv.get('anonKey');

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  _registerHiveAdapters();

  final box = await Hive.openBox('MyCacheBox');

  await _syncData(box);
  final userResponse = await Supabase.instance.client.auth.getUser();
  AppUser.User? user;
  if (userResponse.user != null) {
    user = AppUser.User(
      id: userResponse.user!.id,
      email: userResponse.user!.email ?? '',
      name: userResponse.user!.userMetadata?['name'] ?? '',
      photoUrl: userResponse.user!.userMetadata?['avatar_url'] ?? '',
    );
  } else {
    user = AppUser.User(
      id: '',
      email: '',
      name: '',
      photoUrl: '',
    );
  }
  
  UserPreferences? userPreferences = await box.get('userPreferences');
  userPreferences ??= UserPreferences(fontSize: 16.0, defaultFontId: 'helvetica');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FontProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider(user!, userPreferences!)),
      ],
      child: MyApp(box: box),
    ),
  );
}

void _registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(CategoryAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(FontAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(CardsInternosAdapter());
  } else {
    if (kDebugMode) {
      print('Adapters já registrados');
    }
  }
}

Future<void> _syncData(Box box) async {
  try {
    final categories = await fetchCategories();
    await box.clear();
    for (var category in categories) {
      await box.put(category.id, category);
    }
  } catch (e) {
    if (kDebugMode) {
      print('Erro ao sincronizar dados: $e');
    }
  }
}

class MyApp extends StatelessWidget {
  final Box box;

  const MyApp({required this.box, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final fontFamily = userProvider.userPreferences.defaultFontId == 'helvetica'
            ? GoogleFonts.roboto().fontFamily
            : GoogleFonts.openSans().fontFamily;

        return MaterialApp(
          theme: ThemeData(
            textTheme: Theme.of(context).textTheme.apply(
              fontFamily: fontFamily,
              fontSizeFactor: userProvider.userPreferences.fontSize / 16,
            ),
          ),
          home: WelcomeScreen(box: box),
        );
      },
    );
  }
}
