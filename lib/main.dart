import 'package:alfabetizando_tcc/data/cards.dart';
import 'package:alfabetizando_tcc/screens/welcome_screen%20.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(
      fileName: ".env"); 
  final supabaseUrl = dotenv.get('URL');
  final supabaseAnonKey = dotenv.get('anonKey');

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce, 
  )
  );
  await Hive.initFlutter();
  Hive.registerAdapter(CategoryAdapter());
  final box = await Hive.openBox('MyCacheBox');
  await syncData(box);
  runApp( MyApp(box: box));
}

Future<void> syncData(Box box) async { 
  try {
    final categories = await fetchCategories();
    await box.clear(); 
    for (var category in categories) {
      await box.put(category.id, category); 
    }
  } catch (e) {
    print('Erro ao sincronizar dados: $e');
  }
}


class MyApp extends StatelessWidget {
  final Box box;
  const MyApp({required this.box});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: WelcomeScreen(box:box),
    );
  }
}
