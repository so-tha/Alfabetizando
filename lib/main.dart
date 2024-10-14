// lib/main.dart

import 'package:alfabetizando_tcc/src/models/font.dart';
import 'package:alfabetizando_tcc/src/models/intern.dart';
import 'package:alfabetizando_tcc/src/models/categories.dart';
import 'package:alfabetizando_tcc/src/pages/welcome_screen%20.dart';
// Remova o espaço no nome do arquivo
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:alfabetizando_tcc/src/providers/font_provider.dart'; // Make sure this import is correct

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carregar variáveis de ambiente
  await dotenv.load(fileName: ".env"); 
  final supabaseUrl = dotenv.get('URL');
  final supabaseAnonKey = dotenv.get('anonKey');

  // Inicializar Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, 
    )
  );

  // Inicializar Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path); // Inicialize Hive apenas uma vez com o caminho correto

  // Registrar adapters apenas se ainda não estiverem registrados
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(CategoryAdapter()); // typeId: 0
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(FontAdapter()); // typeId: 1
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(CardsInternosAdapter()); // typeId: 2
  } else {
    print('Adapters já registrados');
  }

  // Abrir Hive box
  final box = await Hive.openBox('MyCacheBox');

  // Sincronizar dados
  await syncData(box);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FontProvider()),
        // Add other providers here if needed
      ],
      child: MyApp(box: box),
    ),
  );
}

Future<void> syncData(Box box) async { 
  try {
    final categories = await fetchCategories(); // Certifique-se de que esta função está definida e importada corretamente
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
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: 'CustomFont', fontSize: 16),
        ),
        useMaterial3: true,
      ),
      home: WelcomeScreen(box: box),
    );
  }
}
